---
title: Volatility Risk Premium Harvest
type: strategy-hypothesis
category: volatility
status: proposed
data-source: yfinance
priority: medium
edge: "Implied vol usually exceeds realized vol; systematically short vol (via VIX term structure / short-vol proxies) harvests a premium — with fat left tail."
decay: "Low-medium — persistent premium but the tail risk IS the cost; crowding makes crashes sharper."
tags: [quant/strategy, quant/volatility, quant/vrp]
created: 2026-07-23
---

# Volatility Risk Premium Harvest

## Source
- **Carr & Wu (2009)** variance swaps; **Coval & Shumway (2001)** expected vs realized returns on VIX-linked options.
- Practitioner: the volatility risk premium (VRP) — implied vol > realized vol on average; short-vol as "picking up nickels in front of a steamroller."
- VIX term structure: contango (front < back) is the carry a short-vol position earns.

## Hypothesis
Implied volatility systematically exceeds subsequent realized volatility (the VRP), reflecting demand for downside insurance. A strategy that is structurally short volatility — proxied free-of-options via the **VIX futures term structure** (short front / long back, or short VIX when term structure is in contango) — earns positive carry in calm regimes. The premium is the compensation for bearing crash risk.

## Expected edge & decay
- **Edge:** insurance premium paid by hedgers; behavioral overestimation of crash probability.
- **Magnitude:** VRP averages several vol-points/yr; short-vol carry strategies Sharpe ~0.5–1.0 **until** they crash.
- **Decay:** low-medium as a premium (persistent), but the true "cost" is episodic — the strategy gives back months of carry in days during vol spikes (Feb 2018 "Volmageddon"). Crowding sharpens these crashes.

## Data needed (FREE) — constraint
- `^VIX` and `^VIX3M` (VIX of VIX / 3-month) via yfinance as a **term-structure proxy** (VIX < VIX3M ≈ contango). True VIX futures front/back series are NOT free → use the VIX/VIX3M ratio as the signal and be explicit it's a proxy.
- SPY daily for realized-vol computation and regime context.

## Test design
1. **Signal:** contango indicator = (^VIX < ^VIX3M). Long a short-vol proxy (e.g., inverse-VIX exposure / short ^VIX futures roll) when contango; flat in backwardation.
2. **VRP measurement:** compute realized 20d vol of SPY vs ^VIX level; quantify the average implied-minus-realized spread (the premium itself).
3. **Proxy strategy:** since free VIX futures are unavailable, simulate a daily short-VIX-when-contango position with a vol-of-vol stop; report it as a **proxy backtest, not a tradable strategy**.
4. **Costs/roll:** model futures roll cost conceptually; note that real execution needs VIX futures data (paid).
5. **Metrics:** Sharpe, **max DD and worst-day return** (the key stats), % time in contango, carry vs crash decomposition.
6. **Tail analysis:** explicitly report drawdown during 2018-02, 2020-03, 2022 vol spikes.
7. **Robustness:** threshold on term-structure slope; add a trend/vol-stop overlay to cut the left tail.

## Failure modes / risks
- **Left-tail blowups** are the defining risk — Sharpe flatters; max DD tells the truth.
- Free data lacks actual VIX futures → this is a proxy/feasibility study; real deployment needs futures data + options.
- Crowding amplifies crashes (Volmageddon).

## Links
- Distillations: [[theory-heston]] & [[theory-local-vol]] (stochastic-vol / IV-vs-RV framing)
- [[Volatility-Managed Portfolios]] — uses realized vol, complementary
- [[Betting-Against-Beta (Low-Volatility)]]
- [[Strategies Index]]
