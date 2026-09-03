#!/usr/bin/env bash
# ── cron-agent-swarm worker ──
# Runs ONE queue job as a bounded headless agent session with model fallback.
# Invoked by runner.sh (the wave dispatcher) as:
#   setsid --wait bash worker.sh <slot> <job-text> [max_turns] [budget]
# setsid makes this worker its own session/process-group leader, so $$ == PGID —
# the dispatcher can reap the whole group (worker + its agent child) via `kill -- -PGID`.
#
# Writes:
#   state/worker-<slot>.out      agent output (last model attempt)
#   state/worker-<slot>.verdict  "<verdict> <model> <dur>" for the dispatcher to log
#   state/worker-<slot>.pid      own pid (== PGID) while running; removed on exit
#
# The WHOLE fallback loop is bounded by <budget> (default WORKER_BUDGET): before each
# model attempt we shrink its per-attempt timeout to the remaining budget, so the loop
# always ends near the deadline even if every model cascades.
set -uo pipefail

slot="${1:?slot required}"; job="${2:?job required}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
export PATH="$(dirname "$AGENT_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"
cd "$WORKSPACE" || exit 1

max_turns="${3:-$MAX_TURNS}"
budget="${4:-$WORKER_BUDGET}"

out="$HARNESS/state/worker-$slot.out"
verdict_file="$HARNESS/state/worker-$slot.verdict"
pidfile="$HARNESS/state/worker-$slot.pid"
echo $$ > "$pidfile"                       # $$ == PGID (setsid made us group leader)
trap 'rm -f "$pidfile"' EXIT

# ── Worker prompt: do ONE job; write only your own artifact; substrate is read-only ──
read -r -d '' PROMPT <<EOF
You are an autonomous CRON WORKER running inside the workspace at $WORKSPACE.
You are one of several workers running IN PARALLEL this tick, each on a different job.

FIRST, orient yourself: read $ORIENT_FILES at the workspace root (constitution, memory, index).

YOUR JOB THIS SESSION:
$job

RULES:
- Stay on mission: do what the workspace constitution says matters. No side quests.
- Write your work product as YOUR OWN NEW artifact in the right place (per the constitution's layout). Do not overwrite another note.
- SHARED SUBSTRATE IS READ-ONLY for workers: do NOT edit $LOG, $QUEUE, or these files: $SUBSTRATE_FILES. The runner logs your result and a serial curator catalogs new notes later. You may READ all of them.
- Do NOT run git (no add/commit) — a serial process handles that.
- Test, don't wonder: attach evidence or a verdict to any claim. No evidence = label it aspiration.
- Do NOT edit the constitution.
- Be concise and bounded. Produce a durable artifact or a clean negative result.

When done, print a ONE-LINE summary of what you produced and where (path). That line is captured as your session record.
EOF

# ── Model fallback, bounded by the whole-loop budget ──
# Agent-CLI flag dialect comes from config.env (defaults = Claude Code).
read -r -a RUN_ARGS <<< "${AGENT_RUN_ARGS:-}"
is_routing_failure() { grep -qiE "issue with the selected model|may not exist or you may not have access" "$out"; }
read -r -a MODELS <<< "${MODEL_CHAIN:-}"
(( ${#MODELS[@]} == 0 )) && MODELS=("")

used_model="(none)"; verdict=""; start=$(date +%s)
deadline=$(( start + budget ))
for m in "${MODELS[@]}"; do
  rem=$(( deadline - $(date +%s) ))
  if (( rem <= 0 )); then verdict="TIMEOUT(${budget}s)"; break; fi
  per=$SESSION_TIMEOUT; (( rem < per )) && per=$rem
  if [[ -n "$m" ]]; then
    timeout "$per" "$AGENT_BIN" "${RUN_ARGS[@]}" "$PROMPT" \
      "$AGENT_TURNS_FLAG" "$max_turns" "$AGENT_MODEL_FLAG" "$m" > "$out" 2>&1
  else
    timeout "$per" "$AGENT_BIN" "${RUN_ARGS[@]}" "$PROMPT" \
      "$AGENT_TURNS_FLAG" "$max_turns" > "$out" 2>&1
  fi
  status=$?
  if [[ $status -ne 124 ]] && is_routing_failure; then continue; fi   # model unavailable → cascade
  used_model="${m:-agent-default}"
  case $status in
    0)   verdict="ok" ;;
    124) verdict="TIMEOUT(${per}s)" ;;
    *)   verdict="exit$status" ;;
  esac
  break
done
dur=$(( $(date +%s) - start ))
[[ -z "$verdict" ]] && { verdict="ROUTING_FAIL"; used_model="(none-routed)"; }   # no spaces: the verdict file is read-split by the runner

printf '%s %s %s\n' "$verdict" "$used_model" "$dur" > "$verdict_file"
