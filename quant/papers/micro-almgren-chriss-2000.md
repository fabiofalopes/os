---
title: "Almgren & Chriss (2000): Optimal Execution of Portfolio Transactions"
authors: [Robert Almgren, Neil Chriss]
year: 2000
type: paper-distillation
domain: microstructure
tags: [microstructure, optimal-execution, market-impact, transaction-costs, twap, vwap, trajectory]
status: distilled
created: 2026-07-23
citekey: almgrenchriss2000
---

# Almgren–Chriss (2000) — Optimal Execution of Portfolio Transactions

Part of [[CANON]]. Sibling notes: [[micro-market-impact]], [[micro-kyle-1985]], [[micro-avellaneda-stoikov-2008]].

## One-liner
The foundational **optimal-execution** framework: liquidate a large position by choosing a trading *trajectory* that balances **permanent + temporary market impact** (cost of trading fast) against **price-risk** (cost of trading slow), producing the **efficient frontier of execution** and the familiar "trade faster when volatile / less risk-averse, slower when impact is high" rule.

## The model
- **Goal:** sell `X` shares over `[0,T]`, choosing holdings trajectory `x(t)` (sell rate `v = −ẋ`).
- **Two impact channels:**
  - **Permanent impact** `g(v)`: each trade moves the fundamental price permanently (information/absorption) — depends on *rate*.
  - **Temporary impact** `h(v)`: a transient displacement you pay only on your own shares this period — also rate-dependent, larger.
- **Price dynamics:** arithmetic random walk with volatility `σ` plus the permanent-impact drift.
- **Objective:** minimize `E[implementation shortfall] + λ · Var[shortfall]` — a mean–variance trade-off over the *trajectory*. `λ` is the trader's risk aversion.

## Key equations
- **Implementation shortfall:** difference between paper return (at decision price) and realized proceeds, net of impact.
- With **linear** impact `g(v)=γv`, `h(v)=ε·sgn(v)+ηv`, the optimal trajectory is a **smooth, front-loaded hyperbolic (sinh) curve**:
  `x(t) = X · sinh(κ(T−t)) / sinh(κT)`, where `κ = sqrt(λ σ² / η)` is the **urgency parameter**.
- **Urgency `κ`:** rises with risk aversion `λ` and volatility `σ`, falls with temporary-impact `η`. High `κ` ⇒ front-loaded / aggressive; low `κ` ⇒ near-uniform (TWAP-like).
- **Efficient frontier:** a curve in (expected cost, std-dev of cost) space; every `λ` picks a point. Pure TWAP = minimum variance-ish; pure "all-at-once" = minimum expected cost but max variance.

## Assumptions
1. **Linear, additive, separable** permanent and temporary impact — impact is a deterministic function of your own rate (no state dependence, no square-root).
2. **Arithmetic Brownian** unaffected price (constant `σ`, no drift/alpha) — you have *no* directional view, only a liquidation task.
3. **No alpha / no signal decay** in the base model — the price is a martingale absent your trading.
4. **Continuous, deterministic** trading; you commit to a trajectory (open-loop), no adaptation to realized prices (the adaptive extension is later work).
5. Single asset, infinite liquidity available at a price, no constraints, no fees beyond impact.

## How it breaks live
- **Impact is not linear.** Empirically **square-root / concave** in size ([[micro-market-impact]]); linear impact mis-sets the urgency and over-penalizes large slices.
- **You usually DO have alpha.** The base model assumes no signal; in practice the single biggest driver of *how* to trade is **signal decay** — if your edge is short-lived you must trade fast regardless of impact. The "optimal" no-alpha trajectory is often wrong for an alpha book.
- **Volatility and impact are regime-dependent and stochastic,** not constant `σ`, `η`; a fixed pre-computed trajectory is stale within minutes. Adaptive / feedback execution (re-solve on the remaining book) is mandatory.
- **Temporary impact recovers, permanent doesn't** — but real transient impact has a *decay kernel* (seconds–minutes) the model collapses into one number; mis-specifying it double-counts or misses recoverable cost.
- **Ignores the book:** liquidity is not infinitely available at a price; walking a thin book, crossing spreads, queue position, and venue fragmentation dominate for any size ([[micro-hft-practitioner]]).
- **Open-loop commitment is exploitable:** a predictable deterministic trajectory (e.g. obvious TWAP) invites front-running / liquidity games.

## Deployable takeaways
- **Separate permanent vs temporary impact in your cost model.** Only permanent impact is a true cost of *being* informed/large; temporary impact is a timing cost you can reduce by slicing. Measure both from your own fills.
- **Trade on an urgency schedule, not a fixed clock.** Compute `κ` from live `σ`, your risk limit, and estimated `η`; front-load when volatility or alpha-decay is high, spread out when impact dominates.
- **Build the efficient frontier for the desk:** present traders a (cost, risk) menu rather than one trajectory; let risk appetite pick the point. This is how sell-side algo suites (VWAP/IS/POV) are actually parameterized.
- **Make it adaptive:** re-solve the remaining trajectory each interval using updated `σ`, impact, and residual alpha — closed-loop beats the open-loop sinh curve materially.
- **Add the alpha term explicitly:** optimal execution with a decaying signal = Almgren–Chriss urgency *plus* a signal-horizon urgency; the binding constraint is usually `max(impact-urgency, alpha-decay-urgency)`.
- **Benchmark honestly:** implementation shortfall vs arrival price is the right P&L lens; VWAP benchmarks hide permanent impact and reward slow trading.

## Connections
- [[micro-market-impact]] — the empirical impact functions (`g`, `h`) this model takes as linear.
- [[micro-kyle-1985]] — permanent impact = Kyle's λ; the information content of your own flow.
- [[micro-avellaneda-stoikov-2008]] — the market-making (inventory *accumulation*) dual to this liquidation problem.
- [[micro-order-flow-toxicity]] — toxicity should raise your urgency / widen the acceptable cost.
- [[micro-hft-practitioner]] — the venue/queue/latency layer beneath the continuous-impact abstraction.
- [[CANON]]

## References
- Almgren, R., & Chriss, N. (2000). "Optimal Execution of Portfolio Transactions." *Journal of Risk* 3: 5–39.
- Almgren, R. (2003) — optimal execution with nonlinear impact.
- Schied, A., Schöneborn, T., & Tehranchi, M. — adaptive / stochastic-control extensions.
- Gatheral, J. & Schied, A. — dynamical market impact / no-dynamic-arbitrage constraints.
