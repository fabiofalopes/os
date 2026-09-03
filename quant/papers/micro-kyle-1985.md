---
title: "Kyle (1985): Continuous Auctions and Insider Trading"
authors: [Albert S. Kyle]
year: 1985
type: paper-distillation
domain: microstructure
tags: [microstructure, market-impact, informed-trading, adverse-selection, kyle-lambda, price-discovery]
status: distilled
created: 2026-07-23
citekey: kyle1985
---

# Kyle (1985) — Continuous Auctions and Insider Trading

Part of [[CANON]]. Sibling notes: [[micro-glosten-milgrom-1985]], [[micro-market-impact]], [[micro-almgren-chriss-2000]].

## One-liner
A single strategic insider hides his information inside noise order flow; the market maker sets price from net order flow, and the equilibrium **price-impact coefficient λ ("Kyle's lambda")** measures how much prices move per unit of net order — the canonical, structural definition of *illiquidity* and *permanent market impact*.

## The model
- **Players:** one risk-neutral informed trader (knows asset value `v`), noise/uninformed traders submitting exogenous order `u ~ N(0, σ_u²)`, and a competitive risk-neutral market maker who observes only total order flow `y = x + u` and sets price `p = E[v | y]`.
- **Timing (single-auction version):** insider picks his order `x` to maximize `E[x(v − p)]`, knowing the market maker will infer from `y`. In the unique linear equilibrium:
  - Insider trades `x = β (v − p₀)`, scaling his position to his information edge.
  - Market maker sets `p = p₀ + λ y`.
- **Continuous-time version (Kyle 1985 §4):** the insider spreads trading smoothly over `[0,1]`; noise flow is Brownian. Price is a martingale that converges to `v` by the terminal date; the insider trades at a *constant rate* and earns half his information rent.

## Key equations
- **Kyle's lambda (price impact):** `λ = σ_v / (2 σ_u)` — impact rises with fundamental uncertainty `σ_v` and *falls* with more noise trading `σ_u`.
- Insider optimal intensity: `β = σ_u / σ_v = 1/(2λ)`.
- Insider expected profit: `½ σ_v σ_u` — the value of private information is proportional to noise-trading volume.
- **Variance decomposition:** noise flow masks the insider; the market maker's posterior variance shrinks linearly in time, and `Var(v|y) → 0` as `t → 1` (full revelation at the end).

## Assumptions
1. **One** informed trader (monopoly on information) — no competition among insiders.
2. Noise order is **exogenous, inelastic, Gaussian** — the classic "greater fool" liquidity source; noise traders don't react to price.
3. Market maker is **risk-neutral and competitive** → zero expected profit, prices at conditional expectation (Bayesian, no inventory aversion).
4. **Gaussian fundamentals** → linear equilibrium; the signal structure is what makes everything closed-form.
5. No adverse-selection from *multiple* sources; no inventory constraints; no latency; continuous, frictionless clearing.

## How it breaks live
- **λ is not constant.** Empirically impact is **concave/square-root** in order size ([[micro-market-impact]]), not the linear `Δp = λ y` Kyle assumes. Linear λ overstates the cost of large orders and understates small ones.
- **Information is not monopolized.** Real alpha decays as many agents trade correlated signals; the "single insider" rent gets competed away fast — a live strategy's edge half-life is usually minutes-to-days, not a fixed auction.
- **Noise isn't exogenous.** Uninformed flow is partly endogenous (rebalancers, index funds, hedgers) and partly *other informed* flow; `σ_u` is regime-dependent and collapses in stress, so λ **spikes exactly when you need liquidity**.
- **Market makers are inventory- and capital-constrained**, not risk-neutral ([[micro-avellaneda-stoikov-2008]]); they widen and skew quotes, breaking the `p = E[v|y]` martingale.
- **Adverse selection is multi-source and dynamic** — Glosten–Milgrom's sequential framing ([[micro-glosten-milgrom-1985]]) fits limit-order books better than Kyle's batch auction.

## Deployable takeaways
- **Measure your own λ.** Regress intra-bar returns on signed net order flow to estimate realized impact; use it as a live *liquidity/illiquidity* gauge and a capacity ceiling for the book.
- **λ as a regime filter:** rising λ ⇒ adverse selection is up, market makers are scared ⇒ cut size, widen required edge. This is the structural cousin of [[micro-order-flow-toxicity]].
- **Trade like the insider: split and hide.** The optimal informed strategy is to camouflage inside noise — the theoretical root of order-splitting / TWAP / iceberg execution ([[micro-almgren-chriss-2000]]). Your *urgency* should scale with edge and inversely with impact.
- **Capacity rule of thumb:** a strategy's capacity scales with the noise volume it can hide in (`σ_u`). Thin names / off-hours = low `σ_u` = high λ = low capacity.
- **Price discovery is gradual:** expect your signal to be only partially incorporated while you trade; residual drift after execution is the footprint others can harvest (see [[micro-momentum]]).

## Connections
- [[micro-glosten-milgrom-1985]] — sequential adverse selection; the *spread* counterpart to Kyle's *impact*.
- [[micro-market-impact]] — empirical square-root law vs Kyle's linear λ.
- [[micro-almgren-chriss-2000]] — optimal execution internalizes a Kyle-style permanent-impact term.
- [[micro-avellaneda-stoikov-2008]] — market-maker side; inventory risk layered on adverse selection.
- [[micro-order-flow-toxicity]] — real-time estimation of the informed-flow probability Kyle takes as given.
- [[CANON]]

## References
- Kyle, A. S. (1985). "Continuous Auctions and Insider Trading." *Econometrica* 53(6): 1315–1335.
- Kyle, A. S. (1985) — multi-auction and continuous-time extensions in the same paper.
- Empirical λ: Amihud (2002) illiquidity ratio as a daily proxy; Hasbrouck (2009) on trading and information.
