---
cssclasses:
  - dashboard-dense
tags: [dashboard, triage, inbox, meta]
date: 2026-09-02
---

# Triage — Inbox insides, no opening

> Pin 5. Status/tags/date inline = triage without opening 60+ files. Bodies via hover preview or the excerpt block at the bottom.

![[_meta/triage.base#Needs-review]]

## Needs review (newest 15, insides showing)

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  status AS "Status",
  date AS "Date",
  join(tags, ", ") AS "Tags",
  file.mtime AS "Modified"
FROM "inbox"
SORT file.mtime DESC
LIMIT 15
```

## By tag (where to route)

```dataview
TABLE WITHOUT ID
  key AS "Tag",
  length(rows) AS "Count"
FROM "inbox"
WHERE tags
FLATTEN tags AS key
GROUP BY key
SORT length(rows) DESC
LIMIT 12
```

## Body excerpts (first ~200 chars, no opening) — needs Dataview JS on

> Settings → Community plugins → Dataview → enable **JavaScript Queries**. If off, everything above still works; only this block needs it.

```dataviewjs
const pages = dv.pages('"inbox"').sort(p => p.file.mtime, 'desc').limit(8);
for (const p of pages) {
  let raw = "";
  try { raw = await dv.io.load(p.file.path); } catch (e) { raw = ""; }
  const body = raw.replace(/^---[\s\S]*?---/, "").replace(/\s+/g, " ").trim().slice(0, 200);
  dv.paragraph(`**${p.file.link}** — _${p.status ?? ""}_ · ${body}…`);
}
```

## Process

1. Skim Status/Tags above → open 1–3 that matter (hover preview first).
2. Promote: move to `wiki/` + link from [[INDEX]] · or stage as queue job.
3. Kill: delete or leave — `LIMIT 15` keeps this screen scroll-free either way.
