---
title: "Skill Candidate Map — July 2026"
created: 2026-07-21
tags:
  - harness-engineering
  - skill-design
  - porting
  - opencode
  - omx
  - claude-code
type: reference
confidence: established
last_updated: 2026-07-21
---

# Skill Candidate Map — July 2026

> Complete inventory of every skill candidate across Claude Code, OMX/Codex, and vault gaps. Classified by [[Tool-Ontology-Framework]].

## Sources Analyzed

| Source | What We Found |
|--------|--------------|
| Claude Code v2.1.88 (25-doc analysis) | 50+ tools, 90+ commands, 25+ hook events, 5-stage context pipeline, 4-type memory |
| OMX/Codex (~/.codex/) | 29 workflow skills, 5 system skills, 37 role prompts, 28 agent TOMLs |
| Vault gaps (337+ notes) | 34 items across 5 tiers |
| OpenCode current state | 35 skills (mostly domain knowledge, NOT workflow orchestration) |

## Critical Finding

OpenCode has the **agents** (via OMO: sisyphus, prometheus, metis, momus, oracle) but NOT the **workflows** that chain them. OMX's value is in orchestration protocols, not individual agents. OMX's `prometheus-strict` even credits OMO Prometheus — OpenCode has the original.

---

## Domain A: Code Quality & Hygiene

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **ai-deslop** | CC+OMX | ✅ built | — |
| **code-review** (two-lane) | OMX | ❌ | 🔴 Phase 1 |
| **security-review** | CC | ❌ | 🟠 Phase 2 |
| **code-simplifier** | OMX | ❌ | 🟡 Phase 2 |
| **comment-checker** (hook) | VG | ✅ built | — |

## Domain B: Planning & Reasoning

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **deep-interview** (ambiguity-gated) | OMX | 🟡 metis exists, no workflow | 🔴 Phase 1 |
| **consensus-plan** (ADR + pre-mortem) | OMX | 🟡 prometheus exists, no gate | 🟠 Phase 2 |
| **analyze** (ranked synthesis) | OMX | ❌ | 🔴 Phase 1 |
| **critical-thinking** | VG | ✅ built | — |
| **scholastic-review** | OMX | ❌ | 🟡 Phase 3 |

## Domain C: Execution & Persistence (BIGGEST GAP)

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **ralph** (persistence loop) | OMX | ❌ | 🔴 Phase 3 |
| **ultragoal** (durable ledger) | OMX | ❌ | 🟠 Phase 3 |
| **autopilot** (full pipeline) | OMX | ❌ | 🟡 Phase 4 |
| **ultraqa** (adversarial QA) | OMX | ❌ | 🔴 Phase 1 |
| **ultrawork** (parallel discipline) | OMX | 🟡 Diane exists | 🟠 Phase 2 |
| **pipeline** (stage sequencer) | OMX | ❌ | 🟡 Phase 4 |

## Domain D: Multi-Agent Coordination

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **team** (tmux workers) | OMX | 🟡 Diane is analog | Reconcile, don't fork |
| **worker-protocol** | OMX | 🟡 | Only if team reconciled |
| **coordinator-mode** | CC | 🟡 Diane informal | Port tool restriction |
| **ask** (external advisor) | OMX | ❌ | 🔴 Phase 1 |

## Domain E: Context & Memory

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **context-compaction** (5-stage) | CC | 🟡 /compact exists | 🟡 Phase 3 |
| **memory-taxonomy** (4-type) | CC | 🟡 OpenMemory exists | 🟠 Phase 2 |
| **auto-dream** (consolidation) | CC | ❌ | 🟠 Phase 3 |
| **session-branching** | VG | ❌ | 🟡 Phase 4 |
| **normalization-pipeline** | VG | ❌ | 🟡 Phase 4 |

## Domain F: Hooks & Quality Gates

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **hook-patterns** (25+ events) | CC+VG | 🟡 1 hook exists | 🟠 Phase 2 |
| **permission-risk-scoring** | CC | 🟡 policy module exists | 🟡 Phase 3 |
| **reversibility-gate** | CC | ❌ | 🟠 Phase 2 |

## Domain G: Vault & Knowledge

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **vault-health-check** | VG | ❌ | 🔴 Phase 1 |
| **moc-auto-gen** | VG | ❌ | 🟡 Phase 3 |
| **obsidian-conductor** (4 agents) | VG | ❌ | 🟡 Phase 4 |
| **knowledge-worker** | VG | ❌ | 🟡 Phase 5 |
| **frontmatter-normalizer** | VG | ❌ | 🟠 Phase 2 |

## Domain H: Infrastructure

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **infrastructure-operator** | VG | ❌ "missing 4th pillar" | 🟠 Phase 4 |
| **z800→z600 migration** | VG | ❌ | 🔴 trivial |
| **model-diagnostics** | VG | ❌ | 🟡 Phase 2 |
| **fuel-gauge** | VG | 🟡 partial | 🟡 Phase 3 |
| **agent-radar-curation** | VG | ❌ | 🟡 Phase 3 |
| **credential-isolation** | VG | ❌ | 🟠 Phase 2 |

## Domain I: Research

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **autoresearch** (validator-gated) | OMX | ❌ | 🟡 Phase 3 |
| **best-practice-research** | OMX | 🟡 librarian exists | 🟡 Phase 3 |
| **repo-auditor** | VG | ✅ Phase A done | Phase B: CLI |
| **performance-goal** | OMX | ❌ | 🟡 Phase 4 |

## Domain J: Design & Frontend

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **design-doc** (DESIGN.md) | OMX | ❌ | 🟡 Phase 3 |
| **visual-ralph** (pixel-diff loop) | OMX | ❌ | 🟡 Phase 4 |

## Domain K: Voice & Communication

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **stt-error-corrector** | VG | ❌ "High priority" | 🟠 Phase 2 |
| **voice-command-router** | VG | ❌ | 🟡 Phase 4 |
| **telegram-bidirectional** | VG | ❌ | 🟡 Phase 3 |

## Domain L: Meta / Harness

| Skill | Source | Status | Priority |
|-------|--------|--------|----------|
| **model-prompt-overlays** | VG | ❌ research DONE | 🔴 Phase 2 |
| **persona-system** | VG | ❌ | 🟡 Phase 3 |
| **canonical-skills-repo** | VG | ❌ decision pending | 🔴 blocking |
| **containerized-portability** | VG | ❌ | 🟡 Phase 5 |
| **skill-creator** (meta-skill) | OMX | ❌ | 🟠 Phase 2 |
| **agents-md-lane-contract** | OMX | ❌ | 🔴 Phase 1 |

---

## Build Order (Dependency-Aware)

```
Phase 1 — Standalone, no dependencies:
  ├── L6  agents-md-lane-contract     ← HIGHEST LEVERAGE, pure text
  ├── B3  analyze                     ← read-only, easy port
  ├── A2  code-review                 ← two-lane, uses oracle
  ├── C4  ultraqa                     ← standalone adversarial QA
  ├── G1  vault-health-check          ← smallest conductor piece
  ├── D4  ask                         ← cross-harness second opinion
  └── H2  z800→z600 migration         ← trivial renames

Phase 2 — Needs Phase 1:
  ├── B1  deep-interview              ← uses metis + ambiguity math
  ├── B2  consensus-plan              ← uses prometheus + ADR
  ├── A3  security-review             ← extends A2 pattern
  ├── L1  model-prompt-overlays       ← research done, pure impl
  ├── F1  hook-patterns               ← expand from 1 to N hooks
  └── K1  stt-error-corrector         ← "High priority, develop soon"

Phase 3 — Needs Phase 2:
  ├── C1  ralph                       ← persistence loop
  ├── C2  ultragoal                   ← durable ledger
  ├── E3  auto-dream                  ← consolidation
  └── I1  autoresearch                ← validator-gated

Phase 4 — Needs Phase 3:
  ├── C3  autopilot                   ← full pipeline
  ├── G3  obsidian-conductor          ← multi-agent vault
  └── H1  infrastructure-operator     ← unify z800-* skills
```

## What NOT to Build

| Skip | Why |
|------|-----|
| `prometheus-strict` | OpenCode has the ORIGINAL OMO Prometheus |
| `wiki` | Vault + QMD + OpenMemory is strictly richer |
| `cancel/hud/doctor/omx-setup` | OMX-runtime-specific |
| `imagegen/openai-docs/plugin-creator` | Codex-native |
| `team/worker` (as-is) | Reconcile with Diane, port protocol not skill |

## Structural Gap (Ontology Insight)

The **orchestrate × persistent** quadrant is almost empty. We have agents that observe and modify, but almost nothing that orchestrates over time. Ralph, autopilot, and Obsidian Conductor are the missing keystones.

## See Also

- [[Tool-Ontology-Framework]] — the 12-axis classification system
- [[Claude-Code-Steganography-And-Hidden-Features]] — CC hidden behaviors
- [[Harness-Porting-Strategy]] — detailed porting guide
- [[Skill-Inventory]] — current 978-skill catalog (by ecosystem)
- [[Agent Skills - The Harness Playbook]] — universal principles
