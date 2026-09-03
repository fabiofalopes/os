---
title: Pairs Trading (Cointegration)
type: strategy-hypothesis
category: mean-reversion
status: proposed
data-source: yfinance + ccxt
priority: medium
edge: "Cointegrated pairs revert; trade the spread z-score. Classic stat-arb, but post-2002 equity returns have decayed sharply."
decay: "High in equities (Gatev et al. edge halved post-2002); crypto cross-exchange/spot-perp pairs fresher."
tags: [quant/strategy, quant/mean-reversion, quant/stat-arb]
created: 2026-07-23
---

# Pairs Trading (Cointegration)

## Source
- **Gatev, Goetzmann & Rouwenhorst (2006)**, "Pairs Trading: Performance of a Relative-Value Arbitrage Rule." 1962–2002, ~11%/yr, but returns fell ~50% post-2002.
- Methodology: **Vidyamurthy (2004)**, *Pairs Trading* (book); Engle-Granger cointegration.
- Crypto: spot–perp and cross-exchange pairs are the modern, less-decayed playground.

## Hypothesis
Identify asset pairs whose log-prices are cointegrated (Engle-Granger test, p<0.05) within sectors (equities) or across venues/instruments (crypto). Compute the hedge-ratio-adjusted spread; enter when |z-score| > 2, exit at z ≈ 0, stop at |z| > 4. The spread mean-reverts because the two assets share a common economic driver.

## Expected edge & decay
- **Edge:** temporary dislocations in strongly-related assets revert as arbitrageurs and fundamentals pull them together.
- **Magnitude:** equities historically ~11%/yr gross, **but ~halved post-2002** due to crowding; crypto spot-perp basis pairs can be better.
- **Decay:** high for vanilla equity pairs. The viable modern form is crypto basis/spot-perp and cross-exchange convergence (see [[Cash-and-Carry Basis Arbitrage]]).

## Data needed (FREE)
- Equities: daily OHLCV, sector-grouped (yfinance), 10+ years.
- Crypto: matched spot + perpetual OHLCV, or same asset on two exchanges, via ccxt (hourly/daily).

## Test design
1. **Pair formation:** within-sector equity pairs / crypto instrument pairs; rolling 12m cointegration test on formation window.
2. **Signal:** spread z-score (standardize by rolling spread mean/SD); entry ±2σ, exit 0, stop ±4σ.
3. **Sizing:** dollar-neutral per pair; portfolio of top-N most-stable pairs; vol-target.
4. **Costs:** 5–10 bps/side; include short-borrow for equities.
5. **Metrics:** per-pair win-rate, half-life of mean reversion, net Sharpe, % of pairs that break cointegration (structural-break loss).
6. **Decay test:** split sample pre/post-2010 for equities; expect material decay — report both.
7. **Robustness:** vary entry/exit thresholds and formation window; require positive half-life stability out-of-sample.

## Failure modes / risks
- **Cointegration breakdown** (M&A, regime change, one leg delists) → tail losses; the stop is essential.
- Severe decay in equities → likely only viable in crypto or as a filtered tail strategy.
- Overfitting pair selection (data-mined cointegration) → use out-of-sample holdout.

## Links
- Distillation: [[micro-stat-arb-cointegration]]
- [[Cash-and-Carry Basis Arbitrage]] — the modern, less-decayed relative-value trade
- [[Short-Term Reversal (1-Month)]]
- [[Crypto Funding-Rate Carry]]
- [[Strategies Index]]
