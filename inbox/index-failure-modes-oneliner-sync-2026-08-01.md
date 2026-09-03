---
tags: [inbox, index, harness, failure-modes, sync, builder-handoff]
date: 2026-08-01
status: ready-to-apply — Curator/builder pastes the line below into INDEX.md
related:
  - "[[FAILURE-MODES]]"
  - "[[janitor-failure-modes-catalog-sync-2026-08-01]]"
---

# INDEX ↔ FAILURE-MODES one-liner sync (2026-08-01)

**Verdict: STALE → replacement drafted, verified against the catalog, ready to paste.** The `[[FAILURE-MODES]]` bullet in INDEX.md (Harness Config section; line 101 as of this writing) still reads "the 7 incident classes of the engine's first 9 days (FM-1 proxy storm → FM-7 gateway 502 storm) … FM-7's Guard-5 … (40/40 sandbox assertions; checklist item 11 signed off)". The catalog itself now carries **9 incident classes across 13 days** (2026-07-20→08-01, FM-1→FM-9), a WATCH ITEMS section (W-1), and a 15-item PRE-CHANGE CHECKLIST with items 11–15 signed.

## Why I did not edit INDEX.md in place

This session ran on the **worker lane**; the substrate snapshot/revert (`runner.sh:293-322`) reverts worker edits to INDEX/LOG/MEMORY/queue — the catalog's own checklist item 9 records two real `SUBSTRATE_VIOLATION` reverts (LOG lines 52, 77) and reserves substrate writes for the builder lane. The job is `[builder]`-tagged for exactly this reason, but dispatched to a worker tick — so the durable artifact is the byte-exact replacement line for the builder/Curator to apply.

## APPLY: replace the whole `[[FAILURE-MODES]]` bullet line with this one line

```markdown
- [[FAILURE-MODES]] — Harness incident catalog (`_harness/`): the 9 incident classes of the engine's first 13 days (2026-07-20→08-01, FM-1 proxy storm → FM-9 first-timeout builder promotion), each with symptom, LOG evidence, root cause, shipped breaker, one-line regression check — breakers shipped+verified since the last sync: FM-7 gateway 502 storm Guard-5+5b (40/40 sandbox assertions, checklist item 11 signed), FM-8 phantom-`[x]`+binary-LOG artifact oracle + UTF-8 sanitization (59/59, item 12), FM-6 TIMEOUT(BUT_ARTIFACT) timeout credit (26/26, item 13 — incident #6 closed), FM-8-follow-up DEFERRED per-job re-dispatch hold / Guard-6 (27/27, item 14), FM-9 first-timeout builder promotion (23/23, item 15) — plus WATCH ITEMS (W-1 connection-closed mid-response: 2 isolated self-healed occurrences + a recorded `fail_streak`-vs-evaluate.sh classifier gap, with the FM-10 promotion trigger + staged fix sketch) and the mandatory PRE-CHANGE CHECKLIST (now 15 items, items 11–15 signed off) every `runner.sh`/`worker.sh`/`config.env` edit must pass before shipping (born from the routing subsystem being patched twice in 24h, FM-4).
```

Apply note: single-line bullet, INDEX house style (cf. the long `[[quant-pilot-02-RESULT]]` / `[[forecast-pilot-01]]` entries). Do not touch the adjacent `[[queue]]` / `[[schedule]]` / `[[janitor-timeout-but-artifact-ship-2026-07-31]]` bullets. INDEX frontmatter `date:` may be bumped by the Curator per its own convention.

## Evidence (test, don't wonder)

- **Staleness:** INDEX.md:101 says "7 incident classes … first 9 days … FM-7" (read this session); FAILURE-MODES.md:12 header says "Nine incident classes in the engine's first 13 days (2026-07-20→08-01)".
- **FM-7 40/40:** `journal/sessions/janitor-gateway502-guard5-ship-verify-2026-07-29.md` contains "40/40 assertions" (grep-verified this session); checklist item 11 ✅ signed 2026-07-29 (FAILURE-MODES.md:139).
- **FM-8 59/59:** FAILURE-MODES.md:88 ("59/59 sandbox assertions"); item 12 ✅ signed 2026-07-29 (:141).
- **FM-6 credit 26/26, incident #6 closed:** FAILURE-MODES.md:65+70 and :143; item 13 ✅ signed 2026-07-31; companion ship note [[janitor-timeout-but-artifact-ship-2026-07-31]] (already in INDEX).
- **FM-8-follow-up 27/27 (Guard-6 / DEFERRED hold):** FAILURE-MODES.md:96–97; item 14 ✅ signed 2026-07-31 (:145).
- **FM-9 23/23 (first-timeout builder promotion):** FAILURE-MODES.md:105–106; item 15 ✅ signed 2026-08-01 (:147); ship note [[janitor-first-timeout-builder-promotion-2026-08-01]].
- **W-1 watch item:** FAILURE-MODES.md:115–120 — 2 isolated self-healed "Connection closed mid-response" deaths (2026-07-21 + 2026-08-01, field-anchored count = exactly 2); latent classifier disagreement recorded (evaluate.sh:58 `infra_re` matches, `fail_streak` regex runner.sh:223 does not); promotion trigger = ≥2 same-day or a 3rd standalone → FM-10.
- **Checklist 15 items, 11–15 signed:** FAILURE-MODES.md:124–147 — items 1–10 unsigned standing rules; 11 (07-29), 12 (07-29), 13 (07-31), 14 (07-31), 15 (08-01) each carry a ✅ SIGNED OFF block.

$0 · no capital · read-only on substrate · companion to today's catalog sync [[janitor-failure-modes-catalog-sync-2026-08-01]].
