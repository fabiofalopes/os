---
id: CTX-fuel
type: context
date: 2026-08-26
summary: Servable-model inventory (live-probed 2026-08-26): 6 live routes, ~180 models, CPU-only local hardware.
---

# Fuel inventory — what we can actually serve

All via upb (control plane, ours). Health-probed live this session.

## Routes / providers

| Route | Cost | Key models | Notes |
|---|---|---|---|
| **models-ai** (modelos.ai.ulusofona.pt) | free (Lusófona) | ornith-9b, omnicoder-9b, qwen3.5-9b-mtp, amalia-9b, stt-large-v3-turbo, bge-m3, nomic-embed-text | our-instance endpoint; 80ms health; chat + embeddings + STT; the "own infrastructure" lane |
| **zen** | free tier | deepseek-v4-flash-free, x-preview-f-free, muse-spark-1.2-free, mimo-v2.5-free, hy3-free, nemotron-3-ultra-free, nemotron-3.5-lightning-free, laguna-s-2.1-free | keyless free; good COLLECTOR/T0 candidates |
| **opencode-go** | $10/mo sub — caps $12/5h, $30/wk, $60/mo | minimax-m3, kimi-k3, kimi-k2.7-code, longcat-2.0, glm-5.x, deepseek-v4-pro/flash, qwen3.7/3.8-max, mimo-v2.x, hy3, gpt-5.6-luna, grok-4.5/4.6, muse-spark-1.2, ox-alpha-free | broadest catalog; metered by sub caps — natural T1/T2 |
| **zai** | coding plan PAID ~1yr | glm-4.5→5.3 incl. glm-5-turbo, air | default route; glm-5.3 = strongest we hold; anthropic-native |
| **prime-intellect** | metered (never default) | 117 models incl. own-deploy | burst/deploy lane; gpu-deploy skill wraps it |
| **pi-own** | GPU rental $0.54/hr A6000-class | any GGUF we stage (qwen3.6-27b staged; Q4 doctrine) | T0 when serving; offline when down (now: down) |
| alibaba | expired 2026-08-20 | qwen3.8-max-preview etc. | auto-hidden; renew to reactivate |

## Local hardware (Kali laptop server)
- 4 vCPU, 30 GB RAM, **no GPU**, 26 GB disk free.
- Verdict: CPU-only → on-device LLM serving is NOT viable for loop roles.
  T0 = models-ai + zen (free remote we control/trust), not local silicon.
- Staged artifacts: `~/Models/qwen3.6-27b-fable-mtp-iq4_xs.gguf` (deploy-ready),
  llama-cuda build tarball — both for pi-own deploys only.

## Constraints
- opencode-go weekly cap $30 is the scarce shared budget — batch jobs must
  respect headroom (C-metric "expansion number").
- prime-intellect metered: only via explicit gpu-deploy or burst decisions.
- zai coding plan: generous, paid, default — but single-provider risk.
