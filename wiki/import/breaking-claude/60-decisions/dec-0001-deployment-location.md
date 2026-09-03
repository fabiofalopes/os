---
id: DEC-0001
type: decision
date: 2026-08-26
context: "Master prompt names 'breaking-Claude repo' + 'vault' as separate items; disk had neither."
options: ["~/breaking-claude with vault/ inside (single root)", "vault inside Forge vault ~/obsidian-vault-kali", "separate repo + separate vault dir"]
decision: "Single root ~/breaking-claude containing repo layer (claims/archive/experiments/telemetry/briefs) + vault/ layer."
supersedes: null
status: active
summary: Mission state lives at ~/breaking-claude; Forge vault remains a sibling, linked not merged.
---
## Context
Master prompt treats repo and vault as two assets; neither existed. Forge
vault already has its own constitution, ledger, and cron engine — mixing
ledgers would violate its governance.
## Options considered
As above.
## Rationale
Single root = one AGENTS cascade, one git repo (init pending), matches spec
path names. Forge vault keeps human-facing broader research; canonical claim
IDs live only here.
