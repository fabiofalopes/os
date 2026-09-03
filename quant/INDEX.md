---
title: Quant — Index / Map of Content
type: moc
status: living
owner: pane-8-synthesis
co-maintainer: pane-1-cartography (note inventory)
created: 2026-07-23
updated: 2026-07-23 05:15
tags: [quant, moc, index]
---

# 🧭 Quant — Map of Content

> Entry point to the quant knowledge base. Maintained by pane 8 (synthesis).
> Every note in `~/obsidian-vault-kali/quant/` should be linked from here.

## Master docs
- [[ROADMAP]] — living research → deployment roadmap + status board
- [[CANON]] — master map of essential trading knowledge (tiered; ✅ merged with deep-research verification)
- [[CANON-researched]] — adversarially-verified paper map from deep-research workflow wf_6b6298b8 (merge source)
- [[Strategies Index]] — index of all tradeable strategy-hypotheses
- [[theory-moc]] — Theory MOC: Tier-1 distillations (sub-index)

## 📚 Canon & distillations (`papers/`)
**Portfolio theory:**
- [[theory-markowitz]] — Mean-Variance Portfolio Theory (1952, tier-1)
- [[theory-capm]] — Capital Asset Pricing Model (1964, tier-1)
- [[theory-black-litterman]] — Black-Litterman Model (1992, tier-1)
- [[theory-kelly]] — Kelly Criterion (1956, tier-1)
- [[theory-risk-parity]] — Risk Parity & Risk Budgeting (2005, tier-1)
- [[theory-fama-french]] — Fama-French Factor Models (3- & 5-factor, tier-1/2)

**Derivatives & volatility:**
- [[theory-black-scholes]] — Black-Scholes-Merton Option Pricing (1973, tier-1)
- [[theory-heston]] — Heston Stochastic Volatility Model (1993, tier-1)
- [[theory-local-vol]] — Local Volatility / Dupire's Equation (1994, tier-2)

**Microstructure:**
- [[micro-kyle-1985]] — Kyle: Continuous Auctions & Insider Trading (price impact)
- [[micro-glosten-milgrom-1985]] — Glosten-Milgrom: bid-ask & adverse selection
- [[micro-almgren-chriss-2000]] — Almgren-Chriss: optimal execution
- [[micro-avellaneda-stoikov-2008]] — Avellaneda-Stoikov: HFT market-making
- [[micro-market-impact]] — Square-root impact law & practitioner cost models
- [[micro-order-flow-toxicity]] — Order-Flow Toxicity: PIN & VPIN (Easley, López de Prado, O'Hara)
- [[micro-momentum]] — Momentum: Jegadeesh–Titman (1993) & Moskowitz TSMOM (2012)
- [[micro-stat-arb-cointegration]] — Stat-Arb & Cointegration: Engle–Granger (1987) & Gatev pairs (2006)
- [[micro-hft-practitioner]] — HFT & Execution Practitioner Knowledge

## 💡 Strategies & hypotheses (`strategies/`)
_IDs per canonical `strategies/HYPOTHESES.md` (pane 4). P1 build-first · P2 next · P3 data-constrained._
- [[Time-Series Momentum (Trend-Following)]] — H01, momentum (P1)
- [[Cross-Sectional Momentum (12-1)]] — H02, momentum (P1)
- [[Idiosyncratic (Residual) Momentum]] — H03, momentum (P3)
- [[Short-Term Reversal (1-Month)]] — H04, mean-reversion (P1)
- [[Pairs Trading (Cointegration)]] — H05, mean-reversion (P2)
- [[Overnight vs Intraday Return Anomaly]] — H06, mean-reversion (P2)
- [[Betting-Against-Beta (Low-Volatility)]] — H07, factor (P1)
- [[Quality (Profitability) Factor]] — H08, factor (P3)
- [[Crypto Funding-Rate Carry]] — H09, carry (P1)
- [[Volatility Risk Premium Harvest]] — H10, volatility (P2)
- [[Volatility-Managed Portfolios]] — H11, volatility overlay (P1)
- [[Avellaneda-Stoikov Crypto Market-Making]] — H12, market-making (P1)
- [[Cash-and-Carry Basis Arbitrage]] — H13, relative-value (P2)
- [[Strategies Index]] — master index of all strategy-hypotheses

## 📈 Backtests
- [[backtest-results]] — backtest results across strategy hypotheses (pane-3 backtest)

## 🛡️ Risk
- [[risk-framework]] — Sizing (fractional Kelly + vol targeting), drawdown limits, concentration rules, paper→live ramp (pane 7; code `risk/sizing.py`)

## 🗃️ Data
- [[data-sources]] — free-data layer: sources, fetchers, sample datasets (pane-8 data)

## 🔀 Synthesis (pane 8)
- [[synthesis-anomaly-persistence]] — answers pane 4's open questions: anomaly decay priors, H03 factor-model choice, combining H01+H09+H12

## 🧩 Concepts / glossary (`concepts/`)
- _none yet_

---
_Updated 2026-07-23 — full inventory reconciled by pane-1 (cartography): 19 distillations + 14 strategies + backtest-results + data-sources + risk-framework + CANON linked. Pane-8 (synthesis) retains ownership of the status board; pane-1 keeps the note inventory in sync._
