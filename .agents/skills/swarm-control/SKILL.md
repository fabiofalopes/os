---
name: swarm-control
description: Operate the Forge cron-swarm engine (the vault's agent queue) — check status, fire waves, arm/disarm the */15 cron, read health and breakers. Triggers on 'swarm', 'fire a wave', 'run the engine', 'queue jobs not running', 'is the swarm armed', 'harness health', 'MAX_SESSIONS'.
---

The Forge engine: `_harness/runner.sh` waves (WORKERS_PER_TICK=3) over `_harness/queue.md` jobs, every */15 when armed. Control surface: `bash _harness/swarm <verb>`.

## When to use

- "Why isn't the queue running?" / "run the pending jobs" / "arm the swarm" / "is the engine on?"
- Before/after arming anything; before adding batch or research jobs
- Any session that needs to know engine state (cron armed? gateway green? queue depth?)

## Verbs

```bash
bash _harness/swarm status   # armed? flag? health.sh, queue counts, last wave, last LOG lines
bash _harness/swarm fire     # ONE manual wave now (detached; flock overlap-safe; needs cronctl flag open)
bash _harness/swarm arm      # enable the 3 forge crontab lines (runner+health+oracle, */15) — ROLLBACK: disarm
bash _harness/swarm disarm   # disable them
```

## Facts & guards

- Two-layer kill switch: crontab lines (arm/disarm) + flag file `~/.config/cronctl/enabled/forge-runner` (must exist or runner exits 0 silently).
- Gateway down → waves `SKIP(GATEWAY)` with a 1800s breaker hold; jobs preserved, zero tokens burned. Not an error — do not "fix" it; check Lusófona/router health (`curl :8705/v1/models`).
- Caps: MAX_SESSIONS_PER_DAY=90, SESSION_TIMEOUT=900s. Config: `_harness/config.env` — any edit to it / runner.sh / worker.sh must pass the PRE-CHANGE CHECKLIST in `_harness/FAILURE-MODES.md`.
- Queue discipline: jobs are `- [ ] [Role] TEXT` lines; one bounded session's worth; must end with `PRODUCED:` evidence.
- Monitor (three dials): `LOG.md` op-lines, `queue.md` counts, `git log`. Health: `bash _harness/health.sh`.
