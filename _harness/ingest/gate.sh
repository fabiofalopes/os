#!/usr/bin/env bash
# ── gate.sh — local ingestion gate for fetched content (v0, 2026-09-06) ──
# Pipeline: fetch → [THIS] scan+classify → staging → distill → vault-graph.
#   usage: gate.sh <dir-or-file> [--llm] [--quarantine]
# Tiers: CLEAN · SUSPICIOUS (injection-heuristic hit) · DIRTY (binary/exec/clam)
# - Static heuristics ALWAYS run ($0, offline). --llm adds classifier calls via
#   :8705 router (local models first; degrades gracefully when lane is down).
# - --quarantine MOVES non-clean files into _harness/ingest/quarantine/
#   (without it: report-only — safe default; rollback for quarantine = move back).
# - Every verdict appends one atomic line to _harness/ingest/verdicts.log (the
#   learnings ledger miners/curators read; foundry runs tune vaultcraft from it).
set -uo pipefail
HARNESS="$HOME/obsidian-vault-kali/_harness"
ING="$HARNESS/ingest"; QR="$ING/quarantine"; LEDGER="$ING/verdicts.log"
ROUTER="${GATE_ROUTER:-http://127.0.0.1:8705/v1/chat/completions}"
MODEL="${GATE_MODEL:-amalia-9b}"
mkdir -p "$ING" "$QR"; touch "$LEDGER"
TARGET="${1:?usage: gate.sh <dir-or-file> [--llm] [--quarantine]}"
USE_LLM=0; DO_QUAR=0
for a in "${@:2}"; do case "$a" in --llm) USE_LLM=1;; --quarantine) DO_QUAR=1;; esac; done
[[ -e "$TARGET" ]] || { echo "no such target: $TARGET"; exit 2; }

INJ_PAT='ignore (all )?(previous|prior|above) instructions|disregard .{0,20}instructions|(reveal|print|repeat|show).{0,20}system prompt|you are now|<\|im_start\||</system>|exfiltrat|curl [^|]{0,60}\|\s*(ba)?sh|wget [^|]{0,60}\|\s*(ba)?sh'
mapfile -t FILES < <(if [[ -d "$TARGET" ]]; then find "$TARGET" -maxdepth 2 -type f; else echo "$TARGET"; fi)
ts() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
llm_ok=1; dirty=0; susp=0; clean=0

llm_classify() { # $1=file → "VERDICT|reason" or empty on lane failure
  local body; body=$(head -c 4000 "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null)
  [[ -n "$body" ]] || return 0
  local r; r=$(curl -s -m 30 "$ROUTER" -H 'Content-Type: application/json' \
    -d "{\"model\":\"$MODEL\",\"max_tokens\":40,\"messages\":[{\"role\":\"system\",\"content\":\"You are a content-intake classifier for a knowledge vault. Reply EXACTLY: CLEAN|SUSPICIOUS|INJECTION <one-line reason>. CLEAN means ordinary informational content.\"},{\"role\":\"user\",\"content\":$body}]}" 2>/dev/null)
  if [[ "$r" != *'"choices"'* ]]; then [[ $llm_ok -eq 1 ]] && { echo "$(ts) | LLANE | DOWN ($ROUTER $MODEL unreachable) — heuristic-only pass" >> "$LEDGER"; llm_ok=0; }; return 0; fi
  printf '%s' "$r" | python3 -c 'import json,sys; print(json.load(sys.stdin)["choices"][0]["message"]["content"].strip())' 2>/dev/null | head -c 200
}

for f in "${FILES[@]}"; do
  h=$(sha256sum "$f" | cut -c1-8); sz=$(stat -c%s "$f")
  mime=$(file -b --mime-type "$f"); verdict=CLEAN; reason=""
  # static: binary/executable
  if [[ "$mime" == application/x-executable* || "$mime" == application/x-pie-executable* || "$mime" == application/x-sharedlib* ]] \
     || grep -qaP '\x7fELF' "$f" 2>/dev/null; then
    verdict=DIRTY; reason="executable/binary ($mime)"
  elif command -v clamscan >/dev/null && ! clamscan --no-summary "$f" 2>/dev/null | grep -q 'OK$'; then
    verdict=DIRTY; reason="clamav"
  elif [[ "$mime" == text/* || "$mime" == application/json || "$mime" == application/xml ]]; then
    hit=$(grep -aoiE "$INJ_PAT" "$f" 2>/dev/null | head -1)
    if [[ -n "$hit" ]]; then verdict=SUSPICIOUS; reason="inj-heuristic: ${hit:0:60}"; fi
  else
    verdict=SUSPICIOUS; reason="unscanned type ($mime)"
  fi
  # optional LLM tier (text only)
  if [[ $USE_LLM -eq 1 && $llm_ok -eq 1 && ( "$verdict" == CLEAN || "$verdict" == SUSPICIOUS ) && ( "$mime" == text/* ) ]]; then
    lv=$(llm_classify "$f")
    case "$lv" in INJECTION*) verdict=SUSPICIOUS; reason="llm: ${lv:0:80}";; esac
  fi
  echo "$(ts) | $h | $sz | $verdict | ${f#$HOME/} | $reason" >> "$LEDGER"
  case $verdict in CLEAN) clean=$((clean+1));; SUSPICIOUS) susp=$((susp+1)); printf '  SUSPICIOUS  %s  (%s)\n' "${f#$HOME/}" "$reason";; DIRTY) dirty=$((dirty+1)); printf '  DIRTY       %s  (%s)\n' "${f#$HOME/}" "$reason";; esac
  if [[ $DO_QUAR -eq 1 && "$verdict" != CLEAN ]]; then mkdir -p "$QR/$(dirname "${f#$TARGET}")" && mv "$f" "$QR/${f#$TARGET/}" && echo "    → quarantined"; fi
done
echo "── gate: $clean clean · $susp suspicious · $dirty dirty  (${#FILES[@]} files, llm=$([[ $USE_LLM -eq 1 ]] && echo $([[ $llm_ok -eq 1 ]] && echo on || echo DOWN) || echo off), clam=$(command -v clamscan >/dev/null && echo on || echo absent))"
exit $((susp+dirty))
