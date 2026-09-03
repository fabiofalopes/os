---
title: "Stat-Arb & Cointegration: Engle–Granger (1987) & Gatev Pairs Trading (2006)"
authors: [Robert Engle, Clive Granger, Evan Gatev, William Goetzmann, K. Geert Rouwenhorst]
year: 1987
type: paper-distillation
domain: microstructure
tags: [statistical-arbitrage, cointegration, pairs-trading, mean-reversion, engle-granger, spread, risk]
status: distilled
created: 2026-07-23
citekey: statarb
---

# Stat-Arb & Cointegration — Engle–Granger (1987) & Gatev Pairs (2006)

Part of [[CANON]]. Sibling notes: [[micro-momentum]], [[micro-market-impact]], [[micro-hft-practitioner]].

## One-liner
Two prices can each wander non-stationarily yet a **linear combination (the spread) is stationary** — that's **cointegration**, the statistical foundation of pairs/stat-arb. Gatev–Goetzmann–Rouwenhorst showed a simple **distance-method pairs strategy** (open when the normalized spread diverges ≥ 2σ, close at zero) earned ~11%/yr historically — a canonical **mean-reversion** strategy that is the horizon-complement to [[micro-momentum]].

## The models
- **Cointegration (Engle–Granger 1987):** if `x_t, y_t` are each `I(1)` (unit-root, non-stationary) but `z_t = y_t − β x_t` is `I(0)` (stationary), they are **cointegrated** with vector `(1, −β)` — a genuine long-run equilibrium relation, not a spurious regression.
  - **Two-step test:** (1) regress `y` on `x`, get residuals `ẑ`; (2) run an ADF unit-root test on `ẑ`. Reject unit root ⇒ cointegrated.
  - **Error-correction:** short-run dynamics pull the spread back: `Δy_t = α (y_{t−1} − β x_{t−1}) + ...` where `α < 0` is the **mean-reversion speed**.
- **Pairs trading (Gatev, Goetzmann, Rouwenhorst 2006):** "distance method" — over a formation period, find stock pairs with minimum **squared distance** between normalized price paths; in the trading period, open a position when the spread exceeds **2 standard deviations**, close when it crosses zero. Self-financing, market-neutral.

## Key equations
- **Spread:** `z_t = y_t − β x_t`, with `β` from the cointegrating regression (or Kalman filter for a time-varying hedge ratio).
- **Cointegration test:** ADF on residuals `Δẑ_t = ρ ẑ_{t−1} + Σ γ_i Δẑ_{t−i} + ε`; reject `ρ = 0` ⇒ stationary spread.
- **Half-life of mean reversion:** from AR(1) `z_t = φ z_{t−1} + ε`, `half-life = −ln(2)/ln(φ)` — the natural holding horizon.
- **Trading rule:** enter at `|z_t/σ_z| ≥ 2`, exit near `0`, stop if the spread keeps diverging (the relation broke).

## Assumptions
1. **The cointegrating relation is stable** — `β` and the mean-reversion speed don't structurally shift. (They do: M&A, regime change, business-model divergence.)
2. **Stationarity of the spread** estimated in-sample persists out-of-sample — a classic overfitting trap with many tested pairs.
3. **Mean reversion, not a random walk with a break:** a diverging spread is "cheap" only if the relation still holds.
4. **Frictionless, continuous trading:** no transaction costs, borrow costs, or short constraints (Gatev's returns shrink materially once these are added).
5. **Market-neutral hedge** fully removes systematic risk — but residual sector/factor exposures remain.

## How it breaks live
- **Cointegration is not permanent.** The #1 killer: the long-run relation **breaks** (one firm acquired, sector shock, structural change) and the spread diverges *forever* — you keep adding to a losing "mean-reverting" position. Statistical significance in-sample ≠ stability out-of-sample.
- **Multiple-testing / data-snooping:** scanning thousands of pairs guarantees some pass the ADF test by chance; out-of-sample the "relationship" vanishes. Gatev's results have **decayed post-publication** and are much weaker after costs.
- **Transaction costs & shorting:** high turnover + a short leg + borrow fees erode the edge; the strategy is **capacity- and cost-constrained** ([[micro-market-impact]]).
- **Hedge-ratio drift:** a static `β` from formation is stale; a time-varying (Kalman) ratio is needed or the "spread" isn't really stationary.
- **Convergence timing risk:** even a true relation can take longer to revert than your capital/patience allows — "markets can stay irrational longer than you can stay solvent."
- **Crowding:** stat-arb is the most crowded quant strategy; simultaneous unwinds (Aug 2007) cause correlated losses across supposedly independent pairs.

## Deployable takeaways
- **Test for cointegration, not correlation.** Correlation is contemporaneous and meaningless for reversion; cointegration is a long-run equilibrium claim. Use Engle–Granger (or Johansen for multivariate) + ADF, and require **out-of-sample** stability.
- **Model the spread dynamics:** estimate the mean-reversion half-life and only trade pairs whose half-life matches your horizon and cost structure.
- **Use a time-varying hedge ratio** (Kalman filter) so the spread stays stationary as `β` drifts; re-estimate continuously.
- **Respect the break:** a hard stop / "relation-broke" detector is essential — the tail risk of pairs trading is a structural break, not normal variance. Cap losses per pair.
- **Control multiple testing:** require economic rationale (same business/sector), out-of-sample validation, and adjust for the number of pairs searched.
- **Cost it honestly:** backtest with realistic TCA, borrow, and turnover; many "profitable" pairs die here. Prefer liquid, easy-to-borrow names.
- **Diversify across many weakly-correlated pairs** to dilute idiosyncratic break risk, but monitor portfolio-level factor/sector exposure and crowding.
- **Pair with microstructure:** enter/exit spread legs with coordinated execution ([[micro-almgren-chriss-2000]]) to avoid legging risk and adverse flow ([[micro-order-flow-toxicity]]).

## Connections
- Strategy-side note (owned by the strategies pane — implementation detail): [[Pairs Trading (Cointegration)]]. This note is the *microstructure/execution* lens on the same papers.
- [[micro-momentum]] — the opposite horizon: mean-reversion (short/medium) vs trend (medium); often combined.
- [[micro-market-impact]] — the transaction-cost ceiling that kills naive pairs strategies.
- [[micro-almgren-chriss-2000]] — legging the two sides without paying excess impact.
- [[micro-order-flow-toxicity]] — avoid entering a leg into informed flow.
- [[micro-hft-practitioner]] — short-horizon mean-reversion at the tick/queue level.
- [[CANON]]

## References
- Engle, R. F., & Granger, C. W. J. (1987). "Co-Integration and Error Correction: Representation, Estimation, and Testing." *Econometrica* 55(2): 251–276.
- Gatev, E., Goetzmann, W. N., & Rouwenhorst, K. G. (2006). "Pairs Trading: Performance of a Relative-Value Arbitrage Rule." *Review of Financial Studies* 19(3): 797–827.
- Johansen, S. (1991) — multivariate cointegration.
- Vidyamurthy, G. (2004) — *Pairs Trading* (practitioner treatment, Kalman hedge ratios).
- Do, B. & Faff, R. — post-2000 decay of pairs-trading profitability.
