---
title: quant-pilot-02 clean-fetch re-run STEP 2/2 — DEFERRED (precondition not met)
date: 2026-07-30
tags: [quant, quant-pilot-02, rerun, deferred, gate-check]
type: negative-result
status: deferred
job: "[Quant] [builder] ROW-4 CLEAN-FETCH RE-RUN — STEP 2/2 (leak audit + re-score + verdict re-apply)"
verdict: DEFERRED
---

# quant-pilot-02 re-run STEP 2/2 — DEFERRED

**Verdict: DEFERRED.** Step-2 (leak audit + re-score + verdict re-apply) was **not run**.
The step-1 re-extraction precondition is **not met** (2 of 3 conjuncts fail). FM-8 keeps
this job queued; step 1 was **not** redone (forbidden by the job), and no audit/score
compute was launched (avoids repeating the ~3600s TIMEOUT-then-retry burn on still-dirty data).

## Precondition check (tested, not wondered)

Source: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`

| Conjunct | Required | Observed | Pass? |
|---|---|---|---|
| RUNSTATE free | lock free | `flock -n data/orchestrate.lock` → **FREE** | ✅ |
| fetch_fail cleared | 27,733 → 0 | **13,797 fetch_fail remain** (only 13,936 cleared) | ❌ |
| Breadth guard | 138/138 months ≥100 tickers | **136/138** (2022-12=93, 2024-06=97) | ❌ |

### Evidence

- `data/extractions.full.jsonl` status counts (now): `ok=41,843 · fetch_fail=13,797 · model_fail=41` (n=55,681).
- Original baseline (`results.json`, 2026-07-28): `ok=27,927 · fetch_fail=27,733` (49.8% fetch-storm → INCONCLUSIVE, breadth 78/138 under).
- Step-1 re-run log `data/resume_extract_rerun.log` (ended 2026-07-29 20:01): `done this run: +27895 | total records=55681/55920 | finished=False` — **re-run stopped early, not finished**; 239 target records never processed.
- `data/progress.full.json`: `records=55681/55920, n_ok=41843, finished=false, updated 2026-07-29T19:01`.
- Breadth recomputed with the exact `run_pilot.py:extraction_guards` logic (TRAIN 2015-01 → OOS 2026-06, 138 months): 136/138 pass, `breadth_fail` flag now **False** (frac_under=0.0145, well under the 20% trip) — a real improvement from 56.5%, but **not** the required 138/138.
- `data/mask_audit.full.json` = `[]` (audit debt still open — untouched this session, correctly).
- `data/probe_rerun_2026-07-29.log` = 0 bytes — consistent with the job's note that the probe re-fetched 0/160 pairs in the **same ongoing SEC egress outage**.

## Why defer (not proceed)

1. Step 1 is objectively incomplete: its own log says `finished=False`, 13,797 fetch_fail persist, 239 records unprocessed.
2. The SEC egress outage is still active (probe 0/160). Running `run_probe.py` now would re-fetch ~0 pairs again, and `run_pilot.py` would re-score a still-decimated sample — buying neither a clean nor a trusted verdict (ρ untrusted while leak audit is empty).
3. The job is explicit: precondition not met → DEFERRED, do **not** redo step 1, do **not** repeat the timeout-retry burn.

## What unblocks this job (belongs to a STEP-1 re-extraction job, not this one)

- Re-run/finish the clean re-extraction (DIRECT sec.gov egress) until the remaining 13,797 fetch_fail clear (or are proven permanently unfetchable) **and** breadth reaches 138/138 ≥100 (close 2022-12=93, 2024-06=97), with `progress.full.json` → `finished=true`.
- Then this STEP-2 job can run: ≥30-sample leak probe on the clean sample → re-score via `run_pilot.py` re-applying the frozen verdict table ([[quant-pilot-02]]) → amend [[quant-pilot-02-RESULT]] → stage the Z2 [[ledger]] row-4 proposal.
- Modal expectation unchanged: **KILL** on a clean sample (decimated family all-negative, mean −0.369, DSR p=0.974). The re-run buys a *clean* verdict, not a hopeful one. $0, paper only.

## Links
[[quant-pilot-02]] · [[quant-pilot-02-RESULT]] · [[critic-quant-pilot-02-RESULT-certification-2026-07-29]] · [[FAILURE-MODES]] (FM-8) · [[ledger]]
