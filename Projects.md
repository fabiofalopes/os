---
cssclasses:
  - dashboard-dense
tags: [dashboard, projects, map, meta]
date: 2026-09-02
---

# Projects — Outside code, vault-side hubs

> Rule: **vault stays markdown-only, no symlinked `.md`.** Obsidian/Dataview/Bases assume real files in-vault — symlinks break indexing, `file.mtime` sort, watchers, mobile, and git. Outside work lives at its path; the vault holds one hub row per project (path + entrypoint + status). Linked from [[Map]].

## Live code (open in terminal, not in vault)

| Project | Path | Entrypoint / note |
|---|---|---|
| trading-agents | `/home/fabio/projects/trading-agents` | Quant pilots + `forecast-scorer/`; vault: [[ledger]], [[Value]] |
| forecast-scorer | `/home/fabio/projects/forecast-scorer` | Row-1 verdict command `run_verdict.sh` |
| agent-wealth | `/home/fabio/projects/agent-wealth` | **MIRRORED** (filtered, no agentkit) → `wiki/import/agent-wealth/` — REVENUE-IDEAS, STRATEGIES, ROADMAP live in vault |
| tartarus | `/home/fabio/projects/tartarus` | TUI project — DESIGN.md, RESUME.md, HANDOFF-* live with code |
| tinygrad-bounty | `/home/fabio/projects/tinygrad-bounty` | Campaign: START-HERE, GOALS, PROGRESS, ORCHESTRATOR-STATE |
| upb | `/home/fabio/projects/upb` | The routing proxy — vault: [[Claude Code Routes — upb CLI Decision & Runbook]], [[Universal Provider Bridge — Project Master Map]] |
| runpod-kit | `/home/fabio/projects/runpod-kit` | GPU pod toolkit — runpod-playbook.md with code |
| wifi-defense-lab | `/home/fabio/projects/wifi-defense-lab` | Wireless research — vault: [[Wireless Pentesting Infrastructure — Kali RPi]] |
| sinte01-raylib | `/home/fabio/sinte01-raylib` | Raylib synth — DESIGN.md, HANDOFF.md, NEXT_PROMPT.md |
| mcp-servers | `/home/fabio/mcp-servers` | simple-searxng |
| research | `/home/fabio/research/claude-code-original` | Leaked-source reference material (47M) — see [[Breaking Claude — The Landscape 2026 (Research Synthesis)]] |
| campaigns | `/home/fabio/campaigns` | RETROSPECTIVE.md + cron.txt |
| breaking-claude (vault) | `/home/fabio/breaking-claude/vault` | **MIRRORED** → `wiki/import/breaking-claude/` (1M; the 1.4G artifacts stay out) |
| agent-knowledge | `/home/fabio/agent-knowledge` | **EXCLUDED from repo** — tree saturated with live secrets (Groq/HF/LiteLLM/Coinbase/Lusófona). Pair OFF; never sync infra-config folders without a secret audit. |
| foundry | `/home/fabio/foundry` | **MIRRORED** → `wiki/import/foundry/` — vaultcraft foundry instance (00-manifest DECISIONS, 10-canon, 90-sessions) |
| tidal | `/home/fabio/tidal` | **TidalCycles foundry** — constitution (rubric ≥6/8, seeds immutable, provenance), 23 seeds, 7 concept hubs, `knowledge/repo-map.md` = 30-repo mining index (⬜ open: vroomvroom deep study, looper eval, JP 100-one-liners batch, Tier 2/3). Canonical home of `~/.config/nvim/knowledge` (symlink). Headless rig per `[[FOUNDRY]]` there. |
| hub notes | `/home/fabio/shared-local/hub/notes` | **MIRRORED** → `wiki/import/hub-notes/` — provider-bridge-architecture, modelos-endpoint, upb fixes |
| tartarus | `/home/fabio/projects/tartarus` | Fork of opencode (branch `2.0`), binary `~/.local/bin/tartarus` v0.0.0-2.0-202609030411 |

## ✅ Formerly-missing notes — HEALED via live mirror (2026-09-03)

The 6 dead links above now resolve: the notes had **moved** to `~/projects/trading-agents-research-notes/` — which is now a live two-way mirror pair (`research-notes` in `_sync/pairs.conf`) into `wiki/import/research-notes/`. [[learning-path]] · [[legitimacy-ledger]] · [[curriculum-draft]] · [[snapshot-survey]] · [[Moon Dev — Research Brief & Leads]] all resolve again. Edits on either side sync (bisync, anti-resurrection flags, 20-delete fuse); `projects/README.md` remains gone, superseded by this hub.

## Nearby but NOT vault notes (do not symlink in)

- `/home/fabio/cecil-taylor-unit-structures.md`, `miles-davis-kind-of-blue.md`, `quincy-jones-walking-in-space.md` — stray home-dir notes. Import a copy into the vault if you want them queryable, don’t link.
- `/home/fabio/obsidian-vault-orcrist/` — whole second vault. Open as a separate vault, never nest/symlink vaults inside each other.
- `/home/fabio/shared-local/{hub,skills,reports,ledger}` — skills/reports store. Reference by path from hub rows, same as above.

## Pattern for new work

1. Code/outside → stays outside at `/home/fabio/projects/<name>`.
2. Vault gets **one row here** (path + entrypoint + status) and, if it’s knowledge, one atomic note in `wiki/` linked from [[INDEX]].
3. Never `ln -s` an outside `.md` into the vault. If a note must be queryable (Dataview/Bases/graph/backlinks), it must be a real file in-vault.
