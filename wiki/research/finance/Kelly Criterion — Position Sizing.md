---
tags: [research, finance, quant, position-sizing, risk, source-clip]
date: 2026-07-20
sources:
  - "Kelly, J.L. Jr. (1956), Bell Labs — original criterion"
  - "MacLean, Thorp & Ziemba — The Kelly Capital Growth Investment Criterion (World Scientific, 2011)"
  - "en.wikipedia.org/wiki/Kelly_criterion — fetched 2026-07-20"
  - "Thorp, E.O. — The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market (Handbook of Statistics, 2006) — NOT fetched (dead mirrors)"
status: clipped — Wikipedia + Thorp book page fetched & verified 2026-07-20; Thorp 2006 paper unfetched
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Kelly Criterion — Position Sizing

> **What it gives the harness:** *how not to go bust.* An edge tells you **what** to bet; Kelly tells you **how much**. Non-negotiable before any live capital (constitution directive 4: human authorizes capital, paper before live).

## The core idea (verified)
- Size a sequence of bets to maximize the **long-term expected logarithm of wealth** — equivalently the long-term expected **geometric growth rate**. Kelly, J.L. Jr., Bell Labs, 1956. *(Wikipedia, fetched)*
- Theorems (Thorp book page, fetched): only the log-utility strategy **maximizes asymptotic long-run wealth** and **minimizes the expected time to reach any arbitrarily large wealth goal**.
- Binary-outcome formula: `f* = p/l − q/g` — p = prob of gain, q = 1−p, g = fraction gained on a win, l = fraction lost on a loss. Gambling form (lose the whole stake, l=1): `f* = p − q/b`, b = odds received. f* ≤ 0 → no edge, don't bet. *(Wikipedia, fetched)*
- Stock market / continuous case: with a riskless bond at r and risky assets, maximize `E[ln((1+r) + Σ u_k·(r_k − r))]` over fractions u_k. For one geometric-Brownian asset (drift μ, vol σ) this yields the standard closed form `f* ≈ (μ−r)/σ²` — i.e. **Kelly fraction ≈ Sharpe² / variance = excess return over variance**. *(Objective verified on Wikipedia; closed form is textbook/Thorp 2006, paper unfetched.)*
- Worked sanity check (Wikipedia): excess return 4%, volatility 16% → Sharpe 25%/yr → Kelly ≈ 150% of capital. Thorp & co-author estimate full Kelly for the S&P 500 at ~117%.

## The catch — why nobody sane bets full Kelly (verified)
- **Short-term risk is real:** the Kelly bettor is wealthier than essentially-different bettors *most* of the time, but "can lead to considerable losses a small percent of the time." *(Thorp book page)*
- **Overbetting is worse than underbetting:** betting more than the Kelly amount **increases the risk of ruin**; growth falls off faster above f* than below it. *(Wikipedia)*
- **Garbage in, garbage out:** the formula takes μ and the covariance structure as *given*, but they are estimates with large uncertainty. "If portfolio weights are largely a function of estimation errors, ex-post performance may differ fantastically from the ex-ante prediction." The standard countermeasure: **invest less than Kelly.** *(Wikipedia, fetched)*
- **Fractional Kelly** (half/quarter) blends the Kelly wager with cash: lower expected final wealth, but much lower volatility, lower ruin chance, and a buffer for model error. Practitioners find full Kelly emotionally unlivable due to drawdowns; half-Kelly is the common compromise. *(Wikipedia + Thorp book page)*

## Verdict
★★★ — pairs inseparably with [[López de Prado — Backtest Overfitting Guards]]: Kelly converts an edge estimate into leverage, so an **overfit edge estimate fed to Kelly = systematic overbetting = amplified ruin**. The two clips are one weapon: verify the edge (DSR/PBO), then size it (fractional Kelly on the *deflated* edge, never the raw backtest number). Forge rule adopted: any future sizing uses fractional Kelly (≤ half), on paper first, with the edge estimate discounted for trial count; capital deployment stays human-authorized (Z4).

## Evidence ledger
- ✅ Fetched 2026-07-20: `en.wikipedia.org/wiki/Kelly_criterion` (formula, fractional Kelly, GIGO, Thorp S&P estimate); `edwardothorp.com/books/kelly-capital-growth-investment-criterion/` (theorems, short-term risk, fractional Kelly).
- ⚠️ Thorp 2006 paper PDF: Harvard + UW mirrors dead, no Wayback snapshot — closed form f*≈(μ−r)/σ² labeled textbook knowledge, not session-verified.
- ⚠️ "Half-Kelly = ¾ of full-Kelly growth" (quadratic approximation near optimum): standard result, NOT verified this session — aspiration until sourced.
- Sources: [Kelly criterion (Wikipedia)](https://en.wikipedia.org/wiki/Kelly_criterion) · [Thorp — Kelly Capital Growth Investment Criterion](https://www.edwardothorp.com/books/kelly-capital-growth-investment-criterion/)
