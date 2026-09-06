---
tags: [concept, architecture, graph, agentic, memory, harness, design]
date: 2026-09-06
status: DESIGN v1 — build plan queued
related:
  - "[[graph-stack-llm-surfaces]]"
  - "[[Graph-Notebook]]"
  - "[[multi-agent-orchestration-patterns]]"
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[OS]]"
---

# Agentic Graph Brain — Own-Stack Graph Intelligence

> Follow-up to [[graph-stack-llm-surfaces]]: the audit found two cloud-locked LLM surfaces (Gemini-only KGA, quota-capped InfraNodus). This note is the replacement architecture: **everything the cloud plugins did, done by our own agents on our own models** — pi/opencode/hermes on cron, POP fleet for tokens, the vault as the single interface. Builds on machinery that already runs (runner/worker/queue swarm, LiteLLM gateway, OpenMemory). Not greenfield: ~80% of this is plumbing that exists today.

## The inversion (the one design decision that matters)

**No LLM inside Obsidian. Obsidian only renders what our agents write.**

Plugins try to be smart *inside* the view (→ vendor-locked models, quota walls, keys in plaintext configs). Inverted: all intelligence runs *outside* in cron sessions; the vault's markdown/JSON is the only contract between agents and views. Any surface (Dataview cell, Bases, even a future plugin) reads the same agent-written state. Cloud lock becomes impossible by construction.

## Five layers

### L0 — Data plane: the graph substrate
- Vault markdown stays the single source of truth (wikilinks + tags).
- `_harness/graph/graph-index.py` (deterministic, no tokens): walks the vault, builds the wikilink graph, writes **`journal/graph/edges.json`** — nodes, edges, communities, per-node stats, gap candidates. ~1s for 422 notes, pure `networkx 3.4.2` (already installed; `louvain_communities` + `adamic_adar_index` built in, zero new deps).
- Replaces: Dataview re-indexing the graph on every cell render; KGA's WASM index; InfraNodus's server-side copy of our text.

### L1 — Deterministic compute (no tokens, no cloud)
All the "graph algorithms" the plugins gate behind their UI, as reproducible Python:
- **Gap detection** (the InfraNodus killer feature): cross-community link scarcity — pairs of clusters with near-zero edges between them = blind spots.
- **Link prediction**: `nx.adamic_adar_index` over unlinked pairs = ranked "link next" list (replaces KGA's core pitch).
- Hub/orphan/stub lists, community labels via top TF-IDF terms.
- Output: `journal/graph/gaps-YYYY-MM-DD.md` + `proposals.json` — deterministic, diffable, free. *Replaces: InfraNodus cloud text-mining + KGA Gemini "insights" inputs.*

### L2 — Agent plane (tokens, local-first)
- **New cron role: [Cartographer]** — the graph gardener, extension of Curator:
  1. Reads L1 outputs (never re-reads the vault — that's L3's job),
  2. Calls **LiteLLM gateway → POP fleet** (model our choice, cost our floor),
  3. Narrates gaps, proposes bridge notes + 3 links per top orphan,
  4. Writes proposals to `inbox/graph-proposals-*.md` — **never auto-applies links** (Critic or human gate, per the constitution),
  5. Applied links land in LOG; edges.json re-computes next tick → the loop closes and compounds.
- Scheduling: the existing `queue.md`/`runner.sh` swarm (15-min ticks, flock, MAX_SESSIONS_PER_DAY) — Cartographer jobs are just queue entries. `worker.sh` already sends one prompt to any agent CLI; `cron-agent-swarm` is agent-CLI-agnostic → **pi slots in as a worker CLI** alongside opencode/claude (model diversity per [[multi-agent-orchestration-patterns]]).
- **Hermes** (`/home/fabio/.local/bin/hermes`, Telegram skill exists): pushes the daily gap digest to phone; human replies = gate decisions from anywhere. Mobile human-in-the-loop without opening Obsidian.

### L3 — Memory plane (the multi-layer agentic memory)
The "multiple layers" ask, concretely — six layers, each with an owner and a decay profile:

| Layer | Substrate | Lifetime | Owner (existing roles) |
|---|---|---|---|
| Working | `MEMORY.md` ≤2000 chars | session | all |
| Episodic | `journal/sessions/*.md` | forever, append-only | Scribe |
| Associative | wikilink graph + `edges.json` | durable, self-editing | **Cartographer (new)** |
| Semantic | OpenMemory MCP (RAG, embeddings) | durable, evolving | Curator |
| Declarative | `wiki/` curated notes | permanent, human-gated | Critic gate |
| Procedural | skills (`_harness`, `.forge`, pi/opencode skills) | versioned | Smith |

Flow: working → episodic (Scribe) → associative+semantic (Cartographer/Curator) → declarative (Critic gate) → procedural (Smith harvests what worked into skills). **Token rule: an agent never reads the 422-note vault directly — it reads MEMORY.md (working) + RAG top-k (semantic) + edges.json (associative).** That's the cost+context win that makes endless cron viable.

### L4 — Surface plane (what the human sees)
- A `dataviewjs` cell in [[Graph-Notebook]] reads `journal/graph/edges.json`: community colors, dashed lines for gap candidates, click-to-open. Same UX as InfraNodus 3D, zero cloud.
- `inbox/graph-proposals-*` surfaces on [[Triage]] (existing pin).
- Juggl/ExcaliBrain/native graph **stay** — they're local views, harmless; the audit cleared them. We only killed their cloud siblings.

## Replacement map (bullshit → ours)

| Removed/defused | Replaced by |
|---|---|
| KGA Gemini insights (notes → Google) | L1 adamic-adar + Cartographer narration on POP |
| KGA endpoint lock (`GEMINI_API_BASE` const) | gone — no patch needed if AI layer never keyed |
| InfraNodus ~500 notes/day quota + cloud copy | L1 gap detection, local, 1s, unlimited |
| InfraNodus cloud model list (`fetchAiModels()`) | LiteLLM model list — ours |
| Future "AI plugin" temptation | the inversion rule: plugins render, agents think |

## v1 build plan (queued — 2 jobs, each one bounded session)

1. **[Smith] `_harness/graph/graph-index.py`** — walk vault, build graph, Louvain communities, adamic-adar top-50, cross-cluster gap scores → `journal/graph/edges.json` + `gaps-$(date).md`. Deterministic; verify = run twice, diff = empty.
2. **[Cartographer] trial run** — read edges.json + gaps, one LiteLLM call to POP, write `inbox/graph-proposals-*.md` with ≤5 link proposals + 1 gap bridge. Stop. Human applies.
3. *(then)* Graph-Notebook cell rendering edges.json; Hermes daily digest; weekly Cartographer cadence.

Kill criterion for the whole thesis (Test Don't Wonder): if after 2 weekly cycles the applied-proposals rate is 0 and gaps don't shrink → the graph brain is theater; kill Cartographer, keep L1 (free regardless).

## Why this compounds

Each cycle: edges.json → gaps → proposals → applied links → denser graph → better RAG recall + better agent context → better proposals. The vault's structure *is* the memory, and every agent session makes the next one cheaper (more associative hits, less full-text reading). That's the "child brain" thesis of the Master Plan, finally wired into the graph.

## Evidence & hooks

- Machinery verified live 2026-09-06: `runner.sh`/`worker.sh`/`queue.md` in `_harness/`; `networkx 3.4.2` on Orcrist; `pi` + `opencode` + `hermes` on PATH; POP LiteLLM gateway per [[OS]].
- Louvain + Adamic-Adar are stdlib networkx (no pip). igraph/Leiden optional later.
- Queue jobs appended to `_harness/queue.md` this session.
