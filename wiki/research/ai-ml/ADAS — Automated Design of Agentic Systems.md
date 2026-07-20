---
tags: [research, ai-ml, self-improving-agents, meta-agent, orchestrator, source-clip]
date: 2026-07-20
source: arXiv:2408.08435
authors: [Shengran Hu, Cong Lu, Jeff Clune]
status: clipped — id verified 2026-07-20 (was to-verify)
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
  - "[[SEAL — Self-Adapting Language Models]]"
---

# ADAS — Automated Design of Agentic Systems

> **What it gives the harness:** "the harness improves the harness," formalized — a meta-agent *searches over agent designs expressed as code* and keeps the best. This directly informs our orchestrator, which [[Agent Roles & Orchestrator — The Moat]] calls the moat.

## The mechanism
- Proposes **ADAS** as a field: automatically create agent architectures instead of hand-designing them.
- **Meta Agent Search** programs candidate agents *in code* and improves them by drawing on an **ever-growing archive** of prior discoveries.
- Because code is **Turing-complete**, the search spans prompts, tool usage, workflows, and their combinations — not just prompt tweaks.
- Retains designs that **generalize across tasks and models**; claims learned designs can outperform human-crafted ones.

## Why it matters to the Forge
ADAS is the formal version of our meta-review ambition: the orchestrator layer (role cast, queue, promotion gates) is itself a *design* that could be searched over and improved, rather than frozen. The key transferable idea: **represent harness components as code/artifacts in an archive, and let a meta-pass propose + evaluate variants against a validation score.** Guardrail from the constitution: design changes to governance stay Z2/Z4 (human-approved) — the search proposes, the human disposes.

## Verdict
★★★ — design reference for the orchestrator/moat. Action: treat harness config (roles, queue rules, gates) as archivable, versionable candidates for a future meta-review pass — never auto-applied.
