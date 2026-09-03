---
created: 2026-08-26
tags: [ai, chess, alphazero, stockfish, symbolic, connectionist, nnue, emergent-representation]
related: "[[Agent Equation — Harness + Model + The Reunification of AI's Two Camps]], [[Hands-On — Building the Chess Treaty (Practical Roadmap)]]"
---

# Symbolic vs Learned — The Chess Evidence (Stockfish, Leela, AlphaZero)

Companion note to the [[Agent Equation — Harness + Model + The Reunification of AI's Two Camps|Agent Equation]]. Chess is the cleanest natural experiment for that thesis, because both camps built a champion and we watched them converge.

## The two engines

**Classical Stockfish — the symbolic camp, distilled.**
Humans write the rules of the world (trivial for chess: perfect information, exact movegen). Humans hand-craft the evaluation function: material tables, piece-square tables, mobility, king safety, passed pawns — decades of distilled human chess wisdom as numeric heuristics. Then alpha-beta search, the *solving* part. Verdict: this is **programming, not intelligence** — a brilliant trick. Exhaustive search over an encoded world is calculation; the intelligence in it is human, upstream, in the encoding.

**AlphaZero / Leela (LC0) — the learned camp, distilled.**
No opening book, no endgame tables, no human eval terms. A deep network initialized randomly, trained purely by **self-play**: play millions of games against yourself, tune the network on win/loss only. Chess learned in **~9 hours** (from random play,超越 Stockfish-level; Go and shogi with the *same* architecture and zero game-specific knowledge). Nothing about "how a knight moves" or "what a passed pawn is worth" was told to it.

## The three-layer result

### 1. Learning beats encoding (the statistic won the match)
Whatever "understanding chess" is, generating it from the win signal alone outperformed generations of grandmaster-tuned heuristics. Same story as vision/speech: hand features lose to learned features.

### 2. The network re-invents the symbolic layer — but *compiled*
The eerie part: probe AlphaZero's internals and you find **emergent structure that looks exactly like the human symbolic encoding** — piece valuations, mobility, king safety, even human opening theory (it independently arrived at the Ruy Lopez and other mainlines, then progressively abandoned some of them for lines humans undervalued).

But this knowledge exists as **weights, not rules**. It is a symbolic-like representation that:
- no human wrote,
- no human can read or edit,
- cannot be inspected one concept at a time.

**The knowledge got compiled, not authored.** A hand-written eval function is source code; a trained eval network is a binary with no source. The symbolic camp's *artifact* (a world-model made of concepts) re-emerged — in a form the symbolic camp's whole methodology can't touch. You can't debug it, only retrain it.

### 3. The convergence — NNUE: the treaty inside one engine
Modern **Stockfish dropped its handcrafted evaluation entirely** (2020) and adopted **NNUE** — an efficiently-updatable small neural net as the leaf evaluator *inside* the classical alpha-beta search. Meanwhile Leela-style engines wrap their network in a search too (MCTS).

Final architecture of both champions, from opposite origins:

$$\text{engine} = \underbrace{\text{search (symbolic, hand-written)}}_{\text{harness}} + \underbrace{\text{neural evaluation (learned, compiled)}}_{\text{model}}$$

This is the Agent Equation in miniature. The search is the harness: deterministic, inspectable, exact — it grounds the network, extends it, checks it. The network is the model: fluid intuition about position value that no rule list could capture. Neither won; the **interface** won.

## The point for agents

Same shape one level up:
- **Stockfish-classical : AlphaZero :: GOFAI : LLM** — encoded world vs compiled world-model.
- The agent harness (tools, filesystem, verification) plays the role of **search**: it takes the network's fluid intuition and *pushes it against reality*, pruning hallucination the way alpha-beta prunes bad lines.
- The LLM's "knowledge" is the compiled symbolic layer: human-concept-shaped structure (grammar, logic, even code semantics) that emerged from training, unreadable and uneditable at the concept level — which is exactly why agents don't *ask* the model what's true, they **run the code and see**. The loop is the search.

Slogan: **AlphaZero didn't kill the symbolic camp — it absorbed it, compiled it, and handed it back as weights. Agents do the same, and the harness is the search around the network.**
