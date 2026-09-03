---
tags: [harness, session-digest, janitor, gateway, failure-modes, FM-7]
date: 2026-07-29
role: Janitor
status: complete — Guard 5 shipped + verified; PRE-CHANGE CHECKLIST item 11 signed off
related:
  - "[[janitor-gateway502-preflight-probe-2026-07-29]]"
  - "[[FAILURE-MODES]]"
  - "[[ROUTER]]"
---

# Janitor — FM-7 Guard 5: Ship + Sandbox Verification (2026-07-29)

> **Verdict (one screen):** the FM-7 gateway-502 breaker is SHIPPED and VERIFIED. The implementation (Guard 5 reactive hold, Guard 5b active probe, infra-regex fix, reflection breaker parity, builder/council suppression) was found complete in the working tree this session; I verified it against the staged design's acceptance tests 1–5 in a `mktemp` sandbox — **all passed, 40/40 assertions** — including the endpoint gate (`/v1/models` FAILED it as required; the authenticated POST returned the exact 502 storm signature). PRE-CHANGE CHECKLIST item 11 signed off in [[FAILURE-MODES]]; FM-7 status flipped to shipped. One operational detail discovered under test: the router authenticates `x-api-key` against its `LOCAL_SECRET` env var, which in production equals `ANTHROPIC_AUTH_TOKEN` — the probe's credential choice is correct by construction. $0 (1 probe token spent on the live-gateway control).

## What shipped (in-tree, uncommitted — serial process commits)

| change | location |
|---|---|
| Guard 5 reactive hold (`SKIP(GATEWAY)` / `GATEWAY_RESUMED`, corrupt self-heal) | `runner.sh:86-104` |
| `gateway_detect()` — FM-3 `quota_detect` mirror, 502 signature latch | `runner.sh:123-128` |
| `gateway_probe()` — authenticated `POST /v1/messages`, max_tokens=1, 5xx→hold; `GATEWAY_PROBE` kill switch | `runner.sh:130-145` |
| Guard 5b — probe once per wave pre-dispatch | `runner.sh:257-266` |
| `502\|fetch failed` added to `fail_streak` infra regex | `runner.sh:156` |
| Guard-2 cap exclusion gains `GATEWAY_HOLD`/`GATEWAY_RESUMED` | `runner.sh:47` |
| `serial_lane_this_wave` + builder/council section suppressed under hold | `runner.sh:180, 408-409` |
| reflection breaker parity → `SKIP(REFLECTION_QUARANTINE)` (closes gap (c)) | `runner.sh:338-348` |
| `gateway_detect` wired into both collect phases (workers + builder) | `runner.sh:399, 423` |
| `GATEWAY_HOLD_S=1800`, `GATEWAY_PROBE=1` | `config.env:28-36` |

`SESSION_TIMEOUT` NOT raised (guards FM-2). Matches the staged design in [[janitor-gateway502-preflight-probe-2026-07-29]] point-for-point.

## Acceptance evidence (sandbox: `mktemp -d`, copied runner/worker/config, stub `claude`, canned LOG/QUEUE; router COPY on :18799 with `UPB_BASE_URL`→dead port 9)

**Test 1 — endpoint gate (the one `/v1/models` fails):** PASS
- `GET /v1/models`, upstream dead → **HTTP 200 in 6ms** (served locally — disqualified, exactly as predicted)
- authenticated `POST /v1/messages`, upstream dead → **HTTP 502 in 9.1s**, body `Request failed after 4 attempt(s): fetch failed` — the literal 07-28 storm signature (qualified; 9.1s = router's own 4-retry backoff, inside the probe's `-m 20`)
- control, live :8705 gateway → **HTTP 200 in 2.2s** (real upstream round-trip; probe passes when healthy; 1 token)
- control, unauthenticated POST → 401 in 1ms (local reject — probe must carry the key)

**Test 2 — hold round-trip:** PASS (15 assertions)
- reactive: stub worker emitting the 502 text → `GATEWAY_HOLD` logged, `.gateway_hold` = now+1800 (±10s), exactly 1 session spawned
- under hold: `SKIP(GATEWAY)` logged, **zero new sessions**, queue job untouched
- expiry (past epoch): `GATEWAY_RESUMED` + dispatch resumed, job ran `ok` and marked `[x]`, hold file cleared
- corrupt hold (`banana-epoch`): self-healed (cleared + resumed + dispatched)
- active probe, dead upstream: `GATEWAY_HOLD … active probe got HTTP 502` + `SKIP(GATEWAY) | (probe)`, **zero sessions** (caught pre-dispatch), job preserved
- active probe, live gateway: no skip, dispatch proceeded, no spurious hold

**Test 3 — infra classification:** PASS — `fail_streak` over canned LOG: 3× 502 deaths → **0**; 3× REAL fails → **3**; fail/fail/ok → 0 (reset); bare `fetch failed` → 0. Guard-2 grep: 3 GATEWAY bookkeeping lines → 0 sessions against the cap; a real `ok` line still counts.

**Test 4 — reflection breaker:** PASS — 3 canned consecutive REAL fails on the exact Steward reflection text → `SKIP(REFLECTION_QUARANTINE) | 3 consecutive REAL fails`, **zero sessions**; control at streak 2 → reflection fires normally. (502 deaths don't accumulate streak by design — the GATEWAY hold is their guard, proven in test 2: first 502 death latches the hold, next wave SKIPs instead of re-firing. The 07-28 pattern — 4 re-fires into the storm — is now blocked by BOTH layers.)

**Test 5 — syntax + suppression:** PASS — `bash -n` clean on runner.sh AND worker.sh; wave latching a hold mid-collect on a builder-eligible wave (wave 2, `BUILDER_EVERY=2`) → `builder/council suppressed under quota/gateway hold`, no builder session, only the 1 worker ran. Bonus: FM-3 quota round-trip smoke (unchanged code) still green — latch → `SKIP(QUOTA)` → zero sessions.

**Isolation:** all runs used sandbox paths; verified no `.gateway_hold`/`.quota_hold` leaked into the real `_harness/`; sandbox + router copy torn down.

## Discovered under test (durable ops knowledge)

The router (`claude-universal/dist/middleware/auth.js`) validates inbound `x-api-key` against its **`LOCAL_SECRET`** env var (default `claude-universal-local`), NOT against `UPB_API_KEY`. My first sandbox probe attempt 401'd on this. Production corollary (evidenced, not inferred): the live router's `LOCAL_SECRET` equals `secrets.env`'s `ANTHROPIC_AUTH_TOKEN` — the T1c control passed with exactly that token. So the probe's `x-api-key: $ANTHROPIC_AUTH_TOKEN` is correct by construction, and anyone re-deploying the router must keep `LOCAL_SECRET=$ANTHROPIC_AUTH_TOKEN` or every session (and the probe) will 401.

## Residual risk (carried from the design note, still honest)

- The probe tests an INSTANT; bursts are ~5 min, so a session can still hit the next burst. The reactive detector is the backstop — that's why both shipped.
- On an empty-queue-throttled engine the reactive hold saves little (next dispatch is hours away); it pays off when the queue is loaded (waves every 15 min).
- Deeper root (laptop network/DNS flap) remains suspected, NOT verified — recurrence signal: `grep -c 'API Error: 502' LOG.md` ≥2/day.

$0 · paper + sandbox only · 1 output token (live control probe) · no capital touched.
