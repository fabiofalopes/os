---
tags: [steward, review, queue-empty]
date: 2026-07-27
session: "#25"
---

# Steward Queue-Empty Review #25 — 2026-07-27

## What compounded (last 24h: 07-26 ~18:47Z → 07-27 ~18:30Z)

**The engine self-healed and the live bet is running.** The builder-lane deadlock that zeroed dispatch 09:00→13:38Z was fixed twice over (empty-queue fall-through + bridge guard at 13:38Z; the 3-bug fix — anchored tag match, `BUILDER_BUDGET` per-attempt cap, builder-pick breaker — verified already in-tree at 14:05Z), and all 4 stranded jobs then completed. **ROW-4 EXECUTE launched** (13:54Z): pipeline audited+hardened (signal.py stdlib-shadow crash fixed, 2 frozen INCONCLUSIVE guards added), Stage-0 PASS, ~22h detached extraction running — last shepherd check 17:15Z: 10,190/25,051 (40.7%), 100% ok, ~2,950/hr, verdict ETA ~2026-07-28 midday WEST. ROW-4 decomposed into 3 resumable ≤900s steps ([[quant-pilot-02-PLAN]]); FETCH verified, EXTRACT shepherd healthy, SCORE correctly deferred. Substrate caught up: INDEX sweep applied (8 entries, revenue pipeline now visible), MEMORY.md state refreshed, Oracle refreshed + made durable (_ORACLE-CURATED.md). Row-1 date re-verified against the live API (first resolution 2026-08-07; single score run ≥2026-09-02). ~12/14 dispatched sessions → ok with artifacts.

## Repeated failures flagged

1. **Monolithic >900s jobs die artifact-less.** ROW-4 EXECUTE timed out at 900/901s twice (07:06/08:33Z, ~1800s burned) before decomposition + the builder cap fix let it finish at 1008s. Mitigation shipped; residual rule: any job whose real runtime can exceed its lane cap must be decomposed or explicitly builder-tagged.
2. **Builder-lane routing patched twice in 24h** (introduced 07-26 20:26Z → deadlock #1; fall-through fix 07-27 13:38Z; 3-bug fix same day). Most fragile subsystem in the harness — job #3 below turns the week's incidents into a regression checklist.
3. **Duplicate dispatch after done-work** (ROW-1 RECONCILIATION re-ran at 08:18Z only to find itself VERIFIED-DUPLICATE; the 14:05Z deadlock-fix run found the fix already in-tree). Cheap because idempotent, but queue check-off lags real completion. Minor; watch.

Quota storm (07-23→26, 10+ × 429) is closed: breaker shipped 07-26, quota reset 07-27 04:07Z, zero 429s since.

## 3 staged jobs (→ _harness/proposals.md, top = first bridged; all worker-lane-safe, none disturbs the live run)

1. **[Critic] ATTACK THE ROW-4 SHEPHERD PROTOCOL** — read-only adversarial audit of the RUNSTATE/resume protocol protecting the unattended ~22h extraction (the one revenue line the agent can complete; never Critic-attacked).
2. **[Janitor] ORACLE REFRESH (pre-verdict)** — the human's screen still leads with the deadlock story; lead instead with row-4 running → verdict tomorrow, and the one decision owed (row-2 publish).
3. **[Janitor] ENGINE FAILURE-MODES CATALOG** — consolidate the week's 6 incident classes into `_harness/FAILURE-MODES.md` (symptom → cause → breaker → regression check) + a pre-change checklist for harness edits.
