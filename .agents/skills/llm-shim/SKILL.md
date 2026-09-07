---
name: llm-shim
description: Make plugin/vendor-locked LLM surfaces run OUR models — gemini-shim (:8706) translates Gemini generateContent to OpenAI against our router (:8705 → POP fleet); includes the staged KGA patch. Triggers on 'plugin only has gemini', 'point KGA at our models', 'gemini shim', 'hardcoded API endpoint', 'use local models in plugin'.
---

The "boom" integration: any Gemini-hardcoded plugin (Knowledge Graph Analysis is the live case) can run against our gateway without touching its logic — we own the endpoint it calls.

## When to use

- A plugin's AI layer is locked to a vendor endpoint you don't control
- User wants plugin AI features on local/own models (privacy, cost, model choice)
- Before/after a plugin update (patches get overwritten)

## Components

```bash
python3 _harness/shim/gemini_shim.py        # :8706; env: SHIM_PORT, SHIM_MODEL (default amalia-9b), SHIM_UPSTREAM (:8705)
bash _harness/shim/kga-patch.sh status      # show KGA endpoint + backup + shim running?
bash _harness/shim/kga-patch.sh apply       # sed GEMINI_API_BASE → http://127.0.0.1:8706/v1beta (backs up main.js)
bash _harness/shim/kga-patch.sh revert      # restore from backup
```

## Facts & guards

- **`.obsidian/` is human territory** — the patch is staged for the human to apply; agents never edit it directly.
- Shim accepts and ignores `?key=` — no vendor key needed; nothing leaves the box.
- Translation proven with a mock upstream (Gemini-format in → Gemini-format out, via OpenAI mid-hop).
- Pre-conditions: router :8705 healthy + shim running (consider a systemd unit). KGA works fine UNPATCHED — its graph algorithms are local; the patch only affects the optional AI-insights layer.
- Same pattern generalizes: write a shim per API dialect (Gemini/OpenAI/Anthropic) → one gateway, N plugins.
- Default policy meanwhile: plugins AI-off (see `wiki/research/ai-ml/graph-stack-llm-surfaces.md`).
