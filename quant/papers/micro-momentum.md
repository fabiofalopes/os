---
title: "Momentum: Jegadeesh–Titman (1993) & Moskowitz Time-Series Momentum (2012)"
authors: [Narasimhan Jegadeesh, Sheridan Titman, Tobias Moskowitz, Yao Hua Ooi, Lasse Pedersen]
year: 1993
type: paper-distillation
domain: microstructure
tags: [momentum, trend, cross-sectional, time-series, anomaly, factor, behavioral, risk]
status: distilled
created: 2026-07-23
citekey: momentum
---

# Momentum — Cross-Sectional (J–T 1993) & Time-Series (Moskowitz 2012)

Part of [[CANON]]. Sibling notes: [[micro-stat-arb-cointegration]], [[micro-market-impact]], [[micro-hft-practitioner]].

## One-liner
**Winners keep winning, losers keep losing.** *Cross-sectional* momentum (Jegadeesh–Titman): buy recent winners / sell recent losers earns abnormal returns over 3–12 months. *Time-series* momentum (Moskowitz–Ooi–Pedersen): each asset's *own* past return predicts its *own* next return — a persistent, cross-asset **trend** effect that survives across 58 instruments and decades.

## The models
- **Cross-sectional (J–T 1993):** rank stocks on past `J`-month return (skip the most recent month), form decile portfolios, hold `K` months. The **winner-minus-loser** spread earns ~1%/month over 3–12 month horizons, not explained by CAPM.
- **Time-series (Moskowitz, Ooi, Pedersen 2012):** for each of 58 liquid instruments (equity indices, commodities, bonds, FX), go long if its own trailing 12-month return is positive, short if negative, size by inverse volatility. A **directional trend** bet, market-neutral only in aggregate.
- Both are usually implemented with **~12-month lookback, ~1-month holding, volatility-scaled, skipping the last week/month** (to dodge short-term reversal).

## Key equations
- **Cross-sectional signal:** `r_{i,t+1} ~ rank( Σ_{τ=t−J}^{t−1} r_{i,τ} )` — relative, zero-sum across names.
- **Time-series signal:** `sign( Σ_{τ=t−12}^{t−1} r_{i,τ} )` per asset — absolute, each asset trades its own trend.
- **Vol scaling:** position `∝ signal / σ_i` — equalizes risk contribution; essential for cross-asset TSM.
- **Return decomposition:** momentum profits = continuation during months 2–12, partially reversing in months 13–24 (long-run reversal).

## Assumptions
1. **Returns are predictable from past returns** over the medium term — a violation of the random walk / semi-strong EMH.
2. **Transaction costs are low enough** to survive weekly/monthly rebalancing of high-turnover portfolios — the original anomaly is *cost-sensitive*.
3. **The effect is stationary** across regimes and decades (it largely is, but with violent episodes).
4. **Risk-adjustment is adequate** — momentum is not payment for a priced risk factor (debated; it *is* a priced factor in Carhart's 4-factor model).
5. TSM assumes **volatility is estimable and mean-reverting enough** to scale by.

## How it breaks live
- **Momentum crashes.** The signature failure: in sharp market rebounds (e.g. 2009), recent losers (high-beta, distressed) rip while recent winners lag → the long/short book gets crushed on *both* sides. Momentum has **negative skew / crash risk** — it sells tail insurance.
- **Crowding & decay:** the anomaly is well-known; post-publication returns are lower, and crowded unwinds (Aug 2007 "quant quake") cause simultaneous, violent drawdowns as everyone de-risks the same factors.
- **Transaction costs & turnover eat it:** high rebalancing frequency + large short book → impact and borrow costs ([[micro-market-impact]]) can erase the edge, especially in small caps.
- **Short-term reversal contamination:** the last week/month *reverses*; failing to skip it turns the signal against you.
- **Regime dependence:** momentum thrives in trending, dispersed markets and bleeds in choppy, mean-reverting, low-dispersion regimes; a static allocation over-trades in the wrong regime.
- **Behavioral vs risk debate is unresolved:** if it's mispricing (underreaction to news, disposition effect), it can persist; if it's hidden risk, you're being paid to bear crash risk you may not want.

## Deployable takeaways
- **Trade the medium-term trend, skip the short-term reversal:** 12-month lookback excluding the last month, ~monthly rebalance — the robust core.
- **Volatility-scale everything** and cap gross/sector/beta exposure; momentum's raw form is a hidden high-beta bet that blows up in rebounds.
- **Manage the crash tail explicitly:** add a market-trend / volatility overlay (reduce momentum when market vol spikes or the broad market turns), or buy tail protection — don't run raw momentum through a regime shift.
- **Mind capacity and cost:** momentum is capacity-constrained by impact and borrow; backtest with realistic TCA ([[micro-market-impact]]) and prefer liquid names.
- **Use dispersion as a regime filter:** cross-sectional momentum needs *cross-sectional dispersion*; when dispersion collapses, expect weak signals.
- **TSM as a diversifying, directional overlay:** time-series momentum is less crowded and cross-asset; combine with cross-sectional for a more robust trend book.
- **Combine with microstructure:** enter momentum positions with patient execution ([[micro-almgren-chriss-2000]]) and avoid trading into high-toxicity flow ([[micro-order-flow-toxicity]]).

## Connections
- Strategy-side notes (owned by the strategies pane — implementation detail): [[Cross-Sectional Momentum (12-1)]], [[Time-Series Momentum (Trend-Following)]], [[Idiosyncratic (Residual) Momentum]], [[Short-Term Reversal (1-Month)]]. This note is the *microstructure/execution* lens on the same papers.
- [[micro-stat-arb-cointegration]] — the mean-reversion counterpart; momentum (trend) vs pairs (reversion) at different horizons.
- [[micro-market-impact]] — the transaction-cost ceiling on momentum capacity.
- [[micro-almgren-chriss-2000]] — execute the high-turnover rebalance efficiently.
- [[micro-order-flow-toxicity]] — avoid entering into adverse flow.
- [[micro-hft-practitioner]] — short-horizon momentum/OFI at the tick level.
- [[CANON]]

## References
- Jegadeesh, N., & Titman, S. (1993). "Returns to Buying Winners and Selling Losers." *Journal of Finance* 48(1): 65–91.
- Moskowitz, T., Ooi, Y. H., & Pedersen, L. (2012). "Time Series Momentum." *Journal of Financial Economics* 104(2): 228–250.
- Carhart, M. (1997) — 4-factor model adding UMD/momentum.
- Daniel, K. & Moskowitz, T. (2016) — "Momentum Crashes."
- Asness, C., Moskowitz, T., & Pedersen, L. (2013) — "Value and Momentum Everywhere."
