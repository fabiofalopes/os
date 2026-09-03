---
tags: [quant, pilot-02, escalation, stall, fm-8, z2]
created: 2026-07-31
type: escalation
status: needs-human-decision
---

# Quant-pilot-02 Step 2/2 — Stall Escalation (10th byte-identical DEFERRED)

**VERDICT: the row-4 clean-fetch re-run step 2 (leak audit + re-score + verdict re-apply) cannot run and is NOT self-healing. The FM-8 keep-queued loop has now deferred 10 times against frozen state. Needs a human/Steward decision — do NOT blindly re-queue.**

## Why this note instead of a 10th DEFERRED

Wave 9 (2026-07-31 ~09:16Z) logged a META warning in the pilot `RUNSTATE.md`: step-1 re-extraction is stalled, no detached run is active, no `data/` mtime has advanced since 2026-07-29, and the loop is burning tokens re-checking a state no cron wave can change. Fresh check this wave (below) confirms all of it still holds. A further `PRODUCED: DEFERRED` would be the 10th identical tick of pure cost — so this note forces the decision the META warning asked for, and the job leaves the blind queue. Six per-wave deferral notes already sit in inbox/ (2026-07-29 → 2026-07-30); none changed anything.

The certified row-4 verdict stands untouched meanwhile: **INCONCLUSIVE** ([[quant-pilot-02-RESULT]], Critic-certified 2026-07-29). $0, paper only — no capital at risk from the stall.

## Fresh precondition check (2026-07-31, this wave)

All via frozen `run_pilot.extraction_guards('data/extractions.full.jsonl')` at `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`:

| Conjunct | Required | Measured | Pass |
|---|---|---|---|
| RUNSTATE lock | FREE | FREE | ✓ |
| fetch_fail cleared | ≈0 | **13,797 (24.8%)** | ✗ |
| extraction finished | `finished=True` | `False` — 55,681/55,920 (239 short), `updated_utc=2026-07-29T19:01` | ✗ |
| breadth | 138/138 months ≥100 | **136/138** (2022-12, 2024-06 under) | ✗ |
| probe ρ | measured, ≥30 pairs | **ρ=None** — `probe.full.json` absent, `mask_audit.full.json`=`[]` (2 bytes), `probe_rerun_2026-07-29.log` 0 bytes | ✗ |

Status distribution: ok 41,843 / fetch_fail 13,797 / model_fail 41. All `data/` mtimes ≤ 2026-07-29 22:49 → **step 1 has NOT been re-run**. `results.json` on disk: still the 2026-07-28 INCONCLUSIVE (n_extractions_used=27,927) — untouched, as required.

Note: the frozen guards themselves would not fire INCONCLUSIVE (`breadth_fail=False` 1.45%<20%, `failure_fail=False` 0.098%) — but the job's literal precondition (27,733 storm fails cleared, 138/138, measured ρ) is unmet, and ρ=None alone guarantees any re-score now reproduces INCONCLUSIVE rather than the clean verdict the re-run exists to buy.

## Decision required (human/Steward)

Root cause unchanged since 2026-07-30: SEC full-text egress still partially impaired (the 24.8% residual fetch_fail is direct evidence). Two options:

1. **Re-launch step 1 with DIRECT www.sec.gov egress** (NOT the :8705 gateway — Critic finding, per [[quant-pilot-02-RESULT]]), then re-queue this step-2 job. Step-2 trigger: fetch_fail≈0 AND `finished=True` AND a ≥30-sample probe returns measured ρ.
2. **Pull the job and accept INCONCLUSIVE as final.** Modal expectation was always KILL on a clean sample (decimated family all-negative, mean −0.369, DSR p=0.974); the re-run buys a CLEAN verdict, not a hopeful one. If egress can't be fixed cheaply, the Critic-certified INCONCLUSIVE is an honest resting state — row 4 stays gated, one redesign allowance remains per the frozen note.

Do NOT re-queue step 2 until option 1's trigger is actually met — re-queuing against frozen state is what produced the 10-wave loop. Frozen config L1Q5 is never re-selected either way ([[quant-pilot-02]]).

## Links

- Pilot design (FROZEN): [[quant-pilot-02]]
- Certified result + re-run spec: [[quant-pilot-02-RESULT]] · certification: inbox/critic-quant-pilot-02-RESULT-certification-2026-07-29.md
- Failure mode: [[FAILURE-MODES]] FM-8 (keep-queued loop — this escalation is its exit valve)
- Operational state (waves 1–9 logged): `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/RUNSTATE.md`
