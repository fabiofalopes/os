---
tags: [meta, graph, health, queries]
date: 2026-09-03
---

# Graph health queries (Dataview — true orphans/stubs)

> Bases can't filter on inlinks yet. Use these Dataview blocks for the revealing work. Companion to [[_meta/graph-health.base]].

## Orphans (no inlinks, LOG excluded)

```dataview
TABLE WITHOUT ID
  file.link AS "Orphan",
  file.folder AS "Folder",
  file.mtime AS "Modified"
FROM ""
WHERE length(file.inlinks) = 0
  AND file.name != "LOG.md"
  AND !contains(file.folder, "_sync")
SORT file.mtime DESC
LIMIT 30
```

## Stubs (few outlinks — weakly linked)

```dataview
TABLE WITHOUT ID
  file.link AS "Stub",
  length(file.outlinks) AS "Out",
  file.folder AS "Folder"
FROM "wiki" OR "quant" OR "/"
WHERE length(file.outlinks) < 3
SORT length(file.outlinks) ASC
LIMIT 30
```

## Mega-hubs (most linked — watch INDEX/Map/Dashboard dominance)

```dataview
TABLE WITHOUT ID
  file.link AS "Hub",
  length(file.inlinks) AS "In"
FROM ""
SORT length(file.inlinks) DESC
LIMIT 15
```

## Unresolved (links to notes that don't exist)

```dataview
TABLE WITHOUT ID
  file.link AS "Source",
  filter(file.outlinks, (o) => !o) AS "Missing"
FROM ""
WHERE length(filter(file.outlinks, (o) => !o)) > 0
LIMIT 20
```

Ritual: weekly — link 3 orphans into their MOC (`[[MOC-trading]]`, `[[MOC-ai-ml]]`, `[[MOC-ledger]]`, `[[MOC-harness]]`), convert 1 stub with +2 links.
