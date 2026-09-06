---
tags: [research, graph, plugins, llm, agentic-control, lab]
date: 2026-09-06
status: living — evidence from plugin binary inspection 2026-09-06
related:
  - "[[Graph-Notebook]]"
  - "[[_meta/graph-groups-proposal]]"
  - "[[Map]]"
  - "[[OS]]"
---

# Graph Stack — LLM Surfaces & Agentic Control Map

> Which graph plugin can call which AI, where vault data actually flows, and where *we* hold the wheel. Receipts = greps against `.obsidian/plugins/*/main.js` (2026-09-06; read-only zone, never edited). Vault size at audit: **422 md notes** (179 in `wiki/`).

## Control map (the one table)

| Surface | Engine | Compute location | LLM surface | Who controls the model |
|---|---|---|---|---|
| Native graph + ColorGroups | Obsidian core | local | none | — |
| Cell 0 D3 force-graph ([[Graph-Notebook]]) | D3 v7 (vendored) | local | **arbitrary** — `dataviewjs` can `fetch()` any endpoint | **US — fully** (local LiteLLM gateway → POP fleet) |
| Juggl 1.5.0 | Cytoscape | local | none (its only "Gemini" hit = zodiac icon `mdiZodiacGemini`) | — |
| ExcaliBrain 0.2.18 | custom, on Dataview index | local | none | — |
| Knowledge Graph Analysis 0.6.7 | WASM graph algorithms (local) | metrics local; **AI insights → Google** | **Gemini only**, hardcoded endpoint | Google (patchable, see §2) |
| InfraNodus AI Graph View 0.10.0 | server-side text-mining | **cloud** (graph.infranodus.com) | server-side AI models, list fetched dynamically | InfraNodus cloud (self-host = us) |

**Verdict:** two of the six surfaces phone home, and in both cases the model choice is locked away from us by default. The surface we fully own is the `dataviewjs` cell — and that's the one to build agentic graph features on.

## 1 · Knowledge Graph Analysis — the "Gemini lmao" one

**Split architecture (good design, wrong vendor lock):**
- Graph algorithms (Co-Citations, Co-Tags, Link Prediction — Adamic-Adar / Common Neighbours) run **locally in WASM** (`wasmHash` in `data.json`; metrics + cache stay on disk). This part is excellent and needs no AI at all.
- "AI insights" = optional layer. Plugin's own privacy note (found in `main.js`, originally Chinese, translated): *"The plugin uses your API key to send note content and analysis prompts to the Google Gemini API (generativelanguage.googleapis.com). No data is sent at plugin load. Graph metrics and cache are stored locally."*
- Provider dropdown has exactly one value: `apiProvider: "Google Gemini"`. No OpenAI/Anthropic/Ollama strings anywhere in the binary.
- Models: `gemini-3-flash-preview`, `gemini-3.1-flash-lite-preview`. Client-side throttling built in ("Gemini 3 Flash: RPM 5 → 12s between requests", "Flash Lite RPM 10").
- Endpoint is a hardcoded const: `GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta"` → `${BASE}/models/${model}:generateContent?key=${apiKey}`.

**Control levers:**
1. **Use it AI-off** — the link-prediction algorithms are the real value and are local. Simply don't set an API key. (Current `data.json`: key absent, `totalFiles: 0` — never configured yet.)
2. **Patch the endpoint** — `main.js` is plain bundled JS; `sed` the `GEMINI_API_BASE` const to a local shim that translates `generateContent` → OpenAI format → our LiteLLM gateway → POP fleet. Caveat: **plugin updates overwrite `main.js`** — keep the patch as a script (proposed: `_harness/gemini-shim.sh`).
3. **Hygiene:** the key lands plaintext in `.obsidian/plugins/knowledge-graph-analysis/data.json` → per the secrets rule it belongs in Vaultwarden and only gets injected at use time, never stored. Note `.obsidian/` is git-synced territory-adjacent — never let the key live there permanently.

## 2 · InfraNodus — the "too many notes" one

**Root cause of the block (exact strings from `main.js`):**
- `"…files). Free tier limit: ~500 notes per day. Continue the remaining {{remaining}}…"`
- `"You've used all your free InfraNodus trial quota"` / `"You've used up all your InfraNodus API quota"`

The vault is 422 notes — **one full-vault push eats ~85% of a day's quota**, so the second sync hits the wall. That's the "too many notes" message.

**Architecture:** unlike everything else here, InfraNodus does text-mining/topic-modeling/gap-detection **server-side** (API key + `InfraNodus API URL` settings; default `https://graph.infranodus.com`). The "AI model" dropdown isn't a plugin feature — the model list is fetched from their server (`fetchAiModels()`), i.e. their cloud decides which models exist.

**Control levers:**
1. **Scope, don't sync-all** — use its per-folder/multi-page processing to push one MOC at a time (e.g. `wiki/research/trading/` ≈ 30 notes) inside the 500/day budget. Gap detection works fine on a subgraph.
2. **Quota resets daily** — treat it as a weekly 500-note budget, not a blocker.
3. **Self-host (full control):** InfraNodus server is AGPL open source (Nodus Labs). Developer-mode setting exposes `INFRANODUS_API_URL` → point the plugin at a self-hosted instance (natural home: an LXC on the darknet pattern). Kills the quota AND moves the AI-model choice to our config. Candidate for a small experiment container.
4. **Data flow caution:** any text pushed there lives on their cloud — don't export the whole vault including `wiki/value/` economics until self-hosted.

## 3 · The surface we own — dataviewjs + local gateway

The D3 Cell 0 pattern already proves it: vendored lib, vault data via `dv.pages()`, no cloud. The same cell can do agentic work under **our** control:

```js
// sketch — Cell 0 + local LLM (LiteLLM gateway on POP cluster)
const r = await fetch('http://<gateway>:4000/v1/chat/completions', {
  method: 'POST',
  headers: {'Authorization': 'Bearer ' + await app.vault.adapter.read('.gemini-key-ish-path'), 'Content-Type': 'application/json'},
  body: JSON.stringify({model: 'local-model', messages: [
    {role: 'system', content: 'Suggest 3 wikilinks between these orphan note titles and hub titles. JSON only.'},
    {role: 'user', content: JSON.stringify({orphans, hubs})}
  ]})
});
```

That replaces KGA's Gemini insights and InfraNodus's cloud GPT with the POP fleet — model choice, cost, privacy all ours. Key stays out of notes (adapter read of an ignored path or injected at runtime).

**Candidate LLM-powered cells (the "better views / work the data" backlog):**
- **Link-suggester cell** — orphan/stub list + top hubs → local model proposes links → human clicks to apply (audit trail in LOG).
- **Gap-narrator cell** — cluster labels from Juggl/KGA stats → model names each community + states the two least-connected clusters (local version of InfraNodus gaps).
- **Dendron-mode arc diagram** — D3 arc instead of force: same edge data, readable at 400+ nodes (force hairballs top out ~150).
- **Graph diff cell** — compare link structure snapshots (`_harness/` already logs graph stats?): what got connected/abandoned this week.

## 4 · Better-view recipes that need no LLM at all

- **Juggl styleGroups** (its `data.json` already has 28 tag-based style groups from a previous life — prune to vault zones): `tag:#quant` → orange, `tag:#research` → blue; per-MOC local graphs become the "domain microscope".
- **ExcaliBrain** for hierarchy (parent/child/friend) — it's the org-chart complement to force-graph geography.
- **Bases embeds** (`_meta/graph-health.base`) for sortable/filterable node tables — the "spreadsheet twin" of the graph.
- D3 forks of Cell 0: swap layout (radial tree by folder, matrix for density), keep the vendored-libs + click-to-open pattern.

## 5 · Agentic policy (what runs where) — proposed

1. **Local-first:** graph algorithms via KGA-WASM / D3 cells. Zero egress.
2. **LLM on graph data → local gateway only** (POP fleet through LiteLLM). No third-party AI keys in plugin configs.
3. **Cloud AI = sandboxed scopes:** InfraNodus only on explicit folder scopes, never full-vault; KGA Gemini layer stays disabled unless a patched shim exists.
4. **Keys never persist in `.obsidian/`** — Vaultwarden + runtime injection.

## Next experiments (queue)

> Promoted to full architecture: [[agentic-graph-brain]] — v1 jobs live in `_harness/queue.md`.

- [ ] `gemini-shim.sh` — patch KGA `main.js` GEMINI_API_BASE → local translating proxy; verify against POP gateway (rollback: reinstall plugin).
- [ ] InfraNodus scoped export: `wiki/research/trading/` only → confirm subgraph gap detection within free quota.
- [ ] Link-suggester dataviewjs cell prototype in [[Graph-Notebook]] against local gateway.
- [ ] Self-host InfraNodus evaluation (LXC sizing, AGPL ok, AI model config).

## Evidence log

- `grep -c gemini knowledge-graph-analysis/main.js` → 51 hits; models + RPM strings extracted.
- `GEMINI_API_BASE` const + `generateContent?key=` call found in same bundle.
- InfraNodus quota strings + `fetchAiModels()` + `INFRANODUS_API_URL` developer-mode found in bundle.
- `grep -c gemini juggl/main.js` → 1 hit = `mdiZodiacGemini` (Material Design icon path — astrology, not AI).
- `data.json` states: KGA `apiProvider: "Google Gemini"`, `totalFiles: 0` (never run); Juggl 28 tag style groups, `limit: 10000`.
- Note count: `find … -name '*.md' … | wc -l` → 422.
