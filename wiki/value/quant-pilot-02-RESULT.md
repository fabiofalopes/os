---
tags: [value, quant, pilot, result, ledger-row-4, inconclusive, guard-fired, llm-signal, kill, clean-rerun, mask-fix-verified]
date: 2026-07-29
status: draft (Z2) — INCONCLUSIVE recorded 2026-07-29 (frozen step 6, Critic-certified); clean-fetch re-run 2026-08-01 SUPERSEDES with KILL (append-only addendum at foot; frozen INCONCLUSIVE text untouched). [[ledger]] row-4 status NOT flipped (KILL proposal staged in [[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]], Critic-certified 2026-08-01 ([[critic-quant-pilot-02-KILL-certification-2026-08-01]]), Z2 human sign-off owed)
related:
  - "[[quant-pilot-02]]"
  - "[[quant-pilot-01-RESULT]]"
  - "[[ledger]]"
  - "[[ktd-fin]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[steward-24h-review-2026-07-29]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[critic-mask-fix-audit-2026-08-01]]"
  - "[[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]]"
  - "[[critic-quant-pilot-02-KILL-certification-2026-08-01]]"
---

# Quant Pilot 02 — RESULT (Row 4: LLM 8-K Extraction Signal)

## VERDICT: **INCONCLUSIVE** (precondition guard fired first — applied exactly as frozen)

The frozen extraction breadth guard fired before any statistical test was consulted: **78/138 months (56.5%) had < 100 tickers with a successfully-extracted in-window filing** (frozen threshold: > 20%). Cause: a sustained SEC full-text **fetch outage during the entire validation+OOS extraction phase** — 27,733/55,681 records (49.8%) logged `fetch_fail`, 99.996% of them in the valoos phase. Per the frozen table ([[quant-pilot-02]], verdict row 1): *"No verdict — infra/compute failure, not thesis failure. Fix the path, re-run. This guard can only ever mask a KILL/NO-EVIDENCE — never manufacture a PROMOTE."*

**Recorded verdict: INCONCLUSIVE.** Row 4 keeps its pre-committed consequence: fix the fetch path, re-extract the failed filings on the frozen config, re-run probe + verdict. Below the guard, the measured family sits in KILL range (all 6 configs `SR_X(EW) ≤ 0`) — but on a 9.7%-success non-random sample no honest statistical verdict can be built, which is exactly what the guard exists to say.

## Verdict-table trace (frozen order: INCONCLUSIVE → KILL → NO EVIDENCE → PROMOTE)

Code of record: `run_pilot.py:apply_verdict` (guard first, house style per [[forecast-pilot-01]]); machine output `data/orchestrate.log` tail: `VERDICT: INCONCLUSIVE`.

| Gate | Frozen condition | Measured | Fired? |
|---|---|---|---|
| **INCONCLUSIVE** (FIRST) | < 100 tickers extracted in > 20% of window months | **78/138 months = 56.5%** (all 78 valoos months 2020-01→2026-06; every train+buffer month ≥ 100) | **YES → verdict stops here** |
| INCONCLUSIVE | extraction failure rate > 20% (malformed after 1 retry) | 0.075% (`parse_fail` = 0; `model_fail` = 21) | no (fetch_fail is infra, not malformed-output) |
| INCONCLUSIVE | EDGAR unreachable (submissions AND full-text both fail) | submissions: 503/503 tickers, 0 fetch errors; full-text: 49.8% fail | no (not *both*) — breadth clause already fired |
| INCONCLUSIVE (logged deviation) | probe missing → INCONCLUSIVE not KILL (RUNSTATE deviation #2, pre-execution, can only mask) | `rho = None`, probe ran but produced 0 pairs (same outage) | yes (redundant) |
| KILL (never reached) | `SR_X(EW) ≤ 0` OR `PBO ≥ 0.5` OR `ρ < 0.5` | −0.349 ≤ 0 (**would fire**); PBO 0.185; ρ not measured (None ≠ < 0.5) | masked by guard |
| NO EVIDENCE / PROMOTE | — | not evaluated | — |

## What happened — timeline (UTC, from `data/orchestrate.log` + `extraction_log.full.json` + `progress.full.json`)

1. **07-27 13:47Z** — TRAIN extraction starts (locked model, digest frozen pre-extraction per A6).
2. **07-27 13:47→22:15Z** — train phase: 24,974 records → **24,959 ok (99.94%)**, 14 model_fail, **1 fetch_fail**. Healthy.
3. **07-27 22:15Z** — config freeze: **L1Q5** (best NET train Sharpe 1.288 of 6; freeze predates all OOS extraction, per anti-peeking commitment).
4. **07-27 22:15Z → 07-28 00:00Z** — VALOOS extraction: 30,707 records → **2,968 ok (9.7%)**, 7 model_fail, **27,732 fetch_fail**. Near-total, uniform ~90% failure in every year 2020–2026.
5. **07-28 ~00:00Z** — masking probe: 160 OOS filings sampled; re-fetch failed for all 160 (outage ongoing) → `n_pairs = 0`, `rho = None`, `mask_audit.full.json = []` (audit dump fills only after a successful fetch).
6. **07-28 00:01Z** — verdict computed, `results.json` written: **INCONCLUSIVE**. Orchestration complete.

The SCORE step was checked off in `_harness/queue.md` but no session ever recorded the verdict ([[steward-24h-review-2026-07-29]] flagged the >24h phantom-completion; this note is that recording).

## Mandatory diagnostic — fetch_fail root cause

**Evidence (all 27,733 fetch_fail records in `data/extractions.full.jsonl`):**

| Error kind | Count |
|---|---|
| `fetch_error:ConnectionError` | 27,732 |
| `http_503` | 1 |

- Latency of failures: median **0.8 s** (fast-fail = connection refused/unreachable), max 40.05 s (= the 40 s timeout on a minority). Not rate-limiting: SEC rate-limit responses are HTTP 429/403 — zero occurred. The frozen ≤ 10 req/s token bucket (`common.py:SEC_LIMITER`) was in force.
- **Temporal concentration is total:** train phase (< 2020-01) = 1 fetch_fail; valoos phase = 27,732 (99.996%). Per-year valoos failure rates are uniform (0.898–0.915) → the failures correlate with *when filings were fetched*, not with their content.
- **Proximate cause (evidenced):** a sustained local-egress failure on direct HTTPS to `www.sec.gov` spanning the whole valoos window (22:15Z→00:00Z). The model layer was healthy over the same window (2,968 successful model calls via `localhost:8705`, only 7 model_fail) — inference worked; SEC fetch did not.
- **The localhost:8705 gateway 502 storm — suspected common root, NOT proven.** [[steward-24h-review-2026-07-29]] hypothesized the same proxy poisoned this run (it killed 4 Steward sessions 07-28T00:49/07:04/13:04/19:04Z). Tested here, not confirmed as direct causation: (a) no proxy env routes SEC traffic through 8705 — only `ANTHROPIC_BASE_URL` is set; the `requests.Session` is default trust_env with no `HTTP(S)_PROXY` (`common.py:http_session`); (b) the model path *through* 8705 stayed healthy during the damage window; (c) the logged Steward deaths begin 00:49Z, **after** extraction finished (00:01Z). What is supported: same-night local network/proxy instability on two surfaces (API gateway 502s + SEC ConnectionErrors), plausibly one root (laptop egress/DNS). **Label: suspected, not verified** — per [[Operating Principle — Test Don't Wonder]], a re-run under a pre-dispatch egress probe (steward staged job #2) is the test.

## Frozen prompt, model, extraction stats (step-6 quotes)

**Model (A6 lock, frozen pre-extraction in `data/extraction_log.full.json`):** id `alibaba-token-plan/qwen3.8-max-preview`, digest `ef495d633ecd4f377e080784f59fc595c9b00d767dbecbbb47a067c60a61090c`, api_base `http://localhost:8705`, temperature 0.0, input cap = first 1,024 whitespace tokens. One lock, never swapped (stage0 + train + valoos + probe all on this digest — `data/stage0_verdict.json` digest matches).

**Frozen prompt (verbatim):**

> You are a financial filing analyst. Below is the opening of an SEC 8-K current report. Assess the material event it discloses.
>
> Respond with ONLY a single valid JSON object. No prose, no markdown fences, no commentary. The object must have exactly these three keys:
> - "materiality": a number in [0,1] measuring how material the disclosed event is to the company's overall value (0 = routine/immaterial, 1 = transformative/highly material).
> - "valence": exactly one of -1, 0, or 1 for the likely direction of the event's impact on firm value (-1 = negative, 0 = neutral or ambiguous, 1 = positive).
> - "rationale": a string of at most 20 words explaining the judgment.
>
> Filing excerpt:
> """
> {text}
> """

**Masking procedure (frozen, `mask.py` first commit, A4):** (1) EDGAR entity name + universe security name → `[COMPANY]` (case-insensitive); (2) bare ticker → removed; (3) persons → `[PERSON]` (honorific- and officer-title-anchored spans); (4) absolute dates (ISO / "Month DD, YYYY" / "MM/DD/YYYY") → `[DAY±n]` relative to the filing's own acceptance date (kept).

**Leak audit: NOT PERFORMED — logged gap.** `data/mask_audit.full.json` = `[]` (empty). The audit dump is populated only after a successful masked re-fetch; the outage zeroed all 160 probe re-fetches → 0 pairs → no ρ, no audit samples. The frozen "> 10% leaks → fix mask.py + re-run probe ONLY" rule is vacuously unmet; the audit must be performed on the re-run before any ρ is trusted.

**Extraction stats:** 55,681 records — ok 27,927 (50.2%), model_fail 21 (0.04%), parse_fail 0, fetch_fail 27,733 (49.8%). Stage-0 gate: PASS (500/500 ok, 2,504.6/hr, mv non-degenerate: 56/500 nonzero, 24 distinct). Filings index: 55,920 included of 77,130 in-window 8-Ks (21,210 excluded for missing `items`, logged), 503/503 mapped, 0 submission fetch errors.

## Measured numbers (for the record — on the decimated 9.7% valoos sample; NOT a clean test)

Config freeze (`data/config_freeze.json`, 07-27T22:15Z, rule: best NET Sharpe on TRAIN 2015-01→2019-12): **L1Q5**, train SR 1.288.

| Config | Train SR | OOS SR raw | OOS `SR_X(EW)` net |
|---|---|---|---|
| L1D | 1.181 | 1.550 | −0.234 |
| **L1Q5 (selected)** | **1.288** | 1.370 | **−0.349** |
| L2D | 1.032 | 1.500 | −0.364 |
| L2Q5 | 1.136 | 1.383 | −0.309 |
| L3D | 1.048 | 1.426 | −0.534 |
| L3Q5 | 1.113 | 1.344 | −0.422 |

Selected L1Q5 OOS (N = 42 months): `SR_X(EW)` = **−0.349** (gross −0.336), `SR_X(SPY)` = −0.365, net return 18.75%/yr vs EW 19.79%/yr (mean excess **−1.05%/yr**) vs SPY 21.37%/yr, MDD −9.92%, one-way turnover 1.69%/mo, validation SR (diagnostic only) 0.573. DSR (trials = 6, realized skew −0.61 / kurt 4.31): **p = 0.974** (null SR0 = 0.676 ann.). PBO (CSCV 16×8, 12,870 combos, first-128-month trim): **0.185** (Sharpe), 0.281 (cumret); L1Q5 IS-best in 8,530/12,870 combos. `ρ = None` (probe: 0 pairs). `beats_rung0 = false`. Engine: `backtests/harness.py` (12/12 known-answer checks), frozen universe `c1f80ec6f12e83f8`, frozen price panel, 10 bps/side.

## Mandatory diagnostic (a) — reconcile vs rung-0 (A8)

- Rung-0 bar: `SR_X(EW)` = **+1.377 net** ([[quant-pilot-01-RESULT]]). Pilot-01 18-config family mean: **1.363** → the bar sits +0.014 (+1.0%) above its family mean: **the bar was NOT selection-luck-inflated** (A8's pre-execution reading confirmed empirically; the +1.634 ceiling was context, never the bar).
- This pilot's family: **all 6 configs negative**, family mean `SR_X(EW)` = **−0.369**, best config −0.234. The gap to rung-0 is not a near-miss but a wrong-sign family (≈ 1.7 Sharpe units below the bar).
- **Caveat that dominates the reading:** the OOS cross-sections were built from 9.7% of filings, survivors of a connection outage — a non-random sample (whatever the egress layer let through first). The negative family is *directionally adverse but not a clean falsification*; the guard's INCONCLUSIVE is the honest verdict precisely because this sample cannot support KILL either.

## Mandatory diagnostic (b) — failures + zero-filing tickers by item/year (A7)

- **By item** (fetch_fail shares; multi-item filings counted per item; **Critic-corrected 2026-07-29** — the original shares were renormalized to the top-3 items only): 2.02 = 33.8%, 7.01 = 25.2%, 5.02 = 20.0%, 1.01 = 11.0%, 2.03 = 7.2%, rest ≤ 1.3%. **No concentration flag:** no item > 50% (max 33.8%), and the shares mirror the index composition (of all records: 2.02 = 33.7%, 7.01 = 24.8%, 5.02 = 20.0%, 1.01 = 11.4%, 2.03 = 7.0%) with per-item failure rates uniform (49.0–52.5%) — failures are volume-proportional, not item-specific. (Conclusion unchanged by the correction.)
- **By year:** max share 2020 = 17.0% — **no year concentration** (< 50%); per-year failure *rates* uniform 0.898–0.915 across 2020–2026. The only real concentration is temporal-phase (99.996% valoos) → flagged as **infrastructure**, per the root-cause section, never a silent re-sample.
- **Zero-filing tickers:** exactly one — **XOM** (mapped, but `n_8k_inwindow = 0`: an enumeration-level zero, not item-filter attrition; `excluded_no_items = 0`). Per frozen A7: `S = 0` neutral, never excluded, logged in `data/coverage.full.json`. 1/503 = 0.2% of the cross-section — second-order. (Next-lowest: HONA 2, FDXF 4 — recent spinoff/IPO thin history, expected.) Lowest-coverage names populate the bottom of the S-distribution as designed.

## Frozen consequence + fix path

INCONCLUSIVE row, verbatim: *"No verdict — infra/compute failure, not thesis failure. Fix the path, re-run."*

1. **Fix the path:** pre-dispatch egress probe to `www.sec.gov` (steward staged job #2, [[steward-24h-review-2026-07-29]]); run the valoos re-extraction only when sustained full-text success is confirmed.
2. **Re-run scope:** re-extract the **27,733 failed filings only** (`status == fetch_fail` in `data/extractions.full.jsonl`; `resume_extract.py` resumes per-filing). Config freeze L1Q5 stands — it predates all OOS extraction and is never re-selected (frozen A9b carve-out: affected-filings re-extraction, logged, is not re-optimization). Then: probe (≥ 30-sample leak audit actually performed) → ρ → re-apply the verdict table exactly.
3. This is an infra-resume, **not** the NO-EVIDENCE one-redesign allowance (which remains unspent).
4. **Honest expectation for the re-run:** if the clean sample resembles the decimated one (wrong-sign family, DSR p = 0.974), the unmasked verdict is KILL (`SR_X(EW) ≤ 0`) — row 4 killed as stated. The re-run buys a *clean* verdict, not a hopeful one. NO-EVIDENCE/KILL remains the modal expected outcome, as pre-committed.

## Z2 flag — ledger (NOT flipped by this session)

Row-4 Result/Status update is staged for Critic + human sign-off at [[critic-quant-pilot-02-RESULT-2026-07-29]] (proposal: Result = INCONCLUSIVE (breadth guard), Status stays `idea` — INCONCLUSIVE is no verdict). [[ledger]] itself untouched here.

**Evidence paths:** `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` — `results.json` (verdict + all numbers), `RUNSTATE.md` (live state + checklist), `data/extraction_log.full.json` (frozen prompt + digest), `data/extractions.full.jsonl` (per-filing statuses), `data/orchestrate.log` (timeline), `data/coverage.full.json` (A7 coverage), `data/mask_audit.full.json` (empty — audit gap), `data/config_freeze.json`. $0, paper only, no capital touched.

## Critic certification — 2026-07-29 (append-only addendum; frozen verdict UNTOUCHED)

**CERTIFIED.** INCONCLUSIVE is the exact frozen-table row, applied guard-first. Full adversarial review: [[critic-quant-pilot-02-RESULT-certification-2026-07-29]].

- **Reproduced independently from `data/extractions.full.jsonl`:** 78/138 window months < 100 ok tickers = 56.5% (exactly 2020-01→2026-06; every train month ≥ 177); status counts ok 27,927 / model_fail 21 / parse_fail 0 / fetch_fail 27,733; error kinds `fetch_error:ConnectionError` 27,732 + `http_503` 1 (the sole train-phase failure, MLM 2016-05); zero 429/403; fail latency median 0.8 s / max 40.05 s. Guard code order verified (`run_pilot.py:apply_verdict` 217-231: guard → KILL → NO EVIDENCE → PROMOTE; no early exit to KILL despite SR_X(EW) = −0.349 ≤ 0).
- **Correction applied above** (A7 by-item shares were top-3-renormalized; true shares 33.8/25.2/20.0/11.0/7.2%; no-flag conclusion unchanged).
- **Sharpenings (verdict-neutral):** (1) the valoos outage was a step function — the first ~2,968 valoos extractions succeeded (~10 min), then the ok-counter flatlines (`orchestrate.log`) → onset ≈22:25Z, the signature of an egress failure, not content attrition ("entire phase" above is precise to ~10 min); (2) the gateway journal's 23:12Z upstream-fail burst sits INSIDE the SEC storm window — strengthens the suspected common root (label stands: suspected, not verified; direct causation refuted); (3) `results.json:guard.extraction.months_under_100_extracted` is a deliberate head-12 preview (`run_pilot.py:207`); the count 78 is authoritative and reproduced.
- **Re-run gate (Critic finding):** Guard-5 probes the :8705 model gateway, NOT SEC egress — in this incident the gateway path was 99.8% healthy while SEC fetch was ~90% dead, so a green gateway probe would NOT imply a green SEC fetch. The re-run must gate on a direct `www.sec.gov` full-text probe.
- **Ledger row-4 update proposal staged** in the certification note (Z2 — NOT flipped here; Status stays `idea`).

## Clean-fetch re-run — 2026-08-01 (append-only addendum; the INCONCLUSIVE above is SUPERSEDED by KILL on the full clean sample — frozen verdict text untouched)

The INCONCLUSIVE above was the exact frozen verdict on the decimated 9.7% sample (infra guard). Its own frozen consequence — *"Fix the path, re-run"* — has been executed: step-1 egress GREEN + re-extraction ([[quant-pilot-02-step1-egress-green-relaunch-2026-07-31]]), then the fixed-mask probe. This addendum records the clean re-score. **Recorded verdict: KILL.**

**Precondition + gates (all MET):** RUNSTATE lock FREE; fixed-mask probe complete (`data/probe_rerun_2026-08-01.log`: `1607 fetched, 0 fetch-fail`, ρ=0.7760, n_pairs=1540); [[critic-mask-fix-audit-2026-08-01]] read first → **CLEAN, no frozen-scope violation** (mask.py diff masking-only, bytecode-verified, A4-sanctioned); mandatory `mask_audit.full.json` re-count → **0/30 = 0.0% ≤ 10%** across all four frozen categories (ticker 0, person 0, absolute-date 0; `[COMPANY]` 30/30, `[DAY±n]` 30/30). ρ trusted.

**Extraction (clean):** 55,681 records → ok **55,563** (99.79%) / model_fail 116 / parse_fail 0 / **fetch_fail 2 (0.0036%)**; malformed-failure rate **0.21%**; breadth **0/138** window months < 100 extracted (was 78/138). **All INCONCLUSIVE sub-guards now FALSE** — the guard that fired above is cleared by the re-extraction, so the table reaches the thesis.

**Config grid (frozen L1Q5, never re-selected — A9b):**

| Config | Train SR | OOS SR raw | OOS `SR_X(EW)` net |
|---|---|---|---|
| L1D | 1.181 | 1.134 | −1.082 |
| **L1Q5 (selected)** | **1.288** | 1.323 | **−0.857** |
| L2D | 1.032 | 1.260 | −0.266 |
| L2Q5 | 1.136 | 1.327 | −0.934 |
| L3D | 1.048 | 1.298 | +0.012 |
| L3Q5 | 1.113 | 1.317 | −0.632 |

Family mean `SR_X(EW)` = **−0.627** (decimated run −0.369 — the clean sample is *more* negative). Selected L1Q5 OOS (N=42): `SR_X(EW)` = **−0.857** net (**gross −0.651** — wrong-sign before costs too), `SR_X(SPY)` = −0.589, net 17.24%/yr vs EW 19.79% (mean excess −2.55%/yr) vs SPY 21.37%, MDD −11.01%, one-way turnover 25.6%/mo (decimated 1.69% — the full sample populates the cross-section, so the book rebalances for real), val SR 0.633. DSR (trials=6, skew +0.046/kurt 3.384): **p = 0.9977** (SR0 0.711 ann.). PBO (CSCV 16×8, 12,870 combos, first-128-month trim): **0.2908** (Sharpe), 0.5721 (cumret); L1Q5 IS-best 9,234/12,870. **ρ = 0.7760188168361031** (fixed mask). `beats_rung0 = false`.

**Verdict-table trace (frozen order):** INCONCLUSIVE → **NO** (breadth 0/138, failure 0.21%, EDGAR reachable, N=42, ρ present). KILL → `SR_X(EW) = −0.857 ≤ 0` → **YES, verdict stops here** (PBO 0.291 < 0.5 and ρ 0.776 ≥ 0.5 do not fire; the wrong-sign clause alone kills). NO EVIDENCE / PROMOTE not evaluated (had SR_X been positive, DSR p 0.998 ≥ 0.05 and ρ 0.776 < 0.8 would each independently give NO EVIDENCE). **KILL** — row 4 killed as stated; revival requires a new ledger row + new Critic review (NOT the NO-EVIDENCE redesign allowance, which a KILL does not grant).

**Leaky-vs-fixed ρ reconciliation:** leaky ρ=0.767988 (n_pairs=n_sample=1607) → fixed ρ=0.776019 (n_pairs=1540, n_sample=1607, p=3.6e-310). **Δρ = +0.008, negligible** — closing the 36.7% identity leak did not inflate ρ; both land in `[0.5, 0.8)` (signal retains ~78% of rank info under masking; not identity-collapsed, moot since KILL fires first). n_pairs −67 (4.2%) = masked re-extractions failing JSON-parse after the one frozen retry (fetch-fail 0; `run_probe` appends a pair only on successful parse); direction conservative per A5 (cannot push ρ toward 0.8); at n=1540, p=3.6e-310.

**Honesty note — `run_pilot.py` ρ-ordering bug (worked around, not patched):** `verdict --tag full` without `--rho` returns a spurious INCONCLUSIVE with a self-contradictory guard (`inconclusive=true` AND `rho_missing=false`): `mode_verdict` tests `rho is None` on the CLI argument (run_pilot.py:281-283) *before* loading ρ from `probe.full.json` (run_pilot.py:313-315). Workaround: pass the frozen probe value via the CLI — `verdict --tag full --rho 0.7760188168361031` → `inconclusive=false` → KILL. Frozen scoring code left untouched (bytecode-identity preserved); the bug biases toward the softer INCONCLUSIVE, the workaround reveals the harsher KILL. Recommended future A9b patch: load probe ρ above the guard. Prior INCONCLUSIVE `results.json` preserved at `results.inconclusive.2026-07-28.json` (verified byte-identical pre-overwrite).

**A8 reconciliation:** rung-0 bar +1.377 net (pilot-01 family mean 1.363, not luck-inflated); this clean family mean −0.627, family best L3D +0.012 (5/6 configs negative; Critic-corrected 2026-08-01 — "best config −0.266" mis-read the table: L3D +0.012 > L2D −0.266) — a wrong-sign family ≈ 2.0 Sharpe units below the bar (even the family best sits 1.37 below it). The [[ktd-fin]] "plausible LLM edge" channel is falsified on this universe/window.

**Z2 flag (NOT flipped here):** row-4 proposal staged in [[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]] — Result = KILL, Status `idea`→`killed`, pending Critic + human sign-off. [[ledger]] untouched.

**Evidence paths:** `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` — `results.json` (run_utc 2026-08-01T05:36:09Z — Critic-corrected from 05:34Z, which was the wave start (RUNSTATE:175); verdict KILL + all numbers), `data/probe.full.json` (ρ=0.776, n_pairs=1540), `data/mask_audit.full.json` (0/30 re-audit), `data/probe_rerun_2026-08-01.log` (1607 fetched, 0 fetch-fail), `data/config_freeze.json` (L1Q5), `results.inconclusive.2026-07-28.json` (preserved). $0, paper only.

## Critic certification of the KILL — 2026-08-01 (append-only addendum; recorded KILL UNTOUCHED)

**CERTIFIED.** KILL is the exact frozen-table row, applied guard-first on the clean sample; every headline number independently reproduced (in-memory re-score of the frozen scoring code — no writes; all figures to 1e-9). Full adversarial review: [[critic-quant-pilot-02-KILL-certification-2026-08-01]]. Two verdict-neutral corrections applied above (run_utc 05:34→05:36:09Z; family best L3D +0.012, not L2D −0.266; "whole family wrong-sign" → 5/6). Ledger row-4 KILL proposal endorsed — staged for human sign-off, NOT flipped.
