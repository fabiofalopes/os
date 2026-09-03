#!/usr/bin/env bash
# ── The Forge council ──
# Multi-model steering deliberation, invoked by runner.sh on council waves
# (wave % COUNCIL_EVERY == 0, and only when COUNCIL_ENABLED=1).
#
# This is deliberately NOT a debate about facts. The vault's own research
# (wiki/research/trading/the-alpha-illusion.md, P6) shows multi-agent debate beats a
# single agent <20% of the time and that persona-debate does NOT remove the shared
# prior (PPL). So the council deliberates about DIRECTION/PRIORITIZATION (where diverse
# perspectives help and a wrong call costs an hour, not a false belief), using three
# DIFFERENT models for genuine independence (Moon Dev's anonymized multi-model insight),
# anonymized as Member-1/2/3 so the critic attacks the argument not the model. A
# single-agent BASELINE runs on the same input for A/B: the council stays enabled only
# as long as journal/council/ab-ledger.md shows it beating that baseline.
#
# Reads: last hour of LOG.md + recently-touched artifacts + current pending queue.
# Writes: journal/council/<date>-w<wave>-{m1,m2,final,baseline}.txt, an ab-ledger.md row,
#         and APPENDS approved '- [ ] [Role] ...' jobs to queue.md (safe, reversible steering).
# Never:  edits CLAUDE.md, moves capital, or auto-applies promotions (recommendations only).
set -uo pipefail
wave="${1:?wave required}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
[[ -f "$SCRIPT_DIR/secrets.env" ]] && source "$SCRIPT_DIR/secrets.env"
export PATH="$(dirname "$CLAUDE_BIN"):/usr/local/bin:/usr/bin:/bin:${PATH:-}"
cd "$VAULT" || exit 1
ts() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }; today() { date -u '+%Y-%m-%d'; }
log_line() { printf '%s\n' "$1" >> "$LOG"; }

outd="$VAULT/journal/council"; mkdir -p "$outd"
stamp="$(today)-w$wave"
read -r -a CM <<< "$MODEL_CHAIN"
ROLES='(Scout|Scribe|Curator|Janitor|Distiller|Smith|Quant|Steward|Critic)'

# ── Council input: recent activity + recently-touched artifacts + pending queue ──
in="$HARNESS/state/council-input.txt"
{
  echo "## Recent LOG.md (last ${COUNCIL_INPUT_LINES} session lines today)"
  grep -a "^- $(today) " "$LOG" 2>/dev/null | tail -n "$COUNCIL_INPUT_LINES"   # -a: FM-8 belt-and-braces
  echo; echo "## Artifacts touched in the last 75 min"
  find wiki inbox projects .forge/skills -name '*.md' -mmin -75 2>/dev/null | head -30
  echo; echo "## Current pending queue jobs"
  grep -E '^- \[ \] ' "$QUEUE" 2>/dev/null | head -20
} > "$in"

# ── council_member <model> <alias> <outfile> <instructions> [prev_output_file] ──
council_member() {
  local model="$1" alias="$2" outfile="$3" instr="$4" prev="${5:-}"
  local prompt start dur st
  prompt=$(cat <<EOF
You are $alias on the Forge COUNCIL — a steering deliberation about DIRECTION and PRIORITIZATION
(not a debate about facts). The Forge is an autonomous knowledge/value-compounding vault; mission:
generate wealth + autonomy through compounding knowledge, skills, and measurable value. Stay vertical.

$instr

Output plain text. If you propose NEW queue jobs, write each EXACTLY as a markdown task line:
"- [ ] [Role] one-line description"  (Roles: Scout Scribe Curator Janitor Distiller Smith Quant Steward Critic).

=== RECENT STATE ===
$(cat "$in")
EOF
)
  [[ -n "$prev" && -f "$prev" ]] && prompt+=$'\n\n=== PRIOR COUNCIL MEMBER OUTPUT (anonymized) ===\n'"$(cat "$prev")"
  start=$(date +%s)
  timeout "$SESSION_TIMEOUT" "$CLAUDE_BIN" -p "$prompt" --dangerously-skip-permissions \
    --max-turns 20 --model "$model" > "$outfile" 2>&1
  st=$?; dur=$(( $(date +%s) - start ))
  local verdict; [[ $st -eq 0 ]] && verdict="ok" || verdict="exit$st"
  log_line "- $(today) $(ts) | ${dur}s | ${verdict} | council($alias) | (council w$wave $alias) | $(grep -vE '^\s*$' "$outfile" | tail -1 | cut -c1-160)"
}

# Member #1 PROPOSER → Member #2 CRITIC (diff model, attacks) → Member #3 SYNTHESIZER (diff model)
council_member "${CM[0]:-}" "Member-1-proposer" "$outd/$stamp-m1.txt" \
  "Propose 3-5 concrete steering actions for the next hour: new queue jobs, jobs to reprioritize, a [!] to triage, or a promotion to gate. Prefer what compounds toward revenue."
council_member "${CM[1]:-${CM[0]:-}}" "Member-2-critic" "$outd/$stamp-m2.txt" \
  "Adversarially critique the prior member's proposal. Kill weak/FOMO/side-quest actions; keep only what compounds. Default skeptical. Then give your revised steering actions." \
  "$outd/$stamp-m1.txt"
council_member "${CM[2]:-${CM[0]:-}}" "Member-3-synthesizer" "$outd/$stamp-final.txt" \
  "Synthesize the deliberation into a FINAL, small set of steering actions. List NEW queue jobs as '- [ ] [Role] ...' lines. Keep it tight (<=5 jobs)." \
  "$outd/$stamp-m2.txt"
# BASELINE — single agent, same input, for the P6 A/B
council_member "${CM[0]:-}" "Baseline" "$outd/$stamp-baseline.txt" \
  "Given the recent state, propose 3-5 steering actions (new queue jobs as '- [ ] [Role] ...' lines). Work alone."

# ── Apply safe steering: append NEW role-tagged jobs from the synthesizer, idempotent ──
added=0
while IFS= read -r jobline; do
  jobline="${jobline%"${jobline##*[![:space:]]}"}"      # rtrim
  grep -qF -- "$jobline" "$QUEUE" && continue            # already queued → skip
  printf '%s\n' "$jobline" >> "$QUEUE"
  added=$(( added + 1 ))
done < <(grep -E "^- \[ \] \[${ROLES}\] " "$outd/$stamp-final.txt" 2>/dev/null)

# ── ab-ledger row (raw A/B data; council-audit.sh scores outcomes later) ──
council_jobs=$(grep -cE "^- \[ \] \[${ROLES}\] " "$outd/$stamp-final.txt" 2>/dev/null || echo 0)
base_jobs=$(grep -cE "^- \[ \] \[${ROLES}\] " "$outd/$stamp-baseline.txt" 2>/dev/null || echo 0)
ledger="$outd/ab-ledger.md"
[[ -f "$ledger" ]] || printf '# Council A/B Ledger (P6 probation)\n\n> council steering vs single-agent baseline. `outcome` filled by _harness/council-audit.sh.\n> Per the-alpha-illusion P6: KILL the council (COUNCIL_ENABLED=0) unless it measurably beats baseline.\n\n| wave | council-jobs | baseline-jobs | appended | outcome |\n|---|---|---|---|---|\n' > "$ledger"
printf '| %s | %s | %s | %s | pending |\n' "$stamp" "$council_jobs" "$base_jobs" "$added" >> "$ledger"

echo "[$(ts)] council w$wave: appended $added jobs (council=$council_jobs baseline=$base_jobs)" >&2
