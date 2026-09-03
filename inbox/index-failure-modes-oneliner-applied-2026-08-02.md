---
tags: [inbox, index, harness, failure-modes, sync, builder-lane, applied]
date: 2026-08-02
status: applied — INDEX.md:102 replaced in place on the builder lane; dead letter [[index-failure-modes-oneliner-sync-2026-08-01]] superseded
related:
  - "[[FAILURE-MODES]]"
  - "[[index-failure-modes-oneliner-sync-2026-08-01]]"
  - "[[janitor-gateway-flap-fm10-ship-2026-08-01]]"
---

# INDEX ↔ FAILURE-MODES one-liner sync — APPLIED (2026-08-02)

**Verdict: APPLIED on the builder lane.** The `[[FAILURE-MODES]]` bullet in INDEX.md (line 102) now reads the current catalog: **10 incident classes, first 13 days (2026-07-20→08-02), FM-1→FM-10**, the six sandbox-verified breaker ships (FM-7 40/40 … FM-10 41/41), WATCH ITEMS (W-1, next number FM-11), and the 15-item PRE-CHANGE CHECKLIST (items 11–15 signed). The 08-01 dead letter's paste-ready line (drafted for 9 classes) was refreshed to 10 and applied; that note is superseded — Curator may triage it to `applied`.

## Lane verification (test, don't wonder — this is the gate the job named)

This session IS on the builder lane. Evidence, all read this session:

- **Process ancestry:** `ps` walk from my own shell: `zsh (848250) ← claude -p (847782) ← bash worker.sh builder … 80 2400 (847775) ← bash runner.sh (847714) ← /bin/sh -c cron (847713)`. Slot arg = `builder`; max-turns 80 / budget 2400 = `BUILDER_MAX_TURNS`/`BUILDER_BUDGET` — the invocation at `runner.sh:692`, the serial builder section.
- **Sidecar:** `_harness/state/worker-builder.job` (mtime 05:15, this wave) contains THIS job's text byte-exact; `worker-builder.pid` = 847775 = my process's ancestor.
- **Why the edit survives:** the substrate snapshot/revert (`runner.sh:652-657`) runs BEFORE the builder section and covers only the parallel worker slots — checklist item 9: "Substrate writes go through the BUILDER lane only — the revert runs before the builder section." My INDEX.md edit is structurally unrevertable by the guard.

## The lane discrepancy, root-caused (why the dead letter was born)

The job noted the 08-01T06:32Z dispatch "logged a `[builder]` prefix yet the session reports worker lane." LOG line 1107 confirms the `[builder]` prefix — the runner dispatched that session on the builder slot, exactly like this one. Yet its artifact ([[index-failure-modes-oneliner-sync-2026-08-01]]) says "This session ran on the worker lane" and refused the edit.

**Root cause: `worker.sh`'s prompt is slot-blind.** The SAME prompt template (`worker.sh:43-67`) goes to every slot — it opens "You are … an autonomous CRON WORKER … one of several workers running IN PARALLEL" and rules "SHARED SUBSTRATE IS READ-ONLY for workers." A builder-slot session reading that has no harness-level signal of its real lane; the 06:32Z session believed the prompt text over the dispatch facts and (per its own rules, rationally) refused the substrate edit → wrote the paste-ready line to inbox/ → the runner marked `[x]` (artifact existed) → the line was never applied → this APPLY job. The session was not wrong given what it could see; the harness never told it. **Fix sketch (staged as a proposal in `_harness/proposals.md`, NOT shipped here — a `worker.sh` edit must pass the 15-item PRE-CHANGE CHECKLIST):** give the builder slot a distinct prompt stanza ("You are the BUILDER — the serial lane; substrate writes ARE permitted for you, the revert runs before your section") keyed on `$slot`, which worker.sh already branches on at line 79.

## The applied line (byte-exact, INDEX.md:102)

```markdown
- [[FAILURE-MODES]] — Harness incident catalog (`_harness/`): the 10 incident classes of the engine's first 13 days (2026-07-20→08-02, FM-1 proxy storm → FM-10 gateway-hold FLAP loop), each with symptom, LOG evidence, root cause, shipped breaker, one-line regression check — FM-1…FM-6 fixed reactively, then six sandbox-verified breakers shipped 2026-07-29→08-01: FM-7 gateway 502 storm Guard-5+5b (40/40 assertions, checklist item 11 signed), FM-8 phantom-`[x]`+binary-LOG artifact oracle + UTF-8 sanitization (59/59, item 12), FM-6 TIMEOUT(BUT_ARTIFACT) timeout credit (26/26, item 13 — incident #6 closed), FM-8-follow-up DEFERRED per-job re-dispatch hold / Guard-6 (27/27, item 14), FM-9 first-timeout builder promotion (23/23, item 15), FM-10 gateway-flap memory + escalating hold + Oracle alert (41/41, W-2 promoted, item 11 W-2 note signed) — plus WATCH ITEMS (W-1 connection-closed mid-response: 2 isolated self-healed occurrences + a recorded `fail_streak`-vs-evaluate.sh classifier gap; next number FM-11) and the mandatory PRE-CHANGE CHECKLIST (now 15 items, items 11–15 signed off) every `runner.sh`/`worker.sh`/`config.env` edit must pass before shipping (born from the routing subsystem being patched twice in 24h, FM-4).
```

## Evidence (every number grep-anchored this session)

- **10 classes / 13 days / 2026-07-20→08-02:** FAILURE-MODES.md:12 header — "Ten incident classes in the engine's first 13 days (2026-07-20→08-02)".
- **FM-7 40/40, item 11 signed 07-29:** `journal/sessions/janitor-gateway502-guard5-ship-verify-2026-07-29.md` contains "40/40 assertions" (grep); FAILURE-MODES.md:153 ✅ block.
- **FM-8 59/59, item 12:** FAILURE-MODES.md:88 + :157.
- **FM-6 credit 26/26, item 13 (incident #6 closed):** :70 + :159; companion [[janitor-timeout-but-artifact-ship-2026-07-31]] already in INDEX (untouched).
- **FM-8-follow-up 27/27, item 14:** :96-97 + :161.
- **FM-9 23/23, item 15:** :105-106 + :163.
- **FM-10 41/41, W-2 promoted, item 11 W-2 note signed 08-01:** :115-116 + :155; ship note [[janitor-gateway-flap-fm10-ship-2026-08-01]] contains "41/41 assertions" (grep).
- **W-1 next number FM-11:** :123 promotion rule + :130 ("FM-10 was taken by the W-2 promotion").
- **15 items, 11–15 signed:** :142-163 — items 1–10 standing rules; 11 (07-29 + 08-01 W-2), 12 (07-29), 13 (07-31), 14 (07-31), 15 (08-01) each carry a ✅ SIGNED OFF block.
- **Adjacency intact:** `[[queue]]` (l.100), `[[schedule]]` (l.101), `[[janitor-timeout-but-artifact-ship-2026-07-31]]` (l.103) bullets untouched; single Edit on the l.102 bullet only; INDEX frontmatter `date:` left to Curator convention.

$0 · no capital · builder-lane substrate edit (the only agent path to INDEX) · supersedes [[index-failure-modes-oneliner-sync-2026-08-01]].
