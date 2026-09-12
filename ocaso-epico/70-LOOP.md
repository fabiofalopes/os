---
tags: [project, foundry, x-twitter, loop, pipeline]
date: 2026-09-12
status: LIVE — v1, first iteration run 2026-09-12
related: "[[20-CONTENT-ONTOLOGY]]", "[[30-SOURCES]]", "[[40-EXPERIMENT]]"
---

# The Pre-Stage Loop — content factory protocol

> O loop que corre DENTRO do vault. Produz combustível e candidatos a post.
> Nada disto posta nada — o human gate é a única saída para o X.

## Fases (uma iteração completa)

| Fase | O que faz | Escreve em |
|------|-----------|-----------|
| 1 · RESEARCH | `research-routines` → novas receipts | `30-SOURCES` (append-only) |
| 2 · DEEPEN | expande conhecimento por pilar — notas vivas, cada vez mais fundas | `knowledge/P*.md` |
| 3 · IDEATE | ≥ 10 ideias novas, baratas, taggadas | `ideas/IDEAS.md` (append-only) |
| 4 · STRUCTURE | 2–3 ideias melhores → posts completos com receipts | `bucket/QUEUE.md` (status: staged) |
| 5 · SIMULATE | proposta de agenda ("se eu decidisse sozinho, postava X na hora Y porque…") | `bucket/QUEUE.md` § SIMULATION |

## Regras

1. **Receipts ou nada**: post staged sem receipt mapeada fica `blocked:needs-receipts`.
2. **Ideias são baratas, posts são caros** — o bucket só recebe o que sobrevive ao filtro.
3. **Interaction lock aplicado sempre** — o loop nunca gera respostas/replies/DMs.
4. **Uma iteração = uma sessão de trabalho** (agora manual; futuro: papel cron no Forge).
5. Deepen ≠ repetir: cada passada numa nota de conhecimento tem de acrescentar camada
   (nova receipt, novo ângulo, contra-argumento), não parafrasear.
6. A simulação mostra raciocínio, não só output: porque este post, porque esta hora,
   porque esta sequência.

## Estado do conteúdo

- `60-DRAFTS-2026-09-12.md` — fila #1 já human-gated (2✅ 3✅ 4✅-reworked) — pronta a postar
- `bucket/QUEUE.md` — ronda 2+ (staged, ainda não gated)
- `ideas/IDEAS.md` — reservatório cru
