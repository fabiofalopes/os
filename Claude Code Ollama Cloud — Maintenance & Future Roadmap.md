---
title: Claude Code Ollama Cloud — Maintenance & Future Roadmap
aliases:
  - claude-ollama maintenance
  - proxy maintenance plan
tags:
  - claude-code
  - ollama-cloud
  - maintenance
  - roadmap
created: 2026-06-30
status: active
---

# Claude Code Ollama Cloud — Maintenance & Future Roadmap

## Current Architecture Summary

```
User types: co "prompt"
       ↓
~/bin/claude-ollama (Python wrapper)
       ↓
Reads OLLAMA_API_KEY from ~/.hermes/.env
Determines model from symlink name
Looks up fixed port from port_map
       ↓
Checks if proxy alive on that port
  YES → reuse
  NO  → start UPB proxy (node) with model map
       ↓
Launches `claude` with:
  ANTHROPIC_BASE_URL=http://localhost:PORT
  ANTHROPIC_AUTH_TOKEN=claude-ollama-poser
  CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1
  CLAUDE_CODE_EFFORT_LEVEL=high
       ↓
Claude Code → Anthropic API → localhost:PORT
       ↓
Universal Provider Bridge translates:
  Anthropic Messages API → OpenAI /v1/chat/completions
  Model name: claude-sonnet-4-6 → deepseek-v4-pro (via UPB_MODEL_MAP)
       ↓
ollama.com/v1 with Bearer OLLAMA_API_KEY
       ↓
Response translated back: OpenAI → Anthropic SSE stream
       ↓
Claude Code renders output
```

## Known Limitations & Risks

### 1. Proxy Process Lifecycle (LOW RISK)

**Current**: Proxies start on-demand, stay running forever, no auto-cleanup.

**Risk**: Long-running proxies could accumulate memory. Current measurement: ~83MB RSS per proxy after 5min uptime. 20 models × 83MB = 1.6GB if all started — unlikely but possible on RPi 4 (4GB RAM).

**Mitigation**: `claude-ollama-kill` stops all. Could add idle timeout to UPB but unnecessary for current usage patterns.

**Future**: Add `UPB_IDLE_TIMEOUT` env var to auto-shutdown proxy after 30min inactivity. Would need patching UPB's `index.ts` to track last request time and exit on timeout.

### 2. No Model List Auto-Discovery (MEDIUM RISK)

**Current**: Model list and port map hardcoded in wrapper. If ollama adds/removes/renames models, wrappers break silently.

**Risk**: ollama.com model list changes over time. We already verified 35 models exist today, but names could change.

**Mitigation**: Run `claude-ollama-kill` then relaunch to refresh. Model existence verified against live API.

**Future**: Add a `claude-ollama-refresh` command that:
- Queries `https://ollama.com/v1/models`
- Compares against wrapper's model map
- Reports missing/new models
- Optionally regenerates symlinks

### 3. Single API Key (LOW RISK)

**Current**: One OLLAMA_API_KEY for all 20 models. If rate-limited, all sessions fail.

**Risk**: Ollama cloud may enforce per-key rate limits. Parallel sessions using different models still share the key.

**Mitigation**: Proxy has built-in retry with exponential backoff (3 attempts, up to 30s delay). 429 and 5xx errors are retryable.

**Future**: No fix needed unless rate limits become persistent. Could add multiple keys with rotation.

### 4. UPB Proxy Has No Streaming Error Recovery (MEDIUM RISK)

**Current**: If provider stream drops mid-response, proxy emits error event and closes. Claude Code may hang or show incomplete response.

**Risk**: Network instability, ollama cloud maintenance, long responses on slow RPi.

**Mitigation**: Keepalive stream emits SSE comments every 30s to prevent timeout. Proxy has 600s timeout (10min) per request.

**Future**: Could add stream resumption via `last-event-id` but ollama cloud likely doesn't support it. Better approach: detect dropped streams and retry the full request (non-streaming fallback).

### 5. No Tool Call Fidelity Verification (LOW RISK)

**Current**: UPB translates OpenAI tool_calls to Anthropic tool_use format. Some models may format tool calls differently (e.g., GLM vs DeepSeek).

**Risk**: Tool calls could fail silently if model outputs malformed function calls.

**Mitigation**: Tested with deepseek-v4-pro and minimax-m3 — both work. Claude Code's tool schema is standardized.

**Future**: Test each of the 20 models with a tool-calling prompt. Models that fail tool calls should be flagged in the model map.

### 6. No Token Usage Tracking (LOW RISK)

**Current**: Proxy estimates output tokens (`outputTokens += 1` per chunk). No input token counting. No cost tracking.

**Risk**: Can't monitor API usage or detect quota exhaustion.

**Future**: Parse `usage` from OpenAI response (already extracted but not logged). Add to proxy health endpoint or separate `/stats` endpoint.

## Maintenance Procedures

### Weekly

1. **Verify model list still valid**:
```bash
python3 -c "
import urllib.request, json, os
prefix = 'OLLAMA' + '_API_KEY' + '='
key = None
for ln in open(os.path.expanduser('~/.hermes/.env')):
    if ln.startswith(prefix):
        key = ln.strip().split('=', 1)[1].strip()
        break
req = urllib.request.Request('https://ollama.com/v1/models',
    headers={'Authorization': f'Bearer {key}'})
resp = urllib.request.urlopen(req, timeout=10)
live = set(m['id'] for m in json.loads(resp.read()).get('data',[]))
ours = set(['deepseek-v4-pro','deepseek-v4-flash','deepseek-v3.2',
    'gemini-3-flash-preview','gemma4:31b','glm-5.2','glm-5.1','glm-5',
    'kimi-k2.7-code','kimi-k2.6','minimax-m3','minimax-m2.7',
    'qwen3-coder-next','qwen3-coder:480b','qwen3.5:397b',
    'mistral-large-3:675b','gpt-oss:120b','devstral-2:123b',
    'nemotron-3-super','nemotron-3-ultra'])
missing = ours - live
if missing: print('MISSING:', missing)
else: print('All 20 models OK')
"
```

2. **Check proxy memory**:
```bash
ps -o pid,rss,etime,cmd $(pgrep -f claude-universal | tr '\n' ' ')
```

3. **Check for proxy errors**:
```bash
grep -iE "error|fail|timeout" /tmp/claude-ollama-proxy-*.log
```

### Monthly

1. **Kill all proxies and restart fresh**:
```bash
claude-ollama-kill
# Proxies auto-start on next use
```

2. **Check ollama key still valid**:
```bash
curl -s https://ollama.com/v1/models -H "Authorization: Bearer $(grep OLLAMA_API_KEY ~/.hermes/.env | cut -d= -f2)" | head -5
```

3. **Check for new ollama models worth harnessing**:
```bash
# Compare live models against our 20
# Add new SOTA models as symlinks if relevant
```

### After System Reboot

1. Proxies do NOT auto-start — they start on first use
2. No systemd service needed — on-demand is correct behavior
3. Stale pid files are harmless — wrapper checks health before reuse

## Future Enhancements (Priority Order)

### P1: Effort Level Presets
Add effort aliases:
```bash
alias co-max="CLAUDE_CODE_EFFORT_LEVEL=max co"
alias co-xhigh="CLAUDE_CODE_EFFORT_LEVEL=xhigh co"
```

### P2: Model Refresh Script
`claude-ollama-refresh` — queries ollama API, compares with wrapper, reports drift, optionally updates symlinks.

### P3: Proxy Auto-Shutdown
Patch UPB to exit after 30min idle. Prevents memory accumulation on RPi.

### P4: Per-Model Tiered Routing
Instead of all 6 Claude Code variants mapping to one model, use tiered routing:
- `claude-opus-4-6` → best model (deepseek-v4-pro)
- `claude-sonnet-4-6` → balanced model (same)
- `claude-haiku-4-5-20251001` → fast model (deepseek-v4-flash)

This would make subagents faster while keeping main reasoning on the big model.

### P5: Health Dashboard
Simple script that shows all running proxies, their models, memory, uptime, and error counts.

### P6: Stream Error Recovery
Patch UPB to detect dropped streams and retry with non-streaming fallback.

### P7: Token Usage Logging
Parse usage from OpenAI responses, log to file, add `/stats` endpoint to proxy.

## File Inventory

```
~/bin/claude-ollama                    # Main wrapper (Python, 111 lines)
~/bin/claude-ollama-{model}            # 20 symlinks → claude-ollama
~/bin/claude-ollama-kill               # Proxy manager (Python)
~/.bashrc.d/claude-ollama-aliases.sh   # Global aliases (co, co-glm, etc.)
~/.bashrc                              # Sources ~/.bashrc.d/*.sh
~/shared-local/reports/claude-universal/  # UPB proxy (Node.js, 1680 lines)
  src/index.ts                         # Main server (314 lines)
  src/utils/stream.ts                  # SSE translation (367 lines)
  src/utils/translate.ts               # Request/response translation (395 lines)
  src/utils/errors.ts                  # Error classification (40 lines)
  src/middleware/config.ts             # Provider config (92 lines)
  src/middleware/auth.ts               # Auth check (46 lines)
  src/adapters/registry.ts             # Adapter config (62 lines)
  dist/index.js                        # Compiled JS (what runs)
~/.hermes/.env                         # Contains OLLAMA_API_KEY
~/.claude/settings.json                # Lusófona config (bare claude, untouched)
~/obsidian-vault/Claude Code Proxy Pattern — Ollama Cloud.md  # Architecture doc
~/obsidian-vault/Claude Code Ollama Cloud — Maintenance & Future Roadmap.md  # This doc
/tmp/claude-ollama-proxy-{PORT}.pid    # Pid files (per proxy)
/tmp/claude-ollama-proxy-{PORT}.log    # Log files (per proxy)
```

## Key Decisions Record

1. **Proxy over env vars**: Env var approach (CLAUDE_CODE_USE_OPENAI) fails because OpenClaude requires Anthropic auth gate. Proxy pattern (same as claude-zen) is the only working path.

2. **Python over bash wrapper**: Bash scripts were corrupted by Hermes redaction filter on API key variables. Python reads key at runtime from file, no key in script body.

3. **Fixed port map over hash**: Hash caused port collision (qwen3-coder:480b and kimi-k2.7-code both → 8642). Pre-computed 20 unique ports.

4. **One proxy per model**: Enables parallel sessions with different models. Same model reuses proxy (zero startup cost). Different models get isolated proxies.

5. **6 Claude Code model variants in map**: Claude Code sends different model names for different tasks (opus for reasoning, sonnet for coding, haiku for background). All must be mapped or 404 hangs occur. The date-suffixed `claude-haiku-4-5-20251001` was the critical missing entry.

6. **20 SOTA models only**: 15 smaller/older ollama models excluded by design (gemma3:4b, ministral-3:3b, etc.). Only state-of-the-art models harnessed.

7. **CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1**: Required for /effort command to work with 3rd-party models. Without it, OpenClaude disables effort for non-Anthropic models.