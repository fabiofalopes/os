#!/usr/bin/env bash
# ── Forge daily rollup (the CALENDAR layer) ──
# LOG.md is the CLOCK (every tick, append-only). evaluate.sh scores ONE day. This is the
# calendar that remembers ACROSS days: one row per day in _harness/state/rollup.csv, so
# the success-rate TREND accumulates and META-REVIEW can read the arc ("rate climbing",
# "EMPTY sessions piling up") instead of re-deriving from LOG.md every time.
# Idempotent by date — re-running a day replaces its row, never duplicates. No tokens.
#
# Usage:
#   bash rollup.sh [YYYY-MM-DD]   upsert that day's row (default: today)
#   bash rollup.sh trend [N]      print the last N days (default 14) as a table
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
mkdir -p "$HARNESS/state"
CSV="$HARNESS/state/rollup.csv"
HDR="date,runs,success,empty,fail,infra,rate_pct"
[[ -f "$CSV" ]] || echo "$HDR" > "$CSV"

if [[ "${1:-}" == "trend" ]]; then
  n="${2:-14}"
  { head -1 "$CSV"; grep -v '^date,' "$CSV" | tail -n "$n"; } | column -s, -t
  exit 0
fi

day="${1:-$(date -u +%F)}"
eval_out=$(bash "$SCRIPT_DIR/evaluate.sh" "$day")
counts=$(printf '%s\n' "$eval_out" | sed -n '2p')
S=$(printf '%s' "$counts" | sed -nE 's/.*SUCCESS[[:space:]]+([0-9]+).*/\1/p')
E=$(printf '%s' "$counts" | sed -nE 's/.*EMPTY[[:space:]]+([0-9]+).*/\1/p')
F=$(printf '%s' "$counts" | sed -nE 's/.*FAIL[[:space:]]+([0-9]+).*/\1/p')
I=$(printf '%s' "$counts" | sed -nE 's/.*INFRA[[:space:]]+([0-9]+).*/\1/p')
rate=$(printf '%s\n' "$eval_out" | sed -n '3p' | sed -nE 's/.*=[[:space:]]*([0-9]+)%.*/\1/p')
real=$(( ${S:-0} + ${E:-0} + ${F:-0} ))
row="$day,$real,${S:-0},${E:-0},${F:-0},${I:-0},${rate:-0}"

# idempotent upsert: drop any existing row for this date, append the fresh one
{ head -1 "$CSV"; grep -v "^$day," <(grep -v '^date,' "$CSV"); echo "$row"; } > "$CSV.tmp"
mv "$CSV.tmp" "$CSV"
echo "$row"
