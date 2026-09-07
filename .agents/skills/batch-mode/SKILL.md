---
name: batch-mode
description: Multi-repo batch runs for the foundry — give N repos (or corpora) + a purpose, get a per-repo state machine and ONE clean view of when/where to intervene; human gates recorded as append-only behavioral traces. Triggers on 'batch', 'process these repos', 'repo-map at scale', '100 repositories', 'where do I intervene', 'batch status'.
---

The repo-map pattern at scale. Script: `bash _harness/batch/batch.sh <verb>`. Per-batch files live in `journal/batch/<id>/`: `manifest.md` (state table) + `trace.md` (append-only record agents learn from).

## When to use

- Ingesting a researched corpus of repos/sources with one intent ("mine patterns from these 30 repos")
- Tracking multi-step validation pipelines where the human needs the ⚠️ INTERVENE view
- Recording human gate decisions so future runs inherit preferences (recipes/methods emerge from traces)

## Verbs

```bash
bash _harness/batch/batch.sh new <id> --purpose "…" --repos "a/b,c/d,…"
bash _harness/batch/batch.sh set <id> <repo> <STATE> ["note"]     # QUEUED FETCHED GATED TRIAGED STAGED MINING DONE BLOCKED DIRTY
bash _harness/batch/batch.sh gate <id> <repo> <ok|dirty> --why "…"  # HUMAN decision → behavioral trace
bash _harness/batch/batch.sh stage <id> [k]                        # emit k [Scout] triage jobs into the queue (fetch→gate→alpha verdict)
bash _harness/batch/batch.sh status [id]                           # default: latest batch
```

## Reading `status`

Progress bar + grouped states. **⚠️ INTERVENE (BLOCKED/DIRTY)** = your entire decision list; everything else advances via the queue. `trace lines / human gates` at the bottom = the behavioral record.

## Guards

- Work-units as rows (corpus chunks, not every page) — keep the manifest human-readable.
- `stage` writes real queue jobs (they run when the swarm is armed + gateway green).
- Current live batches: `graph-stack-patterns`, `userbase-preserve`.
