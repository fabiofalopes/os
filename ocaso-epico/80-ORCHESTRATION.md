---
tags: [project, foundry, orchestration, tmux, harness, z2-draft]
date: 2026-09-12
status: LIVE — stage viva; capacidades documentadas; bloqueios registados
related: "[[70-LOOP]]", "[[50-HARNESS]]", "[[20-CONTENT-ONTOLOGY]]"
---

# Orquestração — stage tmux `foundry`

> A resposta ao pedido "várias sessões pi em paralelo, janela 1 = orquestrador":
> hipervisor tmux à Diane OS, com o human gate intacto.

## Layout (sessão tmux `foundry`)

| Janela | Papel | O quê |
|---|---|---|
| `orchestrator` | orquestrador | pi interativo (muse) com contrato `dispatch/ORCHESTRATOR-CONTRACT.md` — vigia workers, re-fire ≤3, sintetiza GATE-REPORT, PARA |
| `R1-lei24` `R2-comparado` `R3-tabaco` | workers | one-shot `pi -p` (≤900s), cada dono de 1 artifact em `artifacts/` |
| `gate` | status board | `watch` sobre `dispatch/foundry-status.sh` |

Workspace: `~/diane-os/workspaces/ocaso-foundry/` (dimensions/ dispatch/ artifacts/ logs/).
Esta sessão supervisora (Claude/muse) verifica com `tmux capture-pane` + `logs/*.state`.

## Lições de capacidade (2026-09-12, a queniana)

1. **Quota free é account-wide**: orchestrator + workers + delegates partilham
   o mesmo pool muse → 3 paralelos = 429 imediato. **Emenda ao contrato: um
   worker de cada vez.**
2. **tmux server env ≠ shell env**: workers herdam o env do SERVIDOR tmux;
   `OPENCODE_API_KEY` faltava → fix: `dispatch/env.sh` (600) sourced pelos
   dispatch scripts.
3. **pi ↔ POP gateway**: provider `lusofona-gateway` (`:8705`, ornith-9b/amalia-9b)
   já no pi `models.json` (backup `models.json.bak-*`) — pronto quando a frota
   voltar (estava 503).
4. **Web hostil é real**: DDG 202, Bing SERP vazia, Internet Archive offline,
   DRE = SPA JS-only. Rotas de receipts sobreviventes: browser humano (CDP),
   `gesetze-im-internet.de` (funcionou!), `legislation.mt`/`aruc.mt` (funcionaram).

## Resultados do primeiro ciclo

- ✅ R2 (comparado): 9 receipts verificadas (KCanG §§3/9/11/16/19 + ARUC/MT) →
  2 posts P4 prontos para gate (thread DE + Malta one-liner).
- ⛔ R1 (Art. 24.º): TO-VERIFY — Q2-5 permanece bloqueado.
- ⛔ R3 (tabaco PT): BLOCKED — sem receipts não há espelho estatal.
- `artifacts/GATE-REPORT.md` = o gate de hoje.

## Runbook de retoma

```bash
# ver o estado
bash ~/diane-os/workspaces/ocaso-foundry/dispatch/foundry-status.sh
# anexar ao hipervisor
tmux attach -t foundry   # (.detach: C-b d)
# novo ciclo de research (quando quota/frota viva): re-fire manual por worker,
# OU pedir ao orchestrator: "refaz o ciclo com os dimensions/"
# derretedura total (rollback):
tmux kill-session -t foundry && rm -rf ~/diane-os/workspaces/ocaso-foundry
```

## Não resolvido

- Forge cron (CAPPED 114/90, 0% success) — sem jobs foundry até health verde.
- Browser workspace dedicado ao agente (dívida #3 do [[50-HARNESS]]).
- Credentials da conta em Vaultwarden (dívida #4 do [[50-HARNESS]]).
