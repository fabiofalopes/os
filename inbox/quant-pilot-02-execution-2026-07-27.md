---
tags: [quant, pilot, execution, ledger-row-4, llm-signal, in-progress]
date: 2026-07-27
role: Quant (cron worker, builder lane)
status: EXECUTION LAUNCHED — train extraction running detached (~21–22h full run); verdict pending ~2026-07-28; resume protocol in `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/RUNSTATE.md`
related:
  - "[[quant-pilot-02]]"
  - "[[critic-quant-pilot-02-2026-07-26]]"
  - "[[quant-pilot-01-RESULT]]"
  - "[[ledger]]"
  - "[[ktd-fin]]"
---

# Quant Pilot 02 — Execution Session (Row-4 Pilot Launched)

> Job: `[Quant] EXECUTE THE ROW-4 PILOT` — run the frozen [[quant-pilot-02]] test (Critic-hardened 07-26, 9 amendments, kill criterion byte-identical) end-to-end on free data. This session: inherited a built-but-never-launched pipeline from the 07:57–09:33 worker session, audited it against the frozen spec, fixed two pre-execution defects, and launched the long-running extraction detached. **The verdict is not in yet** — compute is the long pole (~22h); the pipeline is resumable and runs unattended. $0, paper only, no capital, no live trading.

## What happened, in order

1. **Inherited state (07:57–09:33 session):** full executor pipeline written (`fetch_filings / stage0 / extract / resume_extract / orchestrate / run_pilot / run_probe / mask / sig`); Stage-0 feasibility gate run; full filings index fetched. Session ended before extraction started. No process was running when this session began (verified 14:39).
2. **Stage-0 verdict (frozen gate, `data/stage0_verdict.json`):** **PASS** — 500/500 structured-JSON success (gate ≥ 0.80), 2,504.6 filings/hr sustained (gate ≥ 150), m×v non-degenerate (56/500 nonzero, 24 distinct values, range −0.7…1.0). Model locked per A6: `alibaba-token-plan/qwen3.8-max-preview`, digest `ef495d633ecd4f37…` — re-verified live this session (sha256 of model string matches; live call through the frozen path returns valid schema, ~11.5s).
3. **Full index (`data/coverage.full.json`):** 77,130 in-window 8-Ks → **55,920 included** after the frozen item filter (21,210 excluded for missing/non-material items, logged); **0 unmapped tickers, 0 fetch errors**; 502/503 tickers with ≥1 included filing — the one zero-filing name is **XOM** (S = 0 neutral per A7, logged). Acceptance-timestamp source: 100% `acceptanceDateTime` (the `filingDate` fallback was never used, as the note predicted). By item: 2.02 (23,524) > 7.01 (17,259) > 5.02 (13,951) > 1.01 (7,963) > 2.03 (4,879) > rest < 1k — the earnings/RegFD-heavy construct the A9a exhibit-attenuation handicap names.
4. **Spec-compliance audit of the inherited code vs the frozen note + 9 amendments:** verified in code — literal `form == "8-K"` (A1), acceptance-windowed `S(i,m)` with 1-month skip (A1), missing-items excluded + logged (A2), enumeration from 2014-09 (A3), frozen masking procedure + ≥30-sample audit dump (A4), identity-sensitive interpretation bound (A5), model lock + digest-into-log-before-first-extraction, no fallback (A6), unmapped → S = 0 (A7), family-mean diagnostic wired (A8), statistics copied **verbatim** from [[quant-pilot-01-RESULT]]'s engine (DSR trials = 6, PBO CSCV 16×8 with asserted 128-month trim), verdict table in frozen order with the exact thresholds, rung-0 bar 1.377.
5. **Two pre-execution fixes (conservative — each can only ever yield INCONCLUSIVE, never manufacture a PROMOTE):**
   - **(bug, A9b carve-out)** the local `signal.py` shadowed the Python stdlib `signal` module → `orchestrate.py` crashed on import and `resume_extract.py`'s SIGTERM handler was silently broken. Neither file had ever executed. Renamed `signal.py` → `sig.py` (one import updated; signal math untouched). Logged in RUNSTATE.
   - **(missing guards)** `mode_verdict` lacked two of the note's frozen INCONCLUSIVE clauses: "< 100 tickers with ≥1 successfully-extracted in-window filing for > 20% of window months" (the inherited code checked the *price* panel, pilot-01's version) and "extraction failure rate > 20% (malformed output after 1 structured retry)". Added as `run_pilot.py:extraction_guards()` (window = 2015-01→2026-06; failure rate = (parse_fail+model_fail)/definitive; fetch_fail reported alongside) + missing-probe ρ → INCONCLUSIVE instead of KILL. Pre-registration compliance, not a design change.
   - Documented operationalization (not a knob): quantile denominator = full panel cross-section (468 names, k = int(468·frac)) — the note's "cross-sectional rank on S; S = 0 never excluded" reading; pilot-01 used an eligible-count denominator. Logged.
6. **Launched the run detached** (14:47 WEST / 13:47Z): `setsid nohup flock -n data/orchestrate.lock …/python orchestrate.py` — the flock guard means a future cron session re-receiving this job detects the live run instead of double-launching. First chunks confirmed: 200/200 ok at 2,762/hr. Frozen execution order enforced by the orchestrator: train extraction → **config freeze (before any OOS extraction)** → val+OOS extraction → masking probe → verdict.

## State at session end

| Stage | State |
|---|---|
| Stage-0 gate | **PASS** (1.00 success, 2,505/hr) |
| Full index | done (55,920 filings, 0 errors) |
| Train extraction (25,051) | **RUNNING detached**, ~2,750/hr, ETA ~9h |
| Config freeze | pending (auto, after train) |
| Val+OOS extraction (30,869) | pending, ~12h |
| Masking probe → ρ | pending (~25 min) |
| Verdict + results.json | pending — **~2026-07-28 midday WEST** if the laptop stays up |

**Risks to the run:** laptop suspend/reboot (process pauses or dies; the flock + 100-filing flush resume picks up — persistent model_fail filings are definitive by design and counted in the failure-rate guard); token-plan expiry (~2026-08-19 vs ~22h runtime — negligible); proxy 429s (would show as model_fail; guard catches systemic rates). Modal expected outcome is unchanged from the pre-registration: **NO-EVIDENCE or KILL** (T = 42 underpowered, rung-0 hurdle dominates, exhibit attenuation biases conservative).

## What the verdict session must do (full checklist in RUNSTATE.md)

Read `results.json` → write `wiki/value/quant-pilot-02-RESULT.md` (quote the frozen prompt from `extraction_log.full.json`, the masking procedure + ≥30-sample leak-audit result from `mask_audit.full.json`, model digest, extraction stats; A8 reconciliation vs +1.377 AND family mean 1.363; A7 failure/zero-filing concentration flags) → flag [[ledger]] row 4 Result + Status (Z2 — Critic + human sign-off) → if PROMOTE, the 8-week operational paper window (step 7) with Critic review first.

## Evidence paths

`~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` — code + `RUNSTATE.md` (resume protocol) · `data/stage0_verdict.json` · `data/coverage.full.json` · `data/filings_index.full.csv` · `data/extraction_log.full.json` (frozen model+prompt) · `data/progress.full.json` (live progress) · `data/orchestrate.log` · `data/extractions.full.jsonl` (growing).

**Verdict: — (execution in progress; aspiration → evidence in ~22h).** No ledger change this session: row 4 stays `idea` until `results.json` exists (the ledger records measured outcomes, and the verdict is Z2-gated).
