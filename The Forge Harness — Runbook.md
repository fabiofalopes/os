---
tags: [harness, runbook, operations, meta]
date: 2026-07-20
status: active
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
---

# The Forge Harness — Runbook

> How to **operate, observe, and tune** the background cron engine. The engine lives in `_harness/`; this is the human-facing manual.

## What's running
A cron job fires every 20 min → `_harness/runner.sh` → picks the top unchecked job from `_harness/queue.md` → runs **one bounded headless Claude session** (`claude -p`) against the vault → logs the result to `LOG.md` → checks the job off. Governed by `CLAUDE.md`. See `_harness/schedule.md` for cadence rationale.

## Observe it (the three dials)
1. **`LOG.md`** — one line per session: `date time | duration | verdict | model | job | one-line summary`. This is the pulse. `verdict=ok` + a named artifact path = healthy. The `model` field shows which fallback served it; `ROUTING_FAIL` means the whole chain is down.
2. **`_harness/queue.md`** — what's queued vs. done. If it's all `[x]` and no new jobs appear, the META-REVIEW isn't firing or the engine is idle.
3. **`git log`** — the vault is a repo; every artifact is a reviewable commit. `git log --oneline` = the growth ring.

```bash
tail -20 ~/obsidian-vault-kali/LOG.md          # recent sessions
grep -c "^- $(date -u +%F)" ~/obsidian-vault-kali/LOG.md   # runs today
cd ~/obsidian-vault-kali && git log --oneline | head       # growth
```

## Tune it
- **Interval:** edit the crontab (`crontab -e`) — the `*/20` field. Or let the META-REVIEW job recommend it.
- **Spend ceiling / turns / timeout / model:** `_harness/config.env`.
- **Routing/auth:** `_harness/secrets.env` (git-ignored, mode 600) holds `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` so cron's bare env can route claude through the proxy. If the token rotates, regenerate it from a working session (capture the two vars into that file).
- **What it works on:** `_harness/queue.md` — just add `- [ ] [Role] …` lines. Order = priority.
- **The rules it plays by:** `CLAUDE.md` (human-governed; the agent can't edit it).

## Stop / pause it
```bash
crontab -l | grep -v '_harness/runner.sh' | crontab -   # remove the entry
```
A running session finishes on its own (bounded by `SESSION_TIMEOUT`). The `flock` means at most one runs at a time.

## Safety model (read this)
- Background sessions run with `--dangerously-skip-permissions` — **necessary** for unattended runs (no human to click approve). The blast radius is bounded by: the vault is git-tracked (recoverable), `CLAUDE.md` forbids editing itself / moving capital / touching the queue+log, and each session is turn- and time-capped.
- **Capital is never deployed by the engine.** Z2/Z4 sovereignty: the agent proposes, the human authorizes money. This is a hard line (see [[Bootstrap to Self-Funding — The Agent Life Arc]]).
- Cost guard: `MAX_SESSIONS_PER_DAY` hard-stops spend; point `MODEL` at cheap overnight Qwen to run more for less.
- **Before editing the engine:** `_harness/FAILURE-MODES.md` catalogs the 6 incident classes the harness has taken (proxy storm, trust-bug hang, quota storm, builder-lane deadlock ×2, monolithic-job timeout ×4, duplicate dispatch — each with LOG evidence, root cause, shipped breaker, regression check) and a **PRE-CHANGE CHECKLIST** every `runner.sh`/`worker.sh`/`config.env` edit must pass before it ships. It exists because routing was patched twice in 24h — test against known failure modes first.

## The self-correcting loop
The recurring **[Steward] META-REVIEW** job reads `LOG.md`, judges whether the interval/caps are right, appends tuned jobs to the queue, and writes a review to `journal/sessions/`. **This is the parent watching the child** — it's how the engine tunes itself from evidence instead of guesswork (see [[Operating Principle — Test Don't Wonder]]).

## First-week checklist
- [ ] LOG.md filling with `ok` lines naming artifacts
- [ ] INDEX.md + MEMORY.md created by the substrate jobs
- [ ] wiki/ gaining verdicted research notes
- [ ] value ledger seeded with ranked hypotheses
- [ ] first META-REVIEW has adjusted interval or caps from data
- [ ] steady small git commits
