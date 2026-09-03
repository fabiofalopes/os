---
title: Strategies Index
type: moc
status: living
tags: [quant/strategy, quant/moc]
created: 2026-07-23
updated: 2026-07-23
---

# Strategies Index

Map of Content for testable alpha hypotheses. Each note: source → hypothesis → expected edge & decay → data needed → test design. Prioritized by implementability with **free data** (equities via yfinance, crypto via ccxt).

> Status: seeded from the established anomaly canon (momentum, mean-reversion, carry, low-vol, quality) + practitioner lore. Cross-linked to [[CANON]] and the `quant/papers/` distillations (see "Distillations" links inside each note).

## Grounding in the canon
- Microstructure strategies ([[Avellaneda-Stoikov Crypto Market-Making]], [[Pairs Trading (Cointegration)]]) ← [[microstructure]], [[micro-avellaneda-stoikov-2008]], [[micro-kyle-1985]], [[micro-glosten-milgrom-1985]], [[micro-stat-arb-cointegration]], [[micro-order-flow-toxicity]], [[micro-almgren-chriss-2000]], [[micro-market-impact]].
- Factor/momentum strategies ← [[theory-fama-french]], [[theory-capm]], [[micro-momentum]].
- Volatility strategies ← [[theory-heston]], [[theory-local-vol]], [[theory-risk-parity]].
- Sizing/portfolio construction (shared): [[theory-kelly]], [[theory-markowitz]], [[theory-black-litterman]], [[theory-risk-parity]].

## Priority tiers (free-data implementability)

**Tier 1 — build first (daily OHLCV only, no fundamentals, no paid data):**
- [[Time-Series Momentum (Trend-Following)]] — ccxt + yfinance
- [[Cross-Sectional Momentum (12-1)]] — yfinance
- [[Short-Term Reversal (1-Month)]] — yfinance + ccxt
- [[Betting-Against-Beta (Low-Volatility)]] — yfinance
- [[Crypto Funding-Rate Carry]] — ccxt
- [[Volatility-Managed Portfolios]] — overlay on the above
- [[Avellaneda-Stoikov Crypto Market-Making]] — ccxt L2

**Tier 2 — build next (needs L2/tick, funding history, or term-structure proxies):**
- [[Cash-and-Carry Basis Arbitrage]] — ccxt futures
- [[Overnight vs Intraday Return Anomaly]] — yfinance OHLC + ccxt hourly
- [[Pairs Trading (Cointegration)]] — yfinance + ccxt
- [[Volatility Risk Premium Harvest]] — yfinance (VIX/VIX3M proxy)

**Tier 3 — data-constrained (fundamentals / point-in-time gaps):**
- [[Idiosyncratic (Residual) Momentum]] — needs factor model
- [[Quality (Profitability) Factor]] — needs point-in-time fundamentals

## By category

### Momentum
- [[Time-Series Momentum (Trend-Following)]] — absolute sign-of-return, crisis alpha
- [[Cross-Sectional Momentum (12-1)]] — relative rank, crash-prone
- [[Idiosyncratic (Residual) Momentum]] — factor-stripped, lower-crash

### Mean-reversion
- [[Short-Term Reversal (1-Month)]] — 1w/1m losers beat winners
- [[Pairs Trading (Cointegration)]] — spread z-score, decayed in equities
- [[Overnight vs Intraday Return Anomaly]] — session/funding-time effects

### Factor
- [[Betting-Against-Beta (Low-Volatility)]] — low-vol + leverage
- [[Quality (Profitability) Factor]] — gross profitability, defensive

### Carry
- [[Crypto Funding-Rate Carry]] — delta-neutral funding harvest

### Volatility
- [[Volatility Risk Premium Harvest]] — implied > realized, fat left tail
- [[Volatility-Managed Portfolios]] — inverse-vol scaling overlay

### Market-making / relative value
- [[Avellaneda-Stoikov Crypto Market-Making]] — inventory-skewed quoting
- [[Cash-and-Carry Basis Arbitrage]] — futures contango convergence

## Portfolio-level notes
- **Diversification:** momentum (trend) + carry + market-making are low-correlation; combine before sizing.
- **Universal overlay:** apply [[Volatility-Managed Portfolios]] to every directional strategy.
- **Crash awareness:** [[Cross-Sectional Momentum (12-1)]] and [[Volatility Risk Premium Harvest]] carry left-tail risk → mandatory vol/crash overlays.
- **Cost discipline:** [[Short-Term Reversal (1-Month)]] and [[Pairs Trading (Cointegration)]] are cost-sensitive; require net-of-cost survival.

## Coordination
- Machine-readable list for the backtest/data panes: `~/Projects/trading-agents/quant-research/strategies/HYPOTHESES.md`
- Handoff: Tier-1 hypotheses are ready for the data pane to fetch and the backtest pane to prototype.
