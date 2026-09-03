#!/usr/bin/env bash
# pairs-sync.sh — Ordo layer: rclone bisync vault <-> system folders/cloud remotes
# Robust anti-resurrection set per rclone docs (2026-07): --resilient --recover
# --max-lock 2m --conflict-resolve newer. --resync is HUMAN-ONLY (init verb).
# NOTE: --max-delete is an absolute COUNT fuse on rclone v1.75.0 (percent not
# accepted by this binary despite docs) — 20 deletions/run max, else abort.
set -euo pipefail

VAULT="/home/fabio/obsidian-vault-kali"
CONF="$VAULT/_sync/pairs.conf"
FILTERS="$VAULT/_sync/filters.txt"
STATE_DIR="$VAULT/_sync/state"
BACKUPS="$VAULT/_sync/backups"
STATUS="$VAULT/_sync/STATUS.md"
WORKDIR="$HOME/.cache/rclone/bisync-vault"
VERB="${1:-status}"

mkdir -p "$STATE_DIR" "$BACKUPS"

need_rclone() { # resolve rclone even under cron/systemd (their PATH lacks ~/bin)
  RCLONE="$(command -v rclone 2>/dev/null || true)"
  [[ -z "$RCLONE" && -x "$HOME/bin/rclone" ]] && RCLONE="$HOME/bin/rclone"
  [[ -n "$RCLONE" ]] || { echo "FAIL: rclone not found (PATH or ~/bin/rclone) — install first"; exit 1; }
}

flags_for() { # $1 = pair name → robust flag set + per-side backups + filters
    printf -- '--resilient --recover --max-lock 2m --conflict-resolve newer --max-delete 20 --filters-file %s --backup-dir1 %s/%s/path1-backup --backup-dir2 %s/%s/path2-backup --workdir %s' \
    "$FILTERS" "$BACKUPS" "$1" "$BACKUPS" "$1" "$WORKDIR"
}

status_mark() { # $1 pair, $2 result, $3 detail — insert/update keys INSIDE frontmatter
  local pair="$1" result="$2" detail="$3" ts; ts="$(date -Is)"
  python3 - "$STATUS" "$pair" "$ts" "$result" "$detail" <<'PY'
import sys, re
p, pair, ts, result, detail = sys.argv[1:6]
text = open(p).read()
if not text.startswith("---"):
    text = '---\n---\n\n# Sync STATUS\n\n> Rewritten by _sync scripts. Do not edit by hand.\n'
end = text.index("\n---", 3)  # closing frontmatter delimiter
fm, body = text[:end], text[end:]
for k, v in ((f"pair_{pair}_last", ts), (f"pair_{pair}_result", result), (f"pair_{pair}_detail", detail)):
    pat = re.compile(rf"(?m)^{k}:.*$")
    row = f'{k}: "{v}"'
    fm = pat.sub(row, fm) if pat.search(fm) else fm + "\n" + row
open(p, "w").write(fm + body)
PY
}

pairs() { grep -vE '^\s*(#|$)' "$CONF" 2>/dev/null | while IFS='|' read -r name p1 p2 enabled extra; do
  [[ "$enabled" != "on" ]] && continue
  printf '%s|%s|%s|%s\n' "$name" "$p1" "$p2" "$extra"
done; }

case "$VERB" in
  list)
    echo "# name | path1 | path2 | enabled | extra — from pairs.conf"
    cat "$CONF" 2>/dev/null | grep -vE '^\s*$' || echo "(no pairs.conf)" ;;
  init) # HUMAN-ONLY first resync: pairs-sync.sh init <pairname>
    need_rclone
    want="${2:?usage: pairs-sync.sh init <pairname>}"
    while IFS='|' read -r name p1 p2 enabled extra; do
      [[ "$name" == "$want" ]] || continue
      echo "INIT $name (resync, interactive — check the dry-run output!)"
      # shellcheck disable=SC2086
      "$RCLONE" bisync --resync --resync-mode newer $(flags_for "$name") "$p1" "$p2" -v || exit 1
      status_mark "$name" "initialized" "resync done"
      exit 0
    done < <(grep -vE '^\s*(#|$)' "$CONF")
    echo "pair not found: $want"; exit 1 ;;
  run)
    need_rclone
    n=0
    while IFS='|' read -r name p1 p2 extra; do
      n=$((n+1))
      exec 8>/tmp/vault-bisync-"$name".lock
      if ! flock -n 8; then echo "SKIP $name (locked)"; continue; fi
      log="$STATE_DIR/pair-$name.log"
      # shellcheck disable=SC2086
      if "$RCLONE" bisync $(flags_for "$name") "$p1" "$p2" $extra >>"$log" 2>&1; then
        status_mark "$name" "ok" "synced"; echo "OK $name"
      else
        rc=$?
        if [[ $rc -eq 3 || $rc -eq 6 ]]; then
          status_mark "$name" "needs-init" "bisync rc=$rc — run: bash _sync/pairs-sync.sh init $name"
          echo "NEEDS-INIT $name (rc=$rc)"
        else
          status_mark "$name" "error" "bisync rc=$rc — see _sync/state/pair-$name.log"
          echo "ERROR $name (rc=$rc)"
        fi
      fi
    done < <(pairs)
    if [[ $n -eq 0 ]]; then echo "no enabled pairs in pairs.conf — nothing to do"; fi
    exit 0 ;;
  status)
    [[ -f "$STATUS" ]] && grep -E "^pair_" "$STATUS" || echo "pairs: never run"
    need_rclone && echo "rclone: $("$RCLONE" version | head -n1)" ;;
  *) echo "usage: pairs-sync.sh list|init <pair>|run|status"; exit 2 ;;
esac
