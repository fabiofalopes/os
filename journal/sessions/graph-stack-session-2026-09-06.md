---
tags: [session, handoff, graph, swarm, foundry, batch, shim]
date: 2026-09-06
status: HANDOFF — full situation after the graph-stack session
related:
  - "[[graph-stack-llm-surfaces]]"
  - "[[agentic-graph-brain]]"
  - "[[multi-vault-agentic-workloads]]"
  - "[[vault-embedded-research-routines]]"
  - "[[foundry-pattern]]"
---

# Graph-Stack Session — Full Handoff (2026-09-06)

> One page: what this session built, what's live, what's pending, how the two sides interface. Started as "graph plugins + LLM control" — ended as the whole engine armed.

## 1 · Situation snapshot

| Subsystem | State | Evidence |
|---|---|---|
| Swarm cron | **ARMED */15** (runner+health+oracle), cap 90/day, rollback `swarm disarm` | `swarm status` → ARMED; 0 disabled forge lines |
| Gateway | **DOWN** — Lusófona 503 (external, full outage) | direct probes 503; waves safely `SKIP(GATEWAY)` until recovery; breaker re-probes |
| Queue | 8 pending jobs (graph-index [Smith] · Cartographer trial · Scribe distil · Scout sweep · deep-research trial · batch triage · quant-gated · …) | `_harness/queue.md`; executes automatically when gateway returns |
| Tidal foundry | Solo run **in flight** on tmux `0:3.3` (glm-5.3): JP one-liners → vroomvroom → looper; dataset ledger contract issued | check pane / `~/tidal` trace |
| Batch mode | **LIVE** — `graph-stack-patterns` (1 staged, 1 BLOCKED for human read, 1 DONE by human gate) | `bash _harness/batch/batch.sh status` |
| Gemini shim | **BUILT + mock-proven** (:8706), KGA patch **staged for human** | `_harness/shim/` |

## 2 · The interface matrix ("plugin X has LLMs — integrate OURS")

| Direction | Mechanism | Status |
|---|---|---|
| **Our agents → Obsidian surfaces** | agents write state (md/JSON) that dataviewjs/Bases render — Cell 0 pattern; `edges.json` cell lands when [Smith] runs | design + jobs queued |
| **Plugins → our LLMs (the boom)** | `gemini_shim.py` :8706 speaks generateContent, thinks OpenAI, routes to router :8705 → POP. ANY Gemini-hardcoded plugin works against it. KGA: `bash _harness/shim/kga-patch.sh apply` (human — `.obsidian/` is yours; revert + status verbs included) | shim proven; apply awaits human + gateway |
| **InfraNodus** | dev-mode API URL → self-host option (AGPL) — superseded by local gap detection unless wanted | optional |
| **Human → engine** | `swarm {status,fire,arm,disarm}` · `batch.sh status` ⚠️ INTERVENE · Hermes phone gates | live |

Principle (leak-derived): **Agent = Model × Harness**; plugins render, agents think; the vault is the harness.

## 3 · Everything built this session (receipts)

1. **Audit**: `[[graph-stack-llm-surfaces]]` — KGA Gemini-only (hardcoded `GEMINI_API_BASE`), InfraNodus ~500 notes/day cloud cap (= the "too many notes"), Juggl/ExcaliBrain/Cell-0 local.
2. **Architecture**: `[[agentic-graph-brain]]` (5 layers, 6-layer memory, [Cartographer] role, kill criteria) + work-dimensions model + attempt-triggered research contract (nvim `knowledge/` receipts as model).
3. **Swarm control**: `_harness/swarm` — found the engine DISARMED since ~Aug 3; armed today; 3 quoting bugs caught by live testing (substring matcher, sed `$`-anchor, hardcoded is_armed).
4. **Ingestion gate**: `_harness/ingest/gate.sh` — 16/16 Clippings clean, verdicts ledger, `--llm` lane (degrades when down), ClamAV hook.
5. **Research routines**: `_harness/research/{websearch,papers}.sh` — keyless, live-verified (DDG-html POST + GitHub API; arXiv https + Crossref).
6. **Batch mode**: `_harness/batch/batch.sh` — repo-map at scale, state machine, ⚠️ INTERVENE view, append-only `trace.md` (behavioral record).
7. **Shim**: `_harness/shim/` — Gemini↔OpenAI translation proven with mock upstream.
8. **Tidal orchestration**: solo-run mission sent to tmux `0:3.3`; absorption queued ([Scribe] distil, [Scout] sweep).

## 4 · Pending decisions / next session pickup

- [ ] **Human:** `kga-patch.sh apply` (when gateway green + shim running as service) — optional, AI-off policy stands meanwhile.
- [ ] **Human:** read BLOCKED `sturlese/hippocampus` (batch graph-stack-patterns).
- [ ] **Auto:** gateway recovery → waves resume 8 queued jobs (first tick after :8705 green).
- [ ] **Then:** harvest tidal solo run → ledger rows → first curation pass (DESIGN FREEZE v1 lifts after it ships).
- [ ] **Consider:** systemd unit for the shim; SearxNG deploy; ClamAV install; POP repoint as gateway fallback (would have made today's outage a non-event — biggest single-resilience win available).

## 5 · One-line doctrine learned today

Perpetual engine, bounded runs: the machine searches and distills forever; every job inside it can die; the human sets intent, decides at gates, reads results.
