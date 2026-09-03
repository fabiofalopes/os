---
title: Idiosyncratic (Residual) Momentum
type: strategy-hypothesis
category: momentum
status: proposed
data-source: yfinance
priority: medium
edge: "Momentum from the stock-specific (factor-stripped) return component; cleaner, lower-crash signal than raw 12-1."
decay: "Medium — less crowded than raw momentum; needs a factor model so implementation cost is higher."
tags: [quant/strategy, quant/momentum, quant/factor]
created: 2026-07-23
---

# Idiosyncratic (Residual) Momentum

## Source
- **Blitz, Huij & Martens (2011)**, "Residual Momentum." Rank on the residual from a Fama-French regression rather than raw returns; higher risk-adjusted returns, lower crash sensitivity.
- Related: **Chordia & Shivakumar (2002)** momentum and business-cycle variables.

## Hypothesis
Regress each stock's rolling 36-month returns on market (and optionally size/value) factors; take the trailing 12-1 cumulative **residual** (alpha component) as the ranking signal. Long top decile / short bottom decile. By stripping common factor exposure, the signal captures firm-specific information diffusion and is less contaminated by sector/industry momentum.

## Expected edge & decay
- **Edge:** isolates genuine stock-specific underreaction; empirically higher Sharpe and milder crashes than raw momentum.
- **Magnitude:** ~comparable or better risk-adjusted than raw momentum in the paper; expect a haircut live.
- **Decay:** medium — less directly arbitraged than headline momentum but correlated with it.

## Data needed (FREE)
- US equities daily/weekly OHLCV (yfinance), 300+ names, 10+ years.
- Factor returns: build a market factor from the equal-/cap-weighted universe itself; size/value factors optional (yfinance fundamentals are sparse → market-only residual is the pragmatic version).

## Test design
1. **Universe:** 300–500 liquid US stocks, monthly rebalance, 10+ years.
2. **Signal:** rolling 36m regression on market factor → residual; rank trailing 12-1 cumulative residual.
3. **Portfolio:** long top / short bottom decile, market-neutral, vol-target 10%.
4. **Costs:** 5 bps/side; exclude hard-to-borrow.
5. **Metrics:** Sharpe, FF3/FF5 alpha, crash beta vs. raw momentum (side-by-side), turnover.
6. **A/B:** directly compare to [[Cross-Sectional Momentum (12-1)]] on identical universe — residual momentum should show lower down-market beta.
7. **Robustness:** vary regression window (24/36/60m) and factor set.

## Failure modes / risks
- Factor-model estimation noise with short histories.
- If only market factor available, "residual" still contains sector effects → note as limitation.
- Higher implementation complexity than raw momentum for modest incremental edge.

## Links
- Distillation: [[theory-fama-french]] (factor model for the residual)
- [[Cross-Sectional Momentum (12-1)]]
- [[Betting-Against-Beta (Low-Volatility)]]
- [[Quality (Profitability) Factor]]
- [[Strategies Index]]
