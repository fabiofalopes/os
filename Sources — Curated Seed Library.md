---
tags: [sources, research, curation, meta]
date: 2026-07-20
status: living — Scout role maintains this
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[Skills Harvest — What's Here & What To Do Differently]]"
---

# Sources — Curated Seed Library

> The Scout's reading list, pre-evaluated. Each entry: **what it is → what it gives the harness → priority**. ✓ = fetched & verified this session. `to-verify` = URL/id from memory, confirm before deep-clip. This is the "fetch amazing sources, curate knowledge" queue.

## A. Self-harnessing / self-improving agents — *the core literature*
This is how the mind "keeps harnessing itself." Highest priority.

| Source | What it gives us | Pri |
|---|---|---|
| **SEAL — Self-Adapting Language Models** ✓ (arXiv:2506.10943, MIT) | Model writes its own "self-edit" → SFT → **persistent weight updates**; RL loop rewards *downstream performance of the updated model*. The purest "learning-to-learn" reference. We can't fine-tune closed models, but the *pattern* (generate adaptation → measure → keep if better) is exactly SkillOpt-in-text. Clipped → [[SEAL — Self-Adapting Language Models]]. | ★★★ |
| **microsoft/SkillOpt** ✓ | Validation-gated text-space skill optimizer + `SkillOpt-Sleep` overnight self-evolution. Our **Smith** engine. | ★★★ |
| **Voyager** ✓ (arXiv:2305.16291) | Auto-curriculum + **skill library** + iterative prompting w/ env feedback. The blueprint for "agent builds its own growing skill library." Clipped → [[Voyager — Open-Ended Embodied Agent]]. | ★★★ |
| **Reflexion** ✓ (arXiv:2303.11366) | Verbal self-reflection stored in memory → better next attempt, no weight change. Cheap self-improvement we can run today. Clipped → [[Reflexion — Verbal Reinforcement Learning]]. | ★★☆ |
| **Self-Refine** (arXiv:2303.17651 `to-verify`) | Same model generates → critiques → refines. The inner loop of every writer/distiller role. | ★★☆ |
| **ADAS — Automated Design of Agentic Systems** ✓ (arXiv:2408.08435) | A meta-agent *searches over agent designs* and keeps the best. The "harness improves the harness" idea, formalized. Directly informs our orchestrator. Clipped → [[ADAS — Automated Design of Agentic Systems]]. | ★★★ |
| **Gödel Agent** (arXiv:2502.14854 `to-verify`) | Self-referential agent that rewrites its own policy given a reward. Theoretical ceiling of self-improvement; read for the safety/governance lessons. | ★☆☆ |
| **Generative Agents** (arXiv:2304.03442) | Memory stream + reflection + planning; importance scoring (recency×.5+relevance×3+importance×2). Already cited in Forge — the memory model. | ★★☆ |
| **Letta / MemGPT** | Tiered memory (core ↔ archival), git-backed. Forge's memory ancestor. | ★★☆ |
| **STaR / ReST / Self-Rewarding LMs** | Self-generated training data bootstraps capability. Background theory for why "sessions on sessions" compounds. | ★☆☆ |

## B. Agent skills & harnesses — *the body the mind drives*

| Source | What it gives us | Pri |
|---|---|---|
| **Anthropic Agent Skills** ✓ | `SKILL.md` + YAML frontmatter; **progressive disclosure** (metadata at startup → full file on relevance → linked files/scripts on demand); now an **open standard**. This is *our* skill format + loading discipline. | ★★★ |
| **huggingface/skills** ✓ | Seed catalog + `hf skills add`; ML/training/datasets/Spaces/deploy skills. Adopt the format, harvest the ML skills. | ★★★ |
| **awesome-claude-skills / community skill lists** (`to-verify`) | Discover what others forged; steal patterns, avoid reinventing. Scout sweeps these. | ★★☆ |
| **OpenCode + Hermes** (present locally) | Two other harnesses on this box. Cross-pollinate skills (Forge §8 portability). See [[Skills Harvest — What's Here & What To Do Differently]]. | ★★☆ |

## C. Quant / ML-finance / making money — *the value imperative*

| Source | What it gives us | Pri |
|---|---|---|
| **Quantpedia** ✓ | 1000+ academic trading systems, a Screener (style/market), Python out-of-sample implementations, an API "alternative dataset." **The Scout's #1 alpha-idea mine.** | ★★★ |
| **Marcos López de Prado — *Advances in Financial ML* + *ML for Asset Managers*** ✓ | The rigorous ML-finance bible: labeling, fractional differentiation, backtest overfitting, meta-labeling. Prevents us from fooling ourselves. Overfitting paper cluster (PBO/CSCV, DSR, Pseudo-Mathematics) fetched & verified from SSRN/davidhbailey.com; AFML book itself still unfetched (paywalled). Clipped → [[López de Prado — Backtest Overfitting Guards]]. | ★★★ |
| **Ernest Chan — *Algorithmic/Quantitative Trading*** | Practical mean-reversion/momentum strategy engineering, retail-feasible. | ★★☆ |
| **Kelly Criterion (Thorpe) + *The Kelly Capital Growth Investment Criterion*** ✓ | Position sizing = how not to go bust. Non-negotiable before any live capital. Wikipedia + Thorp's book page fetched & verified; Thorp 2006 paper PDF mirrors are dead (logged in the note's evidence ledger). Clipped → [[Kelly Criterion — Position Sizing]]. | ★★★ |
| **QuantConnect / Lean** (open engine) | Free backtesting + paper + live execution infra. Where paper-traded strategies actually run. | ★★☆ |
| **yfinance / Alpha Vantage** | Free market data to backtest with. | ★★☆ |
| ***The Man Who Solved the Market* (Simons/Renaissance)** | Narrative of what compounding edge looks like at the extreme. Mindset, not method. | ★☆☆ |
| **Prediction markets — Kalshi / Polymarket / Metaculus** | "Being ahead of the curve" made measurable; forecasting skill + real money markets. A low-capital first value loop. | ★★☆ |

## D. Judgment / being-ahead — *the edge is calibration*

| Source | What it gives us | Pri |
|---|---|---|
| ***Superforecasting* (Tetlock)** | How to update beliefs and beat experts. The epistemic core of "ahead of the curve, not naive." | ★★☆ |
| ***Thinking in Bets* (Annie Duke)** | Decision quality ≠ outcome quality. Stops result-driven self-deception. | ★★☆ |
| **Papers with Code (SOTA leaderboards)** | Objective "where is the edge right now" per task. Scout tracks deltas. | ★★☆ |
| **huggingface.co/papers + arXiv q-fin / cs.AI daily** | Fresh-firehose of SOTA; the Scout's daily intake. | ★★☆ |

---

## Fetch protocol (how Scout uses this)
1. Work the ★★★ tier first, one domain at a time.
2. Clip via `smart-web-clipper`/`defuddle` → `wiki/research/<domain>/`, atomic (`zettel-atomizer`).
3. Every clipped source gets a one-line **"what it gives the harness"** verdict — no clipping without a verdict (see [[Operating Principle — Test Don't Wonder]]).
4. Promote durable insight → `wiki/concepts/`; a repeatable procedure → stage as a **skill candidate** for the Smith.
5. Mark `to-verify` URLs confirmed once fetched; drop dead ones to `LOG.md`.
