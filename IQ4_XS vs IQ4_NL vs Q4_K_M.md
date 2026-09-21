IQ4_XS vs IQ4_NL vs Q4_K_M ????

we shall only download 1 of then maybe IQ4_XS as is smallest 
---
title: "Hugging Face"
source: "https://huggingface.co/0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored-GGUF"
author:
published:
created: 2026-09-21
description: "We’re on a journey to advance and democratize artificial intelligence through open source and open science."
tags:
  - "clippings"
---
## RVN Qwen3.8-Flash-Next Abliterated Uncensored — GGUF

This repository currently publishes 18 verified quant families as 144 GGUF shards. Five IQ families were produced with the V6 calibration importance matrix; the remaining families are standard core quantizations.

## Scope

- Text/main model only.
- NextN/MTP speculative-draft tensors excluded.
- Vision projector excluded.
- Produced from the verified F16 V6 main checkpoint.
- Files are split below the Hugging Face per-file limit.
- A recent `llama.cpp` build with `qwen4exp` support is required.

## Available quant families

Each family contains eight shards. Sizes below are the exact combined GGUF payload size; runtime memory also depends on context length, KV-cache format, offload configuration, and backend. “Yes” in the importance-matrix column means that `llama-quantize` was invoked with the V6 calibration importance matrix.

| Quant    | Combined size                      | Shards | Importance matrix |
| -------- | ---------------------------------- | ------ | ----------------- |
| `Q2_K`   | 80,447,450,592 bytes (74.92 GiB)   | 8      | No                |
| `IQ3_XS` | 86,027,649,280 bytes (80.12 GiB)   | 8      | **Yes**           |
| `Q3_K_S` | 88,755,339,232 bytes (82.66 GiB)   | 8      | No                |
| `IQ3_S`  | 88,882,766,080 bytes (82.78 GiB)   | 8      | **Yes**           |
| `IQ3_M`  | 89,540,819,200 bytes (83.39 GiB)   | 8      | **Yes**           |
| `Q3_K_M` | 94,137,094,112 bytes (87.67 GiB)   | 8      | No                |
| `Q3_K_L` | 96,656,400,352 bytes (90.02 GiB)   | 8      | No                |
| `IQ4_XS` | 97,473,155,840 bytes (90.78 GiB)   | 8      | **Yes**           |
| `Q4_0`   | 99,959,519,712 bytes (93.09 GiB)   | 8      | No                |
| `IQ4_NL` | 100,079,450,880 bytes (93.21 GiB)  | 8      | **Yes**           |
| `Q4_1`   | 110,973,453,792 bytes (103.35 GiB) | 8      | No                |
| `Q4_K_S` | 111,769,915,872 bytes (104.09 GiB) | 8      | No                |
| `Q4_K_M` | 119,150,723,552 bytes (110.97 GiB) | 8      | No                |
| `Q5_0`   | 121,987,387,872 bytes (113.61 GiB) | 8      | No                |
| `Q5_K_S` | 127,728,766,432 bytes (118.96 GiB) | 8      | No                |
| `Q5_1`   | 133,001,321,952 bytes (123.87 GiB) | 8      | No                |
| `Q5_K_M` | 134,106,668,512 bytes (124.90 GiB) | 8      | No                |
| `Q6_K`   | 167,639,839,712 bytes (156.13 GiB) | 8      | No                |

## Matched Q6\_K benchmark

This is a **quant-matched proxy**, not a BF16-vs-BF16 benchmark:

- Official base: `Qwen/Qwen3.8-Flash-Next-GGUF`, `Q6_K`, revision `158fc825df3eaa6c22d3c57a5927a5adf1c7cda7`.
- RVN: this release’s verified `Q6_K` family.
- Runtime: `llama.cpp` build `10721`, commit `eaf937655`.
- Hardware: 4× NVIDIA RTX PRO 6000 Blackwell Workstation Edition; two GPUs per model, layer split `1/1`, full GPU offload.
- Warm throughput: two role-swapped runs × five repetitions = 10 samples per model; `-fa 1`, `-b 512`, `-ub 512`, 16 CPU threads per model.

### Warm throughput

Values are mean tokens/s ± sample standard deviation.

| Test | Official base Q6\_K | RVN V6 Q6\_K | Mean delta |
| --- | --- | --- | --- |
| `pp512` | 2,810.019 ± 104.550 | 2,810.162 ± 99.701 | +0.005% |
| `tg128` | 111.6978 ± 0.6588 | 118.7456 ± 0.4427 | +6.310% |

Prompt processing was effectively unchanged in this run. RVN decoded 6.31% faster in this runtime, but the benchmark does **not** establish that the model edit caused the difference.

### WikiText-2 perplexity

Full WikiText-2 test corpus: 150 complete 2,048-token chunks, context 2,048, batch/ubatch 512. Lower is better.

| Model | PPL | Reported uncertainty |
| --- | --- | --- |
| Official base Q6\_K | 4.5239 | ±0.02589 |
| RVN V6 Q6\_K | 4.5016 | ±0.02529 |

The absolute V6-minus-base delta was `-0.0223` (`-0.493%`). This is a coarse sanity check against gross language-model damage only. Abliteration damage can appear in instruction following and reasoning without materially changing raw LM perplexity, so this result is **not evidence that capability was preserved**.

### Matched downstream evaluation

The same official-base and RVN V6 `Q6_K` artifacts were evaluated with `lm-eval-harness` `0.4.13` through two local `llama.cpp` build `10721` chat-completion servers. Each model used two RTX PRO 6000 Blackwell GPUs with full offload, layer split `1/1`, four concurrent 4,096-token slots, batch size 1, seed 0, the model chat template, and reasoning disabled. Every reported task used its complete test set; no `--limit` was applied. Values are score ± the harness-reported standard error where available. Delta is V6 minus base in percentage points.

| Task / metric | n | Official base Q6\_K | RVN V6 Q6\_K | Delta |
| --- | --- | --- | --- | --- |
| IFEval prompt-level strict accuracy | 541 | 83.73 ± 1.59 | **84.66 ± 1.55** | **+0.92 pp** |
| IFEval instruction-level strict accuracy | 541 | 88.85 | **89.45** | **+0.60 pp** |
| GSM8K CoT (8-shot), flexible extract | 1,319 | **89.31 ± 0.85** | 88.48 ± 0.88 | **−0.83 pp** |
| GSM8K CoT (8-shot), strict match | 1,319 | **88.10 ± 0.89** | 86.73 ± 0.93 | **−1.36 pp** |
| BBH logical deduction, five objects (0-shot), flexible extract | 250 | 34.00 ± 3.00 | **38.00 ± 3.08** | **+4.00 pp** |

The valid tasks move in both directions: V6 is slightly higher on IFEval and this BBH subset and slightly lower on GSM8K. Each delta is small relative to the reported uncertainty. These results provide a narrower and more relevant check than raw LM perplexity, but they still support only **no gross regression on the tested tasks and configuration**, not universal capability preservation.

`arc_challenge_chat` was also run on all 1,172 examples, but its score is intentionally omitted. With this chat-API/task combination, the filter retained the full generated string (for example, `The best answer is C`) while the target was the single letter (`C`), producing an artifact `0.0` exact-match score for both models. A corrected scorer is required before that task can be interpreted.

### Benchmark limitations

- Four concurrent CPU `llama-quantize` jobs were active during the throughput runs. GPU-pair roles were swapped, but a clean idle-host replication remains pending.
- These measurements compare Q6\_K artifacts only; they are not evidence for BF16 throughput or BF16 perplexity.
- Raw LM perplexity does not measure instruction following or reasoning; the matched downstream results above must be interpreted separately and remain task-bounded.
- Throughput is runtime-, hardware-, offload-, context-, and build-dependent.
- WikiText-2 corpus SHA-256: `d790b833ef8cf03a90db7bf1271b7520b83c45ce07ba3c1a9699df81e239eca0`.
- `llama-bench` binary SHA-256: `cb17fad0f47bf6af15e008a58cae2af5b2fd5733a4cd5f198610a0b1942b32b2`.

## Download

Download one family rather than cloning the entire repository:

```bash
hf download 0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored-GGUF \
  --include "*Q4_K_M*" \
  --local-dir ./RVN-Qwen3.8-Flash-Next-Q4_K_M
```

For split models, load the first shard; `llama.cpp` discovers the remaining shards automatically:

```bash
llama-cli \
  -m RVN-Qwen3.8-Flash-Next-Q4_K_M-00001-of-00008.gguf \
  -ngl 99 -c 8192 --single-turn \
  -p "Explain why the sky appears blue in one concise paragraph."
```

Adjust GPU offload and context settings to the available hardware. The combined file size is not a complete runtime-memory estimate.

## Verification policy

A quant family is published only after all of the following pass:

1. exact eight-shard inventory and byte accounting;
2. GGUF metadata and tensor census;
3. unique tensor-name and expected tensor-count checks;
4. confirmation that no NextN/MTP tensors are present;
5. selected-tensor dequantization and non-finite checks where supported;
6. fresh `llama.cpp` load and deterministic generation canary;
7. SHA-256 inventory for every shard;
8. remote LFS size/hash verification after upload.

Behavioral evaluation, lineage, limitations, and the constrained-surgery methodology are documented on the [parent model card](https://huggingface.co/0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored).

## License

The upstream Qwen Community License 1.0 applies. This card does not replace or modify that license.

Downloads last month

10,213

GGUF

Model size

177B params

Architecture

qwen4exp

Hardware compatibility

[Log In](https://huggingface.co/login?next=https%3A%2F%2Fhuggingface.co%2F0bserverx%2FRVN-Qwen3.8-Flash-Next-Abliterated-Uncensored-GGUF) to add your hardware

2-bit

3-bit

4-bit

5-bit

6-bit

## Model tree for 0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored-GGUF

Base model

[Qwen/Qwen3.8-Flash-Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)

Finetuned

[0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored](https://huggingface.co/0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored)

Quantized

([2](https://huggingface.co/models?other=base_model:quantized:0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored))

this model

## Collection including 0bserverx/RVN-Qwen3.8-Flash-Next-Abliterated-Uncensored-GGUF[GGUF quants of abliterated (uncensored) models for local llama.cpp inference. Curated by 0bserverx. • 4 items • Updated • 2](https://huggingface.co/collections/0bserverx/uncensored-abliterated-gguf-models)