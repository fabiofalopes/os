---
title: Universal Provider Bridge — Project Master Map
date: 2026-08-06
tags: [infra, map, upb, universal-router, living]
status: living — update as the system evolves
---

# Universal Provider Bridge — Project Master Map

> The single map for the entire LLM routing stack: `upb` CLI → `routes.yaml` → universal-router proxy → upstream providers. Converged from a graveyard of 35 launcher scripts into one config-driven system.
> Related: [[Claude Code Routes — upb CLI Decision & Runbook]] · [[Claude Code Proxy Pattern — Master Reference]] · [[alibaba-token-plan-20-07-2026]] · [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]]

---

## 1. What This Is

A **dual-intake LLM proxy + route control system** that lets Claude Code, OpenCode, Hermes, and any OpenAI-compatible client talk to any upstream provider (Alibaba, Z.AI, DeepSeek, Ollama, LiteLLM, PrimeIntellect, etc.) through a single translation layer.

**Core value:** Anthropic Messages API ↔ OpenAI Chat Completions API translation, provider routing by model prefix, key management by reference, and usage tracking.

### Main Setup Doctrine (2026-08-06, updated session 2)

**Bare `claude` = routed through the universal-router by default.** No more per-provider launchers, no more `upb run` needed for the default case.

- `~/.local/bin/claude` **wrapper** (first on PATH) intercepts all invocations → sources binding file → execs real binary
- Default binding (`~/.config/upb/default-binding.env`) → `ANTHROPIC_BASE_URL = http://127.0.0.1:8705` + `ANTHROPIC_AUTH_TOKEN = <LOCAL_SECRET>`
- The systemd proxy on :8705 handles model mapping (`claude-opus-4-8` → `qwen3.8-max-preview`) and forwards to the active provider
- Explicit provider switching: `upb run zai/glm-5.2` → writes **session-binding.env** → all sub-sessions stay bound to that model
- `upb stop` clears the session binding → default route restored
- **`~/.claude/settings.json` has NO `env` block** — the wrapper owns routing. Never re-add env vars there (would break binding).
- Other tools (OpenCode, Hermes, scripts): `eval $(upb env)` exports both Anthropic + OpenAI env vars pointing at the router
- Keys: single source of truth in `~/.config/upb/secrets.env` (chmod 600), managed by `upb sync`

### Session-Model Binding (2026-08-06, session 2)

**Problem:** sub-sessions and workflow relaunches silently fell back to the default route because `settings.json` hardcoded env vars.

**Solution:** wrapper + binding file.

```
~/.local/bin/claude (wrapper)
  ├─ session-binding.env exists?  → source it → exec real claude  (UPB-bound)
  ├─ default-binding.env exists?  → source it → exec real claude  (default route)
  └─ neither?                     → hardcoded alibaba :8705 fallback
```

| File | Lifecycle |
|------|-----------|
| `~/.config/upb/session-binding.env` | Written by `upb run`, cleared by `upb stop` |
| `~/.config/upb/default-binding.env` | Static, always present (alibaba :8705) |

**Doctrine:** the binding file is the single source of truth for active model routing. `settings.json` must never contain routing env vars.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  CLIENTS                                                            │
│  Claude Code (Anthropic API)  ·  OpenCode/Hermes (OpenAI API)       │
└──────────────┬──────────────────────────────────┬───────────────────┘
               │ POST /v1/messages                │ POST /v1/chat/completions
               ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  UNIVERSAL-ROUTER (Node.js/TS proxy)                                │
│  ~/shared-local/reports/claude-universal/                           │
│                                                                     │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────┐  ┌───────────┐ │
│  │ Auth     │→ │ Resolve      │→ │ Translate     │→ │ Forward   │ │
│  │ (LOCAL_  │  │ Provider     │  │ Request/      │  │ + Retry   │ │
│  │ SECRET)  │  │ (model_map)  │  │ Response      │  │ + Usage   │ │
│  └──────────┘  └──────────────┘  └───────────────┘  │ Logger    │ │
│                                                       └───────────┘ │
│  Endpoints: /health · /v1/models · /v1/messages ·                   │
│             /v1/chat/completions · /v1/messages/count_tokens ·      │
│             /usage (NEW 2026-08-06)                                 │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
┌──────────────────┐ ┌─────────────────┐ ┌─────────────────────────┐
│ alibaba-token-   │ │ api.z.ai        │ │ modelos.ai.ulusofona.pt │
│ plan (MaaS)      │ │ (GLM Coding)    │ │ (LiteLLM Gateway)       │
│ :8705 systemd    │ │ anthropic-native│ │ :8901/:8903 on-demand   │
└──────────────────┘ └─────────────────┘ └─────────────────────────┘
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
┌──────────────────┐ ┌─────────────────┐ ┌─────────────────────────┐
│ opencode.ai/zen  │ │ api.pinference  │ │ 127.0.0.1:8090          │
│ (free tier)      │ │ (pay-per-use)   │ │ (gpu-deploy ephemeral)  │
│ :8801-8803       │ │ live catalog    │ │ DEAD — disabled         │
└──────────────────┘ └─────────────────┘ └─────────────────────────┘
```

**Two deployment modes:**
1. **systemd persistent** — `universal-router.service` on `:8705` (alibaba-token-plan only, always-on)
2. **upb on-demand** — `upb run <route>` spawns a proxy on the route's static port, kills it with `upb stop`

---

## 3. Component Inventory

| Component | Path | Role |
|---|---|---|
| **upb CLI** | `~/bin/upb` | Python route-control CLI: list/status/run/stop/default/doctor/models/env |
| **claude wrapper** | `~/.local/bin/claude` | Session-binding-aware wrapper (first on PATH). Sources binding → execs real binary. |
| **default-binding.env** | `~/.config/upb/default-binding.env` | Default route env vars (alibaba :8705). Always present. |
| **session-binding.env** | `~/.config/upb/session-binding.env` | Active session binding (transient). Written by `upb run`, cleared by `upb stop`. |
| **routes.yaml** | `~/.config/upb/routes.yaml` | Single source of truth for upb routes (providers, models, ports, keys, priority, enabled) |
| **universal-router src** | `~/shared-local/reports/claude-universal/src/` | TypeScript proxy source (index.ts + adapters/ + middleware/ + utils/ + types/) |
| **universal-router dist** | `~/shared-local/reports/claude-universal/dist/` | Compiled JS (built via `npx tsc`) |
| **providers.yaml** | `~/shared-local/reports/claude-universal/providers.yaml` | Router-level provider config (base_url, api_key refs, model_map, timeouts) |
| **router-alibaba.env** | `~/shared-local/reports/claude-universal/router-alibaba.env` | systemd env file (chmod 600): PORT, UPB_*, LOCAL_SECRET |
| **systemd service** | `~/.config/systemd/user/universal-router.service` | Persistent :8705 proxy (Restart=always) |
| **usage.jsonl** | `~/shared-local/reports/claude-universal/usage.jsonl` | Token usage log (JSONL, appended per-request) |
| **usage-logger.ts** | `~/shared-local/reports/claude-universal/src/utils/usage-logger.ts` | Usage extraction + JSONL append module |
| **SPEC (cookie usage)** | `~/shared-local/reports/claude-universal/SPEC-alibaba-cookie-usage.md` | Spec for cookie-based Alibaba quota fetching (future) |
| **upb cache** | `~/.cache/upb/` | Live-catalog model cache + dynamic port assignments |
| **upb legacy backup** | `~/.local/share/upb/legacy-launchers-2026-08-05.tar.gz` | The 35 removed launcher scripts (5.5 KB) |

---

## 4. Route Table (as of 2026-08-06)

| Route | Port | Kind | Status | Key Source | Notes |
|---|---|---|---|---|---|
| `alibaba/qwen3.8-max-preview` | 8705 | upb | ✅ ok · **default** | `auth.json → alibaba-token-plan.key` | systemd persistent; weekly quota exhausted 08-06, resets 08-07 06:19 UTC |
| `alibaba/qwen3.7-max` | 8704 | upb | ✅ ok | same | on-demand |
| `alibaba/qwen3.7-plus` | 8703 | upb | ✅ ok | same | on-demand |
| `alibaba/qwen3.6-flash` | 8702 | upb | ✅ ok | same | on-demand |
| `alibaba/deepseek-v4-pro` | 8701 | upb | ✅ ok | same | on-demand |
| `alibaba/glm-5.2` | 8706 | upb | ✅ ok | same | on-demand |
| `zai/glm-5.2` | — | anthropic-native | ✅ ok | `$ZAI_API_KEY` (~/.zshrc) | direct to api.z.ai, no proxy |
| `zai/glm-5-turbo` | — | anthropic-native | ✅ ok | same | |
| `zai/glm-4.7` | — | anthropic-native | ✅ ok | same | |
| `zen/deepseek-v4-flash-free` | 8801 | upb | ✅ ok | none (free) | |
| `zen/big-pickle` | 8802 | upb | ✅ ok | none | |
| `zen/north-mini-code-free` | 8803 | upb | ✅ ok | none | |
| `litellm/ornith-9b` | 8901 | upb | ✅ ok | `opencode.json → provider.litellm.options.apiKey` | Lusófona gateway |
| `litellm/omnicoder-9b` | 8903 | upb | ✅ ok | same | |
| `prime-intellect` | dynamic | upb (live catalog) | ✅ ok | `$PRIME_INTELLECT_API_KEY` | pay-per-use, never default |
| `pi-own/qwen36-35b` | 8931 | upb | ❌ disabled | none | backend :8090 dead (gpu-deploy torn down) |
| `deepseek/deepseek-v4-pro` | — | anthropic-native | ❌ disabled | file missing | needs `~/.config/deepseek/api_key` |
| `deepseek/deepseek-v4-flash` | — | anthropic-native | ❌ disabled | same | |
| `ollama-cloud/*` (18 models) | 8447–8646 | upb | ❌ disabled | `$OLLAMA_API_KEY` in `~/.hermes/.env` | unused since 2026-08 |

**Priority order:** alibaba(10) → zai(20) → zen(30) → litellm(40) → prime-intellect(50) → pi-own(55) → deepseek(60) → ollama-cloud(90)

---

## 5. Key Management Map

| Provider | Key type | Location | Format |
|---|---|---|---|
| alibaba-token-plan | json | `~/.local/share/opencode/auth.json` → `alibaba-token-plan.key` | `sk-sp-...` |
| zai | env | `$ZAI_API_KEY` (set in `~/.zshrc`) | hex UUID + suffix |
| litellm | json | `~/.config/opencode/opencode.json` → `provider.litellm.options.apiKey` | `sk-W5-...` |
| prime-intellect | env | `$PRIME_INTELLECT_API_KEY` | |
| deepseek | file | `~/.config/deepseek/api_key` | **MISSING** |
| ollama-cloud | envfile | `~/.hermes/.env` → `OLLAMA_API_KEY` | |
| zen / pi-own | none | — | free/local |

**Doctrine:** keys are referenced by path/env-var in routes.yaml, never stored there. `upb doctor` checks for regressions.

---

## 6. Port Allocation

| Range | Purpose |
|---|---|
| 8701–8706 | alibaba models (static, on-demand except 8705) |
| 8801–8803 | zen free-tier models |
| 8901, 8903 | litellm (Lusófona) |
| 8931 | pi-own (dead) |
| 8447–8646 | ollama-cloud (disabled) |
| 9000–9199 | dynamic ports for `catalog: live` providers (prime-intellect) |

---

## 7. Usage Tracking

### Deployed (2026-08-06): Local JSONL logger
- Every successful request logs: `{ts, provider, model, wire_model, prompt_tokens, completion_tokens, total_tokens, stream}`
- File: `~/shared-local/reports/claude-universal/usage.jsonl`
- Query: `GET http://127.0.0.1:8705/usage` → aggregated by provider/model
- Streaming: `stream_options: {include_usage: true}` injected into outbound requests

### Z.AI quota API (working, no integration yet)
```bash
curl -s "https://api.z.ai/api/monitor/usage/quota/limit" \
  -H "Authorization: $ZAI_API_KEY" -H "Content-Type: application/json"
```
Returns: 5h token window %, monthly MCP calls, plan level.

### Alibaba quota (SPEC ONLY — see [[SPEC-alibaba-cookie-usage]])
- No API-key endpoint exists
- Requires browser cookies from `modelstudio.console.alibabacloud.com`
- Spec at: `~/shared-local/reports/claude-universal/SPEC-alibaba-cookie-usage.md`
- References: CodexBar (Swift), OmniRoute (TS), ClaudeBar (Swift)

### Known quota signals from error responses
- Alibaba 429: `"Your token-plan 1-week quota has been exhausted. The quota will reset at <date> UTC."`
- This reveals: token plan has a **weekly window** (not just 5h)

---

## 8. Evolution Timeline

| Date | Event |
|---|---|
| 2026-09-03 | **Deep-investigation + fixes** ([[upb-launcher-investigation-2026-09-03]]): alibaba expired → `:8705` repointed to opencode-go (`glm-5.2`/`glm-5.3-flash`); reasoning-content leak removed (translate.ts/stream.ts, live+repo); streaming `pendingData` bug fixed; `upb sync` guarded against clobbering a repointed env; default route moved off 429'd zai; `claude-health` pre-flight gate added + hooked into wrapper; stale pre-fix proxies killed; session-binding cleared. |
| ~2026-06 | UPB proxy built (Anthropic↔OpenAI translation, the hard 90%) |
| 2026-07-12 | Ollama Cloud integration, zen free-tier routes |
| 2026-07-20 | alibaba-token-plan note created ([[alibaba-token-plan-20-07-2026]]) |
| 2026-07-26 | Z.AI coding plan configured in Claude settings |
| 2026-08-05 | **The Great Consolidation:** 35 `claude-*` launchers → `upb` CLI + `routes.yaml`. Decision documented in [[Claude Code Routes — upb CLI Decision & Runbook]] |
| 2026-08-05 | prime-intellect live catalog added; zai configured-but-hidden |
| 2026-08-06 | zai enabled (key in ~/.zshrc); pi-own + deepseek disabled (dead backend / missing key); stale :8931 supervisor killed |
| 2026-08-06 | **Usage logging deployed:** usage-logger.ts + GET /usage endpoint + stream_options injection |
| 2026-08-06 | **SPEC written:** cookie-based Alibaba quota fetching (future) |
| 2026-08-06 | Alibaba weekly quota exhausted (resets 08-07 06:19 UTC) |
| 2026-08-06 | **Key restructure:** `~/.config/upb/secrets.env` becomes single source of truth; `upb sync` pulls from auth.json/opencode.json/env and pushes to router env (kills the stale-key bug class) |
| 2026-08-06 | **Main setup:** bare `claude` liberated — `~/.claude/settings.json` env block routes it through `:8705` to any provider |
| 2026-08-06 | **Repo created:** `/home/fabio/projects/upb/` monorepo (router + cli + config + docs + scripts), MIT, secret-free |
| 2026-08-06 | **Self-reproducing installer:** `install.sh`/`uninstall.sh` — rebuild from scratch or take over existing Claude Code (backup+merge, never clobber) |
| 2026-08-06 | **Model discovery:** `upb sync` reports new upstream models for `discover:true` providers (zen `discover_match:free`) |
| 2026-08-06 | **litellm/bonsai diagnosis:** `ornith-9b` serves `bonsai-27b-1bit` — gateway-side aliasing, not an upb bug |
| 2026-08-06 | **Multi-session:** repo `WORKLOG.md` added as shared backlog/session-log hub ([[UPB — Session Handoff 2026-08-06]]) |
| 2026-08-06 | **Session-model binding:** `~/.claude/settings.json` env block removed; `~/.local/bin/claude` wrapper + binding-file mechanism deployed. Sub-sessions and workflow relaunches now stay bound to the model selected via `upb run`. `upb doctor` reports binding state. |

---

## 9. Upstream Provider Details

### alibaba-token-plan
- **Base URL:** `https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1`
- **Also:** Anthropic-protocol at `.../apps/anthropic` (future native route)
- **Plan:** Token Plan Pro (subscription), expires 2026-08-20, auto-renewal OFF
- **Quota windows:** 5-hour rolling + 1-week (discovered via 429 error)
- **Models:** qwen3.8-max-preview, qwen3.7-max, qwen3.7-plus, qwen3.6-flash, deepseek-v4-pro, glm-5.2
- **Usage API:** NONE (cookie-only, see spec)

### zai (Z.AI GLM Coding Plan)
- **Base URL:** `https://api.z.ai/api/anthropic` (anthropic-native, no proxy needed)
- **Plan:** Year-long coding plan, level: lite
- **Quota:** 5h token window + monthly MCP calls
- **Usage API:** ✅ `/api/monitor/usage/quota/limit` + `/model-usage` + `/tool-usage`
- **Models:** glm-5.2, glm-5-turbo, glm-4.7

### zen (OpenCode Zen free tier)
- **Base URL:** `https://opencode.ai/zen/v1`
- **Key:** none (free)
- **Models:** deepseek-v4-flash-free, big-pickle, north-mini-code-free

### litellm (Lusófona Gateway)
- **Base URL:** `https://modelos.ai.ulusofona.pt/v1`
- **Models:** ornith-9b, omnicoder-9b (+ amalia-9b, qwen3.5-9b-mtp in opencode.json)

### prime-intellect
- **Base URL:** `https://api.pinference.ai/api/v1`
- **Catalog:** live (117 models discovered at runtime)
- **Billing:** pay-per-use, balance unknown — explicit runs only

---

## 10. Open Items & Future Work

1. **Alibaba plan expired (2026-08-20) — already lapsed.** `:8705` repointed 2026-09-03 to opencode-go (see [[upb-launcher-investigation-2026-09-03]]). If renewed, revert `router-alibaba.env` + `routes.yaml` `active_until`.
2. **Cookie-based usage fetch** — implement per [[SPEC-alibaba-cookie-usage]] (Phase 1: CLI script, Phase 2: `upb usage` subcommand).
3. **`upb usage` subcommand** — unified usage query: zai via API, alibaba via cookies, others via local JSONL.
4. **DeepSeek key** — restore to `~/.config/deepseek/api_key` to re-enable route.
5. **pi-own** — re-enable after next gpu-deploy; fix model name to `qwen36-27b` (was misconfigured as 35b).
6. **Alibaba anthropic-native route** — `token-plan.../apps/anthropic` endpoint exists; would eliminate proxy hop entirely.
7. **End-state swap** — after 2026-08-20, if fleet healthy: `claude` alias → thin `upb` delegating wrapper.
8. **Zen streaming garble** — one streamed reply came back as token-soup (pre-existing UPB/free-model issue). Verify before trusting zen with real work. **RELATED (fixed 2026-09-03):** the deeper cause was a reasoning-content leak + streaming `pendingData` bug now patched (see [[upb-launcher-investigation-2026-09-03]]).
9. **litellm `ornith-9b` serves `bonsai-27b-1bit`** — confirmed gateway-side aliasing on `modelos.ai.ulusofona.pt`, NOT an upb bug (upb sends `ornith-9b`; direct call echoes `ornith-9b`). Needs Lusófona gateway-admin confirmation of the `model_list` alias.
10. **Repo published?** — `/home/fabio/projects/upb/` is local-only. GitHub remote deferred (no `gh` on box). Fresh-box E2E also pending (no container tooling).
11. **Live ↔ repo CLI drift** — repo `cli/upb` is ahead of live `~/bin/upb` (`sync --full`, `find_router_service`, discovery). Reconcile before the next feature.

> **Multi-session coordination:** the repo's `WORKLOG.md` is the shared backlog + session log for advancing this project across sessions. See [[UPB — Session Handoff 2026-08-06]].

---

## 11. Quick Reference Commands

```bash
# Route management
upb list [--all]                    # show routes
upb status                          # key resolution + health
upb run alibaba/qwen3.8-max-preview # launch claude via route (writes session binding)
upb run litellm/ornith-9b           # bind session to ornith-9b (sub-sessions stay bound)
upb run default                     # first eligible route
upb stop --all                      # kill upb-spawned proxies + clear session binding
upb doctor                          # full diagnostics (incl. binding state)
upb models prime-intellect          # browse live catalog

# Session binding
cat ~/.config/upb/session-binding.env   # active binding (absent = default route)
cat ~/.config/upb/default-binding.env   # default route (alibaba :8705)
which claude                            # must be ~/.local/bin/claude (wrapper)

# Usage
curl -s http://127.0.0.1:8705/usage | python3 -m json.tool
cat ~/shared-local/reports/claude-universal/usage.jsonl | tail -5

# Z.AI quota
source ~/.zshrc && curl -s "https://api.z.ai/api/monitor/usage/quota/limit" \
  -H "Authorization: $ZAI_API_KEY" | python3 -m json.tool

# Service management
systemctl --user status universal-router.service
systemctl --user restart universal-router.service
journalctl --user -u universal-router.service -f

# Build (after editing src/)
cd ~/shared-local/reports/claude-universal && npx tsc
```

---

## 12. File Tree

```
~/bin/upb                                          ← CLI (Python)
~/.local/bin/claude                                ← session-binding wrapper (NEW)
~/.config/upb/routes.yaml                          ← route config (chmod 600)
~/.config/upb/secrets.env                          ← keys (chmod 600)
~/.config/upb/default-binding.env                  ← default route env vars (NEW)
~/.config/upb/session-binding.env                  ← active session binding (transient, NEW)
~/.cache/upb/                                      ← live-catalog cache + ports.json
~/.claude/settings.json                            ← Claude Code settings (NO env block)
~/shared-local/reports/claude-universal/
├── src/
│   ├── index.ts                                   ← main proxy (669+ lines)
│   ├── adapters/{registry,types}.ts
│   ├── middleware/{auth,config,router-config}.ts
│   ├── types/{anthropic,openai,index}.ts
│   └── utils/{errors,stream,translate,usage-logger}.ts
├── dist/                                          ← compiled output
├── providers.yaml                                 ← router provider definitions
├── router-alibaba.env                             ← systemd env (chmod 600)
├── usage.jsonl                                    ← token usage log
├── SPEC-alibaba-cookie-usage.md                   ← future quota spec
├── package.json / tsconfig.json
└── QUICKSTART.md / README.md / architecture-spec-v0.1.md
~/.config/systemd/user/universal-router.service    ← systemd unit
~/.local/share/opencode/auth.json                  ← alibaba + opencode-go keys
~/.config/opencode/opencode.json                   ← litellm key + model config
~/.zshrc                                           ← ZAI_API_KEY, PRIME_INTELLECT_API_KEY
```
