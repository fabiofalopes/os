---
cssclasses:
  - dashboard-dense
tags: [dashboard, map, meta]
date: 2026-09-02
---

# Map — Vault in one screen

> Pin 2. Every area in 5 jumps max. Counts are live (Dataview), summaries are one line. Details live in [[INDEX]] — this is the fast layer.

## 5-pin cockpit

1. [[Dashboard]] — what just changed
2. **Map** (here) — where everything is
3. [[Sessions]] — agentic sessions + queue
4. [[Value]] — money / ledger
5. [[Triage]] — inbox with insides showing

## Areas

```dataview
TABLE WITHOUT ID
  link(key) AS "Area",
  length(rows) AS "Notes"
FROM ""
WHERE file.name != "LOG.md"
GROUP BY file.folder
SORT length(rows) DESC
LIMIT 15
```

## Jump table

- **This machine:** [[OS]] — the manifest (filesystem → vault → agents → sync)
- **Knowledge:** [[Sources — Curated Seed Library]] · [[the-forge-synthesis]] · [[Operating Principle — Test Don't Wonder]]
- **Quant:** [[ledger]] · [[quant-pilot-03]] · `quant/` folder
- **Harness:** [[The Forge Harness — Runbook]] · [[queue]] · [[schedule]] · [[FAILURE-MODES]]
- **Infra:** [[Universal Provider Bridge — Project Master Map]] · [[Claude Code Routes — upb CLI Decision & Runbook]] · [[Hermes Agent — Full System Capability Map]]
- **Ops:** [[MEMORY]] · [[LOG]] · [[_ORACLE]] · [[_ORACLE-CURATED]]
- **Projects (outside vault, no symlinks):** [[Projects]] — hub rows with paths + entrypoints
- **Mirror & sync:** [[_sync/README]] — GitHub layer + Ordo-style folder pairs + [[AGENTS|agent contract]]
- **Method (book ↔ os):** [[_meta/vaultcraft-map]] — where every zone lives in vaultcraft's spine
- **History:** [[forensic-timeline]] · [[project-map]] · [[opencode-sessions]]

## Fresh per area (no opening)

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.folder AS "Area",
  file.mtime AS "Modified"
FROM "wiki" OR "quant" OR "_harness" OR "journal"
WHERE file.name != "LOG.md"
SORT file.mtime DESC
LIMIT 12
```
