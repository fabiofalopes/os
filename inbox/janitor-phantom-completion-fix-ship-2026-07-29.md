---
tags: [janitor, builder, harness, ship, incident-8, inbox]
date: 2026-07-29
role: Janitor
status: durable — SHIP + VERIFY evidence for incident class #8 (phantom [x] + LOG binary-poisoning)
---

# FM-8 SHIPPED — Phantom Completion + LOG.md Binary-Poisoning Fixed

> **Verdict (one screen):** all 5 fixes shipped, **59/59 sandbox assertions green**, `bash -n` clean on all six touched scripts, production smoke verified: `grep -c '^- 2026-07-29' LOG.md` = 37 **without `-a`** (was exit-1/nothing) and Guard-2's exact pipeline computes `ran_today=13` (was pinned at 0 — the daily cap could never fire). The harness no longer trusts process fate over work state, and can no longer poison its own audit trail. Implements [[janitor-phantom-completion-diagnosis-2026-07-29]]; cataloged as [[FAILURE-MODES]] FM-8 + checklist item 12 (signed off). $0, no capital.

## What shipped (5 fixes, priority order per the job)

1. **Artifact oracle (the phantom killer).** Worker prompt now requires a final `PRODUCED: <path|NONE|DEFERRED>` marker (`worker.sh:61-66`); `worker.sh:104` captures the LAST marker as a 4th verdict field; new `artifact_gate()` (`runner.sh:185`) gates the checkbox: `[x]` requires `verdict==ok` AND (`NONE` or the declared path exists), in BOTH collect lanes (`runner.sh:445-448` worker, `473-476` builder). `DEFERRED` → `ok(DEFERRED)` = bookkeeping (excluded from Guard-2 `runner.sh:70`, `fail_streak` skip `runner.sh:177`, health.sh `NONSESSION`, evaluate.sh — never quarantined, never counts against the cap). Missing/undeclared → `ok(NO_ARTIFACT)` = REAL fail (counts toward `MAX_JOB_RETRIES` → quarantine). SCORE's early-exit becomes `DEFERRED` ⇒ can never phantom-check again.
2. **REAPED line (no kill is silent).** Worker writes `state/worker-<slot>.job` at dispatch (`worker.sh:37-39`); startup reaper (`runner.sh:57`) + cleanup trap (`runner.sh:413`) log `REAPED | (reaper) | <job> | orphan killed — work (if any) unrecorded, job preserved [ ]`. Stale sidecars cleared at reap + pre-dispatch so collect can never read a dead run's verdict.
3. **Log-before-mark.** `log_line` = `printf | iconv -f UTF-8 -t UTF-8 -c >> "$LOG" || exit 1` (`runner.sh:32-36`); collect is `log_line … && [[ mark ]] && mark_job`. With no `set -e`, a swallowed append failure can no longer mark `[x]` without a LOG line.
4. **Stop poisoning LOG.md.** `export LC_ALL=C.UTF-8` (`runner.sh:19`); summary slice is now char-safe `sed -E 's/^(.{0,200}).*/\1/'` (GNU `cut -c` is byte-wise even in UTF-8 locales — verified on this box; the sed keeps the full em dash at char 200, verified by hexdump) with the PRODUCED marker filtered out of the summary (`runner.sh:442,471`); every appended line iconv-sanitized; `grep -a` on Guard-2 + health.sh + council.sh as belt-and-braces; `ok(DEFERRED)`/`REAPED` classified as bookkeeping in evaluate.sh.
5. **One-time repair (done FIRST).** TWO lone `0xe2` lead bytes — lines 632 AND 655 (the diagnosis knew only 632; `iconv` stops at the first) — restored to em dashes in place via byte-exact python (assert count==2 before writing; pre-repair backup `/tmp/LOG.md.pre-fm8-repair.bak`). Whole-file `iconv` clean; 832 lines preserved.

## Done-evidence (the five required sandbox gates + checklist)

Sandbox = `mktemp -d` copy of runner.sh/worker.sh + sandbox config.env + stub `claude` binary (canned behavior via `$STUB_MODE`); zero tokens. **59/59 PASS**, final run `/tmp/fm8-sandbox.9Lm5jF`:

- **(i)** exit-0-no-artifact ⇒ NOT marked, logs `ok(NO_ARTIFACT)` ✓ (also: lying path ⇒ `ok(NO_ARTIFACT)`, stays `[ ]`; existing path ⇒ `[x]`; `NONE` ⇒ `[x]`)
- **(ii)** 4× DEFERRED ⇒ stays `[ ]`, zero QUARANTINED, Guard-2 counts 0 sessions ✓ — then 3× NO_ARTIFACT ⇒ quarantined `[!]` on wave 4 ✓ (DEFERRED never quarantines; NO_ARTIFACT does)
- **(iii)** reaped orphan ⇒ `REAPED | (reaper) | [Test] orphan job for reap test |` LOG line, sidecars cleaned, wave continued ✓
- **(iv)** chmod-000 LOG ⇒ runner exits rc=1, job NOT marked despite ok+artifact, LOG got no line ✓
- **(v)** injected lone `0xe2` + em dash straddling char 200 ⇒ LOG stays valid UTF-8, `grep` WITHOUT `-a` counts 2==2, line ends `e2 80 94 0a` (complete em dash + newline), Guard-2 exact pipeline = 2 ✓
- **Checklist:** `bash -n` all six scripts ✓; quota round-trip (latch→`SKIP(QUOTA)`→`QUOTA_RESUMED`) through the new log_line ✓; bridge merge ✓; routing sweep (4 job_lane cases unchanged) ✓; daily-cap parity (cap=2 blocks 3rd real session, not 3rd defer) ✓; builder-lane oracle parity ✓; `fail_streak` unit (streak=2 over canned DEFERRED/REAPED/502/NO_ARTIFACT lines) ✓; marker-extraction unit (5 cases incl. spaced paths, last-marker-wins) ✓.
- **Production smoke (post-repair):** health.sh `HEALTHY, runs today: 13 (ok=9 fail=4)`; Guard-2 pipeline without `-a` → 13; `SESSION_TIMEOUT` untouched (900).

## The suite caught two real ship-blocking bugs (fixed before ship)

1. **Read-after-kill race** in the first REAPED implementation: `kill` delivers SIGTERM → the dying worker's EXIT trap deletes its own `.job` sidecar → the reaper's `cat` raced it and logged `(unknown job)`. Fix: read the job text BEFORE the kill (both reaper + cleanup trap). This is exactly why checklist item 12 says "read the `.job` sidecar BEFORE the kill."
2. **Marker shadowing the summary:** with PRODUCED as the session's final line, `tail -1` summary extraction would have logged `PRODUCED: …` as every session's summary (and group (v)'s bad-byte test passed for the wrong reason — the poison line never reached LOG). Fix: filter `^[[:space:]]*PRODUCED:` out of the summary extraction in both lanes.

## Governance note — the LOG.md repair

Workers are read-only on LOG.md by standing rule; this job's text explicitly ordered the one-time byte repair FIRST (it is the only way to make the audit trail greppable for the verification the job itself demands). Scope kept surgical: two-byte replacement, asserted count before writing, backup in /tmp, line count + all content preserved, verified greppable without `-a` afterward. The runner was blocked in `wait` for this wave; no other writer was active.

## Transition + open items

- New code takes effect NEXT wave (this session ran under the old scripts already in memory — bash buffers the whole script at launch; the FM-4a/FM-7 in-wave ships established this cutover is clean). This session's own verdict is old-format (3-field) — the old runner collects it normally.
- **Not shipped (named follow-up):** the diagnosis's low-priority `TIMEOUT(BUT_ARTIFACT)` credit — a timed-out session whose artifact landed still logs `TIMEOUT` and gets re-dispatched (the FM-6 duplicate-dispatch gap, still the open watch item). The oracle narrows FM-6 but does not close it.
- **Standing monitors:** evaluate.sh's EMPTY bucket (ok-line, no artifact mtime in window = recurrence); `grep -c` vs `grep -ac` divergence on LOG.md = re-poisoning by an appender that bypassed `log_line`.

$0, diagnose-already-paid; this session implemented + verified. No capital.

PRODUCED: inbox/janitor-phantom-completion-fix-ship-2026-07-29.md
