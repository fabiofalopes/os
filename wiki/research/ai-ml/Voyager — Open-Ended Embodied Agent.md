---
tags: [research, ai-ml, self-improving-agents, skill-library, source-clip]
date: 2026-07-20
source: arXiv:2305.16291
authors: [Guanzhi Wang, Yuqi Xie, Yunfan Jiang, Ajay Mandlekar, Chaowei Xiao, Yuke Zhu, Linxi Fan, Anima Anandkumar]
status: clipped — id verified 2026-07-20 (was to-verify)
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[SEAL — Self-Adapting Language Models]]"
  - "[[Skills Harvest — What's Here & What To Do Differently]]"
---

# Voyager — Open-Ended Embodied Agent

> **What it gives the harness:** the blueprint for "agent builds its own growing skill library" — auto-curriculum + executable skill library + iterative prompting with environment feedback. This is the design our `.forge/skills/` growth loop should copy.

## The mechanism
Three components, no weight updates (queries GPT-4 as a black box):
1. **Automatic curriculum** — the agent proposes its own next exploration goal (open-ended, self-directed).
2. **Skill library** — successful behaviors are stored as *executable code*, indexed for later retrieval and reuse.
3. **Iterative prompting** — programs are refined using environment feedback, execution errors, and self-verification until the task passes.

Skills compound: routines learned early are retrieved and composed into later, harder tasks.

## Why it matters to the Forge
Voyager is the closest published analogue to what the Forge is doing in text: a growing, retrievable library of proven capabilities driven by a self-set curriculum. Two concrete transfers:
- **Skills as code/artifacts with a retrieval key**, not prose — mirrors our `SKILL.md` + progressive-disclosure format.
- **Self-verification gate before storing** — matches our Critic/validation-score promotion gate. Nothing enters the library unproven.

## Verdict
★★★ — direct design reference for the skill-accumulation loop. Action: when the Smith promotes skills, structure them as retrievable, composable units (Voyager-style), not flat notes.
