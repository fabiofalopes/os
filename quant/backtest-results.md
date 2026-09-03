---
title: Backtest Engine & Baseline Results
aliases: [Backtest Results, harness.py, Vectorized Backtester]
tags: [quant/backtest, quant/results, quant/engine, trading, research]
type: results
status: validated-on-baselines
created: 2026-07-23
updated: 2026-07-23
maintainer: backtest (pane 6)
---

# Backtest Engine & Baseline Results

> [!abstract] What this is
> A minimal **vectorized backtester** (pandas/numpy only, no heavy deps) at
> `backtests/harness.py`, validated on known baselines, plus the first baseline
> results. Model: **long/short daily rebalance**, proportional **transaction
> costs**, a strict **1-bar execution lag (no lookahead)**, and standard metrics
> (CAGR, Sharpe, Sortino, maxDD, Calmar, volatility, turnover).

> [!info] Artifacts
> - Engine: `~/Projects/trading-agents/quant-research/backtests/harness.py`
> - Strategies: `backtests/strategies.py` · Runner: `backtests/run_backtests.py`
> - Validation: `backtests/test_harness.py` (12 known-answer checks, all pass)
> - Workspace results: `backtests/RESULTS.md`
> - Data prep: `backtests/prepare_fred.py` (builds the FRED-derived panel)

## Engine design

The engine is a pure function `run(prices, weights, cost_bps) -> BacktestResult`.
A *strategy* is any function returning a target weight matrix `W` (dates ×
assets); weights may be **negative (short)** and need not sum to 1 (leverage /
cash). Everything is vectorized — no per-day Python loop.

- **No lookahead.** `held = W.shift(1)`: the weight decided at the close of day
  *t* earns the return of day *t+1*. Signals may use prices up to and including
  the current close.
- **Costs.** One-way proportional cost on turnover. Turnover entering day *t* is
  `|W[t-1] − W[t-2]|` summed across assets; the initial build from a flat book is
  charged too.
- **Metrics.** CAGR from the equity curve (252 d/yr); Sharpe/Sortino annualized
  by √252; maxDD from the running peak; Calmar = CAGR/|maxDD|. The flat
  initialization bar is excluded from the moment statistics.

> [!check] Validation (known-answer tests)
> `test_harness.py` proves the *mechanics* independent of market data:
> - buy & hold reproduces the asset's own return to **1e-15**;
> - the cost model is **exact** — a daily full flip costs precisely 2×bps/day;
> - **no lookahead** — a same-bar signal earns ~0 (0.0003/day) vs the 0.016/day
>   a lookahead engine would capture on iid returns;
> - constant-return CAGR/vol/maxDD match closed forms; a constructed −25%
>   drawdown is recovered exactly; long/short books behave correctly.

## Baseline results (10y, 2016-07 → 2026-07)

Data: FRED-derived panel — **SPX** (S&P 500 *price* index), **UST10** (10y
Treasury constant-duration total return from `DGS10`), **TBILL** (fed-funds cash
from `DFF`). 5 bps one-way cost. Benchmark: buy & hold SPX.

| Strategy | CAGR | Sharpe | Sortino | MaxDD | Vol | Calmar | Turn/yr |
|:--|:--|--:|--:|:--|:--|--:|--:|
| **60/40** | +8.3% | 0.79 | 0.98 | −21.5% | 10.9% | 0.39 | 0.10 |
| **XS Momentum** (top-1, risk-off) | +7.6% | 0.55 | 0.56 | −33.9% | 15.5% | 0.22 | 2.11 |
| **TS Momentum / trend** | +6.3% | 0.62 | 0.67 | −19.8% | 10.8% | 0.32 | 2.01 |
| **Risk parity** (inv-vol) | +3.9% | 0.58 | 0.73 | −19.5% | 6.9% | 0.20 | 0.75 |
| *(bench)* buy & hold SPX | +13.3% | 0.78 | — | — | — | — | — |

**Read-through.**
- In a strong equity decade, **buy & hold equity beat every risk-managed
  strategy** — the classic caveat: defensive/tactical overlays shine in
  drawdowns, not in relentless bull markets. (SPX here is *price-only*, so the
  true total-return gap to a dividend-inclusive benchmark is even larger.)
- **Trend / time-series momentum** ([[micro-momentum]]) delivered the best
  *defensive* risk-adjusted profile: it cut maxDD to −19.8% (vs −21.5% for 60/40
  and the SPX benchmark's own drawdowns) while keeping a 0.62 Sharpe.
- **Cross-sectional momentum** top-1 on a tiny 2-asset universe whipsawed in
  **2022** (stocks *and* bonds fell together), producing the worst maxDD
  (−33.9%). Concentration + a slow 12-month lookback is the culprit — a richer,
  diversified universe is needed before drawing strategy conclusions.
- **Risk parity** ([[theory-risk-parity]]) did what it advertises: lowest
  volatility (6.9%) and a contained drawdown, at the cost of return (bond-heavy
  in a flat-bond decade).

> [!warning] Caveats — read before trusting the numbers
> - **Data provenance.** Yahoo Finance hard-rate-limited the shared IP this run,
>   so the rich ETF total-return universe could not be fetched. Baselines use the
>   FRED-derived panel instead: **SPX excludes ~2%/yr dividends** and **UST10 is a
>   first-order constant-duration approximation** (ignores convexity & coupon
>   reinvestment). Figures are directionally sound for validating the engine and
>   comparing strategies on equal footing — **not** precise total-return numbers.
>   Re-run `data/fetchers/fetch_retry.py` once the limit clears, then
>   `backtests/run_backtests.py` (it auto-prefers the ETF universe). See
>   [[data-sources]].
> - **No hypotheses yet.** `strategies/HYPOTHESES.md` was not published in time;
>   these canonical baselines (60/40, momentum, trend, risk parity) stand in.
>   When hypotheses land, plug them into `strategies.py` and re-run.
> - Single 10y window, no parameter sweep, no out-of-sample split, no statistical
>   significance. This is harness validation, **not** alpha research.

## Next steps

- [ ] Fetch the full ETF universe (SPY/AGG/TLT/QQQ/EFA/EEM/GLD/VNQ/LQD/HYG/BIL)
      once Yahoo's rate limit clears → regenerate on true total returns.
- [ ] Implement the top 2–3 hypotheses from `strategies/HYPOTHESES.md` when posted.
- [ ] Add walk-forward / out-of-sample splits and a parameter-sensitivity sweep.
- [ ] Wire position sizing from `risk/sizing.py` ([[risk-framework]]) when it exists.

## Links

[[INDEX]] · [[CANON]] · [[data-sources]] · [[risk-framework]] ·
[[theory-risk-parity]] · [[micro-momentum]] · [[theory-markowitz]]
