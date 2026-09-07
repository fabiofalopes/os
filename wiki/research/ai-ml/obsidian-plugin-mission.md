---
tags: [mission, graph, plugins, obsidian, llm, status]
date: 2026-09-06
status: LIVING — the original session thread, kept open
related:
  - "[[graph-stack-llm-surfaces]]"
  - "[[agentic-graph-brain]]"
  - "[[Graph-Notebook]]"
  - "[[graph-stack-session-2026-09-06]]"
---

# Obsidian Plugin Mission — The Original Thread

> This session began here (2026-09-06): *"this vault now has a bunch of plugins… we should control what agentic (LLMs and so on) run… one of them only has Gemini lmao… one can't be used because it says too many notes… how do you see current graph systems and what each allows to plug as for agentic or LLM calls."* Everything after (swarm, foundry, batches, userbase) grew from this. This note keeps the plugin thread from being forgotten inside its own success.

## The mission, restated

1. **Control** — decide what LLM/agentic work any plugin may do, with which model, at what egress.
2. **Unblock** — KGA locked to Gemini; InfraNodus quota-walled ("too many notes").
3. **Learn** — better views: how to display and *work* the graph data, not just stare at it.
4. **Integrate ours** — "plugin X has LLMs like this? put OURS in it, boom."

## Answered (with receipts)

| Mission item | Verdict | Evidence |
|---|---|---|
| Who can call LLMs | Only KGA (Gemini-only, hardcoded `GEMINI_API_BASE`) + InfraNodus (cloud, models fetched from server). Juggl/ExcaliBrain/Cell-0 fully local (Juggl's one "Gemini" hit = zodiac icon). | [[graph-stack-llm-surfaces]] |
| "Too many notes" | InfraNodus free tier ~500 notes/day; vault = 422 → one sync eats it. Not our bug — their wall. | same, §2 |
| The doctrine | **No LLM inside Obsidian — plugins render, agents think.** | [[agentic-graph-brain]] |
| "Boom" integration | `gemini-shim` (:8706) speaks Gemini → thinks OpenAI → our router → POP. **Mock-proven.** Any Gemini-hardcoded plugin runs OUR models. | `_harness/shim/` |
| InfraNodus gap detection | Superseded — local L1 (networkx gaps/Adamic-Adar) does it free; self-host optional. | [[agentic-graph-brain]] L1 |

## Still open — the do-not-forget list

**Human gates (yours):**
- [ ] `bash _harness/shim/kga-patch.sh apply` — point KGA at our shim (when gateway green + shim running; revert verb included). Until then: KGA stays AI-off, algorithms-only.
- [ ] Read BLOCKED `sturlese/hippocampus` (batch `graph-stack-patterns`) — the "lite personal brain" that mirrors our thesis.
- [ ] [[_meta/graph-groups-proposal]] — colorGroups patch still staged for `.obsidian/graph.json`.

**Machine-gated (run when gateway returns):**
- [ ] [Smith] `graph-index.py` → `journal/graph/edges.json` (queued) → then the **edges.json cell** in [[Graph-Notebook]] (community colors, dashed gap edges — the InfraNodus-killer view).
- [ ] [Scout] triage `green-dalii/obsidian-llm-wiki` (★574, Karpathy's LLM-wiki pattern) + `simple-graph-builder` — staged in batch `graph-stack-patterns`.

**The "better views" backlog (unstarted, by design — freeze until curation pass):**
- [ ] Arc/matrix D3 fork of Cell 0 (readable at 400+ nodes)
- [ ] Graph-diff cell (structure change week-over-week)
- [ ] Link-suggester + gap-narrator LLM cells (via local gateway, proposals-only)

## Where everything lives

Audit · architecture · shim · batch · session digest: see `related` links. Graph-Notebook = the visible lab (Plugin Lab section). The plugin mission and the vault brain are one system now: plugins are views; the thinking moved outside where we own it.
