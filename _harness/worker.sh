#!/usr/bin/env bash
# ── The Forge worker ──
# Runs ONE queue job as a bounded headless claude session with model fallback.
# Invoked by runner.sh (the wave dispatcher) as:
#   setsid --wait bash worker.sh <slot> <job-text> [max_turns] [budget]
# setsid makes this worker its own session/process-group leader, so $$ == PGID —
# the dispatcher can reap the whole group (worker + its claude child) via `kill -- -PGID`.
#
# Writes:
#   state/worker-<slot>.out      claude output (last model attempt)
#   state/worker-<slot>.verdict  "<verdict> <model> <dur> <produced>" for the dispatcher;
#                                <produced> is the session's final PRODUCED marker (FM-8
#                                artifact oracle: path|NONE|DEFERRED — the runner marks [x]
#                                only if the path exists, never on exit 0 alone)
#   state/worker-<slot>.pid      own pid (== PGID) while running; removed on exit
#   state/worker-<slot>.job      the job text while running, so the reaper can name the job
#                                it kills (FM-8 — no reap is silent); removed on exit
#
# The WHOLE fallback loop is bounded by <budget> (default WORKER_BUDGET): before each
# model attempt we shrink its per-attempt timeout to the remaining budget, so the loop
# always ends near the deadline even if every model cascades.
set -uo pipefail

slot="${1:?slot required}"; job="${2:?job required}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
export PATH="$(dirname "$CLAUDE_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"
cd "$VAULT" || exit 1

max_turns="${3:-$MAX_TURNS}"
budget="${4:-$WORKER_BUDGET}"

out="$HARNESS/state/worker-$slot.out"
verdict_file="$HARNESS/state/worker-$slot.verdict"
pidfile="$HARNESS/state/worker-$slot.pid"
jobfile="$HARNESS/state/worker-$slot.job"
echo $$ > "$pidfile"                       # $$ == PGID (setsid made us group leader)
printf '%s\n' "$job" > "$jobfile"          # FM-8: the reaper names the job if it must reap this group
trap 'rm -f "$pidfile" "$jobfile"' EXIT

# ── Slot-aware prompt: the builder lane may write the substrate, workers may not ──
# worker.sh sends ONE prompt to every slot, so the prompt itself is the only harness-level
# signal of which lane the session is on. The builder slot is the SERIAL lane and IS allowed
# to write the shared substrate (INDEX.md/MEMORY.md) — runner.sh's snapshot/revert runs BEFORE
# the builder section (runner.sh:618→651→685), so a builder substrate write is never reverted.
# Before this branch the builder received the worker's "substrate is read-only" text and refused
# legitimate INDEX/MEMORY syncs (the 08-01 builder-lane dead letter). Worker-slot prompt text is
# frozen BYTE-EXACT in the else branch (regression-checked in the sandbox; do not reword it).
if [[ "$slot" == "builder" ]]; then
read -r -d '' PROMPT <<EOF
You are the Forge running the BUILDER lane — the SERIAL cron session — inside the Obsidian vault at $VAULT.
You are NOT one of the parallel workers: you run alone on the serial lane, AFTER the parallel workers and their substrate revert have finished.

FIRST, orient yourself: read CLAUDE.md (the constitution), MEMORY.md, and INDEX.md at the vault root.

YOUR JOB THIS SESSION:
$job

RULES:
- You are the BUILDER — the serial lane; substrate writes to INDEX.md/MEMORY.md ARE permitted for you, the snapshot/revert runs BEFORE your section; LOG.md and queue.md remain read-only.
- Stay vertical on the mission (compound knowledge/skills/value toward revenue). No side quests.
- Write your work product as YOUR OWN NEW artifact in the correct location (inbox/, wiki/, projects/, .forge/skills/ per CLAUDE.md). Do not overwrite another note.
- Do NOT run git (no add/commit) — a serial process handles that.
- Test, don't wonder: attach evidence or a verdict to any claim. No evidence = label it aspiration.
- Do NOT edit CLAUDE.md. Do NOT move capital.
- Be concise and bounded. Produce a durable artifact or a clean negative result.

When done, print a ONE-LINE summary of what you produced and where (path). That line is captured as your session record.
THEN print, on its own FINAL line, exactly one of:
  PRODUCED: <path>    — the artifact you wrote, vault-relative (e.g. inbox/my-note-2026-07-29.md); the file MUST exist.
  PRODUCED: NONE      — the job genuinely has no file deliverable.
  PRODUCED: DEFERRED  — you deliberately did no work because a precondition was not met (an input file does not exist yet, a gate date has not passed); the job stays queued for a later wave.
The harness marks the job done ONLY on an existing path (or NONE); a DEFERRED, missing, or undeclared artifact leaves it queued. Never claim a path you did not write.
EOF
else
read -r -d '' PROMPT <<EOF
You are the Forge running an autonomous CRON WORKER inside the Obsidian vault at $VAULT.
You are one of several workers running IN PARALLEL this tick, each on a different job.

FIRST, orient yourself: read CLAUDE.md (the constitution), MEMORY.md, and INDEX.md at the vault root.

YOUR JOB THIS SESSION:
$job

RULES:
- Stay vertical on the mission (compound knowledge/skills/value toward revenue). No side quests.
- Write your work product as YOUR OWN NEW artifact in the correct location (inbox/, wiki/, projects/, .forge/skills/ per CLAUDE.md). Do not overwrite another note.
- SHARED SUBSTRATE IS READ-ONLY for workers: do NOT edit LOG.md, INDEX.md, MEMORY.md, or _harness/queue.md. The runner logs your result and a Curator catalogs new notes later. You may READ all of them.
- Do NOT run git (no add/commit) — a serial process handles that.
- Test, don't wonder: attach evidence or a verdict to any claim. No evidence = label it aspiration.
- Do NOT edit CLAUDE.md. Do NOT move capital.
- Be concise and bounded. Produce a durable artifact or a clean negative result.

When done, print a ONE-LINE summary of what you produced and where (path). That line is captured as your session record.
THEN print, on its own FINAL line, exactly one of:
  PRODUCED: <path>    — the artifact you wrote, vault-relative (e.g. inbox/my-note-2026-07-29.md); the file MUST exist.
  PRODUCED: NONE      — the job genuinely has no file deliverable.
  PRODUCED: DEFERRED  — you deliberately did no work because a precondition was not met (an input file does not exist yet, a gate date has not passed); the job stays queued for a later wave.
The harness marks the job done ONLY on an existing path (or NONE); a DEFERRED, missing, or undeclared artifact leaves it queued. Never claim a path you did not write.
EOF
fi

# ── Model fallback, bounded by the whole-loop budget ──
is_routing_failure() { grep -qiE "issue with the selected model|may not exist or you may not have access" "$out"; }
read -r -a MODELS <<< "${MODEL_CHAIN:-}"
(( ${#MODELS[@]} == 0 )) && MODELS=("")

used_model="(none)"; verdict=""; start=$(date +%s)
deadline=$(( start + budget ))
for m in "${MODELS[@]}"; do
  rem=$(( deadline - $(date +%s) ))
  if (( rem <= 0 )); then verdict="TIMEOUT(${budget}s)"; break; fi
  per=$SESSION_TIMEOUT; [[ "$slot" == "builder" ]] && per=$budget   # builder slot: per-attempt cap = its budget (BUILDER_BUDGET); workers keep the 900s hang guard
  (( rem < per )) && per=$rem
  if [[ -n "$m" ]]; then
    timeout "$per" "$CLAUDE_BIN" -p "$PROMPT" --dangerously-skip-permissions \
      --max-turns "$max_turns" --model "$m" > "$out" 2>&1
  else
    timeout "$per" "$CLAUDE_BIN" -p "$PROMPT" --dangerously-skip-permissions \
      --max-turns "$max_turns" > "$out" 2>&1
  fi
  status=$?
  if [[ $status -ne 124 ]] && is_routing_failure; then continue; fi   # model unavailable → cascade
  used_model="${m:-claude-default}"
  case $status in
    0)   verdict="ok" ;;
    124) verdict="TIMEOUT(${per}s)" ;;
    *)   verdict="exit$status" ;;
  esac
  break
done
dur=$(( $(date +%s) - start ))
[[ -z "$verdict" ]] && { verdict="ROUTING_FAIL"; used_model="(none routed)"; }

# FM-8 artifact oracle: the session's final PRODUCED marker is the 4th verdict field.
# The runner marks [x] only if the declared path exists (or NONE) — a clean exit 0 alone
# never completes a job anymore (the SCORE phantom was exit 0 with no artifact).
produced=$(grep -aE 'PRODUCED:' "$out" 2>/dev/null | tail -1 | sed -E 's/.*PRODUCED:[[:space:]]*//; s/[[:space:]]+$//')
printf '%s %s %s %s\n' "$verdict" "$used_model" "$dur" "$produced" > "$verdict_file"
