---
tags: [harness, failure-modes, janitor, session-record]
date: 2026-08-01
status: done — catalog verified current, W-1 watch item added, INDEX fix staged
related:
  - "[[FAILURE-MODES]]"
  - "[[janitor-first-timeout-builder-promotion-2026-08-01]]"
  - "[[janitor-timeout-but-artifact-ship-2026-07-31]]"
---

# FAILURE-MODES Catalog Sync — 2026-08-01

**Verdict: the catalog was ALREADY current on the three breakers (the job's premise was stale by one session); the real work was the W-1 watch item, one latent defect found + recorded, and the INDEX fix staged.**

## What I verified (test, don't wonder)

The job said "catalog reads FM-1→FM-7" — wrong as of dispatch: the FM-9 ship session (`2026-08-01T02:03:05Z ok`, LOG line 1088) had already synced the catalog to FM-1→FM-9, header included ("Nine incident classes in the engine's first 13 days"). All three breaker entries exist in house style (symptom / LOG evidence / root cause / shipped breaker / regression check):

| Breaker | Catalog entry | Assertions | Checklist | Cross-check |
|---|---|---|---|---|
| FM-6 TIMEOUT(BUT_ARTIFACT) credit (07-31) | FM-6 section | 26/26 | item 13 ✅ signed | [[janitor-timeout-but-artifact-ship-2026-07-31]] |
| FM-8 follow-up DEFERRED hold / Guard-6 (07-31) | FM-8 follow-up section | 27/27 | item 14 ✅ signed | field-anchored LOG sweep, below |
| FM-9 first-timeout builder promotion (08-01) | FM-9 section | 23/23 | item 15 ✅ signed | LOG 1085→1086→1088 |

- **FM-9 production promotion confirmed:** LOG line 1085 worker-lane `TIMEOUT(900s)` `01:00:05Z` → line 1086 `[builder]`-prefixed retry `01:15:50Z` (first production promotion, fired on the ship job itself) → line 1088 `ok` 1080s `02:03:05Z` (breaker landed).
- **Guard-6 production-verified, field-anchored (not plain grep):** exactly **16** `SKIP(DEFERRED_HOLD)` verdict lines (`$3` match), `2026-07-31T19:45:01Z → 2026-08-01T05:00:01Z`, **all `| 0s |`**, zero sessions spawned. Plain `grep -c` says 21 — the extra 5 are job-text quotations inside BRIDGE/TIMEOUT bodies (the same trap as below). The job's "since 19:32Z" was approximate; verified first hold = 19:45:01Z. Added to the FM-8 follow-up entry's verification paragraph.

## What I added / repaired in `_harness/FAILURE-MODES.md`

1. **New WATCH ITEMS section** (between FM-9 and the PRE-CHANGE CHECKLIST) with an explicit promotion rule (≥2 same-day deaths or a 3rd standalone → full entry, next number **FM-10**) and the first entry, **W-1 · "Connection closed mid-response"**:
   - Exactly **2** standalone `exit1` deaths, field-anchored (`$3 == exit1` AND signature in summary): `2026-07-21T05:19:21Z | 260s` (line 45, Scout ARXIV-TRACK; self-healed `ok` 05:37Z, line 46; ~50 min AFTER the FM-1 fix, so standalone, not an attributed FM-1 tail) and `2026-08-01T01:15:50Z | 945s` (line 1086, builder-lane FM-9 retry; self-healed `ok` 02:03Z, line 1088). The job said "1 occurrence" — evidence says 2 isolated, 11 days apart, both self-healed. Still watch-item material, NOT an FM: no storm shape. (A third plain-grep hit is the BRIDGE line merging this very sync job quoting the signature — counted and excluded.)
   - **Latent defect found + recorded (the real value-add):** the two infra classifiers DISAGREE — `evaluate.sh:58` `infra_re` matches `Connection closed|mid-response` (which is why the FM-9 smoke's "infra-classified" health.sh claim holds), but `fail_streak`'s infra regex (`runner.sh:223` as of 08-01) does NOT — so `fail_streak` counts these deaths as REAL fails. A recurring storm would false-quarantine healthy jobs after `MAX_JOB_RETRIES=3` — exactly the FM-7 gap shape, closed there by adding `502|fetch failed`. Harmless today (the next-wave `ok` resets the streak). Fix sketch staged in the entry so promotion needs no re-diagnosis.
2. **Checklist item 6** (infra-vs-real-fail filter) gained the matching **W-1 watch — OPEN** note — that item is where a future fixer will look.
3. **Header** now points at the WATCH ITEMS section.
4. FM-8 follow-up entry gained the accumulated production verification (the 16× 0s window + cycle-not-recurred).

## Staged (not done here — workers are read-only on INDEX)

- `_harness/proposals.md`: new top `- [ ]` — `[Curator] [builder] INDEX FAILURE-MODES ONE-LINER SYNC`. INDEX.md's [[FAILURE-MODES]] one-liner still reads "7 incident classes / first 9 days / FM-1→FM-7 / 40/40 assertions" — stale; the proposal carries the 9-class / 13-day / FM-1→FM-9 + watch-items replacement text. `[builder]`-tagged because the substrate guard reverts worker INDEX edits.

## Known residual staleness (deliberately not chased)

- Historical `runner.sh:NNN` citations in older FM entries are ship-time snapshots and have drifted with the FM-8/FM-9 insertions (e.g. item 6's opening cites `runner.sh:112` for the infra regex; it sits at `:223` now). The catalog header's drift warning covers the pattern; every line I ADDED cites 08-01-current locations. A full re-cite is a separate job if ever wanted.

$0 · catalog-only (runner.sh/worker.sh read-only as mandated; no code touched).
