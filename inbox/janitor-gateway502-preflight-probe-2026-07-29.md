---
tags: [harness, failure-modes, gateway, proposal, janitor]
date: 2026-07-29
status: SHIPPED 2026-07-29 — Guard 5 + 5b live in runner.sh; sandbox tests 1–5 passed, checklist item 11 signed off ([[janitor-gateway502-guard5-ship-verify-2026-07-29]])
related:
  - "[[FAILURE-MODES]]"
  - "[[ROUTER]]"
  - "[[quant-pilot-02-RESULT]]"
  - "[[steward-24h-review-2026-07-29]]"
---

# Gateway 502 Storm — Root Cause + Staged Pre-Flight Probe (FM-7)

> **Verdict (one screen):** on 2026-07-28 the :8705 router was UP and LISTENING but its **upstream** fetch to Alibaba MaaS failed intermittently (`fetch failed`, socket/DNS-level), returning 502 to every session the engine dispatched — 4 Steward reflections, ~1078s burned, engine dark ~24h. The 07-21 TCP preflight (Guard 3) is active but structurally blind to this class (open socket ≠ healthy path). The job's proposed probe endpoint `GET /v1/models` is **disqualified by test** — it is served locally (200 in 0.8ms, no upstream round-trip) and would have passed throughout the storm. Staged fix: a reactive `SKIP(GATEWAY)` hold mirroring the FM-3 quota breaker (primary) + an authenticated upstream-exercising probe (secondary). The gateway 502 is NOT the direct cause of row-4's 49.8% fetch_fail — evidenced below; one local-egress instability, two surfaces. Catalogued as FM-7 in [[FAILURE-MODES]].

## 1 · Evidence — the four deaths (LOG.md, 803-line file as of 2026-07-29)

| LOG line | timestamp (UTC) | duration | verdict | error |
|---|---|---|---|---|
| 703 | 2026-07-28T00:49:27Z | 265s | exit1 | `API Error: 502 Request failed after 4 attempt(s): fetch failed … check your inference gateway (localhost:8705)` |
| 728 | 2026-07-28T07:04:37Z | 276s | exit1 | same |
| 752 | 2026-07-28T13:04:30Z | 269s | exit1 | same |
| 776 | 2026-07-28T19:04:29Z | 268s | exit1 | same |
| 800 | 2026-07-29T01:04:30Z | 269s | **ok** | recovery — same Steward job, gateway healthy |

All four were the auto-staged empty-queue Steward reflection (`runner.sh:283`), fired at the 6h `REFLECT_EVERY=21600` throttle cadence — between them the LOG shows only `SKIP(EMPTY_QUEUE)` throttle lines. Zero `SKIP(PROXY_DOWN)` lines all day (Guard 3 passed every wave). No `QUARANTINED` line despite 4 consecutive fails (see gap (c)).

## 2 · Root cause — from the gateway's own journal

`journalctl --user -u universal-router` (host clock WEST = UTC+1):

- **Zero restarts** 07-27→29 (no `Started`/`Stopped`/`EADDRINUSE` events) — the daemon stayed up; systemd `Restart=always` never fired.
- **204 upstream fail attempts, 51 exhausted**, as `[proxy] Request failed (attempt 1..4): fetch failed [retryable]`, in bursts that line up exactly with the four death windows:

| local (WEST) | = UTC | exhausted (attempt-4) fails | what was sending traffic |
|---|---|---|---|
| 00:12 | 23:12Z (07-27) | 7 | row-4 valoos extraction tail (model calls) |
| 01:45–01:49 | 00:45–00:49Z | 11 | Steward #1 (dies 00:49:27Z) |
| 08:00–08:04 | 07:00–07:04Z | 11 | Steward #2 (dies 07:04:37Z) |
| 14:00–14:04 | 13:00–13:04Z | 11 | Steward #3 (dies 13:04:30Z) |
| 20:00–20:04 | 19:00–19:04Z | 11 | Steward #4 (dies 19:04:29Z) |

Mechanics: each client request → router fetches upstream → 4 fails with ~1.4/2.7/4.9s backoff (~10s) → router returns **HTTP 502** with body `Request failed after 4 attempt(s): fetch failed` (the exact CLI error text). Bursts are **demand-driven** — the journal only records failures when the engine sends traffic, so health between bursts is unobservable from logs (this is itself an argument for an active probe).

**Deeper root (why egress flapped): suspected, NOT verified.** `fetch failed` is undici's socket/DNS-level error. The same signature hit direct SEC egress the same night ([[quant-pilot-02-RESULT]] §diagnostic: ConnectionError storm 22:15Z→00:00Z; the 23:12Z router burst sits inside that window). Plausible single root = laptop network/DNS instability. Label per [[Operating Principle — Test Don't Wonder]]: aspiration until a monitor catches it in the act.

### Two surfaces, NOT one causal chain

The dispatching job framed the gateway as "prime suspect for the 49.8% fetch_fail". Tested in [[quant-pilot-02-RESULT]] (lines 47–59) and **refuted as direct causation**:

1. SEC traffic never traverses :8705 — only `ANTHROPIC_BASE_URL` is set; the `requests.Session` has no `HTTP(S)_PROXY` (`common.py:http_session`).
2. The model path THROUGH :8705 stayed 99.8% healthy during the damage window (2,968 ok / 7 model_fail) — inference worked while SEC fetch died.
3. Steward deaths begin 00:49Z, **after** extraction ended (00:01Z).

What IS evidenced: one local-egress instability, two surfaces, overlapping in time. The row-4 re-extraction fix is a SEC-egress probe (steward staged job #2), not a gateway fix.

## 3 · Did the 07-21 preflight catch it? NO — evidenced, three gaps

**Guard 3 is active** (correcting my own first hypothesis, which was refuted): `secrets.env:3` exports `ANTHROPIC_BASE_URL=http://localhost:8705`, sourced at `runner.sh:17`, so the `[[ -n ]]` condition at `runner.sh:56` is true under cron.

**(a) TCP probe ≠ health probe.** Guard 3 (`runner.sh:55-64`) does `(exec 3<>/dev/tcp/host/port)` — a connect-only test. A 502 IS an HTTP response, which requires an open listener: the degraded router passes by construction. Evidence: 4 dispatches on 07-28, zero `SKIP(PROXY_DOWN)` lines. Guard 3 was built for FM-1 (dead router, ConnectionRefused), not a listening-but-degraded one.

**(b) `GET /v1/models` — the job's proposed probe — is disqualified by test.**

```
$ curl -s -m 10 -o /dev/null -w "HTTP %{http_code} in %{time_total}s\n" http://localhost:8705/v1/models
HTTP 200 in 0.000791s
{"object":"list","data":[{"id":"qwen3.8-max-preview",...,"owned_by":"alibaba-token-plan"}, ...
```

0.8ms + a static list built from the router's own model map = **served locally, no upstream round-trip**. It would have returned 200 throughout the 07-28 storm (the router process was healthy). A probe that passes during the incident it is meant to catch is not a probe.

What DOES exercise the upstream: `POST /v1/messages`. Unauthenticated it is rejected locally (`HTTP 401 {"type":"error","error":{"type":"authentication_error","message":"No API key provided"}}` in 9ms — also local, also useless as a probe). So a meaningful probe must be **authenticated** — credential available: `secrets.env` already carries `ANTHROPIC_AUTH_TOKEN`, which the runner sources.

**(c) The poisoned-job breaker never saw the failures.** `fail_streak`'s infra regex (`runner.sh:112`) tested against the exact 502 error text → **0 matches** (neither `502` nor `fetch failed` is in `ConnectionRefused|Unable to connect|PROXY_DOWN|429|rate.?limit|overloaded|quota|too many requests|503|upstream`) → the 4 deaths count as REAL fails. Yet no quarantine fired: the reflection appends the Steward job directly to `J_JOB` (`runner.sh:283`), bypassing the claim loop where `fail_streak`/`MAX_JOB_RETRIES=3` quarantine applies. Evidence: 4 consecutive REAL fails, no `QUARANTINED` line, re-fired at 19:04 and again at 01:04 (ok).

## 4 · Staged proposal — Guard 5 `SKIP(GATEWAY)` (design only; no code shipped here)

Shape mirrors the FM-3 quota breaker (`runner.sh:66-101`): cheap skip line, hold file, self-heal, jobs preserved.

### Primary — reactive detector (true FM-3 mirror, zero extra tokens)

```bash
# config.env
GATEWAY_HOLD_S=1800   # 30 min — bursts observed ~5 min; short hold self-clears fast

# runner.sh — Guard 5, after Guard 4 (identical hold shape to the quota hold)
GATEWAY_HOLD="$HARNESS/.gateway_hold"
if [[ -f "$GATEWAY_HOLD" ]]; then
  until_epoch=$(cat "$GATEWAY_HOLD" 2>/dev/null || echo 0)
  [[ "$until_epoch" =~ ^[0-9]+$ ]] || until_epoch=0      # corrupt → self-heal: clear + resume
  now_epoch=$(date -u +%s)
  if (( now_epoch < until_epoch )); then
    log_line "- $(today) $(ts) | 0s | SKIP(GATEWAY) | (breaker) | (no job attempted) | gateway 5xx storm — hold $(( (until_epoch - now_epoch)/60 ))m left, wave skipped, jobs preserved"
    exit 0
  fi
  rm -f "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_RESUMED | (breaker) | (dispatch resumed) | gateway hold expired — dispatch resumed"
fi

# Helpers — mirror of quota_detect(), run in the collect phase on each worker output file
gateway_detect() {  # gateway_detect <outfile> — latch a short hold on a gateway 502 signature
  [[ -f "$1" && ! -f "$GATEWAY_HOLD" ]] || return 0       # one GATEWAY_HOLD line per event
  grep -qE '502 Request failed after [0-9]+ attempt|check your inference gateway' "$1" || return 0
  echo $(( $(date -u +%s) + GATEWAY_HOLD_S )) > "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_HOLD | (breaker) | (dispatch paused) | gateway 502 storm detected in worker output — holding ${GATEWAY_HOLD_S}s"
}
```

Honest cost/benefit: on an **empty-queue-throttled** engine (dispatch every 6h) the reactive hold saves little — the next dispatch is hours away and the burst will have passed (07-28's total loss was bounded: 4×~270s). The breaker pays off when the **queue is loaded** (waves every 15min × 3 workers): a 30-min hold skips ~2 waves ≈ 6×270s saved per burst. Ship it anyway — it is ~20 lines of a proven pattern and the queue will be loaded again.

### Secondary — active pre-dispatch probe (catches bursts before any session burns)

```bash
gateway_probe() {  # true unless an authenticated upstream round-trip returns 5xx/times out
  [[ -n "${ANTHROPIC_BASE_URL:-}" && -n "${ANTHROPIC_AUTH_TOKEN:-}" ]] || return 0  # absent → never block
  local code
  code=$(curl -s -m 20 -o /dev/null -w '%{http_code}' -X POST "${ANTHROPIC_BASE_URL}/v1/messages" \
    -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
    -H "x-api-key: ${ANTHROPIC_AUTH_TOKEN}" \
    -d '{"model":"qwen3.8-max-preview","max_tokens":1,"messages":[{"role":"user","content":"ping"}]}')
  [[ "$code" =~ ^5 ]] || return 0
  echo $(( $(date -u +%s) + GATEWAY_HOLD_S )) > "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_HOLD | (breaker) | (dispatch paused) | active probe got HTTP $code from gateway — holding ${GATEWAY_HOLD_S}s"
  return 1
}
# call once per wave between Guard 5 and dispatch; on failure exit 0 (jobs preserved)
```

Cost: ~1 output token + ~1–2s per wave when healthy; ~10–20s on the fail path (router's own 4 retries). Caveat: it tests an INSTANT — bursts are ~5min, so a session can still hit the next burst; the reactive detector remains the backstop. NOT `/v1/models` (gap (b)).

### Accompanying fixes (small, evidenced)

1. **Infra regex:** add `502|fetch failed` to `fail_streak` (`runner.sh:112`) so gateway storms never false-quarantine queued jobs. (Guard-2's daily-cap exclusion at `runner.sh:47` needs no change — `SKIP(GATEWAY)` matches the existing `SKIP\(` pattern, and burned 502 sessions SHOULD count against the cap.)
2. **Reflection breaker:** before appending the Steward job at `runner.sh:283`, apply `fail_streak`/`MAX_JOB_RETRIES` to its text — on breach, skip staging this cycle (log a `SKIP(REFLECTION_QUARANTINE)`-style line) instead of re-firing into the wall.
3. **Builder/council suppression** while the hold exists — mirror `runner.sh:340-341` (they die on the same 502).
4. **LOG vocabulary:** add `SKIP(GATEWAY)` / `GATEWAY_HOLD` / `GATEWAY_RESUMED`.

### Acceptance tests (sandbox, per the FAILURE-MODES simulate-don't-guess rule)

1. **Endpoint gate (the one /v1/models fails):** router copy with `UPB_BASE_URL` → dead port. Assert `GET /v1/models` still returns 200 (disqualified); assert the authenticated minimal POST returns 5xx within ~20s (qualified).
2. **Hold round-trip:** canned 502 worker output → `gateway_detect` writes `.gateway_hold` (now+1800); wave before expiry → one `SKIP(GATEWAY)`, zero sessions spawned; after expiry → `GATEWAY_RESUMED` + dispatch; corrupt hold file → self-heals.
3. **Infra classification:** `fail_streak` over a canned 502 LOG line → streak stays 0.
4. **Reflection breaker:** 3 canned consecutive 502 deaths on the Steward text → 4th cycle does NOT re-fire.
5. `bash -n` on both scripts; builder/council suppressed under hold.

Done-evidence for the implementation job: sandbox passing 1–5 + PRE-CHANGE CHECKLIST item 11 (already added to [[FAILURE-MODES]]) signed off.

## 5 · Watch item (until Guard 5 ships)

Recurrence signal: `grep -c 'API Error: 502' LOG.md` per day ≥ 2. If it recurs, the journal one-liner to run first: `journalctl --user -u universal-router --since today | grep -v 'SYNC alibaba' | head -50` (filter the SYNC noise; remember host clock is WEST = UTC+1, LOG is UTC).

$0 · paper only · runner.sh/worker.sh untouched (catalog + staged proposal, per the job).
