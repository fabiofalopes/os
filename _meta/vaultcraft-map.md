---
cssclasses:
  - dashboard-dense
tags: [meta, vaultcraft, map, os, machinery, z2]
date: 2026-09-03
status: Z2 — bridge note, agent-drafted
related:
  - "[[OS]]"
  - "[[AGENTS]]"
  - "[[_sync/README]]"
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "https://github.com/fabiofalopes/vaultcraft"
---

# Vaultcraft Map — Book ↔ OS Bridge

> The "gimmick" made explicit. **vaultcraft is the book** (theory, 13 principles, methods). **`os` is the harness** (machinery, live) — foundry status gated on naming an artifact contract + verify command (FOUNDRY-SPEC v1.0.1 §3). Reclassified 2026-09-10 · human gate: ☑ ratified (burst "continue", veto-by-number protocol). This note pins every current zone to a vaultcraft section so "reorganizing" stops polluting content and the machinery layer becomes findable canon.

## The spine (8 sections, from `vaultcraft` Sep 1)

| # | Section | What lives there |
|---|---|---|
| 00 | manifest | front door, DECISIONS log (decision + why), SOURCES provenance |
| 10 | principles | P1–P13 invariants (every-session-writes-back, taste-must-be-executable, etc.) |
| 20 | foundations | vault-as-proto-ontology, two-vaults-two-purposes, harness-equation, graphs-with-traces |
| 30 | methods | organize / curate / pipelines / learn |
| 40 | playbooks | found-a-foundry, run-a-skill-foundry, gap-analysis |
| 50 | skills | skill-authoring canon + templates |
| 60 | machinery | **executable layer** — AGENTS.md protocol, per-harness adapters, hooks, MCP servers, bridges |
| 90 | sessions | write-back log — one record per working session |

## Where `os` lives now

| Current zone in `os` | Vaultcraft home | Role |
|---|---|---|
| `[[OS]]` + `[[Map]]` | 00-manifest | **this machine's front door** (filesystem → vault → agents → sync) |
| `[[AGENTS]]` | 60-machinery + 10-principles (P: every-session-writes-back) | operating contract — precedence `CLAUDE.md > AGENTS.md > skills` |
| `_harness/` | 60-machinery | cron swarm (runner/worker/council), health, FAILURE-MODES catalog |
| `_sync/` | 60-machinery | mirror engine: GitHub layer + Ordo bisync pairs (anti-resurrection flags) |
| `_meta/` (this folder) | 30-methods + 00-manifest | **meta layer — "reorganizing" notes live here, not in wiki/** |
| `wiki/concepts/`, `wiki/research/` | 20-foundations + 30-methods | knowledge — distilled, linked, not raw |
| `wiki/value/` + `[[ledger]]` | 40-playbooks (the money foundry) | value hypotheses, pilots, verdicts |
| `journal/sessions/` | 90-sessions | session digests — the agentic trace log |
| `inbox/` | 30-methods (capture) | raw input landing strip → triaged via [[Triage]] |
| `.forge/skills/` + `~/.config/opencode/skills/` | 50-skills | skill foundry — forged, harvested, curated |
| `~/shared-local/hub/` + `~/projects/` | outside `os`, hub rows in [[Projects]] | real code stays on disk; vault mirrors it |

## The distinction you named

**"Reorganizing" notes = the book/methods layer.** They answer *how we run the thing* (structure, contracts, sync rules, pin design). Home: `_meta/` + `[[OS]]`/`[[AGENTS]]` + this map.

**Content notes = the foundry's artifacts.** They answer *what we know/built* (research, pilots, value). Home: `wiki/` + `__harness` incidents catalogued, not theory.

If a note is about *how the vault should look* → `_meta/`. If it's about *what the vault knows* → `wiki/`.

## The alpha (why it's been hard to find)

The alpha was never a single file — it's the **integration contract** that makes human (5 pins) + agents (swarm) + filesystem (projects/Documents) + git (repo) + graph (backlinks/Dataview/Bases) behave as one system.

Previously scattered across `_harness/config.env`, `_sync/pairs.conf`, `~/.ssh/config`, `~/.myscripts/`, `agent-knowledge/`, session digests, and the vaultcraft repo itself. Now pinned here:

- **60-machinery lives canonically in `_harness/` + `_sync/`** — per-harness adapters (OpenCode/Claude Code/Hermes), hooks (`vault-sync.sh`, `pairs-sync.sh`), and the AGENTS.md protocol. Before this map they were "config" — now they're canon.
- **Reproducible "servers that we can repo"** — `server-inventory`, `proxmox-*`, `fortigate-*`, `z800-*`, `pop-cluster-*` skills are not notes, they're *state the harness knows*. Next step of 60-machinery is to capture their inventory/config as repo'd artifacts so `clone os → working` isn't re-discovery.

## Next (one move at a time, Z2)

1. Keep `_meta/` as the only home for "reorganizing" proposals — don't let meta leak into `wiki/`.
2. When 60-machinery grows (new adapter/hook/MCP), add one row here + one sentence in [[OS]].
3. Vaultcraft book stays upstream (`fabiofalopes/vaultcraft`); this map is the only coupling point — the book never imports `os` internals.

## DECISIONS

- **2026-09-10 — `os` reclassified first-foundry → harness, pending contract.** WHY: gap-table audit (foundry-lock session): `os` runs cron/swarm/sync machinery but declares no runtime command, no artifact contract, no verify command — the three executables FOUNDRY-SPEC §3 requires of any foundry. The book's claim must match the measured table; upgrading by wording would be grade inflation. Reversibility: high — declare the three contracts and re-run classification (would then likely classify runtime or skeleton on merit). Upgrade paths: (a) name `os`'s artifact + verifying command; (b) spin `wiki/value/` + ledger out as `value-foundry` with its own contracts, `os` as its harness. Gate: ☑ ratified 2026-09-10 (veto-by-number, no veto).
