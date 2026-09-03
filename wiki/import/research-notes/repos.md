---
tags: [project, trading, reference, code-locations]
date: 2026-07-21
status: living index — update when code is added/moved
related:
  - "[[Moon Dev — Current Work (2026)]]"
  - "[[snapshot-survey]]"
  - "[[Moon Dev — Research Brief & Leads]]"
---

# Code Locations (outside the vault)

> **Rule:** the vault is markdown-only knowledge. **All code lives in `~/Projects/`**, never under `~/obsidian-vault-kali/`. This note is the index from vault knowledge to the code it refers to. (The vault `.gitignore` excludes `projects/trading-agents/repos/` precisely so no code is tracked here.)

## Trading agents — `~/Projects/trading-agents/repos/`

| Folder | Source | Captured | What it is | Vault knowledge |
|---|---|---|---|---|
| `moon-dev-ai-agents/` | Software Heritage, Dec-2025 snapshot (upstream now 404) | 2026-07-21 (relocated out of vault) | The 48+ agent monorepo — **terminal** upstream. 270 MB, mostly `src/data/` noise; signal is `src/agents/`, `src/models/`, `src/strategies/`. | [[snapshot-survey]] |
| `Hyperliquid-Data-Layer-API/` | `github.com/moondevonyt/Hyperliquid-Data-Layer-API` | 2026-07-21 | Moon Dev's **current** data layer (liquidations/positions/smart-money). Active. | [[Moon Dev — Current Work (2026)]] |
| `Polymarket-Trading-Bot-Examples-By-Moon-Dev/` | `github.com/moondevonyt/...` | 2026-07-21 | Polymarket bot infra (`5_minute_bots/`). | [[Moon Dev — Current Work (2026)]] |
| `Limitless-Prediction-Market-Bots/` | `github.com/moondevonyt/...` | 2026-07-21 | Limitless (Base prediction market) onboarding kit. | [[Moon Dev — Current Work (2026)]] |

## Conventions
- Clone/pull code into `~/Projects/<campaign>/repos/`, then add a row here + a knowledge note in the vault.
- Never `git clone` into the vault. If a snapshot is large, it's reproducible from source — don't track it.
- To re-pull the terminal ai-agents snapshot: Software Heritage origin `https://github.com/moondevonyt/moon-dev-ai-agents` (see [[Moon Dev — Research Brief & Leads]] §1).
