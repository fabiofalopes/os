---
tags: [critic, review-request, quant, ledger-row-4, z2-proposal, inbox]
date: 2026-07-29
status: staged — awaits adversarial [Critic] pass, then human (Z2) sign-off before [[ledger]] row-4 is touched
related:
  - "[[quant-pilot-02-RESULT]]"
  - "[[quant-pilot-02]]"
  - "[[ledger]]"
  - "[[steward-24h-review-2026-07-29]]"
---

# [Critic] REVIEW REQUEST — quant-pilot-02-RESULT + ledger row-4 update proposal

> Promotion gate (CLAUDE.md): nothing lands in the ledger as a result without passing the Critic. This note stages both the adversarial review target and the exact ledger edit. **Nothing is flipped until a human approves.**

## What to review

[[quant-pilot-02-RESULT]] — the step-6 recording of the row-4 run: verdict **INCONCLUSIVE** (frozen breadth guard fired first: 78/138 months = 56.5% < 100 tickers extracted, threshold > 20%; fetch_fail 27,733/55,681 = 49.8%, a ConnectionError storm confined to the 07-27T22:15Z→07-28T00:00Z valoos phase).

## Attack surfaces for the Critic (verify, don't trust)

1. **Guard application is exact.** Does the RESULT apply the frozen table in frozen order (INCONCLUSIVE first, per `run_pilot.py:apply_verdict`)? Is the 56.5% breadth number reproducible from `data/extractions.full.jsonl` + `results.json:guard`? Is the failure-rate clause correctly reported as NOT fired (0.075% malformed-after-retry; fetch_fail is infra, not the frozen "malformed output" clause)?
2. **The sub-guard KILL reading is honestly hedged.** All 6 configs measured `SR_X(EW) ≤ 0` (family mean −0.369; selected L1Q5 −0.349; DSR p = 0.974; PBO 0.185) — would-be KILL, but on a 9.7%-success non-random sample. Does the note claim this as a verdict anywhere it shouldn't? The frozen note says the guard "can only mask a KILL/NO-EVIDENCE — never manufacture a PROMOTE" — check the note honors that asymmetry.
3. **Root cause: suspected vs proven labeled correctly.** Proximate (evidenced): 27,732 ConnectionError + 1 http_503, median 0.8 s fast-fail, 99.996% in valoos, uniform ~90%/yr, zero 429/403. The localhost:8705 gateway-502-storm link ([[steward-24h-review-2026-07-29]] hypothesis) is labeled *suspected, not verified* on three tested grounds (no proxy env for SEC traffic; model path through 8705 healthy during the window; logged Steward deaths 00:49Z+ postdate extraction end 00:01Z). Any overclaim?
4. **Probe + leak-audit gap recorded, not papered over.** `rho = None` (probe ran, 0 pairs — re-fetches died in the same outage), `mask_audit.full.json = []`. The frozen ≥30-sample audit was never performed; the note must require it on the re-run before any ρ is trusted.
5. **Fix path stays inside the frozen carve-out.** Re-extract the 27,733 failed filings only, config freeze L1Q5 (07-27T22:15Z, pre-OOS) never re-selected — A9b affected-filings carve-out; NOT the NO-EVIDENCE redesign allowance (unspent). Is that reading defensible?
6. **A7/A8 diagnostics complete.** Failures by item (max 43.1%, volume-proportional → no flag) and year (max 17.0% → no flag; phase concentration flagged as infra); XOM zero-filing (enumeration-level, S=0 neutral, 1/503). Rung-0 reconciliation: bar +1.377 = family mean 1.363 + 0.014 → not luck-inflated (A8 confirmed).
7. **Step-6 quotes present:** frozen prompt verbatim, masking procedure (4 rules), model id + digest `ef495d633ecd…`, extraction stats.

## Proposed [[ledger]] row-4 edit (Z2 — apply ONLY after Critic pass + human approval)

- **Result:** `INCONCLUSIVE (extraction breadth guard 56.5% > 20%; 49.8% fetch_fail ConnectionError storm, valoos phase 07-27T22:15→07-28T00:00Z; measured sub-guard: all 6 configs SR_X(EW) ≤ 0, family mean −0.369 (selected L1Q5 −0.349), DSR p=0.974, PBO 0.185, ρ unmeasured — on a 9.7% sample, no statistical verdict valid)`
- **Status:** stays **`idea`** — INCONCLUSIVE is no verdict (frozen consequence: "fix the path, re-run"). Explicitly NOT `killed` (that requires the guard-clearing KILL) and NOT a redesign (allowance unspent).
- **Next:** re-extract 27,733 failed filings under a pre-dispatch SEC egress probe (steward job #2), frozen config L1Q5 untouched → probe + ≥30-sample leak audit → re-apply verdict table. Modal expectation unchanged: KILL on a clean sample.
- **Evidence:** [[quant-pilot-02-RESULT]] · `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/results.json` · `data/orchestrate.log` · `data/extractions.full.jsonl`
- **Cost to date:** $0, paper only (token-plan inference, free EDGAR). Time: ~10.5h wall of a ~22h detached run produced a guard-level result; the re-run is scoped to the failed filings only.

## Process note

This RESULT was recorded by a re-run SCORE job: queue.md:69 had SCORE marked done but no session ever wrote the note (>24h phantom-completion, flagged by [[steward-24h-review-2026-07-29]]). The verdict sat in `results.json` since 07-28T00:01Z; this session's contribution is the recording + root-cause forensics, not new measurement.
