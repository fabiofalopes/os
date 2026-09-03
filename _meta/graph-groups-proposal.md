---
tags: [meta, graph, proposal, z2-draft]
date: 2026-09-03
status: staged — human applies to .obsidian/graph.json
---

# Graph colorGroups + filter proposal (STAGED — do not auto-apply)

> Agents never edit `.obsidian/` (human-only per [[AGENTS]]). This file stages the exact patch. Human: Settings → Graph → Groups → copy, or paste the JSON block into `.obsidian/graph.json` `colorGroups` and restart Obsidian.

## Why

Current `.obsidian/graph.json` has `colorGroups: []`, `showTags: false`, `showArrow: false`. Every node is grey, no communities. Vault already has a clean tag taxonomy (`value, quant, research, harness, infra, concept, dashboard`) — use it for color.

## Patch: `colorGroups` (copy-paste)

```json
"colorGroups": [
  { "query": "tag:#value", "color": "#4ade80" },
  { "query": "tag:#quant", "color": "#fb923c" },
  { "query": "tag:#research", "color": "#60a5fa" },
  { "query": "tag:#harness", "color": "#f87171" },
  { "query": "tag:#infra", "color": "#c084fc" },
  { "query": "tag:#concept", "color": "#facc15" },
  { "query": "tag:#dashboard OR tag:#map", "color": "#2dd4bf" },
  { "query": "path:inbox", "color": "#9ca3af" },
  { "query": "path:_harness", "color": "#ef4444" },
  { "query": "path:_sync", "color": "#525252" }
],
"showTags": true,
"showArrow": true,
"hideUnresolved": true,
"showOrphans": true
```

Manual steps (2 min):
1. Backup: `cp .obsidian/graph.json /tmp/graph.json.bak`
2. Open `.obsidian/graph.json`, replace `"colorGroups": []` with block above, set the 4 flags as above.
3. Obsidian → Settings → Graph → confirm 10 groups listed → toggle one off/on to force repaint.
4. Global graph search bar — save these two filters as workspaces (no plugin):
   - `No-noise`: `-path:_sync/* -path:.obsidian/* -file:LOG.md -path:inbox/*`
   - `Live-only`: `path:wiki/* OR path:quant/*`

## Local-graph presets (per MOC)

For any MOC (`MOC-trading`, `MOC-ai-ml`, `MOC-ledger`, `MOC-harness`, `quant/CANON`): open note → Local Graph → Depth 2 → Show Tags on → Show Arrows on → Link distance 250. This is the revealing view; global graph is the truth view.

## Rollback

Restore `/tmp/graph.json.bak` to `.obsidian/graph.json` and restart. No note content is touched by this patch.

## Related

- [[Map]] · [[INDEX]] · [[Dashboard]]
- New MOCs: [[MOC-trading]] · [[MOC-ai-ml]] · [[MOC-ledger]] · [[MOC-harness]]
- Curated: [[Map.canvas]] · health: [[_meta/graph-health.base]]
