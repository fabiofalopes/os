---
title: "Risk Parity & Risk Budgeting"
aliases: [Risk Parity, Equal Risk Contribution, ERC, Risk Budgeting, All Weather]
tags: [theory, portfolio-theory, risk-allocation, tier1, canon]
authors: [Bernardo, Qian, Maillard, Roncalli]
year: 2005
source: "Qian (2005) Risk Parity; Maillard-Roncalli-Telletche (2010); Bridgewater All Weather (1996)"
status: distilled
tier: 1
area: portfolio-theory
---

# Risk Parity & Risk Budgeting

> Practitioner-born, not a single paper. Bridgewater's **All Weather** (1996, Dalio) popularized balancing *risk* across asset classes. Formalized by Qian (2005, "Risk Parity"), Maillard, Roncalli & Teïletche (2010, "The Properties of Equally Weighted Risk Contribution Portfolios"), and Bruder & Roncalli (2012, "Managing Risk Exposures Using the Risk Budgeting Approach"). The insight: a 60/40 stock/bond portfolio is really a ~90/10 *risk* bet because stocks are far more volatile — dollar diversification ≠ risk diversification.

## Core idea

Allocate so each asset (or asset class) contributes **equally to total portfolio risk**, rather than equally to dollars or to expected return. This sidesteps the unestimable expected returns entirely — you only need the covariance matrix, which *is* estimable (see [[theory-markowitz]] on why this matters).

**Marginal risk contribution** of asset $i$:
$$MRC_i = \frac{\partial \sigma_p}{\partial w_i} = \frac{(\Sigma w)_i}{\sigma_p}$$

**Total risk contribution** (Euler allocation — sums exactly to $\sigma_p$):
$$RC_i = w_i \cdot MRC_i = \frac{w_i(\Sigma w)_i}{\sigma_p}, \qquad \sum_i RC_i = \sigma_p$$

## Core equations

**Equal Risk Contribution (ERC)**: find $w$ such that all contributions are equal:
$$\boxed{w_i\,(\Sigma w)_i = w_j\,(\Sigma w)_j \;\;\forall\, i,j \qquad \text{(equivalently } RC_i = \sigma_p/N\text{)}}$$

Convex optimization form (minimize concentration of risk):
$$\min_w \sum_i \big(w_i(\Sigma w)_i - \bar{RC}\big)^2 \quad \text{s.t. } \mathbf{1}^\top w = 1,\; w\ge 0$$
or the log-barrier form $\min_w \tfrac12 w^\top\Sigma w - \tfrac{1}{N}\sum_i \ln w_i$, whose solution is the ERC portfolio (Maillard et al. 2010).

**Risk budgeting (general)**: target contribution fractions $b_i$ with $\sum b_i = 1$:
$$w_i(\Sigma w)_i = b_i\, \sigma_p^2$$
ERC is the special case $b_i = 1/N$. This is the risk-space analogue of [[theory-markowitz]]'s return budgeting.

**Special cases**: with diagonal $\Sigma$ (uncorrelated assets), ERC reduces to **inverse-volatility weighting** $w_i \propto 1/\sigma_i$. Minimum-variance and max-diversification portfolios are nearby relatives.

## Assumptions

- **Risk (volatility/covariance) is the right thing to equalize** — implicitly treats vol as the relevant risk and as a proxy for expected return (leverages the empirical low-vol / risk-return relation).
- $\Sigma$ is known and stable (still an estimate — but far more robust than $\mu$).
- Often assumes **long-only**, fully invested.
- Volatility is a sufficient risk statistic (ignores skew, tails, liquidity — same Gaussian blind spot as MVO).
- To deliver equity-like returns from low-vol assets, it usually **levers up** the whole book (the All Weather / leveraged risk-parity implementation).

## How it breaks in real markets

- **Leverage is the hidden risk.** Because low-vol assets (bonds) get high weight, achieving target returns requires leverage — and leverage turns a "diversified" book into one exposed to **rates and funding**. The 2020 March / 2022 bond crash hit leveraged risk-parity hard: stocks *and* bonds fell together (positive correlation), so "risk balance" across the two failed.
- **Correlation regime shifts**: ERC's diversification assumes stable, low correlations. In crises correlations spike to ~1, risk contributions concentrate, and the equalization unravels exactly when needed.
- **Vol clustering / procyclicality**: as vol rises, weights shrink → forced deleveraging into falling markets (a momentum-like, trend-amplifying feedback).
- **Still Gaussian**: equalizes variance, not tail risk; fat-tailed assets can dominate true risk while looking balanced on $\sigma$.
- **Concentration in the least volatile**: can over-weight bonds/cash-like assets, creating unintended duration and carry bets.

## What practitioners actually use

- **A mainstream institutional allocation framework** (AQR, Bridgewater, many OCIO/wealth managers) — valued for robustness (no $\mu$ needed), low turnover, and intuitive "balanced risk" narrative.
- **Risk budgeting** generalized: set $b_i$ to express views on *which risks* to take, rather than equalizing.
- Often combined with **trend/time-series momentum overlays** to manage the leverage/drawdown problem (e.g. managed-futures on top of risk parity).
- Uses **shrinkage / robust covariance** and **vol-targeting** to tame procyclical deleveraging.
- Tail-risk extensions: equalize **CVaR / expected shortfall** or drawdown contributions instead of variance for fat-tailed books.
- Serves as the optimizer stage under a [[theory-black-litterman]] return view in some shops.

## Links

- Return-free alternative to → [[theory-markowitz]]
- Shares the "only need $\Sigma$" philosophy; often the optimizer under → [[theory-black-litterman]]
- Sizing/leverage discipline related to → [[theory-kelly]]
- Index: [[CANON]]

## Key references

- Qian (2005), *Risk Parity Portfolios*.
- Maillard, Roncalli & Teïletche (2010), *The Properties of Equally Weighted Risk Contribution Portfolios*, JoPM.
- Bruder & Roncalli (2012), *Managing Risk Exposures Using the Risk Budgeting Approach*.
- Roncalli (2013), *Introduction to Risk Parity and Budgeting* (book).
