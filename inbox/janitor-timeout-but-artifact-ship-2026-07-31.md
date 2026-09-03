---
tags: [janitor, builder, harness, ship, incident-6, inbox]
date: 2026-07-31
role: Janitor
status: durable — SHIP + VERIFY evidence for the FM-6 timeout-credit breaker (the FM-8 ship's named follow-up)
---

# FM-6 TIMEOUT(BUT_ARTIFACT) CREDIT — SHIPPED

> **Verdict (one screen):** the open gap named by [[janitor-phantom-completion-fix-ship-2026-07-29]] is closed for its primary mechanism. A session that TIMES OUT *after its artifact already landed* is no longer logged as a bare `TIMEOUT` and re-dispatched to redo done work — it is now credited `[x]` as `TIMEOUT(BUT_ARTIFACT)` via the SAME `artifact_gate()` the ok-lane uses. **26/26 sandbox assertions green** (stub-claude, zero tokens), `bash -n` clean on all four touched scripts, production smoke HEALTHY. The suite caught + fixed a real cross-wave phantom-credit bug before ship. Cataloged as [[FAILURE-MODES]] FM-6 (breaker shipped) + checklist item 13 (signed off). $0, no capital. `SESSION_TIMEOUT` untouched.

## The disease (FM-6 primary mechanism)

The FM-8 artifact oracle made `[x]` require a landed artifact on the **ok** lane — but a `TIMEOUT` verdict still meant "process fate", the mirror image of the SCORE phantom: there exit 0 lied "done" (no work); here exit 124 lies "failed" *after the work landed*. The 07-29 window burned ~3600s this way (LOG 02:15/03:45/07:45/09:30Z): each timed-out session had written its artifact, stayed `[ ]`, and the retry found the work done and took the credit. Neither verdict answered "did the artifact land?"

## What shipped

1. **`artifact_gate()` handles `TIMEOUT*`** (`runner.sh:185`). If the captured `PRODUCED` path exists, it rewrites the verdict to `TIMEOUT(BUT_ARTIFACT)` and marks `[x]` via the identical `-e` path check the ok-lane uses. A bare `TIMEOUT` (no marker / `NONE` / missing path) is returned unchanged → stays `[ ]` → re-dispatch + quarantine. The trust-bug guard stands; `SESSION_TIMEOUT` deliberately NOT raised.
2. **`timeout_artifact()` mtime fallback** (`runner.sh`, after `artifact_gate`). When the kill beat the marker (`produced` empty), the collect phase recovers the artifact by scanning the durable trees for a `.md` modified in-window — mirroring evaluate.sh's SUCCESS heuristic. Fed into `artifact_gate`, which does the existence check + `[x]`. Wired into BOTH collect lanes (worker + builder).
3. **Two phantom-credit guards** (the whole point — this harness must NEVER false-`[x]`):
   - **Wave-start lower bound.** The window is `[WAVE_START, now+90]`, where `WAVE_START` is sampled before dispatch. mtime and the bound are the same kernel clock, so a PRIOR wave's artifact (mtime < wave start) is structurally excluded — no backward slack (any slack re-admits the previous wave's last write).
   - **Exactly-one.** With >1 in-window artifact (parallel siblings in this wave wrote too) attribution is ambiguous → no credit → safe re-dispatch. Never a false `[x]`.
4. **Four-counter classification** (checklist item 12's rule): `TIMEOUT(BUT_ARTIFACT)` is bookkeeping in Guard-2 exclusion (`runner.sh:70`), `fail_streak` skip (`runner.sh:178`), health.sh `NONSESSION` (`health.sh:26`), and evaluate.sh bookkeeping skip (`evaluate.sh:73`) — like `ok(DEFERRED)`. A BARE `TIMEOUT` is deliberately absent from `fail_streak`'s skip list, so it still counts as a REAL fail and still quarantines after `MAX_JOB_RETRIES`.

## Done-evidence (the three required gates + guards + regressions)

Sandbox = fresh `mktemp -d` vault per scenario + stub `claude` (canned behavior via `$STUB_MODE`, per-PID artifacts), driving real `runner.sh` waves; zero tokens. **26/26 PASS**:

- **(i)** timeout-with-artifact (captured marker) ⇒ `[x]`, logs `TIMEOUT(BUT_ARTIFACT)`, no bare `TIMEOUT` line, not quarantined, **never re-dispatched** (a 2nd wave leaves it `[x]`, count stays 1) ✓
- **(i-b)** timeout-with-artifact, kill beat the marker ⇒ `[x]` via the mtime-in-window fallback ✓
- **(i-c)** 2 PARALLEL siblings each write ⇒ NEITHER credited (both stay `[ ]`, 2 bare `TIMEOUT`s) — the exactly-one guard ✓
- **(i-c2)** a PRIOR-wave artifact (mtime 5 min before wave start) ⇒ NOT credited to this wave's lone timeout — the wave-start guard ✓
- **(i-d)** timeout + `PRODUCED:NONE` ⇒ conservative bare timeout, stays `[ ]` (no demonstrable artifact) ✓
- **(ii)** timeout-without-artifact ⇒ stays `[ ]` across waves 1–3, quarantined `[!]` on wave 4 (3 bare `TIMEOUT`s + 1 `QUARANTINED`), never credited ✓
- **(iii)** all four counters classify the token: Guard-2 counts 2 (ok+bare) excluding `BUT_ARTIFACT`; health `NONSESSION` same; `fail_streak` = 0 for `BUT_ARTIFACT` but 1 for a bare `TIMEOUT`; evaluate skips `BUT_ARTIFACT` (not bucketed), counts the ok session `SUCCESS 1`, bare `TIMEOUT` ⇒ `INFRA 1` ✓
- **FM-8 regression gates** (artifact_gate ok-lane unchanged after the restructure): ok+artifact ⇒ `[x]`; ok+NONE ⇒ `[x]`; ok+no-marker ⇒ `ok(NO_ARTIFACT)` stays `[ ]`; `DEFERRED` ⇒ `ok(DEFERRED)` stays `[ ]` ✓
- **Syntax + smoke:** `bash -n` clean on runner/worker/evaluate/health; production `health.sh` HEALTHY (`runs today: 2`, evaluate `SUCCESS 1 / INFRA 1`, queue done=65 pending=1) ✓

## The suite caught a real ship-blocking bug (fixed before ship)

The first mtime window was `[now-dur-90, now+90]`. With `dur≈900` that reaches ~16 min back — **into the prior wave**. In the sandbox (waves seconds apart) an empty-queue reflection was falsely `[x]`'d from wave-1's leftover artifact (the `TIMEOUT(BUT_ARTIFACT)` count went to 2). In production the same overlap exists: a 900s-timeout window spans the previous wave's artifacts, so a quiet-period timeout could have been credited a neighbor's work — a phantom `[x]`, the exact thing FM-8 forbids. Fix: bound the window below at the wave-start epoch (sampled before dispatch; same kernel clock → no slack needed). `(i-c2)` now proves a prior-wave artifact is never credited.

## Transition + open items

- New code takes effect NEXT wave (this session ran under the old scripts already in memory — bash buffers the whole script at launch; the FM-4a/FM-7/FM-8 in-wave ships established this cutover is clean). This session's own verdict is collected by the OLD runner normally.
- **Still open (FM-6 (b)):** the bridge merging a proposal that duplicates a job already in the queue — a separate mechanism, not touched here. FM-6's title now reads "timeout-credit breaker SHIPPED (bridge-duplicate sub-case still open)".
- **Standing monitor:** the first production `TIMEOUT(BUT_ARTIFACT)` line confirms the path live; any future day where a job shows BOTH a `TIMEOUT(BUT_ARTIFACT)` and a later `ok` for the same text = the credit failed to prevent a re-dispatch (the FM-6 watch signal).

$0, diagnose-already-paid by [[janitor-phantom-completion-diagnosis-2026-07-29]] + [[janitor-phantom-completion-fix-ship-2026-07-29]]; this session implemented + verified. No capital.

PRODUCED: inbox/janitor-timeout-but-artifact-ship-2026-07-31.md
