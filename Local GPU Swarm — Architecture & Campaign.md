---
tags: [project, infrastructure, llm, swarm]
created: 2026-07-25
status: idea
priority: high
---

# Local GPU Swarm — Architecture & Campaign

## Origin

Born from watching two days of Z.ai coding plan quota evaporate. The cron sessions proved autonomous agents work 24/7. The quota burn proved we can't afford it on someone else's API. The problem isn't agents — it's *where* models run and *who pays for tokens*.

## Core Architecture

### Orchestrator (Tier 1)
- 4B or 9B quantized model, resident on one GPU long-term
- Knows the hardware: which tiny model is where, VRAM state, tok/s, context windows
- Becomes the "currency manager" for compute
- Routes tasks to specialists, monitors health, handles failures

### Routing Tiers
- **Tier 0:** Rule-based router (regex, keywords, task type tags) — zero model cost, handles ~70% of routing
- **Tier 1:** 4B orchestrator for ambiguous routing and simple decomposition
- **Tier 2:** Escalation to larger model (llm-prod servers) for complex planning

### Specialists (Disposable)
- 0.8B, 4B, 9B models fully loaded in VRAM on 8GB GPUs
- One-shot: prompt once, get result, move on
- No 100K token conversations. No roleplay. 2K tokens max per task.
- Fine-tuned or prompted for narrow tasks

## Hardware

Seven POP servers, each with 8GB GPU. Models fit entirely in VRAM = fast inference.

### VRAM Budget (8GB)
| Model Size | Q4 VRAM | Fits per GPU | Context Room |
|-----------|---------|--------------|--------------|
| 0.8B      | ~0.5GB  | 6-8 models   | Generous     |
| 4B        | ~2.5GB  | 2-3 models   | Comfortable  |
| 9B        | ~5.5GB  | 1 model      | Tight        |

## Key Principles

1. **Tokens are electricity, not dollars.** The only cost is hardware depreciation + power.
2. **Keep models hot.** Loading/unloading has seconds-to-minutes overhead. Route to resident models.
3. **Specialists are prompts, not model swaps.** Differentiation is mostly prompt engineering on 2-3 resident models per GPU.
4. **No endless conversations.** One-shot specialists. Narrow task in, narrow result out.
5. **The orchestrator is the hard part.** Routing quality determines everything.

## What Already Exists
- POP cluster (pop01-pop07) + llm-prod/llm-prod-2 running llama.cpp
- Parameter sweep infrastructure (inference-engineer skill)
- Configuration playbook

## What's Missing
- Orchestration software: task decomposition → routing → collection → failure handling
- Task queue / message bus between servers
- Model-aware monitoring (VRAM, tok/s, queue depth per server)
- Resource scheduler ("currency manager" logic)

## Anti-Patterns (Learned from the Burn)
- Giant models + huge contexts + endless conversations = token gasoline
- 30 parallel sessions each hitting 100K tokens instantly
- OMO prompting overhead (roleplay, system prompts) consuming budget
- No concurrency awareness — rate limits destroyed

## Next Steps
- [ ] Audit current POP cluster state (what's running, what models, what configs)
- [ ] Design orchestration layer (queue + router + monitor)
- [ ] Pick first specialist task domain to prototype
- [ ] Benchmark: 4B orchestrator routing accuracy vs rule-based Tier 0
