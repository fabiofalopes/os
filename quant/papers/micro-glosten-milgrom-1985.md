---
title: "Glosten & Milgrom (1985): Bid, Ask and Transaction Prices"
authors: [Lawrence R. Glosten, Paul R. Milgrom]
year: 1985
type: paper-distillation
domain: microstructure
tags: [microstructure, adverse-selection, bid-ask-spread, market-making, sequential-trade, information]
status: distilled
created: 2026-07-23
citekey: glostenmilgrom1985
---

# Glosten–Milgrom (1985) — Bid, Ask and Transaction Prices

Part of [[CANON]]. Sibling notes: [[micro-kyle-1985]], [[micro-avellaneda-stoikov-2008]], [[micro-order-flow-toxicity]].

## One-liner
A **sequential-trade** model in which a competitive market maker posts bid/ask quotes facing a mix of informed and uninformed traders; the **bid-ask spread is the compensation for adverse selection** — the dealer must recover losses to informed traders from the spread paid by liquidity (uninformed) traders.

## The model
- **Setup:** asset value `v ∈ {v_L, v_H}`. Traders arrive one at a time; a fraction `μ` are **informed** (know `v`), the rest are **liquidity/uninformed** traders who buy or sell for exogenous reasons with equal probability.
- The market maker cannot tell informed from uninformed, observes only the *direction* of the trade, and updates beliefs via Bayes after each trade.
- He posts `bid = E[v | sell]` and `ask = E[v | buy]`. Because a buy is more likely when `v = v_H`, `ask > E[v] > bid`.
- **Zero-profit condition:** expected spread revenue from liquidity traders exactly offsets expected losses to informed traders. The spread is *endogenous* to the informed fraction `μ`.

## Key equations
- `ask = E[v | buy] = Pr(v_H | buy)·v_H + Pr(v_L | buy)·v_L`, and symmetrically for `bid`.
- **Spread widens in the informed fraction:** `∂(ask − bid)/∂μ > 0`. More adverse selection ⇒ wider quotes.
- **Learning:** each trade moves the posterior; as the sequence of buys/sells accumulates, the quote drifts toward the true `v` (prices are a **martingale** and a Bayesian sufficient statistic).
- Half-spread ≈ `μ · (distance of v from prior)` weighted by the probability a trade is informed — the adverse-selection component of the spread.

## Assumptions
1. **Discrete value** (two states) and **discrete, unit-size** orders — no size information in a trade.
2. **Competitive, risk-neutral** market maker who prices at conditional expectation (no inventory aversion, no capital constraint).
3. Informed fraction `μ` is **constant and known**; informed always trade the "right" direction, liquidity traders are directionally random.
4. **Sequential** arrivals; the specialist is a monopolist quote-setter but earns zero expected profit from competition.
5. No order-splitting, no hidden orders, no latency, no multi-asset.

## How it breaks live
- **Spread ≠ only adverse selection.** Real spreads also carry **inventory** and **fixed-order-processing** components (Stoll decomposition); in liquid names the adverse-selection share can be small, and in HFT it's dominated by queue position and latency, not Bayesian learning.
- **Size and order type carry information** the model ignores: large marketable orders, iceberg detection, and order-book imbalance are strong signals ([[micro-market-impact]], [[micro-order-flow-toxicity]]).
- **μ is regime-dependent and unobserved.** Toxicity spikes in news/stress and collapses in calm; a fixed-`μ` quote is systematically too tight before events and too wide after.
- **Dealers are not risk-neutral.** Inventory accumulation forces quote skewing and widening ([[micro-avellaneda-stoikov-2008]]), and capital/regulatory constraints make supply of immediacy elastic.
- **Multiple competing venues / HFT** turn the "monopolist specialist" into a latency race; the Bayesian-learning timescale (seconds–minutes) is far slower than quote updates (microseconds).

## Deployable takeaways
- **Decompose the spread** you face into adverse-selection vs inventory vs processing; only the adverse-selection part is *permanent* cost, the rest is (partly) recoverable. This is the conceptual basis of the **roll model** and trade-classification (Lee–Ready, BVC).
- **Quote skew = belief update.** When the book skews (bid lifted repeatedly), treat it as the market maker's posterior moving — a short-horizon directional signal (order-flow imbalance → next-tick drift).
- **Widen required edge when toxicity is up:** if estimated informed fraction rises (see [[micro-order-flow-toxicity]]), demand more spread to provide liquidity, or stand aside.
- **Liquidity provision is a cross-subsidy business:** you profit from uninformed flow and lose to informed flow; your P&L is a *classification* problem — get better at telling noise from signal, not at predicting direction.
- **Martingale caution:** because prices are a martingale under the model, *pure* liquidity provision has no directional edge — any persistent drift you capture is a model violation (inventory premia, toxicity mispricing) and should be explicitly modeled, not assumed.

## Connections
- [[micro-kyle-1985]] — batch-auction / strategic-insider counterpart; impact (λ) vs spread.
- [[micro-avellaneda-stoikov-2008]] — adds inventory risk to the adverse-selection dealer.
- [[micro-order-flow-toxicity]] — operationalizes the informed-trader probability `μ` in real time (PIN, VPIN).
- [[micro-market-impact]] — permanent impact as the footprint of the Bayesian learning here.
- [[micro-hft-practitioner]] — how modern market making actually earns (queue, latency, rebates) vs this textbook picture.
- [[CANON]]

## References
- Glosten, L. R., & Milgrom, P. R. (1985). "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders." *Journal of Financial Economics* 14(1): 71–100.
- Roll, R. (1984) — effective spread from serial covariance (the empirical cousin).
- Stoll, H. (1989) — decomposition of the spread into order-processing, inventory, adverse-selection.
