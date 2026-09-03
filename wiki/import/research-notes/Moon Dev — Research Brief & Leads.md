---
tags: [project, trading, ai-agents, research, moon-dev]
date: 2026-07-20
status: brief + leads — converging before deep research
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
---

# Moon Dev & AI Trading Agents — Research Brief & Leads

> **Intent (distilled from the 2026-07-20 dump):** Learn AI trading agents properly — *learn first, execute later* — by finding the best, most recent, most data-rich resources possible. Moon Dev is the trigger, not the ceiling. Filter the FOMO/hype layer ruthlessly; judge the **code and method**, not the personality. Never settle for an older version when a newer one exists. This note captures the raw leads + generated ideas; we converge on scope/method before launching any deep research.

## 0. Hard rules for this research
1. **Learn, don't copy.** Goal is to understand the expertise, not to parrot some repo. Step by step, see it for ourselves.
2. **Filter FOMO.** Anything flashy/"we're losing money just by looking" is marketing until proven otherwise. Judge technical substance.
3. **Latest or nothing.** For any repo, we want the most-recently-updated version/fork — never an old stale one (the MrFadiAi example = years-old, useless for now).
4. **No capital, no live trading.** This is Stage 0/1 ([[Bootstrap to Self-Funding — The Agent Life Arc]]). Paper and study only.
5. **Test, don't wonder** ([[Operating Principle — Test Don't Wonder]]): every resource gets a verdict; backtest claims get checked for overfitting/lookahead.

## 1. Raw leads (from the dump — preserve all)

### Moon Dev core
| Lead | Note / verdict |
|---|---|
| `github.com/moondevonyt/moon-dev-ai-agents` | The repo. Claimed "free & open source" but effectively gated/removed publicly. **Our copy: Dec 2025 snapshot** (via Software Heritage) — recent enough to be useful. |
| Software Heritage archive: `archive.softwareheritage.org/browse/origin/directory/?origin_url=https://github.com/moondevonyt/moon-dev-ai-agents&visit_type=git` | **How we got the Dec-2025 snapshot.** SWH has an API to pull a full snapshot programmatically — mine this. |
| `algotradecamp.com` | The bootcamp. Content now members-only / gone. → **Wayback Machine** to recover historical pages. |
| `moondev.com` | The FOMO/sales site. Low signal, high hype — skim for what it claims, discount the urgency. |
| `fastmcp.me/Skills/Details/30/moon-dev-trading-agents` | An **indexed-skill aggregator** that mirrors the repo. Pattern: aggregators sometimes hold an indexed copy when the source goes dark. Find more aggregators like this. |

### Forks & mirrors (the "QA people fork everything" angle)
| Lead | Note |
|---|---|
| `github.com/molenaar/Trading-Algos-By-Moon-Dev` | Fork/mirror of Moon Dev trading algos — **flagged "seems very important."** Check recency. |
| `github.com/molenaar/AI--LLMs-For-Automated-Trading` | LLMs-for-trading material — flagged important. |
| `github.com/molenaar/mslearn-ai-document-intelligence` | Adjacent (doc intelligence) — "interesting in general." |
| `github.com/TomData/Trading-Algos` | Trading algos — flagged important. Check recency + license. |
| `github.com/MrFadiAi/ai-agents-for-trading` | **Counter-example: old, stale fork — do NOT use.** Shows why we must date-check every fork. |

### Adjacent (user-provided, higher-signal)
| Lead | Note |
|---|---|
| `github.com/NirDiamant/agents-towards-production` | "Agents towards production" — popular, well-regarded. Not trading-specific but strong on *making agents real/robust*. Study for the production-engineering side. |

## 2. FINDING — the local backup is not on this box ⚠️
Searched the vault + all of `~` (deep): **no `moon-dev*`, `trading*`, or fork-named directory exists here**, and there's only one Obsidian vault. The Dec-2025 backup you referenced is not present on this machine. **Options:** it's on another machine · give me the exact path · or we re-pull it from Software Heritage (we have the archive URL). *This decides whether "mine the local backup first" is even possible — see questions below.*

## 3. Generated leads (you asked for many more — these are triggers on triggers)

### Recover the "gone" content
- **Software Heritage API** — pull the full Dec-2025 git snapshot programmatically (`swh` CLI / API), not just browse it. Get the actual code + history.
- **Wayback Machine (web.archive.org)** — crawl historical `algotradecamp.com` + `moondev.com` for curriculum, video lists, free resources that were public before paywalling.
- **GitHub fork network** — enumerate ALL forks of `moon-dev-ai-agents` via the API, **sort by `pushed_at`**, and take the most-recently-updated. This directly solves "never want an older version." Also check stargazers/watchers for who's actively maintaining.
- **YouTube transcript harvest** — Moon Dev's videos (even if "on loop") have transcripts; bulk-fetch via `youtube-transcribe` skill, dedupe, mine for the actual technical content under the hype.

### Adjacent high-signal repos to study (mark `to-verify` before deep-clip)
- `freqtrade/freqtrade` — mature open algo-trading bot, has an ML/RL module (FreqAI). Production-grade reference.
- `QuantConnect/Lean` — the open algo engine; where paper-traded strategies actually run.
- `nautechsystems/nautilus_trader` — high-performance event-driven backtest/live platform.
- `virattt/ai-hedge-fund` — popular multi-agent LLM "hedge fund" (educational; study the agent roles, not the returns). `to-verify` current state.
- `AI4Finance-Foundation/FinGPT` + `FinRL` — LLM/RL for finance, with papers. Strong academic anchor.
- `OpenBB-finance/OpenBB` — open "Bloomberg terminal"; data layer for any trading agent.
- `hummingbot/hummingbot`, `jesse-ai/jesse`, `polakowo/vectorbt`, `backtesting-py/backtesting.py` — the backtest/execution toolbench.
- **arXiv q-fin + cs.MA**: "TradingAgents" (multi-agent LLM trading), "FinAgent", alpha-generation papers. The SOTA layer.

### Reddit as crowd-knowledge (you flagged this as high-value)
Mine these for what practitioners actually ask/find (the "crowd knows" signal):
- `r/algotrading`, `r/quant`, `r/Trading`, `r/Daytrading`
- `r/MachineLearning`, `r/LocalLLaMA`, `r/AI_Agents`, `r/LangChain`
- `r/investing`, `r/stocks`, `r/FinancialCareers`
- Method: search "moon dev", "ai trading agent", "LLM backtest", "freqtrade ml"; read the *questions* (they reveal what people are really after) and the top-vetted answers. Archive good threads to `wiki/research/trading/reddit/`.

### Legitimacy-assessment method (judge code, not personality)
- Separate **technical content** (does the code run? does it backtest *honestly* — no lookahead, no overfit, proper walk-forward?) from **marketing** (testimonials, urgency, "you're losing money"). 
- Run any claimed strategy through the López de Prado overfitting guards we already clipped ([[Sources — Curated Seed Library]] §C). A strategy that only fits the past is a confession, not a result.
- Verdict per resource: `substantive / mixed / hype` — with the evidence.

### Learning path (leverage YOUR edge: you're a systems/network engineer)
Your infra skills (pipelines, monitoring, deployment, reliability) are the *edge*; the ML/finance is the layer to add. Path:
1. **Market + backtest fundamentals** (microstructure, why backtests lie, Kelly/risk) — López de Prado + Kelly already in the library.
2. **Agent frameworks** (the NirDiamant production patterns; LangGraph/CrewAI/AutoGen idioms).
3. **Trading-specific agents** (freqtrade/FreqAI, the multi-agent LLM papers).
4. **Build one paper-traded agent** end-to-end — the capstone that proves the learning.

### Feed it into the cron engine
- **[Scout]** jobs that mine one source family per tick (SWH snapshot · Wayback · fork network · Reddit · arXiv) — incremental, bounded.
- A **[Critic]** pass on every "substantive" verdict before it's promoted.
- A **[Quant]** job that takes one vetted strategy and stands up a *paper* backtest.

## 4. Proposed structure (settle at convergence)
```
projects/trading-agents/
├── Moon Dev — Research Brief & Leads.md   (this note)
├── legitimacy-ledger.md                   (per-resource verdicts: substantive/mixed/hype)
├── learning-path.md                       (the curriculum above, tracked)
└── repos/                                 (cloned/pulled snapshots, gitignored if large)
wiki/research/trading/                     (distilled durable knowledge: concepts, methods)
```

## 5. Next steps (pending the convergence questions)
- Resolve the missing-backup question (below).
- Agree scope + method + depth.
- Then — and only then — launch the first bounded research sweep.
