---
tags: [quant, pilot-02, deferred, precondition, cron-worker]
date: 2026-07-29
type: clean-negative-result
job: "[Quant] ROW-4 CLEAN-FETCH RE-RUN — STEP 2/2 (leak audit + re-score + verdict re-apply)"
verdict: DEFERRED
---

# quant-pilot-02 — Step 2/2 DEFERRED (precondition not met)

> Worker reached step 2/2 (leak audit + re-score + verdict re-apply) on 2026-07-29 ~22:16 UTC.
> The step-1 re-extraction precondition was **not met**, so per the frozen job rule this job
> prints `PRODUCED: DEFERRED` and exits. FM-8 keeps it queued (never quarantined). Step 1 was
> **not** redone (out of this job's scope). No re-score was run on an incomplete sample.

## Precondition (verbatim from job)
"the step-1 re-extraction has completed (RUNSTATE free + `data/progress.full.json` shows the
27,733 fetch_fail cleared + breadth guard now passes 138/138 months ≥100 tickers)."

## Evidence measured this session
At `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`:

| Check | Required | Actual | Pass? |
|---|---|---|---|
| Lock / RUNSTATE | FREE | `flock -n data/orchestrate.lock` → **FREE** | ✅ |
| fetch_fail cleared | 0 (from 27,733) | **13,797 remain** (`progress.full.json`: records 55,681/55,920, n_ok 41,843, `finished: false`) | ❌ |
| Breadth 138/138 ≥100 tickers | 138/138 | **136/138** — `2022-12`, `2024-06` still <100 (`extraction_guards`) | ❌ |

`extraction_guards(data/extractions.full.jsonl)` full output:
```json
{"n_records": 55681, "status_counts": {"ok": 41843, "parse_fail": 0, "model_fail": 41, "fetch_fail": 13797},
 "n_months_total": 138, "n_months_under_100_extracted": 2,
 "months_under_100_extracted": ["2022-12", "2024-06"],
 "failure_rate_malformed": 0.00098, "fetch_fail_rate": 0.2478,
 "breadth_fail": false, "failure_fail": false}
```
`resume_extract_rerun.log` tail: `done this run: +27895 | total records=55681/55920 | finished=False`.

## Reading
The step-1 re-extraction ran and helped materially — it cleared ~13,936 of the 27,733
fetch_fail and drove the *frozen* guards green (`breadth_fail: false`, `failure_fail: false`;
malformed rate 0.098%). But it stopped with `finished=False`: 239 filings never re-attempted
(55,920 − 55,681) and 13,797 fetch_fail still outstanding, leaving 2 of 138 months under the
100-ticker breadth floor. The job's precondition is stricter than "guards pass" — it names
*fetch_fail cleared* and *138/138* — and this is a frozen pre-registration, so the worker does
not substitute a looser standard on its own authority.

## What the next wave needs (do NOT redo step 1 here)
1. **Finish step 1:** resume the clean-fetch re-extraction until `finished=True` and
   fetch_fail → 0 (or to a documented, frozen acceptable floor), so `2022-12` and `2024-06`
   cross 100 extracted tickers → 138/138.
2. **Then re-dispatch this step 2/2 job** unchanged: leak audit (≥30-sample `run_probe.py` on
   the clean sample; `mask_audit.full.json` is still `[]` — audit debt), re-score via
   `run_pilot.py` re-applying the frozen verdict table EXACTLY ([[quant-pilot-02]]), amend
   [[quant-pilot-02-RESULT]] in place, and stage the Z2 [[ledger]] row-4 proposal.
3. Modal expectation unchanged: **KILL** on a clean sample (decimated family all-negative,
   mean −0.369, DSR p = 0.974). The re-run buys a CLEAN verdict, not a hopeful one.

$0, paper only, no capital, no live trading. No substrate files edited (read-only for workers).
