---
tags: [concept, handoff, swarm, multi-vault, dataset, foundry, design]
date: 2026-09-06
status: HANDOFF v1 — engine adaptation contract + pickup list
related:
  - "[[agentic-graph-brain]]"
  - "[[foundry-pattern]]"
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[multi-agent-orchestration-patterns]]"
---

# Multi-Vault Agentic Workloads — Handoff

> The handoff for "agentic workloads inside vaults that each have their own contents." Written the day the tidal foundry got its first orchestrated solo run (prompted from this session to tmux `0:3.3`, 2026-09-06). Vaultcraft is experimental; this note is the current best answer to "how does one engine serve many vaults without redesign."

## 1 · The fleet (contents differ, contract doesn't)

| Vault | Role | Contents | Native discipline |
|---|---|---|---|
| `obsidian-vault-kali` | **the brain** — harness, memory, orchestration | wiki, queue, LOG, harness scripts, graph | roles + Critic gates + kill criteria |
| `~/tidal` | **music foundry** | seeds, concept hubs, repo-map, rubric | constitution: rubric ≥6/8, seeds immutable, provenance |
| `~/foundry` | **vaultcraft instance** (experimental) | 00-manifest DECISIONS, 10-canon, 90-sessions | the 00–90 spine |
| `breaking-claude/vault`, mirrors | reference corpora | imports | read-mostly, filtered sync |

**The adaptation invariant:** each vault's *contents* are its own; what transfers is the **contract** — constitution-first (hard rules at the door) · append-only ledgers · receipts for every claim · kill criteria on every loop · human gates on the irreversible. An engine that reads the constitution before touching contents adapts to any vault in the fleet. That's why the engine "always needs to adapt" is a non-issue: it adapts to the contract, never to the content.

## 2 · Dataset compilation — the layer before workloads scale

Every agentic workload consumes **datasets, not trees**. Per-vault, one atomic, append-only, machine-parseable ledger:

- `~/tidal` → results ledger rows `{id · source · seed · rubric · ports · date}` (contract issued with the solo run)
- this vault → `LOG.md` (PRODUCED lines) + `journal/graph/edges.json` + queue check-offs
- mirrors → sync pairs + git history

Rule: **miners write ledgers; curators read ledgers.** Publication downstream = curation over ledger rows (rubric/filter/Critic), never re-mining. This is what "compile the datasets first" means operationally.

## 3 · The loop we are actually running

```
foundry runs (look · find · distill)
   → results land in ledgers
      → collect (ledgers = the sampler)
         → curate (rubric / Critic / human gates)
            → publish (INDEX · MOCs · canon · external)
               → sampler grows → engine tuning from evidence (Steward meta-reviews)
```

Colony behavior is irrelevant to correctness because each loop step has its own falsifier: seeds die on rubric, queue jobs die on no-PRODUCED-line, roles die on kill criteria (Cartographer: 2 cycles 0 applied). **More science than speculation** = every threshold in this fleet carries its own kill condition, ratified by measured reviews, not vibes.

## 4 · Efficiency targets for the loop (specialized AND general)

1. **Context discipline** — agents read ledgers/graph/RAG top-k, never raw trees (the token rule from [[agentic-graph-brain]] L3).
2. **Deterministic-first** — networkx/scripts before LLM calls; tokens only where judgment is required (L1→L2 order).
3. **Role specialization** — Scout/Scribe/Curator/Cartographer/Smith… each with a bounded prompt; generality lives in the *contract*, not in mega-prompts.
4. **Model diversity per worker** — tidal runs glm-5.3; obsidian swarm mixes models per [[multi-agent-orchestration-patterns]]; POP fleet as local floor.
5. **Bounded runs** — stop criteria in every prompt (the tidal solo: 5 seeds or 2 consecutive rubric rejections).

## 5 · Pickup list (next session starts here)

- [ ] **Tidal solo run in flight** — check tmux `0:3.3` / `~/tidal` trace + ledger; harvest results into the ledgers-if-omitted.
- [ ] Obsidian queue (in order): `[Smith]` graph-index.py → `[Cartographer]` trial → `[Scribe]` foundry-pattern distil → `[Scout]` repo-map sweep (merges with tidal's executed work — no re-staging of done items).
- [ ] After first ledger rows exist: **first curation pass** → publish batch 1 (tidal seeds scored ≥7 + graph proposals applied + foundry-pattern note indexed).
- [ ] Then: grow-the-vault cadence (weekly foundry runs + cron swarm) and a Steward meta-review of the multi-vault loop itself (is the sampler growing? tokens per durable artifact falling?).

## 6 · What we still know we don't know (holes, marked)

- Ledger format isn't standardized across vaults yet — tidal may choose INDEX-table vs `dataset/LEDGER.md`; standardize after first real rows exist (test, don't speculate).
- Publication target undefined (publish = vault-visible? git? external audience?) — decide at first curation pass with real artifacts in hand.
- Colony science: we have n=1 solo runs so far; all efficiency claims above are hypotheses with measurement hooks, not results.
