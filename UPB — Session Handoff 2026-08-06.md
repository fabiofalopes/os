---
title: UPB — Session Handoff 2026-08-06
date: 2026-08-06
tags: [infra, handoff, upb, universal-router, session-binding]
status: handoff — continue in clean session
related: "[[Universal Provider Bridge — Project Master Map]]"
---

# UPB — Session Handoff (2026-08-06)

> Pick-up doc for a clean session. The companion [[Universal Provider Bridge — Project Master Map]] is the durable architecture reference; this is the operational state + what's next.

## TL;DR

The **Universal Provider Bridge (upb)** — a dual-intake LLM translation proxy + route-control CLI + single-source-of-truth key manager — was converged from a scattered live setup into a **public-ready, self-reproducing git repo** at `/home/fabio/projects/upb/` (3 commits, clean). Bare `claude` is now "liberated": it routes through the local proxy to any provider. A real idempotent installer rebuilds the whole setup from scratch or takes over an existing Claude Code install. Usage tracking, key management, and free-model discovery all work. Live system is healthy and untouched by the repo work.

**Latest (session 2, evening):** The **session-model binding problem** is solved. Previously, when `upb run litellm/ornith-9b` launched a session, any sub-sessions or workflow relaunches silently fell back to the default alibaba route (because `~/.claude/settings.json` hardcoded the env vars). Now a **claude wrapper + binding file** mechanism ensures all downstream sessions stay bound to the originally selected model. See §Session-Model Binding below.

## Multi-session coordination (join in)

This project is set up for **multiple sessions to contribute over time**. The coordination hub is **`/home/fabio/projects/upb/WORKLOG.md`** — a shared backlog + in-progress/done tracker + session log.

**To join:** read `WORKLOG.md` first → check *In progress* (don't duplicate) → claim an *Open* item → work in small commits → log it in the session-log table. Ground rules (secrets never in repo, don't break live, verify before Done) are in the WORKLOG header. The open backlog includes: GitHub remote, fresh-box E2E, Alibaba cookie-usage fetch, live↔repo CLI reconciliation, the litellm/bonsai confirmation, and adopting the 5 new zen free models.

## What was accomplished this session (the arc)

1. **Route hygiene** — disabled dead routes (`pi-own` backend gone, `deepseek` key missing), killed a stale :8931 supervisor, enabled `zai` (key added to `~/.zshrc`).
2. **Key restructure** — created `~/.config/upb/secrets.env` (chmod 600) as the single source of truth; `upb sync` pulls from auth.json/opencode.json/env and pushes to the router env file. Killed the stale-key bug class.
3. **Usage logging** — universal-router now logs every request to `usage.jsonl` + exposes `GET /usage` (41 reqs / 8.2M tokens captured this session).
4. **Main setup** — `~/.claude/settings.json` env block points bare `claude` at `http://127.0.0.1:8705` → the router → alibaba token plan. Verified end-to-end.
5. **Repo creation** — `/home/fabio/projects/upb/` monorepo (router/ + cli/ + config/ + docs/ + scripts/), MIT, zero secrets/personal paths.
6. **Self-reproducing installer** — `scripts/install.sh` (8 phases, idempotent, `--dry-run`/`--prefix`/`--no-claude`/`--force`) + `scripts/uninstall.sh`. Takes over existing Claude Code via backup+merge, never clobbers.
7. **Docs** — README + SETUP + ARCHITECTURE rewritten around the installer.
8. **Free-model discovery** — `upb sync` now reports new upstream models for `discover: true` providers (zen `discover_match: free` → surfaced 5 new `-free` models).
9. **Fixed `claude` binary** — `OSError: Exec format error` was a broken npm install (postinstall skipped); repaired via `node .../claude-code/install.cjs`.
10. **Diagnosed litellm `ornith-9b` → `bonsai-27b-1bit`** — proved it's gateway-side aliasing, not an upb bug (see Gotcha #7).
11. **Multi-session coordination** — added `WORKLOG.md` to the repo as the shared backlog/session-log hub so any session can claim and advance work.
12. **Session-model binding** (session 2) — solved the sub-session model drift problem. `~/.claude/settings.json` env block **removed**; replaced by a `~/.local/bin/claude` wrapper + binding-file mechanism managed by `upb run`/`upb stop`. All downstream sessions now stay bound to the originally selected model. See dedicated section below.

## Session-Model Binding (NEW — session 2)

### Problem solved
When `upb run litellm/ornith-9b` launched a session, any sub-sessions or workflow relaunches spawned by Claude Code would silently fall back to the default alibaba route. Root cause: `~/.claude/settings.json` had a hardcoded `env` block (`ANTHROPIC_BASE_URL=http://127.0.0.1:8705`) that every new Claude Code process read, overriding the parent's env vars.

### Solution: wrapper + binding file
```
upb run <route>
  → writes ~/.config/upb/session-binding.env (route-specific env vars)
  → execs claude (via wrapper at ~/.local/bin/claude)

Any subsequent `claude` invocation (sub-session, relaunch):
  → wrapper finds session-binding.env → sources it → stays bound ✓

upb stop
  → clears session-binding.env → next bare `claude` uses default-binding.env
```

### Components
| File | Role |
|------|------|
| `~/.local/bin/claude` | Wrapper (first on PATH). Sources binding, execs real binary. |
| `~/.config/upb/session-binding.env` | Active session binding (written by `upb run`, cleared by `upb stop`) |
| `~/.config/upb/default-binding.env` | Default route (alibaba :8705) for bare `claude` |
| `~/.claude/settings.json` | **env block REMOVED** — wrapper owns routing now |

### Key behaviours
- `upb run` also sets `ANTHROPIC_MODEL` + `CLAUDE_CODE_SUBAGENT_MODEL` in the binding (was missing before)
- `upb doctor` reports binding state (wrapper installed, default present, active binding or not)
- Fallback: if both binding files are missing, wrapper hardcodes alibaba :8705 defaults
- **Limitation:** single binding file = last `upb run` wins. Concurrent sessions on different models not yet supported.

---

## Current state

### Repo — `/home/fabio/projects/upb/` (3 commits, clean worktree)
```
4736b3d feat(sync): new-model discovery for rotating provider catalogs
d7e07b6 feat: self-reproducing installer — rebuild from scratch or take over
4969aa5 feat: initial release — Universal Provider Bridge (upb)
```
Layout: `router/src/` (TS proxy) · `cli/upb` (Python CLI) · `config/*.example` · `docs/` · `scripts/install.sh|uninstall.sh` · README · LICENSE(MIT) · .gitignore.

### Live system (healthy, NOT the repo — see gotcha #3)
- `universal-router.service` (systemd --user) on **:8705** → alibaba token plan. `/health` ok.
- Bare `claude` → **wrapper** (`~/.local/bin/claude`) → default-binding.env → router :8705.
- `upb run <route>` → writes session-binding.env → all sub-sessions stay bound.
- `~/bin/upb` CLI · `~/.config/upb/{routes.yaml,secrets.env,default-binding.env}`.
- Router source live at `~/shared-local/reports/claude-universal/` (usage.jsonl + SPEC-alibaba-cookie-usage.md there).

## Key paths

| What | Where |
|---|---|
| Repo (source of truth) | `/home/fabio/projects/upb/` |
| Live router source | `~/shared-local/reports/claude-universal/` |
| Live CLI | `~/bin/upb` |
| Routes config | `~/.config/upb/routes.yaml` |
| Secrets (single source) | `~/.config/upb/secrets.env` (chmod 600) |
| Live router env | `~/shared-local/reports/claude-universal/router-alibaba.env` |
| systemd unit | `~/.config/systemd/user/universal-router.service` |
| Usage log | `~/shared-local/reports/claude-universal/usage.jsonl` |
| Claude settings | `~/.claude/settings.json` (**no env block** — wrapper owns routing) |
| Claude wrapper | `~/.local/bin/claude` (session-binding aware) |
| Default binding | `~/.config/upb/default-binding.env` |
| Session binding (active) | `~/.config/upb/session-binding.env` (transient) |
| Alibaba cookie-usage spec | `~/shared-local/reports/claude-universal/SPEC-alibaba-cookie-usage.md` |

## Verified working
- Bare `claude` routes through :8705 (journal shows `→ alibaba-token-plan/qwen3.8-max-preview`).
- Usage logging (JSONL + `/usage`), incl. streaming via `stream_options:{include_usage:true}`.
- `upb sync` (key pull → secrets.env → router env) and `upb sync` discovery (5 new zen `-free` models).
- Installer `--dry-run` changes nothing; isolated `/tmp` install boots router to healthy `/health`; settings-merge preserves existing keys; systemd unit renders correctly.
- Z.AI quota API (`/api/monitor/usage/quota/limit`) works with `$ZAI_API_KEY`.

## Pending / user decisions (not agent-blocking)
1. **GitHub remote** — deferred (local-first). When ready: `apt install gh && gh auth login && gh repo create upb --public --source=. --push`. No `gh` on this box yet.
2. **True fresh-box E2E** — no container tooling here (docker/podman/nspawn absent); needs a real spare box/VM. Isolated boot-to-healthy is the strongest proof so far.
3. **Live ↔ repo CLI divergence** — live `~/bin/upb` and repo `cli/upb` drifted (repo is ahead: `sync --full`, `find_router_service`, discovery). Reconcile by deploying repo → live with `UPB_ROUTER_ENV` pointed at the live router env, OR keep them intentionally separate. Decide before next `upb` feature.
4. **Alibaba cookie-based usage** — spec written, not implemented (Alibaba has NO API-key usage endpoint; console cookies required). See SPEC file.
5. **litellm `ornith-9b` → `bonsai-27b-1bit`** — confirm with the Lusófona gateway admin whether this aliasing is intentional (see Gotcha #7). Nothing to change in upb.
6. **Adopt new zen free models** — discovery surfaced 5 new `-free` models; add wanted ones to routes.yaml.

## Gotchas / decisions
1. **`secrets.env` is the single source of truth.** `upb sync` propagates it. Never hand-edit the router env file for keys (that's how the stale-key bug happened).
2. **Alibaba token plan has a WEEKLY quota** (seen via 429: "1-week quota exhausted, resets <date>"). No API-key usage endpoint exists — only browser-cookie console gateway.
3. **Live system ≠ repo.** The repo is the future source of truth; the live setup still runs from `~/shared-local/reports/claude-universal/`. Don't assume editing the repo changes the live proxy (it doesn't until deployed).
4. **`claude` binary fragility** — npm reinstall can skip postinstall → `claude.exe` becomes a stub → `Exec format error`. Fix: `node ~/.npm-global/lib/node_modules/@anthropic-ai/claude-code/install.cjs`.
5. **Installer safety** — always `--dry-run` first; it backs up `settings.json` before merging and never clobbers config/keys.
6. **Model discovery is report-only** — it never edits routes.yaml; you add discovered models manually.
7. **litellm `ornith-9b` actually serves `bonsai-27b-1bit`** — observed in LiteLLM monitoring. Verified NOT an upb bug: upb's :8901 proxy sends `ornith-9b` correctly, and a direct gateway call with `model:"ornith-9b"` returns `model:"ornith-9b"`. The Lusófona gateway aliases `ornith-9b` → a deployment named `bonsai-27b-1bit` server-side; the API echoes the alias while monitoring logs the real deployment. Gateway admin info endpoints are blocked for this key (`llm_api_routes` only). Needs gateway-admin confirmation; nothing to fix in upb.
8. **Session binding is single-slot.** `~/.config/upb/session-binding.env` is one file. If two terminals run `upb run` with different models concurrently, the last one wins. Not a problem for the current single-session workflow, but needs per-PID binding if concurrency becomes routine.
9. **Never re-add an `env` block to `~/.claude/settings.json`.** The wrapper (`~/.local/bin/claude`) owns routing now. Adding env vars back to settings.json would silently override the binding mechanism and reintroduce the model-drift bug.
10. **The wrapper must stay first on PATH.** `~/.local/bin` is position 1. If PATH order changes (e.g., new shell config), the wrapper won't intercept and binding breaks silently. `upb doctor` checks this.

## Next-session quickstart
```bash
# orient
cat /home/fabio/projects/upb/README.md
git -C /home/fabio/projects/upb log --oneline
upb list --all && upb doctor
curl -s http://127.0.0.1:8705/usage | python3 -m json.tool
# verify live router
systemctl --user is-active universal-router.service
# verify session binding mechanism
which claude                          # should be ~/.local/bin/claude (wrapper)
cat ~/.config/upb/default-binding.env # default route
ls ~/.config/upb/session-binding.env  # should NOT exist (no active binding)
# discover new free models
upb sync | tail
# test a bound session (optional)
# upb run litellm/ornith-9b   → verify sub-sessions stay on ornith-9b
# upb stop litellm/ornith-9b  → verify binding cleared
```
