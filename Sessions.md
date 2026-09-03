---
cssclasses:
  - dashboard-dense
tags: [dashboard, sessions, harness, meta]
date: 2026-09-02
---

# Sessions — Agentic ops in one screen

> Pin 3. Queue top + latest digests + harness health. No scrolling, no File Explorer hunting.

![[_meta/sessions.base#Latest]]

## ⏭ Queue head (open [[queue]] to claim)

```dataview
TASK
FROM "_harness/queue"
WHERE !completed
LIMIT 8
```

## 📝 Latest session digests (status inline = insides without opening)

```dataview
TABLE WITHOUT ID
  file.link AS "Session",
  status AS "Status",
  date AS "Date",
  file.mtime AS "Modified"
FROM "journal/sessions"
SORT file.mtime DESC
LIMIT 12
```

## 🚨 Harness health

- [[FAILURE-MODES]] — incident catalog + pre-change checklist (read before touching `runner.sh`/`worker.sh`)
- [[schedule]] — cadence
- [[The Forge Harness — Runbook]] — operate/observe/tune
- Latest cron verdict: [[cron-audit-and-disable-2026-08-03]] (all 5 jobs disabled 08-03 — engine paused, check before expecting new sessions)

## 📥 Latest inbox arrivals (agent output landing strip)

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  status AS "Status",
  file.mtime AS "Modified"
FROM "inbox"
SORT file.mtime DESC
LIMIT 8
```
