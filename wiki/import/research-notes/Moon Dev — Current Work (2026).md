---
tags: [project, trading, moon-dev, research, prediction-markets, hyperliquid]
date: 2026-07-21
status: snapshot captured — current active repos cloned outside vault
related:
  - "[[Moon Dev — Research Brief & Leads]]"
  - "[[snapshot-survey]]"
  - "[[legitimacy-ledger]]"
  - "[[repos]]"
---

# Moon Dev — Current Work (2026)

> **The question:** is there a *newer* snapshot of `moon-dev-ai-agents` than our Dec-2025 copy? **Answer: no — that repo is terminal.** Moon Dev deleted/privated it (404; not among his 25 current public repos) and **moved on**. The "more recent Moon Dev" is not a newer ai-agents snapshot — it's his *current* projects, which are newer **and** closer to the money-vertical. Those are cloned to `~/Projects/trading-agents/repos/` (see [[repos]] for paths — **no code lives in the vault**).

## 1. The ai-agents repo is abandoned — confirmed

- `github.com/moondevonyt/moon-dev-ai-agents` → **404**. Not in his account under any name (checked all 25 public repos, 2026-07-21).
- Our Dec-2025 snapshot ([[snapshot-survey]]) already contains the terminal upstream content (the last genuine upstream commits top out ~Nov 27 2025, "polymarket agent with websearch" — which we have).
- **Genuine newer dev survives only in forks**, already swept in [[legitimacy-ledger]] §"Fork recency sweep": `melFranklin-76` (most recent, 2026-07-20, scanner bug-fix) and `florianleger` (most on-mission, 2026-06-26, **regime-gate logic**). None fix the no-out-of-sample hole from [[snapshot-survey]] §(c).
- The "recent" third-party repos are all fake leads: `ZaphyrRobin/moon-dev-ai-agents` is a **mislabeled** `TauricResearch/TradingAgents` (different project); `pliskiny/...-small` is a stripped single-commit re-upload; `hungpixi/moondev-agent` is one dev's Ichimoku/MQL5 remix.

## 2. What Moon Dev is actually building now (cloned 2026-07-21)

All under `github.com/moondevonyt/`, cloned to `~/Projects/trading-agents/repos/`. Paths in [[repos]].

| Repo | Last push | What it is | Why it matters to us |
|---|---|---|---|
| **Hyperliquid-Data-Layer-API** | **2026-07-20** | Data layer exposing liquidations, positions, smart-money flow on Hyperliquid ("the rigged game ends here"). `api.py`, `api_monitor.py`, `ai_agents/`, `examples/`. | **Direct successor to the `api.moondev.com` data moat** flagged as the real differentiator in [[snapshot-survey]] §(e). He's doubling down on *data*, not prompts. Highest-signal for the money-vertical. |
| **Polymarket-Trading-Bot-Examples-By-Moon-Dev** | **2026-07-18** | Open-source Polymarket bot infra, built live on YT. `5_minute_bots/`. Explicitly "**nothing plug-and-play**." | Prediction-market execution patterns; honest framing (anti-FOMO). Study for structure, not returns. |
| **Limitless-Prediction-Market-Bots** | 2026-04-28 | Onboarding kit for **Limitless** (prediction market on Base). Two ready-to-run tools, live data in <5 min, **no API key**. | Lowest-friction live-data playground. Good first "see data flow" exercise ([[learning-path]] stage 1). |

**Read of the trajectory:** Moon Dev abandoned the 48-agent zoo and converged on **(a) the data layer** (Hyperliquid) and **(b) prediction markets** (Polymarket, Limitless). This matches [[snapshot-survey]]'s verdict that the *data backbone* — not the LLM prompts — was the moat. The FOMO branding is toned down ("nothing plug-and-play", "not financial advice").

## 3. Verdict (for [[legitimacy-ledger]])

- **Hyperliquid-Data-Layer-API** → `substantive` (data infra, active, on-mission). Study the API shape; it's the continuation of the moat.
- **Polymarket / Limitless bots** → `substantive` (as execution-pattern study). No audited live record; paper/study only ([[Bootstrap to Self-Funding — The Agent Life Arc]]).
- Same standing rules apply: no capital, filter FOMO, judge code not personality, backtest claims get the López de Prado / Alpha-Illusion lens.

## 4. Next (optional, bounded)
- Diff `florianleger` (regime-gate) + `melFranklin-76` forks against our snapshot — the only genuine ai-agents deltas worth reading.
- Read `Hyperliquid-Data-Layer-API/api.py` for the data schema — the sharpest current artifact.
- Do **not** re-snapshot the ai-agents monorepo; it's terminal.
