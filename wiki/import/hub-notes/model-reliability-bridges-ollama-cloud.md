---
title: Model Reliability Problem — Claude Code Bridges & Ollama Cloud Models
aliases:
  - model behavior profiles
  - stream hangs
  - reasoning field
  - ollama cloud quirks
  - bridge reliability
tags:
  - infrastructure
  - claude-code
  - ollama-cloud
  - universal-provider-bridge
  - debugging
  - model-behavior
created: 2026-07-01
status: active
---

# Model Reliability Problem — Bridges & Ollama Cloud

Two separate bridges (Hermes passthrough and Claude Code UPB) connect to Ollama Cloud (`ollama.com/v1`). The bridges handle protocol translation and auth correctly, but **model behavior variability** causes intermittent failures that look like bridge bugs. This note catalogs the known issues, root causes, and proposed architecture for reliable operation with any model.

---

## Problem Catalog

### 1. Reasoning Field Mismatch (FIXED)

**Symptom:** Claude Code shows empty responses, tool calls silently fail, model appears to do nothing.

**Root cause:** GLM-5.2, DeepSeek-V4, Qwen3.5, and Kimi models return output in the `reasoning` field of OpenAI SSE chunks, leaving `content` empty:

```json
{"delta": {"role": "assistant", "content": "", "reasoning": "1. **Analyze the Request:**..."}}
```

The UPB's `AnthropicStreamTransformer` and `translateResponse` only read `delta.content` / `message.content`. When `content` is empty, no Anthropic content blocks are emitted. Claude Code receives an empty message.

**Fix applied (2026-07-01):**
- `src/types/openai.ts` — Added `reasoning` and `reasoning_content` to delta/message types
- `src/utils/stream.ts` — Stream transformer falls back to `reasoning` then `reasoning_content` when `content` is empty
- `src/utils/translate.ts` — Non-streaming translator same fallback

**Files changed:**
```
~/shared-local/reports/claude-universal/src/types/openai.ts
~/shared-local/reports/claude-universal/src/utils/stream.ts
~/shared-local/reports/claude-universal/src/utils/translate.ts
```

**Rebuild:** `cd ~/shared-local/reports/claude-universal && npx tsc`

---

### 2. Stream Hangs — No Idle Timeout (NOT YET FIXED)

**Symptom:** Claude Code session works fine for several turns, then freezes — no response, no error, just stops. Can last 10+ minutes before anything happens.

**Root cause:** The UPB's stream reader in `src/index.ts` has no idle timeout. The pump function reads chunks from `providerRes.body.getReader()` in a `while(true)` loop:

```typescript
// src/index.ts:189-198
const pump = async (): Promise<void> => {
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) { transformer.end(); break; }
      transformer.write(Buffer.from(value));
    }
  } catch (err) {
    console.error('[stream] Provider stream error:', (err as Error).message);
    transformer.destroy(err as Error);
  }
};
```

The `AbortSignal.timeout(adapter.timeout)` on the fetch only sets a **total** timeout (600 seconds for ollama-local). If Ollama Cloud sends a few chunks and then the TCP connection goes silent (but doesn't close), `reader.read()` hangs forever. Neither the proxy nor Claude Code knows anything is wrong until the 10-minute total timeout fires.

**Why this happens with reasoning models:** Models like DeepSeek-V4, Qwen3.5, and GLM-5.2 produce long reasoning chains. Between chunks, the upstream may pause for seconds or minutes while generating. If the pause exceeds the TCP keep-alive window or a network hop drops the connection mid-stream, the reader just blocks.

**Impact:** This is the likely explanation for "session runs fine for a while and then stops." The model streams a few reasoning chunks, connection silently drops, and both proxy and Claude Code wait indefinitely.

**Proposed fix:** Add a per-chunk idle timeout to the stream reader. If no chunk arrives for N seconds, abort the fetch and retry. See "Model Profile Architecture" below for per-model configuration.

---

### 3. Intermittent Tool-Use Failures

**Symptom:** Claude Code asks the model to do something (edit a file, run a command), model responds with reasoning text about what it would do, but doesn't actually execute the tool. Claude Code shows the reasoning text and returns to prompt — no action taken.

**Root cause:** Some models on Ollama Cloud produce tool_use unreliably. For the same prompt:
- **Run 1:** Model outputs `tool_calls: [{function: {name: "write_to_file", arguments: "..."}}]` — works
- **Run 2:** Model outputs only `reasoning: "I should edit the file at ~/.tmux.conf.local..."` + `finish_reason: "stop"` — no action

The model sometimes "thinks about" the action without executing it. This is a model-level issue, not a bridge-level issue.

**Why it's worse with CLM-5.2:** GLM-5.2 appears to have a "reasoning-first" architecture where it produces a reasoning pass, then optionally produces tool calls. The tool-call pass is less reliable than the reasoning pass.

**Proposed fix:** Model profiles with `toolUseReliability` flags. For "intermittent" models, the UPB can:
1. Inject a system prompt note: "You MUST use an available tool to take action"
2. Optionally retry once when a tool was expected but not delivered

---

## Per-Model Behavior Catalog

Measured on 2026-07-01 through `ollama.com/v1` (OpenAI Chat Completions).

| Model | Output Field | `content` | `reasoning` | Tool Use | Stream Stability | Notes |
|---|---|---|---|---|---|---|
| **mistral-large-3:675b** | `content` | ✓ filled | N/A | Reliable | Smooth | Best non-reasoning model. Clean output. |
| **gemini-3-flash-preview** | `content` | ✓ filled | N/A | Reliable | Smooth | Fast, reliable, no reasoning noise. |
| **deepseek-v4-pro** | `reasoning` | "" (empty) | ✓ filled | Usually works | Reasoning-heavy | Primary workhorse. Long reasoning chains. |
| **deepseek-v4-flash** | `reasoning` | "" (empty) | ✓ filled | Usually works | Faster reasoning | Good fallback to v4-pro. |
| **glm-5.2** | `reasoning` | "" (empty) | ✓ filled | Intermittent | Gaps between chunks | Tool use sometimes fails silently. |
| **glm-5.1** | `reasoning` | "" (empty) | ✓ filled | Intermittent | Similar to 5.2 | Older GLM, similar behavior. |
| **qwen3.5:397b** | `reasoning` | "" (empty) | ✓ filled | Mostly works | Can stall mid-stream | Very long reasoning, high latency. |
| **qwen3-coder:480b** | `reasoning` | "" (empty) | ✓ filled | Mostly works | Similar to qwen3.5 | Coding-specialized, slower. |
| **qwen3-coder-next** | `reasoning` | "" (empty) | ✓ filled | Mostly works | Similar | Newer coder variant. |
| **kimi-k2.7-code** | `reasoning` | "" (empty) | ✓ filled | Intermittent | Reasoning-heavy | Coding-specialized, tool use hit-or-miss. |
| **kimi-k2.6** | `reasoning` | "" (empty) | ✓ filled | Intermittent | Similar | Older Kimi variant. |
| **minimax-m3** | `reasoning` | "" (empty) | ✓ filled | ? | ? | Not yet tested. |
| **minimax-m2.7** | `reasoning` | "" (empty) | ✓ filled | ? | ? | Older MiniMax variant. |
| **devstral-2:123b** | ? | ? | ? | ? | ? | Not yet tested. |
| **gemma4:31b** | `content` | ✓ filled | N/A | ? | ? | Google's open model, smaller. |
| **gpt-oss:120b** | ? | ? | ? | ? | ? | Not yet tested. |
| **nemotron-3-super** | ? | ? | ? | ? | ? | NVIDIA model. |
| **nemotron-3-ultra** | ? | ? | ? | ? | ? | NVIDIA model. |

### Key insight

**All reasoning-first models** (DeepSeek, GLM, Qwen, Kimi) on Ollama Cloud follow the same pattern:
- Output goes to `reasoning` field, `content` is empty
- Reasoning text includes thinking + intended action
- Tool calls are separate from reasoning, produced after reasoning completes
- Stream chunks may have long gaps (seconds to tens of seconds) between them

**Non-reasoning models** (Mistral, Gemini, Gemma) put output in `content` and work correctly without fixes.

---

## Proposed Architecture: Model Profiles

Instead of one generic `ollama-local` adapter with hardcoded flags, give each model a behavior profile that the UPB uses at translation time.

### Profile schema

```typescript
interface ModelProfile {
  modelId: string;                    // e.g. "glm-5.2"
  outputField: "content" | "reasoning" | "both";
  toolUseReliability: "reliable" | "intermittent" | "none";
  streamIdleTimeoutMs: number;        // Max time between chunks before abort
  streamTotalTimeoutMs: number;       // Total timeout override
  maxTokensHint: number;              // Suggested max_tokens
  stripReasoningFromOutput: boolean;  // Hide reasoning from Claude Code
  stripReasoningFromRequest: boolean; // Don't ask model for thinking
  retryOnEmptyResponse: boolean;      // Retry if response has no content/tools
  systemNote: string | null;          // Injected into system prompt
}
```

### Example profiles

```typescript
const MODEL_PROFILES: Record<string, ModelProfile> = {
  // ── Non-reasoning models (best experience) ──
  "mistral-large-3:675b": {
    modelId: "mistral-large-3:675b",
    outputField: "content",
    toolUseReliability: "reliable",
    streamIdleTimeoutMs: 30_000,     // 30s idle timeout
    streamTotalTimeoutMs: 300_000,   // 5 min total
    maxTokensHint: 8192,
    stripReasoningFromOutput: false,
    stripReasoningFromRequest: false,
    retryOnEmptyResponse: false,
    systemNote: null,
  },

  // ── Reasoning models (need more care) ──
  "deepseek-v4-pro": {
    modelId: "deepseek-v4-pro",
    outputField: "reasoning",
    toolUseReliability: "reliable",
    streamIdleTimeoutMs: 120_000,    // 2 min idle (long reasoning pauses)
    streamTotalTimeoutMs: 600_000,   // 10 min total
    maxTokensHint: 16384,
    stripReasoningFromOutput: false,  // Keep reasoning — it contains useful context
    stripReasoningFromRequest: true,  // Don't request Anthropic thinking blocks
    retryOnEmptyResponse: true,       // Retry if model returns nothing
    systemNote: "You are a capable coding assistant. Use available tools to take action.",
  },

  "glm-5.2": {
    modelId: "glm-5.2",
    outputField: "reasoning",
    toolUseReliability: "intermittent",  // KEY: tool use is hit-or-miss
    streamIdleTimeoutMs: 90_000,     // 90s idle
    streamTotalTimeoutMs: 600_000,
    maxTokensHint: 8192,
    stripReasoningFromOutput: false,
    stripReasoningFromRequest: true,
    retryOnEmptyResponse: true,
    systemNote: "You MUST use an available tool to take action. Do not just describe what you would do — actually do it.",
  },

  "qwen3.5:397b": {
    modelId: "qwen3.5:397b",
    outputField: "reasoning",
    toolUseReliability: "reliable",
    streamIdleTimeoutMs: 120_000,    // Very long reasoning pauses
    streamTotalTimeoutMs: 900_000,   // 15 min total
    maxTokensHint: 16384,
    stripReasoningFromOutput: true,   // Hide reasoning — it's verbose and mostly noise
    stripReasoningFromRequest: true,
    retryOnEmptyResponse: true,
    systemNote: null,
  },

  // ── Known-unreliable models ──
  "kimi-k2.7-code": {
    modelId: "kimi-k2.7-code",
    outputField: "reasoning",
    toolUseReliability: "intermittent",
    streamIdleTimeoutMs: 60_000,
    streamTotalTimeoutMs: 600_000,
    maxTokensHint: 8192,
    stripReasoningFromOutput: false,
    stripReasoningFromRequest: true,
    retryOnEmptyResponse: true,
    systemNote: "You MUST use an available tool to take action.",
  },
};
```

### What each profile flag fixes

| Flag | Problem it addresses |
|---|---|
| `outputField` | Reasoning field mismatch (#1) |
| `streamIdleTimeoutMs` | Stream hangs — TCP silence (#2) |
| `toolUseReliability` + `systemNote` | Intermittent tool-use failures (#3) |
| `retryOnEmptyResponse` | Models that sometimes return nothing |
| `stripReasoningFromOutput` | Noise reduction for verbose reasoning |
| `stripReasoningFromRequest` | Prevent asking for Anthropic thinking (doesn't map to OpenAI well) |
| `maxTokensHint` | Model-specific context limits |

---

## Stream Idle Timeout — Implementation Sketch

The highest-priority fix. Add to `src/index.ts`:

```typescript
// After: const reader = providerRes.body.getReader();
let lastChunkTime = Date.now();
const IDLE_TIMEOUT_MS = modelProfile.streamIdleTimeoutMs;

const idleTimer = setInterval(() => {
  if (Date.now() - lastChunkTime > IDLE_TIMEOUT_MS) {
    console.error(`[stream] Idle timeout after ${IDLE_TIMEOUT_MS}ms — no chunks received`);
    reader.cancel('idle_timeout');
    clearInterval(idleTimer);
  }
}, IDLE_TIMEOUT_MS / 2);

const pump = async (): Promise<void> => {
  try {
    while (true) {
      const { done, value } = await reader.read();
      lastChunkTime = Date.now();
      if (done) { clearInterval(idleTimer); transformer.end(); break; }
      transformer.write(Buffer.from(value));
    }
  } catch (err) {
    clearInterval(idleTimer);
    console.error('[stream] Provider stream error:', (err as Error).message);
    transformer.destroy(err as Error);
  }
};
```

When the idle timeout fires, the `reader.cancel()` causes `reader.read()` to throw, caught by the catch block. The retry loop in `_forward` can then retry the request with a fresh stream.

---

## Response Validation — Implementation Sketch

Before forwarding a response to Claude Code, validate it won't cause silent failures:

```typescript
function validateAndRepair(response: AnthropicResponse): AnthropicResponse {
  // If response has no content blocks (text or tool_use), it's a silent failure
  if (response.content.length === 0) {
    // Signal to retry by throwing a retryable error
    throw new RetryableError('Empty response from model — retrying');
  }

  // If model sent reasoning as text but intended a tool call,
  // check if the text contains tool-like patterns
  // (e.g., "I should run: ls /tmp" → could be a missed tool call)
  // This is a heuristic — not perfect, but better than silent failure

  return response;
}
```

---

## Files Map — Everything Affected

```
~/shared-local/reports/claude-universal/
├── src/
│   ├── index.ts                     # Main server — needs idle timeout + profile support
│   ├── utils/
│   │   ├── stream.ts                # Stream transformer — reasoning fix DONE
│   │   ├── translate.ts             # Request/response translator — reasoning fix DONE
│   │   └── errors.ts                # Error classification — needs RetryableError
│   ├── types/
│   │   └── openai.ts                # OpenAI types — reasoning fields added DONE
│   ├── adapters/
│   │   ├── registry.ts              # Adapter registry — needs ModelProfile support
│   │   └── types.ts                 # Adapter types — needs ModelProfile
│   └── middleware/
│       └── config.ts                # Provider config — needs model profile loading
└── dist/                            # Compiled output (rebuild with: npx tsc)
```

---

## Quick Reference — Current Bridge States

```bash
# Health checks
curl http://localhost:8546/health    # Claude UPB — deepseek-v4-pro
curl http://localhost:8579/health    # Claude UPB — glm-5.2 (with reasoning fix)
curl http://localhost:8699/health    # Hermes Bridge — all models

# Rebuild UPB after source changes
cd ~/shared-local/reports/claude-universal && npx tsc

# Restart a specific UPB proxy
# Kill old:
kill $(cat /tmp/claude-ollama-proxy-<PORT>.pid)
# Start new (example for :8579 / glm-5.2):
env UPB_PROVIDER=ollama-local UPB_BASE_URL=https://ollama.com/v1 \
    UPB_API_KEY=$(grep -v '^#' ~/.hermes/.env | grep OLLAMA_API_KEY= | cut -d= -f2-) \
    UPB_MODEL_MAP='{"claude-sonnet-4-6":"glm-5.2",...}' \
    PORT=8579 LOCAL_SECRET=claude-ollama-poser \
    nohup node ~/shared-local/reports/claude-universal/dist/index.js \
    > /tmp/claude-ollama-proxy-8579.log 2>&1 &

# Hermes Bridge management
hermes-bridge status
hermes-bridge restart
hermes-bridge logs

# Direct model test (bypass bridges)
OLLAMA_KEY=$(grep -v '^#' ~/.hermes/.env | grep OLLAMA_API_KEY= | cut -d= -f2-)
curl -s https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"<model-id>","messages":[{"role":"user","content":"Say: ok"}],"max_tokens":10}'
```

---

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-30 | Built Hermes passthrough bridge (Python) instead of extending UPB | Hermes already speaks OpenAI — no translation needed. Simpler to debug. |
| 2026-06-30 | Hermes bridge port 8699 — fixed, not per-model | Hermes uses one base_url, model is selected in config.yaml. |
| 2026-07-01 | Added `reasoning` fallback to UPB stream transformer | GLM-5.2 session produced empty responses — reasoning was silently discarded. |
| 2026-07-01 | Kept two separate bridges instead of unifying | Different protocols (Anthropic vs OpenAI passthrough), different management models. |
| 2026-07-01 | Proposed Model Profile system | Per-model behavior varies too much for one adapter. Need configuration, not code. |

---

*Created: 2026-07-01 | This is a living document — update per-model behavior catalog as new models are tested*
