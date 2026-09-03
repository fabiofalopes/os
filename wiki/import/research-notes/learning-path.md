---
tags: [trading, ai-agents, learning-path, curriculum]
date: 2026-07-20
status: active — work top-down; check off as you go
related:
  - "[[curriculum-draft]]"
  - "[[snapshot-survey]]"
  - "[[legitimacy-ledger]]"
  - "[[Moon Dev — Research Brief & Leads]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Learning Path — AI Trading Agents (for a systems/network engineer)

> **The through-line:** your **edge is infrastructure** — pipelines, monitoring, deployment, determinism, reliability. The ML + finance is a layer you add *on top of* that edge, not a replacement for it. The whole path is governed by one rule: **test, don't wonder** ([[Operating Principle — Test Don't Wonder]]). Moon Dev is the running case study of what happens when you skip the statistical discipline — real machinery, naively-validated claims. The rigorous resources are the correction.
>
> **How to use:** work top-down, check things off. Each phase names *what to read/do*, *the artifact that proves you did it*, and *what to steal/avoid*. Phases 0–2 are pure learning (no code that trades); Phase 3 is engines; Phase 4 is the paper-only capstone. Study tasks can be fed to the cron engine as bounded sessions (§feed).

---

## Phase 0 — Install the skepticism (do this FIRST, before any agent)
The goal: make "this backtest looks great" trigger alarm bells, not excitement.

- [ ] Read **The Alpha Illusion** (arXiv:2605.16895) — reported LLM-agent alpha ≠ deployment evidence. [[curriculum-draft]] Stage 1.
- [ ] Read the **López de Prado overfitting guards** already in the library (`wiki/research/finance/López de Prado — Backtest Overfitting Guards.md`).
- [ ] Read the **Kelly Criterion** note (`wiki/research/finance/Kelly Criterion — Position Sizing.md`) — how not to go bust.
- [ ] **Watch a backtest lie:** in `backtesting.py`, deliberately overfit a toy strategy (optimize in-sample, then look at how it would have fooled you). *This is the exact sin Moon Dev's RBI loop commits* ([[snapshot-survey]] §c — no walk-forward, in-sample curve-fitting to 50%).
- **Artifact:** a short note in `wiki/research/trading/` — "three ways I just fooled myself with a backtest."
- **⛔ PHASE 0→1 GATE (Critic-ratified 2026-07-21 — [[critic-phase0-gate-triad-crosscheck]]): the FOMO-filter exam.** Take ONE trading-agent claim never previously evaluated (paper/repo/video/post); in ≤1 page: (a) classify claim strength — extractor / backtest / deployable / autonomous ([[the-alpha-illusion]] §4 table); (b) audit the disclosure-checkable tests against the source's *own text* — **P1** temporal integrity (cutoff + ≥1 post-cutoff window disclosed?), **P2** dynamic universe (survivorship/delisting handled?), **P5** net-of-friction (fees+spread+token+latency charged? = [[reddit-crowd-wisdom]] #3) — plus the crowd's window questions (IS or OOS? where does the curve end?). **Pass =** claim classified to the strongest tier its disclosures actually support, **every P1/P2/P5 failure discounts its money claim to zero in writing**, and a Critic independently re-runs the classification and concurs. P3/P4/P6 are killed here (executable only on our own agent — they live in Phase 4). **No Phase 1 before pass.**

## Phase 1 — Map your edge (production patterns → agents)
- [ ] Work through **NirDiamant/agents-towards-production** — observability, eval, guardrails, deployment, mapped onto agents. This is *your* existing playbook; fastest confidence win. ([[curriculum-draft]] Stage 2; note: educational/non-commercial license — study patterns, don't ship the code.)
- **Artifact:** a one-page "my production checklist for agents" (logging, eval, guardrails, deploy) in `wiki/concepts/`.

## Phase 2 — Study orchestration (three codebases, side-by-side)
Read these *comparatively* for roles + orchestration — not returns.
- [ ] **virattt/ai-hedge-fund** — cleanest multi-agent trading code; investor personas + Risk/Portfolio agents. Explicitly makes no trades. The reference design.
- [ ] **TradingAgents** (arXiv:2412.20138) — analysts → bull/bear *debate* → risk gate → portfolio decision. The reference *architecture*.
- [ ] **Moon Dev `src/agents/`** (local snapshot) — read per the ranked list in [[snapshot-survey]] §f: `swarm_agent.py` (multi-model consensus), `rbi_agent_pp_multi.py` (code-self-repair loop), `trading_agent.py`, `model_factory.py`, `strategy_agent.py`.
- **Steal** ([[snapshot-survey]] §d): multi-model consensus-as-library w/ anonymized reviewer · LLM-writes-code→subprocess→traceback→retry · deterministic-proposes/LLM-disposes gatekeeper · filesystem-as-bus composition · provider-agnostic model factory.
- **Avoid** ([[snapshot-survey]] anti-patterns): pixel-coordinate GUI automation, unsandboxed code running, unbounded loops, free-text action parsing, in-sample-only optimization.
- **Artifact:** `wiki/concepts/multi-agent-orchestration-patterns.md` — the 3 designs compared + the patterns worth stealing for *our* Forge ([[Agent Roles & Orchestrator — The Moat]]).

## Phase 3 — Learn the engines
- [ ] **Quick win:** stand up **freqtrade** in **dry-run** (paper mode out of the box) + bolt on **FreqAI**. Get a monitored bot running on fake money. ([[curriculum-draft]] Stage 3.)
- [ ] **Home platform:** learn **NautilusTrader** — deterministic, Rust-native, event-driven, research==live parity. *This speaks your language*; it's the natural capstone home. (Note: v2 RC has breaking changes.)
- [ ] Skim **Hummingbot** (market-making, venue-connector pattern) + **LEAN** (pro engine, C#-heavy) for architecture contrast.
- **Artifact:** a running freqtrade dry-run bot + a NautilusTrader "hello world" backtest, documented in `projects/trading-agents/`.

## Phase 4 — Build ONE paper-traded agent end-to-end (the capstone)
The recipe ([[curriculum-draft]] Stage 4), paper/dry-run **only**:
1. **Data:** OpenBB via MCP/REST/Python (normalized, provider-agnostic — fits an infra mindset).
2. **Engine:** NautilusTrader (your edge) or freqtrade dry-run (faster on-ramp).
3. **Validate:** prototype in backtesting.py → walk-forward / Monte Carlo (vectorbt or Jesse) → López de Prado guards. *No metric trusted until it survives out-of-sample.*
4. **Agent layer:** borrow *roles* from ai-hedge-fund/TradingAgents + *orchestration* from Moon Dev — **not** their returns.
5. **Production wrap:** agents-towards-production (observability, eval, guardrails) — monitor it like any service you run.
6. **Hard rule:** paper only. No funded keys, no live orders ([[Moon Dev — Research Brief & Leads]] §0; capital is human-authorized, [[Bootstrap to Self-Funding — The Agent Life Arc]]).
- **Artifact:** a monitored, paper-traded agent with an *honest* (out-of-sample-validated) performance report — even if the result is "no edge found." A clean negative result is a success here.

---

## The one rule that unifies it all
Every phase applies [[Operating Principle — Test Don't Wonder]]: a strategy that only fits the past is a confession, not a result; a reported Sharpe gets run through The Alpha Illusion + López de Prado before belief; "substantive" verdicts get a [Critic] pass before promotion. **Moon Dev is what this rule exists to catch.** Learn the architecture, discount the money claims to zero.

## §feed — how this feeds the cron engine
Each unchecked phase can spawn bounded study sessions via `_harness/queue.md` (e.g. "[Scout] read + summarize The Alpha Illusion into wiki/research/trading/", "[Scribe] draft the orchestration-patterns comparison"). The ongoing source-sweep (fork recency, Reddit, Wayback, arXiv) runs as recurring Scout jobs — see the queue. The [Critic] gates every promotion.
