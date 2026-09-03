---
title: "Tool Ontology Framework — 12 Structural Axes for Classifying Agent Tools"
created: 2026-07-21
tags:
  - ontology
  - harness-engineering
  - tool-design
  - agent-architecture
type: framework
confidence: established
sources:
  - MCP spec (4-hint risk vocabulary, 2025-11-25)
  - Claude Code v2.1.88 source analysis (7 implicit axes)
  - OpenAI function calling taxonomy
  - Anthropic tool reference (server vs client)
  - CrewAI BaseTool (result_as_answer, max_usage_count)
  - AutoGen Workbench pattern
  - ToolBench/ToolLLM (ICLR 2024)
  - "Evolution of Tool Use" survey (arXiv:2603.22862, 2026)
  - "Agentic AI Architectures" survey (arXiv:2601.12560, 2026)
last_updated: 2026-07-21
---

# Tool Ontology Framework

> No existing framework has a complete ontology. MCP comes closest with 4 boolean hints. Claude Code has 7 implicit axes. This synthesizes all sources into 12 structural axes.

## Why This Matters

Our 978 skills ([[Skill-Inventory]]) are categorized by **ecosystem/ownership** (source, codex reference, hermes bundled, opencode active). That tells you WHERE a skill lives, not WHAT it IS. This ontology classifies by **structural nature** — what a tool fundamentally does, how it behaves, what risks it carries.

Related: [[Agent Skills - The Harness Playbook]], [[agentic-harness-ontology]]

---

## The 12 Axes

### 1. Effect (What Kind of Action)

| Value | Definition | Example |
|-------|-----------|---------|
| `observe` | Reads state, produces knowledge | grep, Read, web search |
| `decide` | Evaluates options, produces judgment | plan review, risk scoring |
| `modify` | Changes state, produces artifacts | Edit, Write, git commit |
| `orchestrate` | Coordinates other tools/agents | Agent spawn, team dispatch |

> Source: Claude Code plan mode (read-only restriction), MCP primitives (Tools vs Resources vs Prompts)

### 2. Mutability (Side-Effect Profile)

| Value | Definition | MCP Hint |
|-------|-----------|----------|
| `read-only` | No environment modification | `readOnlyHint: true` |
| `additive` | Modifies environment, only adds | `destructiveHint: false` |
| `destructive` | Irreversible modification/deletion | `destructiveHint: true` |

> **Industry consensus** — strongest axis. MCP defaults are deliberately pessimistic: no annotations = assume destructive.

### 3. Reversibility

| Value | Definition | Confirmation |
|-------|-----------|-------------|
| `reversible` | Can be undone (edit files, run tests) | Freely allowed |
| `hard-to-reverse` | Technically undoable but painful (force-push, amend published commits) | Confirm |
| `irreversible` | Permanent (DROP TABLE, rm -rf, delete branch) | Confirm or block |

> Source: Claude Code system prompt Section 4 "Executing Actions with Care"

### 4. Blast Radius

| Value | Definition | Example |
|-------|-----------|---------|
| `local` | Affects only local filesystem | Edit a file |
| `shared` | Affects shared systems | Push to git, modify CI/CD |
| `external` | Affects external services | API calls, webhooks |
| `visible-to-others` | Creates artifacts others see | PRs, issues, messages |

> Source: Claude Code system prompt. Determines risk level independently of mutability.

### 5. Temporality

| Value | Definition | Example |
|-------|-----------|---------|
| `instant` | One-shot, no state | grep, read file |
| `session-scoped` | Lives within a session | plan, code review |
| `persistent` | Survives across sessions | memory write, goal ledger |
| `continuous` | Always-on, reactive | hooks, monitoring, auto-dream |

> **Novel axis** — not formalized in any framework. Critical for state management design.

### 6. Composition

| Value | Definition | ToolBench |
|-------|-----------|-----------|
| `atomic` | Single operation | Read, Grep |
| `composite` | Multi-step, single domain | code review pipeline |
| `orchestrating` | Multi-step, cross-domain, stateful | autopilot, ralph |

> Source: ToolBench I1/I2/I3 complexity levels, AutoGen Workbench pattern

### 7. Autonomy

| Value | Definition | Example |
|-------|-----------|---------|
| `self-contained` | No human needed | Read, Grep |
| `needs-confirmation` | Human approves before execution | Write, Bash (dangerous) |
| `needs-human` | Human provides input during execution | AskUserQuestion, elicitation |

> Source: OpenAI `tool_choice`, Claude Code permission modes (bypass/auto/default/plan)

### 8. Epistemic Nature (NOVEL — gap in literature)

| Value | Definition | Verification Strategy |
|-------|-----------|----------------------|
| `produces-knowledge` | Output is information/analysis | Cross-reference, confidence scoring |
| `produces-artifacts` | Output is a created/modified artifact | Tests, lint, typecheck |
| `produces-side-effects` | Output is a state change in the world | Rollback plan, monitoring |

> No existing framework classifies tools by what they **produce epistemically**. This determines how you verify the output.

### 9. Scope

| Value | Definition | Example |
|-------|-----------|---------|
| `file` | Single file | Edit, Read |
| `module` | Module/package | refactoring skill |
| `project` | Whole project | code review, deslop |
| `system` | Infrastructure/system | Proxmox, Docker |
| `cross-system` | Multiple systems | Diane orchestration |

> Source: MCP scope (user/project/local/dynamic), Claude Code memory hierarchy

### 10. Lifecycle

| Value | Definition | Example |
|-------|-----------|---------|
| `one-shot` | Run once, done | file read, search |
| `iterative` | Repeat until condition met | ralph, ultraqa |
| `continuous` | Never stops, reactive | hooks, monitoring |
| `reactive` | Fires on events | PostToolUse hooks, file watchers |

> Source: OMX ralph/autopilot loops, Claude Code hook system (25+ event types)

### 11. Trust Boundary

| Value | Definition | Risk |
|-------|-----------|------|
| `closed-world` | Operates within bounded domain | Low injection risk |
| `open-world` | Interacts with external unpredictable entities | Prompt injection risk |

> Source: MCP `openWorldHint` (default: true). Unique to MCP. Maps to injection risk.

### 12. Idempotency

| Value | Definition | Retry Safety |
|-------|-----------|-------------|
| `idempotent` | Same args → same effect | Safe to retry |
| `non-idempotent` | Repeated calls cause additional effects | Must track execution |

> Source: MCP `idempotentHint` (default: false). OpenAI: "Make function calls idempotent when possible."

---

## Framework Comparison

| Axis | MCP | Claude Code | OpenAI | Anthropic | CrewAI | AutoGen | Academic |
|------|-----|------------|--------|-----------|--------|---------|----------|
| Mutability | ✅ 4 hints | ✅ riskLevel | implicit | implicit | — | — | — |
| Reversibility | — | ✅ system prompt | — | — | — | — | — |
| Blast radius | — | ✅ system prompt | — | — | — | — | — |
| Execution location | — | ✅ access tiers | ✅ built-in vs fn | ✅ primary axis | — | — | — |
| Invocation mode | — | — | ✅ allowed_callers | — | — | — | — |
| Autonomy | — | ✅ permission modes | ✅ tool_choice | ✅ tool_choice | — | — | — |
| Synchronicity | — | ✅ streaming executor | — | — | ✅ _run/_arun | ✅ StreamTool | — |
| Composition | — | — | — | — | — | ✅ Workbench | ✅ ToolBench |
| Schema strictness | — | — | ✅ strict | ✅ strict | — | — | — |
| Trust level | ✅ annotations | — | — | — | — | — | — |
| Lifecycle | — | ✅ hooks/cron | — | — | ✅ max_usage | ✅ Workbench | — |
| Epistemic nature | — | — | — | — | — | — | — |

**Key finding**: No framework uses more than 5 of these 12 axes. The complete ontology is unclaimed territory.

---

## Application: Classifying Our Skills

Use this ontology to classify any skill:

```yaml
# Example: ai-deslop
effect: modify
mutability: destructive  # removes code
reversibility: reversible  # git checkout restores
blast_radius: local
temporality: session-scoped
composition: composite  # multi-pass workflow
autonomy: needs-confirmation  # asks before bulk removal
epistemic: produces-artifacts
scope: project
lifecycle: one-shot
trust_boundary: closed-world
idempotency: idempotent  # running twice on clean code = no-op
```

---

## Insights

1. **Mutability trichotomy is the strongest consensus** — MCP, OpenAI, Anthropic all converge on read-only / additive / destructive
2. **Execution location is the most architecturally significant** — determines who drives the agentic loop
3. **Epistemic nature is the unclaimed axis** — no framework classifies tools by what they produce (knowledge vs artifacts vs side-effects)
4. **Temporality is the practical axis** — determines state management needs, the biggest engineering challenge
5. **MCP's pessimistic defaults are correct** — assume destructive, non-idempotent, open-world until proven otherwise
6. **Palantir's insight**: make ontology action-oriented (what can you DO) not descriptive (what IS it)

## See Also

- [[Skill-Candidate-Map-2026-07]] — 60+ skills classified by this ontology
- [[Claude-Code-Steganography-And-Hidden-Features]] — Claude Code's covert harness behaviors
- [[Agent Skills - The Harness Playbook]] — universal harness principles
- [[Harness-Porting-Strategy]] — OMX → OpenCode porting priorities
