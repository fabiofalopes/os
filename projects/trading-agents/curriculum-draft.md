---
tags: [trading, ai-agents, curriculum, research]
date: 2026-07-20
status: draft — first curated sweep (Scout)
related:
  - "[[Moon Dev — Research Brief & Leads]]"
  - "[[legitimacy-ledger]]"
---

# Learning Curriculum — AI Trading Agents

> **For:** a systems/network engineer. Your **edge** is infra — pipelines, monitoring, deployment, reliability, determinism. The **ML + finance** is the layer to add on top of that edge, not a replacement for it.
> **Stance:** learn first, execute later. No capital, no live trading ([[Moon Dev — Research Brief & Leads]] §0). Judge **code and method**, not personalities. Every resource below carries a verdict: **substantive / mixed / hype**, with a line of evidence.
> **Method note:** WebSearch was broken this session; every entry below was fetched directly from its GitHub page / raw README / arXiv abstract (or, for the Moon Dev repo, from our local Dec-2025 snapshot). Anything not verifiable is marked `to-verify`. Companion table: [[legitimacy-ledger]].

---

## The 4-stage learning path

1. **Market + backtest fundamentals — and why backtests lie.** Microstructure, overfitting, lookahead, walk-forward, Kelly/risk. Install the skepticism *before* touching any agent.
2. **Agent frameworks & production patterns.** Observability, evaluation, guardrails, deployment — your existing playbook applied to agents.
3. **Trading-specific agents & strategies.** The engines, the LLM/RL-for-finance work, the multi-agent architectures.
4. **Build one paper-traded agent end-to-end.** The capstone that proves the learning. Paper only.

---

## Stage 1 — Market + backtest fundamentals (why backtests lie)

### backtesting.py — `kernc/backtesting.py`
- **What:** a small, well-documented Python library for testing a trading rule against historical OHLC(V) candles. Simple strategy-class model, built-in optimizer, interactive charts.
- **Why it matters:** the *honest* first backtester. Small enough to read end-to-end, so you see exactly how a backtest can flatter you (overfitting via the optimizer, lookahead if you're careless). **Also the literal target of Moon Dev's RBI agent** (it emits `backtesting.py` code), so it connects the trigger to the fundamentals.
- **Currency:** 8.7k stars, 444 commits, 26 tags; last-commit timestamp not shown on the page → recency `to-verify`.
- **Verdict:** **substantive.** Evidence: mature, widely used, "Simple, well-documented API"; limitations are honest (BYO indicators, OHLC(V) only, AGPL-3.0).
- **Limits to know:** AGPL-3.0 (copyleft — matters if this ever ships); no built-in indicators; candle-only (no tick/order-book).

### vectorbt — `polakowo/vectorbt`
- **What:** vectorized backtesting "at scale" — packs thousands of parameter sets into NumPy arrays, Numba/Rust-accelerated. Portfolio/trade analytics, walk-forward, ML labeling, visualization.
- **Why it matters:** teaches you to sweep a parameter space *fast* — which is exactly how you discover how easy it is to overfit. The robustness/walk-forward tooling is the antidote.
- **Currency:** 8.4k stars, 1,077 commits, v1.1.0 dated Jul 5 2026; last-commit timestamp not shown → recency `to-verify`.
- **Verdict:** **mixed.** Evidence: genuinely powerful and "battle-tested," **but** the open-source repo is the *community edition* of the commercial **VectorBT PRO**, and the license is fair-code (Apache-2.0 + Commons Clause), not plain OSS. Best features live behind PRO.

### The Alpha Illusion (paper) — arXiv:2605.16895
- **What:** "The Alpha Illusion: Reported Alpha from LLM Trading Agents Should Not Be Treated as Deployment Evidence" (Yuxuan Ye et al., May 2026, preprint).
- **Why it matters:** the academic spine of this whole curriculum's FOMO-filter. It argues, with evidence, that the returns LLM-trading-agent papers report are **not** evidence you can deploy on. Read it *first*; it inoculates you against every "look at my agent's Sharpe" screenshot.
- **Currency:** May 2026 — the freshest item in this sweep.
- **Verdict:** **substantive (on-mission).** Evidence: directly addresses the failure mode the mission is built to avoid. Preprint (not yet peer-reviewed) — `to-verify` after a full read.
- **Pairs with:** the López de Prado overfitting guards already in the library ([[Moon Dev — Research Brief & Leads]] §3).

### Jesse — `jesse-ai/jesse` *(also Stage 3)*
- **What:** a Python crypto algo-trading framework: research → backtest → optimize → live/paper.
- **Why it matters here:** it markets backtests **"without look-ahead bias"** and ships **Monte Carlo Analysis** — a concrete, runnable example of *honest* backtest hygiene to study in Stage 1.
- **Currency:** 8.2k stars, 3,390 commits, MIT; last-commit timestamp not shown → recency `to-verify`.
- **Verdict:** **substantive.** Evidence: explicit anti-lookahead stance + Monte Carlo + MIT + docs/tutorials. (Recency unconfirmed.)

---

## Stage 2 — Agent frameworks & production patterns

### agents-towards-production — `NirDiamant/agents-towards-production`
- **What:** a code-first tutorial playbook for building **"production-ready GenAI agents"** — RAG, memory, tool use, multi-agent flows, security, tracing/observability, evaluation, APIs, containers, accelerator hosting, UI.
- **Why it matters:** **this is your bridge.** It maps the production skills you already have (observability, eval, guardrails, deployment) directly onto agents. Fastest confidence win in the whole path.
- **Currency:** 21.1k stars, 215 commits, 2.8k forks; last-commit timestamp not shown → recency `to-verify`.
- **Verdict:** **substantive (general, not trading-specific).** Evidence: broad, structured, production-focused coverage. Caveat: labeled **"Educational use only"** under a **custom non-commercial license** — study the patterns, don't ship the code as-is.

### ai-hedge-fund — `virattt/ai-hedge-fund`
- **What:** an explicitly **educational** multi-agent LLM "hedge fund." Investor-persona agents (Buffett, Munger, Burry, Cathie Wood, Druckenmiller, …) plus functional agents (Valuation, Sentiment, Fundamentals, Technicals, **Risk Manager**, **Portfolio Manager**). Ships a CLI, web app, and backtester.
- **Why it matters:** the **cleanest, most-readable multi-agent trading codebase** to study for *roles and orchestration*. It is the reference design to compare Moon Dev against.
- **Currency:** **62.3k stars**, 11k forks, 883 commits, v2.0.0 dated Jul 18 2026 — very active by every signal except a visible last-commit timestamp.
- **Verdict:** **substantive (as an orchestration study).** Evidence: MIT-licensed, installable, and — critically — it states plainly that **"the system does not actually make any trades"** and is for **"educational and research purposes only."** Study the agent roles, **not** the returns.
- **Surprise:** more stars than most "serious" engines, yet it's a non-trading proof-of-concept. Popularity ≠ production.

### Moon Dev's `moon-dev-ai-agents` (local Dec-2025 snapshot) + the fastmcp aggregator
- **What:** an experimental crypto trading system orchestrating **48+ specialized agents** (trading, risk, sentiment, whale, funding, liquidation, sniper, RBI…). `ModelFactory` abstracts 6 LLM providers (Claude/GPT-4/DeepSeek/Groq/Gemini/Ollama). Multi-exchange: Hyperliquid, BirdEye/Solana, Extended/X10. **Risk-first loop** (risk agent runs first; circuit breakers). **RBI agent** turns a YouTube/PDF/idea into a `backtesting.py` backtest via DeepSeek-R1.
- **Why it matters:** the *trigger*. Genuinely useful as a **multi-agent orchestration case study** — the ModelFactory abstraction, the risk-first main loop, and the "agent writes its own backtest" RBI pattern are real ideas worth stealing.
- **Currency:** our snapshot is Dec-2025 (recent enough). The public repo is gated/removed; the fastmcp.me aggregator page **failed to fetch (TLS cert error) → `to-verify`**, but it indexes a **Claude skill that mirrors this repo, which we already hold locally** (`.claude/skills/moon-dev-trading-agents/`), so the aggregator adds no unique content.
- **Verdict:** **mixed.** Evidence *for*: real, runnable code; clean orchestration patterns; explicitly **"experimental, educational."** Evidence *against*: FOMO-branded, crypto-degen flavor (up to 50x leverage, sniper/whale/million agents), **no audited out-of-sample or live track record.** Study the orchestration; discount the money claims.

### FinGPT — `AI4Finance-Foundation/FinGPT`
- **What:** open-source **financial LLMs** — low-cost fine-tuning (LoRA) of open base models for sentiment, forecasting, NER, relation extraction, headline classification. Five-layer stack (data source → data engineering → LLMs → task → application); **FinGPT-Benchmark**.
- **Why it matters:** the academic anchor for the *LLM* side of "LLM/RL for finance," with real papers behind it.
- **Currency:** 20.9k stars, 691 commits, v1.0.0 dated Apr 8 2026 — active.
- **Verdict:** **substantive.** Evidence: mature docs/notebooks/datasets/model weights + a paper trail. Note: the page shows **FinGPT-Benchmark, not FinBen**, and **no distinct agent layer** — it's a model/data framework, not an agent runtime.

### FinRL — `AI4Finance-Foundation/FinRL`
- **What:** the reference **reinforcement-learning-for-finance** framework — Market Environments, DRL Agents (A2C/DDPG/PPO/SAC/TD3), Financial Applications (stocks, portfolio, crypto, HFT); `multi-agent-learning` topic; a `train-test-trade` workflow.
- **Why it matters:** the RL counterpart to FinGPT; the standard on-ramp if you want RL-based agents rather than LLM-based ones.
- **Currency:** 15.8k stars, 3,249 commits, v0.3.8 dated Mar 20 2026 — active.
- **Verdict:** **substantive.** Evidence: deep paper trail (NeurIPS workshops, ICAIF, FinRL-Meta). Note: this classic repo is explicitly for **"education, benchmarking, and research prototyping"** — production users are pointed to **FinRL-X / FinRL-Trading**.

---

## Stage 3 — Trading-specific agents & strategies

### freqtrade (+ FreqAI) — `freqtrade/freqtrade`
- **What:** the most mature open-source **crypto trading bot** (Python 3.11+), with Telegram/webUI control, dry-run (paper) mode, backtesting, plotting, and money management. **FreqAI** adds **"Adaptive prediction modeling"** that **"self-trains to the market"** — the ML on-ramp.
- **Why it matters:** the fastest path to a *monitored, deployable* bot — and **dry-run is paper trading out of the box**, which is exactly Stage 4. FreqAI is where you bolt ML onto a real, well-engineered pipeline.
- **Currency:** strong maintenance signals (CI, codecov, docs badges, develop/stable branches); star count not shown on the raw README → `to-verify`.
- **Verdict:** **substantive.** Evidence: production-grade maturity, real exchange coverage, first-class ML module.

### NautilusTrader — `nautechsystems/nautilus_trader`
- **What:** an **open-source, production-grade, Rust-native** trading engine with a **deterministic event-driven runtime** and **Python as the control plane** (PyO3 bindings). Same execution semantics + time model from research → simulation → live; nanosecond-resolution tick/bar/order-book backtests; modular venue adapters.
- **Why it matters:** **this speaks your language.** Determinism, a single event-driven core, research/live parity, production posture — it's the reliability-minded engineer's platform and the natural home for the capstone.
- **Currency:** 24.9k stars, 19,956 commits, 137 releases, latest **1.230.0 Beta (Jun 29 2026)** — very active.
- **Verdict:** **substantive.** Evidence: production-grade architecture + release cadence. Caveat: **"still under active development"** with **breaking changes between releases** during the v2 release-candidate (targeting a stable 2.x API); LGPL-3.0.

### Hummingbot — `hummingbot/hummingbot`
- **What:** open-source (Apache-2.0) framework for **high-frequency crypto market-making bots** across CEX and DEX. Standardized exchange connectors (CLOB CEX / CLOB DEX / AMM DEX), spot + perpetual, Docker deploy, Gateway middleware for DEXs.
- **Why it matters:** the reference for **market-making** and for seeing how a mature project standardizes dozens of venue APIs — a connector/integration pattern an infra engineer will appreciate.
- **Currency:** 19.2k stars, 27,566 commits, 109 releases, latest **v2.15.0 (Jun 16 2026)** — very active.
- **Verdict:** **substantive.** Evidence: huge commit history + release cadence + real-world adoption claims.

### LEAN — `QuantConnect/Lean`
- **What:** an **event-driven, professional-caliber algorithmic trading platform** for backtesting and live trading, with alternative data and pluggable models. Python + C# (repo is ~94% C#), CLI + Docker workflow.
- **Why it matters:** a full professional engine and **a place paper-traded strategies can actually run**; the modular "models for all major plug-in points" design is a good architecture study.
- **Currency:** 20.6k stars, 13,272 commits, 5.1k forks, Apache-2.0 — established; last-commit timestamp not shown.
- **Verdict:** **substantive.** Evidence: pro-caliber, community-backed, well-documented. Caveat: C#-heavy and complex — steeper climb than freqtrade for a Python-first learner.

### TradingAgents (paper) — arXiv:2412.20138
- **What:** "TradingAgents: Multi-Agents LLM Financial Trading Framework" (Yijia Xiao, Edward Sun, Di Luo, Wei Wang). A multi-agent LLM system patterned on a trading firm: **fundamental/sentiment/technical analysts**, **bull vs. bear researchers who debate**, **traders with varied risk profiles**, and a **risk-management team**.
- **Why it matters:** the **reference architecture** for multi-agent LLM trading — the bull/bear *debate* and the explicit risk layer are the ideas to internalize.
- **Currency:** v1 Dec 28 2024, v7 Jun 3 2025 — actively revised.
- **Verdict:** **substantive (preprint).** Evidence: coherent, firm-inspired architecture; claims superior total returns / Sharpe / drawdown vs baselines — **treat those claims through the Alpha-Illusion / López-de-Prado lens.** Not peer-reviewed (notes an oral at "Multi-Agent AI in the Real World").

### FinAgent (paper) — arXiv:2402.18485
- **What:** "A Multimodal Foundation Agent for Financial Trading: **Tool-Augmented, Diversified, and Generalist**" (Wentao Zhang et al., Bo An's group). A multimodal agent that reasons over text + numeric/candle data and uses tools to trade across markets.
- **Why it matters:** the **multimodal** angle — fusing language with price/volume signal — that pure-LLM agents miss. Good Stage-3 depth.
- **Currency:** v1 Feb 28 2024, v3 Jun 28 2024.
- **Verdict:** **substantive (preprint).** Evidence: serious author group, tool-augmented design. *ID verified via arXiv API* — an earlier guess (2402.03755) was a different paper (QuantAgent).

### QuantAgent (paper, adjacent) — arXiv:2402.03755
- **What:** "QuantAgent: Seeking Holy Grail in Trading by Self-Improving Large Language Model" (Saizhuo Wang, Hang Yuan, Lionel M. Ni, Jian Guo). A **two-loop self-improving** LLM agent: an inner loop refines answers from a knowledge base, an outer loop tests them in real-market scenarios to grow the knowledge base.
- **Why it matters:** the **self-improving / feedback-loop** pattern — relevant to anyone thinking about agents that learn from deployment.
- **Currency:** submitted Feb 6 2024, preprint.
- **Verdict:** **substantive (adjacent, preprint).** Evidence: interesting self-improvement mechanism; surfaced while verifying FinAgent. `to-verify` relevance after a full read.

---

## Stage 4 — Build one paper-traded agent end-to-end (capstone)

### OpenBB — `OpenBB-finance/OpenBB`
- **What:** an open-source **"Open Data Platform"** — the **data layer** for any agent. Python SDK (`pip install openbb`), CLI (`openbb-cli`), local API server (`openbb-api`), OpenBB Workspace UI, and — notably — **MCP servers + REST APIs** for AI agents. Many data-provider integrations.
- **Why it matters:** **your capstone's data pipeline.** Normalized market data behind Python/REST/**MCP** is a perfect fit for an infra mindset; it feeds whatever engine you choose.
- **Currency:** **70.8k stars**, 6,863 commits, 7.2k forks, latest stable release Apr 25 2026 — very active.
- **Verdict:** **substantive.** Evidence: huge community, broad integrations, agent-friendly interfaces. Note: it's a **data layer, not execution/risk infra** — pair it with an engine.

### The capstone recipe (paper only)
1. **Data:** OpenBB (via MCP/REST/Python) — normalized, provider-agnostic.
2. **Engine:** **NautilusTrader** if you want the production-grade, deterministic, research==live path (your edge); **freqtrade dry-run** if you want a faster, batteries-included on-ramp with monitoring built in.
3. **Validation:** prototype the idea in **backtesting.py**, then run it through **walk-forward / Monte Carlo** (vectorbt or Jesse) and the **López de Prado overfitting guards** before trusting any metric.
4. **Agent layer:** borrow the *roles* from ai-hedge-fund / TradingAgents (analysts → bull/bear debate → risk gate → portfolio decision) and the *orchestration patterns* from the Moon Dev repo (ModelFactory, risk-first loop) — **not** their returns.
5. **Production wrap:** apply agents-towards-production (observability, eval, guardrails) so the agent is *monitored* like any other service you'd run.
6. **Hard rule:** paper/dry-run only. No keys with funds, no live orders ([[Moon Dev — Research Brief & Leads]] §0).

---

## Cross-cutting caveats (read once, remember always)
- **No LLM-agent repo here publishes an audited, out-of-sample, walk-forward *live* track record.** All returns are backtest/paper. That is the point of Stage 1.
- **"Actively maintained" rests on stars / commit counts / release dates**, because GitHub pages did not expose a last-commit timestamp in this sweep. vectorbt and backtesting.py recency especially → `to-verify`.
- **Licenses matter if this ever ships:** vectorbt = fair-code (Apache-2.0 + Commons Clause, best bits in commercial PRO); backtesting.py = AGPL-3.0; NirDiamant = custom non-commercial; NautilusTrader = LGPL-3.0. freqtrade/Lean/Hummingbot/ai-hedge-fund/Jesse = permissive (GPL/Apache/MIT family).
- **Not financial advice. No capital deployment.** Learn first.
