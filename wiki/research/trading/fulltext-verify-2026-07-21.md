---
tags: [research, trading, ai-agents, llm, verification, evidence-ledger, reproducibility, cost-attribution]
date: 2026-07-21
sources:
  - "arXiv:2606.08285v1 full text — ar5iv HTML + PDF (7 pp), read 2026-07-21"
  - "arXiv:2607.10286v1 full text — arXiv HTML, read 2026-07-21"
status: verified — resolves the two provisional ★★ clips; both upgraded ★★★
related:
  - "[[beyond-agent-architecture]]"
  - "[[tradelens-pay-for-intelligence]]"
  - "[[the-alpha-illusion]]"
  - "[[ktd-fin]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[learning-path]]"
  - "[[ledger]]"
---

# Full-Text Verification — Beyond Agent Architecture + TradeLens (2026-07-21)

> **Scout debt retired.** Both provisional ★★ clips conditioned their upgrade on the full text; this is the evidence appendix that records what the full texts actually contain. Verdicts applied in place on [[beyond-agent-architecture]] and [[tradelens-pay-for-intelligence]].

## Verdicts

| Clip | Full-text test | Verdict |
|---|---|---|
| [[beyond-agent-architecture]] | Per-paper scorecard exists: 30 studies × Y/P/NR codes + worked example with numbers. **Correction:** the operational matrix codes **5 fields**, not 7 separate dimensions. | ★★ → **★★★** |
| [[tradelens-pay-for-intelligence]] | Attribution method delivered with formulas + 10-backbone results + amplifier tables; arithmetic cross-checks pass. | ★★ → **★★★** (Phase-4 dependency) |

---

## Paper 1 — Beyond Agent Architecture (arXiv:2606.08285)

### Correction to the clip's claim (test-don't-wonder catch)
The abstract names **seven** assessment concerns, but the per-study evidence matrix in the full text codes **five fields**: point-in-time and split transparency are **merged** into one "Split/PiT" column, and **universe definition is not scored per study** (only scope prose is given). The "7-dimension clip checklist" survives as 7 *questions* but only 5 *coded answers*. Use it as five gates plus two prose questions.

### Distribution across the 30 audited studies (Y = explicit, P = partial, NR = not recovered)

| Dimension (as coded) | Recoverable (Y+P) | Y | P | NR |
|---|---:|---:|---:|---:|
| Point-in-time / split basis (merged) | 25/30 | 12 | 13 | 5 |
| Clear held-out evaluation | 21/30 | 13 | 8 | 9 |
| Cost / turnover treatment | **14/30** | **0** | 14 | 16 |
| Execution timing / semantics | 26/30 | 7 | 19 | 4 |
| Artifact availability | 18/30 | 7 | 11 | 12 |

**Headline:** cost/turnover treatment is the field's weakest point — **zero** of 30 studies reports it fully; the 14 "recoverable" are all partial. Architecture/execution is the best-reported (26/30) — the full-text confirmation of "architecture well-reported, evaluation assumptions not."

### Per-study codes (the asset)

| # | Study | Split/PiT | Held-out | Costs | Exec. | Art. |
|---:|---|:---:|:---:|:---:|:---:|:---:|
| 1 | Lopez-Lira and Tang | P | P | P | P | P |
| 2 | Alpha-GPT | NR | NR | NR | NR | NR |
| 3 | TradingGPT | NR | NR | NR | P | NR |
| 4 | FinMem | P | P | NR | P | P |
| 5 | QuantAgent | NR | NR | NR | NR | NR |
| 6 | FinAgent | P | NR | NR | P | NR |
| 7 | SEP | P | Y | NR | P | P |
| 8 | FinLlama | P | P | P | P | NR |
| 9 | StockGPT | Y | Y | P | P | NR |
| 10 | StockAgent | P | P | NR | Y | P |
| 11 | CryptoTrade | NR | NR | NR | P | NR |
| 12 | FinCon | P | NR | NR | P | P |
| 13 | TradingAgents | P | P | NR | P | P |
| 14 | InvestorBench | Y | Y | NR | NR | P |
| 15 | Sentiment Trading | Y | Y | P | P | P |
| 16 | AlphaAgents | P | NR | NR | P | NR |
| 17 | MM-DREX | P | NR | NR | P | NR |
| 18 | FinRL-DeepSeek | Y | Y | P | P | Y |
| 19 | AlphaAgent | Y | Y | P | P | Y |
| 20 | LLM market simulation | P | P | P | Y | Y |
| 21 | ContestTrade | P | P | P | P | Y |
| 22 | LLM-guided RL | P | P | NR | P | NR |
| 23 | Adversarial News | Y | Y | P | Y | P |
| 24 | AI-Trader | Y | Y | P | Y | Y |
| 25 | Look-Ahead-Bench | Y | Y | P | Y | Y |
| 26 | Expert Teams | Y | Y | NR | P | NR |
| 27 | QRAFTI | NR | NR | NR | NR | P |
| 28 | Hubble | Y | Y | P | P | P |
| 29 | AlphaCrafter | Y | Y | P | Y | NR |
| 30 | PortBench | Y | Y | P | Y | Y |

(Column totals reproduce the paper's aggregate snapshot: 25/21/14/26/18 recoverable — internal consistency ✓.)

### 10-equity worked example (numbers)
Timing held fixed (signal after close of day t, evaluated on a next-day close-to-close proxy). Friction varied:

| Strategy | 0 bps | 10 bps | 25 bps | Drop @10 | Drop @25 |
|---|---:|---:|---:|---:|---:|
| Buy-and-hold | 1.1995 | 1.1995 | 1.1995 | 0 | 0 |
| Moving average | 1.2420 | 1.0980 | 0.8991 | −0.1439 | −0.3429 |
| LLM-proxy scaffold | 1.4710 | 1.3068 | 1.0806 | −0.1642 | −0.3904 |
| Structured-only ablation | 1.3473 | 1.1558 | 0.8971 | −0.1916 | −0.4502 |

Turnover at 10 bps: B&H 0.0009, MA 0.2058, LLM-proxy 0.2902, structured-only 0.2740 — the active rules trade ~230–320× more often, which is exactly why friction compresses them and leaves buy-and-hold untouched. At 25 bps the structured-only ablation goes **net-negative** (0.8971) — a gross edge erased by costs alone. (Deltas cross-check against the 0 bps column ✓.)

---

## Paper 2 — TradeLens (arXiv:2607.10286)

### The cost-attribution method (formulas)
Inputs: trading records + runtime traces + deployment configs → replay orders to rebuild the portfolio path, then decompose.

**Profit decomposition** (against two counterfactuals):
- Gross: `P_{1:T} = V_T^dyn − V_0`
- Market exposure: `P^sys = V_T^sys − V_0` (passive benchmark path)
- Initial picking: `P^asset = V_T^base − V_T^sys` (frozen initial weights)
- Reallocation/timing: `P^timing = V_T^dyn − V_T^base`
- `P_{1:T} = P^sys + P^asset + P^timing`

**Cost decomposition** (per period): `C_t = C_t^llm + C_t^trd + C_t^inf + C_t^sto` — token fees (÷ completion success rate ρ=98%), commissions (fixed + per-activity), fixed infrastructure κ, uniform stochastic overhead.

**Two viability gates:**
- *System viability:* `R_{1:T} = P_{1:T} − C_{1:T} ≥ 0` (does the whole pipeline cover all costs?)
- *Agentic viability:* `R_{1:T}^agent = P^timing − C_{1:T}^dyn ≥ 0`, where `C^dyn` excludes static infra (only llm+trading+stochastic). **This is "intelligence-to-profit conversion" in numbers:** the active reallocation gain must pay for the decisions that induced it.

### 10-backbone results ($100k, 10 liquid US stocks, 2025-12-01 → 2026-01-30, S&P 500 benchmark)

| Model | Gross | Total cost | Net | Agent margin | Timing |
|---|---:|---:|---:|---:|---:|
| Mistral-large-3 | 777.81 | 414.82 | **362.99** | **833.52** | 1040.14 |
| Claude Sonnet 4.5 | 519.40 | 255.04 | 264.36 | −372.86 | −326.02 |
| Qwen3-Max | 505.76 | 258.79 | 246.97 | 45.06 | 95.65 |
| GPT-5.2 | −50.43 | 223.04 | −273.47 | 111.83 | 125.46 |
| DeepSeek-V3.2 | −388.29 | 304.86 | −693.15 | −335.96 | −239.30 |
| Gemini 3 Flash | −975.58 | 422.38 | −1397.96 | −1040.76 | −826.59 |
| Llama-4-scout | −1020.38 | 228.90 | −1249.29 | −1257.92 | −1237.22 |
| Minimax-m2.1 | −1474.62 | 252.80 | −1727.42 | −2425.04 | −2380.44 |
| Kimi-k2 | −1975.63 | 275.67 | −2251.30 | −1358.50 | −1291.03 |
| GLM-4.7 | −2554.81 | 296.95 | −2851.76 | −2240.81 | −2152.06 |

- **Only Mistral-large-3 passes both gates.** Claude Sonnet 4.5 is system-viable but agentically negative (the pipeline earns, the *decisions* don't). GPT-5.2 is the mirror: positive agent margin, negative net.
- Cost anatomy: LLM fees are trivial ($0.04–$23.84); trading fees $4–$200; infra fixed at $208.20/run; stochastic $8.55–$12.47. **Token cost is rarely the killer — bad timing is.**
- Arithmetic cross-checks pass on every row (net = gross − cost ✓; agent margin = timing − dynamic cost ✓ to rounding).

### Amplifiers (GPT-5.2 / DeepSeek-V3.2)
- **Capital:** at $500k, DeepSeek timing = −15,828 while total cost stays 254; GPT stays net-positive at every scale but its agent margin flips to −5,697 at $500k. Scale magnifies decision quality, never creates it.
- **Frequency:** hourly vs daily cuts gross by 1,104 (DeepSeek) / 335 (GPT); added cost explains only ~12–14% of the deterioration — the rest is worse decisions.
- **Architecture:** CoT → AI-Trader → DeepFund; cheapest is not best; DeepFund wins *only* by producing positive timing (e.g., GPT DeepFund timing +444 vs CoT −572). Architecture amplifies, doesn't substitute.

---

## How this anchors us (unchanged, now evidenced)
1. **The five-gate clip checklist** (Split/PiT · held-out · costs · execution · artifacts + universe as prose) is now extracted and ready — apply it to every future trading-paper clip before verdicting. Cost/turnover is the gate most papers fail (0/30 full).
2. **Agentic viability = Phase-4 capstone gate.** [[learning-path]] Phase 4 must report `R^agent = P^timing − C^dyn` from day one; [[ledger]] quant-signal rows get an "intelligence-to-profit conversion, measured" column.
3. **Third + fourth independent papers** (with [[the-alpha-illusion]], [[ktd-fin]]) converging: architecture/capital/frequency amplify decision quality; they don't create it. The "harvest architecture, discount money claims" rule now has population-scale backing.

## Residual debt (honest)
- ⚠️ Universe definition: named dimension, **not coded per study** in the paper's own tables — the checklist has 5 scored gates, not 7.
- ⚠️ TradeLens code (anonymous.4open.science/r/TradeLens) — **still not fetched**; provenance unverified. Method is paper-specified, not code-verified.
- ⚠️ Single-pass extraction (WebFetch summarizer over HTML); per-study codes and table values cross-checked arithmetically but not re-read line-by-line. Paper 1 PDF also downloaded (7 pp) for spot checks.
- ⚠️ TradeLens window is 2 months / 10 stocks — same short-window caveat [[the-alpha-illusion]] P5 raises applies to its own numbers.

## Evidence ledger
- ✅ 2026-07-21: arXiv:2606.08285 full text read (ar5iv HTML; PDF 2606.08285, 7 pp, downloaded). 30-study matrix, distribution counts, worked-example numbers extracted; column totals reconcile with the paper's aggregate snapshot.
- ✅ 2026-07-21: arXiv:2607.10286 full text read (arXiv HTML). Attribution formulas, 10-backbone table, capital/frequency/architecture tables extracted; row arithmetic reconciles.
- ✅ Verdicts applied in place on both clip notes (frontmatter + verdict + ledger).
