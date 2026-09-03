---
id: DEC-0002
type: decision
date: 2026-08-26
context: "Tiering layer bootstrap: map roles to cheapest verifiable fuel across 6 live routes."
options: ["all-frontier (zai glm-5.3)", "aggressive-cheap (zen/models-ai everywhere)", "tiered with quality floors + shadow certification"]
decision: "Tier table below + role→minimum-tier map; certification per §4 of the tiering charter (shadow → promote → auto-demote). PROPOSED — human approves production table."
supersedes: null
status: active
summary: T0=zen+models-ai free, T1=opencode-go sub models, T2=zai glm-5.x, T3=zai glm-5.3 (reserved); every route certified by gold evals before promotion.
---

## Tier table (T0–T3)

| Tier | Fuel | Cost | Examples |
|---|---|---|---|
| **T0** | free remote we control/trust | $0 | zen free tier (deepseek-v4-flash-free, nemotron-3.5-lightning-free, mimo-v2.5-free…); models-ai 9B class (omnicoder-9b, qwen3.5-9b-mtp) + embeddings (bge-m3) + STT |
| **T1** | sub-covered mid models | sub caps | opencode-go: deepseek-v4-flash, kimi-k2.6, mimo-v2.5, qwen3.5-plus, glm-5-turbo(via zai) |
| **T2** | strong reasoning | sub/paid | zai glm-5.2 (current default), opencode-go kimi-k3, minimax-m3, qwen3.8-max, deepseek-v4-pro, grok-4.6 |
| **T3** | frontier reserve | paid | zai **glm-5.3**; (opencode-go grok-4.6/gpt-5.6-luna as alternates) — judge of last resort, novel-obfuscation disassembly, contradiction arbitration |

## Role → minimum-tier map (initial hypothesis, to be certified)

| Role | Min tier | First candidate | Rationale |
|---|---|---|---|
| COLLECTOR | T0 | zen/deepseek-v4-flash-free | fetch+file, schema-only output |
| RESEARCHER | T1 | opencode-go/deepseek-v4-flash | long-context sweeps |
| DISASSEMBLER (planner) | T2 | zai/glm-5.2 | coding-capable analysis |
| ANALYST | T2→T3 | zai/glm-5.2, escalate glm-5.3 | cross-examination, grading |
| OPTIMIZER | T3 (initially) | zai/glm-5.3 | runs once/cycle; metric reasoning |
| Judge (shadow evals) | T3 | zai/glm-5.3 | never downgrades |

## Guardrails adopted
- Sensitive steps never downgrade (tester-account runs, credential handling,
  final arbitration).
- Cascade escalation with logged reason codes (schema fail / low confidence).
- Routing mix reported per cycle (drift toward cheap = quality regression).
- Re-certification on schedule and on any model version change; routes are
  claims with last_confirmed, they decay.

## Rationale
Empirical substitution, never aspirational: every route must pass gold evals
built from OUR artifacts (real claim matrices, manifests, experiment reports)
before promotion. First production table goes to the human — no self-approval.
