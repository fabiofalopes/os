---
tags: [quant, pilot-02, precondition, deferred, diagnostic]
date: 2026-07-30
status: clean negative result — step 2 deferred, job stays queued
worker: cron [builder] ROW-4 step 2/2
---

# quant-pilot-02 — STEP 2/2 PRECONDITION CHECK → DEFERRED

> Diagnostic, NOT the step-2 deliverable. The leak-audit + re-score + verdict re-apply was **not started** because the step-1 clean-fetch precondition is unmet. Job stays queued (FM-8 keeps it, never quarantines). Step 1 was **not** redone (per instruction). See [[quant-pilot-02-RESULT]] (frozen INCONCLUSIVE, Critic-certified) and [[quant-pilot-02]].

## Verdict: DEFERRED

The "clean-fetch re-run" has **not** produced a clean fetch. Step 1 ran but only half-cleared the failure storm, so the step-2 work (probe + re-score) would re-return INCONCLUSIVE and buy nothing.

## Evidence (measured 2026-07-30 at `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`)

Precondition indicators, checked against data not logs:

| Indicator | Precondition claim | Measured | Met |
|---|---|---|---|
| RUNSTATE | free | `flock` lock **FREE** (no process running) | ✓ |
| fetch_fail cleared | 27,733 → 0 | **13,797 `fetch_fail` remain** (24.8% of 55,681 records) | ✗ |
| breadth guard | 138/138 months ≥100 tickers | **136/138** ≥100 (under: 2022-12, 2024-06); guard *passes* (1.45% < 20% threshold) | ~ partial |
| progress.finished | done | **False** — 55,681 / 55,920 records (239 short) | ✗ |

Status tally (`data/extractions.full.jsonl`, 55,681 lines): `ok=41,843 · fetch_fail=13,797 · model_fail=41`.
`extraction_guards()` → `breadth_fail=false, failure_fail=false, fetch_fail_rate=0.248`.

Step-1 run did execute: `data/resume_extract_rerun.log` → "done this run: +27895 | total records=55681/55920 | finished=False". So the re-extraction pass completed but left ~13.8k filings still `fetch_fail` — SEC full-text egress is **still impaired** (~1 in 4 filings), just no longer storm-level.

## Why defer rather than proceed

- The frozen breadth guard passing is necessary but not the point of a *clean-fetch* re-run; the sample is not clean (24.8% fetch_fail).
- Step 2's leak audit (`run_probe.py`) must re-fetch 160 OOS filings. At 24.8% egress failure it would return few pairs (the outage zeroed it to 0/160); <30 pairs → ρ untrusted → per frozen logic a missing/weak probe is infra-incompleteness → **INCONCLUSIVE again**, not the modal KILL. Expensive step-2 work (~514s score-only; audit pushes past the 900s worker cap) for no verdict gain.
- This window already burned ~3600s on the 4× TIMEOUT-then-retry pattern (job note). Not repeating it.

## What the next wave needs (do NOT redo step 1 here)

1. Another re-extraction pass (step 1, a separate job) to clear the remaining 13,797 `fetch_fail` — gated on a **direct www.sec.gov** egress probe (NOT the :8705 gateway, per Critic finding in [[quant-pilot-02-RESULT]]). Egress is the binding constraint.
2. Only when fetch_fail ≈ cleared AND breadth ≥ the claimed 138/138 (or at least guard-clean with the two residual months explained) should step 2 re-fire: probe ≥30 samples → leak audit (>10% → fix+re-probe) → `run_pilot.py` re-score → amend RESULT → stage ledger row-4 proposal.
3. Modal expectation unchanged: **KILL** on a clean sample (decimated family all-negative, mean −0.369, DSR p=0.974). The re-run buys a *clean* verdict, not a hopeful one.

$0, paper only, no capital, no live trading. Frozen config L1Q5 and verdict table untouched.
