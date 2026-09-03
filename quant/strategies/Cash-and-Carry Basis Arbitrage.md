---
title: Cash-and-Carry Basis Arbitrage
type: strategy-hypothesis
category: market-making
status: proposed
data-source: ccxt
priority: medium
edge: "Dated futures trade at a premium (contango) to spot; long spot + short future locks a near-riskless annualized basis that converges at expiry."
decay: "Low — structural and near-arbitrage, but capital-inefficient and compressed in bear markets; execution/funding frictions matter."
tags: [quant/strategy, quant/market-making, quant/crypto, quant/relative-value]
created: 2026-07-23
---

# Cash-and-Carry Basis Arbitrage

## Source
- Classic cost-of-carry / cash-and-carry arbitrage (textbook futures pricing: F = S·e^{(r+carry)T}).
- Crypto practitioner: the **basis trade** — BTC/ETH quarterly futures historically trade in steep contango; long spot / short future locks an annualized yield.
- Relative to [[Pairs Trading (Cointegration)]]: this is the less-decayed, convergence-at-expiry relative-value trade.

## Hypothesis
Crypto dated (quarterly) futures frequently trade above spot (contango) due to structural long demand and funding costs. Buying spot and shorting the equivalent-dated future locks the basis, which **must converge to zero at expiry** — a near-risk-free annualized return if held to delivery. Rotate into the tenor/exchange offering the richest basis.

## Expected edge & decay
- **Edge:** locked convergence + contango carry; close to arbitrage (only basis risk until expiry, which vanishes at settlement).
- **Magnitude:** annualized basis historically 5–20% in bull markets, near 0 or backwardated in bear.
- **Decay:** low structurally (convergence is mechanical), but the *level* of contango is regime-dependent; capital-inefficient and crowded.

## Data needed (FREE)
- Spot + dated-futures (or perpetual) OHLCV via **ccxt** (Binance/Bybit/Deribit) to compute the basis = F/S − 1 annualized.
- Funding rates for the perp alternative; fee schedules.

## Test design
1. **Measure:** compute annualized basis for BTC/ETH quarterly futures vs spot over 3+ years; characterize distribution by regime.
2. **Strategy:** enter when annualized basis > threshold (e.g., >8%); long spot / short future; hold to expiry (or roll); exit early if basis collapses.
3. **Capital efficiency:** model margin required on the short future leg + spot funding; compute return-on-margin, not just return-on-notional.
4. **Costs:** spot + futures fees, roll slippage, funding on margin.
5. **Metrics:** annualized locked yield, Sharpe, % time basis is attractive, drawdown from mark-to-market basis widening before expiry.
6. **Regime test:** bull vs bear decomposition; confirm strategy goes flat when basis ≤ threshold.
7. **Robustness:** perp-funding variant (see [[Crypto Funding-Rate Carry]]) vs dated-futures variant compared on risk-adjusted basis.

## Failure modes / risks
- **Margin/liquidation risk** on the short future leg if basis widens before convergence — needs buffer capital.
- Exchange/counterparty risk and delivery/settlement mechanics.
- Opportunity cost of capital in low-basis regimes; backwardation produces negative carry.

## Links
- [[Crypto Funding-Rate Carry]] — perpetual-funding sibling
- [[Pairs Trading (Cointegration)]] — relative-value ancestor
- [[Avellaneda-Stoikov Crypto Market-Making]]
- [[Strategies Index]]
