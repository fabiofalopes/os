---
tags: [value, quant, pilot, precommitment, ledger-row-3]
date: 2026-07-23
status: draft (Z2) — LOCKED pre-commitment; factor, grid, splits, costs and kill math are frozen before any data is fetched; execution + Critic before any ledger status change; Critic-hardened 2026-07-26 (8 amendments pre-execution; frozen kill criteria untouched — [[critic-quant-pilot-01-2026-07-26]])
related:
  - "[[critic-quant-pilot-01-2026-07-26]]"
  - "[[ledger]]"
  - "[[ktd-fin]]"
  - "[[the-alpha-illusion]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[learning-path]]"
  - "[[forecast-pilot-01]]"
  - "[[tool-pilot-01]]"
---

# Quant Pilot 01 — First Falsification Test of Ledger Row 3

> Tests [[ledger]] row 3 ("a tradeable edge exists and survives overfitting guards", via Quantpedia idea → backtest → paper). **ONE concrete cheap test:** the bottom rung of the [[ktd-fin]] baseline ladder — a single pre-registered classical price factor (Jegadeesh–Titman 12-1 cross-sectional momentum) on a free-data S&P 500 universe, judged **out-of-sample, net of costs, against the overfitting guards** ([[López de Prado — Backtest Overfitting Guards]]). $0, no capital, no live trading. Dual purpose: (1) falsify the row's premise on the cheapest possible signal; (2) whatever the OOS number is becomes **baseline rung 0** that every future LLM/agent signal must beat risk-adjusted — ktd-fin's lesson ("beat LightGBM" is the bar, not "beat the index") made operational.

## ☠ KILL CRITERION (pre-committed — do not move after seeing any data)

**Metric:** `SR_X` = annualized Sharpe of monthly **excess** returns of the long factor-quantile portfolio over the equal-weight full universe (the equal-weight benchmark strips the common component — excess ≈ stock-selection, per [[ktd-fin]]'s attribution lesson), **net of 10 bps/side**, over the frozen OOS window 2023-01 → 2026-06 (≈42 monthly obs). `DSR` = deflated Sharpe (Bailey–López de Prado, trials = 18 = grid size). `PBO` = probability of backtest overfitting via CSCV (16 blocks) across the 18 pre-registered configs. **CSCV block alignment (Critic 2026-07-26):** the full series is 138 months (2015-01→2026-06), not divisible by 16 — the PBO matrix is trimmed to the **first 128 months (2015-01→2025-08)**, 16 blocks × 8, C(16,8) = 12,870 combos; the trim rule is frozen here, never chosen at execution. The `SR_X` verdict window is unaffected (full 42-month OOS); PBO is a multiple-testing diagnostic on the full matrix (paper-standard), not an independent OOS test.

| Verdict | Condition (applied in order — **guard first**, house style per [[forecast-pilot-01]]) | Consequence for [[ledger]] row 3 |
|---|---|---|
| **INCONCLUSIVE** (precondition guard, evaluated FIRST) | Free data unobtainable cleanly (yfinance **and** stooq fallback both fail), **OR** universe < 100 clean names for > 20% of the window, **OR** OOS window < 30 months | No verdict — infra failure, not thesis failure. Fix the data path (e.g., Qlib free US data), re-run. This guard can only ever mask a KILL/NO-EVIDENCE — never manufacture a PROMOTE. |
| **KILL** | `SR_X ≤ 0` (wrong sign after costs — the factor does not even pay its own friction), **OR** `PBO ≥ 0.5` (the best in-sample config is more likely than not an OOS underperformer — overfit by construction) | Row 3 → `killed` **as stated** (classical-factor path on free large-cap data). Revival requires a **new** ledger row — the natural candidate is the channel [[ktd-fin]] flags as the LLM's *plausible* edge (news/filings extraction, which its price-only design never tests) — with a new Critic review. NOT the NO-EVIDENCE redesign allowance. |
| **PROMOTE** | `SR_X ≥ 0.5` **AND** `DSR p < 0.05` (trials = 18) **AND** `PBO < 0.3` **AND** `N ≥ 30` months **AND** Critic fails to refute | Row 3 → `paper`: the 8-week operational paper window below (execution-fidelity test, not a second statistical test — N≈2 rebalances cannot be one). Live capital remains Z4-gated regardless. |
| **NO EVIDENCE** (residual) | `SR_X > 0` but any PROMOTE gate unmet (positive but noise-scale: insignificant DSR, `PBO ∈ [0.3, 0.5)`, or `SR_X < 0.5`) | Row 3 stays `idea`. **One** redesign allowed — a different factor *family* (e.g., short-term reversal or quality), never a re-optimization of this grid — with a dated, linked artifact + Critic and human (Z2) sign-off. |

**Anti-fooling commitments** (per [[López de Prado — Backtest Overfitting Guards]] and [[Operating Principle — Test Don't Wonder]]):
- **One factor family, one pre-registered grid (18 configs), trials counted and deflated.** No silent extra configs; DSR is told the truth (N_trials = 18).
- **No peeking:** OOS window frozen at 2023-01 → 2026-06 **now**, before any fetch — the executor cannot pick a favorable end date. Config selection happens on the train window only; the validation window is logged, never re-selected on.
- **No universe shopping:** the constituent list is hash-frozen at execution (sha256/16 into the RESULT note). Survivorship bias direction is logged below — it inflates, so a PROMOTE is read with caution and a KILL is conservative.
- **Costs always on.** Gross-positive-but-net-negative = KILL, not "it works before costs."
- **Verdict on the full OOS window.** No sub-period cherry-picking ("it worked in 2023"); splits are diagnostics only.
- **Single execution run.** Re-runs only for a documented pipeline bug (fix logged in the RESULT note); a bug fix is never an excuse to re-optimize.
- **Critic before any PROMOTE** (Z2). Status change on [[ledger]] row 3 is human-approved.
- **Data is NOT point-in-time (Critic 2026-07-26):** current-constituent list + retroactively-adjusted closes = survivorship **plus look-ahead** (post-2015 index additions are backtested before their addition date). Net bias direction believed inflating (failure-delisting channel dominates — standard delisting-bias result; not fetched this session), but conservative costs (10 bps/side ≈ 2× true large-cap friction, ≈1%/yr drag at 40% turnover) partially offset, as do premium-M&A delistings (which remove some winners). "KILL is conservative" holds for a clear KILL; a marginal KILL (`SR_X ∈ [−0.3, 0]` with gross `SR_X > 0`) must be reported in the RESULT note as "killed by costs" — interpretation, never revival.
- **PBO scope (Critic 2026-07-26):** PBO/DSR deflate for the 18-config grid only. The grid is a tightly-correlated family (overlapping formation windows, same universe/dates), which biases PBO optimistic (IS-best tracks OOS-best under high correlation); `PBO < 0.3` is necessary-not-sufficient — the PROMOTE gate composition (DSR **AND** PBO **AND** Critic) carries the load. The factor family was chosen from theory (Jegadeesh–Titman 1993), not in-sample search, so the published factor zoo is not counted in trials=18 (logged, not hidden).
- **Test power (Critic 2026-07-26):** at T = 42 months, trials = 18, the DSR null threshold ≈ 1.85·σ_SR ≈ 0.29/mo ≈ **`SR_X` ≈ 1.0 annualized** (σ_SR ≈ 1/√42 under a normal null; realized negative skew/fat tails raise it — recompute at execution). The `SR_X ≥ 0.5` line is slack; DSR dominates. PROMOTE is a high bar by construction; **NO-EVIDENCE is the modal expected outcome**, read as "underpowered to confirm," not "edge absent."
- **Prior-observation disclosure (Critic 2026-07-26):** a related-design momentum backtest already exists — `~/Projects/trading-agents/quant-research/backtests/RESULTS.md` (2026-07-23): **3-asset** XS 12-1 momentum rotation (SPX/TBILL/UST10, top-1 + risk-off, 5 bps, FRED price-index data) over 2016-07→2026-07, raw Sharpe 0.55, losing to 60/40 (0.79) and SPX buy-and-hold. This is NOT this pilot's statistic (no 500-name universe, no quantile grid, no `SR_X` vs equal-weight, no DSR/PBO — verified: no constituent data ever fetched), but its window contains the frozen OOS window, so per [[López de Prado — Backtest Overfitting Guards]] guard #4 the no-peeking claim is disclosed as incomplete: the researcher has seen momentum-family evidence over this period (in the KILL direction). Consequences: trials=18 counts the grid only, the prior run is logged not hidden; and the RESULT note must explicitly reconcile its verdict against those RESULTS.md numbers.

## What is being tested — and the honest caveats

Thesis under test: *a cheap, published, classical factor signal, executed honestly on free data, carries risk-adjusted selection edge net of costs after overfitting guards — i.e., the row-3 pipeline can produce something real.*

**Known handicaps (logged, not hidden):**
- **Momentum is crowded post-2010.** The prior is that large-cap US 12-1 momentum has decayed since publication; a KILL is a *live, expected* possibility. That is the point — exactly as in [[forecast-pilot-01]], the most likely honest outcome converts aspiration into evidence.
- **Free-data quality — NOT point-in-time.** yfinance adjusted closes: survivorship (current constituents only) **+ look-ahead (post-2015 index additions backtested before their addition date)** + retroactive corporate-action adjustments + occasional bad ticks. Believed net direction = inflates (failure-delisting channel dominates), partially offset by conservative costs and premium-M&A delistings (see anti-fooling commitments) → PROMOTE needs the caveat; a clear KILL stands; a marginal KILL gets the "killed by costs" reading logged there.
- **Test-power honesty:** this batch **falsifies** the classical-price-factor path but **cannot confirm** the deeper row-3 thesis of an *LLM-relevant* edge — [[ktd-fin]]'s own caveat: a price-only OHLCV channel tests technical timing, exactly where agents have no information advantage to claim. A KILL kills the row **as stated**, not quant as such; the news/filings-extraction channel is a new hypothesis (new row, new Critic review).
- **Attribution is partial.** Equal-weight benchmark strips the common component but not style; a full Barra-style decomposition ([[ktd-fin]]) is a Stage-2 requirement before any live claim. Logged, not solved here. **OOS-window-specific risk (Critic 2026-07-26):** 2023–2026 was mega-cap-concentrated — a momentum long book of mega-cap winners can post positive `SR_X` vs EW off the cap-vs-EW spread alone (beta-as-alpha). The RESULT note must report `SR_X` vs SPY alongside vs EW; `SR_X`(EW) passing PROMOTE while `SR_X`(SPY) ≤ 0 is beta, not selection, and fires the PROMOTE row's "Critic fails to refute" clause.

## The test (FROZEN design)

- **Universe:** current S&P 500 constituents (Wikipedia table — free, no auth), list hash-frozen at execution.
- **Data:** yfinance split/dividend-adjusted OHLCV, 2014-01-01 → **2026-06-30 (frozen end)**; fallback stooq free CSVs; both fail → INCONCLUSIVE.
- **Factor:** 12-1 momentum — cross-sectional rank of cumulative return from t−12 to t−2 (skip the most recent month), monthly rebalance, equal-weight within quantile.
- **Config grid (pre-registered, 18 = trials for DSR):** formation {6, 9, 12} months × holding {1, 2, 3} months × quantile {top decile, top quintile}, all long-only. Holding H ∈ {2,3} = equal-weight average of the H most recent monthly cohorts, rebalanced monthly (standard Jegadeesh–Titman overlapping construction) — frozen here, not at execution (Critic 2026-07-26).
- **Splits:** train 2015-01 → 2019-12 (config selection by **net** Sharpe) · validation 2020-01 → 2022-12 (logged only, no re-selection) · **OOS 2023-01 → 2026-06 (frozen verdict window, ≈42 months)**.
- **Costs:** 10 bps/side on turnover (conservative for large-cap US — direction logged above).
- **Report:** `SR_X` (vs equal-weight; **and vs cap-weight SPY — mandatory beta diagnostic: EW-pass + SPY-fail = beta not selection, Critic-refuted**, Critic 2026-07-26), max drawdown, `N`, realized turnover, DSR (skew/kurtosis-corrected, trials = 18), PBO (CSCV, 16 blocks **on the first 128 months — trim frozen in the metric block**, Critic 2026-07-26) — report N and deflate the SR, never raw profit.

## Execution protocol (mechanical — for the executor session)

**Queue this job:** `[Quant] EXECUTE quant-pilot-01 — data pipeline + momentum backtest + guards` (worker may not edit [[queue]]; runner/Curator to add).

0. **Freeze the universe:** fetch the Wikipedia S&P 500 table; write the ordered ticker list + its sha256/16 into the RESULT note before fetching prices.
1. Fetch adjusted OHLCV for all constituents (yfinance; stooq fallback) for 2014-01-01 → 2026-06-30. Log per-ticker coverage; drop names with gaps in the formation window for that month only. Membership is **NOT point-in-time** — it is the frozen current-constituent list as-is, with survivorship + future-addition look-ahead logged above (Critic 2026-07-26).
2. Compute the 18 configs exactly as specified; monthly rebalance; equal-weight within quantile; 10 bps/side on turnover.
3. Select the best config by **net** Sharpe on the train window only; log the validation-window numbers for the selected config (diagnostic, no re-selection).
4. On the frozen OOS window: compute `SR_X` vs equal-weight **and vs SPY** (beta rule applies — see the attribution caveat), MDD, `N`, turnover.
5. Compute DSR (trials = 18, with OOS skew/kurtosis) and PBO (CSCV, 16 blocks × 8 = 12,870 combos, across the 18 configs' net returns **trimmed to the first 128 months, 2015-01→2025-08 — trim frozen in the metric block**) per [[López de Prado — Backtest Overfitting Guards]].
6. Apply the verdict table **exactly as written**. Write `wiki/value/quant-pilot-01-RESULT.md` (append-only relative to this note) and flag the [[ledger]] row 3 Result + Status update (Z2 — human/Critic sign-off).
7. **If PROMOTE — the 8-week operational paper window** (execution fidelity, NOT statistics; N≈2 rebalances is admitted as such): pre-commit pass = (a) live-constructed signal on overlapping dates hash/recompute-matches the backtest signal (no look-ahead), (b) realized one-way cost ≤ 15 bps, (c) ≥ 2 rebalances executed cleanly with zero ops failures. Fail any → back to NO EVIDENCE with the failure logged.

## Time-to-evidence

- **Backtest verdict:** ~3 weeks (≈4 cron sessions: data pipeline → backtest → guards → Critic). First falsifiable checkpoint.
- **Full row verdict (only if PROMOTE):** +8-week operational paper window → **~11–12 weeks total**, inside the ledger's 8–16-week estimate.

## Verdict

`—` untested (aspiration). Until `quant-pilot-01-RESULT.md` exists, row 3 has a scheduled test, not a result.

---

**Set-complete note (for Curator):** with this pre-registration, **all three [[ledger]] rows now carry pre-committed kill criteria** — row 1 [[forecast-pilot-01]] (awaits its single score run ≥ 2026-09-02), row 2 [[tool-pilot-01]] (awaits first publish T0, human-approved), row 3 this note (awaits the EXECUTE backtest job). Rows 1–2 wait on their gates; row 3's gate is queued above. **Curator:** link this note from [[ledger]] row 3 and add an INDEX entry (workers may not edit shared substrate).

## Critic Amendment — 2026-07-26 (pre-execution hardening)

Full adversarial review: [[critic-quant-pilot-01-2026-07-26]]. **Legitimacy of in-place amendment:** the pilot has **never been executed** — no `quant-pilot-01-RESULT.md`, no constituent data ever fetched, the 18-config grid never run (verified 2026-07-26: `~/Projects/trading-agents/quant-research/data/raw` holds only FRED macro + 7 ETF/mega-cap series). Every change below strictly **tightens** the pre-registration or freezes a mechanical detail the executor would otherwise improvise (a peeking vector) — the frozen kill criteria (thresholds, windows, grid, costs) are untouched. This is pre-registration hardening, not post-hoc correction.

Amended: **(A1)** step 1 + caveats — data honestly labelled NOT point-in-time; future-addition look-ahead logged. **(A2)** anti-fooling — bias-offset logged (conservative costs + M&A delistings partially offset survivorship inflation); marginal-KILL "killed by costs" reading. **(A3)** metric block + step 5 — CSCV trim frozen (138 ∤ 16 → first 128 months, 12,870 combos). **(A4)** grid — holding-period overlapping-cohort convention frozen. **(A5)** anti-fooling — PBO scope: grid-only deflation, correlation → optimistic bias, necessary-not-sufficient. **(A6)** anti-fooling — test power: DSR effectively requires SR_X ≈ 1.0 at T=42/N=18; NO-EVIDENCE is modal. **(A7)** attribution + report — EW-vs-SPY beta rule: EW-pass + SPY-fail fires the PROMOTE row's Critic-refute clause. **(A8)** anti-fooling — prior-observation disclosure: the quant-research 3-asset momentum backtest (Sharpe 0.55, 2016-07→2026-07) predates execution and contains the OOS window; not this statistic, but disclosed per de Prado guard #4; RESULT must reconcile.

**Executor-facing flags (for the EXECUTE job):** (1) reuse the **validated** harness at `~/Projects/trading-agents/quant-research/backtests/` (12 known-answer checks pass; 1-bar lag proven; exact cost model) — extend it to the constituent panel rather than writing a new backtester. (2) That repo's run hit **yfinance rate-limiting on the shared IP** — the stooq fallback and the INCONCLUSIVE guard are live risks, not boilerplate. (3) Their SPX series is a **price index** (ex-dividend) — do not reuse it for `SR_X`; fetch adjusted constituent OHLCV fresh.

**Curator flag:** [[López de Prado — Backtest Overfitting Guards]] says "S=16 → 12,780 combos"; C(16,8) = 12,870 (verified). Wiki note is Z2 — flagged, not touched here.
