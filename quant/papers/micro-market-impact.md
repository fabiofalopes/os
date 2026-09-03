---
title: "Market Impact: The Square-Root Law & Practitioner Cost Models"
authors: [Torre (1997), Almgren et al. (2005), Bouchaud et al., Gatheral & Schied, Zarinelli et al.]
year: 2005
type: paper-distillation
domain: microstructure
tags: [microstructure, market-impact, square-root-law, transaction-costs, execution, capacity, tca]
status: distilled
created: 2026-07-23
citekey: marketimpact
---

# Market Impact — Square-Root Law & Practitioner Cost Models

Part of [[CANON]]. Sibling notes: [[micro-almgren-chriss-2000]], [[micro-kyle-1985]], [[micro-order-flow-toxicity]].

## One-liner
The most robust empirical regularity in execution: **permanent price impact is concave — roughly a square-root — in order size** `I(Q) ≈ Y σ √(Q/V)`, where `Q` is order size and `V` typical daily volume. Doubling your order does *not* double your impact; but impact is also **permanent and nearly irreversible**, which is what caps strategy capacity.

## The model / the empirical law
- **Metaorder framing (Bouchaud et al.):** a large parent order is split into many child executions over a day; measure the price move from start to end of the metaorder and its relaxation after.
- **Impact curve:** `I(Q) = Y · σ · (Q/V)^δ` with `δ ≈ 0.5–0.6` across asset classes — the **square-root law**. `Y` is a dimensionless constant of order ~1 (the "impact coefficient").
- **Two components:**
  - **Permanent impact:** the price does *not* fully revert after the metaorder — a lasting displacement (information / inventory absorption).
  - **Transient impact:** a spike during execution that partially decays over a **power-law kernel** (minutes–hours), not exponentially.
- **Practitioner TCA models** (e.g. the "square-root" model used in sell-side algos): `cost_bps ≈ a + b · σ · √(Q/ADV)`, fit per name; used to price execution and estimate capacity.

## Key equations
- **Square-root impact:** `Δp/p ≈ Y σ √(Q/V)` — concave, scale-invariant (depends on participation `Q/V`, not absolute size).
- **Transient decay:** impact relaxes as a slow power law `~ t^{−β}` (β ≈ 0.5), implying **long memory** and near-no-arbitrage constraints (Gatheral: impact kernels must be non-decreasing-then-decreasing in a specific way to exclude dynamic arbitrage).
- **Capacity back-of-envelope:** to keep impact under `c` bps, max size `Q* ≈ V · (c / (Y σ))²`. Capacity scales **linearly with volume** and **inversely with variance squared**.

## Assumptions (of the stylized law)
1. Impact depends on **participation** `Q/V`, stationary across regimes — but `V` and `σ` are themselves regime-dependent.
2. A **single, well-defined metaorder** with a clean start/end — real flow is overlapping and multi-source.
3. The exponent `δ ≈ 0.5` is **universal** — it varies somewhat (0.4–0.7) by asset, venue, and how you define the metaorder.
4. Permanent/transient split is stable — in reality the permanent fraction rises with *information content* of the flow.

## How it breaks live
- **The exponent and `Y` drift.** Around earnings, macro, and in low-liquidity names, impact steepens (toward linear) and `Y` jumps — a single calibrated law overstates capacity exactly when you're most active.
- **Impact is partly *your* information leaking.** If the market detects a persistent buyer, others front-run and the "permanent" component grows — the law assumes anonymous flow ([[micro-kyle-1985]], [[micro-order-flow-toxicity]]).
- **Transient-decay misspecification** breaks optimal execution: assume exponential decay when it's power-law and you'll re-hit the same name too soon, paying impact twice ([[micro-almgren-chriss-2000]]).
- **Cross-asset and cross-venue impact** are ignored: a large order fragments across venues and correlated names, so single-name `Q/V` understates true footprint.
- **Small orders sit in the spread, not the square-root:** for tiny `Q` the dominant cost is the bid-ask spread and fees, not impact — the law is a large-order asymptote ([[micro-glosten-milgrom-1985]]).

## Deployable takeaways
- **Capacity is a first-class constraint, computed from impact.** Before sizing any strategy, compute `Q*` from `Y σ √(Q/V)` and your impact budget; a backtest that ignores this is fiction.
- **Calibrate `Y` and `δ` per name/regime** from your own metaorder fills; maintain a live TCA model and feed it back into execution urgency and position limits.
- **Respect the transient kernel:** space out re-entries to the same name beyond the impact-decay horizon to avoid paying impact twice; use the kernel to schedule slices.
- **Trade participation, not size:** your real footprint is `Q/V`; in thin names or off-hours, shrink size to hold impact constant.
- **Watch for impact as a signal:** if your own execution is moving price more than the law predicts, you are likely leaking information or hitting a regime shift — slow down.
- **Permanent impact = the cost of being right and large:** it is the structural reason alpha decays with AUM; build capacity estimates into the strategy's expected Sharpe.

## Connections
- [[micro-almgren-chriss-2000]] — optimal execution consumes these impact functions.
- [[micro-kyle-1985]] — Kyle's linear λ is the small/linearized cousin of the concave square-root law.
- [[micro-order-flow-toxicity]] — toxicity raises the permanent fraction of impact.
- [[micro-avellaneda-stoikov-2008]] — the MM absorbs impact from others' flow.
- [[micro-hft-practitioner]] — latency/queue determine who *pays* vs *earns* impact.
- [[CANON]]

## References
- Torre, N. (1997). "Market Impact Model Handbook" — early square-root empirical model.
- Almgren, R., Thum, C., Hauptmann, E., & Li, H. (2005). "Direct Estimation of Equity Market Impact." *Risk*.
- Bouchaud, J.-P., Farmer, J. D., & Lillo, F. (2009) — "How Markets Slowly Digest Changes in Supply and Demand."
- Gatheral, J. (2010) — "No-Dynamic-Arbitrage and Market Impact."
- Zarinelli, E., Treccani, M., & Bouchaud — metaorder / propagator model.
