---
tags: [inbox, janitor, oracle, harness, deadlock]
date: 2026-07-27
status: raw — Curator: link from [[janitor-builder-deadlock-3bug-verify-2026-07-27]]; INDEX entry optional
role: Janitor
verdict: ok — Oracle refreshed (both files), two spec deviations, both evidence-backed
job: "queue.md l.66 — ORACLE REFRESH — ENGINE DEADLOCK ALERT"
related:
  - "[[janitor-builder-deadlock-3bug-verify-2026-07-27]]"
  - "[[janitor-builder-deadlock-emptyqueue-2026-07-27]]"
  - "[[quant-pilot-02-execution-2026-07-27]]"
  - "[[quant-row1-date-reconciliation-2026-07-27]]"
  - "[[tool-pilot-01-publish-checklist]]"
---

# Oracle Refresh — Deadlock Alert (2026-07-27 ~15:48Z)

> Refreshed `_ORACLE-CURATED.md` (durable source — `oracle.sh` re-includes it every tick) and patched `_ORACLE.md` (immediate screen), the double-write precedent set by [[quant-row1-date-reconciliation-2026-07-27]]. The lead now opens with the engine deadlock, then row 4 RUNNING, then the two decisions the human owes the engine (row-2 GO/NO-GO + #19 void/exclude).

## Two deviations from the job spec — both evidence-backed (test, don't wonder)

1. **"Engine IS DEADLOCKED … a fix is staged" → reported past tense.** The spec was staged as a proposal ~13:00Z; reality overtook it before the 15:30Z bridge. LOG evidence: zero dispatches 09:00→13:00Z (SKIP(EMPTY_QUEUE) every wave) → empty-queue fix landed 13:38Z (27/27 sim) → 3-bug fix independently verified in-tree 14:05Z (14/14 assertions; `bash -n` clean on runner.sh + worker.sh). All 4 stranded jobs (queue.md l.58/60/61/63) self-healed and completed 13:38→15:19Z; the engine is dispatching again (this session is proof — bridged 15:30Z). The Oracle shows the verified current state: deadlocked → fixed → recovered. Root cause per source-read, not guess: `job_lane()` used `grep -qiF` on `[builder]` — a substring match; the fix anchors it as a leading token.
2. **"Row-1 verdict day 2026-08-04" → kept 2026-09-02.** This morning's reconciliation ([[quant-row1-date-reconciliation-2026-07-27]]) live-verified all 21 Polymarket IDs: **no market ends on 08-04** (first resolution **08-07**, last end 08-31); "08-04→09-01" is the *selection window*. Score/verdict day is **2026-09-02** (`VERDICT_DAY=2026-09-02` in run_verdict.sh; frozen note + Critic G2 agree). The reconciliation note predicted this spec would repeat the conflation (its flag #1, first raised 07-23). Writing 08-04 on the human's screen is the exact harm that job existed to prevent.

## Live evidence attached (15:48Z)

- Row-4 run alive: `progress.full.json` = 6,000/25,051 train records, 6,000 ok (100%), 2,992/hr, updated 15:47:22Z; `orchestrate.py` (PID 866150) running under the flock guard. Stage-0 gate PASS; verdict ~07-28.
- Queue: only this ORACLE REFRESH job unchecked; all 4 formerly-stranded jobs `[x]`.

## Decisions restated as owed (on the human's screen now)

1. Row-2 publish **GO / NO-GO** — 5 min, foot of [[tool-pilot-01-publish-checklist]] — the fastest path to money.
2. **Void/exclude call on market #19** (pulled from Polymarket) before 09-02 — silence defaults to a 20-market verdict.
