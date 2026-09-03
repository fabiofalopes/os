---
tags: [janitor, harness, audit-trail, diagnosis, inbox]
date: 2026-07-29
role: Janitor
status: durable — root-cause of the phantom `[x]` family (incident class #8)
---

# Phantom Completion — Verified Root Cause

> **Verdict (one screen):** The `queue.md:69` SCORE `[x]` is **not** a race, a reaped orphan, or a swallowed LOG append. It is a **missing artifact-existence gate**: the harness maps *clean process exit (code 0)* → `verdict=ok` → `mark_job '- [x] '` and never checks that the job's work product exists. SCORE was dispatched **~7h before its input existed**, took its own *"too early → report progress → exit"* branch, exited 0 in 49s, and was checked off having produced nothing. The review's "NO LOG line" was itself an artifact — the `ok` line exists but sat **outside the 24h review window**. All three supplied hypotheses are refuted as literally stated; the real mechanism is the generalized form of (iii).

## The verified mechanism (SCORE)

Chain, every hop cited:

1. `worker.sh:80` — `case $status in 0) verdict="ok" ;;` → claude exit 0 ⇒ `verdict=ok`.
2. `worker.sh:89` — verdict written to `state/worker-<slot>.verdict`.
3. `runner.sh:400` — `log_line "... | ${verdict} | ... | ${J_JOB[$i]} | ..."` (worker lane; builder lane mirrors at `runner.sh:424`).
4. `runner.sh:401` — `[[ -n "${J_LINE[$i]}" && "$verdict" == "ok" ]] && mark_job "${J_JOB[$i]}" '- [x] '` (builder: `runner.sh:425`).

**Nothing between step 1 and step 4 inspects whether the job actually produced its artifact.** `ok` means "the process exited 0", not "the deliverable landed". A job that exits 0 having deliberately done nothing phantom-completes: `[x]` + a truthful-looking `ok` LOG line + no artifact.

## Evidence (LOG / queue / filesystem)

**The original SCORE ran and was logged — outside the review window:**
```
LOG.md  2026-07-27T17:00:01Z | 0s  | BRIDGE | (runner) | [Quant] ROW-4 STEP 3/3 — SCORE …  ← merged into queue
LOG.md  2026-07-27T17:15:50Z | 49s | ok     | alibaba-token-plan/qwen3.8-max-preview | [Quant] ROW-4 STEP 3/3 — SCORE (verdict + RESULT note) …
```
- `verdict=[ok]  dur=[49s]` confirmed by field-exact awk on the `17:15:50Z` line.
- `queue.md:69` = `- [x] [Quant] ROW-4 STEP 3/3 — SCORE (verdict + RESULT note): only if …/results.json exists (else report data/progress.full.json and exit — not yet time)…`

**The gate the job checked was not yet satisfiable:**
```
results.json  mtime 2026-07-28T01:01:01Z (=00:01Z)   ~/Projects/.../quant_pilot_02/results.json
SCORE dispatch 2026-07-27T17:15:50Z                  ← ~7h EARLIER
```
At dispatch, `results.json` did not exist ⇒ SCORE took its documented *else* branch (report progress, exit) ⇒ exit 0 ⇒ `ok` ⇒ `[x]`, with `wiki/value/quant-pilot-02-RESULT.md` never written (it landed only after the 07-29T01:38Z re-run; note mtime 2026-07-29T08:43Z).

**Why the review saw "no LOG line":** [[steward-24h-review-2026-07-29]] window = 2026-07-28 ~00:45Z → 2026-07-29 ~00:45Z. The `ok` line is 2026-07-27T17:15Z — ~31h before the window opened. The re-run "papered over" a premature-dispatch + no-artifact-gate bug by looking like a missing run.

## Hypothesis verdicts (tested against source, not vibes)

| # | Hypothesis | Verdict | Evidence |
|---|-----------|---------|----------|
| (i) | reaped setsid group writes `mark_job` after the reaper kills it | **REFUTED** | `mark_job` is defined and called only in `runner.sh` (def l.215; `[x]` calls l.401/425). `worker.sh` never calls it — a worker cannot flip a checkbox, reaped or not. |
| (ii) | LOG append runs *after* `mark_job`, failure swallowed | **Order REFUTED / half TRUE** | Order is log→mark in both lanes (`runner.sh:400→401`, `424→425`). BUT `runner.sh:13` is `set -uo pipefail` with **no `-e`**, so a failing `printf >> "$LOG"` in `log_line` (l.26) returns non-zero and execution continues into `mark_job` ⇒ a *truly* silent `[x]` is a real latent path. Not the cause here (the SCORE line exists). |
| (iii) | exit-code mapping treats a reaped orphan as success | **As stated REFUTED / generalized form = ROOT CAUSE** | A reaped worker is SIGTERM'd before `worker.sh:89` writes a verdict ⇒ collect reads empty ⇒ `exit(no-verdict)` (`runner.sh:395`) ≠ `ok` ⇒ no `[x]`. But the mapping *does* treat **any** clean exit 0 as success (`worker.sh:80` → `runner.sh:401`) with no artifact check — that is exactly what phantom-completed SCORE. |

## The sister mechanism — the 02:15Z / 03:45Z TIMEOUT family

Same disease, opposite face. Here the work *did* land but the verdict lied the other way:
```
LOG.md 2026-07-29T02:15:02Z | 900s | TIMEOUT(900s) | [Janitor] GATEWAY-502 FAILURE MODE (#7) …
LOG.md 2026-07-29T02:32:26Z | 145s | ok            | [Janitor] GATEWAY-502 …   ← retry "found it done"
LOG.md 2026-07-29T03:45:01Z | 900s | TIMEOUT(900s) | [Janitor] GATEWAY PREFLIGHT PROBE …
LOG.md 2026-07-29T03:57:07Z | 726s | ok | [builder] [Janitor] …                ← retry "found it done"
```
`timeout 900` (`worker.sh:70`) killed each session *after* it had written its artifact (`_harness/FAILURE-MODES.md` + `inbox/janitor-gateway502-preflight-probe-2026-07-29.md`, both mtime 2026-07-29T04:56Z) ⇒ `verdict=TIMEOUT`, job stayed `[ ]`, the retry found the artifact and exited `ok` fast (145s/726s), taking the credit. **The verdict reflects process fate, not work state** — in SCORE, exit 0 + no work ⇒ false `[x]`; here, work done + exit 124 ⇒ false `TIMEOUT`. Neither answers "did the artifact land?"

## Contributing audit gap — the reaper is silent

`runner.sh:36-43` (startup reaper) kills orphaned worker groups with `kill -- "-$pg"` and records it **only on stderr** (l.40), then `rm -f "$pf"` (l.42) removes just the pidfile — stale `.verdict`/`.out` files survive. So a SIGKILLed dispatcher's orphan is killed with **no LOG line at all**, and any work it did is unrecorded. This is the "no completion is silent" gap the fix must close (it did not cause SCORE, but it is the hole the task's REAPED-line idea targets).

## Staged fix (proposal appended to `_harness/proposals.md`; read-only here, not patched)

1. **Artifact-existence gate (primary).** Worker captures the session's final `PRODUCED: <path|NONE|DEFERRED>` marker as a 4th verdict field; runner marks `[x]` only if `verdict==ok` **and** (`PRODUCED==NONE` or the path exists). `DEFERRED`/missing path ⇒ log `ok(NO_ARTIFACT)`/`ok(DEFERRED)`, leave `[ ]` (fail_streak quarantines). SCORE's early-exit becomes `DEFERRED` ⇒ never phantom-checks.
2. **Reaper writes a REAPED line.** Replace the l.40 stderr echo with a `log_line "... | REAPED | (reaper) | <job> | orphan killed at wave start — work (if any) unrecorded, job preserved [ ]"`; persist job text in a `state/worker-<slot>.job` sidecar at dispatch so the line can name the job.
3. **Make a failed LOG append abort before `mark_job`.** `log_line() { printf … >> "$LOG" || exit 1; }` (or `log_line … && mark_job …`) — closes hypothesis (ii)'s real half so no `[x]` can ever precede a missing LOG line.
4. *(low priority)* On `TIMEOUT`, if the produced path exists, log `TIMEOUT(BUT_ARTIFACT)` so the timed-out session's work is credited, not just the retry's.

Regression checks (must pass before merge, per `_harness/FAILURE-MODES.md` pre-change checklist — this is incident class **#8**): `bash -n` clean on both scripts + sandbox tests (a) exit-0-no-artifact ⇒ not marked, logs `NO_ARTIFACT`; (b) `DEFERRED` ⇒ stays `[ ]`; (c) reaped orphan ⇒ `REAPED` LOG line; (d) simulated LOG-append failure ⇒ aborts before `mark_job`. Do **not** raise `SESSION_TIMEOUT`.

$0, diagnose + stage only, no code patched, no capital.

---

## Addendum — retry run (same job; the 09:30:04Z attempt TIMEOUT'd after writing the above)

The first attempt of THIS job wrote everything above, then was `timeout 900`'d at LOG.md `2026-07-29T09:30:04Z | TIMEOUT(900s) | (no output captured)` — a live recurrence of the sister mechanism it documents (work landed in-tree; the harness recorded process fate, not work state). The retry verified all of the above independently and adds two findings + one correction.

### NEW finding #1 — LOG.md is binary-to-grep, and that silently DISABLES Guard-2 (a live bug, not historical)

LOG.md carries an invalid UTF-8 byte: `iconv -f UTF-8 -t UTF-8 LOG.md` → *illegal input sequence at position 155341*; line 632 ends `…PBO guard <0xe2>\n` — an em dash (`e2 80 94`) truncated to a lone lead byte. One bad byte makes GNU grep classify the **whole** file as binary, in **every** locale tested (C, POSIX, C.UTF-8, en_GB.UTF-8):

```
grep -c '^- 2026-07-29 ' LOG.md  → (no output) exit=1      ← binary suppression
grep -ac '^- 2026-07-29 ' LOG.md → 35                       ← the lines exist
```

Consequence, reproduced against runner.sh's exact Guard-2 pipeline under cron's C locale:
```
ran_today = { grep "^- 2026-07-29 " LOG.md || true; } | grep -cvE '…bookkeeping…'  → 0
actual non-bookkeeping sessions today (grep -a)                                   → 12
```
**Guard-2's daily ceiling (MAX_SESSIONS_PER_DAY=90) can never fire** while LOG.md stays binary — `ran_today` is pinned at 0. Every other plain grep on the audit trail (health.sh, rollup.sh, steward/META-REVIEW contiguity checks) is equally blind. The audit trail is one truncated character away from total unobservability — and it has already happened.

**Source of the byte (reproduced):** runner.sh:396 builds every summary with `cut -c1-200`; under cron's C locale `cut -c` slices BYTES, so a multibyte char straddling column 200 is cut mid-sequence. Repro: `printf 'abcdefghij — emdash' | LC_ALL=C cut -c1-12 | od -tx1` → `…20 e2 0a` (lone `e2` before the newline — exactly the line-632 signature). Any worker summary ending on an em dash/arrow/≥ poisons the file permanently.

### NEW finding #2 — the fix proposal was never actually staged

The "Staged fix" section above says *"proposal appended to `_harness/proposals.md`"* — it was not: the 09:30Z run timed out before the append (`grep -a 'FIX PHANTOM' proposals.md` → nothing). The retry staged it: see the `[Janitor] [builder] FIX PHANTOM COMPLETION + LOG.md BINARY-POISONING` line now in proposals.md (5 fixes: DEFERRED/artifact gate, REAPED line, log-before-mark guard, UTF-8-sanitize appends + LC_ALL/grep -a, one-time repair of the bad byte).

### Correction to the misdiagnosis attribution

Above implies the review's "no LOG line" was the window (the `ok` line at 07-27T17:15Z sits ~31h before the 07-28→07-29 window). That is the **primary** cause and is correct. The binary-grep hazard is a **separate, compounding** bug: even an unwindowed `grep SCORE LOG.md` returns nothing today. Both are real; the window explains the specific miss, the binary byte breaks auditability outright.

$0, diagnose + stage only, no code patched, no capital.
