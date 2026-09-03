---
title: "Avellaneda & Stoikov (2008): High-Frequency Trading in a Limit Order Book"
authors: [Marco Avellaneda, Sasha Stoikov]
year: 2008
type: paper-distillation
domain: microstructure
tags: [microstructure, market-making, limit-order-book, inventory-risk, optimal-quotes, avellaneda-stoikov]
status: distilled
created: 2026-07-23
citekey: avellanedastoikov2008
---

# Avellaneda–Stoikov (2008) — High-Frequency Trading in a Limit Order Book

Part of [[CANON]]. Sibling notes: [[micro-glosten-milgrom-1985]], [[micro-kyle-1985]], [[micro-hft-practitioner]].

## One-liner
A **closed-form optimal market-making** policy: a risk-averse dealer posting bid/ask around a **reservation (indifference) price** that is *skewed away from inventory*, with an **optimal spread** that trades off fill probability against adverse selection — the foundational model behind most modern quantitative market making.

## The model
- **State:** mid-price `S_t` follows arithmetic Brownian motion `dS = σ dW`; the market maker holds inventory `q` and posts bid/ask quotes at distances `δ^b, δ^a` from the mid.
- **Fills:** order arrivals are modeled as **Poisson processes** with intensity `λ(δ) = A exp(−k δ)` — the farther your quote from the mid, the lower the fill probability (an empirical fill-probability law).
- **Objective:** maximize expected utility of terminal wealth with **CARA** (constant absolute risk aversion `γ`) over horizon `T` — i.e. the dealer *dislikes inventory*.
- Solve the HJB equation → reservation price and optimal spread.

## Key equations
- **Reservation (indifference) price:**
  `r(s, q, t) = s − q · γ σ² (T − t)`
  — skew quotes *against* inventory; the penalty grows with risk aversion `γ`, variance `σ²`, position `q`, and remaining time.
- **Optimal spread (around the reservation price):**
  `δ^a + δ^b = γ σ² (T − t) + (2/γ) ln(1 + γ/k)`
  — a **risk-aversion/variance term** (widen when volatile or near horizon) plus an **adverse-selection/fill-elasticity term** `(2/γ) ln(1 + γ/k)` (widen when fills are insensitive to distance, i.e. small `k`).
- Quotes are placed at `r ± δ/2`, so the *quoted mid* is displaced from the raw mid by the inventory skew.

## Assumptions
1. **Arithmetic Brownian mid** (no drift, constant `σ`) — no jumps, no mean reversion, no trends.
2. **Exponential (Poisson) fill intensity** `A e^{−kδ}` — a stylized, stationary fill law; `k` constant.
3. **CARA utility + fixed horizon** — the dealer must flatten by `T`; risk aversion is constant.
4. **Symmetric two-sided** quoting; no queue position, no adverse selection *beyond* what the fill intensity encodes, no latency, single asset, no fees/rebates.
5. You are a **price-taker in fill probability** — your quotes don't move the mid.

## How it breaks live
- **Fill intensity is not stationary or exponential.** `k` varies with volatility regime, time of day, and *your queue position*; queue-reactive and self-exciting (Hawkes) fills beat the memoryless Poisson assumption.
- **Adverse selection is under-modeled.** The model folds toxicity into `k`, but informed flow is directional and event-driven ([[micro-order-flow-toxicity]]); a symmetric policy gets picked off one-sidedly into news.
- **ABM mid is wrong on relevant horizons.** Real mids mean-revert at short horizons and trend at longer ones ([[micro-momentum]]); the `σ²(T−t)` inventory penalty is miscalibrated if `σ` is regime-switching.
- **Fixed-horizon flattening is a fiction.** Live books carry inventory across sessions; the terminal dump creates predictable end-of-day behavior others exploit.
- **Ignores the microstructure that actually drives HFT P&L:** queue position, maker/taker fees and rebates, cross-venue fragmentation, and latency ([[micro-hft-practitioner]]). Backtests without queue simulation and fees overstate MM returns by multiples.
- **Inventory risk ≠ the only risk.** Correlated multi-asset inventory, funding, and gap/jump risk (overnight, news) are absent — the Gaussian `σ²` term badly understates tail inventory cost.

## Deployable takeaways
- **Skew by inventory, always.** The single most robust live rule: shift your quoted mid by `−γ σ² (T−t) q`. It is a principled, bounded alternative to naive "flatten when too big."
- **Widen spread with volatility and toxicity:** scale the spread term by realized `σ` and by an online toxicity estimate ([[micro-order-flow-toxicity]]); pull quotes in calm, widen and skew in stress.
- **Calibrate `k` (fill elasticity) empirically** per name and regime from your own fill data — it sets the spread and is the single most impactful parameter; re-estimate intraday.
- **Treat the reservation price as your fair value,** not the raw mid: base signals and hedges on `r`, so inventory cost is internalized in every decision.
- **Use it as the skeleton, not the whole body:** layer queue-position-aware fill models, fee/rebate economics, and a toxicity gate on top of the A–S core. It is the *baseline* every serious MM stack starts from.

## Connections
- [[micro-glosten-milgrom-1985]] — the adverse-selection spread A–S partially encodes via fill intensity.
- [[micro-kyle-1985]] — permanent impact / λ as the cost the MM absorbs from informed flow.
- [[micro-order-flow-toxicity]] — real-time gate that should modulate A–S spread and skew.
- [[micro-hft-practitioner]] — the queue/latency/fee realities A–S abstracts away.
- [[micro-almgren-chriss-2000]] — inventory-liquidation view; A–S is the *accumulation/management* dual.
- [[CANON]]

## References
- Avellaneda, M., & Stoikov, S. (2008). "High-Frequency Trading in a Limit Order Book." *Quantitative Finance* 8(3): 217–224.
- Guéant, O., Lehalle, C.-A., & Fernandez-Tapia, J. (2012) — multi-asset / discrete-quote extensions.
- Fodra, P. & Labadie, M. — Hawkes-process fill-intensity extensions.
