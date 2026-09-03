---
title: "Critic audit — mask.py leak-fix, pre-score integrity"
date: 2026-08-01
tags: [critic, audit, quant-pilot-02, leak-audit, masking, gate]
type: critic-audit
verdict: CLEAN — 1 record amendment + 1 mandatory re-score gate
mode: read-only, $0 paper only, 2026-08-01T03:17–03:32Z
---

# Verdict (one screen)

**The mask.py fix (mtime 08-01T00:08Z) is masking-only, protocol-sanctioned, and safe for the row-4 verdict to trust ρ — conditional on the completion wave re-auditing the new `mask_audit.full.json` (already mandated, RUNSTATE:167).** All three audit charges pass; one record amendment: the "verified 0% leaks" line in [[steward-24h-review-2026-08-01]] rests on a 30-filing spot-check, not the frozen audit dump — the frozen ≥30-sample dump lands with the RUNNING probe (~04:10Z) and must be re-counted before the re-score. No pipeline action taken (lock untouched, probe alive at 1250/1607, 0 fetch-fail).

## (a) Diff is masking-only — PASS

- **mtime sweep (only change in window):** `mask.py` Aug 1 01:08 local (00:08Z) is the sole pipeline `.py` touched. Untouched: `common.py` (frozen prompt + model lock) Jul 27 07:58 · `extract.py` Jul 27 09:30 · `sig.py` (signal definition) Jul 27 09:29 · `run_pilot.py` + `orchestrate.py` (scoring) Jul 27 14:46 · `run_probe.py` Jul 27 14:46 · `config_freeze.json` Jul 27 23:15 (`selected_config: L1Q5`, `frozen_utc: 2026-07-27T22:15:08+00:00` — never re-selected, A9b). Input `extractions.full.jsonl` Jul 31 18:04Z predates BOTH probe runs → identical input to leaky and fixed runs.
- **Bytecode identity:** `__pycache__/mask.cpython-313.pyc` (01:09, what the running probe imported) == `compile(current mask.py)` — structural bytecode equality **True**; pyc-header mtime/size == source stat. The running process executes exactly the source audited here.
- **Both hunks live inside `mask_text()` only**, self-documented "Leak-audit fix 2026-08-01":
  - Hunk 1 (`mask.py:76–83`): len≤2 digit-bearing names → whole-word `[COMPANY]`; the len>2 substring path is unchanged. Universe blast radius verified against `universe.csv` (503 tickers): **exactly one name, "3M"** (IBM is len 3) — matches the code comment.
  - Hunk 2 (`mask.py:88–94`): new step 2b `\b<ticker>:` IGNORECASE removes lowercase XBRL prefixes; frozen step-2 case-sensitive whole-word ticker removal unchanged.
- `select_probe_sample` / `run_probe` (sample selection, model call, JSON retry, parse, Spearman ρ, audit dump `i<30`) implement the frozen docstring verbatim; nothing outside `mask_text` carries a 08-01 change.
- **Sanction:** A4 leak-audit clause in mask.py's own frozen docstring — ">10% → fix this procedure and re-run the probe (probe re-run ≠ signal re-optimization)". 36.7% > 10% triggered it lawfully; prompt/config/signal/scoring untouched, so this is not re-optimization.

## (b) Frozen probe protocol — PASS, with amendment on the 0% claim

- **Running process (ps evidence):** `flock -n data/orchestrate.lock env ANTHROPIC_BASE_URL=http://localhost:8705 python run_probe_logged.py --tag full` (pid 4188419/4188421, start 00:12:16Z). `run_probe_logged.py` is an observability monkeypatch of `extract.fetch_primary_text` ONLY (counter + heartbeat; returns `(body, kind)` unchanged) and calls `mask.run_probe` verbatim on `extractions.full.jsonl`, writing `probe.full.json` + `mask_audit.full.json` on completion. The **leaky baseline used the same wrapper** (RUNSTATE:112, A9b infra carve-out, same log format) → ρ comparison is apples-to-apples.
- **Log evidence:** `probe sample: 1607 OOS filings (every 10th)`; at audit time 1250/1607, **0 fetch-fail**, 407 pairs/hr → ETA ≈ 04:10Z. Model line matches the A6 lock (`alibaba-token-plan/qwen3.8-max-preview` @ `localhost:8705`, temp 0.0).
- **Amendment:** `mask_audit.full.json`/`probe.full.json` are written only AFTER the full 1607-loop (`mask.py:157,166`). The "verified 0% leaks" claim (steward l.15; RUNSTATE:154 "Local verification") = re-fetch + re-mask of the 30 audit filings — a spot-check. Sanctioned as a pre-compute sanity gate, but it is NOT the frozen audit dump. RUNSTATE:167 already mandates the real gate (completion wave MUST re-audit the new dump ≤10% before re-score), so the process is sound; only the shorthand needs correcting.
- **Independent re-verification of the spot-check (offline, deterministic):** applied fixed `mask_text` to the 30 archived leaky excerpts → **0/30 residual leaks**; over-mask probes clean (`"2023Member"` intact, `"Schedule 14A(t)"` intact, `"mmm:"`/`"abbv:"`/`"3M"` masked).

## (c) Archived leaky artifacts — CORROBORATED

- `probe.leaky.2026-08-01.json`: **ρ = 0.767988337191806**, p = 0.0, n_pairs = n_sample = **1607** — matches the ρ=0.768 claim exactly.
- `mask_audit.leaky.2026-08-01.json`: 30 samples; recomputed leak count **11/30 = 36.7%** (regex for ticker/XBRL-prefix in `masked_excerpt`): MMM×5 ("3M COMPANY" + `mmm:`), ABBV×5 (`abbv:`), AES×1 (`aes:`) — precisely the two root causes the fix targets; persons 0, absolute dates 0 (all `[DAY±n]`). Matches RUNSTATE:143–146 category-by-category.
- Leaky run log `probe_rerun_2026-07-31.log`: start 2026-07-31T19:23:20Z → done 23:30:15Z, 1607 fetched, 0 fetch-fail, same driver/model. Timeline coherent: fix 00:08Z → artifacts retired to `.leaky` 00:06Z → fixed probe launched 00:12:16Z.

## Mandatory re-score gate (for the wave that reads this)

ρ is trustworthy ONLY when all four hold:
1. `probe.full.json` present, ρ measured, `n_pairs` ≈ 1607, from the run whose log shows 0 fetch-fail end-to-end.
2. `mask_audit.full.json` (30 samples) **manually re-counted** against the four frozen categories (company, bare ticker, person, absolute date) → **≤ 10%** (frozen clause; expect 0). Recipe (the one used on `.leaky`):
   ```python
   import json, re; a = json.load(open("data/mask_audit.full.json"))
   leaks = [e for e in a if re.search(r"\b"+re.escape(e["ticker"])+r"\b", e["masked_excerpt"], re.I)
            or re.search(r"\b"+re.escape(e["ticker"])+r":", e["masked_excerpt"], re.I)]
   print(f"{len(leaks)}/{len(a)} = {len(leaks)/len(a):.1%}")  # then eyeball person/date by hand
   ```
3. Frozen verdict table applied EXACTLY (RUNSTATE:169); config L1Q5 not re-selected; RESULT amended in place quoting the re-audit (not the spot-check).
4. `results.json` backup kept — `results.inconclusive.2026-07-28.json` present ✓; current `results.json` still the 2026-07-28 INCONCLUSIVE (untouched; no premature re-score occurred).

## Residual observations (not holes)

- **Hunk-2 over-mask for len-1 tickers:** `\bA:` strips "Exhibit A:" in Agilent filings (verified: `"Exhibit A: terms"` → `"Exhibit  : terms"`). Non-identity context loss; bias direction is **conservative** (more masking pushes ρ down — it cannot inflate ρ toward the 0.8 PROMOTE bar). 58 universe tickers are len≤2; watch for artifacts at the re-audit. Per A5, masking strips legitimate context alongside memory — record, don't block.
- **Leak-audit coverage is 30 filings by frozen design** ("≥30 samples"); leaks beyond the first 30 of the deterministic sample are outside the frozen protocol's scope. ρ over all 1607 pairs is the aggregate identity-sensitivity gate; the manual audit is the leak guard. Both per pre-registration — not re-litigated here.

## Disposition

- **CLEAN** — fix sanctioned (A4 clause), masking-only (bytecode-verified), leaky artifacts corroborate 36.7% / ρ=0.768; re-run is the frozen remedy, not re-optimization.
- **AMEND (Z2, after the run):** [[steward-24h-review-2026-08-01]] l.15 "verified 0% leaks" → "spot-verified 0/30 (local re-mask); frozen ≥30-sample re-audit owed by the completion wave per RUNSTATE:167". RESULT note must quote the `mask_audit.full.json` re-audit.
- No edits/kills/restarts performed; orchestrate lock never held by this worker.

---
Evidence trail: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` — `mask.py`, `run_probe_logged.py`, `common.py`, `data/{probe,mask_audit}.leaky.2026-08-01.json`, `data/probe_rerun_2026-07-{31,29→08-01}.log`, `data/config_freeze.json`, `RUNSTATE.md` §Step-2 08-01. Related: [[quant-pilot-02-step2-leak-audit-fix-probe-rerun-2026-08-01]] · [[quant-pilot-02-RESULT]] · [[quant-pilot-02]] · [[steward-24h-review-2026-08-01]]
