---
title: Own-Instance GPU Harness — Deploy Playbook & Tight-Pack Doctrine
date: 2026-08-05
tags: [infra, gpu, doctrine, playbook, upb]
---

# Own-Instance GPU Harness — Deploy Playbook & Tight-Pack Doctrine

> Session of 2026-08-05 (night): we stopped *talking about* running our own models and built the machine that does it.
> Companions: [[Claude Code Routes — upb CLI Decision & Runbook]] · [[spec-unified-agent-harness-cli]] · [[Local GPU Swarm — Architecture & Campaign]] · skill `~/.claude/skills/gpu-deploy/`

## Mission

Run **our models, on rented GPUs, through the Claude Code harness, with one command** — and make the path to get there a *script*, not an agent improvisation. The agent's job is to pull levers; the tokens spent per deployment should trend to zero. What remains of latency should be only the cloud's own instantiation time, not ours.

## What exists now (the map)

```
claude (harness, local)
  └─ upb run pi-own/qwen36-27b          ← the one command
       └─ UPB proxy :8931 (Anthropic↔OpenAI translation, local)
            └─ SSH tunnel :8090
                 └─ llama.cpp on rented A6000 48GB ($0.54/hr)
                      └─ Qwen3.6-27B-Fable-Fusion MTP IQ4_XS — 3 sessions × 256K, MTP on
```

- **`upb`** (`~/bin/upb`) + `~/.config/upb/routes.yaml` — the route surface. Providers come and go by key/expiry; the interface never changes.
- **`gpu-deploy` skill** (`~/.claude/skills/gpu-deploy/`) — `market.sh` / `deploy.sh` / `teardown.sh` / `status.sh` + `KNOWN-ISSUES.md` (11 failure classes captured tonight). Next deployment = one script, near-zero tokens.
- **UPB proxy** (`~/shared-local/reports/claude-universal/`) — the translation layer; two bugs fixed this session (env-var precedence, `org/model` ids pass verbatim).
- **Home archive** — model + compiled llama.cpp capture to `~/Models/` (slow pipe, runs in background; re-download on pod is always the fast path anyway).

## The Tight-Pack Doctrine (the actual lesson)

1. **Quantize to fit the constraint, never flex precision on a beast.** We run limited setups. The win is a *perfect fit*: weights + KV + concurrency packed into the card with headroom, not fp16 on an H200 doing nothing.
2. **Concurrency × context over precision.** A fancy quant serving one 32K slot is worth less than a tight quant serving 3 × 256K. Precision-for-nothing is waste.
3. **The math is knowable — do it before serving:**
   - KV/token = 2 · attn_layers · kv_heads · head_dim · bytes(Q). This model's hybrid DeltaNet design (16 attn layers, 4 KV heads) makes KV cheap: **q8_0 ≈ 35KB/tok, q4_0 ≈ 20KB/tok**.
   - pool = ctx_per_slot × parallel; pick KV quant so weights + pool + ~3GB ≤ VRAM.
   - Claude Code baseline ≈ **35K tokens** (system + tools) → ctx_per_slot ≥ 100K, always.
4. **Download/stage first, GPU second. GPU off the instant idle.** Verified watchdogs (evidence, not assumption). Budget caps on every deploy.
5. **Spot is a serve-only game.** Never let a preemptible pod hold setup work (compile/download) — a reclaim there is pure burnt money.

## Tonight's verified configuration (A6000 48GB)

```
llama-server -m model.gguf -ngl 999 -c 786432 -ctk q4_0 -ctv q4_0 -fa on \
  --parallel 3 --port 8080 --alias qwen36-27b --spec-type draft-mtp --spec-draft-n-max 2
```
→ 3 slots × 256K, MTP engaged, **37.9 / 49GB**, faster than the pre-MTP config.
MTP rules from the card: temp ≤ 1, rep-pen off, 2-token predict; acceptance < 50% → regular quant wins.

## Economics ledger (2026-08-05)

| Item | Cost | Note |
|---|---|---|
| Spot pod (reclaimed 6min) | $0.03 | lesson bought cheap |
| A6000 deploy+test pod | ~$1.5 | includes ~30min compile — killed by the skill/disk strategy next time |
| Idle burn owned | ~$0.28 | success should equal teardown |
| Orphaned disks (created+deleted) | ~$0 | PI-005/PI-006 lessons |
| Ongoing | **$0** | pod dies 07:39Z watchdog or user kill; no disks left |

## Open threads

1. **Alibaba plan lapses 2026-08-20** → default falls back to zen; add `ZAI_API_KEY` to light the year-long plan.
2. **Persistent-disk staging** — deferred: cheap GPUs and disk-DCs don't overlap right now (massedcompute has no disks). The skill should auto-stage when a disk+GPU DC is cheap. Watcher ([[pi-spot-watch]] in Projects memory) flags the moment.
3. **Next deployment must use the skill** — dogfood it; every new failure goes into KNOWN-ISSUES.md.
4. Usage monitoring for PI inference credits — still unbuilt.

## What we stop doing

- Agent-improvised SSH debugging during deploys (→ scripts).
- Long status monologues while money burns (→ act, then report).
- Assuming guardrails (→ verify with evidence).
- Throwing away built artifacts at teardown (→ persist model + build; ephemeral only what's cheap to remake).
