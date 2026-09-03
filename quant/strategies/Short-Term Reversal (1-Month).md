---
title: Short-Term Reversal (1-Month)
type: strategy-hypothesis
category: mean-reversion
status: proposed
data-source: yfinance + ccxt
priority: high
edge: "Past-week/month losers outperform winners over the next week/month; the mirror image of intermediate momentum."
decay: "Medium-high in equities (capacity-constrained, cost-sensitive); robust in crypto at short horizons."
tags: [quant/strategy, quant/mean-reversion]
created: 2026-07-23
---

# Short-Term Reversal (1-Month)

## Source
- **Jegadeesh (1990)** and **Lehmann (1990)** — 1-week/1-month reversals in US equities.
- Liquidity-provision interpretation: **Avramov, Cheng & Hameed (2016)**; reversals compensate liquidity providers.
- Crypto: short-horizon reversal documented in high-frequency crypto studies.

## Hypothesis
Rank a universe by the most recent 1-week to 1-month return. Go long recent losers, short recent winners (contrarian to [[Cross-Sectional Momentum (12-1)]]), holding 1 week to 1 month. The edge is strongest at the extreme tails and after large, likely liquidity-driven moves.

## Expected edge & decay
- **Edge:** temporary price pressure from liquidity demand / overreaction at short horizons; mean reversion of order-flow imbalance.
- **Magnitude:** US equity reversal ~0.5–1%/mo long-short pre-cost; crypto short-horizon reversal often stronger.
- **Decay:** medium-high in equities — gross edge is real but **transaction costs and capacity are the binding constraint** (high turnover). Crypto less decayed but exchange fees/slippage bite.

## Data needed (FREE)
- Equities: daily OHLCV, liquid large caps (yfinance), 10+ years.
- Crypto: hourly/daily OHLCV top ~30 via ccxt.

## Test design
1. **Universe:** liquid equities (300+) and crypto (20–30); weekly rebalance.
2. **Signal:** trailing 5-day / 21-day return; rank into quintiles; long bottom, short top.
3. **Sizing:** market-neutral, vol-target 10%; **turnover is the key variable** — report gross exposure and turnover.
4. **Costs:** realistic and punitive — 5–10 bps/side equities, 5–10 bps crypto; run a cost-sensitivity sweep (edge must survive 10 bps).
5. **Metrics:** net Sharpe, turnover-adjusted return, capacity estimate (ADV-limited AUM).
6. **Conditioning test:** isolate reversal after high-volume / extreme-return days (should be stronger).
7. **Robustness:** horizon sweep (1w/2w/1m); confirm it's not just bid-ask bounce by using mid-to-mid with a 1-day lag.

## Failure modes / risks
- **Costs kill it** at realistic turnover — the #1 failure mode; may only survive as a low-turnover tail-only variant.
- Momentum crashes coincide with reversal working (good diversifier) but reversal can blow up in genuine fundamental repricings.
- Capacity small → not scalable to large AUM.

## Links
- [[Cross-Sectional Momentum (12-1)]] — opposite horizon
- [[Overnight vs Intraday Return Anomaly]]
- [[Pairs Trading (Cointegration)]]
- [[Strategies Index]]
