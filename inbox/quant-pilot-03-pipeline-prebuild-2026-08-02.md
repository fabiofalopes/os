---
tags: [quant, builder, pipeline, prebuild, ledger-row-5, reversal, inbox]
date: 2026-08-02
status: PRE-BUILD COMPLETE — row-5 pipeline built + unit-verified, idle at $0 awaiting human sign-off of [[quant-pilot-03]]; on GO the scored verdict is ONE builder wave (not the multi-wave arc rows 3–4 took). Frozen pilot-01/02 code + harness untouched; no scored verdict run; no ledger row (Z2); zero new fetch.
related:
  - "[[quant-pilot-03]]"
  - "[[critic-quant-pilot-03-prereg-2026-08-01]]"
  - "[[quant-pilot-01-RESULT]]"
  - "[[quant-pilot-02-RESULT]]"
  - "[[ledger]]"
---

# [builder] Row-5 Pipeline PRE-BUILD — quant-pilot-03 executor built + verified, awaiting sign-off

> **One line:** the NEW pipeline [[quant-pilot-03]] specifies now exists at `~/Projects/trading-agents/quant-research/pilots/quant_pilot_03/` (4 files), implements the frozen pre-registration **verbatim**, architects away pilot-02's ρ-ordering softening bug, and is verified by **12/12** harness known-answer checks + **33/33** new unit checks + a dry-run that **stops short of scoring** on the frozen panel. $0, design-only, no capital, no live trading. If the human NO-GOs, it sits idle at $0; if GO, `run_pilot.py execute` is the post-sign-off EXECUTE.

## What was built (NEW code — `pilots/quant_pilot_03/`)

| file | role |
|---|---|
| `common.py` | every frozen degree of freedom in one place (grid H∈{1,2,3}×Q∈{D,Q5}=6, splits, 10 bps/side, trials=6, rung-0 bar +1.377, verdict thresholds, and the **literal `ENSEMBLE_WEIGHT = 1/6`** per Critic F4). No fetch/model/probe constants — this pilot is close-only. |
| `sig.py` | the frozen factor: `f(i,m)=−(P[m−1]/P[m−2]−1)`, smoothed `F_H(i,m)=(1/H)Σ_{j=1..H}f(i,m−j)`; long top-quantile (long recent losers), table-order tie-break, eligible-denominator quantile size (pilot-01 convention). |
| `run_pilot.py` | executor: fail-closed `load_inputs()` → 6 configs through the validated engine → equal-weight ensemble → guards → verdict table. Modes `dry-run` (plumbing, stops short of scoring) and `execute` (scored verdict — **post-sign-off only**). |
| `test_pilot03.py` | 26 synthetic known-answer checks (never the frozen panel, never a scored verdict). |

`backtests/harness.py` is **imported, not modified** (extend, don't rewrite, per the note). `pilots/quant_pilot_01/` and `quant_pilot_02/` are **untouched** (freeze verified below).

## The ρ-ordering bug, architectured away (lesson (ii))

Pilot-02's `run_pilot.py` tests the CLI-passed `rho is None` inside the INCONCLUSIVE guard (lines 281–283) **before** loading `probe.{tag}.json` (313–315) — the second Critic proved this can only ever soften a KILL into an INCONCLUSIVE by omission (one-way). Pilot-03 removes the whole failure class by construction, not by patching:

- **All statistics computed in-process** from the byte-frozen panel — there is **no second artifact** (no probe equivalent) that could go missing or be hand-supplied. The masking probe is **N/A by construction** for a deterministic function of the price panel.
- **No CLI flags for measured statistics** — the CLI selects `mode`/`--tag` only (unit-verified by inspecting the argparse block).
- **Guards → KILL → NO EVIDENCE → PROMOTE evaluated in frozen order AFTER all inputs load.**
- **Unexpected missing input → hard error** (`FrozenInputError`, fail-closed), never a silent soft verdict; a pre-registered integrity failure → INCONCLUSIVE.
- `apply_verdict` takes **no `rho` parameter** (unit-verified by signature inspection) — nothing can be None at verdict time.

**Unit-verified on a synthetic probe** (the job's requirement): a reference model of pilot-02's ordering reproduces the bug (bad stats + valid on-disk ρ + CLI ρ=None → soft `INCONCLUSIVE`), while pilot-03's ordering (artifact read before the guard) preserves the true `KILL`, and a missing artifact raises (fail-closed) rather than softening. All three checks green.

## Evidence (test, don't wonder)

- **Harness known-answer:** `backtests/test_harness.py` → **12/12 PASS** (unchanged; confirms the engine the pipeline rides on).
- **New unit suite:** `test_pilot03.py` → **33/33 PASS**, incl.: reversal factor + H-smoothing known-answer; **Critic-F3 buffer** (H=3 first goes live exactly at bar m−5 — my impl reproduces "cohorts 2014-12/11/10, earliest bar 2014-08"); top-quantile + equal-weight + table-order tie-break; ensemble == literal 1/6 over exactly 6 configs (asserts on ≠6); all 13 verdict-table branch/boundary cases; the ρ-ordering fix (above); fail-closed `load_inputs` (missing artifact → hard error; digest mismatch → INCONCLUSIVE) on synthetic artifacts; end-to-end plumbing smoke on a synthetic panel; and a **full execute-assembly test** (`compute_verdict` on a synthetic 150-month panel: PBO 12,870 combos / 128-month trim, N=42, trials=6, family table, and the recorded verdict re-derives from its own stats) — this de-risks the EXECUTE wave so it is a guaranteed one-wave run.
- **Dry-run on the frozen panel (stops short of scoring):** guard PASSES — universe `sha256/16 = c1f80ec6f12e83f8` ✓ (symbol-join preimage, **not** the file-bytes trap `844c8968127f6d2a`), panel shape `(150,504)` ✓, contiguous monthly ✓, end `2026-06` ✓, min names/month 460, frac<100 = 0.000, N_oos = 42 ✓. All 6 configs build + run through the engine; ensemble series built at weight 0.166667×6. **No SR_X/DSR/PBO computed, no verdict applied, no `results.json` written** (confirmed absent).
- **Freeze check:** mtimes of `backtests/harness.py`, `test_harness.py`, `pilots/quant_pilot_01/run_pilot.py`, `pilots/quant_pilot_02/{run_pilot,sig}.py`, and `data/pilot01/*` all predate this session (2026-07-23→27); only the 4 new `quant_pilot_03/` files are from today. (The `~/Projects` tree is not a git repo, so freeze is shown by mtime, not `git status`.)
- **Zero new fetch:** the pipeline reads only the frozen `data/pilot01/` artifacts byte-for-byte.

## One interpretive decision (flagged for EXECUTE/Critic — resolved toward the frozen formula)

The note's signal prose says "from bars through month **m−1** … no skip month," while the frozen *formula* `F_H=(1/H)Σ_{j=1..H}f(i,m−j)` makes the smoothed signal's most-recent bar **m−2** (the j=1 term `f(i,m−1)` uses P[m−2],P[m−3]). I implemented the **formula verbatim** because it is explicit and **Critic-verified by amendment F3** (the buffer calculation "cohorts 2014-12/11/10, earliest bar 2014-08" only holds under `Σ_{j=1..H}`, and my buffer unit-test reproduces it exactly). Reconciliation: the *raw* factor `f(i,m)` does use the most-recent bar m−1 with no skip month (the disclosed difference from momentum's m−2 skip); the H-smoothing then averages the H most-recent lagged factors. The formula governs; F3 confirms it. No verdict turns on this pre-build (nothing was scored).

## Hard rules — all respected

- ❌ did **NOT** run the scored verdict on the frozen panel (dry-run only; no verdict table applied, no result recorded — that is the post-sign-off EXECUTE).
- ❌ did **NOT** touch frozen pilot-01/02 code or results (freeze verified).
- ❌ did **NOT** add the [[ledger]] row (Z2 — added on human sign-off).
- ❌ no new fetch; ✅ $0, design-only, no capital, no live trading.

## What GO buys (the EXECUTE wave)

On human sign-off of [[quant-pilot-03]]: `python3 pilots/quant_pilot_03/run_pilot.py execute` runs the full scored verdict in one session — ensemble `SR_X`(EW)/(SPY), DSR (trials=6, ensemble moments), PBO (CSCV 16×8, 128-month trim, assert len==128), the frozen verdict table, the A8 rung-0/family-mean reconciliation, and writes `quant-pilot-03-RESULT.md` material + staged ledger row-5 update (Z2). Modal expectation unchanged: **NO-EVIDENCE/KILL** — the point is the cheapest falsification the ledger has queued.

## Curator flags

- INDEX entry for this note; link from [[quant-pilot-03]] (its execution-protocol section) and beside the pilot-01/02 build notes.
- The code lives in `~/Projects` (vault is markdown-only); this note is the vault pointer + evidence record.

---

*Method: read the frozen spec [[quant-pilot-03]] + Critic [[critic-quant-pilot-03-prereg-2026-08-01]] and the frozen pilot-01/02 executors + harness verbatim; built new code extending (not modifying) the validated harness; verified on synthetic known-answer data + a frozen-panel dry-run that stops short of scoring. $0, paper only, no capital.*
