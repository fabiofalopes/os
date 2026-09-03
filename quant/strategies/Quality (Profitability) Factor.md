---
title: Quality (Profitability) Factor
type: strategy-hypothesis
category: factor
status: proposed
data-source: yfinance
priority: medium
edge: "Profitable, stable, low-accrual firms outperform junk; quality is defensive and pairs well with momentum/value."
decay: "Low-medium — persistent, cheap to hold (low turnover), but crowded into smart-beta."
tags: [quant/strategy, quant/factor, quant/quality]
created: 2026-07-23
---

# Quality (Profitability) Factor

## Source
- **Novy-Marx (2013)**, "The Other Side of Value: The Gross Profitability Premium." Profitable firms have higher returns despite higher valuations.
- **Asness, Frazzini & Pedersen (2019)**, "Quality Minus Junk" (QMJ): profitability, growth, safety, payout.
- **Sloan (1996)** accruals anomaly (low accruals → higher returns).

## Hypothesis
Rank stocks on a composite quality score — gross profitability (gross profits / assets), earnings stability, low accruals, and (optionally) low leverage. Go long high-quality, short low-quality ("junk"), market-neutral. Quality is defensive: it holds up in drawdowns, complementing momentum.

## Expected edge & decay
- **Edge:** mispricing of profitability (investors chase growth/lottery names, underweight boring profitable firms); limits to arbitrage on shorting junk.
- **Magnitude:** QMJ Sharpe ~0.5–0.8 in the paper; gross-profitability premium several %/yr.
- **Decay:** low-medium — persistent and low-turnover (cheap to hold), but heavily mined into commercial smart-beta.

## Data needed (FREE) — the binding constraint
- Fundamentals: yfinance exposes income-statement/balance-sheet snapshots (gross profit, total assets, net income, equity) but **history is short and point-in-time is absent** → look-ahead bias risk. This is the main reason quality ranks **medium** on implementability.
- Prices: daily OHLCV for returns (yfinance).
- Fallback: price-based proxies (low-vol + low-accrual proxies are hard without statements) — or restrict to a smaller universe with reliable yfinance fundamentals.

## Test design
1. **Universe:** subset of US large caps with ≥5y of yfinance fundamentals, annual/quarterly rebalance.
2. **Signal:** gross profitability = gross profit / total assets; optionally z-score-combine with earnings stability & leverage.
3. **Portfolio:** long top / short bottom tercile, market-neutral, vol-target; also long-only quality tilt.
4. **Point-in-time guard:** only use fundamentals as of their (lagged) report date; lag 3–6 months to avoid look-ahead.
5. **Costs:** 5 bps/side; low turnover so costs minor.
6. **Metrics:** Sharpe, FF5 alpha, drawdown behavior, correlation with momentum (should be low/negative → diversifier).
7. **Robustness:** single-factor (gross profitability) vs composite; vary rebalance frequency.

## Failure modes / risks
- **Look-ahead bias** from non-point-in-time fundamentals → must lag and disclose; likely overstates edge.
- Sparse/short yfinance fundamental history limits universe and sample.
- Quality can lag for years in speculative rallies.

## Links
- Distillation: [[theory-fama-french]] (factor framework / FF5 profitability leg)
- [[Betting-Against-Beta (Low-Volatility)]]
- [[Cross-Sectional Momentum (12-1)]] — low-correlation diversifier
- [[Idiosyncratic (Residual) Momentum]]
- [[Strategies Index]]
