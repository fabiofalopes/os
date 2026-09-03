---
tags: [quant, row-4, fetch, verification, session-record]
date: 2026-07-27
role: Quant worker (cron tick)
status: verified — cache intact, no action taken
links: ["[[quant-pilot-02]]", "[[quant-pilot-02-execution-2026-07-27]]"]
---

# Row-4 Step 1/3 — FETCH cache verification (PASS, no-op)

> Job: verify the frozen [[quant-pilot-02]] fetch cache; relaunch `fetch_filings.py --tag full` **iff missing**.
> Pipeline dir: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`

## RUNSTATE decision-tree (ran first, read-only)

- `flock -n data/orchestrate.lock` → **LOCK-HELD** → live detached extraction running → branch 1: do NOT relaunch anything.
- `results.json` → absent → verdict not in (expected ~2026-07-28 midday WEST).
- Live progress (`data/progress.full.json`, 16:13Z): **7,300/25,051** train filings, n_ok 7,300 (0 failures), 2,990/hr, ETA ≈ 6h more on train window.

## Cache invariants — all PASS

| Invariant (frozen) | Observed | Verdict |
|---|---|---|
| 0 fetch errors | `fetch_errors: {}` | ✅ |
| ≥500 tickers with ≥1 included filing | `n_tickers_with_included: 502` (of 503 mapped; XOM is the known zero-filing name) | ✅ |
| 55,920 included after item filter | `n_included: 55,920` **and** CSV data rows = 55,920 (exact cross-check) | ✅ |
| Item counts 2.02 > 7.01 > 5.02 | 2.02 → 23,524 > 7.01 → 17,259 > 5.02 → 13,951 | ✅ |

Supporting: 77,130 in-window 8-Ks total, 21,210 excluded (no matched items); 503/503 universe mapped, 0 unmapped; all 77,130 point-in-time on `acceptance` source.

## Cache integrity

- `data/filings_index.full.csv` (7.8 MB) + `data/coverage.full.json` (52 KB) both present.
- mtimes **09:33:19**, strictly before the 13:47 extraction start → frozen cache, untouched by the live run.

## Action taken

**None — correct outcome.** Cache EXISTS → relaunch condition (iff missing) not met; relaunching would also have violated the LOCK-HELD branch. Step 1/3 verified clean; steps 2–3 (extraction → verdict) are owned by the live detached run.

$0, paper only, read-only session.
