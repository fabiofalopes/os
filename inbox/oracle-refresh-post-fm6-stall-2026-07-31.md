---
tags: [janitor, oracle, inbox]
date: 2026-07-31
role: Janitor
status: durable — evidence trail for the 2026-07-31 oracle refresh
---

# Oracle Refresh — post-FM-6 + row-4 stall→relaunch (2026-07-31)

**Verdict:** `_ORACLE-CURATED.md` refreshed (the durable source `oracle.sh` renders; `_ORACLE.md` itself untouched). One screen, verdict/arc lead, no firehose. Supersedes the 2026-07-29 post-verdict refresh.

## What changed vs the previous lead

1. **FM-6 ship promoted to the lead.** TIMEOUT(BUT_ARTIFACT) credit shipped 2026-07-31, 26/26 sandbox assertions, incident class #6 closed — verified against [[janitor-timeout-but-artifact-ship-2026-07-31]] (26/26 PASS list, `bash -n` clean, production smoke HEALTHY; suite caught + fixed the wave-overlap phantom-credit bug before ship).
2. **Row-4 line rewritten stall→escalation→relaunch.** Verified against [[quant-pilot-02-step2-stall-escalation-2026-07-31]] (10th byte-identical DEFERRED; fresh precondition table: fetch_fail 13,797/24.8%, 136/138 months, ρ=None, all `data/` mtimes ≤ 2026-07-29 22:49Z) and [[quant-pilot-02-step1-egress-green-relaunch-2026-07-31]] (DIRECT www.sec.gov probe 3/3 HTTP 200; detached relaunch ~13:18Z).
3. **Live-state check (test, don't wonder) — 2026-07-31T15:16Z:** `resume_extract.py` PID 3858442 alive, `orchestrate.lock` held, `resume_extract_rerun2.log` advancing: `+5700 new | records=55681/55920 ok=47405`. That is ok 41,843→47,405 (+5,562 of the ~13.8k residual) in ~2h → ETA ≈ 18:00Z (slightly behind the relaunch note's ~17:30Z early-rate estimate; stated as ~18:00Z). The oracle says RUNNING, not "staged" — the job prompt's "staged" framing was overtaken by this morning's green-gate relaunch.
4. **26h dark window added.** Verified against [[steward-24h-review-2026-07-31]]: 106× SKIP(QUOTA) 07-30T04:00Z→07-31T06:15Z, 0 tokens (FM-3 breaker worked); DEFERRED churn 19×/4085s (68 min) as proximate cause; DEFERRED-hold fix = staged proposals job #2.
5. **Decisions section restated as TWO** (was one): row-2 publish GO/NO-GO (☐ GO / ☐ NO-GO at the foot of [[tool-pilot-01-publish-checklist]]) and row-4 relaunch-vs-accept ([[quant-pilot-02-step2-stall-escalation-2026-07-31]]) — the latter flagged *partly preempted* by the green-gate relaunch, returning to the human only if the run dies again. Honesty over spec-verbatim: telling the human they owe a relaunch decision the engine already executed on a green gate would be noise.
6. **Dropped:** the FM-7 gateway-502 / empty-queue engine line (superseded — Guard-5 breaker shipped 07-29, FM-7 closed per [[FAILURE-MODES]]; the current engine story is the FM-6 ship + the quota-dark window).

## Links

- Refreshed artifact: `_ORACLE-CURATED.md` (vault root)
- Staged follow-up that triggered this refresh: [[steward-24h-review-2026-07-31]] job #3
- Next natural refresh: when the row-4 relaunch hits `finished=True` + step-2 re-score lands a clean verdict (ETA this evening) — or on the next FM ship.

$0, paper only, no capital.

PRODUCED: inbox/oracle-refresh-post-fm6-stall-2026-07-31.md
