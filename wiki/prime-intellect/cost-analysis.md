---
title: Prime Intellect — Cost Analysis (serverless vs pods vs training)
date: 2026-09-03
tags: [prime-intellect, costs, serverless, pods, billing, upb]
sources:
  - /tmp/opencode/prime-models.json
  - /tmp/opencode/prime-gpus.json
  - /tmp/opencode/prime-avail.json
  - /tmp/opencode/prime-gpu-summary.json
  - /tmp/opencode/prime-wallet.json
  - /tmp/opencode/prime-openapi.json
---

# Prime Intellect — Cost Analysis

> Snapshot 2026-09-03. Auth by env ref `$PRIME_INTELLECT_API_KEY` only (no keys in vault).
> Related: [[Universal Provider Bridge — Project Master Map]] · [[Claude Code Routes — upb CLI Decision & Runbook]] · [[Claude Code Proxy Pattern — Master Reference]]

## 1. Serverless — $/1M tokens in/out (118 models)

118 serverless models. Family breakdown (case-normalized):

| family | count |
|---|---|
| openai | 26 |
| qwen | 25 |
| anthropic | 12 |
| z-ai | 10 |
| deepseek | 9 |
| google | 9 |
| moonshotai | 5 |
| meta-llama | 4 |
| mistralai | 4 |
| minimax | 3 |
| x-ai | 3 |
| nvidia | 2 |
| poolside | 2 |
| xiaomi | 2 |
| meta | 1 |
| zai-org | 1 |
| **total** | **118** |

Priced `input_usd_per_mtok / output_usd_per_mtok`:

| model                                          | $/1M in | $/1M out | $/1M+1M | $/turn (50k in + 5k out) |
| ---------------------------------------------- | ------- | -------- | ------- | ------------------------ |
| meta-llama/Llama-3.2-1B-Instruct (cheapest in) | 0.027   | 0.201    | 0.228   | 0.0024                   |
| Qwen/Qwen3.5-0.8B (cheapest out)               | 0.04    | 0.08     | 0.12    | 0.0024                   |
| qwen/qwen3.7-flash                             | 0.03    | 0.13     | 0.16    | 0.0022                   |
| google/gemma-3-27b-it (27B cheap)              | 0.119   | 0.30     | 0.419   | 0.0075                   |
| qwen/qwen3.6-27b (27B ref)                     | 0.60    | 3.60     | 4.20    | 0.0480                   |
| z-ai/glm-4.7-flash (harness cheap)             | 0.07    | 0.40     | 0.47    | 0.0055                   |
| deepseek/deepseek-v3.2 (harness)               | 0.3705  | 1.1115   | 1.482   | 0.0241                   |
| moonshotai/kimi-k2-0905 (harness)              | 0.60    | 2.50     | 3.10    | 0.0425                   |
| qwen/qwen3-coder-next (harness coder)          | 0.30    | 1.50     | 1.80    | 0.0225                   |
| anthropic/claude-opus-4.1                      | 15.0    | 75.0     | 90.0    | 1.125                    |
| openai/gpt-5.4-pro (most expensive)            | 30.0    | 180.0    | 210.0   | 2.40                     |

Math: `turn = 0.05*in + 0.005*out`. Example qwen3.6-27b: `0.05*0.60 + 0.005*3.60 = 0.03 + 0.018 = $0.048/turn`; `1M+1M = 0.60+3.60 = $4.20`. Cheapest turn ~$0.0022 (qwen3.7-flash); dearest ~$2.40 (gpt-5.4-pro) — ~1000x span.

## 2. Pods — $/GPU-hour vs serverless

Visible offers to this key (`prime-gpus.json` / `prime-avail.json`, 14 rows):

| offer                               | $/hr on-demand          | 27B fit                                  |
| ----------------------------------- | ----------------------- | ---------------------------------------- |
| H200 141GB 1x (nebius eu-north1)    | 4.50                    | yes — fits 27B BF16 (~54GB weights + KV) |
| A100 40GB 1x (lambdalabs us-east-1) | 1.99                    | no — too small for BF16 27B              |
| A10 24GB 1x (lambdalabs us-east-1)  | 1.29                    | Q4 only (~16GB quant + overhead)         |
| H100 / B200                         | not visible to this key | public refs ~$2.43 / ~$0.94 spot         |

Throughput (realistic vLLM single-stream): H100-class ~60 tok/s = 216k tok/hr; 4090-class ~30 tok/s = 108k tok/hr.

Effective $/1M per pod = `hourly / (toks_per_hr / 1M)`:

| pod | @216k/hr | @108k/hr |
|---|---|---|
| H200 $4.50 | $20.83/M | $41.67/M |
| A100 $1.99 | $9.21/M | $18.43/M |
| A10 $1.29 | $5.97/M | $11.94/M |

Break-even vs qwen3.6-27b serverless blended: **$1.35/M @3:1** (`0.75*0.60+0.25*3.60`), **$2.10/M @1:1** (`0.5*0.60+0.5*3.60`). Pod effective $9–42/M is **~5x (or more)** the blended $1.35–2.10 unless the pod is saturated 24/7 and output-heavy on spot. Bursty single-stream harness traffic never saturates 108–216k/hr.

Billing: pods billed hourly, deducted per-minute.

## 3. Blocks / runs — training + wallet source of truth

- Serverless: billed per-1M-tokens (in/out split above).
- Pods/compute: billed hourly, deducted per-minute.
- Training (RFT): billed per-MTok triple via `GET /api/v1/billing/runs/{run_id}/usage` — `training_per_mtok + inference_input_per_mtok + inference_output_per_mtok` snapshot (`RunPricing`), totals in `training {tokens, cost_usd}` + `inference {input_tokens, output_tokens, cost_usd}`.
- Storage rows: `disks / sandboxes / images / traces` bill to same table.
- Source of truth: `GET /api/v1/billing/wallet` — same `Billing` table the dashboard Billing History tab reads; `resource_type` in {`compute, training, inference, traces, disks, sandboxes, images`}. OpenAPI surface: 97 paths.

Current wallet snapshot (`prime-wallet.json`, 2026-08-27 billings):

- balance **$10.7227**, 23 rows total
- inference **$0.1311** over 11 rows
- compute **$9.1444** over 8 rows
- disks **$0.0018** over 4 rows

## 4. Recommendation

Bursty harness work = **serverless via [[Universal Provider Bridge — Project Master Map|UPB]]** (`upb run` / `upb env` routes; key by `$PRIME_INTELLECT_API_KEY` ref). Default to `gemma-3-27b-it` / `glm-4.7-flash` class for cheap loops, `qwen3.6-27b` / `kimi-k2` / `deepseek-v3.2` when quality matters.

Pods only if **>6–11M tok/day sustained** single-model saturation justifies the hourly burn ($30.96/day A10, $47.76/day A100, $108/day H200) — otherwise the ~5x premium over serverless blended ($1.35–2.10/M) never pays back.
