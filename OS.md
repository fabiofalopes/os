---
cssclasses:
  - dashboard-dense
tags: [os, manifest, map, meta]
date: 2026-09-03
---

# OS — The machine, in one screen

> The `os` repo is this vault. This note is its manifest: **filesystem (ground truth) → vault (window) → agents (writers) → sync (convergence).** Files stay where the OS expects them; the vault documents and mirrors them. Edit this when the machine's shape changes.

## The model

| Layer | What it is | Where |
|---|---|---|
| **Filesystem** | real files, real paths, running software | `~/projects/`, `~/Documents/`, `~/.myscripts/`, `~/bin/` |
| **Vault (window)** | the human sees/reads/inputs here | this repo — 5 pins |
| **Agents (writers)** | cron swarm + OpenCode/Claude/Hermes write back in | `_harness/` + [[AGENTS]] |
| **Sync (convergence)** | makes the above one thing | `_sync/` (GitHub + Ordo pairs) |

## Filesystem map (discovered, keep current)

- `~/projects/` — real code: `trading-agents`, `forecast-scorer`, `agent-wealth` (mirrored, filtered), `tartarus`, `tinygrad*`, `upb`, `runpod-kit`, `wifi-defense-lab`, `sinte01-raylib`. Hub note: [[Projects]].
- `~/agent-knowledge/` (24M) — **EXCLUDED from repo**: saturated with live secrets (Groq/HF/LiteLLM/Coinbase/Lusófona keys in `.env` + notes). Pair OFF, dir purged, gitignored. Local knowledge stays at source.
- `~/breaking-claude/` — campaign (1.4G artifacts stay out); `vault/` subdir **MIRRORED** → `wiki/import/breaking-claude/`.
- `~/foundry/` — vaultcraft foundry instance, **MIRRORED** → `wiki/import/foundry/`.
- `~/shared-local/hub/notes/` — infra notes **MIRRORED** → `wiki/import/hub-notes/`.
- `~/Documents/` — Ordo MIRROR target (onedrive; needs `rclone config` — human). Not yet a vault pair.
- `~/obsidian-vault-orcrist/` — second vault. Open separately, never nest/symlink.
- `~/bin/`, `~/.myscripts/` — CLI tools, agent wrappers, `rclone` (installed 2026-09-03, no sudo).
- `~/research/claude-code-original/` — leaked-source reference (47M), hub row only. `~/campaigns/` — RETROSPECTIVE + cron.txt.
- Stray `~/ *.md` — imported to `Clippings/` 2026-09-03 (Cecil Taylor, Miles Davis, Quincy Jones).

## The window (5 pins, how to open)

1. [[Dashboard]] — what changed + sync status
2. [[Map]] — where everything is
3. [[Sessions]] — agents live: queue + digests
4. [[Value]] — money / ledger
5. [[Triage]] — capture/input landing strip

**Open posture:** Homepage = [[Dashboard]] · pin all 5 · left sidebar = Files (sort: *modified time*) / Search / Bookmarks · right = Terminal (pinned) / Backlinks / Outline / Tags · CSS snippet `dashboard-dense` on.

## Input / read / see (the human-agent loop)

- **Input (capture):** quick-capture into `inbox/` → shows in [[Triage]], agents pick it up or you triage it.
- **Read:** hover-preview any link; Backlinks + Outline panes give context without opening; excerpts inline in [[Triage]].
- **See:** [[Map]] (structure) · [[Dashboard]] (churn) · [[Sessions]] (agent activity) · this note (the machine).
- **Ask an agent:** the queue in [[Sessions]] is the agentic "input" channel — a job posted there is the same as talking to the swarm.

## Sync convergence (`_sync/`)

- GitHub: `bash _sync/vault-sync.sh run` — pull/commit/push (remote = `os`, pending `git remote add origin`).
- Pairs: `bash _sync/pairs-sync.sh run` — Ordo bisync, robust flags, `--resync` human-only.
- Status: `_sync/STATUS.md` (reads into [[Dashboard]]).

## Book ↔ OS

- Book: `fabiofalopes/vaultcraft` (theory). OS: this repo (the proof). Bridge: [[_meta/vaultcraft-map]] — every zone pinned to a vaultcraft section; `_meta/` is now the only home for "reorganizing" notes.

## Rules that keep it human

- Real files only in-vault; outside work = hub rows + mirror pairs, never symlinked `.md`.
- Agents write back ([[AGENTS]]): artifact + LOG + INDEX, never `.obsidian/`, never sync state.
- mtimes are truth; the Dashboard and the mirror both read them — no `touch`.
