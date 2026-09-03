---
title: "Kelly Criterion (Optimal Growth / Log-Optimal Betting)"
aliases: [Kelly, Kelly formula, Log-optimal portfolio, Growth-optimal portfolio, "Kelly 1956"]
tags: [theory, portfolio-theory, sizing, tier1, canon]
authors: [John L. Kelly Jr.]
year: 1956
source: "A New Interpretation of Information Rate, Bell System Technical Journal"
status: distilled
tier: 1
area: portfolio-theory
---

# Kelly Criterion

> Kelly (1956), "A New Interpretation of Information Rate." Popularized for gambling by Thorp (1969, *Beat the Dealer*; 1997, *The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market*). The question it answers: **given an edge, how much do you bet to maximize long-run compounded wealth?** Not "should I bet" but "how big."

## Core idea

Maximize the **expected logarithm of wealth** (equivalently, the expected geometric growth rate). Because wealth compounds multiplicatively, maximizing $E[\log W]$ maximizes the almost-sure asymptotic growth rate and minimizes the expected time to reach any wealth goal. It is the unique strategy that is never beaten in the long run (log-optimality / numéraire portfolio property).

## Core equations

**Binary bet** (win fraction $b$ with prob $p$, lose with prob $q=1-p$), fraction $f$ of bankroll staked:
$$g(f) = p\log(1+bf) + q\log(1-f)$$
$$\boxed{f^* = \frac{bp - q}{b} = \frac{bp-q}{b} \;=\; p - \frac{q}{b}}$$
For even-money ($b=1$): $f^* = p - q = 2p - 1$ (the "edge").

**Continuous / Gaussian approximation** (one asset, excess return mean $\mu$, variance $\sigma^2$):
$$f^* \approx \frac{\mu}{\sigma^2}$$
i.e. bet proportional to the Sharpe-squared-per-unit-risk; the optimal **leverage** is Sharpe$^2$/variance.

**Multi-asset Kelly** (vector of excess returns $\mu$, covariance $\Sigma$):
$$\boxed{w^* = \Sigma^{-1}\mu}$$
This is the *unconstrained, unit-risk-aversion* mean-variance solution — Kelly is the log-utility ($\gamma=1$) special case of [[theory-markowitz]]. Growth-optimal portfolio = the portfolio maximizing $E[\log(1+w^\top r)]$.

**Long-run growth rate**: $g^* = r_f + \tfrac{1}{2}\,\text{Sharpe}^2$ (continuous time, Merton). The max achievable geometric growth is set by the squared Sharpe ratio.

## Assumptions

- **Known** probabilities / return distribution (the fatal one — same estimation-error problem as MVO).
- Bets are repeatable and independent (or at least stationary); you can rebalance continuously.
- Fractional betting: you can stake any fraction, borrow/lend, and survive any single outcome (no ruin constraint in the pure form — log utility allows arbitrarily deep drawdowns).
- No transaction costs, no minimum tick, no capacity limits.
- Objective is *asymptotic* growth — says nothing about the path, volatility of wealth, or drawdowns along the way.

## How it breaks in real markets

- **Estimation error → catastrophic overbetting.** Kelly is *hyper-sensitive* to the edge estimate: if you overestimate $\mu$, you overbet, and overbetting is far more damaging than underbetting (growth is asymmetric — betting $2f^*$ gives *zero* growth; beyond that, guaranteed decline). Since $\mu$ is the least estimable quantity, full Kelly on sample estimates is reckless.
- **Volatility of wealth is brutal.** Full Kelly has enormous variance: the expected **drawdown** is roughly equal to the expected peak (a 50% drawdown is typical; the median outcome lags the mean badly). The "time to recover" from deep drawdowns is long.
- **Non-stationarity & model risk**: real edges decay, regimes shift, and tails are fatter than Gaussian — the $\mu/\sigma^2$ formula understates true risk.
- **Correlations & leverage**: multi-asset Kelly inverts $\Sigma$ and can demand huge gross leverage in low-vol, correlated books — blows up precisely in crises.
- **No utility for the risk-averse**: log utility is one point on the risk-aversion spectrum; most investors/mandates cannot stomach full-Kelly drawdowns.

## What practitioners actually use

- **Fractional Kelly** is the universal fix: bet $c\cdot f^*$ with $c \in [0.25, 0.5]$. Half-Kelly keeps ~75% of the growth rate but cuts variance (and drawdown) by ~4×. The growth-rate-vs-fraction curve is **flat near the top and steep on the downside** — so underbetting costs little, overbetting costs a lot. This asymmetry is the single most important practical fact.
- **Shrink the edge, inflate the risk**: use conservative $\mu$ (Bayesian/shrunk), robust $\Sigma$, and add a safety haircut for model uncertainty. "Bet half of what you think, on half the edge you think you have."
- **Vol targeting / risk budgeting**: cap gross leverage and per-position risk rather than trusting the formula's leverage.
- **Drawdown and ruin constraints** layered on top (Kelly ignores them): stop-outs, max drawdown limits.
- Used as a **sizing** rule on top of a separate alpha signal — the alpha team finds the edge, Kelly (fractional) sizes it. Central to systematic funds (Thorp, Renaissance-adjacent lore, sports/arbitrage books).

## Links

- Log-utility special case of mean-variance → [[theory-markowitz]]
- Sizing a factor/strategy edge → [[theory-fama-french]]
- Index: [[CANON]]

## Key references

- Kelly (1956), *A New Interpretation of Information Rate*, BSTJ.
- Thorp (2006), *The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market*.
- MacLean, Thorp & Ziemba (2011), *The Kelly Capital Growth Investment Criterion*.
- Cover & Thomas, *Elements of Information Theory* (log-optimal portfolio / universal portfolios).
