---
tags: [janitor, oracle-refresh, session-record]
date: 2026-07-27
role: Janitor
status: done
---

# Oracle Refresh — pre-verdict, live-bet lead (2026-07-27 ~19:48Z)

## What changed
Rewrote the curated lead in `_ORACLE-CURATED.md` (the durable source `oracle.sh` renders into `_ORACLE.md` every tick — hand-editing `_ORACLE.md` directly would be clobbered). Then ran `bash _harness/oracle.sh` to render + verified the lead landed (doc comment stripped, live numbers present).

Reframe: the resolved engine deadlock no longer leads as a crisis. The arc line now leads with the **live bet (row 4) running healthy**; the deadlock is demoted to a "RESOLVED, dispatching clean since 13:38Z" bullet. Bullet order follows the job: (1) engine resolved → (2) row-4 live bet → (3) row-1 dates → (4) row-2 publish = fastest path → (5) row-3 killed/rung-0. The decisions line now names the **ONE** decision owed = publish go/no-go (market #19 void/exclude kept as a subordinate, non-urgent parenthetical so a real owed call isn't dropped).

## Live evidence used (Test, don't wonder)
Source: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/data/progress.full.json`, read 19:45:44Z.
- lock: **RUNNING** (`flock -n data/orchestrate.lock` → RUNNING); no `results.json` yet.
- train: **17,223 / 25,051 = 68.7% (~69%)** done; `n_ok` 17,208 → **99.9% ok**; throughput **2,880.9/hr (~2,881)**; elapsed 21,522s (≈6.0h); `updated_utc` 2026-07-27T19:45:44Z (fresh, advancing).
- Note: the job prompt said "~40%+, ~2,950/hr" — that was a stale snapshot; live data is ~69% / ~2,881/hr. Reported the live numbers.
- Verdict ETA: ~7,828 filings left @ 2,881/hr ≈ 2.7h → train done ~22:30Z; then auto config-freeze → val+OOS extraction (~12h) → probe → `run_pilot.py:apply_verdict`. RUNSTATE.md: "results.json expected ~2026-07-28 midday WEST if the laptop stays up." Modal outcome KILL/NO-EVIDENCE (honest).

## Other claims re-verified on disk
- Row-1 one command: `~/Projects/forecast-scorer/run_verdict.sh` exists, executable (-rwxrwxr-x, 8.6KB). First resolution 2026-08-07; single score run ≥2026-09-02 (per [[forecast-pilot-01]] + [[quant-row1-date-reconciliation-2026-07-27]]).
- Engine fix evidence (14/14 + 27/27 sandbox assertions, `bash -n` clean) carried from prior oracle + [[janitor-builder-deadlock-3bug-verify-2026-07-27]]; not re-run this session (out of scope — this was a reframe refresh).

## Verdict
SUCCESS — human's one-screen view now leads with the live bet, deadlock reframed as cleared, ONE decision (publish) restated. $0, no capital, no git.
