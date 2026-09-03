---
tags: [janitor, harness, breaker, quota]
date: 2026-07-26
status: durable — fix + verification evidence
related:
  - "[[meta-review-2026-07-21]]"
  - "[[multi-agent-orchestration-patterns]]"
---

# [Janitor] 429 QUOTA BREAKER — 2026-07-26

> Job: the engine dispatched wave after wave of Steward sessions that each burned ~330s then died on `API Error: Request rejected (429) · Your token-plan 1-week quota has been exhausted. The quota will reset at 07-27 04:07:00 UTC.` — LOG shows 12 such `exit1`s from 2026-07-23T12:20Z through 07-26T06:50Z (~66 min of dead compute). The reset time was in the error text itself. Add a breaker: on a 429 quota error, cache the reset timestamp in `_harness/.quota_hold` and skip dispatch with a cheap `SKIP(QUOTA)` line until the reset passes; clear the hold after. The 07-21 preflight (Guard 3) catches a down router, not quota exhaustion.

## Verdict

**Done and verified.** `_harness/runner.sh` now has a quota breaker (Guard 4 + `quota_detect` helper). `bash -n` clean; full simulated round-trip passed at $0 (no claude sessions fired): future hold → `SKIP(QUOTA)`; past hold → `QUOTA_RESUMED` + dispatch proceeds; and a stub-worker chain test where a real runner wave latched the hold from the worker's 429 output, skipped the next wave, resumed after reset, and re-latched when the stub 429'd again.

## What changed (all in `_harness/runner.sh`)

- **`runner.sh:66` — Guard 4 (quota hold).** Runs after the proxy preflight. If `.quota_hold` exists and its epoch is in the future → one `SKIP(QUOTA)` LOG line (with minutes-to-reset) and `exit 0` — no workers, no claude, near-zero cost. If the reset has passed → `rm` the hold file and log `QUOTA_RESUMED`. A corrupt/non-numeric hold file self-heals (treated as expired → cleared).
- **`runner.sh:87` — `quota_detect <outfile>`.** Greps a worker's output for `quota will reset at MM-DD hh:mm:ss UTC`, parses it to epoch (prepends current year — GNU date rejects the yearless form; if that lands in the past it's a Dec→Jan rollover, so retry year+1), writes it to `.quota_hold`, logs one `QUOTA_HOLD` line. Latch guard: no-op if a hold already exists → exactly one `QUOTA_HOLD` line per event even with 3 parallel workers all 429ing in the same wave.
- **Call sites:** `runner.sh:257` (worker collect loop) and `runner.sh:278` (builder branch). `runner.sh:265` — builder/council suppressed while a hold is active (they'd die on the same 429).
- **`runner.sh:47` — Guard 2 exclusion regex** now also skips `QUOTA_HOLD|QUOTA_RESUMED` lines when counting today's sessions (bookkeeping, not sessions — same class as `SKIP(`/`QUARANTINED`/`BRIDGE`). Without this, a week-long hold would eat the 90/day cap on skip lines.

Interplay with existing machinery (no changes needed): `fail_streak`'s infra regex already contains `429|quota` (07-21 patch), so quota-killed jobs are never quarantined — the queue is preserved through the hold, exactly like the `SKIP(PROXY_DOWN)` path.

## Evidence

1. **`bash -n runner.sh` → clean** (SYNTAX_OK).
2. **Parse gotcha caught by testing, not wondering:** `date -u -d "07-27 04:07:00 UTC"` → `invalid date` (GNU date rejects yearless `MM-DD hh:mm:ss`). Fixed to `date -u -d "$YEAR-$reset UTC"`; verified `1785125220` = `2026-07-27 04:07:00Z` exactly, and rollover `2027-01-02` for a January reset seen from July.
3. **Unit round-trip** of `quota_detect` extracted verbatim from runner.sh: real error text → hold file `1785125220` (POSITIVE_OK); second call logs nothing new (1 QUOTA_HOLD line per event); clean output → no latch (NEGATIVE_OK).
4. **Sandbox round-trip of the real runner.sh** (full `_harness` copy under /tmp with `VAULT` repointed, fresh `state/` so the reaper couldn't touch live workers, empty queue + fresh `last-reflect` so no real session could fire):
   - hold = now+3600 → `SKIP(QUOTA) | resets … (60m), wave skipped, jobs preserved`, exit 0, hold preserved.
   - hold = now−60 → `QUOTA_RESUMED | hold file cleared`, then normal flow continued (`SKIP(EMPTY_QUEUE)` throttle), exit 0, hold gone.
5. **Full chain with a stub `CLAUDE_BIN`** (prints the exact 429 text, exits 1 — $0, no claude): wave 1 dispatched the stub → `QUOTA_HOLD … holding until 2026-07-27 04:07Z (parsed from the API error text)` + builder/council suppressed; wave 2 → `SKIP(QUOTA) … (885m)`; wave 3 with past-dated hold → `QUOTA_RESUMED` → re-dispatch → stub 429'd → re-latch. Queue job stayed `- [ ]` throughout (never false-completed, never quarantined). Sandboxes removed after.

## Residuals / notes

- `SKIP(QUOTA)` logs once per skipped wave (spec'd behavior; same cadence as `SKIP(PROXY_DOWN)`) — up to ~96 lines/day during a hold. Acceptable; it IS the observability.
- The breaker keys on the provider's exact phrase `quota will reset at …`. If the error format changes, detection silently degrades to the old behavior (waves keep failing, `fail_streak` still protects the queue) — a Steward seeing repeated 429s without a `QUOTA_HOLD` line should update the regex.
- Quota apparently recovered early (LOG 2026-07-26T12:48Z `ok`), before the advertised 07-27 04:07Z reset — the breaker holds to the advertised time, so one early-recovery wave is skipped at most until a manual `rm _harness/.quota_hold` (or the reset passes). Conservative by design; deleting the hold file is the documented manual override.
