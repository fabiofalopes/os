---
tags: [janitor, harness, routing, builder-lane]
date: 2026-07-26
status: durable — fix + verification evidence
related:
  - "[[janitor-quota-breaker-2026-07-26]]"
  - "[[multi-agent-orchestration-patterns]]"
  - "[[meta-review-2026-07-21]]"
---

# [Janitor] BUILDER-LANE ROUTING FOR DATA-HEAVY JOBS — 2026-07-26

> Job: the ROW-3 EXECUTE job timed out TWICE on the worker lane (LOG 2026-07-26T14:30/14:45Z, `TIMEOUT(900s)`, no output — ~1800s compute burned for zero artifacts) before the builder lane finished the SAME job in 741s (14:57Z). Workers run `SESSION_TIMEOUT=900`/`MAX_TURNS=40`; builder `2400s`/80 turns. Add routing to `_harness/runner.sh` so a job can be tagged for the builder lane and dispatch there instead of double-timing-out on the worker lane. Do NOT raise `SESSION_TIMEOUT` (the 900s cap guards the trust-bug hang). Done-evidence: `bash -n` clean + one simulated tagged job routing to the builder lane.

## Verdict

**Done and verified.** `_harness/runner.sh` now routes data-heavy jobs to the builder lane via an explicit `[builder]` tag OR a `BUILDER_ROUTE_PATTERN` role+keyword auto-detect (new knob in `config.env`). Workers skip routed jobs in the claim loop; the builder wave picks them first. `bash -n` clean on runner/worker/config; 12/12 unit assertions and a 6/6 full sandboxed wave of the *real* runner.sh (stub claude, $0) all pass. `SESSION_TIMEOUT` untouched.

## What changed

- **`runner.sh:118` — `job_lane <job-text>`.** Echoes `builder` or `worker`. An explicit `[builder]` tag anywhere in the text (case-insensitive) always wins; else `BUILDER_ROUTE_PATTERN` (ERE) auto-detect; else `worker`.
- **`runner.sh:127` — `pick_builder_job`.** The builder phase's job picker: scans unchecked jobs and returns the first one `job_lane` routes to builder; falls back to the top unchecked job (legacy behavior) when nothing is routed.
- **`runner.sh:199` — worker claim-loop skip.** After the quarantine breaker check, a job routed to builder is `continue`d past (with a `defer to builder lane:` stderr note) so it never draws a worker session — *only when `BUILDER_EVERY > 0`*, so disabling the builder also disables routing (no orphaned jobs).
- **`runner.sh:296` — builder phase** now calls `pick_builder_job` instead of `grep -m1`, so a routed job is preferred over an earlier unchecked worker job.
- **`runner.sh:108` — `fail_streak` prefix strip.** Builder-lane LOG lines prefix field 5 with `[builder] `; the breaker now strips it before comparing, so a routed job that keeps failing on the builder lane still hits `MAX_JOB_RETRIES=3` and gets quarantined. Without this, routing would have created an infinite-retry loop (workers skip the job, so its failures never reached the breaker).
- **`config.env:38` — `BUILDER_ROUTE_PATTERN='^\[Quant\][^:]*EXECUTE'`** (case-sensitive ERE, empty = tag-only). Documented inline.
- **`schedule.md`** — new "Lane routing (worker vs builder)" section + change-log line (docs synced to reality).

## Design note: why role+keyword, not a bare keyword

A naive `EXECUTE` match would mis-route the `[Critic] ATTACK … Runs before the EXECUTE job` jobs — which run fine on the worker lane (654s/710s, LOG 07-26). The `^\[Quant\]` role anchor is precisely what excludes them. Verified as an explicit false-positive guard in the unit tests. The explicit `[builder]` tag is the escape hatch for any future data-heavy job the pattern doesn't cover.

## Evidence

1. **`bash -n` → SYNTAX_OK** on `runner.sh`, `worker.sh`, and `config.env`.
2. **Unit tests (12/12)** on the three functions extracted *verbatim* from the shipped runner.sh: auto-detect fires on the real ROW-3 EXECUTE text; both `[Critic] … EXECUTE job` texts stay on worker; `[builder]` tag (any case, any role) → builder; `pick_builder_job` prefers a routed job over an earlier worker job and falls back to top-unchecked when none routed; claim-loop filter defers exactly the 2 routed jobs and claims the 2 normal ones; `fail_streak` counts builder-lane TIMEOUTs (streak 2), still counts worker-lane fails (no regression), and a builder-lane `ok` resets the streak.
3. **Full sandboxed wave of the real runner.sh (6/6, $0):** a temp copy of the harness with `VAULT`/`HARNESS`/`CLAUDE_BIN` repointed, a stub claude (exit 0, no session), fresh `state/` (reaper can't touch live workers), no `secrets.env`/`.quota_hold` (preflight + breaker can't suppress the wave), `BUILDER_EVERY=1`. Result: worker lane ran ONLY the Scout job (1 session); the routed EXECUTE job drew NO worker session; the builder lane ran it (LOG field `[builder] [Quant] EXECUTE…`); both jobs checked `[x]`; exactly 2 LOG lines; stderr announced the deferral. Sandbox auto-removed.
4. **Test-harness bug caught by testing, not wondering:** my first claim-loop sim used `${line#- [ ] }` to strip the queue prefix and silently failed — the exact glob-char-class gotcha runner.sh:172's comment warns about. Fixed the test to the runner's fixed-offset `${line:6}`; the shipped runner was never affected.

## Residuals / notes

- A routed job waits up to `BUILDER_EVERY` waves (~30 min at `BUILDER_EVERY=2`) for its builder slot. That is the intended trade — 30 min of latency beats 1800s of burned compute and zero artifacts.
- `BUILDER_ROUTE_PATTERN` is deliberately narrow (only `[Quant] EXECUTE …`). Broaden it only with a role anchor, and re-run the false-positive guard — a loose pattern would quietly move fast worker jobs onto the slower builder cadence.
- If the builder lane is disabled (`BUILDER_EVERY=0`), routing auto-disables too, so tagged jobs still run on workers rather than starving.
- The `[builder]` tag survives into the job prompt and the LOG field (harmless; the LOG already prepends its own `[builder] ` lane marker). Not stripped — keeping `mark_job` matching the queue line exactly was worth more than cosmetics.
