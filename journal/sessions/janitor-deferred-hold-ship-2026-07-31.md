---
tags: [harness, session-digest, janitor, breaker, failure-modes, FM-8]
date: 2026-07-31
role: Janitor
status: complete — per-job deferred re-dispatch hold (Guard 6) shipped + verified; PRE-CHANGE CHECKLIST item 14 signed off
related:
  - "[[FAILURE-MODES]]"
  - "[[The Forge Harness — Runbook]]"
  - "[[steward-24h-review-2026-07-31]]"
  - "[[multi-agent-orchestration-patterns]]"
---

# Janitor — FM-8 follow-up: Deferred Re-dispatch Hold, Ship + Verification (2026-07-31)

> **Verdict (one screen):** SHIPPED + VERIFIED, $0. A job returning `ok(DEFERRED)` is no longer re-dispatched every wave to re-check a precondition no cron wave can change. A **per-job** hold (Guard 6, mirroring the FM-3 quota / FM-7 gateway breakers but scoped to the single blocked job) latches on `ok(DEFERRED)` for `DEFERRED_HOLD_S=3600`s; while the held job is the sole candidate the wave exits on a cheap `SKIP(DEFERRED_HOLD)` (~0 tokens), and when runnable siblings are pending they still dispatch — only the held job is skipped. **27/27 sandbox assertions** (stub-claude, zero tokens) cover done-evidence (i)–(iv) plus classification, quarantine-immunity, and self-heal. Production smoke HEALTHY. PRE-CHANGE CHECKLIST item 14 signed off in [[FAILURE-MODES]]; cataloged as the FM-8 follow-up.

## The problem (evidenced)

FM-8's artifact oracle did the right thing: a precondition-gated no-op maps to `ok(DEFERRED)`, stays `[ ]`, never quarantined. But nothing throttled the **re-dispatch**. The ROW-4 step-2 builder job (`[Quant] [builder] ROW-4 CLEAN-FETCH RE-RUN — STEP 2/2`) deferred **41×** from `2026-07-29T10:00:06Z` to `2026-07-31T14:30:03Z`, each burning 33–1958s on the ~30-min builder cadence, re-checking a detached re-extraction that only advances on its own clock. That no-op burn is the likely proximate cause of the weekly-quota exhaustion that then held the engine DARK ~26h (111× `SKIP(QUOTA)`). One vicious cycle: **churn → quota exhaust → dark window → backlog.** (Counts field-anchored: `grep -ac 'ok\(DEFERRED\)' LOG.md` = 41, `grep -ac 'SKIP\(QUOTA\)'` = 111.)

## The fix (per-job, the FM-4 lesson)

The quota/gateway holds are GLOBAL — no session can run. A global hold here would strand runnable siblings, repeating the FM-4 over-broad-match bug. So this hold is **per-job**:

1. **`deferred_hold()`** (`runner.sh:202`) — on any `ok(DEFERRED)` verdict, in BOTH collect lanes (worker `runner.sh:570` + builder `runner.sh:602` — the builder lane is where ROW-4 churned), latch the exact job text + expiry epoch in `_harness/.deferred_hold`. One `DEFERRED_HOLD` line per event (mirror of `quota_detect`).
2. **Guard 6** (`runner.sh:389`) — the whole wave exits on a cheap `SKIP(DEFERRED_HOLD)` line **only when the held job is the SOLE unchecked candidate**. Placed before the gateway probe + wave counter ⇒ a fully-held wave burns ~0 tokens (not even the probe's) and, like the other holds, does not advance the cadence.
3. **`deferred_held()`** (`runner.sh:195`) — otherwise, skip just that job in EVERY dispatch path: worker claim loop (`runner.sh:442`) + both `pick_builder_job` passes (`runner.sh:323,338`, breaker parity per checklist item 5). **EXACT job-text match, never a substring** (the FM-4b anchor lesson). Runnable siblings still dispatch.
4. **`deferred_hold_read()`** (`runner.sh:183`) — corrupt/expired hold self-heals (delete + resume), like the quota/gateway holds.
5. **Classification** — `DEFERRED_HOLD` + `SKIP(DEFERRED_HOLD)` are bookkeeping in all FOUR counters: Guard-2 exclusion (`runner.sh:71`), `fail_streak` skip (`runner.sh:221` — a held job is NOT failing and must never quarantine on its own hold lines), health.sh `NONSESSION`, evaluate.sh tuple. `SESSION_TIMEOUT` deliberately NOT raised.

Config: `DEFERRED_HOLD_S=3600` (`config.env:37`). Kill switch: `DEFERRED_HOLD_S=0` makes every hold expire on the next read (reverts to pre-fix every-wave re-check — never a wedge).

## Verification (27/27, zero tokens)

Sandbox = real modified `runner.sh`/`worker.sh` copied to a `mktemp` vault with a stub `claude` that records each invocation (== a token-burning session) and defers/produces per job marker. Waves driven for real; assertions on LOG lines, queue state, hold file, and invocation count:

- **(i)** `ok(DEFERRED)` ⇒ hold latches — numeric epoch on line 1, exact job text on line 2; job stays `[ ]`; `DEFERRED_HOLD` line logged. ✅
- **(ii)** next wave, sole candidate ⇒ `SKIP(DEFERRED_HOLD)` with **ZERO stub invocations** (was 1, stayed 1) ⇒ ~0 tokens; job preserved `[ ]`. ✅
- **(iii)** force-expired hold ⇒ job re-dispatched; with the precondition now met it **completes `[x]`** (artifact landed); expired hold file cleared. ✅
- **(iv)** held job + runnable sibling ⇒ **exactly ONE session** that wave (the `[Janitor]` sibling, `[x]`, artifact landed); the held `[Quant] [builder]` job stays `[ ]` — the per-job scope guard. ✅
- **(v)** `fail_streak` over the held job's `SKIP(DEFERRED_HOLD)`+`DEFERRED_HOLD`+`ok(DEFERRED)` lines == **0** (never quarantined); control `exit1` still counts 1. ✅
- **(vi)** Guard-2 counts only the real `ok`+`exit1` sessions (3), all 9 bookkeeping lines excluded; health.sh `NONSESSION` matches; evaluate.sh tuple includes `DEFERRED_HOLD`. ✅
- **(vii)** a garbage hold file self-heals with no leak into LOG. ✅

The suite caught + fixed two real bugs pre-ship: (a) a duplicated helper/guard block from a double-insert; (b) `${var#- [ ] }` prefix-strip — a glob char-class that fails to match (exactly the bug the claim-loop comment warns about) — replaced with the fixed `:6` offset.

**Production smoke** after ship: `health.sh` HEALTHY (runs today 7, success 100%), Guard-2 live `grep -c` (no `-a`) = 57 (audit trail unpoisoned), queue intact (done=67 pending=1), no stray `.deferred_hold`. `bash -n` clean on all four touched scripts (runner/config/health/evaluate).

## Files touched

`_harness/runner.sh` (Guard 6 + 3 helpers + claim-loop/builder skips + collect latches + Guard-2/fail_streak classification) · `_harness/config.env` (`DEFERRED_HOLD_S`) · `_harness/health.sh` (NONSESSION) · `_harness/evaluate.sh` (bookkeeping tuple) · `_harness/FAILURE-MODES.md` (FM-8-follow-up entry + checklist item 14 signed off + verdict vocab).

## Follow-ups (not shipped, named)

- **Single-slot hold:** concurrent DISTINCT defers are rare; the first blocker keeps its window, a later one re-defers once when it expires. If multi-defer ever churns, extend the hold file to a small per-job list.
- **FM-6 (b) bridge-duplicate** remains the open watch item (unchanged by this work).
