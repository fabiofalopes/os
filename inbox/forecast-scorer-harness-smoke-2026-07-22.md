---
tags: [inbox, quant, forecasting, harness, smoke-test, ledger-row-1]
date: 2026-07-22
status: raw — Curator: triage (suggest link from [[forecast-pilot-01]] + add to [[repos]])
related:
  - "[[forecast-pilot-01]]"
  - "[[ledger]]"
  - "[[repos]]"
---

# Forecast Scorer — Harness Built & Smoke-Run (2026-07-22)

> Pre-built the executable KILL criterion for [[forecast-pilot-01]] **before** the first market resolves (~2026-08-04), per "build the kill criterion into code before then." Code lives outside the vault (markdown-only, see [[repos]]).

## Artifact

`~/Projects/forecast-scorer/score_forecast_pilot01.py` — self-contained Python 3 (stdlib only, cron-safe). Embeds the 21 frozen forecasts verbatim; fetches `gamma-api.polymarket.com/markets?id=<ID>` (public, no auth); computes `BS_F`/`BS_M`/`BS_C` + per-domain diagnostics + hit rate + calibration; applies the pre-committed verdict table; prints the verdict. Modes: live run, `--json`, `--selftest` (offline logic proof). Exit codes: 0 ok / 1 partial fetch / 2 total fail / 3 selftest fail.

## Evidence (test, don't wonder)

- **Verdict logic proven offline:** `--selftest` — 11 boundary cases (coin-KILL, market-loss KILL, exact-tie `>=`, NO-EVIDENCE band, exact `0.90×BS_M` PROMOTE boundary, N<15 guard, ≥2-void guard, coverage grid over the whole BS plane) — **ALL PASS**.
- **Smoke-run vs CURRENT odds (no resolutions yet):** 21/21 IDs reachable, **0 fetch failures** — API path validated weeks before it matters. 0/21 resolved → verdict `INCONCLUSIVE` (guard: N<15), exactly as pre-committed for the pre-resolution state.
- **API-shape finding (corrected the note's assumption):** the live gamma API has **no `isResolved` field**. Resolution = `closed: true` + `outcomePrices` at an extreme (`["1","0"]`→YES, `["0","1"]`→NO); closed-but-mid-prices → void/0.5. Encoded accordingly; the pilot note's protocol line is slightly wrong on field names — the harness is right (flag for human; the frozen note itself is never edited).

## One documented interpretation (flaggable by human)

The verdict table says "applied in order" but lists INCONCLUSIVE (N<15 / ≥2 voids) last. The harness evaluates that guard **first**, as a precondition — BS is undefined at N=0 and meaningless below 15, and the note's own INCONCLUSIVE consequence is "no verdict … infra failure, not thesis failure." The guard can only ever mask a KILL or NO-EVIDENCE (PROMOTE requires N≥15 itself), so it **never manufactures a promotion**. Where literal written-order would differ, the report prints both. If the human prefers strict written-order, it's a 5-line change in `verdict()`.

## Drift since capture (diagnostic only — forecasts are FROZEN)

Notable moves 07-21→07-22: #18 GPT-6-by-Aug-31 0.26→0.345; #20 NVIDIA-top-cap 0.68→0.725; #13 CPI-MoM≥0.1% 0.665→0.705. Most others within ±0.02. No action — the test scores the frozen numbers.

## Curator / runner follow-ups

1. **Queue the SCORE job** (workers can't edit [[queue]]): `[Quant] SCORE forecast-pilot-01 — on/after 2026-09-02: run ~/Projects/forecast-scorer/score_forecast_pilot01.py, write wiki/value/forecast-pilot-01-RESULT.md per the pilot's protocol, flag ledger row-1 status change (Z2) for human/Critic.`
2. Add `~/Projects/forecast-scorer/` → [[repos]] index.
3. Link this note from [[forecast-pilot-01]] (Scoring protocol section).

## Verdict

Harness built + logic-proven + infra-smoked. The kill criterion is now executable and waiting; row 1's fate is scheduled for 2026-09-02.
