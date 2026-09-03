---
tags: [inbox, quant, forecasting, harness, resolution-watcher, ledger-row-1]
date: 2026-07-22
status: raw — Curator: triage (suggest link from [[forecast-pilot-01]] Scoring-protocol + add to [[repos]])
related:
  - "[[forecast-pilot-01]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[ledger]]"
  - "[[repos]]"
---

# Forecast Resolution Watcher — Built & Smoke-Run (2026-07-22)

> Pairs with [[forecast-scorer-harness-smoke-2026-07-22]]. Makes the 2026-09-02 verdict of [[forecast-pilot-01]] **one command** and removes manual fumble risk from the closest-to-revenue row-1 verdict. Code lives outside the vault (markdown-only, see [[repos]]).

## Artifact

`~/Projects/forecast-scorer/fetch_resolutions.py` — stdlib-only, cron-safe. Polls the public API for the 21 frozen IDs (no account), writes `resolutions_pilot01.json` (per-market resolution status + closing odds + the **raw gamma object**), and prints the end-to-end KILL/PROMOTE verdict. Modes: live capture (default), `--json`, `--from-snapshot FILE` (offline replay/audit), `--out FILE`. Exit codes mirror the scorer (0 clean / 1 partial fetch / 2 total fail).

## Design — why it can't drift from the scorer

- **Verdict logic is imported, not re-written:** `FROZEN`, `parse_outcome`, `verdict`, `brier`, `EXTREME` come straight from `score_forecast_pilot01.py`. Watcher verdict ≡ scorer verdict **by construction** (note ≡ harness ≡ watcher). Importing `FROZEN` (no second transcription) is a stronger integrity guarantee than a hash gate.
- **Snapshot is the scorer's native format:** each market stores the raw gamma-API object. Proven by round-trip — the scorer's own `parse_outcome` re-parses all 21 snapshot objects with **21/21 agreement**.
- **Single-score-run lock (Critic G2) respected:** pre-verdict-day the watcher is a *monitor only* (provisional status, no outcome info enters anything). On/after 2026-09-02 the snapshot it writes is the **single official resolution capture**; `--from-snapshot` re-derives from an already-captured file (audit/replay, no new outcomes — not a re-score).

## Evidence (test, don't wonder)

- **Smoke-run (live):** 21/21 IDs reachable, **0 fetch failures**, **0/21 resolved** → verdict `INCONCLUSIVE` (guard: N<15), exactly the pre-committed pre-resolution state. Snapshot written. Exit 0.
- **Offline replay:** `--from-snapshot resolutions_pilot01.json` reproduces the identical `INCONCLUSIVE` verdict with no network.
- **Round-trip:** 21/21 snapshot raw objects re-parse identically through `score_forecast_pilot01.parse_outcome` (0 mismatch) — format compatibility proven, not assumed.
- **Metaculus clean negative (re-verified 2026-07-22):** the job spec said "Metaculus API," but the pilot documents a Metaculus→Polymarket pivot. Re-tested live today: `/api2/` and `/api/posts/` both **HTTP 403** (auth-gated/Cloudflare) — unreachable under the no-accounts rule. The 21 captured IDs are Polymarket IDs; the watcher polls the Polymarket gamma API (same public source the scorer consumes). Pivot is in-scope (ledger row 1 names "Metaculus → Kalshi/Polymarket").

## Flags for the SCORE job / Critic / Curator

1. **Browser User-Agent (Critic follow-up #4, now evidenced):** the gamma API 403s bare/custom clients. The watcher uses a **browser UA (verified working 2026-07-22)**; the scorer's own UA is a custom string (`forge-forecast-scorer/1.0`) and may be 403-prone. SCORE job should confirm the scorer's UA works on the day or switch it to a browser UA. The watcher's `UA` constant is a drop-in reference.
2. **Integrity-hash serialization not reproducible (honest negative):** the Critic's lock hashes (`4c8dfc20456a8918` / `292c90f9c917b4df`) use a serialization **not recorded** in the pilot note; 9 candidate serializations tested, none matched. The watcher therefore does **not** hard-gate on a guessed scheme (a false MISMATCH could block the verdict). It reports its own comma-str hashes and relies on the **shared `FROZEN` import** as the binding guarantee. Reconcile the exact serialization before any hash is used as a hard gate.
3. **Proposed verdict-day flow (one command):** on/after 2026-09-02 run `python3 ~/Projects/forecast-scorer/fetch_resolutions.py` once → snapshot = the single official capture, verdict printed; the SCORE job then runs the scorer (same API + same imported logic → same verdict) and writes `wiki/value/forecast-pilot-01-RESULT.md` citing the snapshot's `captured_at` as the scoring instant. RESULT note + ledger status change remain Z2 (human/Critic sign-off) — the watcher does **not** write them.
4. Curator: add `fetch_resolutions.py` + `resolutions_pilot01.json` to [[repos]]; link this note from [[forecast-pilot-01]] (Scoring-protocol section).

## Verdict

Watcher built + smoke-proven + format-proven. Verdict day is now one command; the row-1 verdict can no longer be fumbled by a manual fetch/transcribe on 2026-09-02. Pre-resolution status: 0/21 resolved → `INCONCLUSIVE` (monitoring only; the thesis verdict is scheduled for 2026-09-02).
