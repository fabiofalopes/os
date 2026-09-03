# Modelos.ai Custom Endpoint

## What
Custom OpenAI-compatible API endpoint managed externally (Lusofona POP Cluster), connected from this Kali host.

**Base URL:** `https://modelos.ai.ulusofona.pt`
**Auth:** API key managed in `.openclaude-profile.json`
**Profile:** `openai` (OpenAI-compatible)

## Available Models

| Model ID | Notes |
|---|---|
| `agentic-192-txt` | Text-only, 192K context |
| `agentic-128-vision` | Vision/multimodal, 128K context |
| `harmonic-hermes-9b` | Currently active in openclaude |
| `qwen3.5-9b-glm51-distill` | Qwen 3.5 distilled via GLM 5.1 |

**Owned by:** Lusofona POP Cluster

## Honest Assessment

The models on this endpoint are **not great**. They're small, local/cluster-hosted models — fine for basic tasks but nowhere near the quality of frontier models (Claude, GPT-4, etc.). Treat this as a free-tier convenience, not a primary workhorse.

## How It Connects

- OpenClaude reads the provider config from `~/.openclaude-profile.json`
- Uses OpenAI-compatible format (`/v1/chat/completions`, `/v1/models`)
- API key: `sk-wNLb8wi_...4DJA` (don't rotate without updating profile)
- This host (Kali ARM64) is where this session runs and where the connection originates

## When to Use

- Quick tests where model quality doesn't matter
- Exploring what the endpoint offers
- Fallback when primary providers are down

## When NOT to Use

- Serious coding work (use zai-coding-plan GLM-5.2+ instead)
- Security analysis or red team ops
- Anything requiring high-quality reasoning

---
*Created: 2026-06-19*
