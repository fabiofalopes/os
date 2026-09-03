---
tags: [value, ledger, quant, money, ranked]
date: 2026-07-21
status: living — Quant maintains, Steward audits; Z2 (human approves capital)
related:
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Kelly Criterion — Position Sizing]]"
---

# Ledger — Ranked Revenue Hypotheses

> The artifact in which the agent "learns where it can make money" ([[Bootstrap to Self-Funding — The Agent Life Arc]], line 56). One row per hypothesis; evidence accumulates, losers are killed, winners scaled. The Conductor routes compute toward the highest-ranked **live** rows.
>
> **Hard rules:** ideas only until the human authorizes capital ([[CLAUDE]] Z4). Paper before live, always. Every result must be *statistically honest* — out-of-sample, overfitting-guarded ([[López de Prado — Backtest Overfitting Guards]]), sized by [[Kelly Criterion — Position Sizing]]. No evidence = **aspiration**, not a claim.

## Schema (per row)

| Field | Meaning |
|---|---|
| **Thesis** | One sentence: what we believe creates value, and why. |
| **Capital required** | Money at risk to test/run it. $0 = evidence-buying only. |
| **Time-to-evidence** | Wall-clock until a falsifiable verdict exists. |
| **Result** | Measured outcome + link to evidence. `—` = untested (aspiration). |
| **Risk-adj. score** | 0–5 rubric below; `n/a` until Result exists. |
| **Status** | `idea` → `paper` → `live` → `killed` (or `parked`). |

**Risk-adjusted score (0–5), applied once a Result exists:**
1. evidence quality (sample size, out-of-sample, Critic-survived) ·
2. edge magnitude (risk-adjusted: Brier/calibration, Sharpe, or demand signal — never raw profit) ·
3. capital efficiency (value per $ at risk) ·
4. time-to-evidence (faster falsification = higher) ·
5. killability (cheap to disprove = higher; unfalsifiable = 0).

**Promotion gate (idea → paper → live):** mirrors the Life Arc Stage 1→2 gate — a statistically honest positive signal out-of-sample that the Critic fails to refute; live capital requires human authorization (Z4).

## The ledger (ranked — row 1 is the Stage-1 pilot)

| # | Thesis | Capital req. | Time-to-evidence | Result | Risk-adj. | Status |
|---|---|---|---|---|---|---|
| 1 | **Forecasting / prediction markets** (Metaculus → Kalshi/Polymarket): we are "ahead of the curve" on a class of questions, and calibration is directly measurable. | $0 (Metaculus calibration is free; Kalshi/Polymarket only at Stage 2, human-approved) | ~4–8 wks: Brier score vs. baseline after ~50–100 resolved questions | — (untested; aspiration) | n/a | idea |
| 2 | **A tool/skill we can give away or sell** (the harness itself, or a forged `.forge/skills/` skill): what we build is wanted by others. | $0 (build + publish; demand = the signal) | ~6–12 wks: publish one artifact, measure adoption/feedback (installs, stars, requests) | — (untested; aspiration) | n/a | idea |
| 3 | **Paper-traded quant signal** (Quantpedia idea → backtest → paper): a tradeable edge exists and survives overfitting guards. | $0 (paper only; live capital gated at Stage 2) | 3 days actual (pre-registered 07-23 → verdict 07-26; est. was 8–16 wks) | **KILL 2026-07-26** — pre-committed guard fired: PBO 0.77 ≥ 0.5 (CSCV, 12,870 combos) + DSR p 0.27 (trials 18, T 42). OOS `SR_X` vs EW **+1.38 net** (vs SPY +1.11, N 42, MDD −11.9%): all 18 configs positive OOS, but train-best selection is noise → premise false *as stated*; killed by guards, not costs. 25/25-check independent audit. [[quant-pilot-01-RESULT]] | 3.5 (test 3.4/4, edge 0.1 — moot: killed) | **killed** |
| 4 | **LLM news/filings-extraction signal** (free SEC EDGAR 8-K full text → LLM-extracted materiality×valence → monthly cross-sectional long quantile): the channel [[ktd-fin]] flags as the LLM's *plausible* edge — textual information processing — which its price-only benchmark never tested. Revival of killed row 3 as a **new** row; inherits the rung-0 gate: must beat `SR_X`(EW) = **+1.377 net** on the same frozen universe/window AND pass DSR + PBO AND a ktd-fin memory-control masking probe. | $0 (free EDGAR data + free local inference; paper only) | ~3–5 wks (Stage-0 smoke → extraction → backtest+guards → Critic) | — (untested; aspiration; pre-registered 2026-07-26) | n/a | idea |

**Ranking rationale:** follows the Life Arc ordering (lowest capital first) and its explicit pilot recommendation — row 1 needs no capital, most directly measures the "edge" we claim, and its calibration feeds the quant path (row 3). Row 2 is parallel-trackable at $0. Row 3 is the slowest to falsify and the most overfitting-prone, so it ranks last despite the largest ceiling.

## Ledger log (append-only)

- **2026-07-21 — Quant:** ledger seeded with the 3 Stage-1 candidates from [[Bootstrap to Self-Funding — The Agent Life Arc]]. All rows `idea`, $0 capital, no results — pure evidence-buying queue. Next: pick row 1 as pilot and define its first falsifiable test (a Metaculus question batch + Brier baseline).
- **2026-07-26 — Quant:** **first real result in the ledger.** [[quant-pilot-01]] executed end-to-end (frozen design + Critic's 8 pre-execution amendments; frozen kill criteria untouched) and independently audited (25/25 checks, separate code path, fresh-fetch price spot-check). Verdict **KILL** (pre-committed): PBO(sharpe) 0.7723 ≥ 0.5; DSR p 0.273. Honest surprise: all 18 configs posted positive OOS `SR_X`(EW) +0.9→+1.6 (12-1 momentum vs EW did NOT decay in the mega-cap 2023–26 window) — but the train-best config is unstable across CSCV splits (selection carries ~no OOS information inside the correlated family) and T = 42 is underpowered, so the premise "edge exists **and survives the guards**" is false as stated. Row 3 → `killed` as stated; revival only as a **new** row (news/filings-extraction channel per [[ktd-fin]], new pre-registration + Critic). Durable assets from the KILL: baseline **rung 0** (future LLM/agent signals must beat ≈ +1.38 `SR_X`(EW) net on the same frozen universe/window AND pass the guards this family failed), a validated constituent-panel pipeline, and aspiration → evidence in 3 days. Evidence: [[quant-pilot-01-RESULT]] · `~/Projects/trading-agents/quant-research/pilots/quant_pilot_01/`. $0, paper only, no capital.
- **2026-07-26 — Quant:** **row-3 revival pre-registered as new row 4** ([[quant-pilot-02]]), exactly as the KILL consequence in [[quant-pilot-01-RESULT]] directs: the channel [[ktd-fin]] flags as the LLM's *plausible* edge (news/filings extraction) which its price-only design never tests. ONE concrete cheap test, kill criterion up top: LLM-extracted materiality×valence from free SEC EDGAR 8-K full text (verified reachable today, no auth, officially dated → the signal layer is point-in-time, a strict fix over pilot-01's look-ahead) → monthly cross-sectional long quantile on the **same hash-frozen universe + price panel** (reused byte-for-byte → exact comparability). **Inherits the rung-0 gate:** PROMOTE requires `SR_X`(EW) > **+1.377 net** AND DSR p < 0.05 (trials = 6) AND PBO < 0.3 AND `SR_X`(SPY) > 0 AND a pre-committed ktd-fin masking probe (ρ ≥ 0.8; ρ < 0.5 = KILL as memory-not-extraction). Grid L∈{1,2,3}×Q∈{D,Q5}, 6 configs, same splits/costs/harness; Stage-0 feasibility gate bounds the CPU-inference risk; model locked once before first extraction (no shopping). Guard #4 clean: verified no prior 8-K/EDGAR work exists in the quant repo. Modal expected outcome = NO-EVIDENCE/KILL (T = 42 underpowered; rung-0 hurdle dominates) — the point is cheap falsification of the channel. Next: queue `[Quant] EXECUTE quant-pilot-02` (worker may not edit [[queue]]). $0, design-only, no capital, no live trading.
