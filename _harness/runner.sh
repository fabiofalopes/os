#!/usr/bin/env bash
[ -f "$HOME/.config/cronctl/enabled/forge-runner" ] || exit 0
# ── The Forge runner (wave dispatcher) ──
# Cron entry point (*/15). Each tick is a WAVE: up to WORKERS_PER_TICK parallel
# worker sessions on distinct queue jobs, then (by wave count) a serial "builder"
# session and/or the multi-model "council" that steers the queue. One clock, tiered
# by a persistent wave counter — the "agentic village". See schedule.md and
# wiki/concepts/multi-agent-orchestration-patterns.md.
#
# Design goals: no overlap (flock), no runaway spend (daily cap + per-worker budget +
# max-turns), no orphaned processes (setsid worker groups + startup reaper + exit trap),
# substrate integrity (workers are read-only on shared files; snapshot detect-and-revert),
# fully observable (everything lands in LOG.md). Sessions are governed by CLAUDE.md.
set -uo pipefail

# FM-8: force a UTF-8 locale regardless of cron's C locale — so the summary slice in the
# collect phase counts CHARACTERS, not bytes (a C-locale `cut -c1-200` once truncated an
# em dash to a lone lead byte and flipped LOG.md binary-to-grep, silently disabling
# Guard 2), and every grep/awk on the audit trail is encoding-safe.
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
mkdir -p "$HARNESS/state"
export PATH="$(dirname "$CLAUDE_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"
# Run from the vault root so claude picks up the vault's .claude allowlist + trust
# (cron's cwd is $HOME, which silently ignored them) and relative paths resolve here.
cd "$VAULT" || exit 1

ts() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
today() { date -u '+%Y-%m-%d'; }
log_line() {  # FM-8: sanitize every appended line to valid UTF-8 (one truncated multibyte
  # char makes grep classify the WHOLE audit trail as binary, silently disabling Guard 2
  # and every grep audit), and ABORT on append failure — with no `set -e`, a swallowed
  # printf failure must never let a mark_job outrun its LOG line.
  printf '%s\n' "$1" | iconv -f UTF-8 -t UTF-8 -c >> "$LOG" || exit 1; }

# ── Guard 1: single instance ──
exec 9>"$LOCKFILE"
if ! flock -n 9; then echo "[$(ts)] skip: another runner holds the lock" >&2; exit 0; fi

# ── Startup reaper: kill orphaned workers from a SIGKILLed prior dispatcher ──
# Safe because flock guarantees we're the sole dispatcher, so any worker pidfile belongs
# to a dead run. Verify the group leader is actually a worker before group-killing
# (guards against a recycled pid), then kill the whole group (worker + its claude child).
for pf in "$HARNESS/state"/worker-*.pid; do
  [[ -e "$pf" ]] || continue
  pg=$(cat "$pf" 2>/dev/null)
  slot="${pf##*/worker-}"; slot="${slot%.pid}"
  if [[ -n "$pg" ]] && ps -o args= -p "$pg" 2>/dev/null | grep -q 'worker\.sh'; then
    # FM-8: no kill is silent — the .job sidecar the worker wrote at dispatch names what
    # was killed (before this, reaps went to stderr only and any work the orphan had done
    # was unrecorded — the 02:15Z/03:45Z TIMEOUT-did-work-unrecorded family). Read the job
    # BEFORE killing: SIGTERM runs the worker's EXIT trap, which deletes its own sidecar.
    rjob=$(cat "$HARNESS/state/worker-$slot.job" 2>/dev/null || true)
    if kill -- "-$pg" 2>/dev/null; then
      log_line "- $(today) $(ts) | 0s | REAPED | (reaper) | ${rjob:-(unknown job)} | orphaned worker group $pg killed at wave start — work (if any) unrecorded, job preserved [ ]"
      echo "[$(ts)] reaped orphaned worker group $pg" >&2
    fi
  fi
  # FM-8: clear the dead run's sidecars too, so this wave's collect can never read a STALE verdict
  rm -f "$pf" "$HARNESS/state/worker-$slot.job" "$HARNESS/state/worker-$slot.verdict" "$HARNESS/state/worker-$slot.out"
done

# ── Guard 2: daily spend ceiling (SKIP/QUARANTINED/QUOTA_* are bookkeeping, not sessions) ──
if [[ -f "$LOG" ]]; then
  # -a: count LOG as text even if a stray bad byte ever returns (belt-and-braces — log_line
  # sanitizes, but Guard 2 must NEVER be silently disabled again, FM-8). ok(DEFERRED)/REAPED
  # are bookkeeping, not sessions (FM-8). DEFERRED_HOLD is the FM-8-follow-up latch line
  # (SKIP(DEFERRED_HOLD) is already matched by SKIP\().
  ran_today=$( { grep -a "^- $(today) " "$LOG" 2>/dev/null || true; } | grep -cvE '\| (SKIP\(|QUARANTINED|BRIDGE|ok\(DEFERRED\)|REAPED|TIMEOUT\(BUT_ARTIFACT\)|QUOTA_HOLD|QUOTA_RESUMED|GATEWAY_HOLD|GATEWAY_RESUMED|DEFERRED_HOLD)' )
else
  ran_today=0
fi
if (( ran_today >= MAX_SESSIONS_PER_DAY )); then
  echo "[$(ts)] skip: daily cap reached ($ran_today/$MAX_SESSIONS_PER_DAY)" >&2; exit 0
fi

# ── Guard 3: proxy preflight (once per wave) ──
if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
  _hp="${ANTHROPIC_BASE_URL#*://}"; _hp="${_hp%%/*}"
  _host="${_hp%%:*}"; _port="${_hp##*:}"
  if ! (exec 3<>"/dev/tcp/${_host}/${_port}") 2>/dev/null; then
    log_line "- $(today) $(ts) | 0s | SKIP(PROXY_DOWN) | (preflight) | (no job attempted) | ${ANTHROPIC_BASE_URL} not accepting connections — router down? wave skipped, jobs preserved"
    echo "[$(ts)] skip: ${ANTHROPIC_BASE_URL} not accepting connections" >&2
    exit 0
  fi
fi

# ── Guard 4: quota hold (429 breaker) ──
# A token-plan quota 429 carries its own reset time in the error text; quota_detect()
# (Helpers, run in the collect phase) latches it as epoch seconds in $QUOTA_HOLD. Until
# the reset passes, every wave exits here on a cheap SKIP(QUOTA) line instead of burning
# ~330s per worker re-hitting the same wall (2026-07-23…26: a dozen dead Steward sessions).
# Guard 3 catches a down router; this catches quota exhaustion — the gap it left open.
QUOTA_HOLD="$HARNESS/.quota_hold"
if [[ -f "$QUOTA_HOLD" ]]; then
  reset_epoch=$(cat "$QUOTA_HOLD" 2>/dev/null || echo 0)
  [[ "$reset_epoch" =~ ^[0-9]+$ ]] || reset_epoch=0          # corrupt hold → self-heal: clear + resume
  now_epoch=$(date -u +%s)
  if (( now_epoch < reset_epoch )); then
    log_line "- $(today) $(ts) | 0s | SKIP(QUOTA) | (breaker) | (no job attempted) | token-plan quota exhausted — resets $(date -u -d "@$reset_epoch" '+%Y-%m-%d %H:%M')Z ($(( (reset_epoch - now_epoch) / 60 ))m), wave skipped, jobs preserved"
    echo "[$(ts)] skip: quota hold until $(date -u -d "@$reset_epoch" '+%Y-%m-%d %H:%M')Z" >&2
    exit 0
  fi
  rm -f "$QUOTA_HOLD"
  log_line "- $(today) $(ts) | 0s | QUOTA_RESUMED | (breaker) | (dispatch resumed) | quota reset passed — hold file cleared"
fi

# ── Guard 5: gateway hold (502 breaker — FM-7) ──
# Guard 3 probes TCP only — a LISTENING router with a dead upstream passes it (2026-07-28:
# 4 Steward sessions, ~1078s burned, zero SKIP(PROXY_DOWN) lines all day). gateway_detect()
# (Helpers, run in the collect phase) and gateway_probe() (Guard 5b below) latch epoch
# seconds in $GATEWAY_HOLD; until they pass, every wave exits here on a cheap SKIP(GATEWAY)
# line instead of burning ~270s a head re-hitting the storm. Exact mirror of the FM-3 hold.
GATEWAY_HOLD="$HARNESS/.gateway_hold"
if [[ -f "$GATEWAY_HOLD" ]]; then
  until_epoch=$(cat "$GATEWAY_HOLD" 2>/dev/null || echo 0)
  [[ "$until_epoch" =~ ^[0-9]+$ ]] || until_epoch=0          # corrupt hold → self-heal: clear + resume
  now_epoch=$(date -u +%s)
  if (( now_epoch < until_epoch )); then
    log_line "- $(today) $(ts) | 0s | SKIP(GATEWAY) | (breaker) | (no job attempted) | gateway 5xx storm — hold expires $(date -u -d "@$until_epoch" '+%Y-%m-%d %H:%M')Z ($(( (until_epoch - now_epoch) / 60 ))m), wave skipped, jobs preserved"
    echo "[$(ts)] skip: gateway hold until $(date -u -d "@$until_epoch" '+%Y-%m-%d %H:%M')Z" >&2
    exit 0
  fi
  rm -f "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_RESUMED | (breaker) | (dispatch resumed) | gateway hold expired — hold file cleared"
fi

# ── Helpers ──
quota_detect() {  # quota_detect <outfile> — latch a quota hold if output shows a 429 quota error
  [[ -f "$1" && ! -f "$QUOTA_HOLD" ]] || return 0            # one QUOTA_HOLD line per event
  local reset epoch now y
  reset=$(grep -oE 'quota will reset at [0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} UTC' "$1" | head -1)
  reset="${reset#quota will reset at }"; reset="${reset% UTC}"
  [[ -n "$reset" ]] || return 0
  y=$(date -u +%Y)                                           # error text has MM-DD hh:mm:ss, no year
  epoch=$(date -u -d "$y-$reset UTC" +%s 2>/dev/null) || return 0
  now=$(date -u +%s)
  if (( epoch < now )); then                                 # a ≤1-week quota can't reset in the past → year rolled (Dec→Jan)
    epoch=$(date -u -d "$((y+1))-$reset UTC" +%s 2>/dev/null) || return 0
  fi
  echo "$epoch" > "$QUOTA_HOLD"
  log_line "- $(today) $(ts) | 0s | QUOTA_HOLD | (breaker) | (dispatch paused) | 429 token-plan quota exhausted — holding until $(date -u -d "@$epoch" '+%Y-%m-%d %H:%M')Z (parsed from the API error text)"
}

gateway_detect() {  # gateway_detect <outfile> — latch a short hold on a gateway 502 signature
  [[ -f "$1" && ! -f "$GATEWAY_HOLD" ]] || return 0          # one GATEWAY_HOLD line per event
  grep -qE '502 Request failed after [0-9]+ attempt|check your inference gateway' "$1" || return 0
  gateway_flap_latch                                         # FM-10: escalating hold + alert marker (W-2)
  echo "$(( $(date -u +%s) + FLAP_HOLD_S ))" > "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_HOLD | (breaker) | (dispatch paused) | gateway 502 storm detected in worker output — holding ${FLAP_HOLD_S}s${FLAP_COUNT:+ (flap $FLAP_COUNT in window — escalated, oracle alerted)}"
}

gateway_probe() {  # true unless an authenticated upstream round-trip returns 5xx — FM-7 gap (b):
  # explicitly NOT GET /v1/models (served locally, 200 in 0.8ms, stayed 200 throughout the storm).
  # POST /v1/messages with max_tokens=1 exercises the router's upstream fetch; ~1 output token.
  # FM-10 (W-2): a 5xx latches via gateway_flap_latch (escalating hold + alert marker); a CLEAN
  # round-trip clears the flap counter (recovery). A disabled/skipped probe does neither — no signal.
  [[ "${GATEWAY_PROBE:-0}" == "1" ]] || return 0             # config kill switch (ships ON)
  [[ -n "${ANTHROPIC_BASE_URL:-}" && -n "${ANTHROPIC_AUTH_TOKEN:-}" ]] || return 0  # absent → never block
  local code probe_model
  probe_model="${MODEL_CHAIN%% *}"                           # probe what we dispatch: first chain entry
  code=$(curl -s -m 20 -o /dev/null -w '%{http_code}' -X POST "${ANTHROPIC_BASE_URL}/v1/messages" \
    -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
    -H "x-api-key: ${ANTHROPIC_AUTH_TOKEN}" \
    -d "{\"model\":\"${probe_model}\",\"max_tokens\":1,\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}]}" 2>/dev/null)
  if ! [[ "$code" =~ ^5 ]]; then                             # 2xx/4xx = path healthy → recovery (FM-10)
    gateway_flap_clear
    return 0
  fi
  gateway_flap_latch                                         # 5xx = upstream dead → escalating hold (FM-10)
  echo "$(( $(date -u +%s) + FLAP_HOLD_S ))" > "$GATEWAY_HOLD"
  log_line "- $(today) $(ts) | 0s | GATEWAY_HOLD | (breaker) | (dispatch paused) | active probe got HTTP $code from gateway — holding ${FLAP_HOLD_S}s${FLAP_COUNT:+ (flap $FLAP_COUNT in window — escalated, oracle alerted)}"
  return 1
}

# ── Gateway FLAP memory (FM-10, W-2) ──
# Guard-5's fixed GATEWAY_HOLD_S hold has no memory across holds: during a PERSISTENT upstream
# degradation it loops latch → expire → clearing-wave probe 502 → re-latch ~9s after RESUMED,
# ~45-min period (measured both cycles 2026-08-01: expiry→clear +891s twice; same shape 07-29).
# Correct protection, ZERO visibility — a 90-min stall skips ~3 builder waves with nothing telling
# the human why (FM-7's regression check cannot fire: no deaths — the silence IS the symptom).
# Mirror of the FM-3/FM-7 breaker style: .gateway_flap counts holds inside GATEWAY_FLAP_WINDOW_S;
# the hold escalates ×2 per in-window repeat (capped); at count ≥2 the runner writes
# state/gateway_flap_alert, which oracle.sh surfaces as ONE line on the human's screen (the runner
# writes ONLY LOG/queue/state — _ORACLE-CURATED.md is hand-maintained per its own header, so the
# alert is marker-rendered, never appended there). Counter resets on a CLEAN authenticated probe
# (recovery) or an out-of-window latch. Kill switch GATEWAY_FLAP=0 → fixed hold, no counter, no
# marker (pre-fix), never a wedge. NO new LOG verdict token — the flap count rides the existing
# GATEWAY_HOLD message text → no four-counter classification needed (checklist item 12).
GATEWAY_FLAP_FILE="$HARNESS/.gateway_flap"                   # "<count> <last_latch_epoch> <first_latch_epoch>"
GATEWAY_FLAP_ALERT="$HARNESS/state/gateway_flap_alert"       # "<count> <first_latch_epoch> <last_latch_epoch>"

gateway_flap_latch() {  # called at BOTH hold latch sites (gateway_detect, gateway_probe). Sets
  # FLAP_HOLD_S (the escalated duration) + FLAP_COUNT (non-empty ONLY at count ≥2, for the log
  # suffix). In-window repeat (now − last ≤ GATEWAY_FLAP_WINDOW_S) → count++; out-of-window or
  # corrupt file → fresh series at 1 (self-heal, mirror the hold readers) + drop a stale marker.
  # hold = GATEWAY_HOLD_S × min(2^(count−1), GATEWAY_FLAP_CAP_MULT): 1800 → 3600 → 7200 → 7200…
  local now count last first cap mult
  now=$(date -u +%s); cap=${GATEWAY_FLAP_CAP_MULT:-4}
  FLAP_HOLD_S="$GATEWAY_HOLD_S"; FLAP_COUNT=""
  if [[ "${GATEWAY_FLAP:-1}" != "1" ]]; then                 # kill switch → pre-fix behavior, and
    rm -f "$GATEWAY_FLAP_ALERT"                              # drop any stale marker (oracle goes quiet)
    return 0
  fi
  count=1; last=0; first=$now
  [[ -f "$GATEWAY_FLAP_FILE" ]] && read -r count last first < "$GATEWAY_FLAP_FILE" 2>/dev/null
  if [[ "$count" =~ ^[0-9]+$ && "$last" =~ ^[0-9]+$ && "$first" =~ ^[0-9]+$ ]] && (( now - last <= ${GATEWAY_FLAP_WINDOW_S:-21600} )); then
    count=$(( count + 1 ))                                   # in-window repeat → flap
  else
    count=1; first=$now                                      # out-of-window / corrupt → fresh series
    rm -f "$GATEWAY_FLAP_ALERT"                              # drop a stale marker (recovery went unseen)
  fi
  echo "$count $now $first" > "$GATEWAY_FLAP_FILE"
  if (( count - 1 >= 16 )); then mult=$cap; else mult=$(( 1 << (count - 1) )); fi
  (( mult > cap )) && mult=$cap
  FLAP_HOLD_S=$(( GATEWAY_HOLD_S * mult ))
  if (( count >= 2 )); then
    FLAP_COUNT=$count
    echo "$count $first $now" > "$GATEWAY_FLAP_ALERT"        # rewrite-in-place, never stack
  fi
  return 0
}

gateway_flap_clear() {  # a CLEAN authenticated probe (gateway_probe's non-5xx path) = recovery:
  # reset the counter + drop the alert marker. Only a probe that actually round-tripped calls this —
  # a disabled/skipped probe carries no signal and never clears. Silent by design (no new LOG token):
  # recovery is already visible as the GATEWAY_RESUMED line + the ok dispatch that follows it.
  [[ "${GATEWAY_FLAP:-1}" == "1" ]] || return 0
  rm -f "$GATEWAY_FLAP_FILE" "$GATEWAY_FLAP_ALERT"
}

# ── Deferred re-dispatch hold (per-job breaker — FM-8 follow-up) ──
# A job that returns ok(DEFERRED) is waiting on a precondition NO cron wave can change (a
# detached extract finishing, a gate date passing). Until this breaker it was re-dispatched
# EVERY wave to re-check it — ROW-4 step-2 deferred 41× on the ~30-min builder cadence, the
# no-op burn that fed the 07-30 quota exhaust → ~26h dark. Mirror of the FM-3 quota / FM-7
# gateway holds, but PER-JOB (the FM-4 lesson — a global hold here would strand runnable
# siblings): deferred_hold() latches the job + expiry epoch in $DEFERRED_HOLD; deferred_held()
# suppresses re-dispatch of ONLY that job in every dispatch path (worker claim loop + both
# pick_builder_job passes), and Guard 6 (below the helpers) exits the whole wave on a cheap
# SKIP(DEFERRED_HOLD) only when the held job is the SOLE unchecked candidate.
DEFERRED_HOLD="$HARNESS/.deferred_hold"

deferred_hold_read() {  # populate DH_EPOCH + DH_JOB from the hold file; true iff a hold is ACTIVE.
  # Corrupt (non-numeric epoch) or expired hold → delete + return 1 (self-heal, like the
  # quota/gateway holds): the next dispatch re-checks the precondition from a clean slate.
  DH_EPOCH=0; DH_JOB=""
  [[ -f "$DEFERRED_HOLD" ]] || return 1
  DH_EPOCH=$(head -1 "$DEFERRED_HOLD" 2>/dev/null || echo 0)
  if ! [[ "$DH_EPOCH" =~ ^[0-9]+$ ]]; then rm -f "$DEFERRED_HOLD"; DH_EPOCH=0; return 1; fi
  if (( $(date -u +%s) >= DH_EPOCH )); then rm -f "$DEFERRED_HOLD"; DH_EPOCH=0; return 1; fi
  DH_JOB=$(tail -n +2 "$DEFERRED_HOLD" 2>/dev/null)
  return 0
}

deferred_held() {  # deferred_held <job-text> — true iff <job-text> is under an ACTIVE deferred
  # hold (exact match — never a substring, the FM-4b anchor lesson). Non-matching jobs, an
  # expired/corrupt hold, and no hold all return 1 (not held); self-heal happens in the read.
  deferred_hold_read || return 1
  [[ -n "$DH_JOB" && "$DH_JOB" == "$1" ]]
}

deferred_hold() {  # deferred_hold <job-text> — latch a per-job hold on an ok(DEFERRED) verdict.
  # One DEFERRED_HOLD line per event (mirror of quota_detect): an already-ACTIVE hold is left
  # alone (single-slot by design — concurrent distinct defers are rare; the first blocker keeps
  # its window, a later one simply re-defers once when this hold expires). Expired/corrupt is
  # cleared by deferred_hold_read and immediately re-latched for the new deferral.
  [[ -n "${1:-}" ]] || return 0
  deferred_hold_read && return 0
  { echo "$(( $(date -u +%s) + ${DEFERRED_HOLD_S:-3600} ))"; printf '%s\n' "$1"; } > "$DEFERRED_HOLD"
  log_line "- $(today) $(ts) | 0s | DEFERRED_HOLD | (breaker) | ${1} | ok(DEFERRED) — precondition not met; holding re-dispatch ${DEFERRED_HOLD_S:-3600}s (per-job; runnable siblings unaffected)"
}

fail_streak() {  # consecutive REAL (non-infra) fails for job "$1", from LOG
  awk -F'|' -v job="$1" '
    /^- / {
      v=$3; j=$5
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", j)
      sub(/^\[builder\][ \t]+/, "", j)  # builder-lane LOG lines prefix the job with "[builder] "
      if (j != job) next
      if (v == "ok") { s = 0; next }
      if (v == "BRIDGE" || v == "ok(DEFERRED)" || v == "REAPED" || v == "TIMEOUT(BUT_ARTIFACT)" || v == "DEFERRED_HOLD" || v == "SKIP(DEFERRED_HOLD)") next  # bookkeeping, not a real fail (FM-8 defer/reaper; FM-6 TIMEOUT(BUT_ARTIFACT) credit — the work LANDED, so it never counts toward quarantine; a BARE TIMEOUT is deliberately absent here so it still counts and still quarantines; DEFERRED_HOLD/SKIP(DEFERRED_HOLD) are the FM-8-follow-up per-job hold — a held job is NOT failing, it must never quarantine on its own hold lines)
      if ($6 ~ /ConnectionRefused|Unable to connect|PROXY_DOWN|429|rate.?limit|overloaded|quota|too many requests|503|upstream|502|fetch failed/) next  # infra (502|fetch failed added FM-7: a gateway storm must never false-quarantine queued jobs)
      s++
    }
    END { print s+0 }' "$LOG"
}

worker_timeout_promote() {  # worker_timeout_promote <job-text> — true iff this job's worker-lane
  # history (since its most recent ok) ends in a BARE TIMEOUT (FM-9). The first TIMEOUT(900s) is
  # already the evidence the job is too big for the worker lane — the claim loop stops claiming it
  # and pick_builder_job pass 1 picks it up, so the retry runs under BUILDER_BUDGET instead of
  # paying a second 900s to relearn the same lesson (2026-07-31: the FM-8-follow-up hold job burned
  # 2×900s on the worker lane before the builder lane did the SAME job in 1595s — the 3rd recurrence
  # of the FM-5 pattern after ROW-3 EXECUTE 07-26 and ROW-4 SCORE 07-29).
  #
  # MECHANICAL — decided from LOG VERDICT HISTORY, never from job-text keywords (the FM-4b lesson:
  # body-substring routing mis-routed the whole queue and deadlocked the engine ~4.5h). The match is
  # EXACT job text, same identity fail_streak uses: worker-lane LOG lines carry the raw job text in
  # field 5 while builder-lane lines prefix "[builder] ", so ONLY worker-lane timeouts trigger — a
  # builder-lane timeout is already on the right lane (it stays counted by fail_streak and still
  # quarantines after MAX_JOB_RETRIES; the promotion buys headroom, not immunity). TIMEOUT(BUT_ARTIFACT)
  # never triggers — the work LANDED (credited [x], no retry at all). An ok on EITHER lane clears the
  # flag, so a re-queued job starts fresh on the worker lane. Kill switch: TIMEOUT_PROMOTE=0
  # (config.env) reverts to pre-fix behavior (retries stay on the worker lane). SESSION_TIMEOUT
  # deliberately NOT raised — it guards the FM-2 trust-bug hang.
  [[ "${TIMEOUT_PROMOTE:-1}" == "1" ]] || return 1
  [[ -f "$LOG" ]] || return 1
  awk -F'|' -v job="$1" '
    /^- / {
      v=$3; j=$5
      gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", j)
      if (j == job) {                                  # worker-lane line (builder lines carry the prefix)
        if (v == "ok") { p = 0; next }                 # success clears — a re-queued job starts fresh
        if (v ~ /^TIMEOUT\(/ && v != "TIMEOUT(BUT_ARTIFACT)") { p = 1; next }   # bare timeout → promote
      }
      if (j == ("[builder] " job) && v == "ok") p = 0  # builder-lane success clears it too
    }
    END { exit (p ? 0 : 1) }' "$LOG"
}

artifact_gate() {  # artifact_gate <verdict> <produced> — echo "<verdict>|<mark>". FM-8 artifact
  # oracle: exit 0 means the process died cleanly, NOT that the deliverable landed (the SCORE
  # phantom: a 49s precondition-gated no-op exited 0 → ok → permanent [x], nothing written).
  # [x] requires verdict==ok AND (PRODUCED==NONE or the declared path exists). DEFERRED and a
  # missing/undeclared artifact rewrite the verdict to ok(DEFERRED)/ok(NO_ARTIFACT) and leave
  # the job [ ] — DEFERRED is bookkeeping (never quarantined); NO_ARTIFACT is a REAL fail
  # (quarantines after MAX_JOB_RETRIES).
  #
  # FM-6 follow-up (TIMEOUT credit): a TIMEOUT whose work demonstrably LANDED is the mirror
  # image of the SCORE phantom — there the verdict lied "done" (exit 0, no work); here it lies
  # "failed" (the kill fell AFTER the artifact landed). If the captured PRODUCED path exists (or
  # the collect phase's timeout_artifact mtime-in-window fallback supplied one because the kill
  # beat the marker), credit it: rewrite the verdict to TIMEOUT(BUT_ARTIFACT) and mark [x] via the
  # SAME path-existence check the ok-lane uses. A bare TIMEOUT (no artifact) is returned unchanged
  # → stays [ ] → re-dispatch + quarantine (the trust-bug guard stands; SESSION_TIMEOUT untouched).
  # TIMEOUT(BUT_ARTIFACT) is bookkeeping in all four counters (like ok(DEFERRED)); a bare TIMEOUT
  # is NOT in fail_streak's skip list, so it still counts as a REAL fail and still quarantines.
  local v="$1" p="$2"
  case "$v" in
    TIMEOUT*)                                            # timeout-lane: credit ONLY a landed artifact
      if [[ -n "$p" && "$p" != "NONE" && "$p" != "DEFERRED" && -e "$p" ]]; then
        printf '%s|[x]\n' "TIMEOUT(BUT_ARTIFACT)"        # work landed → credited, done, never re-dispatched
      else
        printf '%s|[ ]\n' "$v"                           # bare timeout (NONE/missing/no marker) → stays queued
      fi
      return ;;
  esac
  if [[ "$v" != "ok" ]]; then printf '%s|[ ]\n' "$v"; return; fi
  case "$p" in
    NONE)     printf '%s|[x]\n' "ok" ;;                  # declared no-file deliverable — trusted, done
    DEFERRED) printf '%s|[ ]\n' "ok(DEFERRED)" ;;        # precondition not met — stays queued, never a fail
    "")       printf '%s|[ ]\n' "ok(NO_ARTIFACT)" ;;     # no PRODUCED marker — unverified, stays queued
    *)        if [[ -e "$p" ]]; then printf '%s|[x]\n' "ok"
              else printf '%s|[ ]\n' "ok(NO_ARTIFACT)"; fi ;;   # declared path missing — stays queued
  esac
}

timeout_artifact() {  # timeout_artifact <wave_start_epoch> — echo a durable .md path IFF EXACTLY ONE
  # landed in THIS wave's window [wave_start, now+MARGIN], else nothing. FM-6 follow-up: the secondary
  # TIMEOUT credit for when the kill beat the PRODUCED marker (the artifact landed, the marker didn't).
  # Two guards make it phantom-proof: (a) the lower bound is the WAVE START (sampled before dispatch), so
  # a PRIOR wave's artifact (mtime < wave_start) can never be credited to this session — mtime and the
  # bound are the same kernel clock, so no backward slack is needed (any slack would re-admit the previous
  # wave's last write — a phantom credit, the very thing FM-8 forbids); (b) EXACTLY-ONE — with >1 in-window
  # artifact (parallel siblings in THIS wave wrote too) attribution is ambiguous → no credit → the job
  # re-dispatches (current behavior — no regression, never a false [x]). Only consulted on a TIMEOUT with
  # no captured marker; the path returned is fed to artifact_gate, which does the existence check and the
  # [x]. find's @epoch is TZ-absolute; a parse failure yields nothing (2>/dev/null) → safe bare timeout.
  local lo="$1" margin=90 hi
  local -a found=()
  hi=$(( $(date -u +%s) + margin ))
  mapfile -t found < <(find wiki projects journal inbox .forge -name '*.md' \
    -newermt "@$lo" ! -newermt "@$hi" 2>/dev/null)
  (( ${#found[@]} == 1 )) && printf '%s\n' "${found[0]}"
}

job_lane() {  # job_lane <job-text> — echo "builder" if the job belongs on the builder lane, else "worker"
  local j="$1"
  printf '%s' "$j" | grep -qiE '^[[:space:]]*(\[[^]]*\][[:space:]]+)?\[builder\]' && { echo builder; return; }  # explicit opt-in tag as a LEADING token (bare, or right after the [Role] prefix) — never a substring
  if [[ -n "${BUILDER_ROUTE_PATTERN:-}" ]] && printf '%s' "$j" | grep -qE "$BUILDER_ROUTE_PATTERN"; then
    echo builder; return                             # role+keyword auto-detect (tuned in config.env)
  fi
  echo worker
}

builder_jobs_pending() {  # true if any unchecked queue job routes to the builder lane — or was
  # PROMOTED to it (FM-9): a sole promoted job must take the SKIP(BUILDER_WAIT)/fall-through path,
  # not the bridge/reflection branches (which would strand it, the FM-4a deadlock shape).
  local j
  while IFS= read -r j; do
    { [[ "$(job_lane "$j")" == "builder" ]] || worker_timeout_promote "$j"; } && return 0
  done < <(grep -E '^- \[ \] ' "$QUEUE" | sed 's/^- \[ \] //')
  return 1
}

serial_lane_this_wave() {  # true if the every-Nth-wave section below fires this wave (council OR builder)
  [[ -f "$QUOTA_HOLD" || -f "$GATEWAY_HOLD" ]] && return 1   # suppressed under quota/gateway hold — mirrors the gate below
  if (( COUNCIL_EVERY > 0 )) && (( wave % COUNCIL_EVERY == 0 )) && [[ "${COUNCIL_ENABLED:-0}" == "1" ]]; then
    return 0                                         # council wins the wave — fall through so it still runs
  fi
  (( BUILDER_EVERY > 0 )) && (( wave % BUILDER_EVERY == 0 ))
}

pick_builder_job() {  # echo the next builder-lane job: a clean routed job — or one PROMOTED after a
  # bare worker-lane TIMEOUT (FM-9) — first, else the top clean unchecked job.
  # The fail_streak breaker mirrors the worker claim loop, so one
  # perpetually-timing-out builder job can't block the whole lane forever (2026-07-27: ROW-4
  # timed out twice and, with no breaker here, would have wedged the builder lane permanently).
  local j streak
  while IFS= read -r j; do                                     # pass 1: routed builder jobs + FM-9 worker-timeout promotions
    [[ "$(job_lane "$j")" == "builder" ]] || worker_timeout_promote "$j" || continue
    streak=$(fail_streak "$j")
    if (( streak >= MAX_JOB_RETRIES )); then
      mark_job "$j" '- [!] '
      log_line "- $(today) $(ts) | 0s | QUARANTINED | (breaker) | [builder] ${j} | ${streak} consecutive fails — [!], builder lane advanced; META-REVIEW to triage"
      echo "[$(ts)] quarantined builder job after ${streak} fails: ${j}" >&2
      continue
    fi
    if deferred_held "$j"; then                                # FM-8 follow-up: per-job hold on the builder lane
      log_line "- $(today) $(ts) | 0s | SKIP(DEFERRED_HOLD) | (breaker) | [builder] ${j} | precondition re-check held — builder-lane job preserved [ ] (this is the lane ROW-4 step-2 churned on)"
      echo "[$(ts)] skip: deferred hold for builder-lane job: ${j}" >&2
      continue
    fi
    printf '%s\n' "$j"; return
  done < <(grep -E '^- \[ \] ' "$QUEUE" | sed 's/^- \[ \] //')
  while IFS= read -r j; do                                     # pass 2: legacy top-unchecked fallback, breaker-guarded
    streak=$(fail_streak "$j")
    if (( streak >= MAX_JOB_RETRIES )); then
      mark_job "$j" '- [!] '
      log_line "- $(today) $(ts) | 0s | QUARANTINED | (breaker) | ${j} | ${streak} consecutive fails — [!], queue advanced; META-REVIEW to triage"
      echo "[$(ts)] quarantined after ${streak} fails: ${j}" >&2
      continue
    fi
    if deferred_held "$j"; then                                # FM-8 follow-up: per-job hold (fallback pass)
      log_line "- $(today) $(ts) | 0s | SKIP(DEFERRED_HOLD) | (breaker) | ${j} | precondition re-check held — job preserved [ ]"
      echo "[$(ts)] skip: deferred hold for job: ${j}" >&2
      continue
    fi
    printf '%s\n' "$j"; return
  done < <(grep -E '^- \[ \] ' "$QUEUE" | sed 's/^- \[ \] //')
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

# ── Guard 6: deferred re-dispatch hold — sole-candidate wave exit (FM-8 follow-up) ──
# The quota/gateway holds are GLOBAL (no session can run); this one is PER-JOB — the FM-4
# lesson is that an over-broad hold strands runnable work. So the whole wave exits here ONLY
# when the held job is the SOLE unchecked candidate; with any sibling pending, control falls
# through and the claim loop / pick_builder_job skip just the held job while siblings dispatch.
# Placed after the helpers (it calls deferred_hold_read) and before the probe + wave counter,
# so a fully-held wave burns ~0 tokens (not even the probe's) and — like the quota/gateway
# holds — does not advance the wave counter (cadence resumes when the hold expires).
if deferred_hold_read; then
  mapfile -t _unchecked < <(grep -E '^- \[ \] ' "$QUEUE" 2>/dev/null)
  if (( ${#_unchecked[@]} == 1 )) && [[ "${_unchecked[0]:6}" == "$DH_JOB" ]]; then   # :6 strips the fixed 6-char '- [ ] ' prefix (${var#- [ ] } is a glob char-class and fails — see claim loop)
    log_line "- $(today) $(ts) | 0s | SKIP(DEFERRED_HOLD) | (breaker) | ${DH_JOB} | precondition re-check held — sole candidate deferred until $(date -u -d "@$DH_EPOCH" '+%Y-%m-%d %H:%M')Z ($(( (DH_EPOCH - $(date -u +%s)) / 60 ))m), wave skipped, job preserved [ ]"
    echo "[$(ts)] skip: deferred hold — sole candidate held until $(date -u -d "@$DH_EPOCH" '+%Y-%m-%d %H:%M')Z" >&2
    exit 0
  fi
fi

# ── Guard 5b: active gateway probe (once per wave, before any dispatch) ──
# The reactive detector (gateway_detect, collect phase) is the backstop; this catches a
# burst BEFORE any session burns. On 5xx it latches the hold itself and the wave exits 0
# with jobs preserved. Probes an INSTANT — bursts are ~5min, so a session can still hit
# the next burst; hence the reactive detector stays (FM-7 §4 secondary).
if ! gateway_probe; then
  log_line "- $(today) $(ts) | 0s | SKIP(GATEWAY) | (probe) | (no job attempted) | active probe got 5xx from ${ANTHROPIC_BASE_URL:-gateway} — hold latched, wave skipped, jobs preserved"
  echo "[$(ts)] skip: gateway probe failed — hold latched" >&2
  exit 0
fi

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
      log_line "- $(today) $(ts) | 0s | QUARANTINED | (breaker) | ${job} | ${streak} consecutive fails — [!], queue advanced; META-REVIEW to triage"
      echo "[$(ts)] quarantined after ${streak} fails: ${job}" >&2
      continue
    fi
    if (( BUILDER_EVERY > 0 )) && [[ "$(job_lane "$job")" == "builder" ]]; then
      echo "[$(ts)] defer to builder lane: ${job}" >&2
      continue                                     # data-heavy job — don't burn the worker's SESSION_TIMEOUT on it
    fi
    if (( BUILDER_EVERY > 0 )) && worker_timeout_promote "$job"; then
      echo "[$(ts)] promote to builder lane (first worker TIMEOUT): ${job}" >&2
      continue                                     # FM-9: the first bare TIMEOUT is the evidence the job is too big — the retry runs under BUILDER_BUDGET, never a second 900s (gated on BUILDER_EVERY>0 so it can't strand when the builder lane is off)
    fi
    if deferred_held "$job"; then                  # FM-8 follow-up: per-job hold — skip ONLY this job
      log_line "- $(today) $(ts) | 0s | SKIP(DEFERRED_HOLD) | (breaker) | ${job} | precondition re-check held — worker-lane job preserved [ ], runnable siblings still dispatch"
      echo "[$(ts)] skip: deferred hold for worker-lane job: ${job}" >&2
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
# Unthrottled, an empty queue re-fires this every tick (~96/day), burning the daily
# cap on near-duplicate notes (2026-07-21: 11 consecutive asset-less firings).
if (( ${#J_JOB[@]} == 0 )); then
  # ── Builder-lane jobs pending? The claim loop above defers them, so they dispatch ONLY
  #    in the builder section below — bridge/throttle-exiting here strands them forever.
  #    The 2026-07-27 deadlock: a builder-only queue logged SKIP(EMPTY_QUEUE) for ~6h while
  #    ROW-4 EXECUTE + INDEX SWEEP [builder] sat unchecked, and the bridge merged two MORE
  #    proposals into the same deadlock. Fall through on a wave that fires the serial
  #    section; else WAIT — no bridge merge while jobs are stranded, no reflection (the
  #    queue is NOT empty, it just holds builder-lane work).
  if (( BUILDER_EVERY > 0 )) && builder_jobs_pending; then
    if serial_lane_this_wave; then
      echo "[$(ts)] builder-lane jobs pending — falling through to the serial section (no bridge, no reflection)" >&2
    else
      log_line "- $(today) $(ts) | 0s | SKIP(BUILDER_WAIT) | (throttle) | (no job attempted) | worker lane empty but builder-lane jobs pending — next builder wave (BUILDER_EVERY=$BUILDER_EVERY) dispatches them; no bridge merge while stranded"
      echo "[$(ts)] skip: builder-lane jobs wait for the next builder wave" >&2
      exit 0
    fi
  # ── Bridge: self-feed from proposals.md (added 2026-07-22, firing #16). Workers are
  #    read-only on queue.md, so empty-queue Steward reflections stage jobs in proposals.md;
  #    the runner (sole substrate writer) merges the top pending one each empty wave and it
  #    runs next wave. Production beats reflection — a merged wave exits without a Steward
  #    firing. Ends the 24h deadlock where reflections #12–#15 re-proposed the same 3 jobs
  #    with no append path (idle since the throttle patch, 07-21 12:03Z).
  elif [[ -f "$HARNESS/proposals.md" ]] && grep -qE '^- \[ \] ' "$HARNESS/proposals.md"; then
    pj=$(grep -m1 -E '^- \[ \] ' "$HARNESS/proposals.md" | sed 's/^- \[ \] //')
    printf '%s\n' "- [ ] $pj" >> "$QUEUE"
    mark_proposal "$pj"
    log_line "- $(today) $(ts) | 0s | BRIDGE | (runner) | ${pj} | merged top proposal into queue.md — runs next wave"
    echo "[$(ts)] bridge: merged proposal into queue.md: ${pj}" >&2
    exit 0
  else
    now=$(date -u +%s); last=$(cat "$HARNESS/state/last-reflect" 2>/dev/null || echo 0)
    if (( now - last >= ${REFLECT_EVERY:-21600} )); then
      reflect_job="[Steward] Queue is empty and no proposals are pending. Review LOG.md for the last 24h: summarize what compounded, flag any repeated failures, and stage 3 new jobs as '- [ ]' lines in _harness/proposals.md (the runner auto-merges them into queue.md — do NOT edit queue.md). Keep it short."
      # Breaker parity (FM-7 gap (c)): the reflection used to append straight to J_JOB,
      # bypassing the claim-loop breaker — 07-28 re-fired 4 consecutive fails every cycle.
      # 502 storm fails are infra (streak stays 0 — the GATEWAY hold/probe guards those);
      # this catches REAL non-infra Steward failures, same as every other dispatch path.
      streak=$(fail_streak "$reflect_job")
      if (( streak >= MAX_JOB_RETRIES )); then
        echo "$now" > "$HARNESS/state/last-reflect"          # consume the window — re-check at the throttle cadence, not every tick
        log_line "- $(today) $(ts) | 0s | SKIP(REFLECTION_QUARANTINE) | (breaker) | ${reflect_job} | ${streak} consecutive REAL fails — reflection not staged this cycle; META-REVIEW to triage"
        echo "[$(ts)] skip: reflection quarantined after ${streak} consecutive fails" >&2
        exit 0
      fi
      echo "$now" > "$HARNESS/state/last-reflect"
      J_JOB+=("$reflect_job")
      J_LINE+=("")
    else
      log_line "- $(today) $(ts) | 0s | SKIP(EMPTY_QUEUE) | (throttle) | (no job attempted) | empty queue, reflected $(( (now-last)/60 ))m ago (< ${REFLECT_EVERY:-21600}s) — throttled"
      echo "[$(ts)] skip: empty queue, reflection throttled" >&2
      exit 0
    fi
  fi
fi

# ── Snapshot the shared substrate for detect-and-revert (workers must not edit it) ──
snap="$HARNESS/state/substrate"; mkdir -p "$snap"
for f in INDEX.md MEMORY.md; do cp -f "$VAULT/$f" "$snap/$f" 2>/dev/null; done

# ── Fork workers: each in its own session/PGID, self-bounded by WORKER_BUDGET ──
cleanup() {  # kill any live worker groups on dispatcher exit (normal or signalled)
  for pf in "$HARNESS/state"/worker-*.pid; do
    [[ -e "$pf" ]] || continue
    pg=$(cat "$pf" 2>/dev/null)
    slot="${pf##*/worker-}"; slot="${slot%.pid}"
    rjob=$(cat "$HARNESS/state/worker-$slot.job" 2>/dev/null || true)   # FM-8: read BEFORE kill (SIGTERM runs the worker's trap, which deletes the sidecar)
    if [[ -n "$pg" ]] && kill -- "-$pg" 2>/dev/null; then
      log_line "- $(today) $(ts) | 0s | REAPED | (reaper) | ${rjob:-(unknown job)} | orphan killed on dispatcher exit — work (if any) unrecorded, job preserved [ ]"   # FM-8: no kill is silent
    fi
  done
}
trap cleanup EXIT
trap 'exit 143' TERM HUP INT

# FM-6 follow-up: wave start epoch, the lower bound of timeout_artifact's mtime window — sampled
# BEFORE dispatch so a prior wave's artifact (mtime < WAVE_START) can never be credited to this
# wave's timed-out session (the cross-wave phantom the sandbox caught; same kernel clock, no slack).
WAVE_START=$(date -u +%s)

declare -a PIDS=()
for i in "${!J_JOB[@]}"; do
  rm -f "$HARNESS/state/worker-$i.verdict" "$HARNESS/state/worker-$i.out" "$HARNESS/state/worker-$i.job"   # FM-8: collect must never read a STALE verdict
  setsid --wait bash "$HARNESS/worker.sh" "$i" "${J_JOB[$i]}" \
    > "$HARNESS/state/worker-$i.err" 2>&1 &
  PIDS[$i]=$!
done
wait "${PIDS[@]}" 2>/dev/null        # bounded: each worker self-bounds to WORKER_BUDGET

# ── Substrate integrity: revert any shared file a worker touched ──
for f in INDEX.md MEMORY.md; do
  if [[ -f "$snap/$f" ]] && ! cmp -s "$VAULT/$f" "$snap/$f" 2>/dev/null; then
    cp -f "$snap/$f" "$VAULT/$f"
    log_line "- $(today) $(ts) | 0s | SUBSTRATE_VIOLATION | (guard) | ${f} | a worker edited shared substrate — reverted to pre-wave snapshot"
  fi
done

# ── Collect: log ONE line per worker, mark done the ok ones (serial, single writer) ──
for i in "${!J_JOB[@]}"; do
  verdict=""; used_model="(none)"; dur=0; produced=""
  read -r verdict used_model dur produced < "$HARNESS/state/worker-$i.verdict" 2>/dev/null || true
  [[ -z "$verdict" ]] && verdict="exit(no-verdict)"
  summary=$(grep -vE '^\s*$' "$HARNESS/state/worker-$i.out" 2>/dev/null | grep -vE '^[[:space:]]*PRODUCED:' | tail -1 | sed -E 's/^(.{0,200}).*/\1/')   # FM-8: skip the PRODUCED marker (the session's last line), char-safe slice (cut -c cut BYTES → truncated chars poisoned LOG)
  [[ -z "$summary" ]] && summary="(no output captured)"
  quota_detect "$HARNESS/state/worker-$i.out"
  gateway_detect "$HARNESS/state/worker-$i.out"
  if [[ "$verdict" == TIMEOUT* && -z "$produced" ]]; then
    produced="$(timeout_artifact "$WAVE_START")"    # FM-6: the kill beat the marker — recover the artifact by mtime-in-window
  fi
  IFS='|' read -r verdict mark <<< "$(artifact_gate "$verdict" "$produced")"   # FM-8 artifact oracle
  log_line "- $(today) $(ts) | ${dur}s | ${verdict} | ${used_model} | ${J_JOB[$i]} | ${summary}" \
    && [[ "$mark" == "[x]" && -n "${J_LINE[$i]}" ]] && mark_job "${J_JOB[$i]}" '- [x] '   # FM-8: log BEFORE mark; mark only on a real artifact
  [[ "$verdict" == "ok(DEFERRED)" ]] && deferred_hold "${J_JOB[$i]}"   # FM-8 follow-up: latch the per-job hold so this job isn't re-dispatched every wave
  rm -f "$HARNESS/state/worker-$i.verdict" "$HARNESS/state/worker-$i.err" "$HARNESS/state/worker-$i.job"
done

# ── Every-Nth-wave branches, SERIAL after workers (sole substrate writer in phase) ──
# Builder and council are mutually exclusive to bound per-wave cost; council wins on its wave.
# Suppressed under a quota/gateway hold — they'd die on the same 429/502 the workers just latched on.
if [[ -f "$QUOTA_HOLD" || -f "$GATEWAY_HOLD" ]]; then
  echo "[$(ts)] skip: builder/council suppressed under quota/gateway hold" >&2
elif (( COUNCIL_EVERY > 0 )) && (( wave % COUNCIL_EVERY == 0 )) && [[ "${COUNCIL_ENABLED:-0}" == "1" ]]; then
  bash "$HARNESS/council.sh" "$wave" || echo "[$(ts)] council wave $wave failed" >&2
elif (( BUILDER_EVERY > 0 )) && (( wave % BUILDER_EVERY == 0 )); then
  # one bigger session with a larger turn budget. Prefer a job routed to the builder lane
  # ([builder] tag or BUILDER_ROUTE_PATTERN) — workers skip those in the claim loop, so the
  # builder is their only runner; else fall back to the top unchecked job (legacy behavior).
  bj=$(pick_builder_job)
  if [[ -n "$bj" ]]; then
    rm -f "$HARNESS/state/worker-builder.verdict" "$HARNESS/state/worker-builder.out" "$HARNESS/state/worker-builder.job"   # FM-8: never collect a STALE verdict
    setsid --wait bash "$HARNESS/worker.sh" builder "$bj" "$BUILDER_MAX_TURNS" "$BUILDER_BUDGET" \
      > "$HARNESS/state/worker-builder.err" 2>&1
    verdict=""; used_model="(none)"; dur=0; produced=""
    read -r verdict used_model dur produced < "$HARNESS/state/worker-builder.verdict" 2>/dev/null || true
    [[ -z "$verdict" ]] && verdict="exit(no-verdict)"
    summary=$(grep -vE '^\s*$' "$HARNESS/state/worker-builder.out" 2>/dev/null | grep -vE '^[[:space:]]*PRODUCED:' | tail -1 | sed -E 's/^(.{0,200}).*/\1/')   # FM-8: skip the PRODUCED marker, char-safe slice
    quota_detect "$HARNESS/state/worker-builder.out"
    gateway_detect "$HARNESS/state/worker-builder.out"
    if [[ "$verdict" == TIMEOUT* && -z "$produced" ]]; then
      produced="$(timeout_artifact "$WAVE_START")"  # FM-6: the kill beat the marker — recover the artifact by mtime-in-window
    fi
    IFS='|' read -r verdict mark <<< "$(artifact_gate "$verdict" "$produced")"   # FM-8 artifact oracle
    log_line "- $(today) $(ts) | ${dur}s | ${verdict} | ${used_model} | [builder] ${bj} | ${summary:-(no output)}" \
      && [[ "$mark" == "[x]" ]] && mark_job "$bj" '- [x] '   # FM-8: log BEFORE mark; mark only on a real artifact
    [[ "$verdict" == "ok(DEFERRED)" ]] && deferred_hold "$bj"   # FM-8 follow-up: latch the per-job hold (builder lane — where ROW-4 step-2 churned)
    rm -f "$HARNESS/state/worker-builder.verdict" "$HARNESS/state/worker-builder.err" "$HARNESS/state/worker-builder.job"
  fi
fi

echo "[$(ts)] wave $wave done: ${#J_JOB[@]} workers" >&2
