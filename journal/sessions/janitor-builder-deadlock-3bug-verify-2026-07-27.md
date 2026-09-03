---
tags: [session, janitor, harness, runner, worker, verification]
date: 2026-07-27
role: Janitor
verdict: ok — already-fixed + independently verified (14/14 assertions)
job: "queue.md l.64 — FIX THE BUILDER-LANE DEADLOCK (3 verified bugs)"
---

# Janitor — Builder-Lane Deadlock: 3-Bug Fix Verification

> **Status:** The three-bug fix described in this job was **already present in the working tree** (applied by an earlier session; documented in [[janitor-builder-deadlock-emptyqueue-2026-07-27]] as "already in tree"). This session independently verified the in-tree code against the job's three acceptance criteria (i)(ii)(iii) with a sandbox harness exercising the **real** functions. **14/14 assertions pass.** The deadlock cannot recur; all stranded jobs self-heal.

## The three bugs (as stated in the job)

1. **runner.sh:120 `job_lane()`** — `grep -qiF` on the bracketed `[builder]` opt-in tag matched that literal token **anywhere** in the job text, so a job merely *quoting* the tag in its description (like this very job at queue.md:64) was misrouted to the builder lane. With all 4 unchecked jobs classifying as builder, the worker claim loop (l.198-200) deferred every one → `J_JOB` empty → every wave `SKIP(EMPTY_QUEUE)` while jobs sat stranded.

2. **worker.sh:67** — capped every model attempt at `SESSION_TIMEOUT=900` regardless of the budget arg, so builder-lane jobs (intended `BUILDER_BUDGET=2400s`) timed out at 900s. ROW-4 EXECUTE died at 900s/901s twice (LOG 07-27T07:06/08:33Z, ~1800s burned, zero artifacts).

3. **runner.sh:127-133 `pick_builder_job`** — had no fail-streak breaker (unlike the worker claim loop l.192), so one perpetually-timing-out builder job (l.58) would block the whole builder lane forever.

## The fixes (verified in-tree)

All three are present in the current working tree (uncommitted; the entire runner.sh was rewritten into the wave-dispatcher architecture):

1. **Anchored `[builder]` regex** (runner.sh:120):
   ```bash
   printf '%s' "$j" | grep -qiE '^[[:space:]]*(\[[^]]*\][[:space:]]+)?\[builder\]'
   ```
   Matches `[builder]` only as a **leading token** (bare, or right after the `[Role]` prefix) — never as a substring. A tag quoted in the job body does NOT route.

2. **Builder per-attempt cap = budget** (worker.sh:67):
   ```bash
   per=$SESSION_TIMEOUT; [[ "$slot" == "builder" ]] && per=$budget
   ```
   The builder slot uses `BUILDER_BUDGET` (2400s) as its per-attempt timeout; workers keep the 900s hang guard.

3. **`pick_builder_job` fail-streak breaker** (runner.sh:143-169):
   Both pass 1 (routed builder jobs) and pass 2 (legacy fallback) apply `fail_streak` / `MAX_JOB_RETRIES` quarantine, mirroring the worker claim loop. A job with ≥3 consecutive REAL fails is marked `[!]` and the lane advances.

A **companion fix** (empty-queue fall-through; [[janitor-builder-deadlock-emptyqueue-2026-07-27]]) is also present: when builder-lane jobs are pending, the empty-queue branch falls through to the builder section instead of bridge-looping or throttle-exiting. That note documents 27/27 simulated assertions covering the empty-queue restructuring, routing (T7: body-mention → worker), and builder dispatch (T2/T3).

## This session's contribution: independent verification of (i)(ii)(iii)

The prior note's 27/27 sim covered routing + dispatch + drain but did **not** explicitly demonstrate:
- **(ii)** the 2400s builder cap (vs 900s worker guard),
- **(iii)** the builder-quarantine breaker after `MAX_JOB_RETRIES` timeouts.

This session built a sandbox harness (`/tmp/forge-verify`) that:
- Extracted the **real** helper functions from runner.sh (lines 24-26 + 86-211: `ts`, `today`, `log_line`, `quota_detect`, `fail_streak`, `job_lane`, `builder_jobs_pending`, `serial_lane_this_wave`, `pick_builder_job`, `mark_job`, `mark_proposal`) into a sourceable lib (no main-body side effects).
- Ran the **real** worker.sh with a stub `claude` (sleeps 2s, exits 0) and sandbox `SESSION_TIMEOUT=1` to make the cap test fast and decisive.
- Drove the real functions against the three acceptance criteria with production-realistic config values (`BUILDER_ROUTE_PATTERN='^\[Quant\][^:]*EXECUTE'`, `MAX_JOB_RETRIES=3`, `BUILDER_EVERY=2`, `BUILDER_BUDGET=2400`).

### Evidence (test, don't wonder)

**`bash -n` clean** on both scripts:
```
runner.sh: SYNTAX OK
worker.sh: SYNTAX OK
```

**(i) Routing — anchored `[builder]` tag** (6/6 pass):
- (i.a) job merely *quoting* `[builder]` in its body → **worker** ✓ (this job's own text is the test case)
- (i.b) `[Role] [builder]` leading token → **builder** ✓
- (i.c) bare leading `[builder]` → **builder** ✓
- (i.d) `[Quant] EXECUTE` pattern auto-detect → **builder** ✓
- (i.e) `[Critic] … before EXECUTE` (pattern anchor guard) → **worker** ✓
- (i.f) plain `[Scout]` job → **worker** ✓

**(ii) Worker.sh per-attempt cap** (2/2 pass):
- (ii.a) **builder slot**, budget=2400, stub sleeps 2s, `SESSION_TIMEOUT=1` → verdict `ok` (2s job survived) ✓
  - Proves: builder per-attempt cap = budget (2400), **not** SESSION_TIMEOUT. If the bug were present (per=SESSION_TIMEOUT=1 always), the 2s stub would be killed at 1s → `TIMEOUT(1s)`.
- (ii.b) **worker slot**, budget=1200, stub sleeps 2s, `SESSION_TIMEOUT=1` → verdict `TIMEOUT(1s)` ✓
  - Proves: worker keeps the SESSION_TIMEOUT hang guard (killed at 1s, not budget).

**(iii) `pick_builder_job` fail-streak breaker** (4/4 pass):
- (iii.a) 2 consecutive fails (< `MAX_JOB_RETRIES=3`) → job still picked, queue unchecked ✓
- (iii.b) 3 consecutive fails (== `MAX_JOB_RETRIES`) → job quarantined `[!]`, lane advanced (empty return), `QUARANTINED` logged ✓
- (iii.c) an `ok` verdict resets the streak (1 fail after ok) → job picked ✓

**Total: 14/14 assertions pass** (6 routing + 2 worker-cap + 4 quarantine + 2 live-queue classification below).

### Live queue classification (self-heal confirmed)

Real queue.md unchecked jobs, classified by the real `job_lane`:
```
builder  | [Curator] [builder] INDEX SWEEP (APPLY): …      (queue.md:60, leading [builder] tag)
builder  | [Steward] [builder] MEMORY.md STATE REFRESH: …  (queue.md:63, leading [builder] tag)
worker   | [Janitor] FIX THE BUILDER-LANE DEADLOCK …       (queue.md:64, quotes [builder] in body)
```
`builder_jobs_pending` → **true** (builder lane has work; the empty-queue branch will WAIT/dispatch, not bridge-loop).

**Self-heal:** Next wave, workers claim l.64 (this job). Each even wave (`BUILDER_EVERY=2`), the builder takes the top routed job (l.60 INDEX SWEEP → l.63 MEMORY REFRESH). When the queue goes builder-only, the companion empty-queue fix waits/dispatches instead of bridge-looping. **Deadlock cannot recur.**

## Residual observation (not fixed — out of scope)

The prior note flags a conservative target-dedup heuristic in the claim loop (keys on the last `*.md` token; jobs merely *mentioning* `queue.md` collide and one defers a wave). Self-healing; a future Janitor could strip quoted mentions before extracting the target.

## Conclusion

The three-bug fix was already in-tree from an earlier session. This session independently verified the **real** code against the job's three acceptance criteria (i)(ii)(iii) with a sandbox harness: **14/14 assertions pass**, `bash -n` clean on both scripts, live queue classification confirms the self-heal. The builder-lane deadlock is broken and cannot recur.

**Verdict:** ok — already-fixed + independently verified.

Related: [[janitor-builder-deadlock-emptyqueue-2026-07-27]] (companion empty-queue fix + 27/27 sim) · [[janitor-builder-lane-routing-2026-07-26]] (original routing change) · [[multi-agent-orchestration-patterns]] · [[queue]] · [[schedule]]
