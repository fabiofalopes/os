---
tags: [inbox, quant, forecasting, reconciliation, ledger-row-1, test-dont-wonder]
date: 2026-07-27
status: raw — Curator: triage (suggest link from [[forecast-pilot-01]] Deviations + [[repos]]; INDEX entry)
related:
  - "[[forecast-pilot-01]]"
  - "[[verdict-pipeline-dryrun-2026-07-23]]"
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[ledger]]"
---

# Row 1 — Verdict-Date Reconciliation + Smoke (2026-07-27)

> Job: the 07-27 01:36Z ORACLE refresh set row 1's verdict day to 2026-09-02; the job spec claimed the frozen note + MEMORY say 2026-08-04; "one of them is wrong." Mandate: live-check all 21 market IDs + dates against the public API, establish the true first-resolution date, smoke-run the pipeline, correct the wrong note with evidence. $0, public API only.

## Verdict — read this first

- **Score/verdict day = 2026-09-02 — CORRECT.** Frozen single-run protocol (Critic G2). ORACLE, the frozen note, and `run_verdict.sh` (`VERDICT_DAY=2026-09-02`) all agree on it. The job spec's "08-04 verdict day" framing is the conflation **already flagged 2026-07-23** ([[verdict-pipeline-dryrun-2026-07-23]] flag #1: the queue spec's wording) — today's spec repeated it.
- **First resolution = 2026-08-07, NOT 08-04.** Live gamma-API check of all 21 IDs (07-27): earliest `endDate` = **08-07** (#11 US July unemployment, 2775407); **no market ends on 08-04**. "2026-08-04 → 09-01" is the **selection window** (frozen note, Selection-method bullet), mistakenly repeated as the batch's resolution range. True range: **08-07 → 08-31** (13 markets end 08-31, last at 23:59Z; resolutions lag ends via UMA, hence the 09-02 score buffer).
- **Both notes carried the same error** — the ORACLE bullet and the frozen note's header prose. The frozen note's per-market table was already correct (08-07 → 08-31). Both prose errors fixed below, evidence cited.
- **MEMORY.md carries no dates** — nothing to reconcile there (read-only substrate for workers regardless).
- **⚠ Side finding (action owed, Z2): market #19 (Claude Opus, 2761627) has been PULLED from Polymarket** — gamma API returns `[]` by id ×4 retries and `[]` by slug (07-27); the replacement listing ("Next Claude Opus: Text Arena Debut?", event 704768) is a *different question*. The monitor now exits **1 (partial)** instead of 0, and at score time the scorer **silently drops** it (fetch-failed rows get `outcome=None` — neither void nor resolved) → a 20-market verdict + WARNING. That is a de-facto exclusion against the exclusion lock; the human/Critic must ratify it (or choose void/redesign) **before 09-02**.

## Evidence

### 1. Live API cross-check — 2026-07-27 ~07:50 UTC

Source note: the job said "Metaculus API" — the pilot **pivoted to Polymarket** on 2026-07-21 (Metaculus auth-gated: `Permission Error` + Cloudflare 403; frozen note Deviations). The 21 IDs are Polymarket gamma IDs; `gamma-api.polymarket.com` (public, browser UA) is the ground truth.

20/21 fetched live; **0 drift** vs the 2026-07-23 snapshot; **all `closed: false`, `active: true`**; **0/21 resolved**.

| # | ID | end (live 07-27) | # | ID | end (live 07-27) |
|---|---|---|---|---|---|
| 1 | 2633430 | 08-31T23:59Z | 12 | 2234098 | 08-11T00:00Z |
| 2 | 2774056 | 08-31T00:00Z | 13 | 2925106 | 08-12T03:59Z |
| 3 | 2937527 | 08-31T23:59Z | 14 | 2321905 | 08-17T00:00Z |
| 4 | 2686771 | 08-31T23:59Z | 15 | 2955043 | 08-31T00:00Z |
| 5 | 2602052 | 08-31T00:00Z | 16 | 2955045 | 08-31T00:00Z |
| 6 | 2641010 | 08-31T00:00Z | 17 | 2955048 | 08-31T00:00Z |
| 7 | 2911874 | 08-31T00:00Z | 18 | 2850825 | 08-31T00:00Z |
| 8 | 2925075 | 08-12T03:59Z | **19** | **2761627** | **GONE — `[]` by id + slug** |
| 9 | 2925076 | 08-12T03:59Z | 20 | 2941315 | 08-31T23:59Z |
| 10 | 2810507 | 08-12T03:59Z | 21 | 2853384 | 08-14T00:00Z |
| 11 | 2775407 | **08-07T08:30Z ← first** | | | |

Distribution: 08-07 ×1 · 08-11 ×1 · 08-12 ×4 · 08-14 ×1 · 08-17 ×1 · 08-31 ×13 (12 live + #19 per snapshot, which also said 08-31). **First end 08-07, last end 08-31.** Strictly: ends are API ground truth; resolutions land *after* ends (UMA lag) — first resolution ≈ 08-07+, last ≈ 09-01/02, which is exactly what the 09-02 score day buffers.

### 2. Smoke-run — 2026-07-27 ~07:52 UTC

`bash ~/Projects/forecast-scorer/run_verdict.sh` (live, default mode):

- `MODE: MONITOR (2026-07-27 < 2026-09-02)` ✓ — no outcome info enters the vault
- `[0]` selftest **ALL PASS** · `[1]` fetch **20/21** (one FETCH-FAILED: #19) · `[2]` offline score · `[3]` watcher==scorer **AGREE**
- Verdict: **INCONCLUSIVE — 0/21 resolved** ✓ (the job's expected state)
- **Exit 1, not 0** — "some fetches failed (partial data)" — caused solely by #19's disappearance (retried ×4, by-id and by-slug both empty; not transient). The 07-23 dry-run was exit 0 when all 21 were still fetchable.
- Precaution: the 07-23 snapshot (only complete capture incl. #19's raw) backed up to `resolutions_pilot01.json.bak-20260727-recon` before the live run overwrote it.

### 3. Where "08-04" came from

Frozen note Selection-method bullet: "top-400 markets by volume in the **2026-08-04→09-01 window**" — the selection window. The header prose repeated it as "resolving 2026-08-04 → 2026-09-01"; ORACLE, the `run_verdict.sh` DATE-NOTE comment (l.46–47), and the watcher + scorer reason strings ("first resolves ~2026-08-04") all inherited it. The per-market Resolves column (08-07 → 08-31) was correct all along.

## Corrections applied (this session)

1. **`_ORACLE-CURATED.md`** row-1 bullet — the durable source (`oracle.sh` regenerates `_ORACLE.md` from it every tick; the file's own header says edit it, not `_ORACLE.md`): range → 08-07 → 08-31 (API-verified), score day 09-02 unchanged, #19 flag + link to this note.
2. **`_ORACLE.md`** — same line patched now (immediate screen, until the next engine refresh).
3. **`wiki/value/forecast-pilot-01.md`** — header range fixed + dated Deviations bullet with this evidence + status-line provenance. Legitimacy: executed at **0/21 resolved** (live-verified same day — no outcome information exists); forecasts, integrity hashes, kill criterion, and protocol **untouched** (batch block not edited); a factual prose correction under the note's own Critic-amendment precedent (07-22 amendment did the same class of fix at 0/21 resolved).

## Flags — not fixed (out of scope / frozen / Z2)

1. **#19 pulled — Z2 decision owed before 09-02.** Harness status quo = silent exclusion → 20-market verdict + exit-1 WARNING. Options: (a) ratify documented exclusion (the exclusion lock permits removal for "documented falsifiability failure" — an exchange-delisted market qualifies — with Critic + human sign-off); (b) hand-score #19 as void via the frozen fallback ("open polymarket.com/market/<slug>" — but the slug is gone too, so the outcome may be unverifiable); (c) redesign. The human should choose explicitly rather than inherit (a) by default.
2. **"08-04" in harness code** (3 spots: `run_verdict.sh:46-47` comment; `fetch_resolutions.py:205` + `score_forecast_pilot01.py:360` reason strings). Cosmetic — `VERDICT_DAY=2026-09-02` is correct and governs behavior. Not edited: the pipeline is frozen + dry-run-proven; change it once, alongside the #19 decision, then re-run `--selftest`.
3. **Queue SCORE job wording** (carried from 07-23): `bash ~/Projects/forecast-scorer/run_verdict.sh`, once, on/after 09-02, never re-run (workers can't edit [[queue]]).
4. Curator: link this note from [[forecast-pilot-01]] + [[repos]]; add INDEX entry.

## Verdict

The human's one-screen view now shows the true dates: **first resolution 08-07 · last end 08-31 · score day 09-02 (unchanged, correct)**. Pipeline healthy (0/21 resolved, watcher==scorer AGREE) with one honest warning attached: #19 is gone — the single thing between this row and a clean verdict day, and it is a human decision, not an agent one.
