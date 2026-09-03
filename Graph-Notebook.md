---
tags: [notebook, graph, lab, meta, dashboard]
date: 2026-09-03
cssclasses:
  - dashboard-dense
---

# Graph Notebook — Vault as Jupyter Lab

> Every block below is a **live cell** — edit a note, the table re-runs (like Jupyter). `dataview` = code cell, `base` embed = interactive table, `Map.canvas` = figure. Start at the picture, drill with the cells. See [[Map]] · [[Dashboard]] · [[INDEX]] · [[_meta/graph-groups-proposal|graph colors patch]].

## Figure — Curated Story Graph

> Drag nodes, it autosaves. Global Graph = truth, this Canvas = story. The 4 MOCs break the old mega-hub hairball.

![[Map.canvas]]

---

## 1 · Tag Galaxy — what vocabulary you actually use

*Where the vault's tag taxonomy clusters. Patch `showTags`+`colorGroups` in [[_meta/graph-groups-proposal]] to see these colors on the graph.*

```dataview
TABLE WITHOUT ID tag AS "Tag", length(rows) AS "Notes"
FROM ""
FLATTEN file.tags AS tag
GROUP BY tag
SORT length(rows) DESC
LIMIT 20
```

> Try on graph: filter `tag:#quant`, `tag:#research`, `tag:#harness` — watch the cloud separate.

## 2 · Hubs — what the graph *actually* centers on (proxy centrality)

*Most inlinked = gravity. If [[INDEX]]/`[[Map]]`/`[[Dashboard]]` dominate, the MOCs are working.*

```dataview
TABLE WITHOUT ID file.link AS "Hub", length(file.inlinks) AS "In", length(file.outlinks) AS "Out", file.folder AS "Folder"
FROM ""
SORT length(file.inlinks) DESC
LIMIT 15
```

> Local Graph: open [[MOC-trading]] → Local Graph depth 2 → hubs flip to domain.

## 3 · Orphan Garden — notes with no inlinks (link 3/week)

*Inbox transients + root one-offs live here. Garden into their MOC.*

```dataview
TABLE WITHOUT ID file.link AS "Orphan", file.folder AS "Folder", file.mtime AS "Modified"
FROM ""
WHERE length(file.inlinks) = 0
  AND file.name != "LOG.md"
  AND !contains(string(file.folder), "_sync")
  AND !contains(string(file.folder), ".obsidian")
SORT file.mtime DESC
LIMIT 20
```

**Interactive:** ![[_meta/graph-health.base#InboxTransient]]

## 4 · Stubs — weakly linked (<3 outlinks)

*Your next +2 links ritual. Stubs are graph darkness.*

```dataview
TABLE WITHOUT ID file.link AS "Stub", length(file.outlinks) AS "Out", file.folder AS "Folder", file.mtime AS "Modified"
FROM "wiki" OR "quant" OR "/"
WHERE length(file.outlinks) < 3
SORT length(file.outlinks) ASC
LIMIT 20
```

## 5 · Recent Heat — what's alive

*Live mirror of edits. Use Bases to sort by clicking headers.*

![[_meta/recent-edits.base#Latest]]

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "Folder", file.mtime AS "Modified"
FROM ""
WHERE file.name != "LOG.md" AND file.name != "Dashboard.md"
SORT file.mtime DESC
LIMIT 12
```

## 6 · Domain Lab — MOCs + Quant Canon

*Does the graph cluster into 4 communities yet?*

```dataview
TABLE WITHOUT ID file.link AS "MOC", file.tags AS "Tags", length(file.inlinks) AS "In"
FROM ""
WHERE contains(file.name, "MOC-") OR file.name = "CANON"
SORT length(file.inlinks) DESC
```

![[_meta/graph-health.base#MOCs]]

- Trading: [[MOC-trading]] · [[the-alpha-illusion]] · [[ktd-fin]]
- AI-ML: [[MOC-ai-ml]] · [[SEAL — Self-Adapting Language Models]] · [[Voyager — Open-Ended Embodied Agent]]
- Ledger: [[MOC-ledger]] · [[ledger]] · [[quant-pilot-01-RESULT]]
- Harness: [[MOC-harness]] · [[The Forge Harness — Runbook]] · [[FAILURE-MODES]]
- Canon: [[CANON|quant/CANON]] — Tier 1/2/3 master map

```dataview
TABLE WITHOUT ID file.link AS "Area", length(rows) AS "Notes"
FROM ""
GROUP BY file.folder
SORT length(rows) DESC
LIMIT 15
```

## 7 · Ledger Trail — ideas → evidence → KILL/PROMOTE

```dataview
TABLE WITHOUT ID file.link AS "Row", file.mtime AS "Modified", tags AS "Tags"
FROM "wiki/value"
SORT file.mtime DESC
LIMIT 20
```

![[_meta/recent-edits.base#WikiQuant]]

## 8 · Harness Pulse — is the swarm healthy?

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "_harness" OR "journal"
SORT file.mtime DESC
LIMIT 12
```

![[_meta/recent-edits.base#Harness]]

## 9 · Native Search Cells — try these in the note

*Paste into any note as ` ```query ``` ` — they're the graph's text twin:*

```query
path:wiki/research/trading/
```

```query
tag:#quant -path:inbox
```

```query
-path:_sync -path:.obsidian file:LOG
```

---

## How to use this like Jupyter

1. **Top → bottom**: Figure → Galaxy → Hubs → Garden. That's one sweep.
2. **Fork a cell**: copy a `dataview` block into a new note, change `FROM "wiki/value"` to `FROM "quant/strategies"` — new experiment.
3. **Garden weekly**: pick 3 Orphans → add `[[MOC-trading]]`/`[[MOC-ledger]]` etc + 2 related links. Watch the graph re-cluster next open.
4. **Color the graph**: apply [[_meta/graph-groups-proposal]] — then re-run Tag Galaxy and see colors match.
5. **Save filters as workspaces**: Global Graph search → `No-noise`: `-path:_sync/* -path:.obsidian/* -file:LOG.md -path:inbox/*` ; `Live-only`: `path:wiki/* OR path:quant/*`

> Want more cells? Duplicate **Stubs/Orphans** but swap `file.folder` or `tag`. Bases YAML is in `_meta/graph-health.base` and `_meta/recent-edits.base` — add a view there, embed it here with `![[path.base#View]]`.

## Related

- [[_meta/graph-health-queries.md|More health queries (Dataview)]] — hub/stub/unresolved cells
- [[_meta/graph-groups-proposal|ColorGroups staged patch]] — human applies
- [[Map]] · [[INDEX]] · [[Dashboard]] · [[Sessions]] · [[Value]] · [[Triage]]
