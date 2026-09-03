---
title: "Black-Scholes-Merton Option Pricing"
aliases: [Black-Scholes, BSM, Black-Scholes-Merton, "Black & Scholes 1973", Greeks]
tags: [theory, derivatives, volatility, option-pricing, tier1, canon]
authors: [Fischer Black, Myron Scholes, Robert Merton]
year: 1973
source: "Black & Scholes (1973) JPE; Merton (1973) Bell J. Econ."
status: distilled
tier: 1
area: derivatives
---

# Black-Scholes-Merton Option Pricing

> Black & Scholes (1973), "The Pricing of Options and Corporate Liabilities," *JPE*; Merton (1973) supplied the no-arbitrage / continuous-hedging argument and the PDE. Nobel 1997 (Scholes & Merton; Black had died). The single most consequential equation in finance: it made options a **tradable, hedgeable instrument** and created the modern derivatives industry. Its real product was not a price but a **hedge ratio (delta)** and a common language (**implied volatility**, the **Greeks**).

## Core idea

If the underlying follows geometric Brownian motion with **constant volatility**, a continuously-rebalanced portfolio of the option and the stock is **locally riskless**, so by no-arbitrage it must earn $r_f$. This pins down a unique price *independent of the stock's drift or investors' risk preferences* — the risk-neutral pricing principle.

## Core equations

**Underlying dynamics** (GBM):
$$dS_t = \mu S_t\,dt + \sigma S_t\,dW_t$$

**The Black-Scholes PDE** (any derivative $V(S,t)$):
$$\frac{\partial V}{\partial t} + \frac{1}{2}\sigma^2 S^2 \frac{\partial^2 V}{\partial S^2} + r S \frac{\partial V}{\partial S} - r V = 0$$
Note $\mu$ has vanished — the drift is irrelevant (replaced by $r$ under the risk-neutral measure $\mathbb Q$).

**European call closed form**:
$$\boxed{C = S_0\,N(d_1) - K e^{-rT} N(d_2)}$$
$$d_1 = \frac{\ln(S_0/K) + (r + \tfrac12\sigma^2)T}{\sigma\sqrt{T}}, \qquad d_2 = d_1 - \sigma\sqrt{T}$$
Put via put-call parity: $P = C - S_0 + Ke^{-rT}$.

**Delta hedge**: hold $\Delta = \partial V/\partial S = N(d_1)$ shares short per long call → delta-neutral, locally riskless.

**Risk-neutral pricing** (the general principle BSM instantiates):
$$V_0 = e^{-rT}\,\mathbb E^{\mathbb Q}[\text{payoff}]$$

**The Greeks** (risk sensitivities): $\Delta=\partial_S V$, $\Gamma=\partial_{SS}V$, $\Theta=\partial_t V$, $\mathcal V=\partial_\sigma V$ (vega), $\rho=\partial_r V$. They are the desk's risk-management vocabulary.

## Assumptions

- **Constant volatility** $\sigma$ and constant risk-free rate $r$ (the two most-violated assumptions).
- Underlying follows **continuous GBM**: lognormal, no jumps, continuous paths.
- **Continuous, costless trading** and hedging; no transaction costs or taxes.
- No dividends (extended by Merton to continuous dividend yield $q$: replace $r\to r-q$).
- Unlimited shorting, frictionless borrowing/lending at $r$; European exercise.
- Markets are **complete** (one source of risk, one hedging instrument) → unique price.

## How it breaks in real markets

- **The volatility smile/skew**: BSM with a single $\sigma$ predicts a *flat* implied-vol curve across strikes. Real markets show a pronounced **smile** (FX) and **skew** (equity indices: OTM puts much more expensive) — the signature of fat tails and crash fear. One constant $\sigma$ is simply wrong.
- **Jumps**: prices gap (earnings, crashes); continuous hedging fails and the "riskless" portfolio isn't. Merton's jump-diffusion (1976) and later models address this.
- **Stochastic volatility**: vol itself moves and clusters; BSM's constant-$\sigma$ can't capture smile dynamics or the vol-of-vol → [[theory-heston]].
- **Discrete hedging & transaction costs**: continuous rebalancing is impossible; real hedging incurs costs and residual (gamma) risk. Leland (1985) adjusts $\sigma$ for transaction costs.
- **Fat tails / non-lognormal**: realized returns have far fatter tails than lognormal — BSM systematically misprices deep OTM options (underprices crash risk).
- **Liquidity, funding, counterparty risk**: post-2008, the "risk-free" rate and frictionless-funding assumptions broke (XVA, collateral, basis).

## What practitioners actually use

- **BSM is the universal quoting convention, not a belief.** Traders quote and think in **implied volatility** (the $\sigma$ you back out of BSM to match the market price), not dollars. The model is a *coordinate system*; everyone knows it's wrong but it's the shared language.
- **The Greeks run the world**: desks manage delta, gamma, vega, theta exposure daily. BSM gives the Greeks; the art is managing them under a moving smile.
- **Local calibration**: fit a **per-strike implied vol** (or a [[theory-local-vol]] surface) so the model reproduces the observed smile exactly, then price exotics consistently with vanilla prices.
- **BSM as the baseline** that richer models (stochastic vol, jump-diffusion, local-stochastic vol) must reduce to and improve upon.
- For liquid vanillas, the market price *is* the truth; BSM just converts it to/from vol. The real modeling problem is the **surface dynamics** (how the smile moves), which BSM alone can't give.

## Links

- Constant-vol failure motivates → [[theory-heston]] (stochastic vol) and → [[theory-local-vol]] (Dupire)
- Index: [[CANON]]

## Key references

- Black & Scholes (1973), *The Pricing of Options and Corporate Liabilities*, JPE.
- Merton (1973), *Theory of Rational Option Pricing*, Bell J. Econ.
- Merton (1976), *Option Pricing When Underlying Stock Returns Are Discontinuous* (jump-diffusion).
- Hull, *Options, Futures, and Other Derivatives* (the practitioner textbook).
