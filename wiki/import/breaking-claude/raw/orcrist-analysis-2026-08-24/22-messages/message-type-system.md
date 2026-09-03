# Message Type System

> Source: `src/utils/messages.ts` (5,512 lines), `src/types/message.ts`, `src/query.ts`

## Overview

The message type system defines how information flows through Claude Code — from API responses to UI rendering, from tool execution to session persistence. Messages are the universal currency of the conversation, and the normalization pipeline transforms raw API content into a structured format suitable for both API round-trips and UI display.

## Message Type Taxonomy

### Primary Message Types

```typescript
type Message =
  | AssistantMessage      // Model response
  | UserMessage           // User input / tool results
  | ProgressMessage       // Ephemeral UI state (NOT persisted)
  | AttachmentMessage     // Hook results, file attachments
  | SystemMessage         // System notifications
  | TombstoneMessage      // Placeholder for failed streaming
```

### AssistantMessage

```typescript
interface AssistantMessage {
  type: 'assistant'
  uuid: UUID
  timestamp: string
  requestId?: string
  message: {
    content: BetaContentBlock[]   // text, tool_use, thinking, etc.
    usage?: BetaUsage
    stop_reason?: BetaStopReason
    context_management?: object | null
  }
  isMeta?: boolean
  isVirtual?: boolean
  isApiErrorMessage?: boolean
  error?: SDKAssistantMessageError
  advisorModel?: string
  research?: unknown  // Internal only
}
```

### UserMessage

```typescript
interface UserMessage {
  type: 'user'
  uuid: UUID
  timestamp: string
  message: {
    content: string | ContentBlockParam[]  // text, tool_result, image
  }
  toolUseResult?: ToolUseResult
  mcpMeta?: MCPMeta
  isMeta?: boolean
  isVisibleInTranscriptOnly?: boolean
  isVirtual?: boolean
  imagePasteIds?: string[]
  origin?: MessageOrigin
}
```

### SystemMessage Subtypes

```typescript
type SystemMessage =
  | SystemCompactBoundaryMessage
  | SystemMicrocompactBoundaryMessage
  | SystemAPIErrorMessage
  | SystemApiMetricsMessage
  | SystemInformationalMessage
  | SystemLocalCommandMessage
  | SystemMemorySavedMessage
  | SystemPermissionRetryMessage
  | SystemBridgeStatusMessage
  | SystemAwaySummaryMessage
  | SystemStopHookSummaryMessage
  | SystemTurnDurationMessage
  | SystemScheduledTaskFireMessage
  | SystemAgentsKilledMessage
  | ToolUseSummaryMessage
```

### AttachmentMessage

```typescript
interface AttachmentMessage<T = Attachment> {
  type: 'attachment'
  uuid: UUID
  timestamp: string
  attachment: T  // HookAttachment, FileAttachment, etc.
}
```

Attachment types include:
- `hook_success`, `hook_blocking_error`, `hook_cancelled`, `hook_error_during_execution`
- `hook_non_blocking_error`, `hook_system_message`, `hook_additional_context`
- `hook_stopped_continuation`, `hook_permission_decision`
- File attachments, image pastes

### ProgressMessage

Ephemeral UI state — **never persisted to JSONL**:

```typescript
interface ProgressMessage {
  type: 'progress'
  uuid: UUID
  timestamp: string
  data: Progress  // Tool-specific progress data
  parentToolUseID?: string
}
```

### TombstoneMessage

Placeholder for orphaned messages from failed streaming:

```typescript
interface TombstoneMessage {
  type: 'tombstone'
  message: Message  // The orphaned message
}
```

## Content Block Types

### API Content Blocks (from Anthropic SDK)

| Type | Purpose | Delta Type |
|---|---|---|
| `text` | Text content | `text_delta` |
| `tool_use` | Tool invocation request | `input_json_delta` |
| `thinking` | Extended thinking output | `thinking_delta` + `signature_delta` |
| `redacted_thinking` | Redacted thinking (safety) | No delta (opaque) |
| `server_tool_use` | Server-side tool (advisor, search) | `input_json_delta` |
| `web_search_tool_result` | Web search results | N/A (atomic) |
| `mcp_tool_use` | MCP tool invocation | `input_json_delta` |
| `code_execution_tool_result` | Code execution results | N/A (atomic) |
| `connector_text` | Feature-gated connector text | `connector_text_delta` |
| `advisor_tool_result` | Advisor tool response | N/A (atomic) |
| `image` | Image content | N/A (atomic) |
| `document` | Document content | N/A (atomic) |

### User Content Blocks

| Type | Purpose |
|---|---|
| `text` | Text content |
| `tool_result` | Tool execution result (references tool_use by ID) |
| `image` | Base64-encoded image |
| `tool_reference` | Deferred tool definition |

## Message Normalization Pipeline

### `normalizeMessages()` — Split to Single Blocks

The core normalization splits multi-block messages into individual single-block messages:

```typescript
export function normalizeMessages(messages: Message[]): NormalizedMessage[] {
  let isNewChain = false
  return messages.flatMap(message => {
    switch (message.type) {
      case 'assistant': {
        isNewChain = isNewChain || message.message.content.length > 1
        return message.message.content.map((_, index) => ({
          type: 'assistant' as const,
          uuid: isNewChain ? deriveUUID(message.uuid, index) : message.uuid,
          message: { ...message.message, content: [_] },
          // ... preserve other fields
        }))
      }
      case 'user': {
        // Handle string content → wrap in text block
        if (typeof message.message.content === 'string') {
          return [{ ...message, message: { content: [{ type: 'text', text: message.message.content }] } }]
        }
        // Split multi-block user messages
        isNewChain = isNewChain || message.message.content.length > 1
        return message.message.content.map((_, index) => ({ ... }))
      }
    }
  })
}
```

**UUID derivation** for split messages:

```typescript
export function deriveUUID(parentUUID: UUID, index: number): UUID {
  const hex = index.toString(16).padStart(12, '0')
  return `${parentUUID.slice(0, 24)}${hex}` as UUID
}
```

### `normalizeMessagesForAPI()` — Full Pipeline

This 10+ step pipeline prepares messages for the Anthropic API:

1. **Filter synthetic messages** — Progress, certain system messages removed
2. **Reorder attachments** — Bubble attachments to top of message list
3. **Strip unavailable tool references** — Remove `tool_reference` blocks for tools not in current toolset
4. **Inject turn boundary markers** — Append `TOOL_REFERENCE_TURN_BOUNDARY = 'Tool loaded.'` after tool definitions
5. **Merge adjacent messages** — Consecutive user or assistant messages merged
6. **Relocate text siblings** — Move text from `tool_reference` messages
7. **Filter orphaned thinking-only messages** — Remove thinking blocks without context
8. **Filter trailing whitespace/thinking** — Clean up empty trailing content
9. **Add message ID tags** — Inject `[id:xxxx]` tags for snip tool visibility
10. **Validate images** — Check size, format, and `API_MAX_MEDIA_PER_REQUEST` limit

## Tool Use / Tool Result Pairing

### `ensureToolResultPairing()`

Fixes orphaned `tool_use` blocks that have no matching `tool_result`:

```typescript
export const SYNTHETIC_TOOL_RESULT_PLACEHOLDER =
  '[Tool result missing due to internal error]'
```

This placeholder satisfies the API's structural requirement that every `tool_use` must have a `tool_result`. Exported so HFI (training data) submission can reject any payload containing it.

### Type Guards

```typescript
export function isToolUseRequestMessage(message: Message): message is ToolUseRequestMessage {
  return message.type === 'assistant' &&
    message.message.content.some(_ => _.type === 'tool_use')
}

export function isToolUseResultMessage(message: Message): message is ToolUseResultMessage {
  return message.type === 'user' &&
    ((Array.isArray(message.message.content) &&
      message.message.content[0]?.type === 'tool_result') ||
     Boolean(message.toolUseResult))
}
```

## Message ID System

### Short Message IDs for Snip Tool

```typescript
export function deriveShortMessageId(uuid: string): string {
  const hex = uuid.replace(/-/g, '').slice(0, 10)
  return parseInt(hex, 16).toString(36).slice(0, 6)
}
```

Produces 6-character base36 IDs (e.g., `[id:abc123]`) for the snip tool to reference specific messages.

## UI Message Reordering

### `reorderMessagesInUI()`

Groups messages by tool use ID for correct display ordering:

```
Group: { toolUse, preHooks[], toolResult, postHooks[] }

Output order: tool_use → PreToolUse hooks → tool_result → PostToolUse hooks
```

Standalone messages (non-tool-related) pass through in original order. API error messages are deduplicated to keep only the last one.

## Image & Attachment Handling

### Image Validation

`validateImagesForAPI()` checks:
- File size limits
- Supported formats (JPEG, PNG, GIF, WebP)
- Maximum images per request (`API_MAX_MEDIA_PER_REQUEST`)
- Base64 encoding validity

### Attachment Types

```typescript
type Attachment =
  | HookAttachment
  | HookPermissionDecisionAttachment
  | FileAttachment
  | ImageAttachment
  | memoryHeader
```

## Special Message Constants

```typescript
export const INTERRUPT_MESSAGE = '[Request interrupted by user]'
export const INTERRUPT_MESSAGE_FOR_TOOL_USE = '[Request interrupted by user for tool use]'
export const CANCEL_MESSAGE = "The user doesn't want to take this action right now..."
export const REJECT_MESSAGE = "The user doesn't want to proceed with this tool use..."
export const SUBAGENT_REJECT_MESSAGE = 'Permission for this tool use was denied...'
export const NO_RESPONSE_REQUESTED = 'No response requested.'
export const SYNTHETIC_MODEL = '<synthetic>'
```

### Memory Correction Hint

```typescript
const MEMORY_CORRECTION_HINT =
  "\n\nNote: The user's next message may contain a correction or preference..."
```

Appended to rejection messages when auto-memory is enabled, encouraging the model to learn from corrections.

### Denial Workaround Guidance

```typescript
export const DENIAL_WORKAROUND_GUIDANCE =
  `IMPORTANT: You *may* attempt to accomplish this action using other tools...` +
  `But you *should not* attempt to work around this denial in malicious ways...`
```

## Key Insights for Harness Engineers

1. **Messages are the universal data structure** — Every piece of information flows as a typed message through a consistent pipeline.

2. **Normalization splits multi-block into single-block** — This enables progressive rendering and independent processing of each content block.

3. **Deterministic UUID derivation** — Split messages get stable UUIDs from parent + index, ensuring consistent references across normalization passes.

4. **Progress messages are second-class** — They're explicitly excluded from persistence and the parentUuid chain to prevent chain corruption.

5. **Synthetic tool results fill gaps** — Orphaned tool_use blocks get placeholder results to maintain API structural requirements.

6. **Message ID tags enable snip tool** — Short base36 IDs are injected into the text for the model to reference specific messages.

7. **Denial guidance is built into messages** — Permission rejection messages include explicit instructions about workarounds and escalation.
