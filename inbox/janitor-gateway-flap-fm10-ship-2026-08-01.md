---
tags: [harness, failure-modes, gateway, ship, inbox]
date: 2026-08-01
status: SHIPPED + verified — W-2 promoted to FM-10 ([[FAILURE-MODES]]), checklist item 11 signed off
related:
  - "[[FAILURE-MODES]]"
  - "[[janitor-gateway-flap-diagnosis-2026-08-01]]"
  - "[[janitor-gateway502-guard5-ship-verify-2026-07-29]]"
---

# FM-10 Ship — Gateway Flap Counter + Oracle Alert (W-2 promoted)

> Janitor ship+verify. The 08-01 diagnosis ([[janitor-gateway-flap-diagnosis-2026-08-01]]) staged a flap counter + escalating hold + oracle alert for Guard-5's silent ~45-min hold loop; this session **verified the staged code end-to-end (41/41 sandbox), signed off the PRE-CHANGE CHECKLIST, and promoted W-2 → FM-10** in [[FAILURE-MODES]]. Guard-5 was already correct — this ships **memory + visibility**, not protection. $0, zero tokens burned by the suite.

## 0 · Provenance — this ship is the retry of a timed-out attempt

The code being shipped was written by the FIRST attempt at this job: it ran `2026-08-01T23:15→23:30Z` and died `TIMEOUT(900s)` with `(no output captured)` — but its file mtimes (23:23Z, mid-run) show it landed the runner.sh/config.env/oracle.sh changes before the kill, then died before testing or writing its artifact (the FM-6/FM-8 TIMEOUT-did-work-unrecorded family). No phantom credit: the job correctly stayed `[ ]` and FM-9 promoted the retry to the builder lane — this session. **Consequence: the staged code was UNVERIFIED when this session started** (it had been live on the cron working tree since 23:23Z with zero test coverage) — the sandbox below is the gate that attempt never completed.

## 1 · What shipped (staged bytes, verified unchanged)

- **`runner.sh`** — `gateway_flap_latch()` (`runner.sh:196`) at BOTH hold latch sites (`gateway_detect` `:151` reactive, `gateway_probe` `:173` active): `_harness/.gateway_flap` = `<count> <last_latch_epoch> <first_latch_epoch>`; in-window repeat (≤ `GATEWAY_FLAP_WINDOW_S`) → count++, else fresh series + stale marker dropped; corrupt file self-heals. Hold = `GATEWAY_HOLD_S × min(2^(count−1), GATEWAY_FLAP_CAP_MULT)` → 1800 → 3600 → 7200 → 7200s. At count ≥2 the runner writes `state/gateway_flap_alert` (rewrite-in-place, never stacks). `gateway_flap_clear()` (`:227`) on a CLEAN authenticated probe resets counter + marker. Kill switch `GATEWAY_FLAP=0` → exact pre-fix (fixed hold, no files, stale marker dropped). NO new LOG verdict token — the count rides the existing `GATEWAY_HOLD` message text (`(flap N in window — escalated, oracle alerted)`).
- **`oracle.sh:60-68`** — renders ONE line while the marker exists and the window is live: `**⚠ Gateway flap:** N holds in 6h — upstream egress degraded, engine auto-holding (FM-7 surface, self-heals)`; a stale marker (last latch > window) never renders.
- **`config.env`** — three dials: `GATEWAY_FLAP=1` (:37), `GATEWAY_FLAP_WINDOW_S=21600` (:48), `GATEWAY_FLAP_CAP_MULT=4` (:51). `SESSION_TIMEOUT` untouched (900 — the FM-2 hang guard).

**Design deviation (documented, deliberate):** the job said "alert appended to `_ORACLE-CURATED.md`"; the shipped design is marker-RENDERED into `_ORACLE.md` instead. Reason: `_ORACLE-CURATED.md`'s own header declares it hand-maintained ("To refresh: edit THIS file (not _ORACLE.md)") and the runner's contract is LOG/queue/state only — an engine append there would fight the Janitor refresh and break the substrate rule. The human-visible one-liner lands on the SAME one screen (`_ORACLE.md` includes the curated lead), which is what the job's rationale actually required ("nothing telling the human why"). The W-2 staged sketch in [[FAILURE-MODES]] already prescribed exactly this resolution.

## 2 · Done-evidence

- **`bash -n` clean** on runner.sh / worker.sh / oracle.sh / config.env.
- **Invariants:** no script writes `_ORACLE-CURATED.md` (the only grep hit is oracle.sh's READ of it into `_ORACLE.md`); `SESSION_TIMEOUT=900` unchanged; flap call sites at both latches + the clean-probe clear; Guard-2 exclusion list untouched (no new token → no four-counter classification, item 12).
- **Sandbox: 41/41 assertions** (real runner/worker/oracle bytes copied to `mktemp -d`, stub `claude`, stub upstream whose HTTP code flips 200↔502, real waves driven end-to-end; zero tokens; script `/tmp/forge-fm10-sandbox.sh`, ephemeral):
  - **(i) 2nd hold within window ⇒ escalated hold** — probe-latch (T2) AND reactive-latch (T4): 3600s hold + `(flap 2 in window — escalated, oracle alerted)` suffix + alert marker.
  - **(ii) alert on the human's screen on escalation** — oracle renders the flap line (T3); stale markers never render (T11); `_ORACLE-CURATED.md` never written (T14).
  - **(iii) single isolated hold ⇒ unchanged** — fixed 1800s, no marker, no suffix (T1).
  - **(iv) counter resets after a clean probe** — counter file + marker cleared, recovery wave dispatches + completes a job, and the NEXT storm starts a fresh series at the fixed hold (T5/T5b).
  - **Guards:** out-of-window latch resets + drops stale marker (T6); corrupt flap file self-heals, no wedge (T7); pre-existing corrupt-HOLD self-heal unchanged (T7b); escalation caps at 7200s (T8); kill switch = exact pre-fix incl. stale-marker drop (T9); Guard-2 counts exactly the 3 dispatched sessions with ALL `GATEWAY_*` lines excluded (T10); two infra 502 deaths at `MAX_JOB_RETRIES=2` never false-quarantine (T10); LOG stays valid UTF-8 (T12).
- **The suite caught two of its OWN bugs pre-ship** (not engine bugs): a squatter process holding the stub's port (moved to a free port + added a bind guard), and a stub emitting the 502 error on two lines where the production CLI emits one — the latter is a real finding: `fail_streak`'s infra classification reads the LOG SUMMARY (last output line), so it only matches because the production error is single-line; the test now pins that shape.
- **Production smoke:** no flap recurrence since 08-01 15:45Z and zero escalation lines in LOG → the escalation/alert path awaits its first production firing (both historical flaps pre-date the breaker); the new clean-probe path ran on the only wave since the code landed (23:30Z — dispatch proceeded, no flap state written) and on this ship wave; Guard-2 live `grep -c` (no `-a`) = 95 (trail unpoisoned); queue intact (done=84 pending=1 quarantined=0); no flap state files present.
- **Catalog:** W-2 → **FM-10** in [[FAILURE-MODES]] (house-style entry: symptom/LOG evidence/root cause/breaker/verification/regression check); watch-items next number rolled to FM-11 (W-1's two stale "FM-10" references updated); checklist **item 11 ✅ SIGNED OFF 2026-08-01**; verdict vocabulary extended.

## 3 · Honesty notes

- **Promotion was directive-driven, below the death bar.** The watch-item trigger (3rd occurrence / ≥3 consecutive cycles) had NOT fired — 2 zero-burn occurrences. The death bar protects against shipping unearned PROTECTION breakers; FM-10 changes no protection (the fixed hold still catches every first burst) — it adds memory + an alert, so the evidence standard is the sandbox, not a body count. Recorded in the FM-10 entry's "Promotion note".
- **Escalation's value is NOT token savings** — the probe costs ~1 token. It buys log quiet + the human-visible alert during a silent multi-hour stall (on a builder cadence, ~3 skipped waves per 90 min, previously with nothing saying why).
- **Recovery latency trade:** the 7200s cap means up to ~2h between recovery probes during a long outage — acceptable because the probe is ~free and a clean probe (or any dispatching wave after expiry) clears the marker immediately.

## 4 · Regression check + kill switch

- ≥2 `GATEWAY_HOLD` lines inside 6h WITHOUT the `(flap N …)` suffix = no-memory loop recurred; a multi-hour flap with no `⚠ Gateway flap` line in `_ORACLE.md` = alert-path failure (marker/oracle chain).
- Misbehavior → `GATEWAY_FLAP=0` (`config.env:37`): fixed 1800s holds, marker dropped, exact pre-fix — never a wedge.

**Follow-ups:** none blocking. W-1 (connection-closed classifier disagreement) remains the open watch item; its next number is now FM-11.
