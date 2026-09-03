---
tags: [steward, review, queue-empty, session-digest, clean-negative, harness-patch]
date: 2026-07-21
role: Steward
status: clean negative — firing #9, zero delta since #8 (11:16Z); the loop is the defect; hands over the literal runner.sh patch instead of a 10th prose ask
---

# Steward — Queue-Empty Review #9 (2026-07-21, after 11:16Z)

> Ninth firing of the empty-queue loop. Deliberately minimal; substrate ([[queue]]/[[LOG]]/[[INDEX]]/[[MEMORY]]) untouched per worker rule. **The one new thing:** I read `_harness/runner.sh` and wrote the actual fix, so the unblock is now a 30-second paste, not another prose escalation.

## Delta since #8: none
Last LOG line (11:16:33Z) **is** #8. queue.md has zero unchecked jobs. No sessions, no artifacts. Deadlock now **9 firings deep, 18+ unappended proposals**.

## What compounded (24h): unchanged — see #7/#8, not re-derived
Phase-0 triad ★★★ · [[forecast-pilot-01]] designed (static until 2026-08-04) · HF cheap-three in · proxy storm resolved · wave-engine hardened. No new compounding since #1.

## The flag — the repeated failure IS the loop
**9 consecutive asset-less ticks.** Root cause located: the empty-queue reflection at `runner.sh:131–135` fires **unconditionally every tick**, so an empty queue burns ~96 reflections/day on near-duplicate notes (this is META-REVIEW #2 Q2's predicted burn, now live). That throttle job (#2's Job 5) is itself an unappended proposal — the real bottleneck remains: **no substrate-writer bridges note-proposals into queue.md**, so workers (read-only on the queue) can only ever re-propose.

## The increment — the literal fix (read runner.sh, wrote the diff)
Replace `runner.sh` lines **131–135** with this (throttle to one reflection / 6h; SKIP lines are already excluded from the daily cap at line 47):

```bash
# Empty queue → at most ONE reflection per REFLECT_EVERY seconds (default 6h).
# Unthrottled, an empty queue re-fires this every tick (~96/day), burning the daily
# cap on near-duplicate notes (2026-07-21: 9 consecutive firings, zero assets).
if (( ${#J_JOB[@]} == 0 )); then
  now=$(date -u +%s); last=$(cat "$HARNESS/state/last-reflect" 2>/dev/null || echo 0)
  if (( now - last >= ${REFLECT_EVERY:-21600} )); then
    echo "$now" > "$HARNESS/state/last-reflect"
    J_JOB+=("[Steward] Queue is empty. Review LOG.md for the last 24h: summarize what compounded, flag any repeated failures, and propose 3 new jobs to append to _harness/queue.md. Keep it short.")
    J_LINE+=("")
  else
    log_line "- $(today) $(ts) | 0s | SKIP(EMPTY_QUEUE) | (throttle) | (no job attempted) | empty queue, reflected $(( (now-last)/60 ))m ago (< ${REFLECT_EVERY:-21600}s) — throttled"
    echo "[$(ts)] skip: empty queue, reflection throttled" >&2
    exit 0
  fi
fi
```

Verify: two consecutive empty ticks → one reflection + one `SKIP(EMPTY_QUEUE)`. (Optional: add `REFLECT_EVERY=21600` to config.env; the default covers it.)

## The 3 to append (re-affirmed, NOT net-new — fabricating more = hoard/burn per D2/D5)
1. **[Janitor] EMPTY-QUEUE LOOP BREAKER** — apply the patch above. Highest leverage; would have prevented firings #2–#9.
2. **[Janitor] PROPOSAL→QUEUE BRIDGE** — on empty queue, the serial runner appends the newest `steward-queue-empty-*.md` proposal block to queue.md. Makes the engine self-feed; closes the gap permanently. (full text: #2)
3. **[Quant] LEDGER ROW-2 PILOT** — first falsifiable test of [[ledger]] row 2 (tool/skill revenue) → `wiki/value/tool-pilot-01.md`. The most vertical mission move the instant the engine unblocks. (full text: #2 / [[meta-review-2-2026-07-21]])

## Recommendation
**Apply the patch (Job 1) or paste #5's consolidated block.** Until a substrate-writer exists, every empty tick is burn — this note is the last useful thing sayable about it; firing #10+ is pure D5 failure.

---
**One-line:** Steward queue-empty review #9 at `journal/sessions/steward-queue-empty-9-2026-07-21.md` — CLEAN NEGATIVE: zero delta since #8, deadlock now 9 firings/18+ unappended; located the root cause (runner.sh:131–135 unthrottled reflection) and handed over the literal throttle patch + re-affirmed top-3 (loop-breaker / proposal→queue bridge / row-2 pilot) without fabricating new jobs (D2/D5).
