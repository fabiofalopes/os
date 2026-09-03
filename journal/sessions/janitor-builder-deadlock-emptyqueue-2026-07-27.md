---
tags: [session, janitor, harness, runner, fix]
date: 2026-07-27
role: Janitor
verdict: ok — fix applied + 27/27 simulated
job: "queue.md l.61 — FIX BUILDER-LANE DEADLOCK (empty-queue branch)"
---

# Janitor — Builder-Lane Deadlock Fix (empty-queue fall-through)

> Companion fix to the 3-bug job at queue.md l.64 (anchored `[builder]` regex, worker.sh builder budget, pick_builder_job breaker — already in tree from an earlier session). This job closes the hole that session left open.

## The bug (verified against source, not guessed)

When every unchecked queue job routes to the builder lane, the worker claim loop (runner.sh l.218–221) defers them all → `J_JOB` empty → the empty-queue branch fired **before** the builder dispatch (l.312):

1. pending proposal → `BRIDGE` merge + `exit 0` — merged two MORE jobs into the same deadlock (ROW-4 EXECUTE 07-27T01:00Z, INDEX SWEEP 01:45Z),
2. else reflection throttled → `SKIP(EMPTY_QUEUE)` + `exit 0` — every wave, ~6h of stranded jobs.

The builder section was unreachable; the queue could never drain.

## The fix (`_harness/runner.sh`, two edits)

1. **New helpers** after `job_lane()`: `builder_jobs_pending` (any unchecked job routes to builder) and `serial_lane_this_wave` (mirrors the every-Nth-wave gate exactly: quota hold → council precedence → `wave % BUILDER_EVERY`).
2. **Empty-queue branch restructured** to if/elif/else with the builder-pending check first:
   - builder jobs pending + serial lane fires this wave → **fall through** (no bridge, no reflection — the queue is not empty),
   - builder jobs pending + non-builder wave → `SKIP(BUILDER_WAIT)` + exit (bookkeeping line; excluded from daily cap + fail counts by Guard 2, health.sh, evaluate.sh — verified),
   - truly empty → existing bridge / reflection / `SKIP(EMPTY_QUEUE)` behavior, unchanged.

`SESSION_TIMEOUT` untouched (900s trust-bug guard stays).

## Evidence (test, don't wonder)

- `bash -n` clean on runner.sh **and** worker.sh.
- Full simulation (`/tmp/forge-sim`: real fixed runner + stub worker + sandbox vault/queue/log, production lane params `BUILDER_EVERY=2`): **27/27 assertions pass** —
  - T1 builder-only queue, odd wave + pending proposal → `SKIP(BUILDER_WAIT)`, **no bridge merge**, nothing dispatched, jobs preserved;
  - T2 builder-only queue, wave 2 → builder dispatches ROW-4 EXECUTE (`ok`), marks `[x]`, proposal untouched, exactly one dispatch;
  - T3 drain: wave 3 waits, wave 4 (council wave, `COUNCIL_ENABLED=0` → builder wins) dispatches INDEX SWEEP → queue empty;
  - T4/T5 regressions: genuine empty-queue BRIDGE and `SKIP(EMPTY_QUEUE)` throttle unchanged;
  - T6 mixed queue: worker job runs on worker slot, builder job deferred;
  - T7 a job merely *quoting* `[builder]` in its body routes to the WORKER lane (anchored-regex regression).
- Live classification of the real queue with the fixed routing: l.58/60/63 → builder, l.61/64 → worker.

## Self-heal (no re-staging)

Next wave: workers claim l.61 (+l.64 — possibly deferred one wave by the conservative `queue.md` target-dedup, harmless). Each even wave: builder takes the top routed job (ROW-4 EXECUTE → INDEX SWEEP → MEMORY REFRESH). When the queue goes builder-only, the new branch waits/dispatches instead of bridge-looping. Deadlock cannot recur.

## Residual observation (not fixed — out of scope)

Target-dedup in the claim loop keys on the last `*.md` token in the job text; jobs that merely *mention* `queue.md` collide and one defers a wave. Conservative and self-healing; a future Janitor could strip quoted mentions before extracting the target.

Related: [[multi-agent-orchestration-patterns]] · [[queue]] · [[schedule]] · prior art `journal/sessions/janitor-builder-lane-routing-2026-07-26.md`
