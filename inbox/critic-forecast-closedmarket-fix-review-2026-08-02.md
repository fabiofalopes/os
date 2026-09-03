---
tags: [inbox, critic, quant, forecasting, ledger-row-1, decision-prep, adversarial-review]
date: 2026-08-02
status: Critic verdict; 
Curator: link from [[forecast-pilot-01]] Deviations + [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]]
related:
  - "[[forecast-pilot-01]]"
  - "[[quant-forecast-pilot01-preverdict-smoke-2026-08-01]]"
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[ledger]]"
---

# Critic Review — Row-1 Closed-Market Fetch Fix (2026-08-02)

> Adversarial pre-sign-off review of the two-stage `?id → ?id&closed=true` fetch fallback staged in [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]] §2 (NOT applied — Z2/Critic-gated). Read-only on the frozen note, the frozen code (`FROZEN`, `parse_outcome`, `verdict`, `brier`, `EXTREME`, hashes), and the capture set; live tests were read-only against the public gamma API, $0. No frozen pre-commitment moved.

## VERDICT (one screen)

**ENDORSE — apply with wording amendments (d). No KILL-level gap.** All four claims the human must trust **CONFIRMED with live evidence**:

- **(a) fetch-only: CONFIRMED.** The fix lives entirely in `fetch()` in both files. The verdict-day scoring path (`--from-snapshot` / `rows_from_snapshot`) makes **zero** network calls — the *only* `fetch()` call in the scorer is line 312 (live path). So the fix is structurally incapable of touching scoring math, the verdict ladder, `parse_outcome`, `brier`, `EXTREME`, or the integrity hashes. Selftest **ALL PASS**; FROZEN hashes reproduce exactly.
- **(b) capture-set invariant + no look-ahead: CONFIRMED.** `FROZEN` = 21 hardcoded IDs, iterated by `capture_live`; the per-ID fallback adds/removes nothing. `closed=true` is a **strict filter** — EMPTY for open markets (tested) — so the `if not data` fallback can never fire for an unresolved market: it surfaces only already-resolved outcomes. Forecasts + baseline are frozen in code and tamper-guarded; the fix cannot move them.
- **(c) §2 evidence reproduces: CONFIRMED.** Live re-smoke: **#19 → resolved-yes (o=1.0), 0 fetch-fails, 20 unresolved, 1/21 resolved → guard N<15 → INCONCLUSIVE (unchanged)**. The #19 closed record carries every field `parse_outcome`/`capture_live` consume.
- **(d) apply-job wording: ENDORSED with 3 amendments** — `bash -n` is wrong for Python (→ `py_compile`/`--selftest`), add exact integration point, add snapshot-backup + frozen-hash guard.

**What the human still owes (Z2, before 08-07):** ratify treatment **A** for #19 (score resolved-YES) per §3 of the smoke note. This review satisfies the **Critic** half of the gate; human sign-off on fix + #19=A remains owed. If neither happens by 09-02, the pipeline exits 2 and row 1 gets no verdict — the infra failure this fix prevents.

## (a) — "fetch only" : CONFIRMED

Evidence (all offline except the live re-smoke in (c)):

1. **Fix not yet applied** — `grep closed=true` over both files → no match. Matches the note's "staged, NOT applied."
2. **Scoring logic intact** — `python3 score_forecast_pilot01.py --selftest` → `ALL PASS` (11 cases + coverage grid).
3. **Frozen inputs unchanged** — recomputed the harness's informational hashes from live `FROZEN`: forge `fb6ce92417122fc5`, market `f301871bc99dca27` — **byte-identical** to the 08-01 smoke's reported values. 21 IDs, same list.
4. **Architectural proof the fix can't touch scoring** — the verdict-day path is `run_verdict.sh`: selftest → watcher live capture → snapshot → `scorer --from-snapshot` → `watcher --from-snapshot`. `rows_from_snapshot` (the `--from-snapshot` path) contains **no** `urlopen`/`urllib`/`fetch(` — it re-parses already-captured raw objects and **refuses a tampered capture** (verifies `mkt_p_capture`/`forge_p` against `FROZEN`, exit 2 on mismatch). The fix modifies only `fetch()`, which the scoring path never calls. ⇒ scoring math, verdict ladder, and hashes are untouched *by construction*, not just by inspection.

The fix changes **what is captured** (resolution outcomes for closed markets), never **how it is scored** or **the frozen inputs**. That is precisely the "fetch only" claim.

## (b) — capture-set invariant + no look-ahead : CONFIRMED

- **Set invariant:** `capture_live()` iterates the hardcoded 21-row `FROZEN`; `fetch(mid)` is called once per frozen ID; the fallback is per-ID and returns the same single record. No ID added/dropped. (Recomputed ID list matches the frozen batch exactly.)
- **Strict-filter / point-in-time test (the look-ahead crux), run live:**

  | market | `?id=X` bare | `?id=X&closed=true` |
  |---|---|---|
  | OPEN 2633430 | DATA | **EMPTY** |
  | OPEN 2955043 | DATA | **EMPTY** |
  | CLOSED 2761627 (#19) | **EMPTY** | DATA |

  `closed=true` returns EMPTY for open markets ⇒ the fallback condition `if not data` (bare empty) **can never fire for an unresolved market**. It surfaces *only already-resolved outcomes* — exactly what the frozen protocol's step 1 ("read `closed` and `outcomePrices`") intends. There is no path by which the fallback surfaces a not-yet-resolved outcome.
- **No forecast/baseline leak:** `forge_p` and `mkt_p` are frozen in code (captured 2026-07-21) and never written by `fetch`; `rows_from_snapshot` rejects any capture whose frozen values differ from `FROZEN`. Retrieving a market's *own final resolution* is the ground truth the pilot scores against — not look-ahead. The illegitimate look-ahead (changing forecasts/baseline/set after seeing outcomes) is structurally impossible here.
- **No replacement-market contamination:** #19's replacement series (id 3192360) is a *different* ID, never in `FROZEN`, never fetched. `closed=true` returns only the frozen ID's own record.
- **Monitor-mode note (not a violation):** post-fix the *provisional* snapshot will contain #19's public resolution earlier than before. That is not a point-in-time breach — forecasts stay frozen, the snapshot is a transient non-vault artifact overwritten each run, and only the on/after-09-02 capture is official (Critic G2). The resolution is public on polymarket.com; nothing insider enters anything.

## (c) — §2 test evidence reproduces : CONFIRMED

Live read-only re-smoke (imported the real `FROZEN` + `parse_outcome`; implemented the exact proposed two-stage fetch; ran all 21 IDs; no files written):

```
resolved=1/21  void=0  unresolved=20  fetch-failed=0
#19 (2761627): bare=EMPTY → fallback=yes → status=resolved-yes  outcome=1.0  closed=True
fallback fired for #19 ONLY; never for the 20 open markets
guard: N_resolved=1 < 15 → INCONCLUSIVE (unchanged)
```

Matches §2's post-fix expectation exactly (#19 resolved-yes · 0 fetch-fails · verdict still INCONCLUSIVE). #19's closed record (82 keys) carries every field consumed downstream — `outcomePrices`, `outcomes`, `closed`, `lastTradePrice`, `endDateIso`, `question` all present — so `parse_outcome` and `capture_live` see the exact shape they expect. (Current pre-fix watcher exits 1 partial on #19; post-fix 0 fetch-fails ⇒ exit 0, as the apply job's acceptance requires.)

## (d) — apply-job wording : ENDORSED, AMENDED

The staged wording's acceptance criteria are right, but **`bash -n` is a defect** — the fix is in two `.py` files, and `bash -n` checks shell syntax (it would pass vacuously or error, validating nothing). Amended wording to queue (Critic-gated, human sign-off still owed):

> `[Quant] forecast-scorer closed-market fetch fix — APPLY the two-stage ?id → ?id&closed=true fallback to fetch() in BOTH fetch_resolutions.py and score_forecast_pilot01.py (staged + Critic-endorsed in inbox/critic-forecast-closedmarket-fix-review-2026-08-02, tested in inbox/quant-forecast-pilot01-preverdict-smoke-2026-08-01 §2). Integration: inside the retry-loop try, insert `if not data:` → one GET of API+"&closed=true" (same UA/timeout), between `data = json.loads(...)` and the existing `if data and isinstance(data, list):` check, in BOTH fetch(). ACCEPTANCE: (1) python3 -m py_compile on both files + `score_forecast_pilot01.py --selftest` = ALL PASS; (2) back up the snapshot first (resolutions_pilot01.json.bak-YYYYMMDD-prefixfix); (3) re-smoke run_verdict.sh shows #19 resolved-yes, 0 fetch-fails, exit 0, watcher==scorer AGREE, verdict INCONCLUSIVE; (4) FROZEN hashes unchanged (forge fb6ce92417122fc5 / market f301871bc99dca27); (5) record in RESULT-note provenance. Z2 — human sign-off first (changes the official capture path).`

Amendments: **(1)** `bash -n` → `py_compile` + `--selftest`; **(2)** exact integration point specified (the §2 sketch is a sketch); **(3)** snapshot backup + frozen-hash guard added so the apply can't silently touch frozen inputs or lose the pre-fix capture.

## Gap log (kill-or-fix each)

| # | Gap | Verdict |
|---|---|---|
| 1 | `bash -n` validates nothing for `.py` edits | **FIX** — amended to `py_compile`+`--selftest` (d) |
| 2 | §2 diff is a sketch, not an exact patch | **FIX** — exact integration point specified (d) |
| 3 | Re-smoke overwrites the official snapshot | **FIX** — backup step added (d); monitor-overwrite is by design |
| 4 | Empty responses don't trigger the retry loop (returns immediately) | **NO CHANGE** — pre-existing in both versions, not introduced by the fix; out of scope. (Logged, not a gate.) |
| 5 | Could the fix manufacture a verdict? | **KILLED** — no: it completes the capture; verdict still flows from the frozen ladder; guard still INCONCLUSIVE at N<15. Without it, verdict day = exit 2 = *no* verdict. |
| 6 | Does the fix break the single-score-run lock (Critic G2)? | **KILLED** — no: scoring path (`--from-snapshot`) is untouched; still one official capture on/after 09-02. |
| 7 | Look-ahead via `closed=true`? | **KILLED** — strict filter (EMPTY for open markets, tested); fallback can't fire for unresolved markets; forecasts/baseline frozen + tamper-guarded. |

## Honest caveats

- I reproduced #19 (the one frozen closed market) + the open/closed matrix live; the note's 4 *non-frozen* test markets (2863245/1999423/2929609/2379995) I took as reported — same mechanism, not independently re-run here (cheap to add if the human wants).
- This review does not touch the frozen note, forecasts, hashes, protocol, or code — read-only on all; test scripts lived in /tmp. The fix remains staged, not applied.
- The #19 = A ratification is the human's call (Z2), owed before 08-07; this note endorses the *fix*, and records that A is the lock-legal treatment per §3.
