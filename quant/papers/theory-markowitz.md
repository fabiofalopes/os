---
title: "Markowitz Mean-Variance Portfolio Theory"
aliases: [MPT, Mean-Variance Optimization, Efficient Frontier, "Markowitz 1952"]
tags: [theory, portfolio-theory, optimization, tier1, canon]
authors: [Harry Markowitz]
year: 1952
source: "Portfolio Selection, Journal of Finance 7(1)"
status: distilled
tier: 1
area: portfolio-theory
---

# Markowitz Mean-Variance Portfolio Theory

> "Portfolio Selection" (1952), expanded in Markowitz (1959) *Portfolio Selection: Efficient Diversification of Investments*. Nobel 1990. The founding document of quantitative finance: reframed investing from security *selection* (pick the best stock) to portfolio *construction* (pick the best combination).

## Core idea

Investors care about the **distribution of portfolio return**, summarized by its first two moments. Given expected returns $\mu$ and covariance $\Sigma$, choose weights $w$ to maximize expected return for a given variance (or minimize variance for a given return). Risk and return are traded off jointly, not separately.

## Core equations

Portfolio moments:
$$\mu_p = w^\top \mu, \qquad \sigma_p^2 = w^\top \Sigma w$$

The mean-variance objective (risk-aversion form):
$$\max_w \; w^\top \mu - \frac{\gamma}{2} w^\top \Sigma w \quad \text{s.t. } \mathbf{1}^\top w = 1$$

Closed-form (unconstrained, fully invested):
$$w^* = \frac{1}{\gamma}\Sigma^{-1}\mu \;+\; \text{budget term}$$

**Efficient frontier**: the locus of portfolios minimizing $\sigma_p^2$ at each $\mu_p$; a hyperbola in $(\sigma,\mu)$ space. The upper branch is "efficient."

**Tangency / max-Sharpe portfolio** (with risk-free rate $r_f$):
$$w_{\text{tan}} = \frac{\Sigma^{-1}(\mu - r_f\mathbf{1})}{\mathbf{1}^\top\Sigma^{-1}(\mu - r_f\mathbf{1})}, \qquad \text{Sharpe}^2 = (\mu - r_f\mathbf{1})^\top \Sigma^{-1}(\mu - r_f\mathbf{1})$$

**Two-fund separation**: every efficient portfolio is a mix of the risk-free asset and the tangency portfolio. All investors hold the *same* risky portfolio, differing only in leverage. (Becomes the [[theory-capm]] market portfolio under homogeneous expectations.)

**Critical line algorithm**: Markowitz's piecewise-linear method for solving MVO with inequality constraints (long-only, bounds) — the original "solver."

## Assumptions

- Returns are characterized fully by mean and variance (exactly true for **elliptical** distributions, e.g. Gaussian; otherwise only a two-moment approximation).
- Single-period, static horizon; no rebalancing dynamics.
- $\mu$ and $\Sigma$ are **known** inputs (the fatal assumption — see below).
- Frictionless markets: no transaction costs, taxes, liquidity constraints; unlimited shorting and borrowing at $r_f$ (relaxed in practice).
- Investors are mean-variance optimizers (equivalent to quadratic utility, or expected utility under normality).

## How it breaks in real markets

- **Estimation error is amplified, not dampened.** MVO *inverts* $\Sigma$ and loads heavily on $\mu$. Expected returns are estimated with enormous error (need ~$T \gg N^2$ years of data for a stable $\Sigma^{-1}$, effectively impossible). The optimizer treats noise in $\mu$ as signal and builds huge, concentrated, sign-flipping positions. Michaud (1989): MVO is an "**error maximizer**."
- **Instability**: tiny changes in inputs → wildly different weights; portfolios churn on every rebalance (high turnover, transaction costs eat the edge).
- **Corner solutions / "1/N in disguise"**: unconstrained optima put extreme weight on a few assets; with long-only constraints the solution jumps between corners.
- **Non-normality**: fat tails, skewness, and tail dependence make variance a poor risk measure; diversification benefits **collapse in crises** (correlations → 1 exactly when you need them).
- **Single-period**: ignores rebalancing, path dependence, and the fact that today's "optimal" portfolio depends on future opportunities (Merton's intertemporal solution adds hedging demands).

## What practitioners actually use

- **Never raw MVO on sample estimates.** The core lesson: *the covariance matrix matters far more than the expected returns* — $\Sigma$ is estimable, $\mu$ is not.
- **Shrinkage estimators** for $\Sigma$: Ledoit–Wolf shrinkage toward a structured target (constant-correlation, single-factor, identity) — dramatically reduces out-of-sample error. Now the default in most toolboxes.
- **Return shrinkage / Bayesian priors**: pull $\mu$ toward a prior (equal means, CAPM equilibrium). [[theory-black-litterman]] is exactly this: start from equilibrium-implied $\mu$, tilt with views.
- **Resampled efficiency** (Michaud): optimize many Monte-Carlo draws of inputs, average the weights — a frequentist diversification over estimation uncertainty.
- **Constraints as the real alpha**: position bounds, sector/turnover limits, max weight. Practitioners spend more effort on constraints than on the objective.
- **1/N (equal weight) as the benchmark to beat**: DeMiguel, Garlappi & Uppal (2009) show naive $1/N$ is hard to beat out-of-sample once estimation error is counted. Any optimizer must justify itself against $1/N$.
- **Robust / distributionally-robust optimization**: optimize against the worst case in an uncertainty set around $(\mu,\Sigma)$.
- **Risk-based allocation** sidesteps $\mu$ entirely: [[theory-risk-parity]], minimum-variance, max-diversification — only need $\Sigma$.

## Links

- Equilibrium limit → [[theory-capm]]
- Bayesian view-tilting on top of equilibrium → [[theory-black-litterman]]
- Estimation-error-free allocation → [[theory-risk-parity]]
- Growth-optimal alternative → [[theory-kelly]]
- Index: [[CANON]]

## Key references

- Markowitz (1952), *Portfolio Selection*, JoF.
- Michaud (1989), *The Markowitz Optimization Enigma: Is 'Optimized' Optimal?*
- DeMiguel, Garlappi & Uppal (2009), *Optimal Versus Naive Diversification*, JoF.
- Ledoit & Wolf (2004), *A Well-Conditioned Estimator for Large-Dimensional Covariance Matrices*.
