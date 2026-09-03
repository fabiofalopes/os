---
tags: [cron, harness, fleet-optimizer, forge, infrastructure, ops, disabled]
date: 2026-08-03
role: Orchestrator
status: complete — all 5 user cron jobs audited + disabled (reversible); backup saved
related:
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
  - "[[FAILURE-MODES]]"
  - "[[INDEX]]"
---

# Cron Audit + Disable — All User Jobs Stopped (2026-08-03)

> **Verdict (one screen):** Audited every active user cron job, found what each actually *did* on 2026-08-03, then **disabled all 5** (commented out, fully reversible). Only one — Context Growth Forensics — did real work. The Fleet Optimizer spent all day *reporting* that the proxy + RPi are down without fixing anything (self_score 0.0). The Forge failed **12/12** runs (0% success) on gateway flapping plus a pending human GO decision. Net: the cron layer was burning tokens to report breakage, not produce value, so it's now paused until the underlying infra (proxy, RPi, gateway) is addressed. Backup preserved for one-command restore.

## What was active (5 user jobs)

| Schedule | Job | Purpose |
|---|---|---|
| `0 * * * *` | `fleet-optimizer/loop.sh` | Fleet self-tuning agent loop (hourly) |
| `7-59/15 * * * *` | `_harness/health.sh` | Forge watchdog — health flag refresh |
| `*/15 * * * *` | `_harness/runner.sh` | Forge cron-session engine |
| `12-59/15 * * * *` | `_harness/oracle.sh` | Forge oracle |
| `0 6 * * *` | `context-growth-forensics.py` | Daily token/context analysis (6 AM) |

System-wide entries (`/etc/crontab`, `/etc/cron.d/`: e2scrub_all, john, php, sysstat) were left untouched — default OS/package jobs, not part of this harness.

## What each did on 2026-08-03

### 1. Context Growth Forensics — ✅ worked
Ran clean at 06:00. Parsed **329 Claude + 42 OpenCode sessions**, total effective context **95.7M**. Report written to `/home/fabio/shared-local/reports/context-growth/context-growth-20260803-060002.md` (also mirrored to `latest.md`). This was the only cron that did its job.

### 2. Fleet Optimizer — ⚠️ ran but only reported failures
Ran every hour (runs #497→516). Every check found the same broken state:
- **proxy: offline** (0 providers)
- **rpi: unreachable** (ssh=false)
- **vault_sync: out-of-sync** (local:9343, rpi:0)
- webui: online

Performed **zero optimizations** (`self_score: 0.0`, empty optimizations list). It only kept writing escalation reports (`proxy-down-*`, `rpi-down-*` JSON) all day. Detecting the outage, not fixing it.

### 3. The Forge — ❌ failing all day
Health: **FAILING**. **12 runs, 0 success, 12 fail.**
- Root cause: **gateway flapping** — repeated `GATEWAY_HOLD` / `GATEWAY_RESUMED` cycles (`.gateway_flap` + `.gateway_hold` flags fresh at 19:45). Dispatches kept getting held.
- One job (`[Quant]`) ran but produced **no artifact**.
- Worker output shows jobs **DEFERRED** waiting on a human to check a `GO` box in `wiki/value/forecast-pilot-01-fix-checklist.md` — decision still pending.
- Rollup cliff: `2026-08-03, 12, 0, 0, 12, 0, 0%` (vs Aug 1: 58%, Aug 2: 75%).

## The action taken

Backed up, then commented out all 5 job lines with a `# DISABLED ` prefix:

- **Backup:** `/home/fabio/shared-local/reports/crontab-backup-20260803-213324.txt`
- **Disabled at:** 2026-08-03 21:33 local
- **Verified:** `crontab -l | grep -vE '^\s*#|^\s*$'` → no active job lines remain.

## Restore (when ready)

- Restore everything: `crontab /home/fabio/shared-local/reports/crontab-backup-20260803-213324.txt`
- Restore selectively: `crontab -e` and strip the `# DISABLED ` prefix from the lines you want back.

## Follow-ups (why it's paused, what to fix first)

- [ ] **Proxy** is offline (0 providers) — fleet optimizer + forge both depend on it.
- [ ] **RPi** unreachable (ssh=false); vault_sync out-of-sync (local:9343 vs rpi:0).
- [ ] **Gateway flapping** — investigate the HOLD/RESUMED cycle before re-enabling the Forge.
- [ ] **Human GO decision** pending on `forecast-pilot-01-fix-checklist.md` (both `☐ GO` and `☐ NO-GO` unchecked).
- [ ] Consider whether any still-running Forge/worker processes need killing (cron disabled ≠ processes stopped).

> [!note] Rationale
> The cron layer was consuming tokens to *report* breakage rather than produce value. Pausing it stops the burn while the underlying infra (proxy, RPi, gateway) is repaired. Re-enable once the outage is resolved and the GO decision is made.
