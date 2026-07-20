---
title: Claude Code Proxy Pattern — Ollama Cloud
aliases:
  - claude-ollama wrapper
  - proxy pattern for claude code
tags:
  - claude-code
  - ollama-cloud
  - proxy
  - universal-provider-bridge
created: 2026-06-30
status: active
---

# Claude Code Proxy Pattern — Ollama Cloud

## Architecture

```
Claude Code (Anthropic API) → localhost:PORT → Universal Provider Bridge → ollama.com/v1
     ANTHROPIC_AUTH_TOKEN          translates Anthropic→OpenAI           OLLAMA_API_KEY (Bearer)
```

Claude Code only speaks Anthropic Messages API. OpenClaude v2.1.75 requires authentication before any operation. The Universal Provider Bridge (UPB) solves both:

1. **Auth gate**: Claude Code connects to `localhost:PORT` with a local auth token. The proxy accepts it. This passes the login check.
2. **Protocol translation**: Proxy translates Anthropic Messages API → OpenAI `/v1/chat/completions`, forwards to `ollama.com/v1` with real key.
3. **Response translation**: OpenAI responses translated back to Anthropic format.

## Why env var approach failed

`CLAUDE_CODE_USE_OPENAI=1` + `OPENAI_BASE_URL` should route to OpenAI-compatible providers, but:
- OpenClaude's route resolver matches "ollama" in URL → routes to local ollama gateway with `authMode: "none"` (no auth sent)
- `~/.claude/settings.json` `env` block overrides shell env vars (Lusófona leak)
- Even with both fixed, OpenClaude v2.1.75 requires Anthropic account login before any operation
- Only the proxy pattern (same as `claude-zen`) bypasses all three issues

## Key fixes applied

1. **Haiku 404 hang**: Claude Code sends `claude-haiku-4-5-20251001` (with date suffix) for background tasks. Model map must include this exact variant or proxy sends unmapped name to ollama → 404 → silent hang.
2. **Port collision**: `qwen3-coder:480b` and `kimi-k2.7-code` both hashed to port 8642. Fixed with pre-computed fixed port map (no hashing).
3. **Parallel instances**: Each model gets its own proxy on a dedicated port. Same model reuses proxy. Different models run simultaneously.
4. **Orphan cleanup**: Old single-port proxy on 8445 left orphaned. Cleaned up. All pid files now include port number.

## Wrapper

**Path**: `~/bin/claude-ollama` (Python script, 111 lines)

**What it does**:
1. Reads `OLLAMA_API_KEY` from `~/.hermes/.env` at runtime
2. Looks up fixed port for model
3. Starts UPB proxy on that port (if not running)
4. Maps all 6 Claude Code model name variants to selected ollama model
5. Launches `claude` with `ANTHROPIC_BASE_URL=localhost:PORT`
6. Enables `/effort` command via `CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1`

**Effort control**:
- Default: `high`
- Override at launch: `CLAUDE_CODE_EFFORT_LEVEL=max claude-ollama-dsv4-pro`
- Change inside session: `/effort high` or `/effort max`
- Levels: `low`, `medium`, `high`, `xhigh`, `max`

**Proxy location**: `~/shared-local/reports/claude-universal/dist/index.js`

## Aliases (in ~/.bashrc.d/claude-ollama-aliases.sh)

```
co          → claude-ollama-dsv4-pro      (DeepSeek V4 Pro — default)
co-flash    → claude-ollama-dsv4-flash    (DeepSeek V4 Flash)
co-glm      → claude-ollama-glm52         (GLM 5.2)
co-minimax  → claude-ollama-minimax3      (MiniMax M3)
co-kimi     → claude-ollama-kimi27c       (Kimi K2.7 Code)
co-qwen     → claude-ollama-qwen3cn       (Qwen3 Coder Next)
co-gemini   → claude-ollama-gemini3f      (Gemini 3 Flash)
co-mistral  → claude-ollama-mistral-l3    (Mistral Large 3)
co-nemotron → claude-ollama-nemotron3u    (Nemotron 3 Ultra)
co-kill     → claude-ollama-kill          (Stop all proxies)
```

## Available Models (20 symlinks + 1 wrapper = 21)

```
SYMLINK                    MODEL                       PORT
claude-ollama-dsv4-pro     deepseek-v4-pro             8546
claude-ollama-dsv4-flash   deepseek-v4-flash           8536
claude-ollama-dsv32        deepseek-v3.2               8611
claude-ollama-gemini3f     gemini-3-flash-preview      8561
claude-ollama-gemma4       gemma4:31b                  8489
claude-ollama-glm52        glm-5.2                     8579
claude-ollama-glm51        glm-5.1                     8449
claude-ollama-glm5         glm-5                       8502
claude-ollama-kimi27c      kimi-k2.7-code              8613
claude-ollama-kimi26       kimi-k2.6                   8592
claude-ollama-minimax3     minimax-m3                  8498
claude-ollama-minimax27    minimax-m2.7                8447
claude-ollama-qwen3cn      qwen3-coder-next            8504
claude-ollama-qwen3c480    qwen3-coder:480b            8642
claude-ollama-qwen35       qwen3.5:397b                8525
claude-ollama-mistral-l3   mistral-large-3:675b        8637
claude-ollama-gptoss120    gpt-oss:120b                8557
claude-ollama-devstral2    devstral-2:123b             8599
claude-ollama-nemotron3s   nemotron-3-super            8529
claude-ollama-nemotron3u   nemotron-3-ultra            8477
```

## Ollama models NOT harnessed (15, by design — smaller/older)

```
deepseek-v3.1:671b     — previous gen, v3.2 supersedes
devstral-small-2:24b   — small variant
gemma3:4b/12b/27b      — older gen, gemma4:31b supersedes
glm-4.7                — older, glm-5.x supersedes
gpt-oss:20b            — small variant of gpt-oss:120b
kimi-k2.5              — older, k2.6/k2.7 supersede
minimax-m2.1/m2.5      — older, m2.7/m3 supersede
ministral-3:3b/8b/14b  — small models
nemotron-3-nano:30b    — small variant
rnj-1:8b               — small unknown model
```

## Proxy management

- **Stop all**: `claude-ollama-kill` or `co-kill`
- **Stop one**: `kill $(cat /tmp/claude-ollama-proxy-PORT.pid)`
- **Check status**: `curl http://localhost:PORT/health`
- **Logs**: `/tmp/claude-ollama-proxy-PORT.log`

## Dependencies

- `~/shared-local/reports/claude-universal/` — Universal Provider Bridge (Node.js)
- `~/.hermes/.env` — must contain OLLAMA_API_KEY
- `claude` binary at `~/.local/bin/claude` (OpenClaude v2.1.75)
- `~/.bashrc.d/claude-ollama-aliases.sh` — global aliases (sourced by .bashrc)

## Related

- `claude-zen` — same proxy pattern for OpenCode Zen free models
- `~/.claude/settings.json` — Lusófona config (bare `claude` uses this, untouched)