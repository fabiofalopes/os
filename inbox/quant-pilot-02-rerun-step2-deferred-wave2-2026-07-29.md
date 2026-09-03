---
tags: [quant, pilot-02, rerun, deferred, diagnostic, ledger-row-4]
date: 2026-07-29
role: builder
status: DEFERRED — precondition still not met, job stays queued (FM-8); consistent with [[quant-pilot-02-rerun-step2-deferred-2026-07-29]]
---

# quant-pilot-02 — ROW-4 clean-fetch re-run STEP 2/2 DEFERRED, wave 2 (2026-07-29)

> Clean negative result, second wave. Step 2/2 (leak audit + re-score + verdict re-apply) **not run** — precondition not met. Step 1 **not** redone (job rule). FM-8 keeps the job queued, never quarantined. This wave's contribution: verified the blocker is a residual data tail, **not** current connectivity.

## Precondition check (measured this session via `run_pilot.py:extraction_guards` on `data/extractions.full.jsonl`)

Job requires, conjunctively: RUNSTATE free **+** 27,733 `fetch_fail` cleared **+** breadth **138/138** months ≥100 extracted tickers.

| requirement | state | pass? |
|---|---|---|
| RUNSTATE free | `flock` free | ✅ |
| 27,733 fetch_fail cleared | **13,797 remain** (24.78% of 55,681) | ❌ |
| breadth 138/138 months ≥100 | **136/138** — `2022-12` (93), `2024-06` (97) | ❌ |
| (corroborating) `progress.full.json` | `finished=False`, records 55,681/55,920, n_ok 41,843 | ❌ |

`status_counts`: ok 41,843 · parse_fail 0 · model_fail 41 · fetch_fail 13,797 — identical to the wave-1 deferral. No data-state change since [[quant-pilot-02-rerun-step2-deferred-2026-07-29]].

## New this wave — connectivity verified healthy (the blocker is data, not egress)

Tested live this session (locked model via `localhost:8705`, direct `www.sec.gov`):
- **Model proxy:** 1 call, **1.88 s**, no error, correct response → gateway healthy.
- **SEC full-text egress:** 1 real OOS filing, **0.19 s**, HTML body returned → egress healthy (this was the surface that died in the original outage).

So the step-1 completion wave should succeed on egress; the only thing standing between the vault and a clean re-score is re-fetching the residual 13,797 + lifting the two thin months. I launched the leak probe to confirm the pipeline is runnable, then **stopped it for defer discipline** — the probe is step-2 task 1 and the audit is deliberately owed to the re-score wave on a *truly* clean sample. No partial artifacts: `mask_audit.full.json` still `[]`, no `probe.full.json` written.

## Why DEFER, not re-score (the frozen guards pass — that is necessary, not sufficient)

`extraction_guards` on the current sample: `breadth_fail=False` (1.45% of months <100, under the frozen 20% clause), `failure_fail=False` (malformed 0.098%). A frozen-table verdict *could* be computed. But the queue precondition is **deliberately stricter** ("cleared + 138/138") to buy a **clean** verdict, not a half-clean one on a 75%-success sample — and wave 1 explicitly warned: *"Do not relax the precondition to force a re-score early."* I have no new data-state evidence that satisfies the precondition (healthy egress ≠ cleared fetch_fail), the vault already holds a Critic-certified INCONCLUSIVE ([[quant-pilot-02-RESULT]]), so there is no urgency that justifies overriding an explicit, just-reaffirmed design decision. Deferring is the correct, expected branch — not a failure.

## Handoff — step-1 completion wave (then this job fires)

- Re-fetch the **13,797 `fetch_fail`** (`status == fetch_fail` in `data/extractions.full.jsonl`; `resume_extract.py` resumes per-filing). Egress verified healthy this wave.
- Target the two thin months: `2022-12` needs **+7** (123 outstanding in-month), `2024-06` needs **+3** (86 outstanding) → both cross 100 with a small recovery.
- Config freeze **L1Q5** stands (predates all OOS extraction; never re-selected — frozen A9b carve-out).
- On completion (cleared + 138/138): this job's precondition is met → probe (≥30-sample leak audit) → ρ → re-score → verdict re-apply exactly. Modal expectation unchanged: **KILL** on a clean sample (decimated family all-negative, mean −0.369, DSR p = 0.974).

## Decision

`PRODUCED: DEFERRED` — no audit, no re-score, no verdict re-apply, no ledger touch. Frozen artifacts ([[quant-pilot-02]], [[quant-pilot-02-RESULT]], config L1Q5) untouched. $0, paper only, no capital.

Related: [[quant-pilot-02]] · [[quant-pilot-02-RESULT]] · [[quant-pilot-02-rerun-step2-deferred-2026-07-29]] · [[critic-quant-pilot-02-RESULT-certification-2026-07-29]] · [[ledger]] · [[FAILURE-MODES]] (FM-8)
