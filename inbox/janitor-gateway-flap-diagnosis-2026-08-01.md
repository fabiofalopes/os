---
tags: [harness, failure-modes, gateway, diagnosis, inbox]
date: 2026-08-01
status: diagnosis complete — cataloged as WATCH ITEM W-2 in [[FAILURE-MODES]] (NOT promoted to FM-10: zero burns, no new root cause)
related:
  - "[[FAILURE-MODES]]"
  - "[[janitor-gateway502-guard5-ship-verify-2026-07-29]]"
  - "[[quant-pilot-03]]"
---

# Gateway 502 Flap Diagnosis — 2026-08-01 (FM-7 surface, candidate W-2)

> Janitor read-only diagnosis. The localhost:8705 gateway flapped twice in 45 min (LOG 14:15Z HOLD → 15:00Z RESUMED → 15:00:10Z re-HOLD → 15:45Z resumed). Verdict: **same degraded-upstream pattern as the 07-28 storm (FM-7), NOT a new one; ~1/25 the scale; Guard-5 behaved exactly as designed (0 tokens, jobs preserved, self-healed). Cataloged W-2, not FM-10 — zero sessions burned, no new root cause.** Staged proposal: flap counter + escalating hold + one-line Oracle alert (not shipped).

## 1 · Verdict — same pattern as 07-28, tested not vibes

**Signature match (journal, host clock WEST = UTC+1):** exactly TWO upstream fetch-fail bursts today, each 4× `[proxy] Request failed (attempt 1..4): fetch failed [retryable]` — byte-identical to the FM-7 07-28 signature (socket/DNS-level egress to Alibaba MaaS; router healthy, listening, never restarted — single PID 27609, the only start events today are 02:10/02:15 local boot, 12h before the flap).

| burst (local → Z) | aligned LOG event | outcome |
|---|---|---|
| 15:15:01→10 local = **14:15:01→10Z** | `14:15:10Z GATEWAY_HOLD` (line 1137) | probe attempt 4 fails at the exact HOLD timestamp |
| 16:00:02→10 local = **15:00:02→10Z** | `15:00:10Z GATEWAY_HOLD` (line 1142) | the re-probe, 9s after `15:00:01Z GATEWAY_RESUMED` |
| 16:45:01 local = **15:45:01Z** | `15:45:01Z GATEWAY_RESUMED` (line 1146) | probe CLEAN (SYNC, zero fetch fails) → Steward dispatched 15:45:04Z, ok 15:49:24Z |

**Scale:** day-total = **8 upstream fetch fails, all inside the two probe bursts** (zero outside — no session traffic during the holds; demand-driven visibility, exactly as 07-28). vs 07-28: 204 fetch fails over ~24h in 4 session bursts. ~90 min window vs ~24h.

**Guard-5 scorecard (FM-7 regression check PASSES):** 6 waves 14:15→15:30Z all `| 0s | SKIP(GATEWAY)` (lines 1137–1145); zero `exit1`+502 sessions today — the one grep hit (line 1105) is a `| 502s | ok |` catalog-sync job (502-**second** runtime, false positive). Jobs preserved; engine resumed and dispatched normally post-15:45Z (Critic row-5 ok 16:25Z, Quant row-1 smoke ok 16:55Z). Total cost of the flap: ~2 probe tokens.

## 2 · Flap risk quantified (from today's timing)

The loop: latch(T) → hold 1800s → expire T+1800 → cleared on first wave after expiry → **same wave probes → still-502 → re-latch ~9s after RESUMED** → repeat.

- **Loop period ≈ 45 min** = 1800s fixed hold + up to 900s wave-cadence wait. Measured both cycles today: expiry 14:45:10 → cleared 15:00:01 (**+891s**); expiry 15:30:10 → cleared 15:45:01 (**+891s**).
- **Today:** 2 cycles, **~90 min engine idle** (14:15:10→15:45:01Z), ~0 tokens, 0 burns. Cost ≈ 0 *because the queue was empty* (reflection-throttled since 12:30Z).
- **Extrapolation (aspiration until a 3rd occurrence):** a 07-28-scale 24h outage → **~32 flap cycles ≈ 24h of silent engine dark** — no escalation, no alert anywhere. The probe costs ~1 token, so escalation's value is NOT token savings — it is (a) log-noise and (b) **the missing human-visible alert**. That is the real gap: Guard-5 is correct but silent.
- **Mid-campaign cost:** on an active builder cadence (`BUILDER_EVERY=2` → 30 min), a 90-min stall skips ~3 builder waves with nothing telling the human why.

## 3 · Why W-2, not FM-10

House promotion rule ([[FAILURE-MODES]] watch-items header): "≥2 same-day deaths, or a 3rd standalone occurrence." Today had **zero deaths** — Guard-5 caught everything; the FM bar is deaths/burns. The flap shape has now occurred twice (07-29 lines 865–874 — the ship day, 2 cycles; 08-01 — 2 cycles), 3 days apart, both self-healed. Root cause is FM-7's already-cataloged root (degraded upstream egress; laptop network/DNS suspected, NOT verified) — no NEW root cause to promote on. → **WATCH ITEM W-2** with a staged promotion trigger, mirroring W-1's treatment.

## 4 · Staged proposal — flap counter + escalating hold + alert (NOT shipped)

Mirrors the FM-3/FM-7 breaker style; touches the latch path only (`gateway_probe`/`gateway_detect`, `runner.sh:151,167`).

1. **Flap state:** `_harness/.gateway_flap` = `<count> <window_start_epoch>`. On every hold latch (probe OR reactive): if the previous latch was within `GATEWAY_FLAP_WINDOW_S=21600` (6h) → count++; else reset to 1. Corrupt/expired file self-heals (mirror the quota/gateway hold readers).
2. **Escalating hold:** `hold = GATEWAY_HOLD_S × min(2^(count-1), GATEWAY_FLAP_CAP=4)` → 30m → 60m → 120m → 120m. Caps recovery-detection latency at 2h (the probe is ~free, so the cap buys log quiet, not tokens — honest framing).
3. **Alert (the real deliverable):** when count crosses 2 within the window, write ONE de-duplicated line into `_ORACLE-CURATED.md` (survives `oracle.sh` regeneration — the human's one screen, per [[oracle-signal-not-noise]]): `⚠ W-2 gateway flap: N holds in 6h — upstream egress degraded, engine auto-holding (FM-7 surface, self-heals)`. Rewrite-in-place, never stack; clear on 24h clean.
4. **Kill switch:** `GATEWAY_FLAP=0` (`config.env`) → fixed 1800s hold, no flap file, no alert — pre-fix behavior, never a wedge.
5. **Regression check (sandbox, stub-claude, 0 tokens):** (i) 2 probe-502 latches within window ⇒ 2nd hold = 2× duration + exactly ONE alert line; (ii) latch after window expiry ⇒ count resets to 1, fixed hold; (iii) `GATEWAY_FLAP=0` ⇒ pre-fix; (iv) corrupt flap file self-heals with no LOG leak; (v) hold round-trip + infra classification + builder/council suppression unchanged (checklist item 11 re-run).
6. **Checklist:** append to PRE-CHANGE CHECKLIST item 11 (gateway probe) — the W-2 note is staged there now.

## 5 · Matters beyond engine health — [[quant-pilot-03]]

Pilot-03 claims **zero new fetch** (frozen S&P-500 panel reuse, Critic-verified 08-01) — so a row-4-style fetch storm **cannot** corrupt its data; the panel is on disk. W-2's risk to a pilot-03 builder run is the silent mid-run wave stall (Guard-5 holds the WHOLE wave, builder included) — self-heals, delays not corrupts. The surface that actually birthed row-4's 49.8% fetch_fail (DIRECT SEC egress, laptop network) does **not** traverse :8705 (tested in [[quant-pilot-02-RESULT]]) and remains outside Guard-5's visibility — that is a quant-harness concern, out of W-2's scope.

## Evidence index

- LOG.md lines 1137–1146 (today's flap), 865–874 (07-29 flap), 1105 (false-positive exit1+502 grep hit); line numbers drift — grep the timestamps.
- `journalctl --user -u universal-router` 2026-08-01 15:00–18:20 local: 8× `fetch failed` in 2 bursts; clean probe 16:45:01 local; single PID 27609.
- Guard-5 code: `runner.sh:111-128` (hold/resume), `:148-168` (`gateway_detect`/`gateway_probe`), `:443-450` (Guard 5b); `GATEWAY_HOLD_S=1800` / `GATEWAY_PROBE=1` in `config.env`.
