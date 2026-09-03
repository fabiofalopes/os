#!/usr/bin/env bash
# ── cron-agent-swarm runner (wave dispatcher) ──
# Cron entry point (e.g. */15). Each tick is a WAVE: up to WORKERS_PER_TICK parallel
# agent sessions on distinct queue jobs, then (by wave count) a serial "builder"
# session for deeper work, and — if you supply one — a council.sh that steers the
# queue. One clock, tiered by a persistent wave counter.
#
# Design goals: no overlap (flock), no runaway spend (daily cap + per-worker budget +
# max-turns), no orphaned processes (setsid worker groups + startup reaper + exit trap),
# substrate integrity (workers are read-only on shared files; snapshot detect-and-revert),
# fully observable (every tick lands in LOG.md). Sessions are governed by your constitution.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
mkdir -p "$HARNESS/state"
export PATH="$(dirname "$AGENT_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"
# Run from the workspace root so the agent CLI picks up the workspace's own config/trust
# (cron's cwd is $HOME, which silently ignores them) and relative paths resolve here.
cd "$WORKSPACE" || exit 1

ts() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }          # stderr messages only
today() { date -u '+%Y-%m-%d'; }
# log_line "<dur>s | <verdict> | <model> | <job> | <summary>" — the timestamp prefix is
# added HERE so every line matches the documented format `- YYYY-MM-DD HH:MM:SSZ | …`.
log_line() { printf -- '- %s %s | %s\n' "$(today)" "$(date -u '+%H:%M:%SZ')" "$1" >> "$LOG"; }

# ── Guard 1: single instance ──
exec 9>"$LOCKFILE"
if ! flock -n 9; then echo "[$(ts)] skip: another runner holds the lock" >&2; exit 0; fi

# ── Startup reaper: kill orphaned workers from a SIGKILLed prior dispatcher ──
# Safe because flock guarantees we're the sole dispatcher, so any worker pidfile belongs
# to a dead run. Verify the group leader is actually a worker before group-killing
# (guards against a recycled pid), then kill the whole group (worker + its agent child).
for pf in "$HARNESS/state"/worker-*.pid; do
  [[ -e "$pf" ]] || continue
  pg=$(cat "$pf" 2>/dev/null)
  if [[ -n "$pg" ]] && ps -o args= -p "$pg" 2>/dev/null | grep -q 'worker\.sh'; then
    kill -- "-$pg" 2>/dev/null && echo "[$(ts)] reaped orphaned worker group $pg" >&2
  fi
  rm -f "$pf"
done

# ── Guard 2: daily spend ceiling (SKIP/QUARANTINED are bookkeeping, not sessions) ──
if [[ -f "$LOG" ]]; then
  ran_today=$( { grep "^- $(today) " "$LOG" 2>/dev/null || true; } | grep -cvE '\| (SKIP\(|QUARANTINED)' )
else
  ran_today=0
fi
if (( ran_today >= MAX_SESSIONS_PER_DAY )); then
  echo "[$(ts)] skip: daily cap reached ($ran_today/$MAX_SESSIONS_PER_DAY)" >&2; exit 0
fi

# ── Guard 3: proxy preflight (once per wave) ──
# If you route the agent CLI through a local proxy, set PREFLIGHT_URL in config.env;
# a dead proxy then produces one clean SKIP line instead of a wave of timeouts.
if [[ -n "${PREFLIGHT_URL:-}" ]]; then
  _hp="${PREFLIGHT_URL#*://}"; _hp="${_hp%%/*}"
  _host="${_hp%%:*}"; _port="${_hp##*:}"
  if ! (exec 3<>"/dev/tcp/${_host}/${_port}") 2>/dev/null; then
    log_line "0s | SKIP(PROXY_DOWN) | (preflight) | (no job attempted) | ${PREFLIGHT_URL} not accepting connections — router down? wave skipped, jobs preserved"
    echo "[$(ts)] skip: ${PREFLIGHT_URL} not accepting connections" >&2
    exit 0
  fi
fi

# ── Helpers ──
fail_streak() {  # consecutive REAL (non-infra) fails for job "$1", from LOG
  awk -F'|' -v job="$1" '
    /^- / {
      v=$3; j=$5
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", j)
      if (j != job) next
      if (v == "ok") { s = 0; next }
      if ($6 ~ /ConnectionRefused|Unable to connect|PROXY_DOWN|429|rate.?limit|overloaded|quota|too many requests|503|upstream/) next  # infra
      s++
    }
    END { print s+0 }' "$LOG"
}

mark_job() {  # mark_job <job-text> <new-prefix> — flip the UNCHECKED line matching <job-text>
  python3 - "$QUEUE" "$1" "$2" <<'PY'
import sys, os, tempfile
path, job, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
target = '- [ ] ' + job
with open(path) as f:
    lines = f.readlines()
hit = False
for i, l in enumerate(lines):
    if l.rstrip('\n') == target:
        lines[i] = prefix + job + '\n'; hit = True; break
if not hit:
    sys.exit(0)
d = os.path.dirname(path) or '.'
fd, tmp = tempfile.mkstemp(dir=d, prefix='.queue.', suffix='.tmp')
with os.fdopen(fd, 'w') as t:
    t.writelines(lines)
os.replace(tmp, path)
PY
}

mark_proposal() {  # mark_proposal <job-text> — flip a merged proposal in proposals.md to '- [>] '
  python3 - "$HARNESS/proposals.md" "$1" <<'PY'
import sys, os, tempfile
path, job = sys.argv[1], sys.argv[2]
target = '- [ ] ' + job
with open(path) as f:
    lines = f.readlines()
hit = False
for i, l in enumerate(lines):
    if l.rstrip('\n') == target:
        lines[i] = '- [>] ' + job + '\n'; hit = True; break
if not hit:
    sys.exit(0)
d = os.path.dirname(path) or '.'
fd, tmp = tempfile.mkstemp(dir=d, prefix='.proposals.', suffix='.tmp')
with os.fdopen(fd, 'w') as t:
    t.writelines(lines)
os.replace(tmp, path)
PY
}

# ── Wave counter (persistent; flock serializes writers) ──
wave=$(cat "$HARNESS/state/wave" 2>/dev/null || echo 0); wave=$(( wave + 1 ))
echo "$wave" > "$HARNESS/state/wave"

# ── Claim up to N jobs (single process = atomic); de-dup write targets so two
#    parallel workers can't write the same note. Breaker quarantines poisoned jobs. ──
budget=$(( MAX_SESSIONS_PER_DAY - ran_today ))
n=$(( WORKERS_PER_TICK < budget ? WORKERS_PER_TICK : budget ))
declare -a J_JOB=() J_LINE=()
declare -A CLAIMED_TARGET=()
if (( n > 0 )); then
  while IFS= read -r entry; do
    (( ${#J_JOB[@]} >= n )) && break
    lineno="${entry%%:*}"; raw="${entry#*:}"; job="${raw:6}"   # strip 6-char '- [ ] ' prefix (fixed offset — ${raw#- [ ] } is a glob char-class and fails to match)
    streak=$(fail_streak "$job")
    if (( streak >= MAX_JOB_RETRIES )); then
      mark_job "$job" '- [!] '
      log_line "0s | QUARANTINED | (breaker) | ${job} | ${streak} consecutive fails — [!], queue advanced; a review job should triage"
      echo "[$(ts)] quarantined after ${streak} fails: ${job}" >&2
      continue
    fi
    tgt=$(printf '%s' "$job" | grep -oE '[A-Za-z0-9_./-]+\.md' | tail -1)   # best-effort target
    if [[ -n "$tgt" ]]; then
      [[ -n "${CLAIMED_TARGET[$tgt]:-}" ]] && continue                        # collide → skip this wave
      CLAIMED_TARGET[$tgt]=1
    fi
    J_JOB+=("$job"); J_LINE+=("$lineno")
  done < <(grep -nE '^- \[ \] ' "$QUEUE")
fi

# Empty queue → at most ONE reflection per REFLECT_EVERY seconds (default 6h).
# Unthrottled, an empty queue re-fires every tick (~96/day), burning the daily cap on
# near-duplicate notes.
if (( ${#J_JOB[@]} == 0 )); then
  # ── Bridge: self-feed from proposals.md. Workers are read-only on the queue, so an
  #    empty-queue review stages jobs in proposals.md; the runner (sole queue writer)
  #    merges the top pending one each empty wave and it runs next wave. Production
  #    beats reflection — a merged wave exits without a review firing.
  if [[ -f "$HARNESS/proposals.md" ]] && grep -qE '^- \[ \] ' "$HARNESS/proposals.md"; then
    pj=$(grep -m1 -E '^- \[ \] ' "$HARNESS/proposals.md" | sed 's/^- \[ \] //')
    printf '%s\n' "- [ ] $pj" >> "$QUEUE"
    mark_proposal "$pj"
    log_line "0s | BRIDGE | (runner) | ${pj} | merged top proposal into queue — runs next wave"
    echo "[$(ts)] bridge: merged proposal into queue: ${pj}" >&2
    exit 0
  fi
  now=$(date -u +%s); last=$(cat "$HARNESS/state/last-reflect" 2>/dev/null || echo 0)
  if (( now - last >= ${REFLECT_EVERY:-21600} )); then
    echo "$now" > "$HARNESS/state/last-reflect"
    J_JOB+=("[steward] Queue is empty and no proposals are pending. Review $LOG for the last 24h: summarize what compounded, flag any repeated failures, and stage 3 new jobs as '- [ ]' lines in $HARNESS/proposals.md (the runner auto-merges them into the queue — do NOT edit $QUEUE directly). Keep it short.")
    J_LINE+=("")
  else
    log_line "0s | SKIP(EMPTY_QUEUE) | (throttle) | (no job attempted) | empty queue, reflected $(( (now-last)/60 ))m ago (< ${REFLECT_EVERY:-21600}s) — throttled"
    echo "[$(ts)] skip: empty queue, reflection throttled" >&2
    exit 0
  fi
fi

# ── Snapshot the shared substrate for detect-and-revert (workers must not edit it) ──
# SUBSTRATE_FILES (config.env) lists workspace-root files, space-separated, no spaces in names.
snap="$HARNESS/state/substrate"; mkdir -p "$snap"
for f in $SUBSTRATE_FILES; do cp -f "$WORKSPACE/$f" "$snap/$f" 2>/dev/null; done

# ── Fork workers: each in its own session/PGID, self-bounded by WORKER_BUDGET ──
cleanup() {  # kill any live worker groups on dispatcher exit (normal or signalled)
  for pf in "$HARNESS/state"/worker-*.pid; do
    [[ -e "$pf" ]] || continue
    pg=$(cat "$pf" 2>/dev/null)
    [[ -n "$pg" ]] && kill -- "-$pg" 2>/dev/null
  done
}
trap cleanup EXIT
trap 'exit 143' TERM HUP INT

declare -a PIDS=()
for i in "${!J_JOB[@]}"; do
  setsid --wait bash "$HARNESS/worker.sh" "$i" "${J_JOB[$i]}" \
    > "$HARNESS/state/worker-$i.err" 2>&1 &
  PIDS[$i]=$!
done
wait "${PIDS[@]}" 2>/dev/null        # bounded: each worker self-bounds to WORKER_BUDGET

# ── Substrate integrity: revert any shared file a worker touched ──
for f in $SUBSTRATE_FILES; do
  if [[ -f "$snap/$f" ]] && ! cmp -s "$WORKSPACE/$f" "$snap/$f" 2>/dev/null; then
    cp -f "$snap/$f" "$WORKSPACE/$f"
    log_line "0s | SUBSTRATE_VIOLATION | (guard) | ${f} | a worker edited shared substrate — reverted to pre-wave snapshot"
  fi
done

# ── Collect: log ONE line per worker, mark done the ok ones (serial, single writer) ──
for i in "${!J_JOB[@]}"; do
  verdict=""; used_model="(none)"; dur=0
  read -r verdict used_model dur < "$HARNESS/state/worker-$i.verdict" 2>/dev/null || true
  [[ -z "$verdict" ]] && verdict="exit(no-verdict)"
  summary=$(grep -vE '^\s*$' "$HARNESS/state/worker-$i.out" 2>/dev/null | tail -1 | cut -c1-200 | tr '|' '/')  # tr: agent output must not inject the field delimiter
  [[ -z "$summary" ]] && summary="(no output captured)"
  log_line "${dur}s | ${verdict} | ${used_model} | ${J_JOB[$i]} | ${summary}"
  [[ -n "${J_LINE[$i]}" && "$verdict" == "ok" ]] && mark_job "${J_JOB[$i]}" '- [x] '
  rm -f "$HARNESS/state/worker-$i.verdict" "$HARNESS/state/worker-$i.err"
done

# ── Every-Nth-wave branches, SERIAL after workers (sole substrate writer in phase) ──
# Council (bring your own $HARNESS/council.sh) and builder are mutually exclusive to
# bound per-wave cost; council wins on its wave. No council.sh → the hook is inert.
if (( COUNCIL_EVERY > 0 )) && (( wave % COUNCIL_EVERY == 0 )) && [[ -f "$HARNESS/council.sh" ]]; then
  bash "$HARNESS/council.sh" "$wave" || echo "[$(ts)] council wave $wave failed" >&2
elif (( BUILDER_EVERY > 0 )) && (( wave % BUILDER_EVERY == 0 )); then
  # one bigger session on the next unchecked job, with a larger turn budget
  bj=$(grep -m1 -E '^- \[ \] ' "$QUEUE" | sed 's/^- \[ \] //')
  if [[ -n "$bj" ]]; then
    setsid --wait bash "$HARNESS/worker.sh" builder "$bj" "$BUILDER_MAX_TURNS" "$BUILDER_BUDGET" \
      > "$HARNESS/state/worker-builder.err" 2>&1
    read -r verdict used_model dur < "$HARNESS/state/worker-builder.verdict" 2>/dev/null || { verdict="exit(no-verdict)"; used_model="(none)"; dur=0; }
    summary=$(grep -vE '^\s*$' "$HARNESS/state/worker-builder.out" 2>/dev/null | tail -1 | cut -c1-200 | tr '|' '/')
    log_line "${dur}s | ${verdict:-?} | ${used_model} | [builder] ${bj} | ${summary:-(no output)}"
    [[ "$verdict" == "ok" ]] && mark_job "$bj" '- [x] '
    rm -f "$HARNESS/state/worker-builder.verdict" "$HARNESS/state/worker-builder.err"
  fi
fi

echo "[$(ts)] wave $wave done: ${#J_JOB[@]} workers" >&2
