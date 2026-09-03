#!/usr/bin/env bash
# vault-sync.sh — GitHub layer of the vault mirror (vaultcraft sync.sh pattern)
# Vault = canonical repo. pull --rebase → commit → push. Conflict-safe, flock-guarded.
set -euo pipefail

VAULT="/home/fabio/obsidian-vault-kali"
STATE_DIR="$VAULT/_sync/state"
STATUS="$VAULT/_sync/STATUS.md"
LOG="$STATE_DIR/vault-sync.log"
VERB="${1:-status}"

mkdir -p "$STATE_DIR"
cd "$VAULT"

mark_status() { # $1 = result, $2 = detail
  local ts result detail; ts="$(date -Is)"; result="$1"; detail="$2"
  if [[ -f "$STATUS" ]] && head -n1 "$STATUS" | grep -q '^---$'; then
    python3 - "$STATUS" "$ts" "$result" "$detail" <<'PY'
import sys, re
p, ts, result, detail = sys.argv[1:5]
text = open(p).read()
end = text.index("\n---", 3)
fm, body = text[:end], text[end:]
for k, v in (("github_last_run", ts), ("github_result", result), ("github_detail", detail)):
    pat = re.compile(rf"(?m)^{k}:.*$")
    row = f'{k}: "{v}"'
    fm = pat.sub(row, fm) if pat.search(fm) else fm + "\n" + row
open(p, "w").write(fm + body)
PY
  else
    printf -- '---\ngithub_last_run: "%s"\ngithub_result: "%s"\ngithub_detail: "%s"\n---\n\n# Sync STATUS\n' "$ts" "$result" "$detail" > "$STATUS"
  fi
}

log() { printf '%s %s\n' "$(date -Is)" "$*" >> "$LOG"; }

case "$VERB" in
  status)
    echo "remote: $(git remote -v | head -n1 || echo none)"
    echo "dirty files: $(git status --porcelain | wc -l)"
    [[ -f "$STATUS" ]] && grep -E "^github_" "$STATUS" || echo "github: never run"
    exit 0 ;;
  run)
    if [[ -z "$(git remote -v)" ]]; then
      mark_status "skipped" "no remote configured"
      log "SKIP no-remote"
      echo "SKIP: no git remote configured (human adds: git remote add origin git@github.com:fabiofalopes/<repo>.git)"; exit 0
    fi
    exec 9>/tmp/vault-git.lock; flock -n 9 || { log "SKIP locked"; echo "SKIP: another sync holds the lock"; exit 0; }
    if ! git pull --rebase --autostash >/tmp/vault-pull.out 2>&1; then
      mark_status "conflict" "rebase failed — manual: git rebase --abort / status"
      log "FAIL rebase"; cat /tmp/vault-pull.out; exit 1
    fi
    if [[ -n "$(git status --porcelain)" ]]; then
      git add -A
      git commit -m "vault-sync: auto snapshot $(date -Iseconds)" --quiet || true
    fi
    if git push --quiet 2>/tmp/vault-push.out; then
      mark_status "ok" "pushed"
      log "OK pushed"; echo "OK: pushed"
    else
      mark_status "error" "push failed (auth/network) — see _sync/state/vault-sync.log"
      log "FAIL push: $(cat /tmp/vault-push.out)"; cat /tmp/vault-push.out; exit 1
    fi ;;
  *) echo "usage: vault-sync.sh run|status"; exit 2 ;;
esac
