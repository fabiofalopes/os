---
title: "Heston Stochastic Volatility Model"
aliases: [Heston, "Heston Model", Stochastic Volatility, SV, "Heston 1993"]
tags: [theory, derivatives, volatility, stochastic-vol, tier1, canon]
authors: [Steven Heston]
year: 1993
source: "A Closed-Form Solution for Options with Stochastic Volatility, Review of Financial Studies"
status: distilled
tier: 1
area: derivatives
---

# Heston Stochastic Volatility Model

> Heston (1993), "A Closed-Form Solution for Options with Stochastic Volatility with Applications to Bond and Currency Options," *RFS*. The canonical fix to [[theory-black-scholes]]'s constant-vol failure: make volatility itself a **mean-reverting stochastic process**. It produces the observed **implied-vol smile/skew** endogenously and, crucially, admits a **semi-closed-form** price via characteristic functions — tractable enough to calibrate and use on a desk.

## Core idea

Volatility is an unobserved state variable that diffuses and mean-reverts. Because vol is a *second* source of randomness not spanned by the stock, the market is **incomplete** — you can't perfectly hedge an option with stock alone, and a **volatility risk premium** enters. The correlation between stock and vol shocks generates the skew.

## Core equations

**The Heston SDEs** (under $\mathbb Q$):
$$dS_t = r S_t\,dt + \sqrt{v_t}\,S_t\,dW_t^S$$
$$dv_t = \kappa(\theta - v_t)\,dt + \xi\sqrt{v_t}\,dW_t^v, \qquad dW_t^S\,dW_t^v = \rho\,dt$$
- $v_t$: **variance** process (CIR square-root diffusion, stays non-negative).
- $\kappa$: speed of mean reversion; $\theta$: long-run variance; $\xi$: **vol-of-vol**.
- $\rho$: correlation between asset and vol shocks — the **leverage effect** ($\rho<0$ in equities: prices fall → vol rises). This is what tilts the smile into a **skew**.

**Pricing via characteristic function**: the log-price characteristic function $\phi(u)=E[e^{iu\log S_T}]$ is exponential-affine in $v_0$:
$$\phi(u) = \exp\big(C(u,T) + D(u,T)\,v_0 + iu\log S_0\big)$$
with $C,D$ solving Riccati ODEs. Option prices follow by Fourier inversion (Carr–Madan / FFT). This is the "closed-form" of the title — closed in transform space, not elementary functions.

**Feller condition**: $2\kappa\theta > \xi^2$ keeps variance strictly positive (never hits zero).

## Assumptions

- Variance follows a **CIR** process (affine → tractable; non-negative; mean-reverting).
- **Constant** parameters $\kappa,\theta,\xi,\rho$ (in reality all time- and regime-varying).
- Correlation $\rho$ is constant (the leverage effect actually varies with the level of vol and regime).
- No jumps (pure diffusion) — misses the **short-dated skew** and crash behavior.
- Risk-neutral pricing with a specified (often affine) volatility risk premium.

## How it breaks in real markets

- **Can't fit the short-maturity skew**: pure-diffusion SV produces a skew that flattens too fast at short tenors. The very-short-dated equity skew is driven by **jumps**, which Heston lacks → need jump-diffusion or rough vol.
- **Calibration instability**: the 5 parameters are hard to pin down; fits to the vanilla surface are often imperfect and the calibrated params jump around over time (the "smile dynamics" problem).
- **Constant parameters** miss the empirical fact that vol-of-vol, mean-reversion, and correlation all shift with regime and vol level.
- **The forward smile flattens**: like [[theory-local-vol]], Heston's implied dynamics tend to flatten the forward vol smile — imperfect for exotics and forward-starting products.
- **Incomplete market / unhedgeable vol risk**: the volatility risk premium is a modeling choice, not pinned down by no-arbitrage; residual vol-of-vol (vega-of-vega, "volga") risk remains.
- **Rough volatility** (Gatheral–Jaisson–Rosenbaum 2018): realized vol is better fit by a *rough* (Hurst $H<0.5$) process than by Heston's Markovian diffusion — a modern challenge to the whole SV-diffusion family.

## What practitioners actually use

- **The workhorse stochastic-vol model** for FX and rates, and a baseline for equity — calibrated to the vanilla smile, then used to price and hedge exotics consistently.
- **Local-Stochastic Volatility (LSV)** — the industry standard for equity exotics: combine Heston's stochastic vol (for realistic smile *dynamics*) with a [[theory-local-vol]] leverage function (to fit the vanilla surface *exactly*). Best of both.
- **SABR** (Hagan et al. 2002) is the rates/FX analogue — stochastic-vol model with a closed-form smile approximation, ubiquitous on rates desks.
- Traders manage the extra Greeks Heston introduces: **vanna** ($\partial\Delta/\partial\sigma$), **volga/vomma** ($\partial^2 V/\partial\sigma^2$) — the smile-movement risks BSM can't see.
- **Rough-vol and jump-augmented** models (Bates = Heston + jumps) used where the short-dated skew and crash risk matter.

## Links

- Fixes constant-vol failure of → [[theory-black-scholes]]
- Combined with → [[theory-local-vol]] in Local-Stochastic-Vol
- Index: [[CANON]]

## Key references

- Heston (1993), *A Closed-Form Solution for Options with Stochastic Volatility*, RFS.
- Bates (1996), *Jumps and Stochastic Volatility* (Heston + jumps).
- Hagan, Kumar, Lesniewski & Woodward (2002), *Managing Smile Risk* (SABR).
- Gatheral, Jaisson & Rosenbaum (2018), *Volatility is Rough*, Quantitative Finance.
- Gatheral, *The Volatility Surface* (the practitioner reference).
