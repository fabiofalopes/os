---
tags: [steward, meta-review, harness, ops]
date: 2026-07-21
review: 2
window: 2026-07-21T06:23Z (META-REVIEW #1) → 2026-07-21T08:16Z
status: durable — supersedes #1's tuning where noted
related:
  - "[[meta-review-2026-07-21]]"
  - "[[schedule]]"
  - "[[multi-agent-orchestration-patterns]]"
  - "[[ledger]]"
  - "[[forecast-pilot-01]]"
---

# META-REVIEW #2 — first review of the wave engine

> Window: META-REVIEW #1 (06:23Z) → now (08:16Z), ~1h53m. The engine changed underneath this window: the manual "agentic village" upgrade (3 parallel workers/tick + builder + substrate guard) landed ~07:00–07:30Z, so this review covers the wave engine's first ~3 live waves. Named `-2` to avoid overwriting [[meta-review-2026-07-21]]; future reviews: check for an existing same-day file first.

## The numbers (evidence, not vibes)

Full day 2026-07-21, session lines only (`grep '^- 2026-07-21' LOG.md` minus `manual`; cross-checks health.sh exactly: runs=32, ok=9, fail=23):

| Verdict | Count | Root class |
|---|---|---|
| ok | 9 | **9/9 produced a durable artifact** (verified via LOG summaries + INDEX) |
| exit1 | 18 | 17× proxy storm 00:11–04:02Z on ONE job (pre-hardening; breaker now caps retries at 3) + 1× transient "Connection closed" (05:19Z, succeeded on next attempt 05:37Z) |
| TIMEOUT(900s) | 5 | 4× workspace-trust (04:45, 06:45, 07:33×2) + 1× heavy-job (08:00Z) |
| SUBSTRATE_VIOLATION | 1 | guard reverted a worker's INDEX.md edit (07:33Z); zero data loss, one wasted worker-turn |

**Since #1:** 4 ok (all artifacts: [[forecast-pilot-01]] — the first falsifiable revenue test; Janitor trust+health fix; Scout full-text verify upgrading 2 clips ★★★; #1 itself) vs 4 non-ok (3 trust timeouts + 1 heavy-job timeout) + 1 guarded violation.

## Q1 — Is the 15-min cadence right? YES, no change.

Failures in-window were job-size and infra, never cadence: the wave engine cleared the post-storm backlog in ~2 waves, and every post-trust-fix session behaved. The binding constraint is **queue supply, not tick rate** (pending=4 at review time, 2 of which are the recurring Steward jobs). Ratified again at 15-min / 3 workers.

## Q2 — Durable artifacts or token burn? Artifacts, with one structural burn risk.

- Post-hardening burn ratio is healthy: 18 zero-artifact exit1s all predate the router/preflight/breaker; the breaker (MAX_JOB_RETRIES=3) makes a 17-retry storm structurally impossible. Since 04:19Z: 9 ok → 9 artifacts; every transient fail succeeded on retry.
- **New burn risk found:** empty queue → exactly ONE Steward reflection per tick (runner.sh:132) = up to ~96 zero-artifact sessions/day, which would eat the entire daily cap doing nothing. MEMORY already flags "queue drains fast (~1h)". Fix = throttle reflections (Job 5 below) + keep the queue fed (Jobs 1–4).

## Q3 — Recurring failure classes

1. **Proxy storm (exit1 ×17)** — FIXED pre-#1 (router service + preflight SKIP + breaker). Zero recurrence since 04:19Z. Closed.
2. **Trust timeouts (×4)** — FIXED 08:00Z: Janitor set `hasTrustDialogAccepted` + runner `cd "$VAULT"`. Proven: the same two jobs that timed out at 07:33Z succeeded at 08:00Z (584s/437s) with no allowlist warning. Closed.
3. **Heavy-job worker timeout (×1, NEW)** — the 2-paper FULL-TEXT VERIFY hit the 900s worker slot under parallel contention, then completed in 813s as the serial builder. Lesson: multi-target fetch jobs don't fit a worker slot. **Rule for job authors: one fetch-heavy target per job** (all jobs below obey this). No config change — WORKER_BUDGET=1200 must stay the fallback-loop ceiling, not be inflated for slow jobs.
4. **Substrate violation (×1)** — guard worked, but it snapshots **only INDEX.md + MEMORY.md** (runner.sh:139,161). LOG.md and queue.md are protected by prompt-rule alone, and one worker already broke the rule. Extend the guard (Job 4).

## Config verdict — MAX_SESSIONS_PER_DAY=90: KEEP (no edit)

`ran_today` counts every non-SKIP/QUARANTINED log line, so at WORKERS_PER_TICK=3 the cap ≈ 30 waves ≈ 7.5h of fed-queue work/day. It is **not binding** (queue is supply-limited, not cap-limited), and raising it would only enlarge the empty-queue reflection burn from Q2. Revisit only if the queue stays fed for days AND the cap starts skipping waves.

## Tuned jobs — for the serial builder/Curator to append to `_harness/queue.md`

> Workers cannot edit the queue (read-only substrate). Copy the block below the `## META-REVIEW #2 tuned jobs` header, in order. One fetch-target per job (per failure class 3).

```markdown
## META-REVIEW #2 tuned jobs (2026-07-21 — Steward)
> Appended per [[meta-review-2-2026-07-21]]. Order = priority: protect the live experiment → next ledger row → data moat → substrate integrity → burn guard.
- [ ] [Quant] SCORE-PROTOCOL DRY-RUN: execute steps 1–2 of [[forecast-pilot-01]]'s scoring protocol NOW against all 21 IDs (`GET https://gamma-api.polymarket.com/markets?id=<ID>`): confirm the endpoint, fields (`closed`/`isResolved`/`outcomePrices`), and slug fallback all work; list any broken/changed IDs. Append results under a "Dry-run 2026-07-21" heading in forecast-pilot-01.md's Deviations section. Do NOT compute scores or touch the frozen table. Validate the instrument before the experiment ends, not after.
- [ ] [Quant] LEDGER ROW-2 PILOT: design the first falsifiable test of [[ledger]] row 2 (tools/skills people pay for) in the exact format of [[forecast-pilot-01]]: kill criterion up top, pre-committed metric, $0, evidence-buying only → wiki/value/tool-pilot-01.md. If no testable hypothesis survives drafting, write the clean negative and say so — that IS the result.
- [ ] [Scout] HYPERLIQUID DATA STUDY: read ~/Projects/trading-agents/repos/Hyperliquid-Data-Layer-API (cloned 2026-07-21, upstream pushed 2026-07-20 — see [[Moon Dev — Current Work (2026)]]): what data is actually free, what's buildable on this CPU-only box, verdict on relevance to [[ledger]] rows 1/3 → projects/trading-agents/hyperliquid-data-study.md. ONE repo, ONE note — do not clone or study anything else.
- [ ] [Janitor] EXTEND SUBSTRATE GUARD: in _harness/runner.sh, add LOG.md and _harness/queue.md to the snapshot (line ~139) and detect-and-revert (line ~161) loops, so a worker corrupting either is reverted like INDEX.md was at 2026-07-21T07:33Z. Caveat: the runner itself appends to LOG.md and flips queue.md AFTER workers finish — snapshot must stay pre-wave and revert must stay post-worker/pre-builder, or the runner's own writes get reverted. Verify with a stub worker that touches both files.
- [ ] [Janitor] THROTTLE EMPTY-QUEUE REFLECTION: in _harness/runner.sh, run the empty-queue Steward reflection (line ~132) only if >6h since the last one (timestamp in _harness/state/last-reflect); otherwise log a SKIP(EMPTY_QUEUE) line (already excluded from the daily cap) and exit. Evidence: MEMORY "queue drains fast (~1h)" → up to ~96 zero-artifact reflections/day can eat the 90-session cap. Verify: two consecutive empty ticks → one reflection + one SKIP.
```

## Operational flags (for Curator/human)

1. **Recurring jobs get checked off:** the runner marks any `ok` job `[x]`, including the two recurring Self-evaluation lines (META-REVIEW, COUNCIL-AUDIT). After this wave, confirm both are still unchecked; re-add them if checked, or the self-evaluation loop silently dies.
2. **INDEX is stale:** [[beyond-agent-architecture]] and [[tradelens-pay-for-intelligence]] are listed as "provisional ★★" in INDEX but were upgraded ★★★ in-place at 08:13Z. Curator to sync.
3. **Scheduled debt:** the forecast SCORE job must enter the queue **on/after 2026-09-01** (batch resolves 08-04→09-01). The META-REVIEW nearest that date should surface it; until then it lives only in [[forecast-pilot-01]] §Scoring protocol.
4. **Council** remains COUNCIL_ENABLED=0 — the queued COUNCIL-AUDIT job will return the expected "no data" clean negative until it's flipped. No action.

## Verdict

Engine is healthy and self-correcting: every failure class found since #1 was infra/job-size, each fixed within one review cycle, and 9/9 ok sessions compounded into artifacts. Cadence 15-min and cap 90/day ratified unchanged; the two levers that matter now are queue supply (Jobs 1–3) and the two small runner guards (Jobs 4–5). Next review should measure: did Jobs 4–5 land, did any 429s appear at WORKERS_PER_TICK=3, and is row-2 pilot a test or a clean negative.
