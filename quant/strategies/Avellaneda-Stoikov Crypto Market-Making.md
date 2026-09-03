---
title: Avellaneda-Stoikov Crypto Market-Making
type: strategy-hypothesis
category: market-making
status: proposed
data-source: ccxt
priority: high
edge: "Quote two-sided around mid with inventory-skewed reserves; capture spread + maker rebates while controlling inventory risk."
decay: "Low — structural spread/rebate income, but competition and adverse selection compress margins; execution quality is everything."
tags: [quant/strategy, quant/market-making, quant/crypto, quant/microstructure]
created: 2026-07-23
---

# Avellaneda-Stoikov Crypto Market-Making

## Source
- **Avellaneda & Stoikov (2008)**, "High-Frequency Trading in a Limit Order Book." Optimal reservation price (inventory-skewed) and optimal spread given risk aversion γ and order-arrival intensity.
- Practitioner: crypto maker rebates + wide spreads on alt pairs; inventory management is the core skill.
- Microstructure: **Glosten-Milgrom** adverse selection (informed flow picks off stale quotes).

## Hypothesis
On liquid crypto pairs, a two-sided quoting strategy — placing bid/ask around a reservation price that shifts with inventory (Avellaneda-Stoikov) — captures the bid-ask spread and maker rebates while keeping inventory bounded. The reservation price = mid − q·γ·σ²·(T−t), pulling quotes toward reducing inventory. Edge is spread capture net of adverse-selection losses.

## Expected edge & decay
- **Edge:** earn the spread + maker rebate by providing liquidity; inventory-skewing prevents toxic accumulation.
- **Magnitude:** per-trade edge small (bps) but high frequency; profitable on wide-spread alt pairs with rebates.
- **Decay:** low as a structural income stream, but margins compress with competition; **adverse selection** (getting run over in trends) is the main leak, not signal decay.

## Data needed (FREE)
- L2 order book snapshots + trades via **ccxt** (Binance/Bybit) — top-of-book and depth.
- Maker/taker fee schedule + rebate info per venue.
- Recent trade history to estimate order-arrival intensity and short-horizon σ.

## Test design
1. **Simulation:** event-driven LOB replay on 1–3 liquid crypto pairs, 3–6 months of book data (or fetch-and-log live for a pilot).
2. **Model:** Avellaneda-Stoikov reservation price + optimal spread; parameters γ (risk aversion), inventory cap, quote refresh interval.
3. **Fill model:** conservative — assume adverse selection (filled when price moves against you); use empirical queue position / fill probability.
4. **Costs:** maker fees/rebates, taker fees for hedging inventory, latency assumptions.
5. **Metrics:** PnL per day, Sharpe, inventory distribution, fill rate, adverse-selection cost, quote time-in-book.
6. **Robustness:** vary γ, spread, inventory cap; test in trending vs mean-reverting regimes (trending = worst case).
7. **Pilot:** paper-trade live via ccxt before any capital; validate fill model against reality.

## Failure modes / risks
- **Adverse selection** — being picked off by informed/trend flow; the dominant risk. Requires fast requoting and inventory limits.
- Exchange risk: latency, order cancellation, fee changes, API limits.
- Inventory blowup in one-way markets → hard inventory cap + delta hedging mandatory.
- Needs low-latency execution; daily-bar backtests overstate viability → must use tick/LOB data.

## Links
- Distillations: [[micro-avellaneda-stoikov-2008]] (the model), [[micro-glosten-milgrom-1985]] & [[micro-kyle-1985]] (adverse selection), [[micro-order-flow-toxicity]] (VPIN/toxicity filter), [[micro-almgren-chriss-2000]] & [[micro-market-impact]] (execution/impact cost), [[microstructure]] (overview)
- [[Overnight vs Intraday Return Anomaly]] — intraday edge source
- [[Crypto Funding-Rate Carry]] — complementary income stream
- [[Cash-and-Carry Basis Arbitrage]]
- [[Strategies Index]]
