---
created: 2026-08-26
tags: [ai, agents, history, philosophy, harness, symbolic, connectionist]
---

# Agent Equation — Harness + Model + The Reunification of AI's Two Camps

## The equation

$$\text{Agent} = \text{Harness} + \text{Model} + \text{Context} + \text{Loop}$$

- **Harness** — the deterministic body: tools, shell, file system, permissions, memory, skills. Traditional *software*, through and through.
- **Model** — the statistical mind: a neural network, pure learned probability over tokens.
- **Context** — the model pointed at *someone's* world (memories, vault, projects, preferences). The equation is really `Agent = Harness + Model + *you*`.
- **Loop** — the recursion: act → observe → revise. Neither part alone is an agent; the agent *is* the feedback cycle between them, and the other endpoint of that cycle is a human.

## The historical punchline

The two terms of the equation are the two camps that split at the **birth of AI (~1956, Dartmouth)**:

| Camp | Origin | The term it maps to |
|---|---|---|
| **Symbolic AI** (GOFAI) — logic, rules, programs, LISP, expert systems | Simon, Newell, McCarthy, Minsky | the **Harness** |
| **Connectionism / statistical ML** — neural nets, learning from data | Rosenblatt's perceptron → backprop → deep learning → LLMs | the **Model** |

For ~60 years these were rivals. Symbolic AI ruled until the 80s ("machines that think by rules"). Connectionism was mocked (Minsky vs. perceptrons), revived in the 80s, crushed again, then won everything after 2012. The whole history of the field is these two camps trading the throne.

**The modern agent is the treaty.** An agent like Claude Code is literally:

- a **computer program in the classical, 1956 sense** — the harness: deterministic, inspectable, hand-written code that reads files, runs processes, enforces rules; plus
- a **learned statistical representation** — the model: no rules written by hand, just compressed probability learned from data;

…fused by a loop where each covers the other's weakness. The program gives the network *grounding* (real filesystem, real consequences, real state it can't hallucinate around). The network gives the program *judgment* (what to do in the unbounded messiness the rules can't enumerate).

Symbolic systems were brittle because the world doesn't fit in rules. Statistical systems are fluid but ungrounded — they hallucinate because nothing pushes back. **The agent loop is the push-back.** Deterministic code checks the dreamer's work at every step.

## Why this matters

- What the pioneers wanted in 1956 — "making machines use language, form abstractions, solve problems" — didn't come from either camp winning. It came from the *interface* between them.
- Programming didn't die with LLMs; it moved up a layer. The harness is still programming — it's just now written *around* a learned component instead of containing all the intelligence itself.
- Restated as a slogan: **the agent is a program whose if-statements are a neural network.**
