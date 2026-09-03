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
| agent-wealth | `/home/fabio/projects/agent-wealth` | — |
| Ata | `/home/fabio/projects/Ata` | — |
| tinygrad / tinygrad-bounty | `/home/fabio/projects/tinygrad*` | — |
| teamwork-ops | `/home/fabio/projects/teamwork-ops` | Vault: [[Tmux Agent Orchestration — Teamwork & Swarm-Deploy Skills]] |
| runpod-kit / llama.cpp | `/home/fabio/projects/runpod-kit`, `llama.cpp*` | Vault: [[Own-Instance GPU Harness — Deploy Playbook & Tight-Pack Doctrine]] |
| pi-glm / pi-spot-watch | `/home/fabio/projects/pi-glm`, `pi-spot-watch` | — |
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
