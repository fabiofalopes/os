---
tags: [steward, meta-review, harness]
date: 2026-07-21
status: durable — first META-REVIEW
related:
  - "[[schedule]]"
  - "[[queue]]"
  - "[[The Forge Harness — Runbook]]"
  - "[[ledger]]"
---

# META-REVIEW #1 — 2026-07-21

> First meta-review; covers the entire LOG.md since engine stand-up (2026-07-20 20:36Z → 2026-07-21 06:06Z). Evidence-counted answers to the three standing questions, then the tuning actions taken.

## Scope & method
Read: LOG.md (49 lines), `_harness/{config.env,queue.md,schedule.md,runner.sh,health.sh,state/}`, crontab, [[ledger]], [[learning-path]], skill-backlog. All numbers grep-counted from LOG.md unless noted.

## Q1 — Is the 20-min interval too fast/slow?

**It isn't 20 min: crontab runs `*/15` (15 min); schedule.md was stale. Ratified at 15 min, no crontab change.**

Evidence:
- ok-session durations (n=15): median 316s (~5.3 min), mean 300s, max 632s (10.5 min). All fit inside a 15-min tick → `flock` rarely skips; handoffs clean.
- The one failure cluster (17 × ConnectionRefused, 00:11→04:19Z) was a dead/flapping proxy + no breaker — a *failure-handling* problem, not a cadence problem. Slower ticks would have stretched the same storm over ~5.5h instead of 4h. Fixed 04:30/05:38Z (systemd router `Restart=always`, `MAX_JOB_RETRIES` breaker, proxy preflight SKIP).
- Tokens are effectively free during the Alibaba preview window (config.env) → no cost argument for slowing down.
- Empty-queue behavior: runner auto-fires a Steward review every tick when the queue is empty — at 15 min that's up to 96 reviews/day if nobody feeds the queue (risk R2).

Verdict: 15 min is right while sessions average ~5 min and tokens are free. Revisit if (a) median session >10 min (ticks start skipping) or (b) tokens become paid. schedule.md synced to reality.

## Q2 — Durable artifacts or token burn?

**Every session that ran produced a durable artifact. All burn was infra, now fixed.**

- 15/15 ok sessions each name an artifact: INDEX.md, MEMORY.md, 7 scaffold dirs, 4 ai-ml notes (SEAL/Voyager/Reflexion/ADAS), 2 finance notes (de Prado/Kelly), the-forge-synthesis, HARVEST-STATUS, hf-skills-eval, ledger, legitimacy-ledger dates, the-alpha-illusion, reddit-crowd-wisdom, ktd-fin (+2 clips), wayback-recovery, Critic pass. INDEX: 29 → ~45 notes in ~34h. Compounding is real.
- Burn: 19 real fails today; 17 were one poisoned job × dead proxy (~180s wall each, mostly connect-wait → low token cost per fail, but 4h of dead engine = opportunity cost). Breaker + preflight now convert that scenario into 0-token SKIP lines + quarantine after 3 real fails.
- Zero content-level failures: no job has failed because it was badly scoped or impossible.

## Q3 — Recurring failure job types?

All failures are infrastructure; **[Scout] is the canary** (most network-heavy role: 19 of 19 fails).

| Failure class | Count | Root cause | Status |
|---|---|---|---|
| exit127 `claude` not on cron PATH | 3 | cron PATH | fixed (absolute CLAUDE_BIN) |
| exit1 not logged in | 1 | auth | fixed |
| exit1 ConnectionRefused (proxy flap) | 17 | router was a flapping session-child | fixed (systemd router + breaker + preflight) |
| TIMEOUT 900s (REDDIT MINE) | 1 | workspace untrusted → 25 permissions.allow entries ignored → permission-prompt hang | **open** → queued job #2 |
| exit1 connection closed mid-response (ARXIV TRACK) | 1 | transient API | self-healed on retry |

Audit gap found: health.sh counts `- <date> manual |` ops notes as failed runs (reports 21 fails today vs 19 real) → queued job #2b.

## Actions taken this session
1. **queue.md** — appended 5 tuned jobs (below) + a recurring META-REVIEW; archived the 15 done jobs.
2. **config.env** — `MAX_SESSIONS_PER_DAY=90`: **no change warranted** (real runs today 24 ≪ 90; breaker bounds storms; cap stays as backstop). Removed a duplicated `MAX_JOB_RETRIES` line.
3. **schedule.md** — synced to reality (15-min cadence, cap 90, MODEL_CHAIN free-qwen-preview) + change-log entry ratifying the above.
4. **MEMORY.md** — Steward refresh (state, priorities, risks), kept ≤2000 chars.

## Jobs appended (order = priority)
1. **[Quant] LEDGER ROW-1 PILOT** — first falsifiable forecasting test (Metaculus odds + Brier baseline + pre-committed kill criterion). Moves the Life Arc from *map* → *prove-one-thing*; the mission's first $0 evidence buy.
2. **[Janitor] TRUST + HEALTH FIX** — accept workspace trust (root cause of the 900s timeout; this very session runs under the same warning) + health.sh manual-line count bug. Protects every tick after it.
3. **[Scout] FULL-TEXT VERIFY** — the two provisional ★★ clips (arXiv:2606.08285, 2607.10286): test-don't-wonder debt; upgrade or downgrade in place.
4. **[Smith] INSTALL THE CHEAP THREE** — per [[hf-skills-eval]] verdict; smoke-tested on this CPU-only box → recommendation becomes verified capability.
5. **[Critic] PHASE-0 GATE** — adversarial cross-check of the skepticism triad into ONE concrete Phase 0→1 gate criterion in [[learning-path]].

## Risks for the human
- **R1 (open):** workspace untrusted in cron sessions — permission allowlist ignored; any job hitting an unpermitted tool hangs to 900s. Job #2 fixes it mechanically (`hasTrustDialogAccepted`), or accept the dialog interactively once.
- **R2 (design):** queue drains in ~1h (5 jobs); then the runner auto-fires empty-queue Steward reviews every 15 min. Free tokens make it tolerable, but it's review-without-work — feed the queue (or let the next META-REVIEW top it up).
- **R3 (cosmetic):** crontab comment still says "every 20 min"; real entry is `*/15`. Left alone (crontab outside this job's edit authority).
- **R4 (process):** the session boilerplate rule "do NOT touch _harness/queue.md" contradicts this job's explicit "append 3-5 tuned jobs to this queue" (and schedule.md's META-REVIEW mandate). Followed the job; reconcile the boilerplate for Steward sessions.

## Next META-REVIEW should check
- Did job #2 kill the TIMEOUT class? · Did the forecasting pilot record real odds? · Any QUARANTINED lines (breaker fired)? · How many empty-queue auto-reviews ran since today?
