---
tags: [concept, routines, research, agents, terminal, leak, execution]
date: 2026-09-06
status: ROUTINES v1 — execution doc (design freeze respected)
related:
  - "[[multi-vault-agentic-workloads]]"
  - "[[agentic-graph-brain]]"
  - "[[Breaking Claude — The Landscape 2026 (Research Synthesis)]]"
  - "[[graph-stack-llm-surfaces]]"
---

# Vault-Embedded Research Routines — v1

> Como correr agents no terminal com o vault como harness, e as rotinas locais de pesquisa (explorar · web search · papers · deep research). Direto: tudo abaixo já existe como código ou skill; nada é teoria.

## O modelo (do leak, confirmado)

**Agent = Model × Harness** ([[Breaking Claude — The Landscape 2026 (Research Synthesis)]]). O harness é a variável ownable — e o postmortem de Abril provou que detalhes do harness degradam inteligência medida (verbosity prompt → −3%). Consequências práticas:
1. **O vault é o harness** — queue, LOG, INDEX, gate.sh, ledgers, MOCs, breakers, memory layers. Os agents no terminal (pi / opencode / claude) são **motores permutáveis**; nada de estado importante vive neles.
2. **Prompts mínimos e precisos** — o harness pode piorar o agent (caso −3%); cada instrução extra é risco mensurável.
3. **Tools permissionadas + subagents para fan-out + skills para progressive disclosure** — padrões do leak (`research/claude-code-original/docs/{tools,subsystems,architecture}.md` — minerar lá quando preciso).
4. **Determinístico primeiro, LLM depois** — scripts $0 fazem o fetch/parse; o modelo só entra na destilação.

## As rotinas (todas testadas 2026-09-06)

| Rotina | Comando | Estado |
|---|---|---|
| **explorar** (local) | skill `universal-finder` (rg + QMD + OpenMemory + Proxmox); grafo: `edges.json` quando [Smith] correr | existe |
| **web search** | `bash _harness/research/websearch.sh "q" --n 6` — DDG html (POST; lite está 202-blocked) + GitHub API (stars/push) | **novo, testado** |
| **papers** | `bash _harness/research/papers.sh "q" --n 5 [--json out]` — arXiv (https! http falha) + Crossref (DOIs), keyless | **novo, testado** |
| **ler página** | skill `defuddle` (markdown limpo de qualquer URL) | existe |
| **deep research** | o loop abaixo, como job [Scout] na queue | job em fila |

## Deep research — o loop (bounded, com receipts)

```
pergunta (da queue/Sources/MOC gap)
→ websearch.sh + papers.sh (N fontes, keyless)
→ defuddle nas top-urls → staging/
→ gate.sh no staging (scan + inj-heuristics + ledger)
→ agent destila (gateway local quando Lusófona/SearxNG voltarem): 1 nota wiki/research/ com receipts + veredicto ★
→ INDEX row + LOG line + feed do grafo
STOP: 1 nota por job, máx 8 fontes, veredicto obrigatório ou nota não entra
```

Regra do contrato: research é attempt-triggered — a pergunta vem da queue ou de um gap real, nunca do calendário.

## Leads achados já no smoke-test (para o Scout)

- `green-dalii/obsidian-llm-wiki` (★574, push hoje) — LLM Wiki do Karpathy como plugin Obsidian: notas+PDFs → linked LLM knowledge. Relevante para [[graph-stack-llm-surfaces]].
- `sturlese/hippocampus` (★28) — "lite personal brain: Obsidian to browse, Claude Code for everything else, no vector DB" — mesma tese da nossa inversão.
- `junhewk/simple-graph-builder` (★10) — graph builder via LLM entity extraction (comparar com KGA).

## Gaps (marcados, não escondidos)

- SearxNG local não está deployed (`~/mcp-servers/simple-searxng` é wrapper à espera de instância) — DDG html chega para v0.
- LLM lane down (Lusófona 503) — distillation espera gateway; fetch/parse/gate funcionam já.
- DDG html pode bloquear IPs de datacenter em volume → quando escalar, SearxNG próprio.
