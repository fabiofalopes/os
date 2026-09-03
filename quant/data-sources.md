---
title: Data Sources (FREE layer)
type: data-source
status: living
owner: pane-5-data
sources: [yfinance, ccxt, FRED]
coverage: "equities/ETFs + crypto majors (daily) + macro (mixed freq)"
workspace: "~/Projects/trading-agents/quant-research/data/"
created: 2026-07-23
updated: 2026-07-23
tags: [quant/data, quant/infrastructure, quant/reference]
---

# Data Sources (FREE layer)

> The data layer for the research→deployment pipeline. Everything here is **free and
> keyless** for the sample pulls. Fetchers + sample CSVs live in the workspace at
> `~/Projects/trading-agents/quant-research/data/` (see `data/SOURCES.md` there for the
> full technical reference). This note is the knowledge-base summary.

## Sources at a glance

| Asset class | Source | Library | Freq | Sample universe |
|---|---|---|---|---|
| Equities / ETFs | Yahoo Finance | `yfinance` | Daily | SPY, QQQ, IWM, AAPL, MSFT, GOOGL, AMZN, JPM |
| Crypto | Binance (public REST) | `ccxt` | Daily | BTC, ETH, SOL, BNB, XRP (vs USDT) |
| Macro | FRED (keyless CSV) | `urllib`/`requests` | Mixed | SP500, VIXCLS, DFF, DGS10, T10Y2Y, CPIAUCSL, UNRATE |

Standardized CSV schema: equities `date,open,high,low,close,adj_close,volume`; crypto
`date,open,high,low,close,volume` (UTC); macro `date,value`. All dates ISO `YYYY-MM-DD`.

## Why these three

- **yfinance** — zero-setup daily bars for any US-listed equity/ETF. The workhorse for
  cross-sectional and time-series equity studies ([[Cross-Sectional Momentum (12-1)]],
  [[Time-Series Momentum (Trend-Following)]], [[Pairs Trading (Cointegration)]],
  [[Quality (Profitability) Factor]]).
- **ccxt** — one API across 100+ exchanges; public OHLCV needs no key. Feeds the crypto
  strategies ([[Crypto Funding-Rate Carry]], [[Time-Series Momentum (Trend-Following)]]).
- **FRED** — the canonical free macro database. Rates/vol/levels for regime filters and
  macro-conditioned signals ([[Betting-Against-Beta (Low-Volatility)]], trend overlays).

## Limitations (read before trusting the data)

- **Yahoo is unofficial/unrated** — research-grade only, not for production or audited
  backtests. Use `adj_close` (not raw `close`) for returns; expect occasional bad bars, no SLA.
- **Crypto is OHLCV-only for now** — **no funding rates, order book, or trades yet**, which
  [[Crypto Funding-Rate Carry]] requires. Binance can be geo-blocked; the fetcher takes
  `--exchange kraken/coinbase/okx`. Crypto bars include weekends (24/7 market).
- **FRED frequencies are mixed** — `CPIAUCSL` and `UNRATE` are **monthly**, the rest daily.
  Resample/align before joining, and build a **point-in-time** merge to avoid look-ahead bias.
- **Sample is intentionally tiny** (~1.8 MB, a handful of tickers, ~2y) — it validates the
  plumbing, it is not a backtest dataset. No survivorship-bias handling in the fixed equity list.
- **Calendar mismatch** — equity dates are exchange-local close, crypto is UTC; don't merge
  across asset classes without aligning calendars.

## Gaps → next steps

- Crypto **8h funding-rate history** + perp OHLCV (unblocks [[Crypto Funding-Rate Carry]]).
- Intraday bars (yfinance 1m for short windows; ccxt lower timeframes) for
  [[Overnight vs Intraday Return Anomaly]] and microstructure work.
- Fundamentals/earnings dates and a proper point-in-time macro loader.
- A shared `data/load.py` returning aligned DataFrames for the backtest engine.

## Links
- [[INDEX]] — map of content
- [[ROADMAP]] — research→deployment status board
- [[CANON]] — curated paper/source map
- [[Crypto Funding-Rate Carry]] — primary consumer of the crypto gap
- [[Time-Series Momentum (Trend-Following)]] — consumes equities + crypto daily bars
