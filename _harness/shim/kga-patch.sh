#!/usr/bin/env bash
# ── kga-patch.sh — point Knowledge Graph Analysis's hardcoded Gemini endpoint
# at OUR gemini-shim (:8706 → router :8705 → POP fleet). STAGED FOR THE HUMAN:
# .obsidian/ is human territory — agents never edit it directly. (2026-09-06)
#
#   bash kga-patch.sh apply     # sed GEMINI_API_BASE in KGA main.js
#   bash kga-patch.sh revert    # restore the .bak
#   bash kga-patch.sh status    # show current endpoint
# Caveat: plugin UPDATES overwrite main.js — re-run apply after updating KGA.
# Shim must be running:  python3 _harness/shim/gemini_shim.py  (or the systemd
# unit you prefer). No Google key needed — shim accepts and ignores ?key=.
set -uo pipefail
KGA="$HOME/obsidian-vault-kali/.obsidian/plugins/knowledge-graph-analysis/main.js"
BAK="$KGA.gemini-orig.bak"
SHIM_URL='http://127.0.0.1:8706/v1beta'
case "${1:-status}" in
  status)
    grep -o 'GEMINI_API_BASE = "[^"]*"' "$KGA" | head -1
    [[ -f "$BAK" ]] && echo "backup: present" || echo "backup: none"
    pgrep -f gemini_shim.py >/dev/null && echo "shim: running" || echo "shim: NOT running";;
  apply)
    [[ -f "$BAK" ]] || cp "$KGA" "$BAK"
    sed -i "s|GEMINI_API_BASE = \"[^\"]*\"|GEMINI_API_BASE = \"$SHIM_URL\"|" "$KGA"
    echo "patched → $SHIM_URL (backup: $BAK)";;
  revert)
    [[ -f "$BAK" ]] && cp "$BAK" "$KGA" && echo "reverted from backup" || echo "no backup";;
  *) echo "usage: kga-patch.sh {apply|revert|status}"; exit 2;;
esac
