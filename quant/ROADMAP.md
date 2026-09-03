---
title: Quant Research → Deployment Roadmap
type: roadmap
status: living
owner: pane-8-synthesis
created: 2026-07-23
updated: 2026-07-23 09:35
tags: [quant, roadmap, moc, synthesis]
---

# 🗺️ Quant Roadmap — Research → Deployment

> **Living master document.** Synthesized by pane 8 from all panes' Vault notes and workspace artifacts.
> Grounded in the academic canon **and** practitioner wisdom ("follow success, study the past").
> See also: [[INDEX]] (Map of Content) · [[CANON]] (curated paper map, landing soon).

---

## 📊 STATUS BOARD

| Pane | Role | Vault / workspace | Status | Latest |
|------|------|-------------------|--------|--------|
| 1 | theory / canon | `papers/` | 🟢 | 9 theory notes distilled |
| 2 | alpha / hypotheses | `strategies/` | 🟢 | canonical `HYPOTHESES.md` registry (H01–H13, P1/P2/P3) |
| 3 | data | `data/` | 🟢 | raw data pulled + [[data-sources]] note |
| 4 | backtest | `backtests/` | 🟢 | engine validated + baseline results ([[backtest-results]]) |
| 5 | risk | `risk/` | 🟢 | [[risk-framework]] + `sizing.py` |
| 6 | microstructure | `papers/`, `data/` | 🟢 | 9 micro notes distilled |
| 7 | cartography | `CANON.md` | 🟡 | CANON map built (🟡 pending verify) |
| 8 | **synthesis (me)** | `synthesis/`, this doc | 🟡 | ROADMAP skeleton |

Legend: ⬜ not started · 🟡 in progress · 🟢 done · 🔴 blocked

**Pipeline:** Canon → Distillation → Hypothesis → Data → Backtest → Risk → Deploy
**Current stage:** `4 — engine validated, first results in` (CANON + 18 distillations + 13 hypotheses + [[risk-framework]] + validated `harness.py` + [[backtest-results]]). **Now:** baselines run on a FRED-derived 3-asset panel (Yahoo rate-limited the ETF universe). **Next bottleneck:** fetch the full ETF universe (`fetch_retry.py`) → regenerate on true total returns, then run the actual H1–H13 with OOS splits + parameter sweeps.

---

## 1. CANON STATUS

_State of the literature canon + practitioner sources. Owner: theory/microstructure → [[CANON]]._

- [x] [[CANON]] master map built (cartographer) — **tiered**: 🏛️ Tier 1 canon · 🧩 Tier 2 extensions · 🚀 Tier 3 frontier · 📚 Practitioner books & blogs
- [x] **Deep-research paper map MERGED into [[CANON]]** ([[CANON-researched]], workflow `wf_6b6298b8`, 107 agents, **25 claims adversarially confirmed at 3-vote**). Source-confirmed entries now ✅ (DOI/pages added); entries the run didn't cover stay 🟡 = **gaps for a follow-up round, not rejections**. Do not cite a 🟡 entry downstream until de-flagged.
  - **✅ Verified:** Engle-Granger (cointegration), Jegadeesh-Titman (momentum), Heston, Black-Scholes, Almgren-Chriss, Fama-French 93/15, Harvey-Liu-Zhu (t>3.0), McLean-Pontiff (**26% OOS / 58% post-pub decay**), Bailey/López de Prado (PBO + Deflated Sharpe), Gu-Kelly-Xiu (ML), Hambly-Xu-Yang (RL survey).
  - **🟡 Still unverified (gaps):** portfolio allocation (Markowitz/Kelly/Black-Litterman/risk parity), CAPM, microstructure (Kyle/Glosten-Milgrom/Avellaneda-Stoikov/VPIN), risk mgmt (Jorion VaR / tail) — i.e. several of our distilled notes are distilled but not yet source-verified.
- [x] Core academic papers selected & ingested (18 distilled so far)
- [x] Seminal practitioner books / blogs captured (in [[CANON]])
- [ ] Each canon entry has a distillation note (18 of ~40 done)

| Source | Type | Topic | Ingested | Distilled |
|--------|------|-------|----------|-----------|
| [[theory-markowitz]] | academic (1952) | portfolio theory / MVO | ✅ | ✅ |
| [[theory-capm]] | academic (1964) | asset pricing / beta | ✅ | ✅ |
| [[theory-fama-french]] | academic (1993) | factor models (FF3/FF5) | ✅ | ✅ |
| [[theory-black-litterman]] | academic (1992) | Bayesian view-tilting | ✅ | ✅ |
| [[theory-kelly]] | academic (1956) | optimal sizing / growth | ✅ | ✅ |
| [[theory-risk-parity]] | academic (2005) | risk-budgeted allocation | ✅ | ✅ |
| [[theory-black-scholes]] | academic (1973) | option pricing (BSM) | ✅ | ✅ |
| [[theory-heston]] | academic (1993) | stochastic volatility | ✅ | ✅ |
| [[theory-local-vol]] | academic (1994) | local vol (Dupire) | ✅ | ✅ |
| [[micro-kyle-1985]] | academic (1985) | price impact / Kyle's λ | ✅ | ✅ |
| [[micro-glosten-milgrom-1985]] | academic (1985) | bid-ask / adverse selection | ✅ | ✅ |
| [[micro-almgren-chriss-2000]] | academic (2000) | optimal execution | ✅ | ✅ |
| [[micro-avellaneda-stoikov-2008]] | academic (2008) | market-making quotes | ✅ | ✅ |
| [[micro-market-impact]] | practitioner (2005) | square-root impact law | ✅ | ✅ |
| [[micro-momentum]] | academic (1993/2012) | Jegadeesh-Titman + TSMOM | ✅ | ✅ |
| [[micro-stat-arb-cointegration]] | academic (1987/2006) | Engle-Granger + Gatev pairs | ✅ | ✅ |
| [[micro-order-flow-toxicity]] | academic (2011) | PIN / VPIN toxicity | ✅ | ✅ |
| [[micro-hft-practitioner]] | practitioner (2015) | HFT & execution lore | ✅ | ✅ |

---

## 2. DISTILLATION STATUS

_Distilled findings → `papers/` notes, linked from [[INDEX]]._ **18 distilled.**

**Portfolio theory & asset pricing (6):**
- [[theory-markowitz]] — MVO / efficient frontier. **Takeaway:** $\Sigma$ is estimable, $\mu$ is not → never raw MVO; shrinkage + constraints, benchmark vs $1/N$.
- [[theory-capm]] — beta/alpha language. **Takeaway:** report every strategy's **alpha vs market**, not raw return; beta alone isn't alpha.
- [[theory-fama-french]] — FF3/FF5 factor models. **Takeaway:** benchmark every equity strategy vs FF3/FF5; most "anomalies" are factor exposures in disguise.
- [[theory-black-litterman]] — Bayesian view-tilting on equilibrium prior. **Takeaway:** default portfolio-construction layer for heterogeneous alpha views; fixes MVO instability.
- [[theory-kelly]] — log-optimal sizing. **Takeaway:** size to edge/variance but use **fractional Kelly** (estimation error → over-betting).
- [[theory-risk-parity]] — risk-budgeted allocation. **Takeaway:** sidesteps $\mu$ entirely; only needs $\Sigma$ → robust baseline.

**Derivatives & volatility (3):**
- [[theory-black-scholes]] — BSM option pricing. **Takeaway:** use as a *quoting convention* (implied vol), not gospel; assumptions systematically violated.
- [[theory-heston]] — stochastic volatility + leverage effect. **Takeaway:** explains the smile/skew; fit the surface, never price exotics under flat vol.
- [[theory-local-vol]] — Dupire's equation. **Takeaway:** unique vol surface consistent with prices; building block for local-stochastic-vol.

**Microstructure (9):**
- [[micro-kyle-1985]] — Kyle's λ / price impact. **Takeaway:** model slippage as impact ∝ √(volume/ADV); never backtest without it.
- [[micro-glosten-milgrom-1985]] — spread = adverse-selection cost. **Takeaway:** spread is the floor on round-trip cost.
- [[micro-almgren-chriss-2000]] — optimal execution frontier (impact vs timing risk). **Takeaway:** execute on an optimal schedule, calibrate impact from own fills.
- [[micro-avellaneda-stoikov-2008]] — inventory-adjusted market-making quotes. **Takeaway:** center quotes on reservation price, widen with vol + inventory.
- [[micro-market-impact]] — square-root impact law + TCA. **Takeaway:** assume √-impact + long order-flow memory in cost models.
- [[micro-momentum]] — Jegadeesh-Titman (1993) + Moskowitz TSMOM (2012). **Takeaway:** academic backbone of H1/H2; momentum at months ≠ reversal at years.
- [[micro-stat-arb-cointegration]] — Engle-Granger (1987) + Gatev pairs (2006). **Takeaway:** basis for H8 pairs trading; equity returns decayed sharply post-2002.
- [[micro-order-flow-toxicity]] — PIN / VPIN (Easley-López de Prado-O'Hara). **Takeaway:** gauge adverse-selection risk; de-risk when order flow turns toxic.
- [[micro-hft-practitioner]] — HFT & execution lore. **Takeaway:** practical execution/market-making wisdom bridging the models to live venues.

---

## 3. HYPOTHESES

_Tradeable hypotheses derived from canon + practitioner lore. Owner: alpha → `strategies/`._ **Canonical registry: `strategies/HYPOTHESES.md` (pane 4) — IDs below adopt that source of truth.** 13 proposed, 0 backtested. See [[Strategies Index]].

| ID | Hypothesis | Category | Priority | Data | Status |
|----|-----------|----------|----------|------|--------|
| H01 | [[Time-Series Momentum (Trend-Following)]] | momentum | P1 | ccxt + yfinance | 🟡 proposed |
| H02 | [[Cross-Sectional Momentum (12-1)]] | momentum | P1 | yfinance | 🟡 proposed |
| H03 | [[Idiosyncratic (Residual) Momentum]] | momentum | P3 | yfinance + factor model | 🟡 proposed |
| H04 | [[Short-Term Reversal (1-Month)]] | mean-reversion | P1 | yfinance + ccxt | 🟡 proposed |
| H05 | [[Pairs Trading (Cointegration)]] | mean-reversion | P2 | yfinance + ccxt | 🟡 proposed |
| H06 | [[Overnight vs Intraday Return Anomaly]] | mean-reversion | P2 | yfinance OHLC + ccxt hourly | 🟡 proposed |
| H07 | [[Betting-Against-Beta (Low-Volatility)]] | factor | P1 | yfinance | 🟡 proposed |
| H08 | [[Quality (Profitability) Factor]] | factor | P3 | yfinance fundamentals (non-PIT) | 🟡 proposed |
| H09 | [[Crypto Funding-Rate Carry]] | carry | P1 | ccxt funding history | 🟡 proposed |
| H10 | [[Volatility Risk Premium Harvest]] | volatility | P2 | yfinance ^VIX/^VIX3M | 🟡 proposed |
| H11 | [[Volatility-Managed Portfolios]] | volatility | P1 | yfinance + ccxt (overlay) | 🟡 proposed |
| H12 | [[Avellaneda-Stoikov Crypto Market-Making]] | market-making | P1 | ccxt L2 order book | 🟡 proposed |
| H13 | [[Cash-and-Carry Basis Arbitrage]] | relative-value | P2 | ccxt futures | 🟡 proposed |

**Recommended build order (from HYPOTHESES.md, cheapest signal → most infra):** ① H01/H02/H07/H04 (daily bars, vol-target 10%) → ② H11 vol-managed overlay → ③ H09/H13 (funding/futures data) → ④ H06/H05 (hourly + cointegration) → ⑤ H10/H03 (proxy / factor model) → ⑥ H12 (LOB replay, most infra) → ⑦ H08 (blocked on point-in-time fundamentals).

**Open questions (pane 4 → theory/synthesis):** which anomalies are plausibly *persistent* vs arbitraged away (decay priors)? factor-model choice for H03 (market-only vs FF3 with free-data proxies)? portfolio construction — how to combine low-correlation H01+H09+H12 into one book? → **Answered in [[synthesis-anomaly-persistence]]** (decay-prior ranking → build H01/H10/H09 first; H03 strip with FF3 from the French library, market-only as null; combine sleeves in risk space, treat H09+H12 as one crypto risk bucket).

> **Guardrails from canon (apply to every backtest):** require t > 3.0 (Harvey-Liu-Zhu ✅); **haircut published anomaly returns ~50%+ before sizing** (McLean-Pontiff ✅: 26% OOS / 58% post-publication decay); report Deflated Sharpe + PBO with the trial count (Bailey/López de Prado ✅ — undisclosed-trial backtests are likely false positives); treat most anomalies as hypotheses (~65% fail to replicate, Hou-Xue-Zhang 🟡). See [[CANON]] Tier 2 "replication crisis." Standard bar (HYPOTHESES.md): net of realistic costs, parameter-surface robustness (reject if only profitable in a narrow band), OOS last 2y, block-bootstrap CIs.

---

## 4. DATA COVERAGE

_Data assets & gaps. Owner: data → `data/`._ **Raw data pulled** across 3 asset classes — see [[data-sources]] for schema + limitations.

| Dataset | Fetcher | Symbols | Freq | Status |
|---------|---------|---------|------|--------|
| Crypto OHLCV | `fetch_crypto.py` (ccxt) | BTC, ETH, SOL, BNB, XRP | daily | 🟢 5 CSVs in `data/raw/crypto/` |
| US equities/ETFs | `fetch_equities.py` / `fetch_yahoo.py` (yfinance) | SPY, QQQ, IWM, AAPL, MSFT, GOOGL, AMZN, JPM | daily | 🟢 8 CSVs in `data/raw/equities/` |
| Macro (FRED) | `fetch_macro.py` | SP500, VIXCLS, DGS10, T10Y2Y, DFF, CPIAUCSL, UNRATE | mixed | 🟢 7 CSVs in `data/raw/macro/` |

**Caveats (from [[data-sources]]):** sample is intentionally tiny (~2y, validates plumbing not a backtest dataset); Yahoo is research-grade only (use `adj_close`); CPIAUCSL/UNRATE are **monthly** (resample + point-in-time merge to avoid look-ahead); no survivorship-bias handling in the fixed equity list; equity (exchange-local) vs crypto (UTC) calendar mismatch.

**Gaps → next:** 🔴 **populate `data/raw/etf_universe/`** (SPY QQQ IWM EFA EEM GLD VNQ TLT LQD HYG BIL AGG — still empty; **Yahoo rate-limited the shared IP** this run, so the backtest fell back to a FRED-derived 3-asset panel. Re-run `data/fetchers/fetch_retry.py` once the limit clears → regenerate results on true ETF total returns); crypto **funding-rate history** + perp OHLCV (unblocks H4); intraday bars (unblocks H7 + micro work); fundamentals/earnings + point-in-time macro loader; a shared `data/load.py` returning aligned panels for the harness; expand equity universe for cross-sectional H2/H3/H9.

---

## 5. BACKTEST RESULTS

_Owner: backtest → `backtests/`._ **Engine validated + first baseline results in** — see [[backtest-results]].

- `harness.py` — vectorized daily-rebalance engine. Strategy emits target weight matrix W (dates×assets, shorts + leverage allowed); **no lookahead** (`held = W.shift(1)`, W[t] earns day t+1); one-way proportional cost on turnover. `run(prices, weights, cost_bps=5)` → `BacktestResult`.
- **Validated:** `test_harness.py` — 12 known-answer checks pass (buy&hold reproduces return to 1e-15; cost model exact; no-lookahead confirmed; CAGR/vol/maxDD match closed forms).
- `strategies.py` + `run_backtests.py` + `prepare_fred.py` → `backtests/RESULTS.md`.

**Baseline results (10y, 2016-07→2026-07; FRED-derived SPX/UST10/TBILL; 5 bps; bench = buy&hold SPX +13.3%/0.78):**

| Strategy | CAGR | Sharpe | Sortino | MaxDD | Vol | Calmar | Turn/yr |
|----------|------|--------|---------|-------|-----|--------|---------|
| 60/40 | +8.3% | 0.79 | 0.98 | −21.5% | 10.9% | 0.39 | 0.10 |
| XS Momentum (top-1, risk-off) | +7.6% | 0.55 | 0.56 | −33.9% | 15.5% | 0.22 | 2.11 |
| TS Momentum / trend | +6.3% | 0.62 | 0.67 | −19.8% | 10.8% | 0.32 | 2.01 |
| Risk parity (inv-vol) | +3.9% | 0.58 | 0.73 | −19.5% | 6.9% | 0.20 | 0.75 |

**Read-through:** in a strong equity decade buy&hold beat every risk-managed overlay (defensive strategies shine in drawdowns, not bull runs); **TS momentum/trend** gave the best defensive risk-adjusted profile (maxDD −19.8%, Sharpe 0.62); **XS momentum** whipsawed in 2022 (stocks+bonds fell together → worst maxDD −33.9%, concentration + slow lookback); **risk parity** lowest vol (6.9%) at the cost of return.

> ⚠️ **Caveats:** this is **harness validation, not alpha research** — single 10y window, no OOS split, no parameter sweep, no significance. Data is FRED-derived (SPX is *price-only*, excludes ~2%/yr dividends; UST10 is a constant-duration approximation) because **Yahoo rate-limited the shared IP** — re-run `data/fetchers/fetch_retry.py` then `run_backtests.py` on the true ETF total-return universe. `strategies/HYPOTHESES.md` **is now published** (canonical H01–H13 registry + build order) — plug those hypotheses into `strategies.py` and re-run per the build order in §3.

**Methodology to enforce on real runs (canon guardrails):** OOS last 2y; block-bootstrap CIs; **t > 3.0** hurdle (Harvey-Liu-Zhu ✅); **~50%+ post-publication decay haircut** (McLean-Pontiff ✅: 26% OOS / 58% post-pub); deflated Sharpe + PBO with trial count (Bailey/López de Prado ✅); wire `risk/sizing.py` ([[risk-framework]]) for position sizing.

---

## 6. RISK FRAMEWORK

_Owner: risk → `risk/`._ **Framework defined ([[risk-framework]], code `risk/sizing.py`).** Philosophy: *survival first, compounding second* — size for estimation error, vol is the unit of risk, budget top-down, paper→live is a gated ramp.

- [x] Position-sizing model — `size_position`: most-conservative of fractional-Kelly / vol-target / VaR budgets, × drawdown multiplier, clamped to cap (logs the `binding_constraint`)
- [x] Tail budgets — parametric + historical VaR, **Expected Shortfall** preferred for control (coherent, convex)
- [x] Drawdown limits — soft 10% / hard 20% de-risking multiplier + cool-off; CPPI; loss-budget-per-trade
- [x] Concentration — effective-N floor 8, diversification ratio, correlation-adjusted gross cap; `check_limits` pre-trade gate
- [x] Paper→live ramp — start 10% of paper size, ramp to 100% over ~30d, gated on tracking-error + vol surprise

**Default mandate (`RiskLimits`):** 15% port. vol target · quarter-Kelly · 25% Kelly cap · 10% single-name · 2.0 gross · 2% daily VaR · 10/20% dd · eff-N ≥ 8. *Starting points — re-fit per strategy/regime.*

| Metric | Limit | Current | Breach |
|--------|-------|---------|--------|
| Portfolio vol target | 15% ann. | — (no live book) | — |
| Daily VaR budget | 2% | — | — |
| Single-name gross | 10% | — | — |
| Effective-N floor | ≥ 8 | — | — |
| Drawdown soft/hard | 10% / 20% | — | — |

---

## 7. DEPLOYMENT PLAN (paper → live)

_Gated rollout — no gate advances without the prior gate green._

| Gate | Criteria | Status |
|------|----------|--------|
| **G0 Research** | Canon distilled, ≥1 testable hypothesis | ✅ (18 distilled, 13 hypotheses) |
| **G1 Backtest** | Robust backtest (costs + out-of-sample) | 🟡 engine validated + baselines in; H1–H13 runs + OOS pending |
| **G2 Risk** | Risk framework signed off, limits set | ✅ [[risk-framework]] + `sizing.py` |
| **G3 Paper** | Live-data paper run matches backtest stats | ⬜ |
| **G4 Live-small** | Sized-down live capital, monitoring on | ⬜ |
| **G5 Live-scaled** | Scaled within risk limits | ⬜ |

---

## 🔗 Integration log

| Time | Event |
|------|-------|
| 2026-07-23 04:57 | ROADMAP skeleton created in Vault. Polling panes + awaiting [[CANON]]. |
| 2026-07-23 05:05 | Folded in [[theory-markowitz]] (distilled), H1 [[Time-Series Momentum (Trend-Following)]] (proposed), yfinance fetcher (data). |
| 2026-07-23 05:15 | **Big sweep:** [[CANON]] map landed (tiered, 🟡 unverified). +9 distillations (theory-capm/black-litterman/kelly/risk-parity + 5 micro), +8 strategies (H2–H9), raw data pulled (5 crypto / 8 equities / 7 macro). Pipeline → stage 2. |
| 2026-07-23 05:35 | +8 distillations (FF, BSM, Heston, local-vol + micro-momentum/stat-arb/toxicity/hft → 18 total); +4 strategies (H10–H13 → 13 total); [[risk-framework]] + `sizing.py` (G2 ✅); [[data-sources]] note; `backtests/harness.py` built. **Gates G0+G2 green; bottleneck = G1 backtest results.** Pipeline → stage 3. |
| 2026-07-23 05:48 | Backtest pane added `strategies.py` + `run_backtests.py` (60/40, XS-mom, TS-mom, risk-parity suite → emits `RESULTS.md`). **Found critical-path blocker:** `data/raw/etf_universe/` is EMPTY — flagged in §4/§5 + status board as the item gating G1. (`theory-moc.md` is a sub-index, not a distillation — count stays 18.) |
| 2026-07-23 06:15 | **G1 breakthrough:** [[backtest-results]] landed — engine validated (12 known-answer tests pass) + first baseline results (60/40 0.79 Sharpe, TS-mom 0.62 best-defensive, XS-mom whipsawed 2022, risk-parity lowest vol). Run on FRED-derived 3-asset panel because **Yahoo rate-limited the ETF fetch** (`fetch_retry.py` to regenerate). G1 → 🟡 (baselines in; H1–H13 + OOS pending). Pipeline → stage 4. |
| 2026-07-23 06:25 | Alpha pane published canonical `strategies/HYPOTHESES.md` (H01–H13 registry + P1/P2/P3 priorities + data sources + backtest build order + open questions for theory/synthesis). **Reconciled §3 H-IDs to this source of truth** (my earlier ad-hoc numbering replaced). Alpha pane → 🟢. §5 caveat updated (HYPOTHESES.md no longer missing). |
| 2026-07-23 09:10 | During the data stall, delivered [[synthesis-anomaly-persistence]] — answers pane 4's three open questions from the canon: (1) decay-prior ranking → build H01/H10/H09 first, treat H05/H04/H06 as decayed-unless-proven; (2) H03 strip with FF3 (French library), market-only as null; (3) combine H01+H09+H12 in risk space, treat H09+H12 as one crypto risk bucket. Linked from §3 + INDEX. |
| 2026-07-23 09:35 | **Deep-research CANON landed & merged** ([[CANON-researched]], wf_6b6298b8, 107 agents, 25 claims 3-vote-verified; cartographer merged into [[CANON]] with ✅/🟡 flags). Folded into §1 (verified vs gap lists). **Corrected a propagated error:** McLean-Pontiff decay is **26% OOS / 58% post-pub** (not ~32%) → sizing haircut updated to **~50%+** in §3, §5, and [[synthesis-anomaly-persistence]]; added Deflated-Sharpe/PBO guardrail. (Note: my `-newermt` poll filter missed the 08:20/08:28 landing due to clock skew — caught on inventory recount.) |
