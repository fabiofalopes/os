---
tags: [value, quant, pilot, result, ledger-row-3, KILL]
date: 2026-07-26
status: final — append-only result record (Z2 draft; human/Curator review); supersedes the Verdict section of [[quant-pilot-01]]
related:
  - "[[quant-pilot-01]]"
  - "[[critic-quant-pilot-01-2026-07-26]]"
  - "[[ledger]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[ktd-fin]]"
  - "[[the-alpha-illusion]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Quant Pilot 01 — RESULT (Ledger Row 3 Falsified)

> **VERDICT: KILL** — the pre-committed overfitting guard fired: `PBO = 0.7723 ≥ 0.5` (CSCV, 12,870 combos across the 18 frozen configs) and `DSR p = 0.273 ≥ 0.05` (trials = 18, T = 42). [[ledger]] row 3 → **killed as stated** (classical-factor path on free large-cap data). $0, paper only, no capital touched.

Executed end-to-end 2026-07-26 on the frozen design in [[quant-pilot-01]] (Critic-hardened the same day, 8 amendments, frozen kill criteria byte-identical — [[critic-quant-pilot-01-2026-07-26]]). Pipeline run 14:23–14:29 UTC (universe freeze → fetch → 18-config grid → guards); that session died before writing vault artifacts; a second cron session (15:45 UTC) **verified, did not re-run** (single-execution clause): 25/25 independent-audit checks reproduce every number on a separate code path. No pipeline bug found → no re-execution.

## Verdict application (frozen order, exactly as pre-registered)

| Step | Test | Value | Outcome |
|---|---|---|---|
| 1. INCONCLUSIVE guard | data obtained? min clean names? N ≥ 30? | yfinance 468/503 ok (stooq blocked); min 460 names/month; N = 42 | **passes** |
| 2. KILL | `SR_X ≤ 0` OR `PBO ≥ 0.5` | `SR_X`(EW) = **+1.377**; `PBO`(sharpe) = **0.7723** | **FIRES → KILL** |
| (3. PROMOTE) | `SR_X ≥ 0.5` ∧ `DSR p < 0.05` ∧ `PBO < 0.3` ∧ `N ≥ 30` ∧ Critic | DSR p = 0.273, PBO = 0.77 | unreachable |
| (4. NO EVIDENCE) | residual | — | unreachable |

- `marginal-killed-by-costs` (A2 rule): **False** — `SR_X` = +1.38 ≫ 0; gross +1.423 vs net +1.377 (cost drag 0.39%/yr at 16.3%/mo one-way turnover). This is **killed by the overfitting guards, not by costs**.
- `beta-as-alpha` flag (A7 rule): **False** — `SR_X`(SPY) = +1.109 > 0; the EW-excess is not purely the mega-cap-vs-EW spread. (Moot: KILL already fired.)
- **Metric dependence (logged, not hidden):** PBO on cumulative returns = 0.3399 → verdict would be NO EVIDENCE. Primary = Sharpe, frozen in the executor before the run because it is the pre-registered *selection* criterion (train selection by net Sharpe) — PBO must ask "does IS-best *by the rule we selected on* underperform OOS". Under **neither** metric is PROMOTE reachable (DSR gate fails both ways). The frozen table's PBO line binds on the primary → **KILL**.

## OOS numbers — selected config **F9H3Q5** (formation 9, holding 3, top quintile), 2023-01 → 2026-06, net of 10 bps/side

Selected on train 2015-01→2019-12 by **net** Sharpe only (1.277); validation 2020-01→2022-12 logged, never re-selected on (0.612).

| metric | value |
|---|---|
| `SR_X` vs EW (net / gross) | **+1.377** / +1.423 |
| `SR_X` vs SPY (net, beta diagnostic) | +1.109 |
| N months | 42 |
| mean excess vs EW (ann) | +12.02% |
| vol of excess (ann) | 8.73% |
| net return (ann) | +31.81% |
| MDD (OOS net / full-period net) | −11.89% / −22.44% |
| mean one-way turnover /mo | 0.163 |
| cost drag (ann) | 0.39% |
| EW universe ann return / SPY ann return | +19.80% / +21.37% |

## Overfitting guards ([[López de Prado — Backtest Overfitting Guards]])

- **DSR** (Bailey–López de Prado, trials = 18, OOS skew 0.12 / Pearson kurt 4.62): DSR = 0.7266, **p_deflated = 0.2734**; null threshold SR0 = **1.036 annualized** (vs observed 1.377). At T = 42 the observed Sharpe is not significant against the 18-trial expected max — exactly the underpowered regime the Critic pre-computed (A6: NO-EVIDENCE/KILL modal).
- **PBO** (CSCV, 16 blocks × 8 on the frozen first-128-month trim 2015-01→2025-08, C(16,8) = **12,870 combos**): **0.7723** (sharpe) / 0.3399 (cumret); mean logit ω = −1.176; P(IS-best config posts OOS loss) = 0.000. The IS-best config is more likely than not an OOS *under-median* performer — overfit by construction.

## The full 18-config family (transparency — every config, train + OOS)

| config | train SR | OOS SR raw | OOS `SR_X`(EW) | | config | train SR | OOS SR raw | OOS `SR_X`(EW) |
|---|---|---|---|---|---|---|---|---|
| F6H1D | +1.165 | +1.721 | +1.331 | | F9H1D | +1.101 | +1.742 | +1.430 |
| F6H1Q5 | +1.227 | +1.542 | +0.917 | | F9H1Q5 | +1.271 | +1.590 | +1.049 |
| F6H2D | +1.208 | +1.774 | +1.460 | | F9H2D | +1.164 | +1.752 | +1.463 |
| F6H2Q5 | +1.261 | +1.624 | +1.147 | | F9H2Q5 | +1.255 | +1.620 | +1.176 |
| F6H3D | +1.135 | +1.841 | +1.633 | | **F9H3D** | +1.197 | +1.838 | **+1.634** |
| F6H3Q5 | +1.245 | +1.691 | +1.359 | | **F9H3Q5 ← sel.** | **+1.277** | +1.689 | +1.377 |
| F12H1D | +1.191 | +1.776 | +1.492 | | F12H2D | +1.054 | +1.845 | +1.612 |
| F12H1Q5 | +1.129 | +1.627 | +1.153 | | F12H2Q5 | +1.130 | +1.711 | +1.323 |
| F12H3D | +1.016 | +1.857 | +1.617 | | F12H3Q5 | +1.113 | +1.723 | +1.356 |

## What the KILL means (interpretation, never revival)

The honest surprise: **every one of the 18 configs posted positive OOS selection edge** (+0.92 → +1.63 `SR_X` vs EW) — 12-1-family momentum vs equal-weight did *not* decay in the mega-cap 2023–26 window. What died is the **pre-registered selection procedure**: the train-best config is unstable across CSCV splits (IS-win counts: F12H1D 2,842 · F9H3D 2,807 · F6H1D 2,330 · F6H2D 1,214 · … · the selected F9H3Q5 won only 265/12,870). IS rank carries almost no OOS information inside this tightly-correlated family — the realized +1.38 of the selected config is indistinguishable from selection luck at T = 42. Since family correlation biases PBO *optimistic* (A5), 0.77 is, if anything, understated. This is the textbook [[López de Prado — Backtest Overfitting Guards]] pathology at the *config-selection* level, caught by the guard it was designed for — the row-3 premise ("a tradeable edge exists **and survives overfitting guards**") is false as stated, whatever the raw factor did.

## Data & universe (logged per Critic A1/A2)

- **Universe:** current S&P 500 from Wikipedia, table order preserved, `.`→`-` normalized; **503 constituents**, **sha256/16 = `c1f80ec6f12e83f8`** (full `c1f80ec6f12e83f8df1a4fa9fe4dd4b8a21d0b5586a02bf7cca2e1fea1d19178`), frozen 2026-07-26T14:23Z **before** any price fetch. **NOT point-in-time** — survivorship + post-2015-addition look-ahead; believed net-inflating (failure-delisting channel), partially offset by conservative 10 bps costs and premium-M&A delistings → **a clear KILL is conservative**, which this is (fired on PBO at `SR_X` = +1.38, not marginally).
- **Panel:** yfinance `auto_adjust=True` monthly, 2014-01 → 2026-06, 150 contiguous months; **468/503** tickers fetched clean; **36 batch failures** (yfinance rate-limiting on the shared IP, as the Critic flagged; stooq fallback blocked by anti-bot): ABNB APP CARR CVNA COIN CEG CTVA CRWD DDOG DELL DASH DOW EXE FDXF FOXA FOX GEHC GEV HONA HWM IR INVH KVUE MRNA OTIS PLTR Q HOOD SNDK SOLV TTD UBER VLTO VRT VICI VST. Guard still passes comfortably (min 460 clean names/month; INCONCLUSIVE threshold is <100 for >20% of months). **Direction of the gap:** the failed names are dominated by recent additions and 2023–26 momentum winners (PLTR, APP, VRT, COIN, UBER, CRWD…) — their absence likely *understates* the strategy's OOS and slightly *reduces* the look-ahead bias; second-order for a PBO-based KILL (the guard measures selection stability, not level). No retry: single-execution clause; the pre-registered guard, not discretion, decides sufficiency.
- **Signal convention (frozen literal reading):** momentum at month m = `P[m−2]/P[m−F] − 1` (endpoints as pre-registered: "cumulative return from t−12 to t−2" → 10 monthly returns at F = 12 vs the canonical Jegadeesh–Titman 11; one endpoint shorter, disclosed, chosen before results). H ∈ {2,3} = equal-weight mean of the H most recent monthly cohorts (A4). Costs = Σ|ΔW| × 10 bps = 10 bps/side, charged the bar the new weights earn (validated harness 1-bar lag).

## Prior-observation reconciliation (Critic A8, de Prado guard #4)

The related-design 3-asset backtest (`~/Projects/trading-agents/quant-research/backtests/RESULTS.md`, 2026-07-23: XS 12-1 momentum rotation, raw Sharpe 0.55, losing to 60/40's 0.79 over 2016-07→2026-07) predates this run and contains the OOS window. Over the comparable 2016-07→2026-06 window, the selected 500-name config's raw **net** Sharpe was **1.190** (EW universe 1.073, SPY 1.015). Reconciliation: the 500-name *diversified quantile* construction is a different animal from a *3-asset top-1 rotation* (concentrated noise) — same factor family, ~2× the raw Sharpe, and it still fails the guarded OOS test. The two results agree in direction (momentum is not reliably exploitable here) and the KILL is driven by selection overfit + test power, not by negative raw performance. Prior logged, not hidden; trials = 18 counts the grid only.

## Frozen consequence for [[ledger]] row 3

1. **Row 3 → `killed` as stated** — the classical-price-factor path on free large-cap data. Revival requires a **new** ledger row; the natural candidate is the channel [[ktd-fin]] flags as the LLM's *plausible* edge — news/filings extraction, which its price-only design never tests — with its own pre-registration + Critic review. NOT the NO-EVIDENCE redesign allowance (that dies with the KILL).
2. **Baseline rung 0 is now measured:** any future LLM/agent signal must beat, risk-adjusted on the same frozen universe/window, `SR_X`(EW) ≈ **+1.38 net** (family ceiling +1.63) *and* pass DSR + PBO guards this family failed — operationalizing [[ktd-fin]]'s "beat LightGBM, not the index" bar. This is the durable asset the KILL buys.
3. This is the first ledger row to carry an actual result — aspiration → evidence in 3 days (pre-registered 07-23 → verdict 07-26) vs the ledger's 8–16-week estimate.

## Risk-adjusted score (0–5 rubric, applied now that a Result exists)

| dimension | score | why |
|---|---|---|
| evidence quality | 0.9 | frozen OOS, Critic-hardened pre-registration, 25/25 independent audit; N = 42 modest (underpowered to *confirm* — sufficient to kill) |
| edge magnitude | 0.1 | no *reliable* selection edge: PBO 0.77, DSR p 0.27; raw family OOS positive but unselectable at this T |
| capital efficiency | 0.5 | $0 at risk → evidence + rung-0 baseline + validated infra (real, non-revenue value) |
| time-to-evidence | 1.0 | 3 days vs 8–16 weeks estimated — fast falsification |
| killability | 1.0 | pre-committed guards, $0, killed cleanly and cheaply — the design working as intended |
| **total** | **3.5 / 5** | excellent test, zero exploitable edge — score moot: `killed` rows leave the ranking |

## Evidence & reproducibility

- **Code:** `~/Projects/trading-agents/quant-research/pilots/quant_pilot_01/` — `fetch_universe.py`, `fetch_panel.py`, `run_pilot.py` (executor), `audit_verify.py` (independent audit), `results.json` (every number), `SUMMARY.md`.
- **Data:** `~/Projects/trading-agents/quant-research/data/pilot01/` — `universe.csv` + `universe_meta.json` (hash-frozen list), `monthly_panel.csv` (150×504), `coverage.csv`, `fetch_log.json`.
- **Engine:** `backtests/harness.py` — 12/12 known-answer checks re-passed this session; audit cross-checks the harness path against a from-scratch monthly engine to max abs diff **0.00**.
- **Audit (25/25 PASS):** universe hash reproduced; panel contiguous, ends 2026-06; guard reproduced (min 460); all 18 train Sharpes to 2.2e-16; train selection F9H3Q5; `SR_X`(EW) 1.3772, `SR_X`(SPY) 1.1092, MDD −0.1189; DSR 0.7266 / SR0 1.0363; PBO 0.7723 / 0.3399 over 12,870 combos; verdict KILL reproduced; panel prices match a **fresh yfinance fetch** (AAPL/JPM/XOM × 3 dates) to ≤ 3e-7.
- **Single-execution compliance:** one pipeline run (14:29 UTC); the second session ran only deterministic verification on the frozen panel — no re-fetch, no re-optimization, no discretion.

## Curator flags

- INDEX entry for this note; link it from [[ledger]] row 3 and [[quant-pilot-01]] (workers may not edit shared substrate; ledger row/log updated by this session as the job directs).
- [[López de Prado — Backtest Overfitting Guards]] says "S=16 → 12,780 combos"; C(16,8) = **12,870** (Critic F7, Z2 — wiki note untouched here).
- Set-complete: all three ledger rows now have outcomes or live gates — row 1 awaits its ≥2026-09-02 score ([[forecast-pilot-01]]), row 2 awaits human-approved publish ([[tool-pilot-01]]), **row 3 = KILLED (this note)**.
