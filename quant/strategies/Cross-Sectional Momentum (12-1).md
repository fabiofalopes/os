---
title: Cross-Sectional Momentum (12-1)
type: strategy-hypothesis
category: momentum
status: proposed
data-source: yfinance
priority: high
edge: "Winners (top-decile 12-1m returns) minus losers earn ~6-9%/yr in US equities; relative-rank signal."
decay: "High in crowded large-cap US; medium in crypto cross-section; crashes hard in sharp reversals (momentum crashes)."
tags: [quant/strategy, quant/momentum]
created: 2026-07-23
---

# Cross-Sectional Momentum (12-1)

## Source
- **Jegadeesh & Titman (1993)**, "Returns to Buying Winners and Selling Losers." Formation 12m, skip 1m, hold 1–12m.
- **Asness, Moskowitz & Pedersen (2013)**, "Value and Momentum Everywhere" — cross-sectional momentum across asset classes.
- Crash risk: **Daniel & Moskowitz (2016)**, "Momentum Crashes."

## Hypothesis
Rank a liquid universe by trailing 12-month return skipping the most recent month (12-1). Go long the top decile, short the bottom decile, dollar-neutral, equal- or vol-weighted, rebalanced monthly. The recent-month skip isolates intermediate momentum from [[Short-Term Reversal (1-Month)]].

## Expected edge & decay
- **Edge:** underreaction to firm-specific news + disposition effect + analyst forecast sluggishness.
- **Magnitude:** US equity long-short ~6–9%/yr pre-costs historically; crypto cross-section momentum stronger but noisier.
- **Decay:** high for US large-cap (widely known, arbitraged); the tail risk (momentum crashes when markets rebound from lows) is the real cost, not mean decay. Crypto less decayed.

## Data needed (FREE)
- US equities: daily/weekly OHLCV for a survivorship-aware universe. yfinance gives current S&P 500 / Russell constituents; **survivorship bias is the key data risk** — use a point-in-time-ish proxy or accept it as an upward bias and haircut results.
- Crypto: top ~50 by market cap via ccxt for a cross-section variant.

## Test design
1. **Universe:** 300–500 liquid US stocks (or S&P 500), 10+ years monthly rebalance.
2. **Signal:** 12-1 cumulative return; form deciles/quintiles.
3. **Portfolio:** long top / short bottom decile, market-neutral; vol-scale to 10%.
4. **Costs:** 5 bps/side + short-borrow proxy (exclude hard-to-borrow via price/size screen).
5. **Metrics:** long-short Sharpe, long-only vs short-leg decomposition, **crash exposure** (regress on market returns in down-markets; report conditional beta).
6. **Crash filter test:** add dynamic vol-scaling / market-trend overlay (cf. [[Time-Series Momentum (Trend-Following)]]) and measure DD reduction.
7. **Robustness:** vary formation (6-1, 12-1) and holding period; Fama-French 3-factor alpha to confirm not just beta.

## Failure modes / risks
- **Momentum crashes** (e.g., 2009 Q1): short losers rally hardest → mandatory vol/crash overlay.
- Survivorship bias inflates backtest → haircut and note explicitly.
- Crowding → expect lower live Sharpe than paper.

## Links
- Distillations: [[micro-momentum]] (microstructure view), [[theory-fama-french]] (factor-alpha benchmark)
- [[Time-Series Momentum (Trend-Following)]]
- [[Idiosyncratic (Residual) Momentum]]
- [[Short-Term Reversal (1-Month)]]
- [[Strategies Index]]
