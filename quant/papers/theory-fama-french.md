---
title: "Fama-French Factor Models"
aliases: [Fama-French, FF3, FF5, Three-Factor Model, Five-Factor Model, Carhart, Factor Zoo]
tags: [theory, asset-pricing, factors, tier1, canon]
authors: [Eugene Fama, Kenneth French, Mark Carhart]
year: 1993
source: "Fama & French (1993) 3-factor, JFE; Carhart (1997); Fama & French (2015) 5-factor"
status: distilled
tier: 1
area: asset-pricing
---

# Fama-French Factor Models

> Fama & French (1992, 1993) showed [[theory-capm]]'s single beta can't explain the cross-section of returns, and that **size** and **value** do. The three-factor model became the empirical benchmark for "what counts as a priced risk." Carhart (1997) added **momentum**; Fama & French (2015) added **profitability** and **investment**, giving the five-factor model. Together with the sprawling "factor zoo," this is the workhorse framework of empirical asset pricing and systematic investing.

## Core idea

Expected returns are compensation for exposure to a small set of **common risk factors**. Portfolios sorted on firm characteristics (size, book-to-market, etc.) proxy for these risks. A factor model explains returns as loadings ("betas") on traded factor-mimicking portfolios; residual $\alpha$ is the anomaly to be explained away.

## Core equations

**Three-factor model** (time-series regression for asset/portfolio $i$):
$$r_i - r_f = \alpha_i + \beta_i^{MKT}(r_m - r_f) + \beta_i^{SMB}\,SMB + \beta_i^{HML}\,HML + \varepsilon_i$$
- $MKT$: market excess return.
- $SMB$ (Small Minus Big): long small-cap, short large-cap — the **size** factor.
- $HML$ (High Minus Low): long high book-to-market (value), short low B/M (growth) — the **value** factor.

**Carhart four-factor**: add $UMD/WML$ (Up-Minus-Down, Winners-Minus-Losers) — **momentum** (Jegadeesh & Titman 1993).

**Five-factor model** (Fama & French 2015):
$$r_i - r_f = \alpha_i + \beta^{MKT}MKT + \beta^{SMB}SMB + \beta^{HML}HML + \beta^{RMW}RMW + \beta^{CMA}CMA + \varepsilon_i$$
- $RMW$ (Robust Minus Weak): long high-**profitability**, short low — the **profitability** factor.
- $CMA$ (Conservative Minus Aggressive): long low-**investment**, short high — the **investment** factor.
- Notably, in FF5 the value factor $HML$ becomes largely **redundant** (subsumed by the others).

**Cross-sectional (Fama-MacBeth) form**: regress returns on characteristics/loadings, price the risk premia $\lambda_k$: $E[r_i] = r_f + \sum_k \beta_{ik}\lambda_k$.

## Assumptions

- Factors are **priced risks** (rational risk-based explanation) — the original claim. (Behavioral alternative: factors are mispricing/limits-to-arbitrage, not risk.)
- Factor-mimicking portfolios (2×3 sorts on size × characteristic) correctly span the relevant risk exposures.
- Linear loadings; premia are roughly **stationary** over time.
- Anomalies are **out-of-sample robust**, not data-mined — increasingly doubtful (see below).

## How it breaks in real markets

- **The factor zoo & p-hacking**: hundreds of published "factors," most of which decay or vanish out-of-sample. Harvey, Liu & Zhu (2016): with so many trials, $t$-stats need to exceed ~3.0, not 2.0. Many factors are the same exposure repackaged.
- **Factor crowding**: once a premium is published and capital flows in, it **decays** (the value factor has been weak/absent for much of 2010s–2020s; momentum crashes recur). Publication → arbitrage → decay.
- **Regime dependence & crashes**: factors have **fat left tails** — momentum crashes (2009), value crashes, all hit simultaneously in stress. Factor "diversification" evaporates in crises.
- **Risk vs. mispricing debate unresolved**: it's genuinely unclear whether premia compensate risk (rational) or exploit persistent mispricing/behavioral biases — which changes how durable you expect them to be.
- **Implementation matters enormously**: the academic long-short sort ignores transaction costs, shorting constraints, and capacity; realizable premia are much smaller, especially for small/illiquid names (the size premium is largely an illiquidity/microcap effect).
- **Definition sensitivity**: results flip with how you define value (B/M vs. earnings yield vs. cash-flow yield), the sample period, and the geography.

## What practitioners actually use

- **The empirical benchmark**: any new strategy/alpha must show it survives controlling for FF/Carhart factors (i.e. has genuine $\alpha$, not just factor exposure).
- **Smart-beta / factor investing** is a huge industry (AQR, Dimensional, Research Affiliates): systematically harvest value, momentum, quality, low-vol, carry across asset classes — but with heavy emphasis on **costs, capacity, and diversification across uncorrelated factors**.
- **Quality/profitability** (Novy-Marx; Asness-Frazzini-Pedersen "Quality Minus Junk") has proven the most robust recent addition.
- Practitioners treat premia as **time-varying and partially harvestable**, not fixed risk compensations; they combine many weakly-correlated factors and manage factor-timing/crowding risk.
- **Cross-asset factors** (value/momentum/carry/defensive in equities, bonds, FX, commodities — Asness, Moskowitz, Pedersen 2013) generalize the equity-only zoo.

## Links

- Extends/supersedes → [[theory-capm]]
- Factor exposures feed sizing via → [[theory-kelly]]
- Index: [[CANON]]

## Key references

- Fama & French (1993), *Common Risk Factors in the Returns on Stocks and Bonds*, JFE.
- Carhart (1997), *On Persistence in Mutual Fund Performance*, JoF (momentum).
- Fama & French (2015), *A Five-Factor Asset Pricing Model*, JFE.
- Harvey, Liu & Zhu (2016), *...and the Cross-Section of Expected Returns* (factor zoo / multiple-testing).
- Asness, Moskowitz & Pedersen (2013), *Value and Momentum Everywhere*, JoF.
