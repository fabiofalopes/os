#!/usr/bin/env bash
# ── Forge health check ──
# Glanceable "are the cron sessions running fine?" signal. Writes
# _harness/state/health.txt and prints status. Run on demand or via the
# watchdog cron (see crontab). Distinguishes healthy / stale / failing /
# capped (daily ceiling hit — done for today, NOT broken) / no-runs.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
mkdir -p "$HARNESS/state"
HEALTH="$HARNESS/state/health.txt"

now=$(date +%s)
today=$(date -u +%F)
ts_now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# runs today + success/fail split
ran_today=$(grep -c "^- $today " "$LOG" 2>/dev/null || echo 0)
ok_today=$(grep -E "^- $today " "$LOG" 2>/dev/null | grep -c '| ok |')
fail_today=$(( ran_today - ok_today ))

# recent window (last 5 dated runs) — health is about NOW, not cumulative since
# midnight (old pre-fix failures would otherwise poison the verdict all day).
recent=$(grep -E "^- $today " "$LOG" 2>/dev/null | tail -5)
recent_ok=$(printf '%s\n' "$recent" | grep -c '| ok |')
recent_total=$(printf '%s\n' "$recent" | grep -c '^- ')
recent_fail=$(( recent_total - recent_ok ))

# last runner completion timestamp (ISO ...T..Z) from the most recent dated line
last_iso=$(grep -E "^- $today " "$LOG" 2>/dev/null \
  | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' | tail -1)
if [[ -n "$last_iso" ]]; then
  last_epoch=$(date -d "$last_iso" +%s 2>/dev/null || echo "$now")
  mins_since=$(( (now - last_epoch) / 60 ))
else
  mins_since=-1
fi

# is a runner active right now? (non-destructive lock probe)
if flock -n "$LOCKFILE" true 2>/dev/null; then lock="idle"; else lock="running-now"; fi

# verdict — a tick is every 20 min; >40 min silent with no cap = something's wrong
if   (( ran_today >= MAX_SESSIONS_PER_DAY )); then verdict="CAPPED"
elif (( mins_since < 0 ));                     then verdict="NORUNS"
elif (( recent_fail > recent_ok )) && (( recent_total >= 3 )); then verdict="FAILING"
elif (( mins_since > 40 )) && [[ "$lock" == "idle" ]];   then verdict="STALE"
else verdict="HEALTHY"
fi

{
  echo "Forge health: $verdict  (checked $ts_now)"
  echo "runs today: $ran_today  (ok=$ok_today fail=$fail_today)  cap=$MAX_SESSIONS_PER_DAY"
  echo "recent (last 5): ok=$recent_ok fail=$recent_fail"
  echo "last run: ${last_iso:-none}  (${mins_since} min ago)   runner: $lock"
  echo "queue: done=$(grep -c '^- \[x\]' "$QUEUE")  pending=$(grep -c '^- \[ \]' "$QUEUE")"
} | tee "$HEALTH"
