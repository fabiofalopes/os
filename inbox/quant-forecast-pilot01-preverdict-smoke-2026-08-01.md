---
tags: [inbox, quant, forecasting, smoke-test, decision-prep, ledger-row-1]
date: 2026-08-01
status: raw — Curator: triage (link from [[forecast-pilot-01]] Deviations; supersedes the #19 "pulled" diagnosis there)
related:
  - "[[forecast-pilot-01]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[ledger]]"
---

# Forecast Pilot 01 — Pre-Verdict Smoke + #19 Decision Material (2026-08-01)

> Rehearsed verdict day 6 days before the first resolution (#11, 2026-08-07; score day ≥2026-09-02). The smoke found one **systemic verdict-day-breaking bug** and **resolved the #19 question**: it is not void/ambiguous — it resolved **YES**, and the "pulled market" diagnosis in [[forecast-pilot-01]] was an artifact of the bug below. $0, public Polymarket gamma API only (the documented Metaculus→Polymarket pivot; the queue spec's "Metaculus" is stale wording).

## VERDICT (one screen)

1. **Pipeline health: GREEN except one systemic bug.** Selftest ALL PASS · watcher==scorer AGREE · 20/21 live markets parse cleanly (no API schema drift, no stale IDs, no scorer crash) · verdict INCONCLUSIVE at 0/21 resolved, exactly as pre-committed.
2. **THE BUG (headline):** the gamma API's `/markets?id=<ID>` endpoint **returns `[]` for closed markets by default**. Every market resolved by 2026-09-02 will therefore FETCH-FAIL → watcher exit 2 → **no verdict at all on verdict day**. Today's exit 1 (partial) is the same bug's first symptom — #19 is simply the first batch market to have closed. The harness never exercised the closed-market path (the 07-22 smoke hit 0 resolutions). **Fix staged + fully tested below; NOT applied (Z2/Critic-gated — it changes the official capture path).**
3. **#19 (2761627, "Next Claude Opus released by Aug 31"): RESOLVED YES** — verifiable right now via `/markets?id=2761627&closed=true` (`closed: true`, `outcomePrices: ["1","0"]`); the scorer's own `parse_outcome` returns `resolved-yes`. The owed void/exclude call is **moot if the fix is approved** — the faithful treatment is to score it YES. Decision material + recommendation in §3; human/Critic call owed before 08-07.

## §1 — Smoke evidence (ran 2026-08-01 ~16:47Z)

`bash ~/Projects/forecast-scorer/run_verdict.sh` end-to-end, live:

- `[0/3] preflight: selftest: ALL PASS` — criterion logic intact.
- `[1/3] fetch`: 20/21 OK, all 20 `unresolved` with valid `outcomePrices`/`lastTradePrice` — **no schema drift** on the live path. #19 `FETCH-FAILED: empty/unexpected response`.
- `[2/3] score` (offline on snapshot) + `[3/3]` watcher replay: **watcher == scorer AGREE**, both `INCONCLUSIVE`.
- Tallies: **resolved 0/21 · void 0 · unresolved 20 · fetch-failed 1** → guard `N_resolved=0 < 15`.
- **Exit code 1** (partial), not 0 — caused solely by #19. This is the documented partial lane, and (new diagnosis) the early symptom of §2's bug. No exit 2/3/4; no crash.
- Integrity: binding guarantee (FROZEN import, single source) intact; informational hashes unchanged since 07-27 (`fb6ce92417122fc5` / `f301871bc99dca27`; still ≠ Critic-recorded serialization — documented, not a hard gate).
- Snapshot rewritten by the run (monitor-mode design); the 07-27 copy preserved at `resolutions_pilot01.json.bak-20260801-preverdict-smoke` (prior art: `.bak-20260727-recon`).

### Resolution status of all 21 (live, 2026-08-01)

| # | Domain | ID | Status | M(cap) → now | F |
|---|---|---|---|---|---|
| 1 | A-Geopol | 2633430 | unresolved | 0.075 → 0.038 | 0.06 |
| 2 | A-Geopol | 2774056 | unresolved | 0.14 → 0.065 | 0.13 |
| 3 | A-Geopol | 2937527 | unresolved | 0.515 → 0.485 | 0.45 |
| 4 | A-Geopol | 2686771 | unresolved | 0.465 → 0.415 | 0.45 |
| 5 | A-Geopol | 2602052 | unresolved | 0.075 → 0.065 | 0.07 |
| 6 | A-Geopol | 2641010 | unresolved | 0.0315 → 0.019 | 0.03 |
| 7 | A-Geopol | 2911874 | unresolved | 0.165 → 0.075 | 0.14 |
| 8 | B-Macro | 2925075 | unresolved | 0.445 → 0.415 | 0.40 |
| 9 | B-Macro | 2925076 | unresolved | 0.27 → 0.215 | 0.25 |
| 10 | B-Macro | 2810507 | unresolved | 0.2505 → 0.247 | 0.27 |
| 11 | B-Macro | 2775407 | unresolved — **first to resolve, 08-07** | 0.395 → 0.415 | 0.38 |
| 12 | B-Macro | 2234098 | unresolved | 0.92 → 0.988 | 0.90 |
| 13 | B-Macro | 2925106 | unresolved | 0.665 → 0.645 | 0.65 |
| 14 | B-Macro | 2321905 | unresolved | 0.365 → 0.275 | 0.35 |
| 15 | C-AI/Tech | 2955043 | unresolved | 0.905 → 0.955 | 0.85 |
| 16 | C-AI/Tech | 2955045 | unresolved | 0.052 → 0.022 | 0.06 |
| 17 | C-AI/Tech | 2955048 | unresolved | 0.0265 → 0.024 | 0.03 |
| 18 | C-AI/Tech | 2850825 | unresolved | 0.26 → 0.16 | 0.22 |
| **19** | C-AI/Tech | **2761627** | **RESOLVED-YES (early)** — visible only via `&closed=true` (§3) | 0.946 → 1.0 | 0.90 |
| 20 | C-AI/Tech | 2941315 | unresolved | 0.68 → 0.745 | 0.65 |
| 21 | C-AI/Tech | 2853384 | unresolved | 0.044 → 0.021 | 0.04 |

**Summary: 1 resolved (YES, early — #19), 20 open, 0 voids.** "Now" prices are diagnostic only — forecasts and baseline M are frozen. Notable drift vs capture: #2, #7 halved (de-escalation); #12 → 0.988 (RBA hold near-certain); #18 → 0.16 (GPT-6 odds slipped).

## §2 — The verdict-day bug (found by the smoke; root-caused + fix tested)

**Symptom:** `GET https://gamma-api.polymarket.com/markets?id=<ID>` (browser UA) returns `[]` for **closed** markets. Both harness files use this bare URL (`fetch_resolutions.py:68`, `score_forecast_pilot01.py:60`).

**Evidence (all four matrix cells tested live today):**

| market state | `?id=X` (bare) | `?id=X&closed=true` |
|---|---|---|
| open (2633430, + the 19 other batch markets) | DATA ✓ | EMPTY |
| closed (2863245, 1999423, 2929609, 2379995, 2761627) | **EMPTY** (4/4) | DATA ✓ |

So `closed=true` is a **strict filter**, not an include — the fix must be two-stage, never an unconditional param add.

**Verdict-day consequence (as built today):** by 2026-09-02 all 21 markets are closed → 21/21 FETCH-FAILED → watcher exit 2 → `run_verdict.sh` exit 2 → **total fetch failure, no verdict** — the exact failure the frozen protocol's browser-UA design meant to prevent (it guarded against 403s; the real failure mode is the closed-market default filter). The 07-22 smoke could not catch this: 0/21 were resolved then. The 07-27 #19 "pulled from Polymarket" finding ([[forecast-pilot-01]] Deviations) was the first encounter — misdiagnosed as a #19-specific delisting because no known-closed market was ever probed for comparison.

**Staged fix (tested, NOT applied — Z2/Critic gate: it changes the official capture path):** in `fetch()` in BOTH files, on an empty response retry once with `&closed=true`:

```python
# fetch_resolutions.py fetch() and score_forecast_pilot01.py fetch()
data = ...  # existing GET ?id={mid}
if not data:                       # closed markets are hidden by the default filter
    req2 = urllib.request.Request(API.format(mid=mid) + "&closed=true", headers=UA)
    with urllib.request.urlopen(req2, timeout=TIMEOUT) as r:
        data = json.loads(r.read().decode())
```

Verified downstream: the closed record's shape is exactly what `parse_outcome` consumes — `parse_outcome(#19 live record) = (1.0, 1.0, 'resolved-yes')` (EXTREME=0.999). Post-fix re-smoke expectation: #19 shows `resolved-yes`, tallies 1/21 resolved · 0 fetch-failed, exit 0, verdict still INCONCLUSIVE (N<15). **Legitimacy:** the frozen protocol's step 1 says "read `closed` and `outcomePrices`" from this API — impossible for resolved markets at the bare URL, so this is a mechanical repair in the protocol's own spirit, but it must be Critic-reviewed + human-approved before the single score run, and recorded in the RESULT note's provenance.

**Fallback if the fix is NOT approved by 09-02:** the frozen protocol's manual fallback (open `polymarket.com/market/<slug>`, read the resolution banner) still works; all 21 slugs are archived in the snapshots (07-23 backup has all 21 incl. #19; 08-01 snapshot has the 20 open ones).

## §3 — #19 decision material (owed before 08-07; the call is the human's, Z2)

**Current state (live, via `?id=2761627&closed=true`):** `closed: true` · `outcomePrices: ["1","0"]` (YES) · `outcomes: ["Yes","No"]` · `lastTradePrice: 0.999` · `endDate: 2026-08-31` · slug `will-the-next-claude-opus-model-be-released-by-august-31-2026-20260701204710233-223-869-558-982`. The original event (`/events?slug=next-claude-opus-released-byptptpt-20260701204710232`) shows the whole series resolved YES: Jul-24 YES (2925816) with Jul-23 NO (3044465) and Jul-22 NO (2934926) → **the next Claude Opus model was released 2026-07-24 (ET)**; Jul-27/Jul-31/Aug-31/Oct-31/Dec-31 all YES. A **replacement series** was created 2026-07-27 14:23Z (`...20260727142323912`): new "by Aug 31" market (id 3192360) at **0.065 YES**, Oct-31 0.53, Dec-31 0.905 — i.e., "next Opus" now means the one *after* the ~07-24 release. (Which model name: not established by this evidence — no independent news access, the pilot's documented handicap; the executing environment references `claude-opus-4-8` as current, unverified here.)

**Archived criterion (07-23 snapshot, pre-delisting):** "resolves Yes if Anthropic's next Claude Opus model is made available to the general public by the specified date"; Opus-named models only (Sonnet/Haiku/Fable/Mythos explicitly excluded); public access incl. open beta/waitlist; "primary resolution source … official information from Anthropic, with additional verification from a consensus of credible reporting." → **public and deterministic; it in fact resolved cleanly.**

**What the frozen exclusion lock prescribes ([[forecast-pilot-01]]):** "no question may be removed from the batch except for a documented falsifiability failure (criterion proven non-public or non-deterministic) — never for score or price-drift reasons." The criterion is public, deterministic, and resolved → the carve-out does **not** apply → **exclusion is lock-illegal.** The frozen void definition ("closed without extreme outcomePrices, or still-unresolved at the score run") does not fit either: #19 is closed *with* extreme prices. The protocol simply never anticipated its own API endpoint hiding closed markets — that is §2's bug, not a #19 ambiguity.

**The three treatments, with exact Brier arithmetic** (F=0.90, M=0.946; contribution to the BS sum, ÷N over the batch):

| Treatment | o | F adds | M adds | C adds | N / voids | Lock-legal? |
|---|---|---|---|---|---|---|
| **A — score resolved-YES** (via §2 fix) | 1 | 0.010000 | 0.002916 | 0.250000 | 21 / 0 | yes — the frozen rule applied as written |
| B — void | 0.5 | 0.160000 | 0.198916 | 0.000000 | 21 / **1** | strained — treats a known resolution as unknown; and it **spends the void budget**: one more void at score time → ≥2 voids → INCONCLUSIVE, no verdict at all |
| C — exclude | — | — | — | — | 20 / 0 | **no** — no falsifiability failure exists; also the current harness *default* (silent drop of fetch-fails = de-facto exclusion without the lock's gate — precisely why the call is owed) |

Note B is not outcome-neutral: the void penalizes M (0.199) more than F (0.160) because F sat closer to 0.5 — it mechanically favors Forge, another reason the honest call is A. (M beats F on this one market, 0.0029 vs 0.0100 — fine; it is 1 of 21.)

**Recommendation (agent draft, Z2):** approve the §2 fix and treat #19 as **resolved-YES (A)**. Then no exclusion lock question arises at all — the batch stays 21/21, scored on reality. **What the human must choose, before 08-07:** (1) approve/reject the two-stage fetch fix (Critic-reviewable; exact diff + test transcript above); (2) ratify treatment A for #19 (or, rejecting the fix, pick B/C with the consequences above recorded). If neither happens before 09-02, the pipeline exits 2 and row 1 gets no verdict — an infra failure the rehearsal exists to prevent.

## Follow-ups (workers can't edit [[queue]]; runner/Curator to action)

1. **Queue, Critic-gated:** `[Quant] forecast-scorer closed-market fetch fix — apply the two-stage ?id → ?id&closed=true fallback to fetch() in BOTH fetch_resolutions.py and score_forecast_pilot01.py (staged + tested in inbox/quant-forecast-pilot01-preverdict-smoke-2026-08-01 §2); bash -n + re-smoke must show #19 resolved-yes, 0 fetch-fails, exit 0; record in RESULT-note provenance. Z2 — Critic + human sign-off first (changes the official capture path).`
2. **Human/Critic before 08-07:** the §3 decision (fix approval + #19 = A). Supersedes the "void/exclude owed" framing in [[forecast-pilot-01]] Deviations and the 10:17Z Oracle flag.
3. **Curator:** link this note from [[forecast-pilot-01]] Deviations (the #19 diagnosis there is corrected here, evidence-linked); [[repos]] already should carry `~/Projects/forecast-scorer/`.

## Honest caveats

- No independent news access (documented pilot handicap): release date/name from sibling-market resolutions only; the ~07-24 date is ET-bracketed by daily markets, not news-confirmed.
- This note does not touch the frozen note, the forecasts, the hashes, or the protocol — read-only on [[forecast-pilot-01]]; the fix is staged, not applied.
- Monitor-mode snapshot overwrite is by design; 07-27 copy backed up first.
