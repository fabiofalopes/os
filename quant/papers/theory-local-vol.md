---
title: "Local Volatility (Dupire's Equation)"
aliases: [Local Volatility, Dupire, Dupire Equation, Local Vol, "Dupire 1994"]
tags: [theory, derivatives, volatility, local-vol, tier1, canon]
authors: [Bruno Dupire, Emanuel Derman, Iraj Kani]
year: 1994
source: "Dupire (1994) Pricing with a Smile, Risk; Derman & Kani (1994)"
status: distilled
tier: 1
area: derivatives
---

# Local Volatility (Dupire's Equation)

> Dupire (1994), "Pricing with a Smile," *Risk*; independently Derman & Kani (1994), "Riding on a Smile," *Risk*. The elegant answer to the [[theory-black-scholes]] smile problem: instead of one constant $\sigma$, let volatility be a **deterministic function of spot and time**, $\sigma(S,t)$, chosen so the model **exactly reproduces the entire observed vanilla surface**. It restores market completeness (one state variable, hedgeable with the stock) while fitting every listed option price.

## Core idea

There exists a unique local-volatility function $\sigma_{LV}(S,t)$ consistent with all observed European option prices. It's the diffusion coefficient that makes the model-implied marginal distribution of $S_T$ match the one implied by the market smile at every maturity. Calibrate once to vanillas, then price **exotics** consistently (no arbitrage vs. the vanilla book).

## Core equations

**Local-vol dynamics**:
$$dS_t = r S_t\,dt + \sigma_{LV}(S_t,t)\,S_t\,dW_t$$

**Dupire's equation** — the forward PDE for the transition density / call price $C(K,T)$ as a function of strike $K$ and maturity $T$:
$$\boxed{\sigma_{LV}^2(K,T) = \frac{\dfrac{\partial C}{\partial T} + (r-q)K\dfrac{\partial C}{\partial K} + q\,C}{\tfrac{1}{2}K^2\dfrac{\partial^2 C}{\partial K^2}}}$$
Given the market call surface $C(K,T)$ (interpolated smoothly), this recovers the local vol at each $(K,T)$ directly — no iterative calibration needed. Numerator = time value + drift terms; denominator = the strike **gamma** (curvature of the surface).

**Intuition**: where the smile has high curvature (deep OTM), local vol is high; the surface's shape *is* the local-vol function.

## Assumptions

- Volatility is a **deterministic** function of $(S,t)$ — no independent vol randomness (contrast [[theory-heston]]).
- The underlying is a **Markov diffusion** (continuous paths, no jumps).
- The full vanilla call surface $C(K,T)$ is known, smooth, and **arbitrage-free** (calendar and butterfly conditions) — Dupire needs $\partial^2 C/\partial K^2 > 0$.
- Continuous trading, frictionless markets; market is **complete** (hedge with stock + cash).

## How it breaks in real markets

- **The forward-smile problem (the big one)**: local vol flattens and inverts the **forward** implied smile. Because $\sigma_{LV}$ is a function of *spot level*, when the spot moves the model predicts the smile moves the *wrong way* — e.g. in equity LV, a market drop raises local vol at the new (lower) spot, but the forward skew dynamics come out backwards. It prices vanillas exactly but gets **exotic/forward-starting dynamics wrong** (e.g. misprices cliquets, forward-start options, barriers).
- **Unstable / spiky surface**: Dupire's formula divides by gamma ($\partial^2 C/\partial K^2$); noisy or thinly-quoted market data → noisy, unstable local vol. Requires careful smoothing/regularization.
- **No vol randomness**: can't capture vol-of-vol, stochastic smile movement, or the leverage effect as a *dynamic* — it's all baked into a deterministic surface.
- **Path dependence mispriced**: because it's Markovian in spot, path-dependent and multi-asset exotics can be off.
- **Assumes continuous, arbitrage-free input** — real surfaces have discrete strikes, bid-ask, and occasional static-arb violations that must be cleaned first.

## What practitioners actually use

- **The standard vanilla-calibration backbone**: fit the local-vol surface to liquid vanillas, then price exotics consistently with the whole book. Fast, arbitrage-free, complete (clean hedges).
- **Local-Stochastic Volatility (LSV)** — the equity-exotics industry standard: multiply a [[theory-heston]] stochastic-vol process by a **leverage function** $L(S,t)$ calibrated so the *combined* model still fits the vanilla surface exactly. LV gives the exact fit; SV gives realistic smile dynamics. This is how most banks price equity exotics.
- **Used where dynamics matter less** (short-dated, vanilla-heavy books) and as the calibration target that richer models must match.
- **Regularized Dupire** (smooth interpolation, SABR- or SVI-fit surface fed into Dupire) to tame the gamma-division instability. SVI (Jim Gatheral 2004) is the standard smile parametrization feeding this.
- Traders know LV's forward dynamics are wrong and **overlay** stochastic vol or adjust hedges accordingly.

## Links

- Completes the smile fix started by → [[theory-black-scholes]]
- Combined with → [[theory-heston]] in Local-Stochastic-Vol (LSV)
- Index: [[CANON]]

## Key references

- Dupire (1994), *Pricing with a Smile*, Risk.
- Derman & Kani (1994), *Riding on a Smile*, Risk.
- Gatheral (2004), *A Arbitrage-Free SVI* / *The Volatility Surface* (SVI parametrization).
- van der Weijst (2013), *Stochastic Local Volatility* (LSV).
- Local vol vs. stochastic vol comparison: Gatheral, *The Volatility Surface*.
