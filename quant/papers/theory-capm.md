---
title: "Capital Asset Pricing Model (CAPM)"
aliases: [CAPM, Security Market Line, Beta, Sharpe-Lintner-Mossin]
tags: [theory, asset-pricing, factors, tier1, canon]
authors: [William Sharpe, John Lintner, Jack Treynor, Jan Mossin]
year: 1964
source: "Sharpe (1964) CAPM, JoF; Lintner (1965); Mossin (1966)"
status: distilled
tier: 1
area: asset-pricing
---

# Capital Asset Pricing Model (CAPM)

> Sharpe (1964), Lintner (1965), Mossin (1966); Treynor's unpublished earlier work. Nobel 1990 (Sharpe). The first **equilibrium** asset-pricing model: it asks what expected returns *must* be if all mean-variance investors ([[theory-markowitz]]) hold the market portfolio in aggregate. Its lasting gift is **beta** — the idea that only *systematic*, non-diversifiable risk is priced.

## Core idea

If everyone holds the tangency portfolio and markets clear, the tangency portfolio *is* the value-weighted **market portfolio**. An asset's expected return depends only on its covariance with the market (its **beta**), not its standalone variance — idiosyncratic risk is diversified away and earns no premium.

## Core equations

**Beta** (systematic risk of asset $i$):
$$\beta_i = \frac{\text{Cov}(r_i, r_m)}{\text{Var}(r_m)} = \frac{\sigma_{im}}{\sigma_m^2}$$

**Security Market Line (SML)** — the pricing equation:
$$\boxed{E[r_i] = r_f + \beta_i\big(E[r_m] - r_f\big)}$$
Expected excess return is linear in beta; the slope is the **market risk premium** $E[r_m]-r_f$.

**Single-index / factor regression** (the empirical workhorse):
$$r_i - r_f = \alpha_i + \beta_i(r_m - r_f) + \varepsilon_i$$
$\alpha_i$ = abnormal return; CAPM predicts $\alpha_i = 0$ for all assets.

**Market portfolio efficiency**: the SML is the tangent line from $r_f$ to the efficient frontier; the market Sharpe ratio is the equilibrium price of risk.

## Assumptions

- Investors are **mean-variance optimizers** with homogeneous expectations (same $\mu,\Sigma$) and a single common horizon.
- **Frictionless markets**: no taxes, transaction costs; unlimited borrowing/lending at $r_f$; unlimited shorting.
- All assets are marketable and divisible; prices are competitive.
- The **market portfolio is mean-variance efficient** (the "roll critique" makes this untestable — see below).
- Returns are (effectively) normal / two-moment.

## How it breaks in real markets

- **Roll's critique (1977)**: the true "market portfolio" includes *all* wealth (human capital, real estate, private assets, bonds) — the observable stock index is only a proxy. CAPM is therefore **not empirically testable**; any test is really a test of the proxy's efficiency.
- **Beta is a weak predictor**: Fama & French (1992) show the cross-sectional relation between beta and return is **flat** — high-beta stocks don't earn proportionally more. The SML is empirically too flat (the "low-beta anomaly" / betting-against-beta).
- **Anomalies CAPM can't price**: size, value, momentum, profitability, low-vol — all produce persistent non-zero $\alpha$, motivating multi-factor models ([[theory-fama-french]]).
- **The market portfolio isn't efficient** in the data (it sits inside the feasible frontier once you add other asset classes).
- **Unrealistic assumptions**: borrowing at $r_f$, no constraints, homogeneous beliefs — Black's zero-beta CAPM and constrained variants relax these but the core predictive failure remains.
- **Time-varying risk premium**: CAPM assumes a constant premium; the equity premium varies with conditions and is far larger than standard models justify (equity premium puzzle).

## What practitioners actually use

- **Beta as a risk descriptor and cost-of-capital input** survives everywhere: corporate finance (WACC), performance attribution, and as a quick systematic-risk gauge — even though it's a poor *return predictor*.
- **CAPM as the equilibrium prior** in [[theory-black-litterman]] (the implied returns $\Pi = \delta\Sigma w_{mkt}$ are exactly reverse-engineered CAPM).
- **Jensen's alpha** and **information ratio** for performance evaluation are CAPM-descended.
- As a *pricing model* it has been **superseded by multi-factor models** ([[theory-fama-french]], Carhart, q-factor) for explaining cross-sectional returns.
- The conceptual core — **diversify idiosyncratic risk, get paid only for systematic exposure** — remains the mental bedrock of the whole field.

## Links

- Equilibrium limit of → [[theory-markowitz]]
- Superseded/extended by → [[theory-fama-french]]
- Equilibrium prior for → [[theory-black-litterman]]
- Index: [[CANON]]

## Key references

- Sharpe (1964), *Capital Asset Prices*, JoF.
- Roll (1977), *A Critique of the Asset Pricing Theory's Tests*, JFE.
- Fama & French (1992), *The Cross-Section of Expected Stock Returns*, JoF.
- Black (1972), *Capital Market Equilibrium with Restricted Borrowing* (zero-beta CAPM).
