---
tags: [inbox, quant, forecasting, harness, verdict-pipeline, dry-run, ledger-row-1]
date: 2026-07-23
status: raw — Curator: triage (suggest link from [[forecast-pilot-01]] Scoring-protocol + [[repos]] entry)
related:
  - "[[forecast-pilot-01]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[forecast-resolution-watcher-2026-07-22]]"
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[ledger]]"
  - "[[repos]]"
---

# Verdict Pipeline — End-to-End Dry-Run (2026-07-23)

> Wired the two halves of the row-1 kill criterion into **ONE COMMAND** and smoke-ran it end-to-end, so verdict day is `bash ~/Projects/forecast-scorer/run_verdict.sh` — zero manual fumble on the closest-to-revenue hypothesis. Code lives outside the vault (markdown-only, see [[repos]]).

## Artifacts (in `~/Projects/forecast-scorer/`)

1. **`run_verdict.sh`** (new) — the one-command pipeline:
   - `[0]` preflight: `score_forecast_pilot01.py --selftest` (refuses to score if the criterion logic is broken → exit 3)
   - `[1]` fetch: `fetch_resolutions.py` live (browser UA) → writes `resolutions_pilot01.json`, the single official capture
   - `[2]` score: `score_forecast_pilot01.py --from-snapshot` — scores the capture **offline** with the scorer's own `parse_outcome` + verdict rules
   - `[3]` cross-check: watcher replay verdict ≡ scorer verdict (independent code paths, same data → must agree; mismatch → exit 4 integrity alarm)
   - `[4]` prints the consolidated verdict: `KILL` / `PROMOTE` / `NO EVIDENCE` / `INCONCLUSIVE → "NO VERDICT YET"`.
   - Modes: live (default) · `--replay [SNAPSHOT]` (offline audit — not a re-score, no new outcome info). Exit codes: 0 clean (INCONCLUSIVE is clean) / 1 partial fetch / 2 total fail or snapshot tampered/unusable / 3 selftest fail / 4 watcher≠scorer mismatch.
2. **`score_forecast_pilot01.py`** (amended, additive) — new `--from-snapshot FILE` mode: re-parses each captured raw gamma object with the scorer's own resolution rule and **verifies the snapshot's frozen values against FROZEN** (refuses a tampered/incomplete capture, exit 2). **FROZEN batch + `verdict()` untouched**; `--selftest` re-run after the edit → ALL PASS.

## Design — why the scorer runs offline on the snapshot

- The snapshot is the single official resolution capture (Critic G2). Scoring that exact file makes the verdict a function of **one fixed dataset** — no second network pass that could see different data, and **no 403 risk on verdict day** (the gamma API has 403'd custom clients; the watcher's browser UA is the verified path).
- Watcher ≡ scorer by construction (shared imported `verdict()`); the pipeline still cross-checks the two independent scoring paths (`derive()` vs scorer `main()`) and alarms (exit 4) if they ever diverge.

## Evidence (test, don't wonder — all 2026-07-23)

- **Live smoke-run:** 21/21 fetched, **0 fetch failures**, **0/21 resolved → `INCONCLUSIVE` → "NO VERDICT YET — 0/21 resolved"**, watcher==scorer **AGREE**, snapshot written, **exit 0** — exactly the pre-committed pre-resolution state.
- **Offline replay:** `--replay` reproduces the identical verdict in 0.28 s, no network, exit 0.
- **Selftest after scorer edit:** ALL PASS (11 boundary cases + full BS-plane coverage) — criterion logic provably intact.
- **Round-trip:** scorer re-parses all 21 snapshot raw objects via its own `parse_outcome` — 21/21, 0 mismatch.
- **Tamper defense proven:** snapshot with one altered `forge_p` → `FATAL: frozen-value mismatch … refusing to score a tampered capture`, exit 2; snapshot with a deleted market → exit 2; snapshot with a fetch-failed market → verdict still produced + WARNING, exit 1 (this test **caught and fixed** a wrapper bug: watcher replay exits 1 on partial data, which the wrapper first misread as fatal).
- **UA test (both 200 today):** scorer's custom UA `forge-forecast-scorer/1.0` returned HTTP 200 on 2026-07-23 (Critic follow-up #4 was 403-*prone*, not 403-*always*); browser UA also 200. Verdict day no longer depends on either — the scorer never touches the network on the official run.

## Flags (for human / SCORE job / Curator)

1. **Date discrepancy in the job spec (resolved toward the frozen note):** the queue job said "2026-08-04 verdict day," but [[forecast-pilot-01]] pre-commits the single score run to the **first scheduled opportunity on/after 2026-09-02**; markets resolve across **2026-08-04 → 2026-09-01**, so 2026-08-04 is the *first resolution*, not the score day. The pipeline follows the frozen protocol (`VERDICT_DAY=2026-09-02` in `run_verdict.sh`, banner switches MONITOR → OFFICIAL there). If the human actually wants to score on 2026-08-04, that contradicts the frozen single-run lock (N would be ~0–2 → guaranteed INCONCLUSIVE) — almost certainly a spec conflation, but flagging per Z2.
2. **SCORE job wording (workers can't edit [[queue]]):** the queued SCORE job says "run `score_forecast_pilot01.py`" — update to **`bash ~/Projects/forecast-scorer/run_verdict.sh`** (once, on/after 2026-09-02, never re-run), then write `wiki/value/forecast-pilot-01-RESULT.md` citing the snapshot's `captured_at`; RESULT + [[ledger]] row-1 status change remain Z2.
3. **Critic hash serialization still unreconciled** (carried from [[forecast-resolution-watcher-2026-07-22]] #2): the pipeline's binding guarantee is the shared `FROZEN` import + the scorer's tamper-check, not the hashes.
4. Curator: add `run_verdict.sh` + the `--from-snapshot` scorer mode to [[repos]]; link this note from [[forecast-pilot-01]] (Scoring-protocol).

## Verdict

Pipeline wired + dry-run proven on every exit path. Verdict day is one command; row 1's fate (most likely KILL or NO-EVIDENCE by construction — that is the point) can no longer be fumbled on 2026-09-02. Pre-resolution status unchanged: 0/21 resolved → `INCONCLUSIVE`, monitoring only.
