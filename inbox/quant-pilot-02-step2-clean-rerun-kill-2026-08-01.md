---
title: "quant-pilot-02 step-2 — clean-fetch re-score → VERDICT: KILL (fixed-mask ρ=0.776)"
date: 2026-08-01
tags: [quant, pilot, ledger-row-4, result, kill, clean-rerun, mask-fix-verified, z2-proposal]
type: session-record + staged Z2 ledger proposal
verdict: KILL (row 4 killed as stated)
mode: $0 paper only, no capital, no live trading
---

# Verdict (one screen)

**ROW 4 = KILL.** The clean-fetch re-run the INCONCLUSIVE verdict itself mandated ([[quant-pilot-02-RESULT]]) was executed on the full re-extracted sample (55,563 ok, fetch_fail 49.8%→0.0036%) with the FIXED masking probe (ρ=0.776, leak audit 0/30). All INCONCLUSIVE precondition guards now PASS, so the frozen verdict table ([[quant-pilot-02]], order INCONCLUSIVE→KILL→NO EVIDENCE→PROMOTE) reaches the thesis for the first time: selected config **L1Q5** (frozen 2026-07-27, never re-selected — A9b) posts **`SR_X(EW) = −0.857` net ≤ 0 → KILL** (first KILL clause: the extraction channel does not even pay its own friction). 5/6 of the family is wrong-sign (mean −0.627; family best L3D +0.012 ≈ 0 — Critic-corrected 2026-08-01). The re-run bought a CLEAN verdict, not a hopeful one — exactly the modal KILL pre-committed.

**Ledger status NOT flipped here (Z2).** Proposal staged below: row-4 Result = KILL, Status `idea`→`killed`, pending Critic + human sign-off. [[ledger]] untouched by this worker.

## Precondition + gate check (all MET — so I scored, did not DEFER)

- **RUNSTATE lock FREE** ✓ (`flock -n data/orchestrate.lock`).
- **Fixed-mask probe COMPLETE** ✓: `data/probe_rerun_2026-08-01.log` ended `done 2026-08-01T04:12:51Z | rho=0.7760 n_pairs=1540 | 1607 fetched, 0 fetch-fail`; `data/probe.full.json` + `data/mask_audit.full.json` (39.5 KB, no longer empty) present.
- **(Step 0) [[critic-mask-fix-audit-2026-08-01]] read FIRST → CLEAN, no frozen-scope violation** (mask.py diff is masking-only, bytecode-identity verified, A4 leak-audit clause sanction; leaky artifacts corroborate 36.7%/ρ=0.768). → proceeded to score.
- **(Critic mandatory re-score gate #2) `mask_audit.full.json` RE-COUNTED** against the four frozen categories: ticker **0/30**, person **0/30**, absolute-date **0/30**, union **0/30 = 0.0% ≤ 10%** ✓ (`[COMPANY]` in 30/30, `[DAY±n]` in 30/30, `[PERSON]` in 0/30 — no officer/honorific spans in these 8-K cover excerpts). This is the frozen ≥30-sample audit dump, not the spot-check. ρ is now trusted.

## Clean re-run numbers (`results.json`, run_utc 2026-08-01T05:36:09Z (wave start ~05:34Z); engine `backtests/harness.py` 12/12; frozen universe `c1f80ec6f12e83f8`; 10 bps/side)

**Extraction (clean):** 55,681 records → ok **55,563** (99.79%) / model_fail 116 / parse_fail 0 / **fetch_fail 2 (0.0036%)**. Malformed-failure rate **0.21%**; breadth **0/138** window months < 100 extracted (was 78/138 = 56.5% on the decimated run). **All INCONCLUSIVE sub-guards FALSE** (`guard.inconclusive=false`).

**Config grid — frozen L1Q5 never re-selected (A9b):**

| Config | Train SR | OOS SR raw | OOS `SR_X(EW)` net |
|---|---|---|---|
| L1D | 1.181 | 1.134 | −1.082 |
| **L1Q5 (selected)** | **1.288** | 1.323 | **−0.857** |
| L2D | 1.032 | 1.260 | −0.266 |
| L2Q5 | 1.136 | 1.327 | −0.934 |
| L3D | 1.048 | 1.298 | +0.012 |
| L3Q5 | 1.113 | 1.317 | −0.632 |

Family mean `SR_X(EW)` = **−0.627** (decimated run was −0.369 — the clean sample is *more* negative, not a rescue).

**Selected L1Q5, OOS (N = 42 months):** `SR_X(EW)` = **−0.857** net (**gross −0.651** — wrong-sign *before* costs too, so the KILL is not a cost artifact); `SR_X(SPY)` = −0.589; net return 17.24%/yr vs EW 19.79% (mean excess **−2.55%/yr**) vs SPY 21.37%; MDD −11.01%; one-way turnover 25.6%/mo (decimated run 1.69% — the full sample actually populates the cross-section, so the portfolio rebalances for real); validation SR (diagnostic only) 0.633.

**Guards:** DSR (trials = 6, realized skew +0.046 / kurt 3.384): **p = 0.9977** (null SR0 = 0.711 ann.). PBO (CSCV 16×8, 12,870 combos, first-128-month trim): **0.2908** (Sharpe), 0.5721 (cumret); L1Q5 IS-best in 9,234/12,870. **ρ = 0.7760188168361031** (fixed mask). `beats_rung0 = false`.

## Verdict-table trace (frozen order, applied exactly)

| Gate | Frozen condition | Measured (clean) | Fired? |
|---|---|---|---|
| INCONCLUSIVE (FIRST) | breadth > 20% months < 100 / failure > 20% / EDGAR down / OOS < 30 / ρ missing | 0/138 months; 0.21%; reachable; N=42; ρ=0.776 present | **NO** (all cleared by the re-extraction + fixed probe) |
| **KILL** | `SR_X(EW) ≤ 0` OR `PBO ≥ 0.5` OR `ρ < 0.5` | **−0.857 ≤ 0** | **YES → verdict stops here** (PBO 0.291 < 0.5 and ρ 0.776 ≥ 0.5 do not fire; the SR_X clause alone kills) |
| NO EVIDENCE | `0 < SR_X ≤ +1.377` / `DSR p ≥ 0.05` / `PBO ∈ [0.3,0.5)` / `ρ ∈ [0.5,0.8)` | not evaluated (KILL first) | — (note: DSR p 0.998 and ρ 0.776 < 0.8 would each independently give NO EVIDENCE had SR_X been positive) |
| PROMOTE | all bars | not evaluated | — |

**Recorded verdict: KILL.** Row 4 → `killed` as stated (LLM 8-K-extraction path on free large-cap data). This is a KILL, **not** NO-EVIDENCE — the one-redesign allowance is NOT available; revival requires a **new** ledger row + new Critic review (frozen KILL consequence).

## Leaky-vs-fixed ρ reconciliation

| Probe | ρ | n_pairs | n_sample | p |
|---|---|---|---|---|
| Leaky mask (36.7% leaks) | 0.767988 | 1607 | 1607 | 0.0 |
| **Fixed mask (0% leaks)** | **0.776019** | 1540 | 1607 | 3.6e-310 |

- **Δρ = +0.008 — negligible.** Closing the 36.7% identity leak (MMM "3M COMPANY" + `mmm:`/`abbv:`/`aes:` XBRL prefixes) did **not** materially move the memory-control correlation: the leaks were not inflating ρ. Both readings land in the same `[0.5, 0.8)` band — the signal retains ~78% of per-filing rank information under masking (not identity-collapsed, which would be ρ < 0.5 → its own KILL), but falls short of the 0.8 PROMOTE bar. Moot for the verdict: KILL fires first on `SR_X(EW) ≤ 0`.
- **n_pairs 1607 → 1540 (−67, 4.2%):** 67 masked re-extractions failed to return parseable JSON after the one frozen retry (`fetch-fail = 0` end-to-end; `run_probe` appends a pair only on successful parse). Per A5 the direction is conservative — more masking / dropped pairs cannot push ρ *up* toward the 0.8 bar. At n = 1540, p = 3.6e-310: ρ is statistically rock-solid; the 4.2% drop does not qualify the gate (Critic gate #1 "n_pairs ≈ 1607" met to 95.8%, all attrition = masked-parse-drop, 0 fetch-fail).

## Honesty note — `run_pilot.py` ρ-ordering bug (worked around, NOT patched)

Running the re-score exactly as RUNSTATE:168 writes it — `python run_pilot.py verdict --tag full` (no `--rho`) — returns **VERDICT: INCONCLUSIVE** with a self-contradictory guard block: `guard.inconclusive=true` **and** `guard.rho_missing=false`. Cause (code read + empirically reproduced): `mode_verdict` computes `guard_inconclusive` (run_pilot.py:281-283) testing `rho is None` on the **CLI argument**, but loads ρ from `probe.full.json` only afterward (run_pilot.py:313-315). With no `--rho`, the argument is `None` → the guard spuriously fires INCONCLUSIVE even though the probe exists and is loaded — masking the true verdict.

**Workaround (this wave):** pass ρ through the frozen CLI argument — `run_pilot.py verdict --tag full --rho 0.7760188168361031` (the exact content of `probe.full.json`) → `guard.inconclusive=false` → **VERDICT: KILL**. This applies the frozen table correctly; the value is identical to the file-loaded one. **Frozen scoring code deliberately left UNTOUCHED** (preserves the bytecode-identity / "untouched since 2026-07-27" property [[critic-mask-fix-audit-2026-08-01]] verified). The bug biases toward the *softer* INCONCLUSIVE; the workaround reveals the *harsher* KILL — no gaming direction. **Recommendation (future A9b patch, logged not done here):** move the `probe.{tag}.json` ρ-load above the `guard_inconclusive` computation, or always pass `--rho`. The 2026-07-28 INCONCLUSIVE `results.json` is preserved at `results.inconclusive.2026-07-28.json` (verified byte-identical before overwrite).

## A8 reconciliation vs rung-0

Rung-0 bar `SR_X(EW)` = **+1.377 net** ([[quant-pilot-01-RESULT]]; pilot-01 family mean 1.363 — the bar is not luck-inflated). This pilot's clean family mean = **−0.627**, family best (L3D) +0.012 (5/6 negative; Critic-corrected 2026-08-01 — L3D +0.012 > L2D −0.266), selected L1Q5 −0.857: a wrong-sign family ≈ **2.0 Sharpe units below** the bar (even the family best sits 1.37 below it). The LLM 8-K extraction channel on free large-cap data carries no risk-adjusted selection edge net of costs — the [[ktd-fin]] "plausible LLM edge" channel is falsified on this universe/window, consistent with (not merely "similar to") rung-0's momentum KILL. Durable asset: rung-0 baseline stands; every future LLM/agent signal must still beat +1.377 net AND pass DSR + PBO + ρ ≥ 0.8 + beta rule + Critic.

## STAGED Z2 proposal — [[ledger]] row 4 (NOT flipped by this worker)

> Human/Critic to approve. [[ledger]] is Z2-maintained; this worker stages, does not edit.

- **Result:** `KILL — clean-fetch re-run 2026-08-01: SR_X(EW) = −0.857 net ≤ 0 (L1Q5, frozen config), family mean −0.627, DSR p = 0.998, PBO 0.291, ρ = 0.776 (fixed mask, 0/30 leaks). All INCONCLUSIVE guards cleared; KILL on the wrong-sign-after-costs clause. See [[quant-pilot-02-RESULT]] clean-re-run addendum.`
- **Status:** `idea` → **`killed`** (as stated; revival = new ledger row + new Critic review, NOT the redesign allowance).
- **Guards/evidence path:** `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` — `results.json` (verdict + all numbers), `data/probe.full.json` (ρ=0.776, n_pairs=1540), `data/mask_audit.full.json` (0/30 re-audit), `data/probe_rerun_2026-08-01.log` (1607 fetched, 0 fetch-fail), `data/config_freeze.json` (L1Q5, never re-selected), `results.inconclusive.2026-07-28.json` (preserved prior verdict). Vault: [[quant-pilot-02-RESULT]] · [[critic-mask-fix-audit-2026-08-01]] · [[quant-pilot-02]].
- **Capital:** $0, paper only, no capital touched, no live trading.

## Disposition

- **VERDICT: KILL** recorded; [[quant-pilot-02-RESULT]] amended in place (clean-re-run addendum; frozen INCONCLUSIVE text untouched); RUNSTATE step-2 marked COMPLETE.
- NO-EVIDENCE redesign allowance **unspent and unavailable** (this is a KILL). Row-3 lineage (momentum KILL → 8-K revival KILL) is closed on this universe/window; the next LLM/agent hypothesis, if any, is a fresh row.
- $0 at risk throughout; the re-run converted an infra-INCONCLUSIVE into a clean thesis-KILL — aspiration → evidence, the mission's core move.
- **Critic-certified 2026-08-01** ([[critic-quant-pilot-02-KILL-certification-2026-08-01]]): staged proposal ENDORSED with the two verdict-neutral corrections applied above (family best L3D +0.012, not L2D −0.266; run_utc 05:36:09Z, not 05:34Z). Ledger still untouched — human sign-off owed.
