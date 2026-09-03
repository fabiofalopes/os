---
tags: [steward, review, queue-empty]
date: 2026-07-27
session: "#24"
---

# Steward Queue-Empty Review #24 — 2026-07-27

## What compounded (last 24h: 07-26 ~12:30Z → 07-27 ~12:30Z)

**The engine's first real falsification landed.** Row 3 (12-1 momentum) was KILLED by its pre-committed PBO guard (0.77 ≥ 0.5) — a durable negative result plus a measured rung-0 baseline (≈ +1.38 SR net) that every future agent signal must beat ([[quant-pilot-01-RESULT]]). Row 4 (LLM 8-K extraction) was born ([[quant-pilot-02]]) and Critic-hardened (9 amendments). Engine upgrades shipped: 429 quota breaker + builder-lane routing. Row-1 verdict date reconciled (08-04 confirmed correct; ORACLE's "09-02 correction" was wrong). 8/9 dispatched sessions → ok with artifacts.

## Repeated failures — ENGINE DEADLOCK (critical, root-caused from source)

Zero jobs dispatched since ~09:00Z; every wave `SKIP(EMPTY_QUEUE)` while 4 jobs sit unchecked in queue.md (l.58/60/61/63). Verified by reading runner.sh + worker.sh:

1. **Routing false positive (the deadlock core).** `runner.sh:120` `job_lane()` does `grep -qiF '[builder]'` — matches that literal token **anywhere** in the job text. The FIX job at `queue.md:61` *quotes the token in its own description*, so it's misrouted to the builder lane. Net effect: all 4 unchecked jobs classify as builder. The worker claim loop (`runner.sh:198-200`) doesn't stop at builder jobs — it `continue`s — but with *every* job builder-classified, `J_JOB` ends empty → empty-queue branch → no pending proposals → throttle → SKIP. The fix is stranded by the very bug it fixes.
2. **Builder jobs cap at 900s, not 2400s.** `worker.sh:67` sets `per=$SESSION_TIMEOUT` (900) for every attempt regardless of the budget arg, so ROW-4 EXECUTE died at 900s/901s twice (LOG 07-27T07:06/08:33Z, ~1800s burned, zero artifacts) instead of using `BUILDER_BUDGET=2400`.
3. **No breaker on the builder pick.** `pick_builder_job` (`runner.sh:127-133`) has no fail-streak quarantine (the worker loop does, l.192), so the perpetually-timing-out job at l.58 is returned every builder wave forever, blocking the whole lane.

**Staging hazard (acted on):** because of bug #1, any proposal whose text contains the literal builder token is itself misrouted and stranded. The 3 jobs below are deliberately worded to avoid that token (and the `^[Quant]…EXECUTE` auto-route) so they dispatch on the worker lane; once #1 is fixed the 4 stranded jobs self-heal.

## 3 staged jobs (→ _harness/proposals.md, top = first bridged)

1. **[Janitor] FIX THE BUILDER-LANE DEADLOCK** — the master key; fixes all 3 verified bugs (anchored tag match, builder per-attempt cap = BUILDER_BUDGET, breaker on the builder pick) so the queue self-heals.
2. **[Quant] DECOMPOSE THE ROW-4 PILOT** — split the monolith into 3 resumable ≤900s steps (fetch → extract → score) so it can't timeout again.
3. **[Janitor] ORACLE REFRESH — ENGINE DEADLOCK ALERT** — tell the human the engine is stuck and that row-2 publish go/no-go remains the fastest path to money.
