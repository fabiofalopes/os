---
tags: [critic, audit, quant, quant-pilot-02, shepherd-protocol]
date: 2026-07-27
role: Critic
status: complete — verdict CLEAN-CONDITIONAL (4 low/medium holes, none integrity-threatening; fixes staged for post-run)
related:
  - "[[quant-pilot-02-PLAN]]"
  - "[[quant-pilot-02]]"
---

# Critic Audit — Row-4 Shepherd Protocol (live, read-only)

> **Mandate:** adversarially attack the RUNSTATE/resume protocol protecting the detached [[quant-pilot-02]] extraction (~22h, verdict ETA 2026-07-28 midday WEST) while ~60% of the run remains. Three attack questions: (a) can a shepherd relaunch (branch c) corrupt extraction ORDER or masking? (b) can a mid-flush crash lose >100 filings? (c) is the flock discipline race-free vs parallel cron waves + the detached process? Hard rules honored: no edits/restarts/kills on the pipeline, no prompt/masking/model changes, lock never held by this session, $0 paper only. Audit window 20:15–20:35 WEST, run at 15,663/25,051 train (62.5%).

## Verdict table

| # | Attack | Verdict | Evidence |
|---|---|---|---|
| A | Relaunch corrupts extraction ORDER (train→freeze→OOS) | **CLEAN** | `orchestrate.py` stages are sequential + file-gated; stage 4 (valoos) unreachable before stage 3 creates `config_freeze.json` in *any* single run; resume skips DEFINITIVE records keyed by accession. Verified in code + live: no `config_freeze.json` exists while train still running (correct). |
| B | Relaunch corrupts masking/probe | **CLEAN** | `mask.py`/`run_probe` contain no RNG; probe sample = every 10th OOS ok-record in (universe-rank, acceptanceDateTime) order — deterministic given the jsonl; probe gated on `probe.full.json` existence, runs once. Interrupted probe leaves neither `mask_audit` nor `probe` file → relaunch re-runs from scratch on identical input. Neither file exists yet (correct — extraction in progress). |
| C | Mid-flush crash loses >100 filings | **CLEAN — bound holds** | `resume_extract.flush()` writes `*.jsonl.tmp` then `tmp.replace(path)` (atomic rename); flush every chunk=100. Crash mid-write → partial tmp, original intact → loss ≤100 new extractions. Live: no stray `.tmp` files; jsonl = 15,663 lines, 15,663 unique accessions, **0 unparseable, 0 dups**. |
| D | Flock race vs parallel cron waves | **CLEAN** | Live `fuser`: single holder (PID 866148 flock + 866150 orchestrate). The branch-c relaunch command is *self-locking* (`setsid nohup flock -n data/orchestrate.lock … orchestrate.py`) — N simultaneous shepherd relaunches → only one acquires; the rest exit immediately. Check-then-relaunch TOCTOU is closed by this inner flock. |
| E | Double-count in signal panel after restart | **CLEAN** | `sig.load_mv_panel` reads the jsonl, which `flush()` writes from a dict keyed by accession → structurally one record per accession. Verified live: 0 duplicate accessions in 15,663 lines. |

**Bottom line:** the three headline attacks fail. The protocol's core invariants (atomic jsonl flush, accession-keyed dedup, self-locking relaunch, file-gated stage order, deterministic probe) are real and live-verified. The run has never been resumed (start log: `already-done=0`, single continuous chunk sequence) — the resume path is code-verified only, an honest caveat.

## Holes found (ranked; all availability/robustness class — none can corrupt the signal)

### H1 — MEDIUM (availability): non-atomic `progress.full.json` + unchecked parse → potential infinite relaunch-crash loop
`resume_extract.progress()` writes via `write_text` (truncate+write, **not** tmp+rename). `orchestrate.window_complete()` does `json.loads(p.read_text())` with no try/except. A crash/power-loss mid-write → corrupt progress file → **every** subsequent orchestrate launch throws → shepherd sees FREE + no results → relaunches → crashes again → stuck until a human deletes the file. Extraction data is intact (jsonl is the truth); only recovery is blocked. Probability low (tiny single write) but non-zero over 22h on a laptop.
**Staged fix (post-run):** (1) progress write via tmp+rename like the jsonl; (2) `window_complete` returns False on JSONDecodeError — safe because the re-run stage regenerates progress from the jsonl truth. Zero design degrees of freedom added.

### H2 — LOW (same class): `config_freeze.json` and `results.json` also written non-atomic
`run_pilot.py:258` (freeze) and `:341` (results) use `write_text`. A torn freeze file would make stage 3's exists-branch parse crash on every relaunch (and a torn `results.json` would crash the shepherd's verdict read). Same fix: tmp+rename.

### H3 — LOW (waste/cosmetic, flag for STEP 3): 239 duplicate accessions in the frozen index
`filings_index.full.csv`: 55,920 rows, **55,681 unique accessions** (478 dup rows; same filing under 2 tickers, e.g. CEG+EXC share `0001109357-22-000001` — EDGAR multi-subject 8-Ks). Consequences, all bounded: (a) ~478 wasted model calls over the full run (0.85%); live log shows the dedup divergence directly (`+15700 new | records=15663` — 37 dup re-extractions so far). (b) Last-wins ticker attribution for those 239 filings is `as_completed`-order-dependent **across from-scratch re-runs** — locked within this run (resume skips definitives). (c) `finished` flag can't reach True via the in-loop check (24,974 unique < 25,051 rows) but the `not pending` early-exit self-heals it on relaunch, and orchestrate never gates stage 3 on the flag — no stall. 3/239 dups have differing cik → a permanently failing fetch row may retry on every resume (3 cheap SEC fetches, harmless tail; current jsonl: exactly 1 fetch_fail).
**Action:** STEP 3 (SCORE) must reconcile *unique records* (55,681 expected) vs *index rows* (55,920) in the RESULT note's extraction stats so the discrepancy is documented, not discovered later. No pipeline change during the run.

### H4 — LOW (hardening): relative lock path in the RUNSTATE decision tree
`flock -n data/orchestrate.lock` is cwd-relative. A shepherd that skips the `cd` line checks/creates a stray lock elsewhere → misreads FREE while the run is live. The chain to actual damage needs a second mistake *and* fails safe in practice (from the vault root `data/` doesn't exist → flock errors; from `quant-research/` the relative `orchestrate.py` path won't resolve). RUNSTATE.md documents the `cd` first, so this is residual.
**Staged fix (post-run):** absolute lock path (`flock -n "$PWD/data/orchestrate.lock"` or literal path) in the relaunch line.

## Requested spot-checks (live, read-only)

- **progress monotonicity:** the three named checkpoints (16:16/16:46/17:15Z) were **not found as vault artifacts** (grep of LOG.md + inbox/ empty — they appear to have been verbal shepherd reports). Verified by a stronger source instead: `data/orchestrate.log` per-chunk history is **strictly monotonic** records 100 → 15,663, `ok` non-decreasing (15,648), throughput steady 2,846–2,992/hr across 157 chunks; current `progress.full.json` (19:16:39Z, elapsed 19,776s ⇒ start 13:47Z, matches RUNSTATE) is consistent with the PLAN's logged 4,300 @15:14Z. No backwards step anywhere.
- **extraction_log "append-only":** more precisely write-once-then-immutable — `resume_extract.py:117` writes only `if not exists`. Live: mtime 14:47 WEST (=13:47Z, before first extraction), model digest `ef495d63…` matches RUNSTATE, prompt byte-identical to `common.PROMPT_TEMPLATE`. ✓
- **mask_audit samples so far:** file does not exist — *correct*, the probe is stage 5 after valoos completes. Nothing to sample yet; determinism verified in code (see attack B).
- **Failure rate so far:** 14 model_fail + 1 fetch_fail / 15,663 = **0.096%** — two orders of magnitude under the frozen 20% guard.
- **ETA sanity:** 9,388 train left @ 2,851/hr ≈ 3.3h; valoos 30,869 ≈ 10.8h; +probe 25min ⇒ results ~07-28 midday WEST, consistent with the PLAN.

## Staged fix proposal (execute ONLY after `results.json` lands — never during the run)

1. `resume_extract.progress()` + `run_pilot.py` freeze/results writes → tmp+rename (H1, H2).
2. `window_complete()` → try/except JSONDecodeError → return False (H1).
3. RUNSTATE/PLAN relaunch line → absolute lock path (H4).
4. `fetch_filings.py` → dedup index rows by accessionNumber at build time, keeping the universe-order-first ticker (kills H3 at the source; changes a frozen-input *build* step, so it needs a documented A9b-style note before any future re-run, not this run).
5. STEP 3 RESULT note: add the unique-vs-rows reconciliation line (H3).

None of these touch the frozen prompt, model lock, masking procedure, grid, kill criteria, or verdict table — operational resilience only, in the PLAN's own A9b lane.

## Self-audit honesty notes
- Resume path verified statically, not live (the run has never resumed).
- The 16:16/16:46/17:15Z checkpoints could not be located; monotonicity proven from the authoritative per-chunk log instead (superset of the requested check).
- This session never acquired `data/orchestrate.lock` (the `flock -n … true` probe is non-blocking and was refused → RUNNING; no write/restart/kill issued).
