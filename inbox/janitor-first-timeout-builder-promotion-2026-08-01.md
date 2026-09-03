---
tags: [janitor, builder, harness, ship, incident-9, inbox]
date: 2026-08-01
role: Janitor
status: durable — SHIP + VERIFY evidence for the FM-9 first-timeout builder-promotion breaker
---

# FM-9 FIRST-TIMEOUT BUILDER PROMOTION — SHIPPED + VERIFIED

> **Verdict (one screen):** the 2×900s double-burn is over. A job whose FIRST worker-lane attempt ends in a bare `TIMEOUT(900s)` now gets its retry on the builder lane (`BUILDER_BUDGET` cap) — decided **mechanically from LOG verdict history, never from job text** (the FM-4b lesson). Builder-lane timeouts still count toward `MAX_JOB_RETRIES` quarantine — promotion buys headroom, not immunity. `SESSION_TIMEOUT` untouched (FM-2 hang guard). **23/23 sandbox assertions green** (stub-claude, zero tokens), `bash -n` clean, production smoke healthy. Cataloged as [[FAILURE-MODES]] FM-9 + checklist item 15 signed off. $0, no capital. The job ran its own failure mode end-to-end: attempt 1 timed out on the worker lane (the disease) after shipping the code unrecorded; attempt 2 was the FIRST production promotion (the fix, firing on its own ship job); attempt 3 (this note) verified + cataloged.

## The disease (3rd recurrence of the FM-5 pattern)

FM-5 laned jobs KNOWN to be big (`[builder]` tag / `BUILDER_ROUTE_PATTERN`) but left no path for a job whose first attempt just PROVED it too big — `fail_streak` kept it queued (right) while nothing changed its LANE (the gap), so the retry re-burned 900s on workers. Evidence chain: ROW-3 EXECUTE 2×900s 07-26 → 741s builder ok; ROW-4 EXECUTE 2×900s 07-27 (FM-5); the FM-8-follow-up hold job `TIMEOUT(900s)` at LOG 1042/1043 (`07-31T14:00:04Z`+`14:30:03Z`) → builder `ok` 1595s at LOG 1044 (`14:56:38Z`). Each double-burn feeds the quota exhaust → dark cycle (FM-3 / FM-8 follow-up).

## What shipped (in-tree from the job's own timed-out first attempt; verified by this session)

1. **`worker_timeout_promote()`** (`runner.sh:229`) — awk over LOG history: true iff the job's WORKER-lane history since its most recent `ok` ends in a BARE `TIMEOUT`. Identity = EXACT job text in field 5 (same identity `fail_streak` uses): worker lines carry raw text, builder lines carry `[builder] ` — so builder-lane timeouts never trigger (already on the right lane; still counted → still quarantine). `TIMEOUT(BUT_ARTIFACT)` never triggers (work landed, no retry exists). An `ok` on EITHER lane clears the flag → re-queued jobs start fresh on workers.
2. **Claim-loop skip** (`runner.sh:479`) — promoted jobs are not claimed by workers; gated on `BUILDER_EVERY>0` so a disabled builder lane can never strand the job.
3. **`pick_builder_job` pass 1** (`runner.sh:351`) — picks promoted jobs alongside routed ones with full breaker parity (`fail_streak` quarantine + `deferred_held` skip).
4. **`builder_jobs_pending`** (`runner.sh:327`) — promoted jobs count as builder-pending → a sole promoted candidate takes `SKIP(BUILDER_WAIT)`/fall-through, never bridge-merged or reflection-stranded (FM-4a shape).
5. **Kill switch** `TIMEOUT_PROMOTE=1` (`config.env:46`) — flip to 0 → pre-fix behavior, never a wedge. No new LOG token (promotion is LOG-silent; the promoted run logs as the ordinary `[builder]`-prefixed line) → no four-counter classification needed.

## Done-evidence — the three required gates + guards

Sandbox = fresh `mktemp -d` vault per scenario + stub `claude` (scripted behaviors), driving REAL `runner.sh` waves; zero tokens. **23/23 PASS**:

- **(i)** first worker `TIMEOUT(2s)` ⇒ retry dispatches on the builder lane, lands `ok` + `[x]`; exactly ONE timeout line total — the double-burn is gone (2 sessions, not 3) ✓
- **(ii)** `[builder]`-tagged job timing out on the builder lane ⇒ 3× `TIMEOUT(4s)` (per-attempt cap = `BUILDER_BUDGET`, not 900/2) ⇒ `QUARANTINED [!]`, zero sessions on the quarantine wave ✓
- **(ii-b)** promoted untagged job: 1 worker + 2 builder TIMEOUTs ⇒ streak 3 ACROSS lanes ⇒ `QUARANTINED [!]`; post-quarantine wave spawns nothing for the job ✓
- **(iii)** plain `ok` ⇒ worker lane `[x]`; `ok(DEFERRED)` ⇒ stays `[ ]` + hold latched; next wave sole candidate ⇒ `SKIP(DEFERRED_HOLD)`, zero sessions ✓
- **clear-on-ok:** after builder `ok`, re-queued same-text job returns to the WORKER lane ✓
- **kill switch:** `TIMEOUT_PROMOTE=0` ⇒ retry stays on the worker lane (pre-fix) ✓
- **FM-4b mechanical guard:** a job whose body QUOTES `"TIMEOUT(900s)"` and `[builder]` with no LOG history ⇒ worker lane, `ok [x]` — keywords route nothing ✓
- **FM-4a shape:** promoted sole candidate on a non-builder wave ⇒ `SKIP(BUILDER_WAIT)`, job preserved, no bridge merge ✓

`bash -n` clean: runner.sh, worker.sh, config.env. Production smoke: health.sh success rate **100%** (1/1 real; the 2 fails are this job's own 01:00Z TIMEOUT + 01:15Z connection-closed — infra-classified, excluded), Guard-2 live `grep -c` (no `-a`) = 5 (trail unpoisoned), queue intact (done=70 pending=1 quarantined=0).

**Production proof of the path** (better than any sandbox): LOG 1085 → 1086 — this ship job's own first attempt died `TIMEOUT(900s)` on the worker lane at `01:00:05Z`; its retry dispatched at `01:15:50Z` ran **`[builder]`-prefixed** = the first production promotion, firing on the job that shipped it. (The timed-out attempt had written runner.sh/config.env at 00:52Z but died before its artifact — the TIMEOUT-did-work-unrecorded family; `.sh` edits are invisible to the `.md`-only `timeout_artifact` scanner, so no phantom credit — the job was correctly re-dispatched and the code verified before catalog.)

## Suite self-audit (test, don't wonder — including about the tests)

The suite went 21/23 → 22/23 → 23/23; both reds were harness bugs, not engine bugs, and each was traced to ground truth before touching an assertion: (1) the quarantine wave's "extra" session was the empty-queue REFLECTION (sandbox never set `last-reflect`, so the 6h throttle was inactive) — fixed by seeding the throttle, keeping the assertion's intent; (2) with `BUILDER_EVERY=1` the builder section runs EVERY wave, so pass 1 promoted the job in the SAME wave as its first worker TIMEOUT (it sees the freshly-logged line) — quarantine landed a wave earlier than scripted. Engine correct both times; assertions aligned to the real wave arithmetic.

## Regression watch

≥2 bare worker-lane `TIMEOUT` lines for one job (no `[builder]` line between) = recurrence — structurally impossible with `TIMEOUT_PROMOTE=1`. Misbehaving promotion → `TIMEOUT_PROMOTE=0` reverts to pre-fix, never a wedge.

Related: [[FAILURE-MODES]] (FM-9 + item 15) · FM-5 (the pattern) · FM-4 (the routing cautionary tale) · FM-6/FM-8 (the unrecorded-work family) · [[The Forge Harness — Runbook]]
