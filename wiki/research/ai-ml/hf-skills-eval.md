---
tags: [research, ai-ml, tooling, skills, validation, smith]
date: 2026-07-21
source: huggingface/skills bucket (manifest v1.0.17) via hf CLI 1.22.0
status: installed + smoke-tested 2026-07-21 — datasets & hf-mem verified working; local-models discovery verified, serve pending `sudo apt install llama.cpp`; community-evals deferred
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[HARVEST-STATUS]]"
  - "[[Sources — Curated Seed Library]]"
---

# HF Skills — Eval/Local Quartet Evaluation

> **What it gives the harness:** the quartet is the toolkit for the Forge's **validation gate** — the "promote only on measured improvement" discipline SkillOpt/Smith needs ([[Daily Cron Sessions — Swarm Harness Master Plan]] §2a, §7.4, open decision §9 "benchmark per skill candidate"). Read together they form one cheap-local pipeline: *pick a model that fits → get the eval data → serve the model locally → score it*. Verdict: **install the cheap three, defer community-evals.** Nothing installed yet — this is the recommendation.

## Method (test, don't wonder)
- `hf` CLI is present at `~/.local/bin/hf` (v1.22.0) but **not on PATH**; marketplace is the Hub bucket `huggingface/skills` (manifest v1.0.17, 25 plugins). All four quartet skills exist there.
- Read each skill's actual `SKILL.md` (+ scripts/references) straight from the bucket — read-only, no install into any assistant.
- Probed **this box** (the Kali Lenovo): **CPU-only** (no `nvidia-smi`/`rocm-smi`), **30 GiB RAM** (27 avail) + 5.7 GiB swap, **Intel i5-6200U** (2 physical / 4 logical cores, 2015 Skylake, x86_64). **No `uv`, no llama.cpp, `HF_TOKEN` unset.** The hardware reality drives every verdict below.

## The quartet as one pipeline

| Stage | Skill | Role in cheap local validation |
|---|---|---|
| 1. Pre-flight | `hf-mem` | "Will the validator/judge model fit in 30 GB?" — answered with **zero download** |
| 2. Data | `huggingface-datasets` | Source eval/validation rows + stats **without pulling full datasets** |
| 3. Serve | `huggingface-local-models` | Run the model **locally at ~$0** (CPU GGUF) — the "local" leg |
| 4. Score | `huggingface-community-evals` | Produce the actual **eval scores** (inspect-ai / lighteval) the gate reads |

## Per-skill verdicts

### hf-mem — ★★★ RECOMMEND (install first)
Estimates inference memory (weights + optional KV cache) for Safetensors/GGUF **via HTTP Range requests — no download, no load**. Zero hardware barrier; the only dep is `uv`/`uvx` (not installed, one-line fix). On a RAM-constrained-for-big-models box this is the ideal **pre-flight gate**: before committing bandwidth/disk to a judge model, confirm it fits. Highest value-per-cost of the four here.
- Needs: `uv` (install). No GPU, no token for public models.

### huggingface-datasets — ★★★ RECOMMEND (install first)
Read-only Dataset Viewer API over plain `curl`/HTTP: `/splits`, `/first-rows`, `/rows` (paginate ≤100), `/search`, `/filter`, `/parquet`, `/size`, `/statistics`. **Zero hardware barrier** — the cheapest of the four. Two concrete uses for us:
1. **Source validation data** (e.g. peek mmlu/gsm8k rows + column stats) to build Smith's held-out sets without downloading whole datasets.
2. **Bonus — solves an open question:** its "Agent Traces" section documents that Claude Code transcripts live at `~/.claude/projects`, and gives a *private*-repo upload pattern. That is exactly the Distiller session-capture source the Master Plan §9 leaves open. (Note its own warning: traces can contain secrets/PII → keep private; aligns with our "no secret patterns to any provider" rule.)
- Needs: nothing for public reads; `HF_TOKEN` only for gated/private.

### huggingface-local-models — ★★☆ RECOMMEND WITH CAVEATS (build llama.cpp first)
The "local" leg: find GGUF repos (`apps=llama.cpp`), pick a quant (default `Q4_K_M`), serve with `llama-cli`/`llama-server` (OpenAI-compatible), CPU build via `make LLAMA_OPENBLAS=1`, `-t` = **physical** cores. This directly realizes Master Plan §7.7 ("low-stakes roles → local model → ~$0"). **But** the bottleneck on this box is CPU, not RAM: 30 GB holds large weights fine, yet 2 physical 2015 cores make anything beyond a small quant (≤3B `Q4_K_M`) crawl. Realistic use: a **small local judge/embedder** for low-stakes scoring, not big-model inference.
- Needs: build/install llama.cpp (absent). Set expectations to small models.

### huggingface-community-evals — ★☆☆ DEFER (do not install yet)
The eval harness that emits the scores the gate reads (inspect-ai / lighteval; smoke-test with `--limit`/`--max-samples`; backend fallback vLLM→Transformers/accelerate). Conceptually the most on-mission skill — **but its fast paths assume hardware we lack:**
- **vLLM / local-GPU path: dead here** (no GPU).
- **Provider path** (`scripts/inspect_eval_uv.py`) targets `hf-inference-providers/<model>` — that is **remote API inference, not local**: needs `HF_TOKEN` + network and spends provider quota, contradicting "local + cheap."
- **Truly-local CPU path** (Transformers/`accelerate`) works but is limited to tiny smoke tests; the skill's own hardware table puts `<3B` on "consumer GPU / Apple Silicon / small dev GPU" — this i5 sits below that.
- **Verdict:** mine the *pattern* (smoke-test-then-scale, backend-fallback ladder) now; install later, when either (a) `HF_TOKEN` is provisioned and provider-backed evals are wanted, or (b) a GPU box is in play.

## Recommendation (bounded)
1. **Install the cheap three** — `hf-mem`, `huggingface-datasets`, `huggingface-local-models` — as the local validation pipeline (pre-flight → data → serve). They have no hard GPU dependency and map 1:1 onto the validation-gate need.
2. **Defer `huggingface-community-evals`** until a token or GPU exists; meanwhile adopt its smoke-test + backend-fallback pattern by hand.
3. **Prereqs a future session/human must clear first** (none done here — task was recommend-only): install `uv`; build llama.cpp (`LLAMA_OPENBLAS=1`, `-t 2`); provision `HF_TOKEN` if gated data or the provider eval path is wanted.

```bash
# install commands for the approving session (NOT run now)
hf skills add hf-mem --claude
hf skills add huggingface-datasets --claude
hf skills add huggingface-local-models --claude
# hf skills add huggingface-community-evals --claude   # deferred
```

## Provenance
- `huggingface/skills` bucket, manifest v1.0.17 — `skills/{hf-mem,huggingface-datasets,huggingface-local-models,huggingface-community-evals}/SKILL.md` read in full; `community-evals/scripts/inspect_eval_uv.py` + `examples/USAGE_EXAMPLES.md`; `local-models/references/hardware.md`.
- Hardware probe of the Kali Lenovo, 2026-07-21 (CPU-only / 30 GiB / i5-6200U / no uv / no llama.cpp / no HF_TOKEN).

## Smoke-test results — installed & verified (2026-07-21, Smith cron worker)

> **Status update:** the cheap three are now **installed** (symlinked `.claude/skills/` → `.agents/skills/`, manifest v1.0.17) and each was smoke-tested with one minimal call on this CPU-only box. `community-evals` stays deferred per the verdict above. Prereq `uv` was installed this session; `HF_TOKEN` still unset; llama.cpp still absent (see below).

| Skill | Verdict | Minimal call | Measured result |
|---|---|---|---|
| `huggingface-datasets` | ✅ WORKS | `curl '…/is-valid?dataset=stanfordnlp/imdb'` + `/splits` | Valid JSON, zero deps. `/is-valid`→`{"preview":true,"viewer":true,"search":true,"filter":true,"statistics":true}`; `/splits`→train/test/unsupervised |
| `hf-mem` | ✅ WORKS (after installing `uv`) | `uvx hf-mem --model-id Qwen/Qwen2.5-0.5B --json-output` | `{"memory":988065536,…}` ≈ **942 MiB** weights, via HTTP Range, **zero download** |
| `huggingface-local-models` | ⚠️ PARTIAL — discovery works, serve blocked | Hub search + tree API | Discovery ✅; serve needs llama.cpp (absent) |

### Evidence / how

**uv installed this session** (hf-mem's only dep): `curl -LsSf https://astral.sh/uv/install.sh | sh` → `uv 0.11.30` at `~/.local/bin/{uv,uvx}`. One-line fix, as predicted.

**hf-mem gotcha (verified):** gated models 401 without a token — `google/embeddinggemma-300m` (the SKILL.md's own example) returned `401 Unauthorized`. Use a non-gated public model for tokenless pre-flight, or set `HF_TOKEN`. Confirms the eval's "HF_TOKEN only for gated/private."

**huggingface-datasets:** read-only Dataset Viewer works out of the box; confirms the "peek rows/stats without downloading whole datasets" use. (Agent-Traces upload path still needs `HF_TOKEN` + a private repo — not tested, stays deferred.)

**huggingface-local-models — discovery verified, serve blocked on one root step:**
- ✅ Search: `curl 'https://huggingface.co/api/models?filter=llama.cpp&sort=likes&limit=3'` → 3 GGUF repos. (Note: `sort=trending` is web-UI-only; the API rejects it — use `sort=likes`/`downloads`.)
- ✅ Exact-filename tree API: `curl 'https://huggingface.co/api/models/Qwen/Qwen2.5-0.5B-Instruct-GGUF/tree/main?recursive=true'` → 9 quants incl. the default `q4_k_m` (491 MB). Field is `path`, not `rfilename`.
- ❌ Serve (`llama-cli`/`llama-server`): **blocked — llama.cpp not installed, and a non-root cron worker can't install it interactively.**
  - **New, easier prereq (vs the source build assumed above):** llama.cpp is **packaged in Kali apt** — `sudo apt install llama.cpp` pulls `llama.cpp-tools` (llama-cli/llama-server/llama-quantize) + `libllama0`/`libggml0`. Candidate `9721+dfsg-1` (confirmed via `apt-get install -s`). A one-line **human/root** action, not a compile.
  - Source build is the fallback but heavier: modern llama.cpp is **CMake-only** (the old `make LLAMA_OPENBLAS=1` path above is gone); `cmake` absent here (pip-installable), OpenBLAS absent, 2-core compile slow.
  - **Next action (human):** `sudo apt install llama.cpp`, then serve smoke test = `llama-server -hf Qwen/Qwen2.5-0.5B-Instruct-GGUF:q4_k_m` + the `/v1/chat/completions` curl from the SKILL.md. 30 GB RAM holds the 491 MB quant trivially; CPU throughput is the only caveat (small model keeps it usable).

### Bottom line
Two of three (datasets, hf-mem) are **verified working now** with zero/one trivial dep. The third (local-models) is verified through discovery; its serve leg needs a single `sudo apt install llama.cpp` a non-root cron worker can't perform — **flagged for the human**. `community-evals` stays deferred.
