---
title: Time-Series Momentum (Trend-Following)
type: strategy-hypothesis
category: momentum
status: proposed
data-source: ccxt + yfinance
priority: high
edge: "Assets with positive trailing-12m excess returns keep outperforming; each asset bets on its own sign, not relative rank."
decay: "Medium — crowded since 2010s, but crypto TSMOM still strong; equity TSMOM sharpe ~0.5 post-2000 vs ~1.0 pre-2000."
tags: [quant/strategy, quant/momentum, quant/trend]
created: 2026-07-23
---

# Time-Series Momentum (Trend-Following)

## Source
- **Moskowitz, Ooi & Pedersen (2012)**, "Time Series Momentum," *JFE*. 58 instruments, 25 years: past 12-month return predicts next-month return, sign-consistent.
- Practitioner: managed futures / CTA trend-following (AQR, Winton, Man AHL). See [[CANON]] momentum section.
- Crypto extension: Liu, Tsyvinski & Wu (2022) "Risks and Returns of Cryptocurrency" — crypto exhibits strong momentum.

## Hypothesis
For each liquid asset, go long if its trailing 12-month (skip last month) excess return is positive, short if negative, sized inversely to realized volatility. In crypto (24/7, no earnings gaps), use a faster lookback (4–12 weeks). The signal is **absolute** (own past return), distinct from [[Cross-Sectional Momentum (12-1)]].

## Expected edge & decay
- **Edge:** behavioral underreaction to news + herding; crisis alpha (positive in drawdowns / rate-of-change regimes).
- **Magnitude:** crypto TSMOM Sharpe historically ~1.0–1.5; equity index TSMOM ~0.4–0.6.
- **Decay:** moderate. Crowding compresses equity TSMOM; crypto less efficient but decaying as derivatives mature. Whipsaw in choppy/range-bound regimes is the main PnL leak.

## Data needed (FREE)
- Crypto: daily OHLCV for top ~20 liquid perps/spot via **ccxt** (Binance/Coinbase). Funding optional.
- Equities: daily OHLCV for S&P 500 + sector ETFs + a universe of large caps via **yfinance**.
- Risk-free rate: yfinance `^IRX` / FRED (optional; use 0 for crypto).

## Test design
1. **Universe:** 20 crypto + 100 liquid US equities/ETFs, 5+ years daily.
2. **Signal:** sign of trailing L-month return, L ∈ {1,3,6,12} months; skip last week (crypto) / last month (equities) to avoid short-term reversal.
3. **Sizing:** vol-target each position to equal risk (1/σ, σ = 60d realized vol), portfolio vol-targeted to 10% annualized.
4. **Costs:** crypto 5–10 bps/side + slippage; equities 2–5 bps.
5. **Metrics:** Sharpe, Sortino, max DD, hit-rate, turnover; **crisis alpha** = return during top-decile market drawdowns.
6. **Robustness:** parameter surface over L and vol window (reject if only profitable in a narrow band); block-bootstrap CIs; out-of-sample last 2 years.
7. **Null:** vs. buy-and-hold and vs. randomized-sign permutation test.

## Failure modes / risks
- Whipsaw losses in mean-reverting/choppy regimes → add trend-strength/vol filter.
- Transaction costs at high rebalance frequency → rebalance weekly, threshold bands.
- Crypto regime shifts (bull→bear) and exchange risk.

## Links
- Distillation: [[micro-momentum]]
- [[Cross-Sectional Momentum (12-1)]] — relative-rank cousin
- [[Volatility-Managed Portfolios]] — vol scaling shared
- [[Crypto Funding-Rate Carry]] — often combined as diversified trend+carry
- [[Strategies Index]]
