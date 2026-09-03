---
title: Crypto Funding-Rate Carry
type: strategy-hypothesis
category: carry
status: proposed
data-source: ccxt
priority: high
edge: "Perpetual funding rates are usually positive (longs pay shorts); delta-neutral short-perp/long-spot harvests carry."
decay: "Medium — structural in bull markets, compresses/can invert in bear; crowded but still a core crypto carry trade."
tags: [quant/strategy, quant/carry, quant/crypto]
created: 2026-07-23
---

# Crypto Funding-Rate Carry

## Source
- Crypto-native extension of the **carry** factor: **Koijen, Moskowitz, Pedersen & van Nieuwerburgh (2018)**, "Value and Momentum Everywhere" / carry across asset classes.
- Practitioner lore: perpetual-swap funding as the crypto "interest rate"; cash-and-carry / basis trade.
- Microstructure: funding mechanism keeps perp price near spot (see [[Cash-and-Carry Basis Arbitrage]]).

## Hypothesis
Perpetual futures charge/pay a funding rate (typically every 8h) to tether perp price to spot. In net-long-sentiment markets funding is positive, so a **delta-neutral** position — long spot, short the perpetual — collects funding while hedged against price. Rank assets by expected funding and allocate carry across the highest-paying, most-liquid names.

## Expected edge & decay
- **Edge:** persistent speculative long demand pays a premium to liquidity providers / hedgers; a carry risk premium.
- **Magnitude:** annualized funding carry often 5–30% in bull regimes, near 0 or negative in bear/chop.
- **Decay:** medium — structural while retail leverage is long-biased; compresses sharply in risk-off and can invert (shorts pay). Crowded but remains a foundational crypto income stream.

## Data needed (FREE)
- Funding rate history (8h) + perp & spot OHLCV via **ccxt** (Binance/Bybit/OKX expose funding history).
- Order book depth for execution/slippage estimates.

## Test design
1. **Universe:** top ~15–20 liquid perpetuals, 3+ years of 8h funding history.
2. **Signal:** trailing mean funding as predictor; long-spot/short-perp when expected funding > threshold; optionally rank and pick top-N.
3. **Delta-neutral construction:** verify hedge (spot long = perp short notional); measure residual basis risk.
4. **Costs:** perp taker/maker fees + spot fees + **funding paid on the short leg is the income, not a cost**; include slippage and roll.
5. **Metrics:** annualized carry, Sharpe, % of periods with positive funding, drawdown when funding inverts, basis-tracking error.
6. **Regime test:** decompose returns by bull/bear/chop; confirm the strategy de-risks (goes flat) when funding ≤ 0.
7. **Robustness:** cross-exchange funding consistency; threshold sweep; capacity vs depth.

## Failure modes / risks
- **Funding inversion** in bear markets → strategy must flatten or flip; holding through inversion bleeds.
- Exchange/counterparty risk, auto-deleveraging (ADL), and liquidation of the short leg if not margined.
- Basis can gap on extreme volatility despite delta-neutrality.

## Links
- [[Cash-and-Carry Basis Arbitrage]]
- [[Avellaneda-Stoikov Crypto Market-Making]]
- [[Time-Series Momentum (Trend-Following)]] — diversifying directional overlay
- [[Strategies Index]]
