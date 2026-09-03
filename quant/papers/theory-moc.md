---
title: "Theory MOC — Tier 1 Distillations"
aliases: [Theory Index, Theory MOC, Portfolio & Pricing Theory Index]
tags: [moc, theory, index, tier1, canon]
status: distilled
type: moc
---

# Theory MOC — Tier 1 Distillations

> Map of Content for the **theory distiller** output. Deep distillations of the Tier 1 theory canon — one note per topic, each covering: core equations, assumptions, how it breaks in real markets, what practitioners actually use. All link back to [[CANON]].
>
> Consolidated single-document reference: `~/Projects/trading-agents/quant-research/papers/distillations/theory.md`.

## Portfolio theory
- [[theory-markowitz]] — Markowitz mean-variance, efficient frontier, two-fund separation. *The scaffold; an error-maximizer if used raw.*
- [[theory-kelly]] — Kelly criterion, log-optimal growth, fractional Kelly. *Sizing; overbetting is the danger.*
- [[theory-black-litterman]] — equilibrium prior + Bayesian views. *The practical fix to Markowitz instability.*
- [[theory-risk-parity]] — equal risk contribution, risk budgeting. *Allocate risk, not dollars; needs only Σ.*

## Asset pricing & factors
- [[theory-capm]] — beta, security market line, single-factor equilibrium. *Beta as risk descriptor; superseded for pricing.*
- [[theory-fama-french]] — 3/4/5-factor models, the factor zoo. *The empirical benchmark; mind crowding & p-hacking.*

## Derivatives & volatility
- [[theory-black-scholes]] — BSM PDE, closed form, Greeks, risk-neutral pricing. *A coordinate system (implied vol), not a belief.*
- [[theory-heston]] — stochastic volatility, leverage effect, characteristic-function pricing. *Realistic smile dynamics.*
- [[theory-local-vol]] — Dupire's equation, exact surface fit. *Calibration backbone; forward-smile problem.*

## The one-paragraph synthesis
Expected returns are unestimable; covariances are estimable. So shrink/avoid $\mu$ ([[theory-black-litterman]], [[theory-risk-parity]]), size edges conservatively ([[theory-kelly]]), harvest robust factor residuals ([[theory-fama-french]]) while knowing premia decay, and treat every pricing model as a quoting/hedging language whose assumptions fail in crises ([[theory-black-scholes]] → [[theory-heston]] / [[theory-local-vol]]).

## Related canon (not separately distilled here)
- [[APT]] — Ross (1976), multi-factor via no-arbitrage.
- [[Merton Option Theory]], [[CIR Model]] — term structure / jump-diffusion.
- [[Gatheral Volatility Surface]], [[Sinclair Volatility Trading]] — practitioner vol references.

## Links
- Master map: [[CANON]]
- Vault root: [[INDEX]]
