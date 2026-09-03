---
title: UPB Reasoning Field Fix — GLM-5.2 / Reasoning Models
tags:
  - bugfix
  - universal-provider-bridge
  - claude-code
  - ollama-cloud
created: 2026-07-01
---

# UPB Reasoning Field Fix

## Symptom

Claude Code sessions using reasoning models (GLM-5.2, DeepSeek-V4, Qwen3.5, Kimi series) through the UPB would:
- Appear to brew/think for several minutes
- Then show a new prompt with no response at all
- Tool calls (like file edits) silently failed
- The user's message appeared to be ignored

## Root Cause

Ollama Cloud's reasoning models return their output in the `reasoning` field of the OpenAI streaming delta, leaving `content` empty:

```json
{"delta": {"role": "assistant", "content": "", "reasoning": "1. **Analyze the Request:**..."}}
```

The UPB's `AnthropicStreamTransformer` and `translateResponse` only read `delta.content` / `message.content`. When content is empty, no text deltas or content blocks are emitted. The Anthropic response arrives with empty content — Claude Code shows nothing.

## Fix (2026-07-01)

Three files modified:

### 1. `src/types/openai.ts`
Added `reasoning` and `reasoning_content` fields to:
- `OpenAIStreamChoice.delta`
- `OpenAIChoice.message`
- `OpenAIAssistantMessage`

### 2. `src/utils/stream.ts` — Streaming path
```typescript
// Before:
const text = delta.content;

// After:
const deltaAny = delta as Record<string, unknown>;
const text = delta.content
  || (deltaAny.reasoning as string | null | undefined)
  || (deltaAny.reasoning_content as string | null | undefined)
  || null;
```

### 3. `src/utils/translate.ts` — Non-streaming path
```typescript
// Before:
if (choice?.message?.content) {
  content.push({ type: 'text', text: choice.message.content });
}

// After:
const textContent = choice?.message?.content
  || choice?.message?.reasoning
  || choice?.message?.reasoning_content
  || null;
if (textContent) { content.push({ type: 'text', text: textContent }); }
```

## Side Effect

Reasoning models now stream their thinking process as visible text to Claude Code. The model's reasoning (e.g., "1. **Analyze the Request:**...") appears in the conversation. This is slightly noisy but infinitely better than silent failure.

## Rebuild & Deploy

```bash
cd ~/shared-local/reports/claude-universal
npx tsc                                    # Compile TypeScript → dist/
# Then restart the proxy for the affected port
```

## Models Fixed

- GLM-5.2 (`glm-5.2`)
- DeepSeek-V4 Pro (`deepseek-v4-pro`)
- DeepSeek-V4 Flash (`deepseek-v4-flash`)
- Qwen3.5 (`qwen3.5:397b`)
- Qwen3-Coder series
- Kimi K2.6 / K2.7-Code
- Any other reasoning model on Ollama Cloud that uses `reasoning` field

## Models That Worked Before (no change needed)

- Mistral Large 3 (`mistral-large-3:675b`) — puts output in `content`
- Gemini 3 Flash (`gemini-3-flash-preview`) — uses `content`
- Non-reasoning models generally

---

*Fixed: 2026-07-01 — UPB stream transformer now reads reasoning/reasoning_content as fallback when content is empty*
