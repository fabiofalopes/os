---
title: Volatility-Managed Portfolios
type: strategy-hypothesis
category: volatility
status: proposed
data-source: yfinance
priority: high
edge: "Scaling exposure inversely by recent realized vol improves Sharpe for many factors/strategies — a universal overlay, not a standalone signal."
decay: "Low — a risk-management overlay; robust and cheap, but gains are modest and depend on vol predictability."
tags: [quant/strategy, quant/volatility, quant/risk]
created: 2026-07-23
---

# Volatility-Managed Portfolios

## Source
- **Moreira & Muir (2017)**, "Volatility-Managed Portfolios." Scaling factor exposure by 1/(past-month realized variance) raises Sharpe and alpha across value, momentum, profitability, market.
- Related: volatility targeting / risk parity practitioner literature; **Fleming, Kirby & Ostdiek (2001)** volatility timing.

## Hypothesis
Recent realized volatility predicts near-future volatility (vol clustering). Scaling any portfolio's gross exposure inversely by its trailing realized variance — taking MORE risk after calm periods and LESS after volatile ones — improves the Sharpe ratio without needing return forecasts. This is an **overlay** applicable to [[Cross-Sectional Momentum (12-1)]], factors, and trend strategies.

## Expected edge & decay
- **Edge:** vol is predictable even when returns aren't; inverse-vol scaling harvests the volatility-timing component and dampens drawdowns.
- **Magnitude:** Moreira-Muir report Sharpe improvements of ~0.2–0.5 across factors; DD reduction meaningful.
- **Decay:** low — it's risk management, not an arbitraged signal; robust across regimes. Gains are modest and vanish if vol stops being persistent.

## Data needed (FREE)
- Daily OHLCV for the underlying strategy assets (yfinance/ccxt) — whatever the base strategy uses.
- Just need returns to compute rolling realized variance; no fundamentals.

## Test design
1. **Base strategies:** apply the overlay to 2–3 existing hypotheses (e.g., momentum, BAB, TSMOM) as the test bed.
2. **Signal:** trailing 21-day realized variance; scale gross exposure to target constant variance (e.g., c / σ²_past, capped at 2x leverage).
3. **A/B:** identical base strategy with vs. without vol scaling — compare Sharpe, Sortino, max DD, and alpha.
4. **Leverage cap:** impose a realistic max (e.g., 1.5–2x) and a financing cost on leverage.
5. **Metrics:** Δ Sharpe, Δ max DD, turnover added by scaling, leverage utilization.
6. **Robustness:** vary vol window (10/21/63d) and target; confirm improvement isn't window-specific.
7. **Sanity:** confirm the overlay helps in high-vol regimes (2008, 2020) and doesn't just add leverage in calm ones.

## Failure modes / risks
- Requires leverage to scale UP in calm periods → financing cost and margin-call risk.
- Vol can gap up faster than the lookback reacts (whipsaw at regime breaks).
- Modest standalone value — best framed as a mandatory overlay on the team's other strategies, not a standalone PnL line.

## Links
- Distillation: [[theory-risk-parity]] (vol-scaling / risk-budgeting foundation)
- [[Cross-Sectional Momentum (12-1)]] — primary test bed (crash reduction)
- [[Time-Series Momentum (Trend-Following)]]
- [[Volatility Risk Premium Harvest]]
- [[Strategies Index]]
