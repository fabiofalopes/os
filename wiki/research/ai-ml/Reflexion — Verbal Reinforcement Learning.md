---
tags: [research, ai-ml, self-improving-agents, memory, source-clip]
date: 2026-07-20
source: arXiv:2303.11366
authors: [Noah Shinn, Federico Cassano, Edward Berman, Ashwin Gopinath, Karthik Narasimhan, Shunyu Yao]
status: clipped — id verified 2026-07-20 (was to-verify)
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[SEAL — Self-Adapting Language Models]]"
  - "[[Voyager — Open-Ended Embodied Agent]]"
---

# Reflexion — Verbal Reinforcement Learning

> **What it gives the harness:** cheap self-improvement we can run *today* — verbal self-reflection stored in memory improves the next attempt, with **no weight change**. This is the mechanism behind session-digest → next-session recall.

## The mechanism
- Agent attempts a task, receives scalar or textual feedback.
- It generates a **verbal self-reflection** (a self-critique of what went wrong).
- Reflections are stored in an **episodic memory buffer** and condition subsequent trials.
- No gradient updates — improvement comes purely from conditioning on accumulated lessons.
- Reported gains across decision-making, coding, and reasoning (strong HumanEval results).

## Why it matters to the Forge
Reflexion is the cheapest rung on the self-improvement ladder and the one we can execute immediately: the Forge's `journal/sessions/` digests + `MEMORY.md` *are* an episodic memory buffer. The transferable discipline: **after a failed or partial attempt, write the lesson as a reflection the next session will read** — not just a status line. This is how "sessions on sessions" compounds without any fine-tuning.

## Verdict
★★☆ — immediately actionable. Action: standardize a one-line "lesson/reflection" field in session digests so failures convert into retrievable memory, not just logged outcomes.
