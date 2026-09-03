---
title: Claude Code Routes — Freebuff2API via upb Integration Plan
date: 2026-09-03
tags: [infra, upb, freebuff, runbook, plan]
---

# Claude Code Routes — Freebuff2API via upb Integration Plan

> Chain `Claude Code -> upb :8705 -> Freebuff2API :8080 -> Freebuff`. No client rewrite, provider becomes config.
> Related: [[Claude Code Routes — upb CLI Decision & Runbook]] · [[Claude Code Proxy Pattern — Master Reference]] · [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]]

## Decision

1. **Don't fork Freebuff2API** — use `Quorinex/Freebuff2API` as-is (OpenAI-compatible `/v1/*`, token rotation, stealth fingerprints). Source: https://github.com/Quorinex/Freebuff2API
2. **Add one `routes.yaml` entry** — `kind: upb`, `catalog: live`, `key: none`, `base_url: http://127.0.0.1:8080/v1`. upb discovers models from `:8080/v1/models` at runtime, same as `zen` / `alibaba` / `models-ai`.
3. **Tokens live in Freebuff2API, not upb** — `AUTH_TOKENS` in `Freebuff2API/config.json` (from https://freebuff.llm.pm/), upb uses `local_secret: claude-freebuff-poser`.

## What exists now

- Scripts: `/home/fabio/Downloads/scripts/` — `build-freebuff.sh`, `run-freebuff.sh`, `setup-upb.sh` (fixed for real `routes.yaml`), `start-all.sh`, `DETAILED-PLAN.md`
- upb truth: `~/.config/upb/routes.yaml` (600), `~/.config/upb/secrets.env`, `~/.config/upb/default-binding.env` (-> `http://127.0.0.1:8705`)
- Freebuff2API upstream: `https://github.com/Quorinex/Freebuff2API` — Go 1.23+, `main.go -config config.json`, GHCR `ghcr.io/quorinex/freebuff2api:latest`
- This box: no `~/.config/manicode/credentials.json` yet — use Web method for tokens.

## Routes.yaml snippet (canonical)

```yaml
  freebuff:
    label: Freebuff via Freebuff2API (free tier)
    kind: upb
    upb_provider: freebuff
    base_url: http://127.0.0.1:8080/v1
    trust_zone: local-approved
    key: none
    local_secret: claude-freebuff-poser
    priority: 60
    enabled: true
    catalog: live
    note: local Freebuff2API - AUTH_TOKENS held by :8080, rotation 6h; models via localhost:8080/v1/models
```

Why this shape:
- `local-approved` (not `remote-approved`) — localhost :8080
- `key: none` — real `AUTH_TOKENS` held by :8080, rotation `6h`
- `priority: 60` — after paid 10-50, before `ollama-cloud` 90. Use 5 to prefer free first, 95 for explicit-only.
- No `default_model` until stable — keep `opencode-go` / `zai` default, call freebuff explicitly.

## Runbook

```bash
chmod +x /home/fabio/Downloads/scripts/*.sh
export AUTH_TOKENS="tok-from-https://freebuff.llm.pm/"  # comma-separated if multiple
export FREEBUFF_PORT=8080
/home/fabio/Downloads/scripts/build-freebuff.sh
/home/fabio/Downloads/scripts/run-freebuff.sh
# verify :8080 alone first:
curl -s http://127.0.0.1:8080/v1/models | head -c 2000
/home/fabio/Downloads/scripts/setup-upb.sh  # backs up routes.yaml, appends freebuff: if missing, yaml-validates
# restart :8705 router (universal-router.service), then:
curl -s http://127.0.0.1:8705/v1/models | python3 -m json.tool | grep -i -A1 -B1 freebuff
source ~/.config/upb/default-binding.env
ANTHROPIC_MODEL=freebuff/<model> claude -p "explain XOR"
```

Debug order: `:8080/models` -> `:8080/chat/completions` -> `:8705/models` -> `:8705/chat/completions` -> `claude -p`. Never jump to Claude until :8080 passes alone.

Docker alt:
```bash
docker run -d --name freebuff2api -p 8080:8080 -e AUTH_TOKENS="tok1,tok2" ghcr.io/quorinex/freebuff2api:latest
```

AppImage note (you tested AppImage):
- Wrap only Freebuff2API if needed: `go build -o freebuff2api`, AppDir `usr/bin/` + `.desktop`, `appimagetool`. Run `./Freebuff2API-x86_64.AppImage -config config.json`.
- Don't wrap upb — upb already is the single-file layer (13-line YAML). Prefer GHCR + snippet, less breakage when `free-agents.ts` logic updates.

## Verification evidence (2026-09-03)

- `routes.yaml`, `secrets.env`, `default-binding.env` read — confirmed `catalog: live` pattern, `:8705` persistent router, no `manicode/credentials.json`.
- `setup-upb.sh` fixed — old version wrote `config.yaml` (doesn't exist), new version appends to `routes.yaml` with backup + `python3 -c yaml.safe_load` check.
- CDP live-Chromium lane still down (`ECONNREFUSED 9222`, PID 551344 without `--remote-debugging-port`, log `Opening in existing browser session`) — token must be copied manually from https://freebuff.llm.pm/ for now.

## Open items

1. **Token** — paste from https://freebuff.llm.pm/ into `Freebuff2API/config.json`, never commit, `chmod 600`.
2. **Lock down :8080 in prod** — set `API_KEYS: ["local-dev-key"]` in Freebuff2API, then change upb `key: none` to static/env. Homelab `key: none` + firewall is fine.
3. **Egress** — if Freebuff blocks IP, set `HTTP_PROXY` in Freebuff2API config, not in upb.
4. **Default flip** — only after explicit runs stable: add `default_model:` or set `UPB_BOUND_ROUTE=freebuff/<model>` in `default-binding.env`.
5. **Rollback** — `cp ~/.config/upb/routes.yaml.bak.* ~/.config/upb/routes.yaml` + restart :8705.

## Index

- Scripts: `/home/fabio/Downloads/scripts/DETAILED-PLAN.md` (full runbook with curl bodies)
- Upstream: `https://github.com/Quorinex/Freebuff2API`, `https://freebuff.llm.pm/`, `https://github.com/fabiofalopes/upb`
