#!/usr/bin/env bash
# ── The Forge runner ──
# Cron entry point. Picks the next job from queue.md, runs one bounded
# headless Claude session against the vault, logs the result, marks the job done.
#
# Design goals: no overlap (flock), no runaway spend (daily cap + max-turns +
# timeout), fully observable (everything lands in LOG.md + the vault), and the
# spawned session is governed by CLAUDE.md.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
mkdir -p "$HARNESS/state"

ts() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
today() { date -u '+%Y-%m-%d'; }

log_line() {  # append one structured line to LOG.md
  printf '%s\n' "$1" >> "$LOG"
}

# ── Guard 1: single instance ──
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "[$(ts)] skip: another runner holds the lock" >&2
  exit 0
fi

# ── Guard 2: daily spend ceiling ──
if [[ -f "$LOG" ]]; then
  ran_today=$(grep -c "^- $(today) " "$LOG" 2>/dev/null || echo 0)
else
  ran_today=0
fi
if (( ran_today >= MAX_SESSIONS_PER_DAY )); then
  echo "[$(ts)] skip: daily cap reached ($ran_today/$MAX_SESSIONS_PER_DAY)" >&2
  exit 0
fi

# ── Pick the next unchecked job ──
# A job is a markdown checkbox line:  - [ ] [ROLE] description
job_line=$(grep -nE '^- \[ \] ' "$QUEUE" | head -1)
if [[ -z "$job_line" ]]; then
  # Queue empty → run a default maintenance/reflection job instead of idling.
  job="[Steward] Queue is empty. Review LOG.md for the last 24h: summarize what compounded, flag any repeated failures, and propose 3 new jobs to append to _harness/queue.md. Keep it short."
  job_ref="(auto: empty-queue reflection)"
else
  lineno="${job_line%%:*}"
  job="${job_line#*:}"
  job="${job#- [ ] }"          # strip the checkbox prefix
  job_ref="$job"
fi

# ── Build the session prompt ──
read -r -d '' PROMPT <<EOF
You are the Forge running an autonomous CRON SESSION inside the Obsidian vault at $VAULT.

FIRST, orient yourself: read CLAUDE.md (the constitution), MEMORY.md, and INDEX.md at the vault root.

YOUR JOB THIS SESSION:
$job

RULES:
- Stay vertical on the mission (compound knowledge/skills/value toward revenue). No side quests.
- Write your work product to the correct vault location (inbox/, wiki/, projects/, .forge/skills/ per CLAUDE.md).
- Test, don't wonder: attach evidence or a verdict to any claim. No evidence = label it aspiration.
- Do NOT edit CLAUDE.md. Do NOT move capital. Do NOT touch _harness/queue.md or LOG.md (the runner logs for you).
- Be concise and bounded. Produce a durable artifact or a clean negative result.

When done, print a ONE-LINE summary of what you produced and where (path). That line is captured as the session record.
EOF

# ── Run one bounded headless session ──
model_flag=()
[[ -n "$MODEL" ]] && model_flag=(--model "$MODEL")

out_file="$HARNESS/state/last-session.out"
start=$(date +%s)
timeout "$SESSION_TIMEOUT" claude -p "$PROMPT" \
  --dangerously-skip-permissions \
  --max-turns "$MAX_TURNS" \
  "${model_flag[@]}" \
  > "$out_file" 2>&1
status=$?
dur=$(( $(date +%s) - start ))

# ── Record the result ──
summary=$(grep -vE '^\s*$' "$out_file" | tail -1 | cut -c1-200)
[[ -z "$summary" ]] && summary="(no output captured)"
case $status in
  0)   verdict="ok" ;;
  124) verdict="TIMEOUT(${SESSION_TIMEOUT}s)" ;;
  *)   verdict="exit$status" ;;
esac

log_line "- $(today) $(ts) | ${dur}s | ${verdict} | ${job_ref} | ${summary}"

# ── Mark the job done in the queue (only real queue jobs, not the auto one) ──
if [[ -n "${lineno:-}" ]]; then
  # Replace this exact line's unchecked box with a checked one.
  python3 - "$QUEUE" "$lineno" <<'PY'
import sys
path, lineno = sys.argv[1], int(sys.argv[2])
with open(path) as f:
    lines = f.readlines()
if 0 < lineno <= len(lines):
    lines[lineno-1] = lines[lineno-1].replace('- [ ] ', '- [x] ', 1)
with open(path, 'w') as f:
    f.writelines(lines)
PY
fi

echo "[$(ts)] done: ${verdict} | ${job_ref}" >&2
