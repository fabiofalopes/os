---
tags: [trading, ai-agents, curriculum, research]
date: 2026-07-20
recency-swept: 2026-07-21
critic-swept: 2026-07-21
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
| **LEAN** `QuantConnect/Lean` | Event-driven pro-caliber algo platform; backtest+live; Python+C# (~94% C#) | 20.6k★, 13,272 commits, 5.1k forks, Apache-2.0; **pushed 2026-07-20 (active)** | **substantive** | Pro engine where paper strategies run; modular plug-in models; C#-heavy/complex | 3 (→4) |
| **NautilusTrader** `nautechsystems/nautilus_trader` | Production-grade Rust-native event-driven engine; Python control plane; research==live parity | 24.9k★, 19,956 commits, 137 releases, v1.230.0 Beta Jun 29 2026; LGPL-3.0 | **substantive** | Deterministic event-driven core + release cadence; breaking changes during v2 RC | 3→4 |
| **Hummingbot** `hummingbot/hummingbot` | HFT crypto market-making bots; CEX+DEX connectors; Docker; Gateway middleware | 19.2k★, 27,566 commits, 109 releases, v2.15.0 Jun 16 2026; Apache-2.0 | **substantive** | Huge commit history + release cadence + standardized venue connectors | 3 |
| **Jesse** `jesse-ai/jesse` | Python crypto framework: research→backtest→optimize→live/paper; Monte Carlo | 8.2k★, 3,390 commits, MIT; **pushed 2026-07-16 (active)** | **substantive** | Explicit "without look-ahead bias" + Monte Carlo + MIT + docs | 1 & 3 |
| **vectorbt** `polakowo/vectorbt` | Vectorized backtesting at scale (NumPy/Numba/Rust); walk-forward, ML labels | 8.4k★, 1,077 commits, v1.1.0 Jul 5 2026; **pushed 2026-07-14 (active)**; fair-code Apache-2.0+Commons Clause | **mixed** | Powerful, but OSS = community edition of commercial PRO; best bits paywalled | 1 |
| **backtesting.py** `kernc/backtesting.py` | Small, well-documented OHLC(V) backtester; optimizer; interactive charts | 8.7k★, 444 commits, 26 tags; **pushed 2026-07-20 (active)** | **substantive** | Honest, readable, widely used; BYO indicators; AGPL-3.0; target of Moon Dev RBI | 1 |
| **FinGPT** `AI4Finance-Foundation/FinGPT` | Open financial LLMs (LoRA fine-tuning); 5-layer stack; FinGPT-Benchmark | 20.9k★, 691 commits, v1.0.0 Apr 8 2026 | **substantive** | Docs/notebooks/weights + paper trail; shows FinGPT-Benchmark (not FinBen), no agent layer | 2 & 3 |
| **FinRL** `AI4Finance-Foundation/FinRL` | RL-for-finance framework; DRL agents (A2C/PPO/…); train-test-trade; multi-agent topic | 15.8k★, 3,249 commits, v0.3.8 Mar 20 2026 | **substantive** | Deep paper trail; classic repo = education/benchmarking; production → FinRL-X | 2 & 3 |
| **ai-hedge-fund** `virattt/ai-hedge-fund` | Educational multi-agent LLM "hedge fund"; investor personas + Risk/Portfolio agents | **62.3k★**, 11k forks, 883 commits, v2.0.0 Jul 18 2026; MIT | **substantive** (as orchestration study) | Cleanest multi-agent example; explicitly "does not actually make any trades" | 2 & 3 |
| **OpenBB** `OpenBB-finance/OpenBB` | Open "Open Data Platform" data layer; SDK/CLI/API/Workspace; MCP + REST for agents | **70.8k★**, 6,863 commits, 7.2k forks, stable release Apr 25 2026 | **substantive** | Huge community + agent-friendly MCP/REST/Python; data layer, not execution | 1 & 4 |
| **agents-towards-production** `NirDiamant/agents-towards-production` | Code-first tutorials for production GenAI agents (RAG/eval/observability/deploy/security) | 21.1k★, 215 commits, 2.8k forks; **pushed 2026-07-14 (active)** | **substantive** (general, not trading) | Broad production coverage = the systems-engineer's bridge; "Educational use only", non-commercial license | 2 |
| **TradingAgents** (paper) arXiv:2412.20138 | Multi-agent LLM trading: analysts + bull/bear researcher debate + traders + risk team | v1 Dec 28 2024, v7 Jun 3 2025; preprint (oral @ "Multi-Agent AI in the Real World") | **substantive** (preprint) | Reference multi-agent architecture; returns claims need Alpha-Illusion/LdP lens | 3 |
| **FinAgent** (paper) arXiv:2402.18485 | Multimodal foundation agent for trading: tool-augmented, diversified, generalist | v1 Feb 28 2024, v3 Jun 28 2024; preprint | **substantive** (preprint) | Serious group (Bo An); multimodal+tools. ID verified via arXiv API (2402.03755 was QuantAgent) | 3 |
| **The Alpha Illusion** (paper) arXiv:2605.16895 | Argues reported LLM-agent alpha ≠ deployment evidence | May 16 2026; preprint (freshest item) | **substantive** (on-mission) | Academic spine of the FOMO-filter; `to-verify` after full read | 1 |
| **QuantAgent** (paper, adjacent) arXiv:2402.03755 | Self-improving LLM for mining trading signals; inner/outer feedback loop | Submitted Feb 6 2024; preprint | **substantive** (adjacent, preprint) | Interesting self-improvement loop; surfaced while verifying FinAgent | 3 |
| **fastmcp.me aggregator** `/Skills/Details/30/moon-dev-trading-agents` | Indexed-skill aggregator that mirrors the Moon Dev repo | Fetch failed (TLS cert error) both attempts → `to-verify` | **to-verify** | Indexes a Claude skill we already hold locally; adds no unique content | — |
| **Moon Dev `moon-dev-ai-agents`** (local Dec-2025 snapshot) | Experimental crypto system: 48+ agents, ModelFactory (6 LLMs), multi-exchange, risk-first loop, RBI backtest agent | Snapshot Dec-2025; **parent repo now 404** (deleted/privated, checked 2026-07-21); fork network alive — 2,381 forks, 33 pushed in 2026 (see sweep below) | **mixed** | Real orchestration patterns (ModelFactory, risk-first, RBI) BUT FOMO-branded, 50x-leverage degen flavor, no audited live record | 2 & 3 |

## Moon Dev's current repos (2026-07-21) — he moved on

The ai-agents monorepo is **terminal** (upstream 404; not among his 25 public repos). Moon Dev (`moondevonyt`) is active but has converged on **data layer + prediction markets**. Cloned to `~/Projects/trading-agents/repos/` (see [[repos]]); full note in [[Moon Dev — Current Work (2026)]].

| Resource | What it is | Currency | Verdict | Evidence (1 line) | Stage |
|---|---|---|---|---|---|
| **Hyperliquid-Data-Layer-API** `moondevonyt/Hyperliquid-Data-Layer-API` | Data layer: liquidations, positions, smart-money flow on Hyperliquid | **pushed 2026-07-20 (active)** | **substantive** | Successor to the `api.moondev.com` data moat ([[snapshot-survey]] §e); data, not prompts | 3 |
| **Polymarket bots** `moondevonyt/Polymarket-Trading-Bot-Examples-By-Moon-Dev` | Polymarket bot infra (`5_minute_bots/`); "nothing plug-and-play" | **pushed 2026-07-18 (active)** | **substantive** (pattern study) | Honest anti-FOMO framing; execution patterns, no audited live record | 3 |
| **Limitless bots** `moondevonyt/Limitless-Prediction-Market-Bots` | Limitless (Base prediction market) onboarding kit; no API key | pushed 2026-04-28 | **substantive** (onboarding) | Lowest-friction live-data playground; good stage-1 exercise | 1 |

**Fake leads ruled out (2026-07-21):** `ZaphyrRobin/moon-dev-ai-agents` = mislabeled `TauricResearch/TradingAgents` (different project) · `pliskiny/...-small` = stripped single-commit re-upload · `hungpixi/moondev-agent` = personal Ichimoku/MQL5 remix · `brenwhyte`/`eugeneleychenko` = genuine but top out Nov-27-2025, **older** than our snapshot.

## Fork recency sweep — `moon-dev-ai-agents` (2026-07-21)

**Parent repo `moondevonyt/moon-dev-ai-agents` is now 404** (deleted or privated — checked 2026-07-21; the owner's current public repos don't include it, the newest being `Hyperliquid-Data-Layer-API`, pushed 2026-07-20). The **fork network survives**: GitHub search finds **2,381 forks**, of which **33 have been pushed since 2026-01-01** — i.e. newer than our Dec-2025 snapshot.

**Method:** `search/repositories?q=moon-dev-ai-agents+in:name+fork:only+pushed:>=2026-01-01` (sorted by `pushed_at`), then per-fork `commits?per_page=1` to separate real commits from fork-sync noise — a fork's `pushed_at` can be recent even when its latest commit is old.

**Forks with genuine post-snapshot commits (signal):**

| Fork | Last commit | What changed | Read |
|---|---|---|---|
| `melFranklin-76/moon-dev-ai-agents` | 2026-07-20 | "Fix scanner returning 0 movers during the entry window" | **Most recent real dev** — bug fix to a scanner agent |
| `stoutmeister/moon-dev-ai-agents` | 2026-07-18 | "Add standalone skip-tracer-dialer project folder (#3)" | New sub-project |
| `chizee/moon-dev-ai-agents` | 2026-07-15 | "Add Pull app config for auto-sync with upstream" | Infra (auto-sync), not strategy |
| `florianleger/moon-dev-ai-agents` | 2026-06-26 | "Regime gate: compute before threshold so it replaces th…" | **Trading-logic change** (regime gating) — most on-mission |
| `ds1985damp-cmyk/moon-dev-ai-agents` | 2026-05-02 | Dependabot merge (#10) | Dependency maintenance only |
| `TonyFalcon555/moon-dev-ai-agents` | 2026-04-30 | "Harden monetization gateway defaults (#1)" | Config hardening |
| `r1q` ≡ `morningtrading/moon-dev-ai-agents` | 2026-02-28 | "docs: Add comprehensive Strategy Improvements section" | Docs only; the two share one commit (fork-of-fork) |

**Noise (recent `pushed_at`, latest commit predates our snapshot):** `Shamdon` (last commit 2025-10-31), `ssalihsrz` (2025-10-20) — recent pushes are branch/fork-sync, no new code.

**Verdict:** our Dec-2025 snapshot is **not** the latest word — a handful of forks carry real 2026 development, the most substantive being `florianleger` (regime-gate logic) and the most recent `melFranklin-76`. **None** show a maintained, audited live-trading record, and the methodological hole from [[snapshot-survey]] §(c) (no out-of-sample / walk-forward) is **not fixed** in any fork surveyed. Candidate follow-up: diff `florianleger` + `melFranklin-76` against our snapshot. No capital implications.

## Notes for future sweeps
- **Recency gap — RESOLVED (2026-07-21):** swept via GitHub API `pushed_at`. All five `to-verify` repos are active with July-2026 pushes: vectorbt 07-14 · backtesting.py 07-20 · Jesse 07-16 · NirDiamant 07-14 · Lean 07-20. Fork network swept by `pushed_at` — see section above.
- **Promote-before-Critic:** every **substantive** verdict gets a [Critic] pass before promotion ([[Moon Dev — Research Brief & Leads]] §3).
- **Paper claims:** run any reported Sharpe/return through the López de Prado overfitting guards + The Alpha Illusion framing before believing it.

## Critic Pass — adversarial review of the top-5 "substantive" verdicts (2026-07-21)

> [Critic] gate per the "Promote-before-Critic" note above. **Stance:** default to skepticism — try to refute each verdict's *load-bearing claim* before it is treated as trusted. **Method:** fetched primary sources (raw `LICENSE` files, official docs, raw README), not the repos' own marketing blurbs. Scope = first five `substantive` rows: freqtrade, LEAN, NautilusTrader, Hummingbot, Jesse.

**Headline:** none of the five is refuted as *real, active, well-engineered software* (clean negative on refutation) — but the verdicts rest on activity metrics + self-description, and three evidence lines overstate. **All survive; two with corrected evidence, one with a missing license fact added.**

| Resource | Load-bearing claim tested | Critic outcome | Evidence |
|---|---|---|---|
| **freqtrade** (+FreqAI) | "adaptive ML that self-trains to the market" | **SURVIVES — evidence corrected** | Official docs: FreqAI can "self-adapt to the market in a supervised manner" = *scheduled retraining on user-defined features/labels*, not autonomous edge discovery; the shipped example is "Not for production" / "It is not designed to be run in production"; **no edge is promised anywhere**. License = **GPL-3.0 (copyleft)** — absent from the table; matters for Stage-4 build-on-top (derivatives must stay GPL). |
| **LEAN** | "pro-caliber engine where paper strategies run" | **SURVIVES** (most defensible) | Backed by a real company/platform (QuantConnect), not just stars. Evidence is still activity-based; local operation is complex (C#-heavy — already flagged). No user-profitability evidence. |
| **NautilusTrader** | "research == live parity" | **SURVIVES — self-claim flagged** | Parity is the project's own claim, not independently verified here. v2-RC breaking changes (already flagged) = a real learning cost. |
| **Hummingbot** | "HFT crypto market-making" | **SURVIVES — label downgraded to branding** | Raw README frames HFT as a *mission* to "democratize high-frequency trading" — project branding, **not** verified latency-grade HFT. Language not stated in README (unverified). Treat "HFT" as marketing, not technical fact. |
| **Jesse** | "MIT" + "without look-ahead bias" | **SURVIVES — license verified, look-ahead untested** | `LICENSE` = **MIT confirmed** (no non-commercial clause). "Without look-ahead bias" is the repo's self-claim — **not independently tested**; label it aspiration until a backtest audit checks it. |

**Cross-cutting finding (the real Critic result): category error.** All five verdicts conflate *substantive-as-software* with *substantive-for-the-money-mission*. Every evidence line is (a) activity metrics (stars/commits/releases/pushes) or (b) the repo's self-description. **None is evidence that learning or using the tool produces risk-adjusted returns** — exactly the [[the-alpha-illusion]] confound. Correct reading: these are **infrastructure worth studying** (Stage 3→4), **not** validation of any [[ledger]] revenue hypothesis. "Substantive" must not be allowed to drift into "will make money."

**Disposition:** all five keep `substantive` for promotion purposes, **scoped to "real, active software worth learning as infrastructure."** No capital implication. Follow-ups: (1) add `GPL-3.0` to freqtrade's Currency cell; (2) audit Jesse's look-ahead claim with an actual backtest before trusting it; (3) apply this same Alpha-Illusion lens to the remaining `substantive` rows (FinGPT / FinRL / ai-hedge-fund / OpenBB / the papers) on a future Critic pass.
