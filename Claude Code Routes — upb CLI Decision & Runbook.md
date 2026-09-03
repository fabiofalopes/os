---
title: Claude Code Routes — upb CLI Decision & Runbook
date: 2026-08-05
tags: [infra, decision, runbook]
---

# Claude Code Routes — `upb` CLI — Decision & Runbook

> Replaced a graveyard of 35 `claude-*` launcher scripts with one config file + one command.
> Related: [[spec-unified-agent-harness-cli]] (north star) · [[Claude Code Proxy Pattern — Master Reference]] · [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]]

## Decision (2026-08-05, human-approved)

Context: [[spec-unified-agent-harness-cli]] proposed a full Go control plane in response to the alias debt. Evaluation: right diagnosis, overweight starting point, and it ignored the existing UPB proxy (the hard 90% — Anthropic↔OpenAI translation, tool-use round-trip — already built in TS and running).

1. **Thin consolidation first** — one `routes.yaml` + one Python CLI around the existing UPB. Spec stays the north star; later stages only on evidence.
2. **Name: `upb`** — not `harness` (collides with the `_harness/` cron-swarm vocabulary).
3. **End state: bare `claude` becomes a thin wrapper over the router** — only after parity is proven (not done yet; bare `claude` untouched).

## What exists now

- `~/.config/upb/routes.yaml` (chmod 600) — single source of truth: providers, models, ports, priority, key *references*, `enabled`, `active_until`.
- `~/bin/upb` — Python stdlib CLI: `list` / `status` / `run` / `stop` / `default` / `doctor`.
- UPB proxy unchanged (`~/shared-local/reports/claude-universal/`).
- `universal-router.service` (systemd --user) untouched: persistent :8705 alibaba/qwen3.8-max-preview uplink (backs the cron engine's gateway probe too). `upb` reuses it, never stops it.

## Runbook

```bash
upb list [--all]        # usable routes only (--all: hidden ones + reasons)
upb status              # key resolution + live endpoint health per provider
upb run zen/deepseek-v4-flash-free [-- <claude args>]
upb run default         # first eligible route by preference
upb stop --all          # stops ONLY proxies upb spawned (never systemd's)
upb doctor              # config, keys, ports, binaries, hygiene
```

**Preferential config (the monthly problem):** in `routes.yaml` per provider — `enabled: true/false`, `active_until: "YYYY-MM-DD"`, `priority:` (lower = preferred); model order inside a provider = preference. `upb list` never shows what you can't use this month; `upb list --all` says why each hidden route is hidden.

## Migration table (old → new)

| Old launcher | New route |
|---|---|
| `claude-ollama-*` (20 files) | `ollama-cloud/*` — `enabled: false` (unused since 2026-08; flip to revive) |
| `claude-alibaba-*` (6) | `alibaba/*` — `active_until: 2026-08-20` |
| `claude-zen-*` (3) | `zen/*` |
| `claude-ornith` / `claude-omnicoder` | `litellm/*` |
| `claude-deepseek(-flash)` | `deepseek/*` — needs key at `~/.config/deepseek/api_key` |
| `claude-ollama-kill` | `upb stop` |

## Cleaned

- 35 launchers removed from `~/bin`; backup: `~/.local/share/upb/legacy-launchers-2026-08-05.tar.gz` (5.5 KB, one file).
- Plaintext LiteLLM key removed from `providers.yaml` (canonical copy: `~/.config/opencode/opencode.json`; INDEX flagged this leak back in July).
- Secrets are referenced by path/env-var in `routes.yaml`, never stored there; `upb doctor` checks for regressions.

## Parity evidence (2026-08-05)

- `upb run litellm/ornith-9b` — spawned proxy :8901, claude one-shot, coherent reply. ✅
- `upb run zen/deepseek-v4-flash-free` — spawned proxy :8801, claude ran; direct curl through proxy returned clean "OK". ✅ (one streamed one-shot came back garbled — see open items)
- `upb run alibaba/qwen3.8-max-preview` — reused healthy :8705 systemd proxy, no respawn. ✅
- `upb stop --all` — killed upb-spawned proxies, refused to touch :8705. ✅

## Open items

1. **Alibaba plan expires 2026-08-20 17:00, auto-renewal OFF.** After that date the default route silently falls back to zen (by design). Renew → bump `active_until`; or let it lapse.
2. **DeepSeek key missing** — route configured but hidden until a key lands in `~/.config/deepseek/api_key`.
3. **Zen free-tier streamed one reply as token-soup** once (non-streaming direct probe clean). Pre-existing UPB/free-model behavior, not upb's plumbing — verify before trusting zen with real work.
4. **`openclaude` alias in `~/.zshrc` points at a binary that no longer exists** — removal is a human call (Z4-adjacent: shell config).
5. Alibaba also exposes an **Anthropic-protocol endpoint** (`token-plan.../apps/anthropic`) — future `anthropic-native` route, no proxy at all.
6. After 2026-08-20, if the fleet stays healthy, consider the end-state swap: `claude` alias → thin `upb` delegating wrapper (decision #3).

## Amendment — same session, later: dynamic provider surface

Doctrine fixed by the human: **routes follow what we pay for this month — nothing is assumed.** Valid key → visible; no key/expired → hidden, zero obligation. (So DeepSeek is correctly hidden, not an "open item".)

- **`catalog: live` providers**: models discovered from `/v1/models` at runtime (cached 1h in `~/.cache/upb/`), any listed model runnable on demand; dynamic ports from 9000–9199 recorded in `~/.cache/upb/ports.json`; never the default route (metered = explicit choice). Browse: `upb models <provider>`.
- **`prime-intellect` LIVE** — `https://api.pinference.ai/api/v1` verified with the `PRIME_INTELLECT_API_KEY` (env): 117 models, pay-per-use, balance unknown. E.g. `upb run prime-intellect/deepseek/deepseek-v4-flash`.
- **`zai` configured-but-hidden** — coding plan is paid ~1 year; route appears the moment `export ZAI_API_KEY=...` exists.
- **RunPod**: key present but no deployed inference endpoint yet — add as a route when one exists (never provision silently; see cloud-staging-discipline).
- **Two UPB router bugs found+fixed** (see repo NOTES.md): env-var config precedence restored (a rebuild had silently flipped to YAML-first — would have broken the :8705 service on restart), and `org/model` ids in model_map now pass upstream verbatim (PI 404 otherwise).
- **Usage monitoring**: future add-on (community monitor or own), explicitly deferred.

## Path B proven — own GPU instance (2026-08-05, ~$0.65)

Full loop verified: `claude` → UPB proxy → SSH tunnel → llama.cpp on a rented PI pod → **Ornith-9B on our own A6000**. Route: `upb run pi-own/ornith-9b`.

What it took (record so the next time is 10 minutes, not an hour):
- Pod: `POST /api/v1/pods/` copying offer fields (`cloudId`, `gpuType`, `socket`, `dataCenterId`, `country`, `security`, `provider.type`). Running state is `ACTIVE` (not `RUNNING`); IP appears in the pod record; SSH = `ubuntu@<ip>` with `/home/fabio/private_key.pem`.
- Spot lesson: `_SPOT` cloudIds are ~65% cheaper and get reclaimed without reason (~6 min here, ~$0.03 lost). On-demand for anything you don't want interrupted.
- Image `ubuntu_22_cuda_12` has driver + **CUDA 12.2 local apt repo** but no nvcc: `sudo apt-get install cuda-toolkit-12-2`, and `g++-12` too (nvcc's host compiler is `gcc` → gcc-12, which ships without cc1plus otherwise). No Linux CUDA prebuilts exist upstream; compile is the only way (~25 min on 6 vCPUs).
- Model download is trivially fast in-datacenter (5.3GB in ~3 min).
- Guardrails that worked: watchdog armed at creation (auto-DELETE after 2h), budget cap, ephemeral everything.
- Cost anatomy: GPU is the whole bill (~$0.54/hr A6000 x1); provisioning time free.

**Cost doctrine (human, 2026-08-05 — learned at ~$0.30 of idle burn):**
1. **Download first, GPU second.** All staging (models, deps) happens on free/cheap compute; the GPU boots only when serving starts. Spot doubly so — never pay GPU rates for downloads.
2. **GPU off the moment it's not in use.** Success of the test = teardown. Idle billing is the failure mode, not the exception.
3. **Verify guardrails; don't assume.** A watchdog only counts if you've seen its process alive (a truncated `pgrep` here nearly produced false confidence).
4. Secrets in argv (`ps`-visible) are leaks too: watchdog one-liners must reference `$PRIME_INTELLECT_API_KEY`, never inline the key.

Next iteration (if this becomes regular): persistent disk + CPU staging node + prebaked image per the `tinygrad-bounty/forward-deploy/gpu-harness-runbook.md` — turns the 30-min setup into boot-and-serve, and makes the spot strategy viable (stage once on disk, boot GPU only to serve, kill after).

## North-star staging (from the spec)

- **Stage 2** (only if the swarm pulls it): `--json` route API for `_harness/worker.sh`, thin per-launch session JSONL, fzf picker.
- **Stage 3**: spec phases 3–5 (circuit breakers, egress enforcement modes, orchestrator socket API), each gated on evidence.
