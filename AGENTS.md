---
tags: [contract, agents, harness, z2-draft]
status: Z2 DRAFT — agent-authored 2026-09-02, human approves (CLAUDE.md stays supreme, Z4)
related:
  - "[[CLAUDE]]"
  - "https://github.com/fabiofalopes/vaultcraft (AGENTS.md protocol + 60-machinery)"
---

# AGENTS.md — Vault Operating Contract

> The harness-blend layer: how every agent session (cron swarm, OpenCode, Claude Code, Hermes) behaves inside this vault. Precedence: **CLAUDE.md (constitution) > this file > per-skill instructions.**

## 1. Every session writes back (vaultcraft: every-session-writes-back)

A session that produces nothing durable is a failed session. Minimum write-back:

1. **Artifact** in its canonical zone: knowledge → `wiki/` · outputs → `inbox/` · session digests → `journal/sessions/` · ops → `_harness/` · value → `wiki/value/`
2. **LOG line** (append-only, one line, dated, tagged)
3. **INDEX row** if a new note exists (one wikilink + one-line summary)
4. **MEMORY refresh** only via the builder lane (substrate guard)

## 2. Vault etiquette (mirror-safe)

- **Real files only.** Never symlink outside `.md` into the vault (breaks Dataview/Bases/watchers). Outside work = one hub row in [[Projects]].
- **Never edit:** `.obsidian/` (human), `_sync/state|STATUS.md` (scripts own), `_sync/pairs.conf` (stage a Z2 proposal instead), `LOG.md` history (append-only), `CLAUDE.md` (Z4).
- **mtimes are sacred:** no `touch`, no bulk rewrites that churn unmodified notes — the mirror and the Dashboard read mtime as truth.
- Obsidian-side surfaces (5-pin cockpit, Bases, Dataview) are the **human layer** — agents maintain the data, never the pins' content style.

## 3. Sync contract

- At session end, an agent may run `bash _sync/vault-sync.sh run` (GitHub layer) — nothing else in `_sync/`.
- `--resync` and pair changes are **human-only** (the Ordo resurrection rule).
- Agents write notes as if a mirror is watching: atomic saves, no partial files, frontmatter valid YAML.

## 4. The human surface (the sauce)

The human navigates ONLY through 5 pins: [[Dashboard]] · [[Map]] · [[Sessions]] · [[Value]] · [[Triage]] — plus [[Projects]] for outside code. If a session's work is invisible on those pins, the session failed UX, not just governance.

## 5. Roles

Cron roles (Scout/Scribe/Curator/Janitor/Smith/Quant/Steward/Critic) per [[Daily Cron Sessions — Swarm Harness Master Plan]]; harness incidents per [[FAILURE-MODES]]; the PRE-CHANGE CHECKLIST binds any `_harness/` script edit.
