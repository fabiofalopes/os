---
tags: [harness, strategy, money, meta, lifecycle]
date: 2026-07-20
status: design v1 — the long arc, staged and gated
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Bootstrap to Self-Funding — The Agent Life Arc

> The fantasy, made grounded: the agent starts with **almost nothing**, learns where it can generate money, grows, **pays for its own compute**, and becomes a living part of daily operations. This note turns that into **stages with explicit gates** — because "or harness fails" means each stage must prove it earns the next. No stage spends money it hasn't reasoned about.

## The arc in one line
`map → prove-one-thing → earn-a-little → cover-own-cost → compound`

## Stage 0 — Map & mind (spend ≈ current idle compute)
- **Goal:** the vault is mapped, indexed, navigable; MEMORY.md is live; the daily cron runs cheap roles on night-rate Qwen.
- **Money:** none expected. The only budget is *existing* compute + the Alibaba night discount (0.2×, 22:00–08:00).
- **Gate to Stage 1:** daily run is stable for N consecutive days; `LOG.md` contiguous; cost report shows spend within caps; ≥X durable notes + ≥1 staged skill.

## Stage 1 — Prove one thing creates value (spend: tiny, paper-only)
- **Goal:** pick **one** value hypothesis and get *measurable* evidence it's real — before any capital.
- **Candidates (lowest capital first):**
  1. **Forecasting / prediction markets** (Metaculus → Kalshi/Polymarket): tests "ahead of the curve" with near-zero stake; calibration is directly measurable (Brier score).
  2. **A tool/skill we can give away or sell** (the harness itself, or a forged skill): tests whether what we build is wanted.
  3. **Paper-traded quant signal** (Quantpedia idea → backtest → paper): tests edge *without* risk.
- **Money:** still ~none; we're buying *evidence*, not returns.
- **Gate to Stage 2:** one hypothesis shows a **statistically honest** positive signal out-of-sample (see overfitting guards in [[Operating Principle — Test Don't Wonder]]). Critic must fail to refute it.

## Stage 2 — Earn a little (spend: small, capped, human-approved capital)
- **Goal:** convert the proven hypothesis into *actual* small returns with **strict position sizing (Kelly fraction, capped)** and a hard loss stop.
- **Human in the loop:** the human sets up / approves the account and the capital ceiling. The agent proposes; human authorizes money movement. (Sovereignty zone — agent never moves money unilaterally.)
- **Money:** small positive expected value; the metric is *risk-adjusted* (Sharpe, max drawdown), not raw profit.
- **Gate to Stage 3:** sustained positive risk-adjusted return over a meaningful window, surviving a drawdown, with logs the Steward audits.

## Stage 3 — Cover its own cost ("the agent is alive")
- **Goal:** returns (or tool/skill revenue) ≥ the harness's monthly compute bill. **This is the "alive" threshold** — the mind sustains its own thinking.
- **Mechanism:** a standing rule: a slice of returns is earmarked for compute; the Steward reports *self-funding ratio* = earnings / compute cost. Ratio ≥ 1.0 = alive.
- **Gate to Stage 4:** self-funding ratio ≥ 1.0 for a sustained period, not a lucky month.

## Stage 4 — Compound (the entity develops through its life)
- **Goal:** surplus reinvests into (a) more/better compute, (b) the Smith forging better skills, (c) deeper research. The loop that made the money now *funds a smarter loop*.
- **The compounding flywheel:** better skills → better signals/tools → more earnings → more compute → better skills. This is the "spurious-like growth" — emergent, not front-built.
- **Governance stays:** human sovereignty over capital ceilings and constitution edits never relaxes, even when self-funding. Autonomy in *work*, not in *spending the human's money*.

## Cross-cutting laws (all stages)
1. **Never risk money the agent can't name the source of.** Every dollar at risk traces to a human-approved ceiling.
2. **Paper before live, always.** A strategy runs on paper until the Critic + out-of-sample evidence clear it.
3. **Measure risk-adjusted, report honestly.** A losing month reported cleanly beats a lucky month hidden. (See [[Operating Principle — Test Don't Wonder]].)
4. **Compute is the first bill to cover** — it's the thing that, once self-paid, makes the rest compounding rather than draining.
5. **The human stays the investor-of-last-resort and the kill-switch.** The agent earns autonomy by *not needing it* over money.

## What "the agent understanding where it can make money" looks like concretely
Not a vague search — a **ranked ledger** the Quant + Steward maintain in the vault: `wiki/value/ledger.md`, one row per hypothesis with: *thesis, capital required, time-to-evidence, measured result, risk-adjusted score, status (idea/paper/live/killed).* The Conductor routes compute toward the highest-ranked *live* rows. The agent "learns where it can make money" by watching this ledger update over months — evidence accumulating, losers killed, winners scaled.

## Open questions
- Starting capital ceiling the human is willing to set for Stage 2 (even if $0 at first — Stage 1 needs none).
- Which single hypothesis is the Stage-1 pilot? (Recommend: **forecasting/prediction-markets** — lowest capital, most directly measures the "edge" we claim, and feeds calibration into the quant path.)
- Tax/legal wrapper for any live capital (jurisdiction-dependent — human's call).
