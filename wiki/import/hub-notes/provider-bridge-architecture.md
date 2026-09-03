---
title: Provider Bridge Architecture — Ollama Cloud Proxies
aliases:
  - local proxy bridges
  - UPB proxy
  - Hermes Ollama Bridge
  - provider bridges
tags:
  - infrastructure
  - ollama-cloud
  - claude-code
  - hermes-agent
  - proxy
  - universal-provider-bridge
created: 2026-07-01
status: active
---

# Provider Bridge Architecture — Ollama Cloud Proxies

Two local passthrough proxies bridge Claude Code and Hermes Agent to Ollama Cloud (`ollama.com/v1`). Every AI tool session connects to `localhost` — never directly to upstream providers. The proxies handle auth, retry, streaming, and observability, making sessions ultra-stable even when upstream endpoints change or credentials need rotation.

---

## Why This Exists

### The problem
Claude Code speaks only the Anthropic Messages API. Hermes speaks OpenAI Chat Completions. Both need to reach Ollama Cloud (`ollama.com/v1`), which speaks OpenAI Chat Completions. Direct connection from Hermes was broken — `config.yaml` had `base_url: https://opencode.ai/zen/go/v1` (OpenCode Go) instead of `https://ollama.com/v1`. Claude Code can't connect directly at all because it only speaks Anthropic protocol.

### The solution
Local proxies on fixed ports that:
1. Accept local connections (no auth or local secret)
2. Manage authentication (read real API keys from `~/.hermes/.env`)
3. Forward requests to the correct upstream provider
4. Handle retry, streaming, and error translation
5. Log all activity for observability

The result: change provider endpoints, rotate keys, or add new providers **without touching tool config**. All tools point at `localhost` and the proxies handle the rest.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         OLLAMA CLOUD                                │
│                     https://ollama.com/v1                           │
│                  (OpenAI Chat Completions API)                      │
└──────────────┬──────────────────────────┬───────────────────────────┘
               │                          │
               │ OLLAMA_API_KEY           │ OLLAMA_API_KEY
               │ (Bearer auth)            │ (Bearer auth)
               │                          │
    ┌──────────▼──────────┐    ┌──────────▼──────────────────────────┐
    │   BRIDGE 2: HERMES  │    │   BRIDGE 1: CLAUDE CODE (UPB)       │
    │                     │    │                                      │
    │  Python stdlib      │    │  Node.js / TypeScript               │
    │  Port: 8699         │    │  Ports: 8445–8642 (per model)       │
    │  Protocol: passthru │    │  Protocol: Anthropic ↔ OpenAI       │
    │  OpenAI → OpenAI    │    │  Translation + passthrough          │
    └──────────┬──────────┘    └──────────┬───────────────────────────┘
               │                          │
               │ http://localhost:8699/v1 │ http://localhost:PORT
               │ (Bearer or no-auth)      │ (ANTHROPIC_AUTH_TOKEN)
               │                          │
    ┌──────────▼──────────┐    ┌──────────▼──────────────────────────┐
    │    HERMES AGENT     │    │         CLAUDE CODE                 │
    │                     │    │                                      │
    │  config.yaml:       │    │  ANTHROPIC_BASE_URL=                │
    │  base_url:          │    │  http://localhost:PORT              │
    │  http://localhost:  │    │                                      │
    │  8699/v1            │    │  ANTHROPIC_AUTH_TOKEN=              │
    │                     │    │  claude-ollama-poser                │
    │  provider:          │    │                                      │
    │  ollama-cloud       │    │  /effort high (default)             │
    └─────────────────────┘    └─────────────────────────────────────┘
```

---

## Bridge 1: Claude Code Universal Provider Bridge (UPB)

**Purpose:** Translate Anthropic Messages API ↔ OpenAI Chat Completions so Claude Code can use non-Anthropic models through Ollama Cloud.

**Why it exists:** Claude Code v2.1.75 (OpenClaude) requires authentication before any operation. It only speaks Anthropic Messages API. The `CLAUDE_CODE_USE_OPENAI=1` env var approach failed because:
- OpenClaude's route resolver matches "ollama" in the URL → routes to local ollama gateway with `authMode: "none"` (no auth sent)
- `~/.claude/settings.json` `env` block overrides shell env vars (Lusófona leak)
- Even with both fixed, OpenClaude v2.1.75 requires Anthropic account login before any operation
- Only the proxy pattern passes the login check

### Per-Model Port Map

| Launch script | Model | Port | Status |
|---|---|---|---|
| `claude-ollama-dsv4-pro` | deepseek-v4-pro | 8546 | Primary workhorse |
| `claude-ollama-dsv4-flash` | deepseek-v4-flash | 8536 | Fast fallback |
| `claude-ollama-dsv32` | deepseek-v3.2 | 8611 | |
| `claude-ollama-gemini3f` | gemini-3-flash-preview | 8561 | |
| `claude-ollama-gemma4` | gemma4:31b | 8489 | |
| `claude-ollama-glm52` | glm-5.2 | 8579 | |
| `claude-ollama-glm51` | glm-5.1 | 8449 | |
| `claude-ollama-glm5` | glm-5 | 8502 | |
| `claude-ollama-kimi27c` | kimi-k2.7-code | 8613 | Coding specialist |
| `claude-ollama-kimi26` | kimi-k2.6 | 8592 | |
| `claude-ollama-minimax3` | minimax-m3 | 8498 | |
| `claude-ollama-minimax27` | minimax-m2.7 | 8447 | |
| `claude-ollama-qwen3cn` | qwen3-coder-next | 8504 | |
| `claude-ollama-qwen3c480` | qwen3-coder:480b | 8642 | |
| `claude-ollama-qwen35` | qwen3.5:397b | 8525 | |
| `claude-ollama-mistral-l3` | mistral-large-3:675b | 8637 | Best non-reasoning |
| `claude-ollama-gptoss120` | gpt-oss:120b | 8557 | |
| `claude-ollama-devstral2` | devstral-2:123b | 8599 | |
| `claude-ollama-nemotron3s` | nemotron-3-super | 8529 | |
| `claude-ollama-nemotron3u` | nemotron-3-ultra | 8477 | |

### UPB Internals

**Source:** `~/shared-local/reports/claude-universal/src/index.ts`
**Runtime:** `~/shared-local/reports/claude-universal/dist/index.js` (compiled TypeScript)
**Language:** Node.js / TypeScript
**Dependencies:** `yaml`, `tsx`

**Request flow:**
1. Claude Code connects to `localhost:PORT` with `ANTHROPIC_AUTH_TOKEN=claude-ollama-poser`
2. UPB validates the token against `LOCAL_SECRET` env var
3. Translates Anthropic Messages API → OpenAI Chat Completions
4. Forwards to `ollama.com/v1` with real `OLLAMA_API_KEY`
5. Translates OpenAI response → Anthropic Messages format
6. Returns to Claude Code

**Translation layer (`src/utils/translate.ts`):**
- Anthropic `messages` → OpenAI `messages` (role mapping, system prompt extraction)
- Anthropic `tools` → OpenAI `tools` (schema translation)
- Anthropic `stop_reason` → OpenAI `finish_reason`
- Streaming: SSE chunks translated in-flight via `AnthropicStreamTransformer`

**Adapters (`src/adapters/`):**
- `ollama-local` — Ollama Cloud (used by all claude-ollama-* scripts)
- `glm-zai` — Z.AI / GLM models
- `openai-gpt` — OpenAI
- `zen` — OpenCode Zen free models
- Each adapter can strip thinking tokens, extra headers, timeout config

**Auth middleware (`src/middleware/auth.ts`):**
- Validates `x-api-key` header or `Authorization: Bearer <token>`
- Accepts token matching `LOCAL_SECRET` env var
- Returns Anthropic-formatted 401 on failure

**Retry logic (`src/utils/errors.ts`):**
- Classifies errors: `RETRYABLE`, `NON_RETRYABLE`, `RATE_LIMIT`, `AUTH`
- Exponential backoff: 1s, 2s, 4s, 8s (configurable via `UPB_MAX_RETRIES`)
- Max 3 retries by default

**Lifecycle management:**
```bash
# Each model has its own proxy instance
claude-ollama-dsv4-pro    # Launches Claude Code with deepseek-v4-pro via :8546

# Kill all running proxies
claude-ollama-kill        # Kills all PIDs in /tmp/claude-ollama-proxy-*.pid

# Health check any proxy
curl http://localhost:8546/health
```

**Key files:**
| File | Purpose |
|---|---|
| `~/bin/claude-ollama` | Master script (all symlinks point here) |
| `~/bin/claude-ollama-dsv4-pro` | Symlink → claude-ollama (deepseek-v4-pro) |
| `~/bin/claude-ollama-kill` | Kill all running proxies |
| `~/shared-local/reports/claude-universal/src/index.ts` | UPB source |
| `~/shared-local/reports/claude-universal/dist/index.js` | Compiled runtime |
| `/tmp/claude-ollama-proxy-{PORT}.pid` | PID files |
| `/tmp/claude-ollama-proxy-{PORT}.log` | Per-proxy logs |

**Env vars set by launch scripts:**
```bash
UPB_PROVIDER=ollama-local
UPB_BASE_URL=https://ollama.com/v1
UPB_API_KEY=<from ~/.hermes/.env>
UPB_MODEL_MAP={"claude-opus-4-6":"deepseek-v4-pro","claude-sonnet-4-6":"deepseek-v4-pro",...}
PORT=8546
LOCAL_SECRET=claude-ollama-poser
```

**Env vars set for Claude Code process:**
```bash
ANTHROPIC_BASE_URL=http://localhost:PORT
ANTHROPIC_AUTH_TOKEN=claude-ollama-poser
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
API_TIMEOUT_MS=600000
CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1
CLAUDE_CODE_EFFORT_LEVEL=high
```

---

## Bridge 2: Hermes Ollama Bridge

**Purpose:** Reliable OpenAI-passthrough proxy between Hermes Agent and Ollama Cloud. No protocol translation — pure forward with auth, retry, and observability.

**Why it exists:** Hermes config.yaml was broken (pointing at OpenCode Go endpoint instead of Ollama Cloud, causing `HTTP 401`). Rather than just fixing the URL, we built a proxy layer for the same stability benefits the Claude Code UPB provides.

### Bridge Internals

**Source:** `~/shared-local/reports/hermes-ollama-bridge/hermes_ollama_bridge.py`
**Language:** Python 3 (stdlib-only — no dependencies)
**Port:** 8699 (fixed)
**Lines:** ~400

**Endpoints exposed:**
| Method | Path | Purpose |
|---|---|---|
| `GET` | `/health` | Health check (returns JSON with uptime, API key status, upstream) |
| `GET` | `/v1/models` | Passthrough → ollama.com/v1/models |
| `POST` | `/v1/chat/completions` | Passthrough → ollama.com/v1/chat/completions (streaming + non-streaming) |

**Auth model:**
1. Accepts `Authorization: Bearer <LOCAL_SECRET>` (admin/health)
2. Accepts `Authorization: Bearer <OLLAMA_API_KEY>` (Hermes sends its real key)
3. Accepts no auth at all (local-only trust — drop-in for Hermes without config changes)
4. Rejects everything else with `HTTP 401`

**Retry logic:**
- 3 attempts (configurable via `HERMES_BRIDGE_MAX_RETRIES`)
- Exponential backoff: 1s, 2s, 4s, 8s (capped at 30s)
- Retries on: 429 (rate limit), 5xx (server errors, excluding 501)
- Does NOT retry on: 4xx (client errors), 501 (Not Implemented)
- Streaming retries use same logic with chunk-level recovery

**Observability:**
- Structured JSON logs to `/tmp/hermes-ollama-bridge-8699.log`
- Logs include: request model, stream/non-stream, body size, retry attempts, upstream errors
- PID file: `/tmp/hermes-ollama-bridge-8699.pid`

**Lifecycle management:**
```bash
hermes-bridge start      # Start bridge (waits for health check, 15s timeout)
hermes-bridge stop       # Graceful SIGTERM, force SIGKILL after 5s
hermes-bridge status     # Check health + process status
hermes-bridge restart    # Stop → wait 1s → start
hermes-bridge logs       # Tail -f the bridge log
```

**Key files:**
| File | Purpose |
|---|---|
| `~/shared-local/reports/hermes-ollama-bridge/hermes_ollama_bridge.py` | Bridge source |
| `~/bin/hermes-bridge` | Management CLI |
| `~/.bashrc.d/hermes-bridge-autostart.sh` | Auto-start on shell init |
| `~/.config/systemd/user/hermes-ollama-bridge.service` | systemd unit (for full systemd envs) |
| `/tmp/hermes-ollama-bridge-8699.pid` | PID file |
| `/tmp/hermes-ollama-bridge-8699.log` | Activity log |

**Hermes config (`~/.hermes/config.yaml`):**
```yaml
model:
  default: deepseek-v4-pro
  provider: ollama-cloud
  base_url: http://localhost:8699/v1    # ← Points at bridge, not ollama.com directly
  api_mode: chat_completions
```

**Env vars (set via systemd or shell):**
```bash
HERMES_BRIDGE_PORT=8699
HERMES_BRIDGE_UPSTREAM=https://ollama.com/v1
HERMES_BRIDGE_MAX_RETRIES=3
HERMES_BRIDGE_TIMEOUT=300
```

**API key loading order:**
1. `OLLAMA_API_KEY` environment variable
2. `~/.hermes/.env` — parses `OLLAMA_API_KEY=` line (skips commented lines, skips `your_ollama_key_here`)
3. Falls back to `~/.hermes/hermes-agent/.env`

---

## Port Allocation Map (All Bridges)

```
┌────────────────────────────────────────────────────────────────┐
│  LOCALHOST PORTS                                               │
├────────┬───────────────────────────────────────────────────────┤
│  8445  │  Claude Code UPB — glm-5.1                            │
│  8447  │  Claude Code UPB — minimax-m2.7                       │
│  8477  │  Claude Code UPB — nemotron-3-ultra                   │
│  8489  │  Claude Code UPB — gemma4:31b                         │
│  8498  │  Claude Code UPB — minimax-m3                         │
│  8502  │  Claude Code UPB — glm-5                              │
│  8504  │  Claude Code UPB — qwen3-coder-next                   │
│  8525  │  Claude Code UPB — qwen3.5:397b                       │
│  8529  │  Claude Code UPB — nemotron-3-super                   │
│  8536  │  Claude Code UPB — deepseek-v4-flash                  │
│  8546  │  Claude Code UPB — deepseek-v4-pro ★ PRIMARY          │
│  8557  │  Claude Code UPB — gpt-oss:120b                       │
│  8561  │  Claude Code UPB — gemini-3-flash-preview             │
│  8579  │  Claude Code UPB — glm-5.2                            │
│  8592  │  Claude Code UPB — kimi-k2.6                          │
│  8599  │  Claude Code UPB — devstral-2:123b                    │
│  8611  │  Claude Code UPB — deepseek-v3.2                      │
│  8613  │  Claude Code UPB — kimi-k2.7-code                     │
│  8637  │  Claude Code UPB — mistral-large-3:675b               │
│  8642  │  Claude Code UPB — qwen3-coder:480b                   │
│  8699  │  HERMES OLLAMA BRIDGE ★ (all models, one port)        │
└────────┴───────────────────────────────────────────────────────┘
```

---

## API Key Management

Both bridges read the same API key from a single source of truth:

**Location:** `~/.hermes/.env`
```
OLLAMA_API_KEY=bcadedc9c55f4f81b89653e412dda3bb.qAeyfdTj0aiHSuoYkGDs6ZFB
```

**Rotation procedure:**
1. Update `OLLAMA_API_KEY` in `~/.hermes/.env`
2. Restart both bridges:
   ```bash
   hermes-bridge restart
   claude-ollama-kill          # Kill all UPB proxies
   # Next claude-ollama-* invocation auto-starts fresh proxy with new key
   ```
3. Hermes picks up new key next session (or on config reload)

**Auth flow for Hermes:**
1. Hermes reads `OLLAMA_API_KEY` from env/`.env` (via credential pool)
2. Hermes sends `Authorization: Bearer <OLLAMA_API_KEY>` to `localhost:8699`
3. Bridge accepts it (matches `API_KEY == token` check)
4. Bridge forwards request to `ollama.com/v1` with its OWN copy of the key
5. Response flows back through bridge to Hermes

**Auth flow for Claude Code:**
1. User runs `claude-ollama-dsv4-pro`
2. Script reads `OLLAMA_API_KEY` from `~/.hermes/.env`
3. Script launches UPB with `UPB_API_KEY=<key>`
4. Script launches Claude Code with `ANTHROPIC_AUTH_TOKEN=claude-ollama-poser`
5. Claude Code sends `x-api-key: claude-ollama-poser` to `localhost:8546`
6. UPB validates `LOCAL_SECRET` match
7. UPB forwards (translated) request to `ollama.com/v1` with real key
8. UPB translates response back to Anthropic format
9. Claude Code receives Anthropic-formatted response

---

## Troubleshooting

### Hermes Bridge

```bash
# Quick health check
curl http://localhost:8699/health | python3 -m json.tool

# Check model availability
curl http://localhost:8699/v1/models | python3 -c "
import sys,json; d=json.load(sys.stdin)
print(f'{len(d.get(\"data\",[]))} models available')
"

# Test a real completion
curl http://localhost:8699/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral-large-3:675b","messages":[{"role":"user","content":"Say: ok"}],"max_tokens":5}'

# View recent activity
hermes-bridge logs

# Check Hermes config
python3 -c "
import yaml
with open('$HOME/.hermes/config.yaml') as f:
    cfg = yaml.safe_load(f)
print(cfg['model']['base_url'])   # should be http://localhost:8699/v1
"

# If bridge is down but config points to it → Hermes fails with connection refused
# Quick fix: switch config back to direct
# base_url: https://ollama.com/v1   (bypass bridge temporarily)
```

### Claude Code UPB

```bash
# Check if proxy is running for a model
curl http://localhost:8546/health

# Check proxy log
cat /tmp/claude-ollama-proxy-8546.log

# Kill all proxies (use before restart)
claude-ollama-kill

# Start fresh proxy for a model
claude-ollama-dsv4-pro

# If Claude Code says "invalid API key":
# 1. Check OLLAMA_API_KEY in ~/.hermes/.env
# 2. Kill proxies: claude-ollama-kill
# 3. Rebuild UPB if needed: cd ~/shared-local/reports/claude-universal && npx tsc
# 4. Retry: claude-ollama-dsv4-pro
```

### Common failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| Hermes: `HTTP 401 Invalid API key` | `base_url` in config.yaml pointing at wrong endpoint | Set to `http://localhost:8699/v1` or `https://ollama.com/v1` |
| Hermes: `Connection refused` | Bridge not running | `hermes-bridge start` |
| Bridge: `No OLLAMA_API_KEY found` | `.env` file missing or key not set | Check `cat ~/.hermes/.env \| grep OLLAMA_API_KEY` |
| UPB: `Provider request failed` | ollama.com unreachable or key expired | Check log, verify key, restart proxy |
| Claude Code: "Authentication required" | UPB not running on expected port | Check `curl http://localhost:8546/health` |
| Both: Models returning empty `content` | Reasoning models put output in `reasoning` field | This is normal for deepseek/qwen models — content is in `reasoning`, use non-reasoning models (mistral-large-3:675b, gemini) for clean `content` |

---

## Future: Unification

Currently two separate bridges serve two different protocols. The UPB already has the infrastructure to add a passthrough mode:

**Option: Add `/v1/chat/completions` route to UPB**
- The UPB would accept both Anthropic `/v1/messages` AND OpenAI `/v1/chat/completions` on different paths
- One Node.js process per model handles both Claude Code and Hermes
- Hermes points at `http://localhost:8546/v1` (same port as Claude's deepseek-v4-pro proxy)
- Reduces running processes from 21 (1 Hermes bridge + 20 UPB instances) to 20 (just UPB instances)

**Not yet implemented** — the separate bridges work reliably and the Python bridge is simpler to debug. Unify only if process count or maintenance burden becomes a problem.

---

## Filesystem Map

```
~/
├── .hermes/
│   ├── config.yaml                    # Hermes: base_url → localhost:8699/v1
│   ├── auth.json                      # Credential pool (ollama-cloud + opencode-go keys)
│   └── .env                           # OLLAMA_API_KEY (single source of truth)
│
├── .bashrc.d/
│   └── hermes-bridge-autostart.sh     # Auto-starts bridge on shell init
│
├── bin/
│   ├── claude-ollama                  # Master UPB launch script
│   ├── claude-ollama-dsv4-pro         # Symlink → claude-ollama (deepseek-v4-pro)
│   ├── claude-ollama-dsv4-flash       # Symlink → claude-ollama (deepseek-v4-flash)
│   ├── claude-ollama-*                # ...18 more model symlinks
│   ├── claude-ollama-kill             # Kill all UPB proxies
│   └── hermes-bridge                  # Hermes bridge management CLI
│
├── shared-local/reports/
│   ├── claude-universal/              # UPB source + compiled dist
│   │   ├── src/index.ts              # UPB main entry
│   │   ├── src/middleware/auth.ts     # Auth validation
│   │   ├── src/middleware/config.ts   # Provider config loader
│   │   ├── src/utils/translate.ts     # Anthropic ↔ OpenAI translator
│   │   ├── src/utils/stream.ts        # SSE stream transformer
│   │   ├── src/utils/errors.ts        # Error classification + retry
│   │   ├── src/adapters/registry.ts   # Provider adapter registry
│   │   └── dist/index.js             # Compiled runtime
│   └── hermes-ollama-bridge/
│       └── hermes_ollama_bridge.py   # Hermes bridge source
│
└── .config/systemd/user/
    └── hermes-ollama-bridge.service   # systemd unit (for full systemd envs)

/tmp/
├── claude-ollama-proxy-{PORT}.pid    # UPB PID files (one per model/port)
├── claude-ollama-proxy-{PORT}.log    # UPB log files (one per model/port)
├── hermes-ollama-bridge-8699.pid     # Hermes bridge PID
└── hermes-ollama-bridge-8699.log     # Hermes bridge structured JSON log
```

---

## Quick Reference

```bash
# ── Hermes Bridge ──
hermes-bridge status          # Is it running?
hermes-bridge logs            # What's happening?
hermes-bridge restart         # Fix after config changes

# ── Claude Code Proxies ──
claude-ollama-dsv4-pro        # Start Claude Code with deepseek-v4-pro
claude-ollama-kill            # Kill all running UPB instances

# ── Health Checks ──
curl http://localhost:8699/health           # Hermes bridge
curl http://localhost:8546/health           # Claude UPB (deepseek-v4-pro)
curl http://localhost:8536/health           # Claude UPB (deepseek-v4-flash)
curl http://localhost:8637/health           # Claude UPB (mistral-large-3)

# ── Key Rotation ──
vim ~/.hermes/.env            # Update OLLAMA_API_KEY
hermes-bridge restart         # Restart Hermes bridge
claude-ollama-kill            # Kill all UPB proxies (next launch auto-starts fresh)
```

---

*Created: 2026-07-01 | Architecture designed for ultra-stable local-to-cloud provider connections*
