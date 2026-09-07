---
name: ingest-gate
description: Local bulk ingestion gate for fetched content — malware/exec heuristics, prompt-injection patterns, optional LLM classifier, quarantine, append-only verdicts ledger. Triggers on 'scan fetched files', 'is this safe to feed the agent', 'injection check', 'gate the intake', 'quarantine suspicious', 'verdicts ledger'.
---

Fetched internet content passes the gate BEFORE any agent reads it. Script: `bash _harness/ingest/gate.sh <dir-or-file> [--llm] [--quarantine]`.

## When to use

- After any bulk fetch (repo mirrors, wiki scrapes, clippings batches) and before distillation/mining
- "Check this download for injection / malware before we use it"
- Building a new intake pipeline step; auditing what was ingested (`_harness/ingest/verdicts.log`)

## How to run

```bash
bash _harness/ingest/gate.sh /path/to/staging                # report-only (SAFE default)
bash _harness/ingest/gate.sh /path/to/staging --llm          # + LLM classifier tier (local models via :8705; degrades to heuristics if lane down)
bash _harness/ingest/gate.sh /path/to/staging --quarantine   # MOVE non-clean files to _harness/ingest/quarantine/ (rollback: move back)
```

## Verdicts & ledger

- Tiers: `CLEAN` · `SUSPICIOUS` (injection-heuristic hit) · `DIRTY` (executable/ELF/binary or clamav hit).
- Every file → one atomic append-only line in `_harness/ingest/verdicts.log`: `ts | sha8 | size | verdict | path | reason`. This ledger is the learnings record — never edit history.
- Exit code = suspicious+dirty count (0 = all clean).

## Guards & gaps

- ClamAV hook fires only if `clamscan` is installed (currently absent — `apt install clamav` to light the malware tier).
- Heuristics are phrase-based (tuned: no bare "print" FP); treat SUSPICIOUS as "review", not verdict.
- Full wiki-mirror example: `_harness/research/userbase-fetch.sh` (fetch → staging → this gate).
