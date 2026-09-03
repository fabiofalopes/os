---
tags: [research, trading, ai-agents, llm, multi-agent, cost-attribution, viability, source-clip]
date: 2026-07-21
sources:
  - "arXiv:2607.10286v1 [cs.AI, cs.MA], 2026-07-11 — Can Agentic Trading Systems Pay for Their Own Intelligence?"
  - "Code: https://anonymous.4open.science/r/TradeLens — NOT fetched this session (anonymous review link, verify later)"
authors: [Qiqi Duan, Changlun Li, Chen Wang, Fan Zhang, Mengxiang Wang, Dayi Miao, Peixian Ma, Jiangpeng Yan]
status: full-text verified 2026-07-21 (arXiv HTML) — verdict ★★★, Phase-4 dependency
related:
  - "[[fulltext-verify-2026-07-21]]"
  - "[[the-alpha-illusion]]"
  - "[[ktd-fin]]"
  - "[[beyond-agent-architecture]]"
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
  - "[[ledger]]"
  - "[[Kelly Criterion — Position Sizing]]"
---

# TradeLens — Can Agentic Trading Systems Pay for Their Own Intelligence?

> **What it gives the harness:** the evaluation question that matches our own arc. [[Bootstrap to Self-Funding — The Agent Life Arc]] has a literal "cover-own-cost" gate; this paper makes that gate a *metric*: **agentic viability = do the LLM-mediated decisions convert their induced costs (tokens, tools, continual inference) into measurable incremental profit?** It is the most recent paper in the sweep (2026-07-11), the cs.MA entry the track asked for, and it reframes evaluation from capability ranking to trace-grounded cost/profit diagnosis — the same reframe [[the-alpha-illusion]] demands, applied to the P&L line the others ignore: token cost.

## The criterion and the tool
- **Viability, not performance.** Existing evals report performance metrics; they rarely ask whether dynamic LLM decisions convert their *induced costs* into *incremental* profit. An agent that beats a benchmark but costs more to run than it adds is not viable — it is a subscription with extra steps.
- **TradeLens** — a trace-grounded diagnostic toolkit: from trading records, runtime traces, and deployment configs it reconstructs trajectories, **attributes profit and cost to interpretable evidence**, and diagnoses whether and why an agent pays for its own intelligence.

## The findings (across backbones, capital scales, frequencies, architectures)
- Viability hinges on **intelligence-to-profit conversion**; models show *distinct* failure signatures — e.g., poor asset selection in DeepSeek-V3.2, negative timing in GLM-4.7.
- **Capital scale, trading frequency, and architecture matter only as amplifiers** — they amplify or degrade *decision-attributed timing value*; they do not create it. (The multi-agent-architecture-as-magic-lever belief, deflated again — consistent with Alpha Illusion P6: architecture doesn't rescue the decision quality.)

## How it anchors us
1. **It is our Life Arc's gate, operationalized.** "Cover-own-cost" stops being a vibe and becomes: attribute profit vs (tokens + tools + infra) per decision, require net-positive conversion before the stage gate passes. Add this to [[ledger]]'s scoring column for any quant-signal hypothesis: *intelligence-to-profit conversion, measured, not assumed.*
2. **Token cost enters the anti-fooling screen.** [[the-alpha-illusion]] P5 lists token cost among frictions; this makes it the *headline* friction for agentic systems. Our Phase-4 capstone ([[learning-path]]) must report net-of-inference-cost from day one — a backtest that ignores what the agent costs to run is testing a different system than the one we'd deploy.
3. **Failure-signature attribution is a reusable diagnostic pattern.** "Poor asset selection vs negative timing" as separable diagnoses beats one Sharpe number — it tells you *where* the agent fails, which is what a learning harness needs to iterate on. Same spirit as CLQT's capability scorecard (see source queue below).
4. **Architecture-as-amplifier, again.** Third independent paper in this sweep saying scaffolding/capital/frequency modulate decision quality rather than substituting for it. The vault's "harvest architecture, discount money claims" rule keeps accumulating external support.

## Verdict
★★★ (full-text verified 2026-07-21 — see [[fulltext-verify-2026-07-21]]). The full text delivers the attribution method **with worked numbers**: profit split into market/picking/timing against two counterfactuals, cost split into llm/trading/infra/stochastic, and two gates — system viability (`P − C ≥ 0`) and **agentic viability** (`P^timing − C^dyn ≥ 0`), the numeric form of intelligence-to-profit conversion. 10 backbones tested with full tables; only Mistral-large-3 passes both gates; row arithmetic reconciles. Amplifier analysis (capital/frequency/architecture) quantified — e.g., hourly-vs-daily damage is ~86–88% worse *decisions*, not cost. **Phase-4 dependency** per this note's own criterion: [[learning-path]] capstone must report `R^agent` from day one. Residual caveats: code link (anonymous mirror) still unfetched — method is paper-specified, not code-verified; 2-month/10-stock window carries the [[the-alpha-illusion]] P5 short-window caveat against its own numbers.

## Evidence ledger
- ✅ Fetched & read 2026-07-21: arXiv API metadata + full abstract for 2607.10286v1 (cs.AI, cs.MA, 2026-07-11).
- ✅ Full-text verified 2026-07-21 (arXiv HTML): attribution formulas extracted (profit = market + picking + timing; cost = llm + trading + infra + stochastic; agentic viability = P^timing − C^dyn ≥ 0, ρ=98%); 10-backbone results table extracted ($100k, 2025-12-01→2026-01-30, 10 US stocks, S&P 500 benchmark) — only Mistral-large-3 viable on both gates; capital/frequency/architecture amplifier tables extracted; row arithmetic cross-checked and reconciles. Full evidence in [[fulltext-verify-2026-07-21]].
- ⚠️ Code (anonymous.4open.science/r/TradeLens) — still NOT fetched; anonymous mirror, verify provenance before use.
- Sweep context: arXiv cs.MA+trading recency sweep (25 entries, 2026-07-21) — the only cs.MA paper in the sweep directly about LLM trading-agent evaluation.
