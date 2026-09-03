---
created: 2026-08-26
tags: [project, chess, alphazero, rl, ml-learning-path, requirements]
related: "[[Symbolic vs Learned — The Chess Evidence (Stockfish, Leela, AlphaZero)]]"
---

# Hands-On — Building the Chess Treaty (Practical Roadmap)

Practical companion to the chess note. Goal: stop theorizing, build both camps ourselves and watch them converge. Priority: **seeing it with my own eyes > strength > elegance.**

## Requirements engineering

### Track A — Symbolic engine (the harness, by hand)
- **Cost:** ~zero. Laptop CPU, C or Python. No dependencies beyond python-chess for validation.
- **Scope:** legal movegen → alpha-beta + quiescence → simple hand-written eval (material + piece-square tables). Target: beats me reliably. That's enough. We are NOT building Stockfish — the point is to *feel* what "encoding the world" means, and to later use it as teacher/opponent/ground-truth verifier.
- **Time:** 2–4 focused days.

### Track B — Learned engine (the model, trained)
Compute reality check:
- Full AlphaZero chess (44M games, 5000 TPU-hours): not for us.
- **Scaled down: one rented GPU is enough.** Rough tiers:
  - Connect-4 / Othello from scratch, pure self-play: **weekend**, single consumer GPU. This is the canonical "AlphaZero in a weekend" project — do this FIRST to learn the whole pipeline end-to-end.
  - 6x6 mini-chess self-play: days, one GPU.
  - 8x8 chess, small resnet (~10 blocks), reduced MCTS simulations: 1–2 weeks of churning on a rented A100/H100 (PrimeIntellect — gpu-deploy skill already exists for exactly this).
- **Data strategy (the shortcut):** stages, replaying history —
  1. **Supervised on Lichess dump** (free): policy = predict human move, value = predict game result. AlphaGo-style bootstrap.
  2. **Distill Stockfish**: train value net on Stockfish/NNUE evals of positions — literally compiling the symbolic engine into weights, in front of us.
  3. **Self-play RL (the Zero step)**: MuZero-style/AlphaZero self-play to surpass the teacher. Watch the emergent eval emerge stage by stage.
- **Software:** Python, PyTorch, python-chess, a vectorized board encoder (AlphaZero's 119-plane encoding from the paper, or simpler), self-play workers (CPU) feeding a trainer (GPU). Existing references below — do not write from scratch blind; port pseudocode, understand each line.

### Track C — Looking inside the compiled model (the payoff for me personally)
- Probe the trained net: linear probes for material/mobility/king-safety; saliency maps over the input planes; watch piece-value structure emerge during training checkpoints.
- This is the "I can't wrap my mind around it" → "I have literally watched it form" step.
- Compare probe findings against the hand-written eval from Track A. Symbolic table vs emergent table, side by side.

## Reading list (papers, in order)

1. **Silver et al. 2016 — Mastering the game of Go with deep neural networks and tree search** (AlphaGo) — the supervised+RL hybrid we're replaying. arXiv:1602.01712
2. **Silver et al. 2017 — Mastering the game of Go without human knowledge** (AlphaGo Zero) — the self-play-only recipe. arXiv:1712.01815
3. **Silver et al. 2018 — A general reinforcement learning algorithm that masters chess, shogi and Go through self-play** (AlphaZero) — the chess encoding (119 planes), MCTS details, pseudocode of the training loop. arXiv:1712.01815 is Go-Zero; AlphaZero is arXiv:1712.01815-v1 → actually **arXiv:1712.01815 = AZ science paper; use 1712.01815 & the Science version**. (Verify IDs when pulling PDFs.)
4. **Schrittwieser et al. 2020 — Mastering Atari, Go, chess and shogi by planning with a learned model** (MuZero) — learned rules too, no more hand-encoded movegen: the model swallows the harness as well. arXiv:1911.08265
5. **Nasu 2018 — Efficiently Updatable Neural-Network Evaluation (NNUE)** — what modern Stockfish actually runs; the small-net-inside-search design we can copy for Track B cheaply. (translate.google the original Japanese shogi paper or read the Stockfish docs)
6. ** DeepMind AlphaZero pseudocode repo**: github.com/deepmind/pseudo-code-for-AlphaZero — the actual loop, ~4 pages.
7. **Leela Chess Zero (lc0)** — github.com/LeelaChessZero/lc0 — full open AZ implementation; read its training docs before writing our own.

Implementation references worth more than most tutorials:
- github.com/Zeta36/chess-alpha-zero (older but readable AZ-chess in TF)
- Kunh Kim's "AlphaZero from scratch" tutorial-style implementations
- Bert Chesson's / other single-file Connect4-AlphaZero repos — weekend target for Track B step 1.

## Session plan (what "going somewhere" looks like)

1. **This week:** Track A engine skeleton (movegen + alpha-beta + dumb eval) — laptop, zero cost.
2. **Same week, parallel:** Connect-4 AlphaZero from an existing repo, run locally CPU/small-GPU just to see the pipeline run once.
3. **Next:** rent PI GPU, 8x8 supervised-on-Lichess run (stage 1), checkpoint probes (Track C).
4. **Then:** turn on self-play. Watch it beat the supervised net. That moment is the whole thesis, experienced.

## Why this matters (vault-context)

The vault was drifting into stories-about-stories. This project anchors the Agent Equation thesis in something runnable: I encode the world (Track A), I compile it (Track B stage 1–2), it outgrows the encoding (stage 3), and I inspect the compilation (Track C). Important for me first; useful to others if it happens to be.
