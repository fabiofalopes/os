---
tags: [value, quant, pilot, execution-plan, ledger-row-4, resumable]
date: 2026-07-27
status: draft (Z2) — operational decomposition of the FROZEN [[quant-pilot-02]] test into 3 bounded cron steps; no design degree of freedom added (kill criteria, grid, model lock, verdict table untouched)
related:
  - "[[quant-pilot-02]]"
  - "[[quant-pilot-02-execution-2026-07-27]]"
  - "[[quant-pilot-01-RESULT]]"
  - "[[ledger]]"
---

# Quant Pilot 02 — 3-Step Resumable Execution Plan

> **Why this exists:** the monolithic `[Quant] EXECUTE THE ROW-4 PILOT` job timed out twice on the builder lane at 900s (LOG 2026-07-27T07:06/08:33Z, ~1800s burned, zero artifacts) — a ~22h compute job cannot live inside one cron session. This note decomposes it into **3 bounded queue jobs (FETCH → EXTRACT → SCORE)**, each ≤900s, each resuming from cache so a timeout never restarts from zero. **Operational change only:** the frozen design in [[quant-pilot-02]] (signal, grid, model lock, masking, verdict table, rung-0 bar +1.377) is untouched — the decomposition adds checkpoint discipline, not degrees of freedom (A9b-compliant: never config re-selection).

## ⚠ Live-run reconciliation (verified 2026-07-27 ~16:20 WEST)

**The pipeline is already running detached** — the 14:47-WEST session ([[quant-pilot-02-execution-2026-07-27]]) launched `orchestrate.py` under `flock` after the two builder-lane timeouts. Verified live: process alive (PID 866148/866150/866151), train extraction **4,300/25,051 at 2,956/hr** (`data/progress.full.json`, 15:14Z), Stage-0 PASS, full index done. ETA `results.json` ≈ **2026-07-28 midday WEST** if the laptop stays up.

**Consequence:** every step-job below begins with the RUNSTATE decision tree (`pilots/quant_pilot_02/RUNSTATE.md`): check the flock, never relaunch a live run. While the detached run is healthy, STEP 1 and STEP 2 dispatch as cheap verify/monitor no-ops. The steps are the *recovery and completion protocol* — they also cover the case where the run dies (suspend/reboot) and must be resumed by a later tick.

**Path correction:** the staging job named `~/Projects/quant-pilot-02/`; the actual pipeline lives at **`~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`** (verified on disk). All step-jobs use the real path.

## Critic audit (2026-07-27, live, read-only) — CLEAN-CONDITIONAL

Attacked mid-run at 15,663/25,051 train ([[critic-shepherd-audit-2026-07-27]] has full evidence). **The three headline attacks fail:** relaunch cannot corrupt extraction order (stages sequential + file-gated) or masking (probe deterministic, no RNG, runs once); mid-flush crash loses ≤100 filings (atomic tmp+rename flush — verified: 0 unparseable lines, 0 dup accessions in 15,663 live records); flock is race-free vs parallel waves (relaunch command is self-locking; live `fuser` shows a single holder). Per-chunk log strictly monotonic; failure rate 0.096% (≪ 20% guard). Frozen design untouched by this audit.

**Four holes found — all availability/robustness, none can corrupt the signal; fixes STAGED for after `results.json`, never during the run:**
- **H1 (medium):** `progress.full.json` written non-atomically and parsed unchecked in `window_complete` → a torn file would crash-loop every shepherd relaunch until human repair (data safe; recovery blocked).
- **H2 (low):** `config_freeze.json` / `results.json` same non-atomic write class.
- **H3 (low):** frozen index has 239 duplicate accessions (478 rows, multi-subject 8-Ks) → ~0.85% wasted calls; **STEP 3 must reconcile unique records (55,681 expected) vs index rows (55,920) in the RESULT note**.
- **H4 (low):** relaunch flock path is cwd-relative → use the RUNSTATE `cd` line verbatim; absolute path staged.

**Shepherd caution until the run lands:** if a relaunch ever exits non-zero repeatedly, suspect H1 (corrupt progress file) — the recovery is deleting `data/progress.full.json` (the jsonl is the truth; the stage regenerates it), but that is a human/Critic decision, not an autonomous one.

## Cache layout (real artifacts ↔ the job's abstract names)

All under `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/` (vault stays markdown-only):

| Step | Abstract | Real artifact | Status 2026-07-27 |
|---|---|---|---|
| 1 FETCH | `data/` filings cache | `data/filings_index.full.csv` (55,920 included 8-Ks, 2014-09→2026-06, item-filtered) + `data/coverage.full.json` (502/503 tickers, 0 fetch errors, XOM zero-filing) | **DONE** |
| 2 EXTRACT | `signals/` | `data/extractions.full.jsonl` (per-filing `{materiality, valence, rationale}` — the raw of `S(i,m)`) + `data/progress.full.json` (checkpoint, flushed every 100 filings) + `data/extraction_log.full.json` (frozen model+prompt+digest) + `data/config_freeze.json` (auto-written after train, before any OOS extraction) | **RUNNING** (train window) |
| 2b probe | — | `data/mask_audit.full.json` → ρ (runs *inside* the detached orchestrator, ~25 min — not a cron step) | pending |
| 3 SCORE | verdict | `results.json` (written by `orchestrate.py` step 6: SR_X vs EW+SPY, DSR trials=6, PBO CSCV 16×8/128-mo trim, ρ, guards, verdict) → `wiki/value/quant-pilot-02-RESULT.md` + [[ledger]] row-4 flag | pending (~07-28) |

The `S(i,m)` panel is built from `extractions.full.jsonl` by `sig.py` at score time (`run_pilot.py`) — there is no separate signals directory; the jsonl **is** the signal cache.

## The 3 step-jobs

### STEP 1 — FETCH (verify cache; worker lane, ~60s)

- **Precondition check:** `filings_index.full.csv` + `coverage.full.json` exist → verify-only.
- **Action (warm, the normal path):** assert coverage invariants from the frozen note — 0 fetch errors, ≥500 tickers with ≥1 included filing, item-filter counts sane (2.02 > 7.01 > 5.02…), index row-count matches coverage total. Report + exit.
- **Action (cold — cache missing only):** `python fetch_filings.py --tag full` (idempotent; ≤10 req/s SEC fair access; all `filings.files` pages per A3). Cold fetch is ~10–20 min — if it cannot finish in 900s it dies cleanly and retries next tick; tag cold-refetch dispatches for the builder lane if ever needed.
- **Done criterion:** coverage invariants hold. **Resume:** warm path is stateless; cold path restarts (index fetch is all-or-nothing on disk — the only non-incremental artifact, and the cheap one).

### STEP 2 — EXTRACT (ensure-running + bounded monitor; **[builder]** tag, ≤~300s session)

The 22h compute **never runs inside the session** — it runs detached; the cron job is its shepherd.

- **Precondition check (RUNSTATE tree, verbatim):** `flock -n data/orchestrate.lock true` → RUNNING or FREE; `ls results.json`.
  - **RUNNING** → read `progress.full.json`, report `records/target · n_ok · throughput/hr`, exit. (This is the current state.)
  - **FREE + results.json** → extraction done; exit — STEP 3's turn.
  - **FREE + no results.json** → relaunch detached (idempotent, resumes from last 100-filing flush): `export ANTHROPIC_BASE_URL=http://localhost:8705; setsid nohup flock -n data/orchestrate.lock …/.venv-pilot/bin/python orchestrate.py >> data/orchestrate.log 2>&1 &` — then `sleep 180; cat data/progress.full.json` and assert `records` advanced. Exit.
  - **Locked model unreachable** (proxy down/404) → INCONCLUSIVE pause per A6. **Do NOT swap models.** Report + exit.
- **Done criterion:** `progress.full.json` shows `finished: true` for window `oos` (orchestrator then auto-runs probe + verdict). **Resume:** every timeout loses ≤100 filings of work (flush granularity) — never a restart.
- **Invariants the job may not touch:** model lock `alibaba-token-plan/qwen3.8-max-preview` (A6), frozen prompt + masking procedure (in `common.py`/`mask.py`), extraction order (train → freeze → OOS, enforced by `orchestrate.py`).

### STEP 3 — SCORE (verdict + RESULT note; worker lane, ~300–600s)

- **Precondition check:** `results.json` exists (else: report progress, exit — not yet time). The masking probe (~25 min) and verdict computation already ran *inside* the detached orchestrator, so this step is bounded.
- **Action:** read `results.json`; independently re-check the verdict-table application (order: INCONCLUSIVE → KILL → NO EVIDENCE → PROMOTE, thresholds exactly as frozen in [[quant-pilot-02]]); write `wiki/value/quant-pilot-02-RESULT.md` per the frozen step-6 checklist — quote the frozen prompt (`extraction_log.full.json`), masking procedure + ≥30-sample leak audit (`mask_audit.full.json`), model digest, extraction stats + failure rate; mandatory diagnostics (a) reconcile `SR_X`(EW) vs rung-0 **+1.377** AND family mean **1.363** (A8); (b) failures + zero-filing tickers by item/year with concentration flag (A7).
- **Ledger (Z2):** the SCORE job writes the RESULT note as a Z2 draft and **stages a Critic-review + ledger-row-4 update proposal** — it does not silently flip row-4 status (human/Critic sign-off per the frozen note).
- **Done criterion:** RESULT note exists with verdict + all six frozen report fields; ledger flag staged. **Resume:** stateless re-run (results.json is immutable once written; re-runs only for a documented pipeline bug per A9b).

## Failure modes (all → INCONCLUSIVE, never model-swap, never sample-shrink)

- **Laptop suspend/reboot:** detached process pauses or dies; STEP 2's next tick detects FREE + no results and relaunches; flush-granularity loss ≤100 filings.
- **Token-plan expiry (~2026-08-19 vs ~22h runtime):** negligible now; if it bites mid-run → INCONCLUSIVE pause, resume on the same locked model.
- **Proxy 429 storm:** shows as `model_fail` records; the 20% failure-rate guard catches systemic rates → INCONCLUSIVE.

## Staging record

2026-07-27: three step-jobs appended to `_harness/proposals.md` (FETCH → EXTRACT `[builder]` → SCORE), dependency order = priority; they merge via the bridge one-per-wave when the queue empties. The monolithic EXECUTE proposal is superseded (already merged `[>]`; its live detached run is what these steps now shepherd to completion).

---

**Verdict:** `—` (plan only; the test runs). This note buys operational resilience, not evidence — the evidence lands in `quant-pilot-02-RESULT.md` (~2026-07-28).
