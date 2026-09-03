---
tags: [quant, pilot-02, rerun, deferred, diagnostic]
date: 2026-07-29
role: builder
status: DEFERRED — precondition not met, job stays queued (FM-8)
---

# quant-pilot-02 — ROW-4 clean-fetch re-run STEP 2/2 DEFERRED (2026-07-29)

> Clean negative result. Step 2/2 (leak audit + re-score + verdict re-apply) was **not run** because its precondition was not met. Step 1 was **not** redone (per the job rule). FM-8 keeps the job queued, never quarantined.

## Precondition check (measured, not guessed)

Job requires, conjunctively: RUNSTATE free **+** the 27,733 `fetch_fail` cleared **+** breadth guard passing **138/138** window months ≥100 extracted tickers.

| requirement | state | pass? |
|---|---|---|
| RUNSTATE free | `flock` free; no extract/orchestrate process alive | ✅ |
| 27,733 fetch_fail cleared | **13,797 remain** (24.78% of 55,681 records) | ❌ |
| breadth 138/138 months ≥100 | **136/138** — 2 months under 100 | ❌ |
| (corroborating) `progress.full.json` | `finished=False`, records 55,681/55,920, n_ok 41,843 | ❌ |

Step-1 re-extraction **ran and exited** (`resume_extract_rerun.log`: "done this run: +27895 … finished=False") but did **not** finish the job: it recovered ~13,936 of the 27,733 failed filings (~50%) and left the run incomplete.

## What remains for step 1 (targeting for the next wave)

- **13,797 `fetch_fail` still outstanding**, spread broadly (top months ~250–280 each: 2020-04=279, 2026-02=250, 2020-05=249, 2021-02=247, 2022-02=246, 2025-02=240). Not a single-month problem — a residual egress/availability tail.
- **Two breadth-short months**, both close:
  - `2022-12`: 93 ok tickers → needs **+7** (123 fetch_fail outstanding in-month)
  - `2024-06`: 97 ok tickers → needs **+3** (86 fetch_fail outstanding in-month)
- `status_counts`: ok 41,843 · parse_fail 0 · model_fail 41 · fetch_fail 13,797. Malformed failure rate 0.001 (well under the frozen 20% clause).

## Note for the re-score wave (when step 1 truly completes)

The **frozen** INCONCLUSIVE guards already pass on the current partial sample — `extraction_guards` gives `breadth_fail=False` (1.45% of months < 100, under the 20% clause) and `failure_fail=False`. So the *only* thing between the vault and a clean re-score is finishing step-1; no guard logic needs touching. This job's precondition is deliberately stricter than the frozen guard ("cleared + 138/138") to buy a **clean** verdict, not a half-clean one — consistent with the modal expectation (KILL on a clean sample; decimated family all-negative, mean −0.369, DSR p = 0.974). Do not relax the precondition to force a re-score early.

## Decision

`PRODUCED: DEFERRED` — no audit, no re-score, no verdict re-apply, no ledger touch. Frozen artifacts ([[quant-pilot-02]], [[quant-pilot-02-RESULT]], config L1Q5) untouched. $0, paper only.

Related: [[quant-pilot-02]] · [[quant-pilot-02-RESULT]] · [[critic-quant-pilot-02-RESULT-certification-2026-07-29]] · [[ledger]] · [[FAILURE-MODES]] (FM-8)
