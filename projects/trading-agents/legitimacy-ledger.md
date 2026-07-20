---
tags: [trading, ai-agents, curriculum, research]
date: 2026-07-20
status: living ledger — append as sources are swept
related:
  - "[[Moon Dev — Research Brief & Leads]]"
  - "[[curriculum-draft]]"
---

# Legitimacy Ledger — AI Trading Agent Resources

> Per-resource verdicts: **substantive / mixed / hype**, with a line of evidence. Judge **code and method**, not personalities ([[Moon Dev — Research Brief & Leads]] §3). This ledger **grows** as more source families are swept (SWH, Wayback, fork network, Reddit, arXiv).
> **Method:** fetched directly from GitHub pages / raw READMEs / arXiv abstracts (WebSearch was broken this session). `to-verify` = could not fetch or confirm. Not financial advice; no capital deployment.

**Learning-stage key:** 1 = backtest fundamentals / why backtests lie · 2 = agent frameworks & production · 3 = trading-specific agents & strategies · 4 = build-one-end-to-end capstone.

| Resource | What it is | Currency | Verdict | Evidence (1 line) | Stage |
|---|---|---|---|---|---|
| **freqtrade** (+FreqAI) `freqtrade/freqtrade` | Mature OSS crypto bot; FreqAI = adaptive ML that "self-trains to the market"; dry-run paper mode | Active (CI/codecov/docs badges, develop+stable branches); stars not on raw README → `to-verify` | **substantive** | Production-grade bot + first-class ML module + paper mode out of the box | 3 (→4) |
| **LEAN** `QuantConnect/Lean` | Event-driven pro-caliber algo platform; backtest+live; Python+C# (~94% C#) | 20.6k★, 13,272 commits, 5.1k forks, Apache-2.0; last-commit ts not shown | **substantive** | Pro engine where paper strategies run; modular plug-in models; C#-heavy/complex | 3 (→4) |
| **NautilusTrader** `nautechsystems/nautilus_trader` | Production-grade Rust-native event-driven engine; Python control plane; research==live parity | 24.9k★, 19,956 commits, 137 releases, v1.230.0 Beta Jun 29 2026; LGPL-3.0 | **substantive** | Deterministic event-driven core + release cadence; breaking changes during v2 RC | 3→4 |
| **Hummingbot** `hummingbot/hummingbot` | HFT crypto market-making bots; CEX+DEX connectors; Docker; Gateway middleware | 19.2k★, 27,566 commits, 109 releases, v2.15.0 Jun 16 2026; Apache-2.0 | **substantive** | Huge commit history + release cadence + standardized venue connectors | 3 |
| **Jesse** `jesse-ai/jesse` | Python crypto framework: research→backtest→optimize→live/paper; Monte Carlo | 8.2k★, 3,390 commits, MIT; last-commit ts not shown → recency `to-verify` | **substantive** | Explicit "without look-ahead bias" + Monte Carlo + MIT + docs | 1 & 3 |
| **vectorbt** `polakowo/vectorbt` | Vectorized backtesting at scale (NumPy/Numba/Rust); walk-forward, ML labels | 8.4k★, 1,077 commits, v1.1.0 Jul 5 2026; fair-code Apache-2.0+Commons Clause | **mixed** | Powerful, but OSS = community edition of commercial PRO; best bits paywalled | 1 |
| **backtesting.py** `kernc/backtesting.py` | Small, well-documented OHLC(V) backtester; optimizer; interactive charts | 8.7k★, 444 commits, 26 tags; last-commit ts not shown → recency `to-verify` | **substantive** | Honest, readable, widely used; BYO indicators; AGPL-3.0; target of Moon Dev RBI | 1 |
| **FinGPT** `AI4Finance-Foundation/FinGPT` | Open financial LLMs (LoRA fine-tuning); 5-layer stack; FinGPT-Benchmark | 20.9k★, 691 commits, v1.0.0 Apr 8 2026 | **substantive** | Docs/notebooks/weights + paper trail; shows FinGPT-Benchmark (not FinBen), no agent layer | 2 & 3 |
| **FinRL** `AI4Finance-Foundation/FinRL` | RL-for-finance framework; DRL agents (A2C/PPO/…); train-test-trade; multi-agent topic | 15.8k★, 3,249 commits, v0.3.8 Mar 20 2026 | **substantive** | Deep paper trail; classic repo = education/benchmarking; production → FinRL-X | 2 & 3 |
| **ai-hedge-fund** `virattt/ai-hedge-fund` | Educational multi-agent LLM "hedge fund"; investor personas + Risk/Portfolio agents | **62.3k★**, 11k forks, 883 commits, v2.0.0 Jul 18 2026; MIT | **substantive** (as orchestration study) | Cleanest multi-agent example; explicitly "does not actually make any trades" | 2 & 3 |
| **OpenBB** `OpenBB-finance/OpenBB` | Open "Open Data Platform" data layer; SDK/CLI/API/Workspace; MCP + REST for agents | **70.8k★**, 6,863 commits, 7.2k forks, stable release Apr 25 2026 | **substantive** | Huge community + agent-friendly MCP/REST/Python; data layer, not execution | 1 & 4 |
| **agents-towards-production** `NirDiamant/agents-towards-production` | Code-first tutorials for production GenAI agents (RAG/eval/observability/deploy/security) | 21.1k★, 215 commits, 2.8k forks; last-commit ts not shown → recency `to-verify` | **substantive** (general, not trading) | Broad production coverage = the systems-engineer's bridge; "Educational use only", non-commercial license | 2 |
| **TradingAgents** (paper) arXiv:2412.20138 | Multi-agent LLM trading: analysts + bull/bear researcher debate + traders + risk team | v1 Dec 28 2024, v7 Jun 3 2025; preprint (oral @ "Multi-Agent AI in the Real World") | **substantive** (preprint) | Reference multi-agent architecture; returns claims need Alpha-Illusion/LdP lens | 3 |
| **FinAgent** (paper) arXiv:2402.18485 | Multimodal foundation agent for trading: tool-augmented, diversified, generalist | v1 Feb 28 2024, v3 Jun 28 2024; preprint | **substantive** (preprint) | Serious group (Bo An); multimodal+tools. ID verified via arXiv API (2402.03755 was QuantAgent) | 3 |
| **The Alpha Illusion** (paper) arXiv:2605.16895 | Argues reported LLM-agent alpha ≠ deployment evidence | May 16 2026; preprint (freshest item) | **substantive** (on-mission) | Academic spine of the FOMO-filter; `to-verify` after full read | 1 |
| **QuantAgent** (paper, adjacent) arXiv:2402.03755 | Self-improving LLM for mining trading signals; inner/outer feedback loop | Submitted Feb 6 2024; preprint | **substantive** (adjacent, preprint) | Interesting self-improvement loop; surfaced while verifying FinAgent | 3 |
| **fastmcp.me aggregator** `/Skills/Details/30/moon-dev-trading-agents` | Indexed-skill aggregator that mirrors the Moon Dev repo | Fetch failed (TLS cert error) both attempts → `to-verify` | **to-verify** | Indexes a Claude skill we already hold locally; adds no unique content | — |
| **Moon Dev `moon-dev-ai-agents`** (local Dec-2025 snapshot) | Experimental crypto system: 48+ agents, ModelFactory (6 LLMs), multi-exchange, risk-first loop, RBI backtest agent | Snapshot Dec-2025 (recent); public repo gated/removed | **mixed** | Real orchestration patterns (ModelFactory, risk-first, RBI) BUT FOMO-branded, 50x-leverage degen flavor, no audited live record | 2 & 3 |

## Notes for future sweeps
- **Recency gap:** GitHub pages didn't expose last-commit timestamps here. When sweeping forks (brief §3), sort by `pushed_at` to get true recency — resolves the `to-verify` on vectorbt, backtesting.py, Jesse, NirDiamant, Lean.
- **Promote-before-Critic:** every **substantive** verdict gets a [Critic] pass before promotion ([[Moon Dev — Research Brief & Leads]] §3).
- **Paper claims:** run any reported Sharpe/return through the López de Prado overfitting guards + The Alpha Illusion framing before believing it.
