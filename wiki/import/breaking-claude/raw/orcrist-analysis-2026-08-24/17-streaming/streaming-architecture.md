# Streaming Architecture

> Source: `src/services/api/claude.ts` (3,419 lines), `src/utils/messages.ts` (5,512 lines), `src/query.ts`, `src/services/tools/StreamingToolExecutor.ts`

## Overview

Claude Code's streaming architecture is an **event-driven, generator-based pipeline** that processes SSE events from the Anthropic API, accumulates partial message state, yields normalized messages to the query loop, and executes tools concurrently during streaming. The entire flow is built on `async function*` generators — the query engine consumes yielded `Message` objects and `StreamEvent` objects in a single for-await loop.

The core streaming loop lives in `claude.ts:1940-2304` — a single `for await (const part of stream)` switch statement that processes every SSE event type.

## SSE Event Parsing

The Anthropic SDK returns a `Stream<BetaRawMessageStreamEvent>` object. Events are processed sequentially in this switch:

```typescript
for await (const part of stream) {
  resetStreamIdleTimer()
  switch (part.type) {
    case 'message_start':       // Initialize partial message + usage
    case 'content_block_start': // Create empty content block by type
    case 'content_block_delta': // Append delta data to content block
    case 'content_block_stop':  // Finalize block → yield AssistantMessage
    case 'message_delta':       // Write usage/stopReason to last message
    case 'message_stop':        // Stream end (no-op)
  }
  yield { type: 'stream_event', event: part, ...ttftMs }
}
```

### Event Processing Details

**`message_start`** (line 1980-1993):
- Sets `partialMessage = part.message` (message skeleton with zero tokens)
- Captures Time-To-First-Token: `ttftMs = Date.now() - start`
- Updates cumulative usage from `part.message.usage`
- Internal-only: captures `research` field for Anthropic employees

**`content_block_start`** (line 1995-2051):
Creates empty content blocks indexed by `part.index`:

| Content Block Type | Initialization |
|---|---|
| `text` | `{ ...part.content_block, text: '' }` — SDK sometimes duplicates text in start+delta, so text is zeroed |
| `tool_use` | `{ ...part.content_block, input: '' }` — JSON accumulates as string |
| `server_tool_use` | `{ ...part.content_block, input: '' }` — Same pattern, for server-side tools |
| `thinking` | `{ thinking: '', signature: '' }` — Signature initialized even if never arrives |
| Default | `{ ...part.content_block }` — Shallow copy for immutability |

**`content_block_delta`** (line 2053-2169):
Appends delta data to the content block at `part.index`:

| Delta Type | Accumulation |
|---|---|
| `text_delta` | `contentBlock.text += delta.text` |
| `input_json_delta` | `contentBlock.input += delta.partial_json` |
| `thinking_delta` | `contentBlock.thinking += delta.thinking` |
| `signature_delta` | `contentBlock.signature = delta.signature` |
| `citations_delta` | TODO — not yet handled |
| `connector_text_delta` | Feature-gated: `contentBlock.connector_text += delta.connector_text` |

Error handling: Every delta type validates the content block type matches. Mismatches throw immediately (logged as `tengu_streaming_error` analytics events).

**`content_block_stop`** (line 2171-2211):
Finalizes the content block and **yields an `AssistantMessage`**:

```typescript
const m: AssistantMessage = {
  message: {
    ...partialMessage,
    content: normalizeContentFromAPI([contentBlock], tools, agentId),
  },
  requestId: streamRequestId,
  type: 'assistant',
  uuid: randomUUID(),
  timestamp: new Date().toISOString(),
}
newMessages.push(m)
yield m
```

Key insight: **One message is yielded per content block**, not per API response. A single API response with 3 tool uses + 2 text blocks yields 5 `AssistantMessage` objects.

**`message_delta`** (line 2213-2293):
Writes final `usage` and `stopReason` back to the **last yielded message via direct mutation**:

```typescript
stopReason = part.delta.stop_reason
const lastMsg = newMessages.at(-1)
if (lastMsg) {
  lastMsg.message.usage = usage
  lastMsg.message.stop_reason = stopReason
}
```

Why direct mutation instead of replacement: "The transcript write queue holds a reference to `message.message` and serializes it lazily (100ms flush interval). Object replacement would disconnect the queued reference."

Also handles:
- Cost calculation: `costUSD += addToTotalSessionCost(...)`
- Refusal detection via `getErrorMessageIfRefusal()`
- `max_tokens` stop → yields error message for recovery
- `model_context_window_exceeded` → reuses max_tokens recovery path

## Stream Watchdog & Idle Detection

Two-tier timer system (line 1897-1928):

1. **Warning timer** (`STREAM_IDLE_WARNING_MS`): Logs diagnostic when no chunks received
2. **Abort timer** (`STREAM_IDLE_TIMEOUT_MS`): Aborts the stream entirely

```typescript
let streamIdleWarningTimer = setTimeout(...)
let streamIdleTimer = setTimeout(() => {
  streamIdleAborted = true
  releaseStreamResources()  // Aborts the HTTP request
}, STREAM_IDLE_TIMEOUT_MS)
```

Both timers are **reset on every chunk** via `resetStreamIdleTimer()`. If the abort fires, the stream loop exits and throws, triggering the retry engine's non-streaming fallback.

### Stall Detection (line 1936-1966)

Tracks gaps between events after the first chunk:

```typescript
const STALL_THRESHOLD_MS = 30_000  // 30 seconds
if (lastEventTime !== null) {
  const timeSinceLastEvent = now - lastEventTime
  if (timeSinceLastEvent > STALL_THRESHOLD_MS) {
    stallCount++
    totalStallTime += timeSinceLastEvent
    logEvent('tengu_streaming_stall', { ... })
  }
}
```

## Streaming Fallback

When streaming fails (idle timeout, no events, incomplete stream), the system falls back to non-streaming retry:

```typescript
// No message_start event received at all
if (!partialMessage || (newMessages.length === 0 && !stopReason)) {
  throw new Error('Stream ended without receiving any events')
}
```

This throw lands in the `catch` block in the retry wrapper (`withRetry.ts`), which retries the entire API call in non-streaming mode.

## Thinking Block Handling

Thinking configuration (claude.ts ~1596-1630):

```typescript
if (hasThinking && modelSupportsThinking(options.model)) {
  if (modelSupportsAdaptiveThinking(options.model)) {
    thinking = { type: 'adaptive' }  // Model decides budget
  } else {
    thinking = { type: 'enabled', budget_tokens: thinkingBudget }
  }
}
```

During streaming, thinking blocks accumulate `thinking_delta` events into `contentBlock.thinking` and `signature_delta` into `contentBlock.signature`. The UI switches to "thinking mode" via `onSetStreamMode('thinking')` on `content_block_start` when the block type is `thinking` or `redacted_thinking`.

Thinking blocks are **preserved across turns** — they cannot be the last message in the API payload and must accompany the tool_use → tool_result → next assistant message chain.

## Message Normalization Pipeline

The `normalizeMessages()` function (messages.ts:731-823) splits multi-block messages into individual messages:

1. Each content block becomes its own message with a single-element content array
2. UUIDs are derived deterministically: `deriveUUID(parentUUID, index)` — first 24 chars of parent + zero-padded hex index
3. The `isNewChain` flag ensures that once ANY message requires new UUIDs, all subsequent messages also get new UUIDs

```typescript
export function deriveUUID(parentUUID: UUID, index: number): UUID {
  const hex = index.toString(16).padStart(12, '0')
  return `${parentUUID.slice(0, 24)}${hex}` as UUID
}
```

### Full Normalization for API (messages.ts)

`normalizeMessagesForAPI()` applies a 10+ step pipeline:

1. **Filter synthetic messages** — progress, certain system messages removed
2. **Reorder attachments** — bubble up to top of message list
3. **Strip unavailable tool references** — remove tool_reference blocks for tools not in current toolset
4. **Inject turn boundary markers** — add `TOOL_REFERENCE_TURN_BOUNDARY = 'Tool loaded.'`
5. **Merge adjacent messages** — consecutive user messages or assistant messages merged
6. **Relocate text siblings** — move text from tool_reference messages
7. **Filter orphaned thinking-only messages** — remove thinking blocks without context
8. **Filter trailing whitespace/thinking** — clean up empty trailing content
9. **Add message ID tags** — inject `[id:xxx]` for snip tool visibility
10. **Validate images** — check size, format, count limits

### Tool Use / Tool Result Pairing

`ensureToolResultPairing()` fixes orphaned tool_use blocks that have no matching tool_result. Inserts a synthetic placeholder:

```typescript
export const SYNTHETIC_TOOL_RESULT_PLACEHOLDER =
  '[Tool result missing due to internal error]'
```

### Turn Boundary Injection

When tool search is enabled, a `Tool loaded.` text block is appended after tool references:

```typescript
const TOOL_REFERENCE_TURN_BOUNDARY = 'Tool loaded.'
```

This signals to the model that tool definitions are complete and the next user message is a real prompt, not a tool definition continuation.

## Message Type Taxonomy

```typescript
type Message =
  | AssistantMessage     // Model response (text, tool_use, thinking)
  | UserMessage          // User input (text, tool_result, images)
  | ProgressMessage      // Ephemeral UI state (NOT persisted)
  | AttachmentMessage    // Hook results, file attachments
  | SystemMessage        // Compact boundaries, errors, info
  | TombstoneMessage     // Placeholder for failed streaming
```

**Critical distinction**: `ProgressMessage` is explicitly NOT a transcript message — it's ephemeral UI state that must not be persisted to JSONL or participate in the `parentUuid` chain. Including them caused chain forks that orphaned real messages on resume.

## UI Message Reordering

`reorderMessagesInUI()` (messages.ts:855-1026) groups messages by tool use ID for display:

```
Group structure: { toolUse, preHooks[], toolResult, postHooks[] }
```

Messages are reconstructed in order: tool_use → PreToolUse hooks → tool_result → PostToolUse hooks. Standalone messages (non-tool-related) pass through in original order.

## Key Insights for Harness Engineers

1. **Yield per content block, not per response** — The API response is decomposed into individual messages at content_block_stop boundaries. This enables progressive rendering and concurrent tool execution.

2. **Direct mutation for late-arriving data** — `message_delta` arrives after all content blocks and mutates the last yielded message in-place. This is necessary because the transcript writer holds a reference.

3. **Two-tier idle detection** — Warning → abort with configurable thresholds. The abort triggers non-streaming fallback.

4. **Deterministic UUID derivation** — Normalized messages get stable UUIDs from parent + index, ensuring consistent references across normalization passes.

5. **Progress messages are poison** — They must never enter the parentUuid chain. Historical bugs (#14373, #23537) caused chain forks when progress entries participated in the chain.

6. **Streaming is the only first-class path** — Non-streaming is a fallback, not an alternative. The retry engine switches to non-streaming only when streaming fails.

7. **Tool input accumulates as raw string** — JSON is never parsed during streaming. It's accumulated as a string via `input_json_delta` and parsed only when the tool executes.
