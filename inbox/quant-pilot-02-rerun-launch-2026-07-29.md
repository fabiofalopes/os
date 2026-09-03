---
tags: [quant, pilot, execution, inbox]
date: 2026-07-29
status: live — detached re-extraction running; STEP 2/2 shepherd owed
---

# quant-pilot-02 — Clean-Fetch Re-Run LAUNCHED (STEP 1/2 shepherd)

> **Verdict: egress gate GREEN (3/3 HTTP 200), re-extraction DETACHED + ALIVE, first 200/200 re-extractions → ok.** The frozen consequence of the Critic-CERTIFIED row-4 INCONCLUSIVE ([[quant-pilot-02-RESULT]], [[critic-quant-pilot-02-RESULT-certification-2026-07-29]]) is now executing. This session was its shepherd; the compute outlives it.

## 1. RUNSTATE check (ran FIRST, per the decision tree)

- `flock -n data/orchestrate.lock` → **FREE** (no live detached run to disturb)
- `results.json` → **EXISTS** (original run complete; INCONCLUSIVE verdict already recorded + Critic-certified)
- `data/progress.full.json` (pre-launch): `finished: true`, records 55,681, n_ok 27,927, window valoos — the storm-damaged run, at rest.

## 2. The gate the Critic certified MISSING — DIRECT www.sec.gov egress probe

Explicitly **not** the :8705 model gateway (gateway was 99.8% healthy while SEC fetch was ~90% dead; gateway 200 checked anyway for launch sanity: `GET /v1/models` → 200, 0.9 ms).

**Design:** fetch 3 EDGAR full-text filing URLs through the pipeline's OWN session config (`common.py:sec_get` → `http_session()` — same UA `Forge Research fabio@forge.local`, ≤10 req/s limiter, same retry adapter). Targets = **the very URLs that failed** (most honest test):

| ticker | CIK | accession | prior failure | probe status | bytes | latency |
|---|---|---|---|---|---|---|
| MLM | 916076 | 0001564590-16-017858 | http_503 | **200** | 33,153 | 0.27 s |
| AXP | 4962 | 0000004962-26-000281 | ConnectionError | **200** | 27,148 | 0.14 s |
| AZO | 866787 | 0001171843-20-001448 | ConnectionError | **200** | 13,995 | 0.17 s |

**Probe GREEN: 3/3 HTTP 200.** The local-egress storm has cleared. (Root cause of the 2026-07-28 storm remains unproven — suspected transient local egress, per [[quant-pilot-02-RESULT]]; this probe confirms recovery, not cause.)

## 3. Failure census (evidence for the launch scope)

From `data/extractions.full.jsonl` (55,681 records): **ok 27,927 · fetch_fail 27,733 · model_fail 21**.
- fetch_fail by window: **valoos 27,732, train 1** (MLM 2016-05, http_503) — the storm hit during the valoos phase but one train-window filing fell too.
- fetch_fail by kind: ConnectionError 27,732, http_503 1.
- `model_fail` (21) is DEFINITIVE → correctly never retried.

## 4. Launch (detached, per RUNSTATE pattern)

```bash
cd ~/Projects/trading-agents/quant-research/pilots/quant_pilot_02
export ANTHROPIC_BASE_URL=http://localhost:8705          # locked-model proxy (A6)
setsid nohup flock -n data/orchestrate.lock \
  ~/Projects/trading-agents/quant-research/.venv-pilot/bin/python \
  resume_extract.py --tag full --window all \
  >> data/resume_extract_rerun.log 2>&1 &
```

Launched 2026-07-29 ~13:48 UTC (pid 2327216 under flock 2327214). Lock confirmed HELD by the re-run. Log: `data/resume_extract_rerun.log`.

**One documented deviation:** the job said `resume_extract.py --tag full`, but `--window` is a *required* argparse flag — bare `--tag full` errors. Used `--window all` because the census shows failures in BOTH windows (1 train + 27,732 valoos); `all` is the only scope re-extracting all 27,733. This is a scope flag for *which pending records get re-attempted* — NOT a config re-selection: frozen config L1Q5, prompt, model (`qwen3.8-max-preview`), and parsing are untouched (A9b affected-filings carve-out). `resume_extract.py` retries only transient `fetch_fail`; definitive statuses are skipped.

Runner-reported pending: **27,895** (27,733 fetch_fail + 239 never-attempted + index/jsonl membership drift −77).

## 5. The 180 s assertion — PASS

| metric | baseline | +112.8 s (chunk 1) | +~265 s (chunk 2) |
|---|---|---|---|
| n_ok | 27,927 | 28,027 (+100) | **28,127 (+200)** |
| records | 55,681 | 55,681 | 55,681 |
| process | — | ALIVE | ALIVE |

- **n_ok grew +200; first 200/200 re-extractions → ok (zero new failures).** Clean fetch confirmed under production load, not just probe.
- `records` flat **by construction**: `resume_extract.py` rewrites the jsonl deduped by accession — re-attempts *replace* fetch_fail records; records grows only via the 239 never-attempted. **n_ok is the true progress signal** for this run; the next shepherd should track it, not records.
- **Throughput honesty:** `progress.full.json:throughput_per_hour` (1.78M) is an artifact — it computes `len(done)/elapsed` over the 55,681 pre-loaded records. Real rate from flush intervals: chunk 1 ≈ 3,190/hr, chunk 2 ≈ 2,480/hr → **~2,500–3,200/hr** (consistent with Stage-0's 2,504/hr and train's 2,750/hr).
- **ETA:** ~27,700 remaining ÷ ~2,800/hr ≈ **9–10 h → completion ~2026-07-29 23:00–00:00 UTC** if the laptop stays up.

## 6. Handoff — STEP 2/2 shepherd (owed, next wave)

1. RUNSTATE check first: lock HELD → report progress, exit. Lock FREE + `finished: true` in `progress.full.json` → re-extraction done.
2. Verify clean fetch: count `fetch_fail` in `data/extractions.full.jsonl` — expect ≈0 (the 21 `model_fail` remain, definitive). If a NEW storm appears (fetch_fail climbing), do NOT relaunch blindly — re-run the §2 probe first (that is how the 49.8% was born).
3. Only then: re-run signal + verdict on the completed extractions, frozen config L1Q5, per the frozen table in [[quant-pilot-02]] — record-and-advance, NOT a new pre-registration. Modal expectation stays **KILL**; the re-run buys a CLEAN verdict, not a hopeful one.

## Invariants held

Model LOCKED (`alibaba-token-plan/qwen3.8-max-preview`; gateway reachable; no swap, no chain-walk). $0, paper only, no capital. No frozen constant touched. Shared substrate (LOG/INDEX/MEMORY/queue) untouched — Curator catalogs.
