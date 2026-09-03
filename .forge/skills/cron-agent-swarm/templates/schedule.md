# Schedule & Cadence

> How the engine runs, and why. This is a *tuned* setting, not a fixed one — the
> recurring [steward] META-REVIEW job re-decides the interval from evidence in LOG.md.

## Picking a cadence (measure, don't guess)
1. Run a few waves; read the durations in LOG.md (`| <dur>s |` column).
2. Take the median and max ok-session length. Pick a tick that contains the max —
   if sessions run median ~5 min / max ~10 min, `*/15` gives clean handoffs and `flock`
   rarely skips.
3. Revisit when anything changes (model speed, token price, job size).

Example crontab line (runner cd's itself; cron's cwd doesn't matter):
```
*/15 * * * * /path/to/your/workspace/_harness/runner.sh >> /path/to/your/workspace/_harness/state/cron.log 2>&1
```

## Overlap safety
`flock` in runner.sh — if a wave is still running when the next tick fires, that tick
exits immediately. No double-spend, no LOG races, no orphaned workers (startup reaper +
exit trap clean up anything a SIGKILL left behind).

## Cost guards (the "don't burn tokens" layer — all in config.env)
- `MAX_SESSIONS_PER_DAY` — hard daily ceiling; runner skips past it.
- `MAX_TURNS` per session + `SESSION_TIMEOUT` — no runaway session.
- `WORKER_BUDGET` — outer deadline for a worker's *entire* model-fallback cascade, so a
  wave can never wedge the cron.
- `MODEL_CHAIN` — cheap/free first; total routing failure logs `ROUTING_FAIL` instead of
  silently spending paid quota. Put a paid default last only if you mean it.
- `MAX_JOB_RETRIES` — a poisoned job is quarantined `[!]` after N *real* fails (infra
  fails like a dead proxy never count) so the queue advances instead of storming.

## The two layers
- **Foreground:** you, live, steering — feeding the queue, approving promotions, setting
  spend ceilings.
- **Background:** this cron engine — the "subconscious" that keeps researching, distilling,
  curating, and growing the workspace between your sessions.

## Rhythm of job types
- Most waves: knowledge/build/value jobs from the queue, `WORKERS_PER_TICK` in parallel.
- Every `BUILDER_EVERY`-th wave: one serial deeper session (bigger turn budget).
- Empty queue: at most one [steward] reflection per `REFLECT_EVERY` seconds; it stages new
  jobs in `proposals.md`, which the runner auto-merges into the queue (workers never write
  the queue directly).
- The META-REVIEW is what makes the whole thing self-correcting: it reads the evidence in
  LOG.md and rewrites the queue + config. The harness tunes itself.

## What "running well" looks like (week 1)
- LOG.md fills with mostly `ok` lines, each naming a durable artifact path.
- The index + working-memory files exist and stay current (a curator job maintains them).
- The first META-REVIEW has already adjusted the interval or caps from real data.
- Git history shows steady, small, reviewable commits (a serial job commits; workers don't).

## Change log
- *(record each cadence/cap change here with the LOG evidence that justified it)*
