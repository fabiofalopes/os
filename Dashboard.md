---
cssclasses:
  - dashboard-dense
tags:
  - dashboard
  - meta
date: 2026-09-02
---

# Dashboard — Latest Edits

> No-scroll command center. Pin this note (`Ctrl/Cmd+P → Pin`), set as Homepage. Each table is capped (`LIMIT 10–20`) — click a link to jump, use the **Ba3ses** views below for sort/filter without scrolling.

![[_meta/recent-edits.base#Latest]]

## ⚡ Latest 15 — everything (LOG excluded, it always wins)

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.folder AS "Folder",
  file.mtime AS "Modified"
FROM ""
WHERE file.name != "LOG.md"
  AND file.name != "Dashboard.md"
SORT file.mtime DESC
LIMIT 15
```

## 📥 Inbox triage — newest 10

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.mtime AS "Modified"
FROM "inbox"
SORT file.mtime DESC
LIMIT 10
```

## 📚 Wiki + Quant — newest 10

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.folder AS "Folder",
  file.mtime AS "Modified"
FROM "wiki" OR "quant"
SORT file.mtime DESC
LIMIT 10
```

## 🔧 Harness + Journal + Root — newest 10

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.folder AS "Folder",
  file.mtime AS "Modified"
FROM "_harness" OR "journal" OR "/"
SORT file.mtime DESC
LIMIT 10
```

## 🔄 Sync status (mirror to GitHub + system folders)

- Engine: `_sync/` — [[_sync/README|docs]] · status: `_sync/STATUS.md` (inline fields below)
- Commands: `bash _sync/vault-sync.sh run` (GitHub) · `bash _sync/pairs-sync.sh run` (folder pairs)

```dataview
TABLE WITHOUT ID
  github_last_run AS "GitHub last run",
  github_result AS "Result",
  github_detail AS "Detail"
FROM "_sync"
WHERE file.name = "STATUS"
LIMIT 1
```

## 🗂 All views (sortable, no query language)

- [[_meta/recent-edits.base|Open full Bases dashboard]] — Latest / Inbox / Wiki+Quant / Harness views, click column header to sort, `LIMIT 20` each.
- To change what counts as "recent": open the `.base`, Filter → `file.mtime > now() - "1 week"`.

## Setup (one time, 5 min)

1. **Recent Edits plugin** (sidebar, grouped by Today/Yesterday — perfect for cron churn):
   Settings → Community plugins → Browse → `Recent Edits` → Install → Enable → ribbon History icon.
   Recommended settings: Lookback `7` days, Background folders: `inbox`, `journal`, Excluded: `.obsidian`, `.trash`. Externally-edited (agent) dot: on.
2. **Homepage plugin** (open this on startup):
   Browse → `Homepage` → Install → Enable → set Homepage value to `Dashboard.md` → enable Open on startup. Then right-click this tab → Pin.
3. **Dense CSS**: Settings → Appearance → CSS snippets → enable `dashboard-dense`.
4. **Dataview**: already installed (`0.5.68`). No JS needed for the queries above.
5. **Bases**: core plugin, already on. No install.

> Don't build a custom plugin — Dataview (frozen but stable) + native Bases + Recent Edits covers 100%. Custom only if you need task-level rollups or JS charts later.
