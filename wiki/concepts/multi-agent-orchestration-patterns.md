---
tags: [concept, harness, multi-agent, orchestration, meta]
date: 2026-07-21
status: design v1 — workers live; council on probation (COUNCIL_ENABLED=0)
related:
  - "[[Agent Roles & Orchestrator — The Moat]]"
  - "[[the-alpha-illusion]]"
  - "[[snapshot-survey]]"
  - "[[the-forge-synthesis]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Multi-Agent Orchestration Patterns — What We Steal and What We Don't

> **What it gives the harness:** the design rationale for the "agentic village" wave-engine (`_harness/runner.sh` + `worker.sh` + `council.sh`). One decision above all: **multi-agent value here comes from parallel independent WORK and model-diverse steering, NOT from debate.** That isn't aesthetic — it's forced on us by our own ★★★ finding in [[the-alpha-illusion]]. Completes [[learning-path]] Phase 2 and skill-backlog #13.

## The three patterns we researched (and their verdicts)

| Pattern | Source | Shape | Verdict for us |
|---|---|---|---|
| **Role-playing debate** | TradingAgents (arXiv:2412.20138) | analysts → bull/bear debate → risk gate → decision | Harvest the *architecture* (roles + gate); do NOT trust debate as a truth-finder. |
| **Multi-model consensus** | Moon Dev `swarm_agent.py` ([[snapshot-survey]]) | fan one prompt to N *different* LLMs in parallel, anonymize as "AI #1..N", a cheap reviewer synthesizes | **Steal the shape.** Independence comes from *different models*, not persona prompts. |
| **Plurality vote** | Moon Dev `trading_agent.py` | tally raw BUY/SELL/NOTHING, `max(votes)` (plurality, not >50%) | Steal for discrete decisions; note it's plurality, not majority. |

## The constraint that shapes everything ([[the-alpha-illusion]], P6 + PPL)

- **Multi-agent debate wins <20% of the time** across 36 configs (Zhang et al. 2025). Architecture, not backbone, dominates outcome variation (AMA benchmark).
- **PPL:** persona prompts and debate do **not** remove the shared pretraining prior → multi-agent *agreement* is a poor proxy for *independent-expert* agreement. Same-model "debaters" agree because they share priors, not because they're right.
- **P6 rule:** single-agent baseline + disagreement rate + net-value delta — or the multi-agent claim is void.

**Therefore:** a council of same-model persona agents "debating" a factual question is near-guaranteed underperformance. We don't do that.

## Our adaptation — where multi-agent actually pays

1. **Parallel workers = throughput, not deliberation.** N workers on N *distinct* jobs (the [[Agent Roles & Orchestrator — The Moat]] roles) is pure parallelism. No PPL problem — they aren't trying to agree, they're doing separate work. This is the unambiguous win and the core of the wave-engine (`WORKERS_PER_TICK`).
2. **Council = steering about DIRECTION, not facts.** The council (`council.sh`) deliberates about *what to prioritize next* — where diverse perspectives help and a wrong call costs an hour, not a false belief. It uses **three different models** (genuine independence per Moon Dev), **anonymized** (the critic attacks the argument, not the model), and runs a **single-agent baseline** on the same input for A/B.
3. **The council is on probation (P6, operationalized).** Every council wave logs a row to `journal/council/ab-ledger.md` (council-jobs vs baseline-jobs vs appended). `_harness/council-audit.sh` scores whether the council's appended jobs actually succeeded (`[x]` vs `[!]`). **Kill the council (`COUNCIL_ENABLED=0`) unless it measurably beats the baseline.** This is [[Operating Principle — Test Don't Wonder]] applied to the harness itself.
4. **The Critic stays a gate.** Promotions the council endorses are *recommendations* for human approval (Z2), never auto-applied — the adversarial Critic lens from [[Agent Roles & Orchestrator — The Moat]], defaulting to "refuted if uncertain."

## The architecture (one clock, tiered by wave count)

```
cron */15 → runner.sh (wave dispatcher; flock = one wave at a time)
 ├─ claim up to WORKERS_PER_TICK distinct jobs (target de-dup; breaker quarantines [!])
 ├─ fork workers in parallel (setsid groups; self-bounded by WORKER_BUDGET; reaped on exit)
 ├─ substrate detect-and-revert (workers are read-only on INDEX/MEMORY/LOG/queue)
 ├─ serial: log one line per worker, mark [x] the ok ones
 ├─ every BUILDER_EVERY wave: one serial "builder" session (bigger job, bigger turn budget)
 └─ every COUNCIL_EVERY wave (if COUNCIL_ENABLED): council.sh steering (3 models + baseline)
```

The loop: **workers produce → council synthesizes & steers (appends/reprioritizes jobs) → workers produce.** The Conductor ([[Agent Roles & Orchestrator — The Moat]] §6.2 — "start fixed, earn autonomy") earning its re-plan autonomy. Measured, not assumed.

## Evidence ledger
- ✅ Patterns + verdicts from [[snapshot-survey]] (Moon Dev consensus/voting, read & vetted) and [[learning-path]] Phase 2 (TradingAgents).
- ✅ P6/PPL constraints from [[the-alpha-illusion]] (fully read 2026-07-21; debate <20% of 36 configs; PPL flip-rate 8% vs 30% at 60% counter-evidence).
- ✅ Wave-engine mechanics validated 2026-07-21: parallel fork (2 workers × 2s stub = 2s wall), content-matched checkbox flip, substrate detect-and-revert, orphan reaping.
- ⚠️ Council A/B results: **pending** — `COUNCIL_ENABLED=0`; `ab-ledger.md` empty until enabled. Do not trust council steering until `council-audit.sh` shows it beats the baseline.
- Design rule carried forward: **single-agent ablation before any multi-agent claim** ([[the-alpha-illusion]] P6).
