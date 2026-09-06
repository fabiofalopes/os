#!/usr/bin/env bash
# ── batch.sh — multi-repo batch runs for the foundry (v0 2026-09-06) ──
# The repo-map pattern, scaled: give 100 repos + a purpose; get a state machine
# per repo and ONE clean view of when/where to intervene.
#   batch.sh new <id> --purpose "..." --repos "a/b,c/d"     (create batch)
#   batch.sh set <id> <repo> <STATE> ["note"]               (state transition)
#   batch.sh gate <id> <repo> <ok|dirty> --why "..."        (HUMAN intervention → trace)
#   batch.sh stage <id> [k]                                 (append [Scout] triage jobs)
#   batch.sh status [id]                                    (the clean view)
# States: QUEUED → FETCHED → GATED → TRIAGED → STAGED → MINING → DONE
#         (+ BLOCKED = needs you · DIRTY = gate rejected)
# Files per batch: manifest.md (state table, curatable) · trace.md (append-only
# interventions/validations — the behavioral record agents learn from).
set -uo pipefail
HARNESS="$HOME/obsidian-vault-kali/_harness"
BJ="$HOME/obsidian-vault-kali/journal/batch"
QUEUE="$HARNESS/queue.md"
STATES='QUEUED|FETCHED|GATED|TRIAGED|STAGED|MINING|DONE|BLOCKED|DIRTY'
mkdir -p "$BJ"

upd_row() { # ledger file, repo, state, note — rewrite the row in place (state = current truth)
  awk -v r="| $2 " -v s="$3" -v n="$4" -v d="$(date -u +%FT%TZ)" '
    BEGIN{FS=" \\| "; OFS=" | "}
    $0 ~ ("^\\| " substr(r,3) ) {$2=s; $3=d; $4=n}
    {print}' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}
trace() { printf '%s | %s | %s | %s\n' "$(date -u +%FT%TZ)" "$1" "$2" "$3" >> "$4"; }

cmd="${1:-status}"; shift || true
case "$cmd" in
  new)
    id="$1"; purpose=""; repos=""
    while [[ $# -gt 1 ]]; do case $2 in --purpose) purpose="$3"; shift 2;; --repos) repos="$3"; shift 2;; *) shift;; esac; done
    [[ -d "$BJ/$id" ]] && { echo "batch exists: $BJ/$id"; exit 1; }
    mkdir -p "$BJ/$id"
    { echo "---"; echo "batch: $id"; echo "purpose: \"$purpose\""; echo "created: $(date -u +%FT%TZ)"; echo "---"; echo
      echo "# Batch $id — $purpose"; echo; echo "## State ledger"; echo
      echo "| repo | state | updated | note |"; echo "|---|---|---|---|"
      IFS=','; for r in $repos; do [[ -n "$r" ]] && echo "| $r | QUEUED | $(date -u +%FT%TZ) | intake |"; done; unset IFS
    } > "$BJ/$id/manifest.md"
    echo "# trace — batch $id (append-only: interventions + validations)" > "$BJ/$id/trace.md"
    echo "batch $id created: $(grep -c '^| .*/' "$BJ/$id/manifest.md") repos · $BJ/$id";;
  set)
    id="$1"; repo="$2"; st="$3"; note="${4:-}"
    [[ "$st" =~ ^($STATES)$ ]] || { echo "bad state ($STATES)"; exit 2; }
    upd_row "$BJ/$id/manifest.md" "$repo" "$st" "$note"
    trace "$repo" "$st" "$note" "$BJ/$id/trace.md"; echo "→ $repo: $st";;
  gate)
    id="$1"; repo="$2"; verdict="$3"; why=""; a=("$@")
    for ((i=0;i<${#a[@]};i++)); do [[ "${a[$i]}" == "--why" ]] && why="${a[$((i+1))]}"; done
    st=DONE; [[ "$verdict" == dirty ]] && st=DIRTY
    upd_row "$BJ/$id/manifest.md" "$repo" "$st" "$why"
    trace "$repo" "HUMAN_GATE:$verdict" "$why" "$BJ/$id/trace.md"
    echo "→ $repo: $verdict (recorded as behavioral trace)";;
  stage)
    id="$1"; k="${2:-3}"; n=0
    mapfile -t todo < <(grep -E '^\| .*/.*\| (QUEUED|GATED) ' "$BJ/$id/manifest.md" | head -"$k" | awk -F' \\| ' '{print substr($1,3)}')
    [[ ${#todo[@]} -eq 0 ]] && { echo "nothing to stage"; exit 0; }
    { echo; echo "## Batch $id — staged triage ($(date -u +%F), per batch mode v0)"; } >> "$QUEUE"
    for r in "${todo[@]}"; do
      echo "- [ ] [Scout] BATCH $id TRIAGE: $r — fetch (git clone --depth 1 to /tmp/batch-$id), \`bash $HARNESS/ingest/gate.sh <dir> --llm\`, then triage for the batch purpose (read manifest.md frontmatter): 3-line alpha verdict (mine/skip/map-only) + expected yield. \`batch.sh set $id $r TRIAGED 'verdict'\`. No mining in this session. PRODUCED: trace.md lines." >> "$QUEUE"
      n=$((n+1)); upd_row "$BJ/$id/manifest.md" "$r" STAGED "triage job queued"
    done
    echo "staged $n triage job(s) → queue.md";;
  status)
    id="${1:-$(ls -t "$BJ" | head -1)}"
    M="$BJ/$id/manifest.md"; [[ -f "$M" ]] || { echo "no batches yet (batch.sh new)"; exit 0; }
    total=$(grep -cE '^\| .*/.*\| ' "$M"); done_n=$(grep -c '| DONE ' "$M")
    echo "═══ BATCH $id ═══ $(grep '^purpose:' "$M" | cut -d'"' -f2)"
    echo "progress: [$(printf '█%.0s' $(seq 1 $done_n 2>/dev/null) ; printf '░%.0s' $(seq 1 $((total-done_n)) 2>/dev/null))] $done_n/$total done"
    for st in BLOCKED DIRTY MINING STAGED TRIAGED GATED FETCHED QUEUED DONE; do
      rows=$(grep -E "\| $st " "$M" | awk -F' \\| ' '{n=$4; gsub(/\| *$/,"",n); print "  " substr($1,3) " — " n}')
      [[ -n "$rows" ]] && { case $st in BLOCKED|DIRTY) echo "⚠️  INTERVENE ($st):";; *) echo "$st:";; esac; echo "$rows"; }
    done
    t="$BJ/$id/trace.md"; echo "trace lines: $(($(wc -l < "$t")-1)) · $(grep -c HUMAN_GATE "$t" 2>/dev/null) human gates";;
  *) echo "usage: batch.sh {new|set|gate|stage|status}"; exit 2;;
esac
