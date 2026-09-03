#!/usr/bin/env bash
[ -f "$HOME/.config/cronctl/enabled/forge-health" ] || exit 0
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

# runs today + success/fail split. NONSESSION excludes bookkeeping lines that are not
# claude sessions: SKIP(...)/QUARANTINED verdicts, the substrate guard's revert notes
# (0s, actor "(guard)" — added with the wave engine), and "manual" ops notes (2nd field
# the literal `manual`, no verdict). Counting manual notes inflated fail_today by the
# number of manual notes (reported 21 fails vs 19 real on 2026-07-21); the guard line
# is the same class. Verdict markers are FIELD-anchored ("| SKIP(...) |") so an ops
# note that merely MENTIONS one can't fake a verdict (that bug lived ~10 min 2026-07-21).
# FM-8: ok(DEFERRED) (precondition-gated no-op) and REAPED (reaper event) are bookkeeping
# too; -a on every LOG grep so a stray bad byte can never re-blind the health check.
# DEFERRED_HOLD is the FM-8-follow-up per-job hold latch line (SKIP(DEFERRED_HOLD) matches SKIP\().
NONSESSION='\| (SKIP\(|QUARANTINED|BRIDGE|ok\(DEFERRED\)|REAPED|TIMEOUT\(BUT_ARTIFACT\)|DEFERRED_HOLD|SUBSTRATE_VIOLATION \| \(guard\))|^- [^ ]+ manual '
ran_today=$( { grep -a "^- $today " "$LOG" 2>/dev/null || true; } | grep -cvE "$NONSESSION" )
ok_today=$(grep -aE "^- $today " "$LOG" 2>/dev/null | grep -vE "$NONSESSION" | grep -c '| ok |')
fail_today=$(( ran_today - ok_today ))
proxy_skips=$(grep -aE "^- $today " "$LOG" 2>/dev/null | grep -c '| SKIP(PROXY_DOWN) |')

# recent window (last 5 dated SESSIONS) — health is about NOW, not cumulative since
# midnight (old pre-fix failures would otherwise poison the verdict all day).
recent=$(grep -aE "^- $today " "$LOG" 2>/dev/null | grep -vE "$NONSESSION" | tail -5)
recent_ok=$(printf '%s\n' "$recent" | grep -c '| ok |')
recent_total=$(printf '%s\n' "$recent" | grep -c '^- ')
recent_fail=$(( recent_total - recent_ok ))

# last runner completion timestamp (ISO ...T..Z) from the most recent dated line
last_iso=$(grep -aE "^- $today " "$LOG" 2>/dev/null \
  | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' | tail -1)
if [[ -n "$last_iso" ]]; then
  last_epoch=$(date -d "$last_iso" +%s 2>/dev/null || echo "$now")
  mins_since=$(( (now - last_epoch) / 60 ))
else
  mins_since=-1
fi

# is a runner active right now? (non-destructive lock probe)
if flock -n "$LOCKFILE" true 2>/dev/null; then lock="idle"; else lock="running-now"; fi

# verdict — a tick is every 15 min; >40 min silent with no cap = something's wrong
last_line=$(grep -aE "^- $today " "$LOG" 2>/dev/null | tail -1)
if   (( ran_today >= MAX_SESSIONS_PER_DAY )); then verdict="CAPPED"
elif (( mins_since < 0 ));                     then verdict="NORUNS"
elif [[ "$last_line" == *'| SKIP(PROXY_DOWN) |'* ]]; then verdict="PROXY_DOWN"   # timer alive, router dead
elif (( recent_fail > recent_ok )) && (( recent_total >= 3 )); then verdict="FAILING"
elif (( mins_since > 40 )) && [[ "$lock" == "idle" ]];   then verdict="STALE"
else verdict="HEALTHY"
fi

# ── Session SUCCESS score (did each session actually produce an artifact?) ──
# evaluate.sh judges by artifact-production, not exit code/error string; INFRA fails
# (proxy/429/timeout) are excluded from the rate. Refresh it, then surface the headline.
bash "$SCRIPT_DIR/evaluate.sh" >/dev/null 2>&1 || true
bash "$SCRIPT_DIR/rollup.sh"   >/dev/null 2>&1 || true   # keep the daily calendar row live
success_line=$(sed -n '3p' "$HARNESS/state/evaluate.txt" 2>/dev/null)
counts_line=$(sed -n '2p' "$HARNESS/state/evaluate.txt" 2>/dev/null)

{
  echo "Forge health: $verdict  (checked $ts_now)"
  echo "runs today: $ran_today  (ok=$ok_today fail=$fail_today  proxy-skips=$proxy_skips)  cap=$MAX_SESSIONS_PER_DAY"
  echo "recent (last 5): ok=$recent_ok fail=$recent_fail"
  [[ -n "$counts_line" ]]  && echo "$counts_line"
  [[ -n "$success_line" ]] && echo "$success_line"
  echo "last run: ${last_iso:-none}  (${mins_since} min ago)   runner: $lock"
  echo "queue: done=$(grep -c '^- \[x\]' "$QUEUE")  pending=$(grep -c '^- \[ \]' "$QUEUE")  quarantined=$(grep -c '^- \[!\]' "$QUEUE")"
} | tee "$HEALTH"
