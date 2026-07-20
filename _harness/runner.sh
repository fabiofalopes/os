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
# Routing/auth for claude (ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN). Git-ignored;
# cron's bare env doesn't have them — the session launcher injects them interactively.
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
mkdir -p "$HARNESS/state"

# Cron runs with a bare PATH (/usr/bin:/bin). Make sure claude + node are reachable.
export PATH="$(dirname "$CLAUDE_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"

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

# ── Run one bounded headless session, with model fallback ──
out_file="$HARNESS/state/last-session.out"

# A model-ROUTING failure (model unavailable) cascades to the next model in the chain.
# Any other outcome (timeout, non-zero exit, normal output) is a real session result — final.
is_routing_failure() {
  grep -qiE "issue with the selected model|may not exist or you may not have access" "$out_file"
}

read -r -a MODELS <<< "${MODEL_CHAIN:-}"
(( ${#MODELS[@]} == 0 )) && MODELS=("")   # empty chain → run claude default once

used_model="(none)"
verdict=""
start=$(date +%s)
for m in "${MODELS[@]}"; do
  if [[ -n "$m" ]]; then
    timeout "$SESSION_TIMEOUT" "$CLAUDE_BIN" -p "$PROMPT" --dangerously-skip-permissions \
      --max-turns "$MAX_TURNS" --model "$m" > "$out_file" 2>&1
  else
    timeout "$SESSION_TIMEOUT" "$CLAUDE_BIN" -p "$PROMPT" --dangerously-skip-permissions \
      --max-turns "$MAX_TURNS" > "$out_file" 2>&1
  fi
  status=$?
  if [[ $status -ne 124 ]] && is_routing_failure; then
    echo "[$(ts)] model '$m' unavailable — cascading to next" >&2
    continue
  fi
  used_model="${m:-claude-default}"
  case $status in
    0)   verdict="ok" ;;
    124) verdict="TIMEOUT(${SESSION_TIMEOUT}s)" ;;
    *)   verdict="exit$status" ;;
  esac
  break
done
dur=$(( $(date +%s) - start ))
[[ -z "$verdict" ]] && { verdict="ROUTING_FAIL"; used_model="(none routed)"; }

# ── Record the result ──
summary=$(grep -vE '^\s*$' "$out_file" | tail -1 | cut -c1-200)
[[ -z "$summary" ]] && summary="(no output captured)"

log_line "- $(today) $(ts) | ${dur}s | ${verdict} | ${used_model} | ${job_ref} | ${summary}"

# ── Mark the job done ONLY on success (verdict=ok). Failures (exit127, timeout,
#    routing_fail, non-zero) stay UNCHECKED so the next tick retries — never silently
#    drop work. A poisoned job that keeps failing is loud in LOG.md; META-REVIEW clears it. ──
if [[ -n "${lineno:-}" && "$verdict" == "ok" ]]; then
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
