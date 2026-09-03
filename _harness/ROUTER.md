---
tags: [harness, ops, router, infra]
date: 2026-07-21
status: live — universal-router.service (systemd --user)
---

# ROUTER — The Forge's Persistent Uplink

> Why this exists: on 2026-07-21 the cron engine lost **17 consecutive ticks** because the model router on `:8705` was a *child process of an interactive claude session* — it died when that session ended, and every session (cron included) pointing at `http://localhost:8705` got `ConnectionRefused` until some interactive launch happened to respawn it. The router is now a daemon. Sessions come and go; the uplink stays.

## What runs

- **Unit:** `~/.config/systemd/user/universal-router.service` — `Restart=always`, `RestartSec=3`, enabled, and `loginctl` linger is already on (survives logout + reboot).
- **Config:** `EnvironmentFile=/home/fabio/shared-local/reports/claude-universal/router-alibaba.env` (chmod 600, **untracked** — holds `PORT=8705`, `UPB_PROVIDER=alibaba-token-plan`, `UPB_BASE_URL`, `UPB_API_KEY`, `UPB_MODEL_MAP`, `LOCAL_SECRET`). Kept out of the vault on purpose: `_harness/*.env` is not fully git-ignored.
- **Binary:** `node /home/fabio/shared-local/reports/claude-universal/dist/index.js` (the Universal Provider Router; translates Anthropic wire protocol → Alibaba MaaS, all tiers → `qwen3.8-max-preview`).

## Ops

```bash
systemctl --user status universal-router      # health
journalctl --user -u universal-router -f      # logs
systemctl --user restart universal-router     # bounce
ss -tlnp | grep 8705                          # confirm listener (ppid should be systemd --user)
```

**If the API key / model map changes:** recapture the env from a live ad-hoc router before it dies —
`tr '\0' '\n' < /proc/<router-pid>/environ` → write the six vars into `router-alibaba.env` (single-quote values) → `systemctl --user restart universal-router`.

## Gotchas

- An ad-hoc `./claude-universal` launch now **fails to bind :8705** (EADDRINUSE) and exits — harmless; everything routes through the daemon anyway.
- `./claude-universal --stop` kills the daemon — systemd revives it within ~3s (`Restart=always`). Expected, not an outage.
- The old systemd unit pointed at `providers.yaml` + port 8443 — that config has **no `alibaba-token-plan` provider**; the env-var recipe above is the one that actually routes the cron MODEL_CHAIN.
- Companion harness guards (runner.sh): proxy **preflight** logs `SKIP(PROXY_DOWN)` instead of burning a 180s mystery fail, and the **poisoned-job breaker** quarantines a job as `- [!]` after `MAX_JOB_RETRIES` consecutive *real* fails (infra fails never count) so the queue — and META-REVIEW — can't deadlock again.
