---
cssclasses:
  - dashboard-dense
tags: [dashboard, value, money, meta]
date: 2026-09-02
---

# Value — Money in one screen

> Pin 4. Ledger rows + closest-to-runway pilots. Human gates are the only unblock.

## Ledger (live source: [[ledger]])

| Row | Thesis | Gate / verdict |
|---|---|---|
| 1 | Forecasting / calibration | Verdict run ≥2026-09-02, one command |
| 2 | Tool/skill demand | Human GO/NO-GO at [[tool-pilot-01-publish-checklist]] — fastest path |
| 3 | Momentum factor | **KILLED** ([[quant-pilot-01-RESULT]]) — rung-0 baseline +1.377 |
| 4 | 8-K extraction | **KILLED** clean 08-01 ([[quant-pilot-02-RESULT]]) |
| 5 | Short-term reversal | Pre-reg [[quant-pilot-03]] — needs sign-off = only runway |

## Pilot notes, freshest first (status inline)

```dataview
TABLE WITHOUT ID
  file.link AS "Pilot",
  status AS "Status",
  date AS "Date",
  file.mtime AS "Modified"
FROM "wiki/value"
SORT file.mtime DESC
LIMIT 12
```

## Research that guards the money (no opening to triage)

```dataview
TABLE WITHOUT ID
  file.link AS "Note",
  file.folder AS "Area",
  file.mtime AS "Modified"
FROM "wiki/research"
SORT file.mtime DESC
LIMIT 8
```

> Rule: paper before live, human authorizes capital (Z4). Every session leaves an artifact or a clean negative.
