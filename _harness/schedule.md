# Schedule & Cadence

> How the engine runs, and why. This is a *tuned* setting, not a fixed one — the recurring
> [Steward] META-REVIEW job re-decides the interval from evidence (see queue.md).

## Current cadence
- **Cron:** every **15 minutes**, 24/7 (`*/15`) → `_harness/runner.sh`
- **Why 15 (ratified 2026-07-21 by META-REVIEW #1):** measured ok-sessions run median
  ~5 min, max ~10.5 min — all fit inside a 15-min tick, so `flock` rarely skips and
  handoffs are clean. The 2026-07-21 failure storm was failure-*handling* (dead proxy,
  no breaker), not cadence; slowing ticks would only have stretched it. Tokens are free
  during the Alibaba preview window, so there's no cost argument for 20+. The META-REVIEW
  job moves this to 10 min *if* sessions stay short once tokens are paid and the cap
  isn't hit, or to 30+ if they start burning tokens without artifacts.
- **Overlap safety:** `flock` in runner.sh — if a session is still running when the next
  tick fires, that tick exits immediately. No double-spend, no LOG races.

## Cost guards (the "don't burn tokens" layer)
- `MAX_SESSIONS_PER_DAY=90` → hard ceiling (15-min cadence ≈ 96 ticks/day). Runner skips
  past it. Ratified 2026-07-21: real usage runs ~24/day; the poisoned-job breaker
  (`MAX_JOB_RETRIES=3`) now bounds storms, so the cap stays a backstop, not a constraint.
- `MAX_TURNS=40` per session, `SESSION_TIMEOUT=900s` → no runaway session.
- `MODEL_CHAIN` routes free-preview → cheap-flash → stronger-max (all Qwen); routing
  failure logs ROUTING_FAIL rather than spending paid quota. Paid claude-default is
  deliberately NOT in the chain — append an empty `""` entry to allow it as last resort.

## The two layers
- **Foreground:** you and I, live, steering — feeding ideas, approving Z2 promotions, setting capital ceilings.
- **Background:** this cron engine — the "subconscious" that keeps analyzing, distilling,
  curating, and growing the vault between our sessions.

## Rhythm of job types
- Most ticks: one knowledge/skill/value job from the queue.
- Every ~6th tick (or when queue empties): a **[Steward] META-REVIEW** — the parent
  checking on the child. Is it growing healthy? Stressed? Wasting resources? Tune accordingly.
- The META-REVIEW is what makes the whole thing self-correcting: it reads the evidence in
  LOG.md and rewrites the queue + config. The harness tunes itself.

## Lane routing (worker vs builder)
- Most jobs run on the **worker lane** (parallel; `SESSION_TIMEOUT=900`/`MAX_TURNS=40`). Jobs
  that need the bigger **builder lane** (`BUILDER_BUDGET=2400`/`BUILDER_MAX_TURNS=80`) can be
  routed there so they don't double-timeout on the worker lane:
  - **Explicit:** put `[builder]` anywhere in the job text — always routes to builder.
  - **Auto-detect:** `BUILDER_ROUTE_PATTERN` (config.env, ERE) — default `^\[Quant\][^:]*EXECUTE`
    catches `[Quant] EXECUTE …` jobs. Workers *skip* routed jobs in the claim loop; the builder
    wave picks them first. Added 2026-07-26 after a ROW-3 EXECUTE job burned 2×900s on workers
    then ran in 741s on builder (LOG 2026-07-26T14:30/14:45/14:57Z). `SESSION_TIMEOUT` was
    deliberately NOT raised — the 900s cap guards the trust-bug hang. Tune the pattern carefully:
    the `^\[Quant\]` anchor is what keeps `[Critic] … before the EXECUTE job` on the worker lane.

## What "running well" looks like (week 1)
- LOG.md fills with ~30–48 lines/day, most `ok`, each naming a durable artifact path.
- INDEX.md and MEMORY.md exist and stay current.
- wiki/ gains atomic, verdicted research notes; the value ledger has ranked hypotheses.
- The first META-REVIEW has already adjusted the interval or caps from real data.
- Git history shows steady, small, reviewable commits.

## Change log
- 2026-07-20: engine stood up. 20-min cadence, 48/day cap, default model. First run pending.
- 2026-07-21: META-REVIEW #1 ([[meta-review-2026-07-21]]) ratified the live settings from
  LOG evidence: 15-min cadence (`*/15` crontab) and 90/day cap (both already in place),
  MODEL_CHAIN on the free Qwen preview. Docs synced to reality; no dial moved.
- 2026-07-26: builder-lane routing ([[janitor-builder-lane-routing-2026-07-26]]) — a `[builder]`
  tag + `BUILDER_ROUTE_PATTERN` auto-detect dispatch data-heavy jobs to the builder lane instead
  of double-timing-out on the worker lane. `SESSION_TIMEOUT` unchanged.
