---
tags: [quant, pilot-02, egress, shepherd, cron-worker]
date: 2026-07-31
status: active-run
---

# quant-pilot-02 — step-1 egress gate GREEN → detached re-launch (2026-07-31 ~13:18Z)

**Verdict: egress GREEN (3/3 HTTP 200 direct www.sec.gov) → step-1 `resume_extract` re-launched DETACHED, verified healthy: +200 ok in 219s (~3,290/hr), ETA ≈ 2026-07-31 ~17:30Z.** This ends the 9-wave byte-identical DEFERRED loop ([[quant-pilot-02-step2-stall-escalation-2026-07-31]]). $0, paper only; model LOCKED (qwen3.8-max-preview, no swap).

## 1. RUNSTATE decision tree (ran first)
- Lock **FREE**, no detached run alive — all `data/` mtimes 2026-07-29; `progress.full.json` frozen at 2026-07-29T19:01 (records 55,681/55,920, n_ok 41,843, `finished=False`).
- `results.json` = the stale 2026-07-28 INCONCLUSIVE — **untouched**.

## 2. Egress gate (the Critic finding, non-negotiable)
DIRECT www.sec.gov probe — explicitly **not** the :8705 model gateway — via the pipeline's OWN `common.sec_get` (shared `http_session`, UA `Forge Research fabio@forge.local`, ≤10 req/s limiter), against 3 filings that had died `fetch_error:ConnectionError` (first/mid/last of the 13,793 ConnectionError residuals):

| status | bytes | time | URL |
|---|---|---|---|
| HTTP 200 | 33,153 | 0.17s | sec.gov/Archives/edgar/data/916076/000156459016017858/mlm-8k_20160505.htm |
| HTTP 200 | 19,823 | 0.14s | sec.gov/Archives/edgar/data/872589/000093041320000068/c94939_8k-ixbrl.htm |
| HTTP 200 | 61,972 | 0.14s | sec.gov/Archives/edgar/data/1555280/000155528026000029/zts-20260520.htm |

**3/3 → GREEN.** Locked-model gateway :8705 also healthy (HTTP 200, 3.6s on a max_tokens=8 ping).

## 3. Action (GREEN branch)
Launched detached per RUNSTATE pattern (new log; the 2026-07-29 death log preserved):
```bash
export ANTHROPIC_BASE_URL=http://localhost:8705
setsid nohup flock -n data/orchestrate.lock \
  ~/Projects/trading-agents/quant-research/.venv-pilot/bin/python \
  resume_extract.py --tag full --window all \
  >> data/resume_extract_rerun2.log 2>&1 &
```
- Script-reported `pending=13,865` at start (transient `fetch_fail` retries + never-attempted; definitive ok/parse_fail/model_fail skipped by design).
- Frozen config **L1Q5 untouched** — `resume_extract.py` is extraction-only; no selection path exists in it (A9b carve-out honored).

## 4. 180s shepherd verification
- **n_ok 41,843 → 42,043 (+200)**; log shows +100 → +200 new with ok tracking 1:1 → ~100% retry success. Egress repair holds at scale, not just on the 3 probe URLs.
- `records` unchanged at 55,681 — **expected**: retries overwrite per-accession (deduped flush), so `records` only moves on the ~239 never-attempted filings. **n_ok growth is the residual-clearing signal**; a flat `records` here is not a stall.
- Throughput (delta-honest): 200 new / 218.9s ≈ **3,290/hr**. ⚠ `progress.full.json`'s own `throughput_per_hour` (915,580) divides cumulative records by this-run elapsed — an artifact, ignore it.
- **ETA:** 13,665 pending remain → ~4.2h → `finished=True` ≈ **2026-07-31 ~17:30Z** if the laptop stays up.
- Lock HELD by the detached run, python alive, log advancing.

## 5. Next-wave trigger (step 2)
Proceed to step 2 (leak audit ≥30 samples → re-score → verdict re-apply) ONLY when: `fetch_fail≈0` AND `finished=True` AND a ≥30-sample probe returns a measured ρ. Never re-select L1Q5. If the run DIED again (lock FREE + frozen progress), re-run THIS gate first — probe RED → record + exit, never relaunch into a storm (that is how the 49.8% was born).

Related: [[quant-pilot-02-step2-stall-escalation-2026-07-31]] · [[quant-pilot-02-RESULT]] · RUNSTATE.md (pilot dir)
