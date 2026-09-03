---
title: Betting-Against-Beta (Low-Volatility)
type: strategy-hypothesis
category: factor
status: proposed
data-source: yfinance
priority: high
edge: "Low-beta/low-vol stocks deliver higher risk-adjusted returns than high-beta; lever low-vol, short high-vol."
decay: "Medium — persistent since 1926, but leverage cost and crowding compress live returns."
tags: [quant/strategy, quant/factor, quant/low-vol]
created: 2026-07-23
---

# Betting-Against-Beta (Low-Volatility)

## Source
- **Frazzini & Pedersen (2014)**, "Betting Against Beta." Constrained investors overpay for high-beta → low-beta + leverage beats.
- **Ang, Hodrick, Xing & Zhang (2006)**, "The Cross-Section of Volatility and Expected Returns" — high idiosyncratic vol → low returns.
- Practitioner: low-volatility / minimum-variance smart-beta (AQR, Robeco, S&P Low Vol indices).

## Hypothesis
Rank stocks by beta (or realized volatility). Go long low-beta names levered up to market beta ≈ 1, short high-beta names levered down — a market-neutral "betting-against-beta" (BAB) portfolio. Equivalently, a long-only low-vol tilt outperforms on a risk-adjusted basis. The anomaly is a violation of the CAPM security-market line.

## Expected edge & decay
- **Edge:** leverage constraints + lottery/skewness preference make investors overpay for high-beta; low-vol is under-owned.
- **Magnitude:** BAB Sharpe ~0.7–1.0 in the paper (US, 1926+); low-vol long-only risk-adjusted outperformance a few %/yr.
- **Decay:** medium — one of the most persistent anomalies, but live returns depend critically on **financing/leverage cost**; crowding since ~2010.

## Data needed (FREE)
- US equities daily OHLCV, 300+ names, 10+ years (yfinance).
- Market factor: cap-weighted or equal-weighted universe return (build in-house).
- Risk-free rate: yfinance `^IRX` (T-bills).

## Test design
1. **Universe:** 300–500 liquid US stocks, monthly rebalance, 10+ years.
2. **Signal:** rolling 1-year beta (regress on market) OR realized vol; form quintiles.
3. **BAB portfolio:** long low-beta (levered to β=1), short high-beta (levered to β=1) → market-neutral; also build long-only low-vol quintile.
4. **Costs:** 5 bps/side + **explicit financing cost on leverage** (e.g., SOFR+spread proxy) — this is decisive.
5. **Metrics:** Sharpe, alpha vs FF3/FF5, performance in down-markets (low-vol should be defensive), leverage-adjusted return.
6. **Robustness:** beta vs realized-vol vs idiosyncratic-vol signals side by side; vary estimation window.
7. **Risk:** report max DD and the leverage required; confirm edge survives realistic financing.

## Failure modes / risks
- **Financing cost** can erase the levered edge in a high-rate regime.
- Underperforms badly in strong risk-on rallies (low-beta lags) → long-only version avoids short-leg pain.
- Sector concentration (low-vol = utilities/staples) → industry-neutralize to test pure effect.

## Links
- Distillations: [[theory-capm]] (the security-market line BAB violates), [[theory-fama-french]]
- [[Quality (Profitability) Factor]]
- [[Volatility Risk Premium Harvest]]
- [[Idiosyncratic (Residual) Momentum]]
- [[Strategies Index]]
