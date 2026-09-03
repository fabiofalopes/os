---
title: "Harness Porting Strategy — OMX/Claude Code → OpenCode"
created: 2026-07-21
tags:
  - harness-engineering
  - porting
  - opencode
  - omx
  - claude-code
  - strategy
type: strategy
confidence: established
last_updated: 2026-07-21
---

# Harness Porting Strategy

> How to port the best of Claude Code and OMX/Codex into our OpenCode harness. Not copying — adapting. The harness is the product; the model is just gas.

## Architectural Insight

The three systems are **complementary layers**, not competitors:

```
Claude Code  =  Prevention layer (anti-slop rules in system prompt)
             +  Covert layer (steganography, undercover, telemetry)
             +  Infrastructure layer (context pipeline, permissions, hooks)

OMX/Codex    =  Workflow layer (ralph, ralplan, autopilot, team, ultraqa)
             +  Role layer (28 agent TOMLs with model routing)
             +  Discipline layer (lane selection, consensus gates, verification loops)

OpenCode/OMO =  Agent layer (sisyphus, prometheus, metis, momus, oracle)
             +  Domain layer (35 skills: networking, infra, Obsidian)
             +  Orchestration layer (Diane tmux sprawl)
```

**What OpenCode is missing**: The workflow and discipline layers. We have agents but not the protocols that chain them.

---

## Porting Principles

1. **Port protocols, not code** — OMX skills reference `omx state`, `omx question`, Codex goal mode. Replace with OpenCode subagent calls to OMO's metis/oracle/sisyphus.
2. **Reconcile, don't fork** — Diane IS the team orchestrator. Port OMX's coordination protocol (claim-safe tasks, ATEM gate) as Diane guidance.
3. **Skills are SKILL.md** — Both OMX and OpenCode use the same format. Most Tier 1 skills port near-verbatim.
4. **The AGENTS.md lane contract is the highest-leverage port** — Pure guidance text, no runtime dependency.

---

## What to Port (Priority Order)

### Tier 1 — Standalone, immediate value

| # | Skill | From | Adaptation Needed |
|---|-------|------|-------------------|
| 1 | **agents-md-lane-contract** | OMX AGENTS.md | Pure text. Copy delegation lanes + specialist routing into OpenCode AGENTS.md |
| 2 | **analyze** | OMX skill | Remove `omx` references. Use explore + oracle for ranked synthesis |
| 3 | **code-review** | OMX skill | Replace `code-reviewer`/`architect` agents with oracle calls |
| 4 | **ultraqa** | OMX skill | Standalone. Remove Codex goal-mode references |
| 5 | **vault-health-check** | Vault gap | New skill. Use QMD + filesystem tools |
| 6 | **ask** | OMX skill | Replace `omx sparkshell` with bash calls to other harnesses |

### Tier 2 — Needs Tier 1

| # | Skill | From | Adaptation Needed |
|---|-------|------|-------------------|
| 7 | **deep-interview** | OMX skill | Use OMO metis. Port ambiguity-scoring math |
| 8 | **consensus-plan** | OMX skill | Use OMO prometheus + momus. Add ADR artifact |
| 9 | **security-review** | CC `/security-review` | New skill based on CC's bundled review prompt |
| 10 | **model-prompt-overlays** | Vault research | Research done (632 lines). Pure implementation |
| 11 | **hook-patterns** | CC hooks system | Expand from 1 hook (comment-checker) to N |
| 12 | **stt-error-corrector** | Vault idea | New skill. Persistent mistake map + pipeline |

### Tier 3 — Needs Tier 2

| # | Skill | From | Adaptation Needed |
|---|-------|------|-------------------|
| 13 | **ralph** | OMX skill | The big one. Replace Codex goal-mode with OpenCode session persistence |
| 14 | **ultragoal** | OMX skill | Durable ledger. Use filesystem for goals.json/ledger.jsonl |
| 15 | **auto-dream** | CC dream system | Nightly consolidation. Use cron + cheap model |
| 16 | **autoresearch** | OMX skill | Validator-gated. Use oracle for validation gate |

### Tier 4 — Needs Tier 3

| # | Skill | From | Adaptation Needed |
|---|-------|------|-------------------|
| 17 | **autopilot** | OMX skill | Full pipeline. Composes B1→B2→C1→A2→C4 |
| 18 | **obsidian-conductor** | Vault spec | 4 sub-agents. Use cheap models |
| 19 | **infrastructure-operator** | Vault gap | Unify 5 z800-* skills |

---

## What NOT to Port

| Item | Why |
|------|-----|
| `prometheus-strict` | OpenCode has the ORIGINAL. OMX copied from us. |
| `wiki` | Vault + QMD + OpenMemory is strictly richer |
| `cancel/hud/doctor/omx-setup` | OMX-runtime-specific, not portable |
| `imagegen/openai-docs/plugin-creator/skill-installer` | Codex-native |
| `team/worker` (as-is) | Reconcile with Diane, don't fork |
| Steganography/undercover | Trust-violating. We don't want covert channels. |

---

## Claude Code Features Worth Studying (Not Porting)

These are harness engineering patterns to learn from, not copy:

| Feature | Why It's Interesting | Our Equivalent |
|---------|---------------------|----------------|
| 5-stage context compression | Most sophisticated context management | `/compact` (single-stage) |
| YOLO classifier (ML-based permission) | ML danger assessment for Bash commands | Permission prompts |
| 4-type memory taxonomy | Closed system: user/feedback/project/reference | OpenMemory (open, untyped) |
| Auto-dream consolidation | Sleep-like memory processing | Nothing |
| 25+ hook event types | Rich lifecycle extensibility | 1 hook (comment-checker) |
| Microcompact (cache-editing) | Zero-cost compression via cache manipulation | Nothing |
| Context Collapse (projection-based) | Lazy archival with commit log replay | Nothing |
| KAIROS daemon mode | Always-on autonomous agent | Nothing (closest: Diane) |
| Buddy/Tamagotchi | Companion personality layer | Nothing |
| Coordinator mode (4-tool restriction) | Strict tool limitation for orchestrators | Diane (unrestricted) |

---

## The Trust Contract

From [[Claude-Code-Steganography-And-Hidden-Features]]:

> "Coding agents already live on the wrong side of a scary boundary. They can inspect code, summarize secrets by accident, run commands, install packages, edit files, and push commits on your local machine."

Our harness should be **boring in the ways that matter**:
- No covert channels in prompts
- No obfuscated telemetry
- No hidden feature flags
- Explicit, documented behavior
- Trust earned in the boring parts

The science we steal: context compression, memory taxonomy, hook architecture, permission layers, workflow discipline.
The behavior we reject: steganography, undercover mode, obfuscated flag names.

## See Also

- [[Tool-Ontology-Framework]] — 12-axis classification for any tool/skill
- [[Skill-Candidate-Map-2026-07]] — full 60+ candidate inventory
- [[Claude-Code-Steganography-And-Hidden-Features]] — CC hidden behaviors
- [[Agent Skills - The Harness Playbook]] — universal harness principles
- [[Skill-Inventory]] — current 978-skill catalog
