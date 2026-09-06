---
tags: [notebook, graph, lab, meta, dashboard]
date: 2026-09-03
cssclasses:
  - dashboard-dense
---

# Graph Notebook — Vault as Jupyter Lab

> Every block below is a **live cell** — edit a note, the table re-runs (like Jupyter). `dataview` = code cell, `base` embed = interactive table, `dataviewjs` = live force-graph, `Map.canvas` = figure. Start at the picture, drill with the cells. See [[Map]] · [[Dashboard]] · [[INDEX]] · [[_meta/graph-groups-proposal|graph colors patch]].

## Figure — Curated Story Graph

> Drag nodes, it autosaves. Global Graph = truth, this Canvas = story. The 4 MOCs break the old mega-hub hairball.

![[Map.canvas]]

---

## 0 · Live Force Graph — the actual graph, in the note

*Real D3 physics: every note is a node, every wikilink an edge, rendered live inside this cell. Works offline (D3 v7 vendored at `_meta/vendor/d3.v7.min.js`).*
**One-time human toggle:** Settings → Community plugins → Dataview (gear) → **Enable JavaScript Queries** → ON.


```dataviewjs
// CELL 0 - live vault force-graph (D3 v7, vendored offline)
if (!window.__d3v7) {
  window.eval(await app.vault.adapter.read('_meta/vendor/d3.v7.min.js'));
  window.__d3v7 = window.d3;
}
const d3 = window.__d3v7;

const pages = dv.pages()
  .where(p => !p.file.path.startsWith('_sync/')
           && !p.file.path.startsWith('.obsidian/')
           && p.file.name !== 'LOG.md')
  .array();

const nodes = pages.map(p => ({
  id: p.file.path,
  name: p.file.name,
  folder: p.file.folder || '(root)',
  deg: 0
}));
const byPath = new Map(nodes.map(n => [n.id, n]));

const seen = new Set();
const links = [];
for (const p of pages) {
  for (const l of p.file.outlinks ?? []) {
    const t = l.path;
    if (t === p.file.path || !byPath.has(t)) continue;
    const key = p.file.path + ' -> ' + t;
    if (seen.has(key)) continue;
    seen.add(key);
    links.push({ source: p.file.path, target: t });
    byPath.get(t).deg++;
  }
}

const colorFor = f =>
  f.startsWith('wiki/value')    ? '#4ade80' :
  f.startsWith('quant')         ? '#fb923c' :
  f.startsWith('wiki/research') ? '#60a5fa' :
  f.startsWith('_harness')      ? '#f87171' :
  f.startsWith('inbox')         ? '#9ca3af' :
  f.startsWith('journal')       ? '#a3a3a3' :
  f.startsWith('wiki/concepts') ? '#facc15' :
  f.startsWith('wiki')          ? '#818cf8' :
  f.startsWith('_meta')         ? '#525252' : '#2dd4bf';

const W = dv.container.clientWidth || 900, H = 540;
const svg = d3.select(dv.container).append('svg')
  .attr('viewBox', [0, 0, W, H])
  .style('width', '100%').style('height', H + 'px')
  .style('background', '#0b0e14').style('border-radius', '10px');

const g = svg.append('g');
svg.call(d3.zoom().scaleExtent([0.2, 4]).on('zoom', e => g.attr('transform', e.transform)));

const sim = d3.forceSimulation(nodes)
  .force('link', d3.forceLink(links).id(d => d.id).distance(70).strength(0.3))
  .force('charge', d3.forceManyBody().strength(-120))
  .force('center', d3.forceCenter(W / 2, H / 2))
  .force('collide', d3.forceCollide().radius(d => 7 + Math.sqrt(d.deg) * 2));

const link = g.append('g').selectAll('line').data(links).join('line')
  .attr('stroke', '#334155').attr('stroke-opacity', 0.35);

const node = g.append('g').selectAll('circle').data(nodes).join('circle')
  .attr('r', d => 4 + Math.sqrt(d.deg) * 2)
  .attr('fill', d => colorFor(d.folder))
  .attr('stroke', '#0b0e14')
  .style('cursor', 'pointer');

node.append('title').text(d => d.name + '  [' + d.folder + ']  in:' + d.deg);

node.call(d3.drag()
    .on('start', (e, d) => { if (!e.active) sim.alphaTarget(0.25).restart(); d.fx = d.x; d.fy = d.y; })
    .on('drag',  (e, d) => { d.fx = e.x; d.fy = e.y; })
    .on('end',   (e, d) => { if (!e.active) sim.alphaTarget(0); d.fx = null; d.fy = null; }))
  .on('click', (e, d) => app.workspace.openLinkText(d.id, ''));

sim.on('tick', () => {
  link.attr('x1', d => d.source.x).attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x).attr('y2', d => d.target.y);
  node.attr('cx', d => d.x).attr('cy', d => d.y);
});

dv.paragraph('*drag = pin · scroll = zoom · click = open note · size = in-links · colors = zone (same palette as [[_meta/graph-groups-proposal]])*');
```

---

## 1 · Tag Galaxy — what vocabulary you actually use

*Where the vault's tag taxonomy clusters. Patch `showTags`+`colorGroups` in [[_meta/graph-groups-proposal]] to see these colors on the graph.*

```dataview
TABLE WITHOUT ID tag AS "Tag", length(rows) AS "Notes"
FROM ""
FLATTEN file.tags AS tag
GROUP BY tag
SORT length(rows) DESC
LIMIT 20
```

> Try on graph: filter `tag:#quant`, `tag:#research`, `tag:#harness` — watch the cloud separate.

## 2 · Hubs — what the graph *actually* centers on (proxy centrality)

*Most inlinked = gravity. If [[INDEX]]/`[[Map]]`/`[[Dashboard]]` dominate, the MOCs are working.*

```dataview
TABLE WITHOUT ID file.link AS "Hub", length(file.inlinks) AS "In", length(file.outlinks) AS "Out", file.folder AS "Folder"
FROM ""
SORT length(file.inlinks) DESC
LIMIT 15
```

> Local Graph: open [[MOC-trading]] → Local Graph depth 2 → hubs flip to domain.

## 3 · Orphan Garden — notes with no inlinks (link 3/week)

*Inbox transients + root one-offs live here. Garden into their MOC.*

```dataview
TABLE WITHOUT ID file.link AS "Orphan", file.folder AS "Folder", file.mtime AS "Modified"
FROM ""
WHERE length(file.inlinks) = 0
  AND file.name != "LOG.md"
  AND !contains(string(file.folder), "_sync")
  AND !contains(string(file.folder), ".obsidian")
SORT file.mtime DESC
LIMIT 20
```

**Interactive:** ![[_meta/graph-health.base#InboxTransient]]

## 4 · Stubs — weakly linked (<3 outlinks)

*Your next +2 links ritual. Stubs are graph darkness.*

```dataview
TABLE WITHOUT ID file.link AS "Stub", length(file.outlinks) AS "Out", file.folder AS "Folder", file.mtime AS "Modified"
FROM "wiki" OR "quant" OR "/"
WHERE length(file.outlinks) < 3
SORT length(file.outlinks) ASC
LIMIT 20
```

## 5 · Recent Heat — what's alive

*Live mirror of edits. Use Bases to sort by clicking headers.*

![[_meta/recent-edits.base#Latest]]

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "Folder", file.mtime AS "Modified"
FROM ""
WHERE file.name != "LOG.md" AND file.name != "Dashboard.md"
SORT file.mtime DESC
LIMIT 12
```

## 6 · Domain Lab — MOCs + Quant Canon

*Does the graph cluster into 4 communities yet?*

```dataview
TABLE WITHOUT ID file.link AS "MOC", file.tags AS "Tags", length(file.inlinks) AS "In"
FROM ""
WHERE contains(file.name, "MOC-") OR file.name = "CANON"
SORT length(file.inlinks) DESC
```

![[_meta/graph-health.base#MOCs]]

- Trading: [[MOC-trading]] · [[the-alpha-illusion]] · [[ktd-fin]]
- AI-ML: [[MOC-ai-ml]] · [[SEAL — Self-Adapting Language Models]] · [[Voyager — Open-Ended Embodied Agent]]
- Ledger: [[MOC-ledger]] · [[ledger]] · [[quant-pilot-01-RESULT]]
- Harness: [[MOC-harness]] · [[The Forge Harness — Runbook]] · [[FAILURE-MODES]]
- Canon: [[CANON|quant/CANON]] — Tier 1/2/3 master map

```dataview
TABLE WITHOUT ID file.link AS "Area", length(rows) AS "Notes"
FROM ""
GROUP BY file.folder
SORT length(rows) DESC
LIMIT 15
```

## 7 · Ledger Trail — ideas → evidence → KILL/PROMOTE

```dataview
TABLE WITHOUT ID file.link AS "Row", file.mtime AS "Modified", tags AS "Tags"
FROM "wiki/value"
SORT file.mtime DESC
LIMIT 20
```

![[_meta/recent-edits.base#WikiQuant]]

## 8 · Harness Pulse — is the swarm healthy?

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "_harness" OR "journal"
SORT file.mtime DESC
LIMIT 12
```

![[_meta/recent-edits.base#Harness]]

## 9 · Native Search Cells — try these in the note

*Paste into any note as ` ```query ``` ` — they're the graph's text twin:*

```query
path:wiki/research/trading/
```

```query
tag:#quant -path:inbox
```

```query
-path:_sync -path:.obsidian file:LOG
```

---

## Plugin Lab — the four microscopes (installed 2026-09-03)

*Global Graph = truth · `Map.canvas` = story · Cell 0 = live physics · these four = the microscopes.* **LLM/quota audit of all four:** [[graph-stack-llm-surfaces]].

### InfraNodus AI Graph View (`infranodus-graph-view` v0.10.0)

- **Reveals:** communities + **structural gaps** — pairs of clusters that are never linked. The "what am I blind to" tool.
- **Run:** Command palette → `InfraNodus` → open its Graph View → build from vault → check the **Gaps** panel.
- **Vault ritual:** weekly. Expect a gap between the `trading` and `harness` clusters → bridge it with one note (e.g. a harness note applying [[the-alpha-illusion]]'s P-checklist to worker evals).

### Knowledge Graph Analysis (`knowledge-graph-analysis` v0.6.7)

- **Reveals:** ranked *hidden* connections — Co-Citations (notes cited together), Co-Tags, Link Prediction (Adamic-Adar / Common Neighbours). The best "what should I link next" list in the vault.
- **Run:** Command palette → `Graph Analysis` → open the analysis pane → pick algorithm → scope to `wiki/research` or a MOC.
- **Vault ritual:** feed the Orphan Garden (Cell 3) — run Adamic-Adar, add the top-3 suggested links, watch Cell 0 re-cluster.

### Juggl (`juggl` v1.5.0)

- **Reveals:** styled local graphs in a pane — per-note neighborhood with colors/icons, its own physics; works without the JS toggle.
- **Run:** open a MOC ([[MOC-trading]] · [[MOC-ledger]] · [[MOC-ai-ml]] · [[MOC-harness]]) → palette → `Juggl: Open local graph of current note`.

### ExcaliBrain (`excalibrain` v0.2.18 + Excalidraw v2.26.4)

- **Reveals:** hierarchical parent/child/friend map built from links — the vault's org-chart view.
- **Run:** open [[quant/CANON]] or any MOC → palette → `ExcaliBrain: Start ExcaliBrain` (or the brain ribbon icon).

### The loop (all five surfaces, one habit)

1. **See** — Cell 0 (or global graph `No-noise` filter)
2. **Find the gap** — InfraNodus Gaps panel
3. **Find the link** — Graph Analysis (Adamic-Adar / Co-Citations)
4. **Garden** — add `[[MOC-*]]` + 2 links to an orphan (Cell 3)
5. **Confirm** — re-render Cell 0; the gap should shrink

---

## How to use this like Jupyter

1. **Top → bottom**: Figure → Galaxy → Hubs → Garden. That's one sweep.
2. **Fork a cell**: copy a `dataview` block into a new note, change `FROM "wiki/value"` to `FROM "quant/strategies"` — new experiment.
3. **Garden weekly**: pick 3 Orphans → add `[[MOC-trading]]`/`[[MOC-ledger]]` etc + 2 related links. Watch the graph re-cluster next open.
4. **Color the graph**: apply [[_meta/graph-groups-proposal]] — then re-run Tag Galaxy and see colors match.
5. **Save filters as workspaces**: Global Graph search → `No-noise`: `-path:_sync/* -path:.obsidian/* -file:LOG.md -path:inbox/*` ; `Live-only`: `path:wiki/* OR path:quant/*`

> Want more cells? Duplicate **Stubs/Orphans** but swap `file.folder` or `tag`. Bases YAML is in `_meta/graph-health.base` and `_meta/recent-edits.base` — add a view there, embed it here with `![[path.base#View]]`.

## Related

- [[_meta/graph-health-queries.md|More health queries (Dataview)]] — hub/stub/unresolved cells
- [[_meta/graph-groups-proposal|ColorGroups staged patch]] — human applies
- [[Map]] · [[INDEX]] · [[Dashboard]] · [[Sessions]] · [[Value]] · [[Triage]]
