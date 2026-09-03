---
tags: [session, critic, skill-validation, cron-agent-swarm]
date: 2026-07-23
role: Critic
status: done — verdict PASS after fixes
---

# Critic — Clean-room install test: [[cron-agent-swarm]] (row-2 publish gate)

**Verdict: PASS (after 4 code/doc bug fixes + 7 doc-gap fixes, all re-verified).** The skill
now survives a from-zero install by someone with no Forge context: every one of the 9
documented LOG verdicts was exercised end-to-end in a fresh `mktemp -d` workspace, and
every LOG line matches the documented pipe format.

## Method
Fresh scratch dir (`mktemp -d`, outside the vault). Followed ONLY `README.md` quickstart →
stub-CLI ticks. Then amended SKILL.md/README/templates in place and re-ran the ENTIRE flow
from a second fresh dir against the fixed templates, with PASS/FAIL assertions.

## Battery (all PASS on the fixed templates, ~26 waves)
3-worker wave · builder wave (`[builder]` line) · queue drain · empty-queue reflection ·
`SKIP(EMPTY_QUEUE)` throttle · proposals-bridge round-trip (`BRIDGE` → `[>]` → ran `ok`) ·
`SUBSTRATE_VIOLATION` detect-and-revert (rogue stub edited INDEX.md; byte-reverted) ·
model cascade (`modelA`→`modelB ok`) · `ROUTING_FAIL` · `TIMEOUT(2s)` · `QUARANTINED`
(poison job → `[!]` after 3 real fails) · `SKIP(PROXY_DOWN)` (dead preflight port) ·
cron-style `/bin/sh -c` invocation · edited-`config.env` path (no env overrides) ·
pipe-injection sanitized. Final sweep: `! grep -qvE '^- \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}Z \| ' LOG.md` → clean.

## Bugs found by execution (fixed in templates)
1. **LOG format ≠ docs** — runner wrote `- 2026-07-23 2026-07-23T01:17:23Z | …` (doubled
   date); SKILL.md documents `- YYYY-MM-DD HH:MM:SSZ | …` as "the API everything parses".
   Fix: timestamp assembled once in `log_line` (runner.sh); all 7 call sites simplified.
2. **`ROUTING_FAIL` field corruption** — `used_model="(none routed)"` (space) mis-split by
   runner's `read verdict model dur` → line read `| routed) 0s | ROUTING_FAIL | (none |`.
   Fix: `(none-routed)` in worker.sh.
3. **Cron chicken-and-egg** — crontab redirects to `_harness/state/cron.log`; `state/`
   only created at first manual run → fresh clone + crontab died exit 2 every tick,
   silently (demonstrated). Fix: `mkdir -p _harness/state` in Install.
4. **Pipe injection** — arbitrary agent output with `|` shifted LOG fields. Fix: `tr '|' '/'`
   on summaries (both worker + builder collect).

## Doc/UX gaps found by reading (fixed in README/queue.md/config.env)
`touch INDEX.md/MEMORY.md` vs bootstrap "Create …" jobs vs "don't overwrite notes" rule
(touch only LOG.md; jobs now say "Create (or fill in…)") · unguarded `cp CONSTITUTION.md
CLAUDE.md` clobbers existing constitutions (`[ -f ] ||` guard) · no gitignore guidance
(snippet for `_harness/state/` + `secrets.env`) · Claude-only `is_routing_failure` grep +
`CLAUDE.md` orient undocumented for opencode users (README + config.env note) · no
`secrets.env` var examples (added) · literal `$(date -u +%F)` in META-REVIEW job text
(→ `<today, YYYY-MM-DD>`) · EDIT-ME example showed bare assignments, which would break the
`${VAR:-}` env-override the dry-run relies on (example now shows the real form) · queue.md
header now warns: no `|` in job text, no spaces in target file names.

## Accepted / not fixed
- Builder wave can re-run a job a worker already failed the same wave (harmless; hastens
  quarantine). Documented in README §Clean-room findings.
- First-wave workers are prompted to read INDEX.md/MEMORY.md that don't exist yet on a
  fresh install (one graceful failed read; bootstrap jobs create them that wave).
  Design-verified: a worker-created substrate file survives the revert (no pre-wave
  snapshot ⇒ no revert), and target de-dup prevents same-file collisions.
- Real-CLI tick not run (cost; the job specifies a FAKE tick). The "then run once with the
  real AGENT_BIN" README step covers this for installers.

## Evidence
Scratch workspaces: `/tmp/cas-cleanroom.7H38Et` (discovery, old templates) and
`/tmp/cas-rerun.QE5nOY` (verification, fixed templates) — ephemeral, deleted after test.
`bash -n` clean on edited runner.sh + worker.sh. Findings list appended to the skill
README (§Clean-room findings); evidence bullet appended to SKILL.md §Evidence.

**Publish readiness (row-2 artifact):** the skill no longer assumes Forge context; a
stranger can install from the README alone and get a verified tick. Z2 promotion remains
human-approved per constitution.
