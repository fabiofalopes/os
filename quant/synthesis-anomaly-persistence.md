---
title: "Synthesis Answers — Anomaly Persistence, H03 Factor Model, Combining H01+H09+H12"
type: synthesis
owner: pane-8-synthesis
status: living
created: 2026-07-23
updated: 2026-07-23 09:35
answers: strategies/HYPOTHESES.md "Open questions for THEORY / SYNTHESIS panes"
tags: [quant/synthesis, quant/alpha, quant/risk, decay, portfolio-construction]
---

# Synthesis Answers to Pane 4's Open Questions

> Answers the three questions pane 4 (alpha) posed at the foot of `strategies/HYPOTHESES.md`.
> Every claim below is grounded in the team's own distilled canon — no outside assertions.
> Consumer: alpha (prioritization) + backtest (test design) + risk (combination).

---

## Q1 — Which anomalies are plausibly *persistent* vs arbitraged away? (decay priors)

**Framework.** Persistence ∝ *(a) a risk or behavioral rationale that won't be competed away* × *(b) a cost/capacity barrier to exploiting it* × *(c) survival of the replication filters*. Apply the canon's three guardrails to every signal before sizing:

- **t > 3.0** hurdle for any "new" factor ([[CANON]] Tier 2 — Harvey, Liu & Zhu 2016 ✅ verified).
- **~50%+ post-publication decay haircut** ([[CANON-researched]] — McLean & Pontiff 2016 ✅ verified: returns fall **26% out-of-sample and 58% post-publication**; the extra 32-point post-pub drop is arbitrage, so discount headline anomaly returns by roughly half before sizing).
- **Report Deflated Sharpe + PBO with the trial count** (Bailey & López de Prado ✅ verified) — a backtest that doesn't disclose its number of trials is a likely false positive.
- **~65% of published anomalies fail to replicate** ([[CANON]] — Hou, Xue & Zhang 2020 🟡 unverified) → start from the replicable minority.

**Likely persistent** (structural rationale + costly/capacity-limited to exploit):
| Signal | Why it should persist | Decay note |
|---|---|---|
| **H01 TS momentum / trend** | Behavioral underreaction + herding; **crisis alpha** (positive in drawdowns); capacity-friendly via liquid futures | Survived OOS across 58 instruments / decades ([[micro-momentum]]), but equity TSMOM Sharpe ~1.0→~0.5 post-2000; crypto stronger |
| **Value + momentum combined** | Universal across asset classes and **negatively correlated** → a free diversification lunch ([[CANON]] — Asness, Moskowitz & Pedersen 2013) | Both are risk/behavioral premia, not data-mined equity quirks |
| **H10 Volatility risk premium** | Structural — implied > realized vol compensates real tail/insurance risk | Not arbitraged away *because* it's genuinely risky: fat left tail = the cost |
| **H09 funding carry / H13 basis** | Financing frictions + convenience yield; pays for real counterparty/inventory risk | Persists while the friction exists; watch regime shifts |

**Likely arbitraged / heavily decayed** (crowded, low barrier, or replication-fragile):
| Signal | Why it decays |
|---|---|
| **H05 pairs / stat-arb** | Gatev-style equity pairs **decayed sharply post-2002** (crowding + decimalization) — [[micro-stat-arb-cointegration]] |
| **H02 XS momentum at high freq / H04 short-term reversal** | Crowded; our own baseline XS top-1 **whipsawed in 2022** ([[backtest-results]]); reversal is the fast-decaying mirror of intermediate momentum ([[micro-momentum]]) |
| **H06 overnight/intraday** | Likely transient, capacity-constrained, execution-sensitive — treat as hypothesis, not fact |
| **Generic published equity anomalies** | Apply the ~32% haircut + t>3 + OOS; most fail replication |

**Rule of thumb for the registry:** rank by (risk/behavioral story) + (exploitation cost) + (passes t>3 ∧ OOS ∧ replication); haircut every literature-sourced edge **~50%+** (26% OOS / 58% post-pub, McLean-Pontiff ✅) before sizing, and require a disclosed trial count (Deflated Sharpe / PBO). This argues for **building H01/H10/H09 first** (P1, structural) and treating H05/H04/H06 as decayed-unless-proven.

---

## Q2 — Factor-model choice for H03 (market-only vs FF3 with free-data proxies)?

H03 = **idiosyncratic (residual) momentum** — momentum from the *factor-stripped* return. The whole point is to isolate the stock-specific component, so the model choice determines what "residual" means.

- **Market-only (CAPM):** free and simple (SPX via FRED `SP500` or `SPY`). But it leaves **size and value exposures in the residual** — so "residual momentum" is contaminated by factor exposures, not a clean stock-specific signal. [[theory-capm]] + [[theory-fama-french]]: most cross-sectional return variation *is* factor exposure.
- **FF3 (market + SMB + HML):** cleaner residual. Free proxies from the **Kenneth French data library** (daily/monthly, US). This is the standard free source and directly matches [[theory-fama-french]]'s "benchmark against FF3/FF5" rule.
- **Recommendation:** **strip with FF3 as the primary signal** (market-only leaves size/value in the residual and re-introduces exactly the contamination H03 is meant to remove). If FF5 proxies (RMW/CMA) are available, prefer FF5 — it also serves the related **H08 quality** hypothesis. **Run market-only as a sanity null and report both**; the market-only → FF3 delta *is* the measurement of factor contamination.
- **Caveats:** French factors are US-centric and lagged — document the point-in-time gap; and whatever the model, the residual signal must still clear the **t>3 + OOS** bar of Q1.

---

## Q3 — Portfolio construction: combining low-correlation H01 + H09 + H12 into one book?

Use the team's own [[risk-framework]] machinery — combine in **risk space, not dollar space**.

1. **Vol-target each sleeve, then aggregate.** Scale each of H01/H09/H12 to equal *risk* contribution (inverse-vol / risk-parity across sleeves), then hit the portfolio vol target (default **15%** mandate). Dollar diversification ≠ risk diversification ([[theory-risk-parity]]).
2. **Size each sleeve with fractional Kelly on its own edge** (quarter-Kelly default), then take the **governing budget** `min(w_kelly, w_vol, w_VaR)` × drawdown multiplier, clamped to caps — i.e. call `size_position` per sleeve ([[risk-framework]]).
3. **Respect the correlation-adjusted gross cap.** Monitor **effective-N** and **diversification ratio**; tighten gross leverage as average pairwise correlation rises, because correlations → ~1 exactly in crises when diversification is most needed ([[risk-framework]], [[theory-risk-parity]]).
4. **⚠️ The diversification illusion — H09 & H12 are both crypto.** Low *signal* correlation ≠ low *risk* correlation: they share crypto regime, exchange, and liquidity risk. **Treat H09 + H12 as one crypto risk bucket** for concentration/venue caps. **H01 (multi-asset trend) is the true diversifier** here — this is the Asness value/momentum negative-correlation "free lunch" applied across sleeves ([[CANON]]).
5. **Timescale separation.** H01 rebalances monthly (slow trend), H09 on ~8h funding intervals, H12 continuously/intraday. **Aggregate risk at the portfolio level daily; execute each sleeve at its native frequency.**
6. **Paper→live per sleeve.** Ramp each via `paper_to_live_ramp` ([[risk-framework]]), and gate the *whole book* on aggregate live-vs-paper tracking error before advancing.

---

## Links
- Questions answered: `strategies/HYPOTHESES.md` (pane 4)
- Decay/replication canon: [[CANON]] Tier 2 · [[micro-momentum]] · [[micro-stat-arb-cointegration]]
- Factor models: [[theory-capm]] · [[theory-fama-french]]
- Combination/risk: [[risk-framework]] · [[theory-risk-parity]] · [[theory-kelly]]
- Baseline evidence: [[backtest-results]]
- [[ROADMAP]] · [[INDEX]]
