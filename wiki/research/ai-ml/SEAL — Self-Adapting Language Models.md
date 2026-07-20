---
tags: [research, ai-ml, self-improving-agents, source-clip]
date: 2026-07-20
source: arXiv:2506.10943
authors: [Adam Zweiger, Jyothish Pari, Han Guo, Ekin Akyürek, Yoon Kim, Pulkit Agrawal]
affiliation: MIT
status: clipped — id verified 2026-07-20
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Voyager — Open-Ended Embodied Agent]]"
  - "[[Reflexion — Verbal Reinforcement Learning]]"
  - "[[ADAS — Automated Design of Agentic Systems]]"
---

# SEAL — Self-Adapting Language Models

> **What it gives the harness:** the purest "learning-to-learn" reference — *generate an adaptation → measure downstream performance → keep it if better*. We can't fine-tune closed models, but that exact loop is SkillOpt-in-text.

## The mechanism
- Given new input/objectives, the model writes its own **self-edit**: reorganize facts, set tuning settings, or call tools.
- Those edits become **persistent weight updates** via supervised fine-tuning on the model's own generated content.
- An **RL loop** rewards the *downstream performance of the updated model*, so SEAL learns to produce more useful adaptation instructions over time.
- Evaluated on knowledge incorporation + few-shot generalization; gains are durable, not per-prompt.

## Why it matters to the Forge
SEAL is the weight-space ideal we approximate in text-space. Our loop — session produces an artifact/skill → validation-score delta → promote if better — is the same generate→measure→keep shape, minus the gradient. The verdict: **the pattern is transferable; the weight update is not.** Treat SEAL as the north star for [[Sources — Curated Seed Library]] §A, realized concretely via the Smith (SkillOpt).

## Verdict
★★★ — foundational reference. No action item beyond anchoring the generate→measure→keep loop as the harness's core rhythm.
