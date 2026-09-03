---
tags: [infra, session-digest, upb, universal-router, claude-code, breaking-claude, version-map, FM]
date: 2026-09-03
role: Orchestrator
status: complete — root-caused "claude seems shit" to pre-fix proxy processes; fixed + gated
related:
  - "[[Claude Code Routes — upb CLI Decision & Runbook]]"
  - "[[Universal Provider Bridge — Project Master Map]]"
  - "[[Breaking Claude — The Landscape 2026 (Research Synthesis)]]"
  - "[[FAILURE-MODES]]"
  - "[[Claude Code No-Login on New Tmux Panes]]"
---

# upb Launcher Deep-Investigation + Fixes (2026-09-03)

> **Verdict (one screen):** Claude Code was **never** the problem, the model was **never** the problem, and the version was **secondary**. "Claude code seems shit with any model" traces to **two bugs in the upb translation router + stale pre-fix proxy processes still serving corrupted code**, plus one dead provider (alibaba, expired 2026-08-20). Fixed, verified end-to-end (`claude -p` → clean `PONG`), and gated behind a new `claude-health` pre-flight.

## What was actually broken (evidence, not speculation)

1. **Alibaba Token Plan expired** (`active_until: 2026-08-20`, `AccessDenied/unpurchased`), but the persistent `:8705` router still mapped every `claude-*` name → `qwen3.8-max-preview` on that dead plan → `fetch failed [retryable]` ×4 in the Sep 02 22:49–22:50 sessions.
2. **Reasoning-content leak (critical).** The router pivoted to *reasoning models* (glm-5.2, glm-5.3-flash, deepseek-v4). Those models emit `reasoning_content` (chain-of-thought) separately from `content` (the answer). `translate.ts`/`stream.ts` fell back to `reasoning_content` when `content` was empty → CoT flooded answers. Live `claude -p "say PONG"` returned `"context word", but appears the looks system actualReply withONG just say P`.
3. **Streaming `pendingData` clearing bug (critical).** `_transform` wiped the pending buffer when a chunk arrived without an `\n\n` boundary, silently dropping the next content event → truncated/garbled streaming.
4. **Stale proxies.** `:9000` (03:48) and `:9001` (04:43) were still running the **pre-fix** `dist/` long after `dist/utils/*.js` was corrected at 05:05 — every session timestamped before 04:54 hit them and got corrupted, even after the code was fixed on disk.

## Session text — the smoking gun (two parallel analysts, 8 files + 1.7MB)

| File (version) | Route | Result |
|---|---|---|
| `952b8488` (2.1.247) | `claude-sonnet-4-6` | ✅ clean `PONG`, `end_turn`, valid usage |
| `610263c7` (2.1.247) | `glm-5.3` | ✅ clean `PING_OK` |
| `408e2034`, `1e949e1e`, `04404440`, `76dd8393` (2.1.247) | `glm-5.3-flash` | ❌ word-salad, CoT leak, token-repetition loops, broken tool-calls (`"name":""` → 24× `No such tool`) |
| `f8d536e5` (2.1.223, 16h) | `glm-5.3` | ✅ healthy agentic build (297 Bash) — see below |

The split is **not** version, **not** model — it's **which proxy process served the request**. Direct upstream `glm-5.3-flash` and `glm-5.2` both return clean `PONG` today.

## Version map (4 versions in evidence, ~9.6k events)

| Version | Events | Character |
|---|---|---|
| **2.1.247** | 238 | current install. SDK/queue entrypoint (`sdk-cli`, `queue-operation`, `promptSource:sdk`), subagent listing. Clean when routing is clean. |
| **2.1.246** | 359 | brief; needs a dedicated pass |
| **2.1.223** | 5180 | best-instrumented: `cost-state` telemetry (`totalCostUSD`, `totalLinesAdded/Removed`), transparent `thinking` blocks with signatures, `cache_creation` metrics. **Zero subagent delegation.** |
| **2.1.197** | 3867 | oldest; needs a dedicated pass |

**Favorite lean:** 2.1.247 for stability+features (proven clean on a healthy path). 2.1.223 for telemetry richness. The "does 2.1.247 keep 2.1.223's telemetry" question is open — no long 2.1.247 session exists yet to compare.

## Fixes shipped

1. **`:8705` repointed** (backup `router-alibaba.env.bak-*`) dead alibaba → `opencode-go` (`glm-5.2` / `glm-5.3-flash`), `LOCAL_SECRET` preserved.
2. **Reasoning fallback removed** from `translate.ts` + streaming `content`-only in `stream.ts` — in live `dist/`, live `src/`, and repo `router/`.
3. **`pendingData` clearing fixed** (keep buffer when no `\n\n` boundary yet).
4. **`upb sync` guard** added (live `~/bin/upb` + repo `cli/upb`): push no longer clobbers a repointed env — only fires when `UPB_PROVIDER='alibaba-token-plan'` is actually present.
5. **Default route** moved off 429'd `zai` → `:8705` opencode-go (backup `default-binding.env.bak-*`).
6. **Stale proxies killed** (`:9000`/`:9001`), stale `session-binding.env` cleared.
7. **`claude-health` gate** (`~/bin/claude-health`) + non-invasive hook in the wrapper — checks C1 stale-proxy, C2 dead-binding port, C3 `:8705` health, C4 live PONG smoke. `CLAUDE_HEALTH_GATE=0` disables, `CLAUDE_HEALTH_BLOCK=1` makes fatal.

## The durable lesson

Version selection is **secondary** to a pre-launch **proxy/dist staleness check**. Today 5 of 8 sessions were corrupted not by Claude Code, not by the model, but by pre-fix proxy processes and a dead provider. The gate now enforces the actual invariant: *every session starts on a healthy routing path*.

$0 spent on live inference; parallel analysts + direct curl/SSE probes only.

## Remaining (reported, not fixed — human call)

1. Rebuild router via a **working `tsc`** (the toolchain `lib/tsc.js` is a 267-byte stub).
2. Minor router bugs: OpenAI endpoint echoes upstream `glm-5.2` (should echo requested `claude-*`); unknown model → `401` (should be 400/404); `/v1/models` duplicates; malformed `msg_chatcmpl-…` id.
3. Stale model policy: hub `AGENTS.md` still pins `alibaba-token-plan/qwen3.8-max-preview` (dead); `opencode.json` `small_model: zai/glm-5-turbo` unresolvable.
4. `glm-5.3-flash` triggers Claude Code `unrecognized_model` warning → auto-compacts at 200k (needs `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1` or `modelOverrides`).
