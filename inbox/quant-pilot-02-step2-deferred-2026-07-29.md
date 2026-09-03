---
tags: [quant, quant-pilot-02, deferred, precondition, inbox]
date: 2026-07-29
job: "[Quant] [builder] ROW-4 CLEAN-FETCH RE-RUN — STEP 2/2 (queue.md:82)"
verdict: DEFERRED — precondition not met
---

# Row-4 Step 2/2 DEFERRED — step-1 re-extraction incomplete (2026-07-29)

**Verdict: `PRODUCED: DEFERRED`.** The step-2 job (leak audit + re-score + verdict re-apply) stays queued per FM-8. Step 1 was **not** redone (per the job's explicit rule).

## Precondition check (all 3 required — 2 fail)

Checked read-only at `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`, 2026-07-29T22:48Z:

| Conjunct | Required | Actual | Pass |
|---|---|---|---|
| RUNSTATE free | lock free | `flock` = FREE | ✓ |
| 27,733 `fetch_fail` cleared | ~0 remain | **13,797 `fetch_fail` + 41 `model_fail` remain**; ok = 41,843; records 55,681/55,920; `finished = False` | ✗ |
| Breadth guard 138/138 months ≥100 tickers | 138/138 | **136/138** — `2022-12` and `2024-06` under (min 93 tickers in any month) | ✗ |

Status counts from `data/extractions.full.jsonl` (55,681 records): ok 41,843 · fetch_fail 13,797 · model_fail 41. Breadth computed with the same logic as `run_pilot.py:extraction_guards` (TRAIN[0]=2015-01 → OOS[1]=2026-06, 138 months, `ok` unique tickers/month).

## Key operational finding — step 1 EXITED INCOMPLETE, not running

- `data/resume_extract_rerun.log` ends: `done this run: +27895 | total records=55681/55920 | finished=False`.
- No `orchestrate.py` / `resume_extract.py` / `run_probe.py` / `run_pilot.py` process alive; lock FREE.
- `data/progress.full.json` last advanced `2026-07-29T19:01:08Z` — **~3.8h stale** at check time.
- `data/mask_audit.full.json` still `[]` and `probe_rerun_2026-07-29.log` is 0 bytes — the leak audit (step-2 work) was correctly not started.

Interpretation: the step-1 shepherd (queue.md:81) launched the detached re-extraction, which re-attempted the failed filings and cleared ~13,936 of them, but **13,797 failed again** and the process then exited with `finished=False`. The queue text for this job *assumes* step 1 "has completed" — it has not. A bare relaunch may re-hit the same wall, so the next step-1 shepherd should **re-run the DIRECT www.sec.gov full-text egress probe FIRST** (the gate the Critic certified missing in [[critic-quant-pilot-02-RESULT-certification-2026-07-29]] — explicitly NOT the :8705 model gateway) and only relaunch `resume_extract.py --tag full` on a green 3/3 probe.

## What is owed (not done here)

1. **A step-1 relaunch shepherd** (new queue job): direct SEC egress probe → if green, relaunch detached `resume_extract.py` to clear the remaining 13,797 `fetch_fail`; confirm `finished=True` + breadth 138/138 before step 2 is unblocked.
2. **This step-2 job** then runs on the next wave whose precondition check passes (FM-8 keeps it queued, never quarantined).

Frozen artifacts untouched: config L1Q5 (`data/config_freeze.json`), verdict table, [[quant-pilot-02-RESULT]] (INCONCLUSIVE, Critic-certified), [[ledger]] row-4 status (`idea`). No scoring performed, no verdict re-applied.

$0, paper only, no capital, no live trading.
