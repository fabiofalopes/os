---
title: "Claude Code Proxy Pattern — Master Reference"
aliases:
  - claude-code-proxy
  - claude-code-effort
tags:
  - claude-code
  - proxy
  - claude-code-cli
  - universal-provider-bridge
created: 2026-07-20
status: active
---

# Claude Code Proxy Pattern — Master Reference

## The Problem

Claude Code (v2.1.197) only speaks the **Anthropic Messages API** natively. To use any OpenAI-compatible provider (ollama, Alibaba token-plan, Zen free, Lusófona LiteLLM), a local proxy translates the protocol:

```
Claude Code → localhost:PORT → Universal Provider Bridge → upstream/v1 (OpenAI-compatible)
             (Anthropic API)      (translates→↔)            (Bearer API key)
```

## Effort Control — Fix

**`--effort` CLI flag was being overridden** because all master scripts forced `CLAUDE_CODE_EFFORT_LEVEL=high` in the spawned env.

**Fix (2026-07-20):** Removed the hardcoded default. Now `--effort low` and `settings.json` `"effortLevel": "low"` are respected.

- **Inside session:** `/effort low|medium|high|xhigh|max`
- **At launch:** `claude-ollama-dsv4-pro --effort max`
- **Env override (if needed):** `CLAUDE_CODE_EFFORT_LEVEL=max claude-ollama-dsv4-pro`

Note: `claude-deepseek` / `claude-deepseek-flash` shell scripts still force `CLAUDE_CODE_EFFORT_LEVEL="max"` intentionally — reasoning models need it.

## Available Wrappers

| Family | Script | Models | Ports |
|---|---|---|---|
| **Ollama Cloud** | `claude-ollama` (Python) | 20 model symlinks : dsv4-pro, dsv4-flash, gemma4, glm52, kimi27c, qwen3cn, etc. | 8447–8642 |
| **Alibaba Token-Plan** | `claude-alibaba-dsv4-pro` (Python) | 5 symlinks : qwen36f, qwen37p, qwen37m, qwen38m, glm52 | 8701–8705 |
| **Zen Free** | `claude-zen-dsv4-free` (Python) | 2 symlinks : bp, nmc | 8801–8802 |
| **Lusófona LiteLLM** | `claude-ornith` (Python) | 2 symlinks : ornith (port 8901), omnicoder (port 8903) | 8901, 8903 |

### Quick aliases (Ollama, most used)

```
co          → claude-ollama-dsv4-pro
co-flash    → claude-ollama-dsv4-flash
co-glm      → claude-ollama-glm52
co-kimi     → claude-ollama-kimi27c
co-qwen     → claude-ollama-qwen3cn
co-gemini   → claude-ollama-gemini3f
co-kill     → kill all ollama proxies
```

### Proxy details

- **Binary:** `~/shared-local/reports/claude-universal/dist/index.js`
- **Config mode:** `UPB_PROVIDER` env var (avoids `providers.yaml`)
- **Auth:** `ANTHROPIC_AUTH_TOKEN` or `x-api-key` header (set to `LOCAL_SECRET`)
- **Health check:** `curl http://localhost:PORT/health`
- **Pid files:** `/tmp/claude-*-proxy-PORT.pid`
- **Logs:** `/tmp/claude-*-proxy-PORT.log`
- **Kill all:** `pkill -f "node.*dist/index.js"` or individual `kill $(cat /tmp/...pid)`

## Settings File

`~/.claude/settings.json`:

```json
{
  "effortLevel": "low",
  "skipDangerousModePermissionPrompt": true,
  "theme": "light",
  "allowDangerouslySkipPermissions": true
}
```

No `env` block — each wrapper script sets env per-session.

---

## Learning from the Ecosystem

### 1. CLIProxyAPI (`router-for-me/CLIProxyAPI`)

> **Go proxy server** that wraps subscription-based AI CLIs behind OpenAI/Claude-compatible API endpoints.
>
> **~43.8k ★**, MIT, v7.2.92

**Key concepts relevant to our setup:**

- **OAuth-to-API bridging**: Authenticates via Claude Code subscription (OAuth), then serves it as a standard API — no API key needed.
- **Multi-account pooling**: Round-robins across Claude subscriptions (automatic failover on rate limits).
- **Request cloaking** (`disable-claude-cloak-mode`): Disguises non-Claude-Code clients as Claude Code, replaces system prompts so the subscription channel accepts the request.
- **Payload manipulation**: Per-model injection/override/filter rules for prompts, system messages.
- **Session affinity**: Sticky sessions across proxy restarts.
- **Plugin system**: Dynamic Go/C ABI plugins for custom executors.
- **Management API**: REST admin for credentials, health, config.

**What to learn from it:**

- How OAuth session reuse works (our UPB only handles API keys)
- Multi-account load balancing patterns
- Request cloaking / system prompt injection for model compatibility
- Config hot-reload without restart

**Config example:**

```yaml
port: 8317
api-keys: ["your-api-key"]
claude-api-key:
  - api-key: "sk-ant-..."
    prefix: "claude"
routing:
  strategy: "round-robin"
```

**Run:** `./cli-proxy-api --config config.yaml --tui --standalone`

**Docs:** https://help.router-for.me/

**Derivative projects:** vibeproxy, CCS, Quotio, ProxyPilot, ProxyPal, CPANine, ProxyK, MUMU, CBox

---

### 2. CC-Switch (`farion1231/cc-switch`)

> **Cross-platform desktop GUI (Tauri 2)** for managing 8 AI coding CLIs: Claude Code, Claude Desktop, Codex, Gemini CLI, Grok Build, OpenCode, OpenClaw, Hermes Agent.
>
> **~119k ★**, Tauri 2 + Rust backend + React frontend

**Key concepts relevant to our setup:**

- **50+ provider presets**: Including AWS Bedrock, NVIDIA NIM, community relays. One-click import with API key.
- **System tray switching**: Switch active providers without opening the app — hot-swaps the config files.
- **Unified MCP panel**: Manage MCP servers bi-directionally across Claude Code, Codex, Gemini CLI, Grok Build, OpenCode, and Hermes Agent.
- **Unified prompts**: Markdown editor syncing `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` with backfill protection.
- **Skills Manager**: One-click install from GitHub repos or ZIP files (symlink or file-copy).
- **Local proxy with failover**: Hot-switchable proxy with circuit breaker, health monitoring, format conversion.
- **Usage dashboard**: Spending, requests, tokens with trend charts.
- **Session manager**: Browse/search/restore conversation history.
- **Cloud sync**: Dropbox, OneDrive, iCloud, NAS, WebDAV.
- **Deep link** (`ccswitch://`): Import providers, MCP, prompts, skills via URL.

**What to learn from it:**

- **Config file injection** — how to make Claude Code switch providers at runtime (it overwrites `~/.claude.json` / `~/.claude/settings.json` live)
- **Universal provider config** pattern that works across Claude Code, Codex, and Gemini CLI simultaneously
- MCP server portability across different CLI tools
- Skill packaging and distribution (one-click install from GitHub)
- Proxy failover with circuit breaker

**Data model:**

| Path | What |
|---|---|
| `~/.cc-switch/cc-switch.db` | SQLite DB (atomic writes with temp file + rename, auto-backup 10 rotations) |
| `~/.cc-switch/settings.json` | UI preferences |
| `~/.cc-switch/backups/` | Auto-backups |
| `~/.cc-switch/skills/` | Symlinked skill repos |

**Install:**

```bash
brew install --cask cc-switch          # macOS
paru -S cc-switch-bin                   # Arch Linux
# AppImage for other Linux distros
```

**Dev:** `pnpm install && pnpm dev`

---

## How These Compare to Our Setup

| Aspect | Our UPB | CLIProxyAPI | CC-Switch |
|---|---|---|---|
| **Purpose** | Protocol translation for API keys | OAuth→API bridge + multi-account | GUI config manager for CLIs |
| **Auth** | API keys only | OAuth (Claude, Codex, Grok, Gemini) + API keys | Edits provider config files |
| **Multi-account** | No | Yes (round-robin + failover) | No |
| **MCP** | No | No | Yes (unified panel) |
| **Proxy** | UPB only | Built-in | Built-in with failover |
| **Config management** | Manual scripts | YAML config | GUI + deep links |
| **Platform** | CLI wrapper scripts | Go server | Desktop app (Tauri) |

## Improvement Ideas from Both

1. **MCP server management** across all our agents (from CC-Switch)
2. **Multi-account load balancing** for rate-limited providers (from CLIProxyAPI)
3. **Config hot-reload** instead of restarting proxies (from CLIProxyAPI)
4. **Skill one-click install** from our skill hub (from CC-Switch)
5. **Unified provider config** that works across Claude Code and OpenCode simultaneously (from CC-Switch)

## References

- `Alibaba Token-Plan 20-07-2026.md` — token plan details + model list
- `Claude Code Proxy Pattern — Ollama Cloud.md` — ollama-specific proxy setup
- `Claude Code + OpenCode Setup — Lusófona Endpoint Map.md` — legacy direct config
- `~/shared-local/reports/claude-universal/` — UPB source + dist
- https://github.com/router-for-me/CLIProxyAPI
- https://github.com/farion1231/cc-switch
- https://ccswitch.io
- https://help.router-for.me/
