---
tags: [harness, architecture, agents, orchestrator, meta]
date: 2026-07-20
status: design v1
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Agent Roles & Orchestrator — The Moat

> The user's core instinct: *different personalities for different work, under one orchestrator — and that orchestration layer IS the moat.* Anyone can call a model; the defensible thing is the **defined roles + the scheduler that composes them + the memory they share**. This note defines the cast and the conductor.

## 0. Why roles, not one generalist
A single prompt that must "research + write + curate + forge + not-burn-tokens" optimizes for nothing. Splitting into **personalities** lets each carry: a tight system prompt, its own tool allowlist, its own model tier, its own budget, and its own *validation gate*. The orchestrator's job is composition and memory — not doing the work.

## 1. The cast (personalities)

Each = a role prompt + governed folders (Forge zones) + model tier + cap.

| Role | Personality / voice | Core drive | Model tier |
|---|---|---|---|
| **Conductor** (orchestrator) | Calm, terse, budget-obsessed | Decide *what runs, in what order, with what budget*; never does leaf work; reads `LOG.md`/`INDEX.md`/metrics to route | capable, but called rarely |
| **Scout** | Curious, skeptical, fast | Find the edge; clip + verdict; never clip without "what it gives us" | cheap (Qwen flash) |
| **Scribe** | Precise, atomic | Turn raw material into clean atomic notes + idea sparks | cheap→mid |
| **Curator** | Librarian, connective | Tag, link, MOC, glossary — make the graph navigable | cheap |
| **Janitor** | Ruthless, tidy | Lint, heal links, dedupe, prune rot | cheap / local |
| **Distiller** | Reflective | Sessions + research → durable knowledge; stage skill candidates | mid |
| **Smith** | Rigorous, empirical | Forge/optimize skills via SkillOpt; promote **only on measured gain** | capable (night) |
| **Quant** | Numerate, paranoid about overfitting | Mine alpha ideas → backtest → paper-trade, gated | mid→capable |
| **Steward** | Auditor | Health, cost report, asset accounting, surface dead loops | tiny |
| **Critic** *(adversarial)* | Hostile by design | Attack any claim/strategy/skill before it's promoted; default to "refuted if uncertain" | mid |

**Critic is special:** it's not a stage, it's a *lens* the Conductor invokes on anything about to be promoted (a wiki synthesis, a trading signal, a forged skill). This is how we stay "ahead of the curve, not naive" — every durable artifact survives an adversary.

## 2. The Conductor (the moat)

```
Conductor (cron tick / nightly)
 ├─ read state: LOG.md, INDEX.md, metrics.json, MEMORY.md, budget remaining
 ├─ plan the run: which roles, in what order, what caps  (this plan is written to LOG.md)
 ├─ dispatch roles in dependency order:
 │     Scout → Scribe → (Curator ∥ Janitor) → Distiller → Quant → Smith
 ├─ before any promotion: invoke Critic (adversarial gate)
 └─ Steward: write cost+asset report, update MEMORY.md, commit
```

The Conductor is **deterministic control flow around model calls** — exactly what the Workflow/cron-wrapper pattern gives us. Its intelligence is *routing under budget*, not generation. Because it's the thing that decides how the whole mind spends its tokens and what it promotes, **it is the hardest part to replicate and the thing worth perfecting.**

## 3. Shared substrate (what makes the cast one mind)
- **One vault, one `MEMORY.md`** (char-bounded, loaded at session start) — every role starts with the same working memory.
- **One `LOG.md`** — append-only audit; the Conductor's episodic memory and the Steward's health signal (contiguity check catches a dead timer).
- **One `INDEX.md`** — the map every role consults before creating (dedupe-by-lookup).
- **One skill store** (`.forge/skills/`, SKILL.md format) — roles *use* skills; the Smith *improves* them. The cast literally runs on what it previously learned.

## 4. Instantiation model ("an entity developing through its life")
Each cron tick **instances** the cast fresh, but they boot from the shared substrate — so the *entity* persists even though each *instance* is ephemeral. Growth = the substrate getting richer (denser wiki, better skills, sharper MEMORY.md). The Conductor's routing policy itself is a skill the Smith can optimize → the harness tunes its own orchestration. See [[Bootstrap to Self-Funding — The Agent Life Arc]].

## 5. Build order (don't cast the whole play on day one)
1. **Conductor + Steward + Janitor + Curator** — safe, uses installed skills, immediate hygiene. Proves the scheduler + substrate.
2. **+ Scout + Scribe** — knowledge intake begins.
3. **+ Distiller** — once the Claude Code transcript source is confirmed.
4. **+ Critic** as a gate on promotions.
5. **+ Smith** — SkillOpt nightly, once we have skill candidates + a benchmark.
6. **+ Quant** — the first hard value test, paper-only.

## 6. Open design questions
- Conductor as a shell-wrapper cron (like `fleet-optimizer`) vs. a Workflow script vs. a Claude Code headless (`claude -p`) call? (Recommend: shell wrapper dispatching `claude -p` per role — matches existing pattern, cheap, observable.)
- How much autonomy does the Conductor have to re-plan mid-run vs. fixed DAG? (Start fixed; earn autonomy.)
- Critic budget: how many adversarial passes per promotion before diminishing returns?
