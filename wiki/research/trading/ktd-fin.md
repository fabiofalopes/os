---
tags: [research, trading, ai-agents, llm, benchmark, contamination, skepticism, source-clip]
date: 2026-07-21
sources:
  - "arXiv:2605.28359v1 [cs.AI, q-fin.TR], 2026-05-27 — From Knowing to Doing: A Memory-Controlled Benchmark for LLM Trading Agents on Stock Markets"
authors: [Taojie Zhu, Wentao Zhao, Rui Sun, Beidi Luan, Jiacheng Lu, Sinuo Wang, Jing Li, Daxin Jiang, Yonghong He, Zuo Bai]
status: full-text verified 2026-07-21 (arXiv HTML — protocol, probe audit, Tables 3–5, baselines, limitations); supersedes this morning's abstract-only clip
related:
  - "[[the-alpha-illusion]]"
  - "[[beyond-agent-architecture]]"
  - "[[tradelens-pay-for-intelligence]]"
  - "[[learning-path]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# KTD-Fin — Memory-Controlled Benchmark for LLM Trading Agents

> **What it gives the harness:** the first *empirical* follow-up to [[the-alpha-illusion]]'s confound #1 (temporal contamination). Where Alpha Illusion argued from others' evidence (FinMem −71.85% post-cutoff), KTD-Fin builds the instrument and runs it: anonymize the market data itself, then ask whether the "alpha" survives. At the attribution level it doesn't — 9 of 10 frontier models post *negative* stock-selection alpha under blinding. Also supplies the missing attribution methodology (returns decomposed into market-like/style/selection, so "made money" ≠ "has skill") and — new on full read — a classical-ML baseline ladder that every LLM agent loses to risk-adjusted.

## The two evaluation failures it names
1. **Memory-for-reasoning substitution.** Long backtests overlap frontier LLM knowledge cutoffs, so memorized tickers, dates, prices, and narratives substitute for investment reasoning. (Alpha Illusion confound #1, stated independently.)
2. **Raw returns are a noisy proxy for selection skill.** Positive performance may be market beta, style exposure, or a favorable regime — not genuine alpha.

## The instrument (KTD-Fin) — verified on full read
- **Four-level data-side masking:** bright (real ticker + real date) → stock-blind (aliased ticker) → date-blind (relative day index) → blinded (both). Aliases are stable within an episode and reshuffled across episodes; tool arguments are decoded for the data layer and re-masked on return, so a blinded agent never sees a real identifier even transiently. Numeric features are computed on the original series — only labels change.
- **The mask holds — audited, not assumed:** 10 attacker LLMs × 200 probes → top-1 ticker recovery ≤3.0%, best attacker top-5 10.2%, strict joint (ticker top-5 + date within ±7 trading days) ≤1.5%. That is Alpha Illusion's P1 with a measurement attached.
- **The harness is not a strawman** (resolves the provisional caveat): ReAct-style research loop → forced JSON submission; six read-only tools (market context, screening, snapshot, comparison, portfolio state, risk check); invalid submissions get 3 retries then fall back to no-trade; three decision modes (open-research, fixed-candidate, memory-only). Headline config: blinded × open-research.
- **Barra-style attribution:** portfolio return → common (unit-exposure market-like component) + style (nine factors) + residual stock-selection alpha.
- **Design:** CSI300 constituents, daily portfolio construction, next-day-open execution, CNY 1M start; long window 2024-01-01 → 2026-04-10 (548 trading days) plus ten ~43-day regime windows.

## The results (10 frontier LLM agents, CSI300, 2024–2026) — verified numbers
- **Raw returns look good; attribution kills them.** Under blinding, 5 of 10 agents beat CSI300 buy-and-hold (+36.92%): Qwen3.6-Plus +85.29% (Sharpe 1.13), GPT-5.5 +61.26% (0.98), Doubao-Seed-2.0 +61.01% (1.15), Claude-Opus-4-7 +58.80% (0.98), MiniMax-M2.7 +56.31% (0.89). The other five range +21.86% (Step-3.5-Flash) down to −24.23% (Kimi-K2.6, Sharpe −0.34). But the seed-averaged decomposition puts **stock-selection alpha at −0.7 to −77.8 for nine of ten models; only Claude is ≈0 (+0.2)**. Returns are common-factor (+29 to +42) plus style (+12 to +29) — levered beta and style bets, not skill. "Made money in a +37% bull window" is exposed as exactly the beta the abstract warned about.
- **Masking changes the reasoning** (qualitative): with real identifiers the agents tell brand/sector stories; blinded, they fall back on factor-rank language — the parametric prior caught in the act, consistent with Alpha Illusion's PPL.
- **The baseline ladder — the sharpest number in the paper (absent from the abstract):** 18 Qlib Alpha9 classical-ML factor models (trained 2008–2022, validated 2023). Best: SFM +86.58%, **Sharpe 2.02, MDD −7.41%**; then DoubleEnsemble +73.66%/1.41, CatBoost +72.97%/1.43, LightGBM +66.22%/1.29, Transformer +60.35%/1.61. The best classical baseline **beats every LLM agent on both return and Sharpe at roughly a quarter of the drawdown** (best agent MDD −15.62%). The agents' 24–72 h of API wall-clock per seed buy what a laptop factor model beats.

## How it anchors us
1. **Confirms the FOMO filter with new data, not just argument.** [[the-alpha-illusion]] P1 (temporal integrity) goes from "plausible failure mode" to "demonstrated across ten frontier models on a real index, with the mask audited at ≤1.5% joint re-identification." The classify-then-check rule stands.
2. **Adopt attribution AND a baseline ladder as capstone gates.** [[learning-path]] Phase 4 gains two concrete requirements: (a) any paper-traded result must decompose (common vs style vs selection) before it counts as edge; (b) it must beat a cheap classical baseline (Alpha9-style factor model) risk-adjusted — not just buy-and-hold. "Beat the index in a bull window" is beta; "beat LightGBM" is the actual bar. This is the LLM-specific echo of [[López de Prado — Backtest Overfitting Guards]].
3. **Masking-as-protocol is harvestable architecture.** The pattern — anonymize identifiers/calendar across prompts *and* tools, then audit re-identification — is a cheap sanity test for any future signal of ours: if a signal dies when the memorable specifics are stripped, it was memory, not information.
4. **Composes with PPL.** Alpha Illusion's parametric-prior lock-in predicts exactly what masking revealed: strip the specifics and the agents fall back on generic factor reasoning — the prior, exposed.

## Verdict
★★★ — **confirmed on full read** (was provisional). Direct, well-constructed empirical confirmation of the vault's core trading-skepticism thesis, now with three reusable instruments: the audited masking protocol, the attribution requirement, and the baseline-ladder lesson. Remaining caveats — which survived the full read, so they are real, not merely unread: single market (CSI300 A-shares) in a +37% bull window; **price-only OHLCV channel — this tests technical-timing skill, not the news/filings reasoning that is the LLM's plausible edge**, so the negative is strongest exactly where the agents had no information advantage to claim; full mask×mode grid only on the anchor model (the other nine ran the headline cell only, compute-bound); minor internal inconsistency on baseline training span (setup says 2008–2022, intro says 2015–2022 — shared by all baselines, so it doesn't affect the comparison).

## Evidence ledger
- ✅ Fetched & fully read 2026-07-21: `arxiv.org/html/2605.28359v1` — masking protocol + probe audit, Table 3 (anchor mask×mode contrast), Table 4 (headline blinded leaderboard), Table 5 (seed-averaged Barra attribution), 18-model baseline table, limitations.
- Key quantitative anchors (all from the paper): mask audit top-1 ≤3.0% / joint ≤1.5%; blinded long window Qwen +85.29% (SR 1.13) top → Kimi −24.23% (SR −0.34) bottom, CSI300 B&H +36.92%; selection alpha +0.2 (Claude, only non-negative) to −77.8 (Kimi), 9/10 negative; SFM baseline +86.58%, SR 2.02, MDD −7.41% — dominates all ten agents risk-adjusted.
- The abstract's "limited evidence of persistent stock-selection alpha" is confirmed and sharpened (9/10 negative; classical baselines dominate). Supersedes the abstract-only clip from earlier today.
- Still queued (future sessions): [[beyond-agent-architecture]] (the 30-study evidence matrix) and [[tradelens-pay-for-intelligence]] remain abstract-only/provisional.
