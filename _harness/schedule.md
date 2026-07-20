# Schedule & Cadence

> How the engine runs, and why. This is a *tuned* setting, not a fixed one — the recurring
> [Steward] META-REVIEW job re-decides the interval from evidence (see queue.md).

## Current cadence
- **Cron:** every **20 minutes**, 24/7 → `_harness/runner.sh`
- **Why 20 not 10 (yet):** a headless session averages 10–15 min. 10-min ticks with a
  single-instance lock means every other tick skips while one runs — wasted wakeups, no
  extra work. 20 min ≈ one session per tick with clean handoff. The META-REVIEW job will
  move this to 10 min *if* sessions run short and the daily cap isn't hit, or to 30+ if
  they're burning tokens without artifacts.
- **Overlap safety:** `flock` in runner.sh — if a session is still running when the next
  tick fires, that tick exits immediately. No double-spend, no LOG races.

## Cost guards (the "don't burn tokens" layer)
- `MAX_SESSIONS_PER_DAY=48` → hard ceiling (~24h × 2/hr). Runner skips past it.
- `MAX_TURNS=40` per session, `SESSION_TIMEOUT=900s` → no runaway session.
- `MODEL=""` today (claude default). **First tuning move:** point background sessions at
  the cheap Qwen endpoint overnight (0.2× price 22:00–08:00, per alibaba-token-plan).

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

## What "running well" looks like (week 1)
- LOG.md fills with ~30–48 lines/day, most `ok`, each naming a durable artifact path.
- INDEX.md and MEMORY.md exist and stay current.
- wiki/ gains atomic, verdicted research notes; the value ledger has ranked hypotheses.
- The first META-REVIEW has already adjusted the interval or caps from real data.
- Git history shows steady, small, reviewable commits.

## Change log
- 2026-07-20: engine stood up. 20-min cadence, 48/day cap, default model. First run pending.
