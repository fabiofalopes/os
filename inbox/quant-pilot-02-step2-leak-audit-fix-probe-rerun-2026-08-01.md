---
tags: [quant, pilot-02, leak-audit, masking, builder, cron-worker]
date: 2026-08-01
status: probe-rerun-active
---

# quant-pilot-02 — step-2 leak audit FAILED 36.7% → mask.py FIXED (frozen-clause sanctioned) → fixed-mask probe re-launched → re-score DEFERRED

**Verdict: the completed probe's masking leaked identity in 11/30 audit samples (36.7% > 10% frozen bar) → ρ=0.768 is UNTRUSTED. Per the frozen leak-audit clause I fixed the two masking defects, verified 0% leaks + 0 over-mask locally, and re-launched the probe detached on the fixed mask (ETA ≈ 2026-08-01 ~03:38Z). Re-score / RESULT amendment / ledger proposal are DEFERRED to the wave that holds a clean ρ.** $0, paper only; model LOCKED (qwen3.8-max-preview, no swap); frozen config L1Q5 never re-selected.

## 1. RUNSTATE decision tree (ran first)
- The 2026-07-31 detached probe **completed** 23:30:15Z: `probe.full.json` ρ=0.768, n_pairs=1607, 0 fetch-fail; `mask_audit.full.json` = 30 samples (the audit debt is now populated).
- Lock **FREE** at wave start, no live run → NOT deferred on FM-8; proceeded into step 2.

## 2. Breadth guard — PASS (job step 1)
Fresh frozen `run_pilot.extraction_guards('data/extractions.full.jsonl')`:

| metric | value |
|---|---|
| n_months_total | 138 |
| **n_months_under_100_extracted** | **0 → 138/138** ✓ (was 78/138 on the decimated sample) |
| breadth_fail / failure_fail | False / False |
| status | ok 55,563 (99.79%) · model_fail 116 (0.21%) · fetch_fail 2 (0.0036%) · parse_fail 0 |
| n_records | 55,681 |

## 3. Leak audit — FAILED 11/30 = 36.7% (job step 2)
Manual review of all 30 `masked_excerpt` in `mask_audit.full.json`, scored ONLY against the four categories the frozen `mask.py` procedure claims to strip (company name, bare ticker, person, absolute date). Addresses / phone / IRS-ID / commission-file-number leak too, but they were **never in the frozen procedure**, so they are noted, not counted (no goalpost move either direction).

| category | leaking samples | count |
|---|---|---|
| company name | 0,1,2,3,4 (MMM "3M COMPANY") | 5 |
| bare ticker | 0,1,2,3,4 (`mmm:`) · 9,10,11,12,13 (`abbv:`) · 22 (`aes:`) | 11 |
| person | — | 0 |
| absolute date | — (all → [DAY±n]) | 0 |
| **union (distinct leaking samples)** | {0,1,2,3,4,9,10,11,12,13,22} | **11/30 = 36.7%** |

Company-name alone = 5/30 = 16.7%; both readings exceed the 10% frozen bar.

**Root causes (both in `mask.py`, both mechanical):**
1. **Company name** — step-1 guard `if name and len(name) > 2:` skipped MMM's universe security name **"3M"** (len 2) → nothing masked → "3M COMPANY" leaked verbatim.
2. **Bare ticker** — step-2 `re.sub(r"\b"+t+r"\b", " ", s)` is **case-sensitive**; the ticker is uppercase ("MMM") but the XBRL custom namespace prefix is lowercase (`mmm:Notes…`), so the prefix survived and trivially re-identifies the issuer.

**Consequence:** ρ=0.768 was measured while identity leaked — the model could lean on memory of the named company, which is exactly what the mask exists to prevent. **ρ is untrusted until the leak rate is ≤10%** (frozen rule).

## 4. The fix — sanctioned, surgical, verified
`mask.py` is frozen (A4), but its **own docstring** carries the amendment clause: *"residual identity leak rate > 10% → fix this procedure and re-run the probe (probe re-run ≠ signal re-optimization)."* The job and RUNSTATE concur. This is masking **mechanics** only — sample selection, model, prompt, ρ math, and the verdict table are untouched (A9b infra carve-out, like the sig.py rename). Two changes:

1. **Step 1 — short digit-bearing names masked whole-word.** Added `elif any(c.isdigit() for c in name): re.sub(r"\b"+name+r"\b", "[COMPANY]", s, IGNORECASE)`. Long names keep the frozen substring path byte-for-byte. Whole-word (not substring) so "3M" doesn't corrupt "2023**M**ember". Universe blast radius = **exactly one name** ("3M"; IBM is len 3, already masked; F5/L3Harris/Phillips 66 are len>2, unchanged).
2. **Step 2b (new) — lowercase XBRL prefix removed.** `re.sub(r"\b"+t+r":", " ", s, IGNORECASE)`. The required trailing colon + leading word boundary strip `mmm:`/`abbv:`/`aes:` while keeping len-1 tickers (A,T,C,…) from eating prose ("ide**a:**" has no boundary before the 'a').

**Local verification (test, don't wonder):** re-fetched the same 30 audit filings and re-masked with the fixed `mask.py`:
- Leak rate **36.7% → 0/30 = 0.0%** (whole-word check matching the frozen spec).
- Over-mask artifacts **0/30** ("2023Member" left intact; no `\d[COMPANY]` corruption).
- Locked-model proxy healthy (HTTP 200, model replied).

## 5. Action — fixed-mask probe re-launched DETACHED
Leaky outputs retired as evidence — `data/probe.leaky.2026-08-01.json` (ρ=0.768) + `data/mask_audit.leaky.2026-08-01.json` (the 36.7% audit) — and the live `probe.full.json`/`mask_audit.full.json` **deleted** so no later wave mistakes the untrusted ρ for the clean one. Then:
```bash
cd ~/Projects/trading-agents/quant-research/pilots/quant_pilot_02
setsid nohup flock -n data/orchestrate.lock env ANTHROPIC_BASE_URL=http://localhost:8705 \
  ~/Projects/trading-agents/quant-research/.venv-pilot/bin/python run_probe_logged.py --tag full \
  >> data/probe_rerun_2026-08-01.log 2>&1 &
```
Launched 2026-08-01T00:12:16Z (flock wrapper pid 4188419 / python pid 4188421). Healthy at first heartbeat: `probe sample: 1607 OOS filings`, **25 fetched / 0 fetch-fail / 468 pairs/hr → ETA ≈ 2026-08-01 ~03:38Z.** Same deterministic sample (every 10th OOS, universe-then-date). `results.json` still the 2026-07-28 INCONCLUSIVE — untouched.

## 6. Deferred (needs the clean ρ)
Re-score (`run_pilot.py verdict --tag full`), the [[quant-pilot-02-RESULT]] clean-re-run amendment, and the Z2 [[ledger]] row-4 proposal all wait on the new `probe.full.json`. The finishing wave must:
1. **RE-AUDIT** the new `mask_audit.full.json` (30 samples) against the four frozen categories — must be ≤10% (expect 0 with the fix); quote it in the RESULT note.
2. Re-score, then apply the frozen verdict table EXACTLY (order INCONCLUSIVE → KILL → NO EVIDENCE → PROMOTE; PROMOTE bar SR_X(EW) > +1.377 net AND DSR p < 0.05 trials=6 AND PBO < 0.3 AND ρ ≥ 0.8 AND SR_X(SPY) > 0). Note the leaky ρ was already 0.768 < 0.8; the clean ρ is re-measured now.
3. Amend RESULT in place (frozen verdict text untouched); stage the ledger row-4 proposal as a NEW inbox note — do NOT flip ledger status.

**Modal expectation unchanged: KILL** on a clean sample (decimated family all-negative, mean −0.369, DSR p = 0.974). The re-run buys a CLEAN verdict, not a hopeful one.

## Links
[[quant-pilot-02]] (FROZEN design) · [[quant-pilot-02-RESULT]] (2026-07-28 INCONCLUSIVE, to be amended) · [[quant-pilot-02-step1-egress-green-relaunch-2026-07-31]] · [[ledger]] · RUNSTATE.md in the pilot dir (live decision tree).
