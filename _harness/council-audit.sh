#!/usr/bin/env bash
# ── The Forge council-audit ──
# Deterministic (no tokens) scorer for the council's P6 probation. For each council wave
# it reads journal/council/<stamp>-final.txt vs -baseline.txt, checks what happened to the
# jobs the council actually APPENDED to queue.md ([x]=done / [!]=quarantined / [ ]=pending),
# measures disagreement vs the single-agent baseline, fills the ab-ledger.md `outcome`
# column, and prints a keep/kill recommendation. Per the-alpha-illusion P6: the council
# stays enabled only while it measurably beats the baseline. Run manually or via a [Steward]
# job; safe to run any time (read-only on everything except ab-ledger.md's outcome column).
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
cd "$VAULT" || exit 1

python3 - "$VAULT" <<'PY'
import sys, os, re, glob
vault = sys.argv[1]
cdir = os.path.join(vault, "journal", "council")
queue = os.path.join(vault, "_harness", "queue.md")
ledger = os.path.join(cdir, "ab-ledger.md")
ROLE = re.compile(r'^- \[ \] \[(Scout|Scribe|Curator|Janitor|Distiller|Smith|Quant|Steward|Critic)\] ')

def jobs(path):
    if not os.path.exists(path): return []
    return [l.rstrip("\n") for l in open(path) if ROLE.match(l)]

def state_of(jobline, qlines):
    body = jobline[6:]                       # strip '- [ ] '
    for q in qlines:
        if q.rstrip("\n").endswith(body):
            if q.startswith("- [x]"): return "done"
            if q.startswith("- [!]"): return "failed"
            return "pending"
    return "absent"

qlines = open(queue).readlines() if os.path.exists(queue) else []
if not os.path.exists(ledger):
    print("no ab-ledger.md yet — nothing to audit (council hasn't run)"); sys.exit(0)

rows = open(ledger).read().splitlines()
out, totals = [], {"done":0,"failed":0,"pending":0,"absent":0,"waves":0}
for line in rows:
    m = re.match(r'\|\s*([0-9]{4}-[0-9]{2}-[0-9]{2}-w\d+)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|\s*pending\s*\|', line)
    if not m:
        out.append(line); continue
    stamp = m.group(1); totals["waves"] += 1
    cj = jobs(os.path.join(cdir, f"{stamp}-final.txt"))
    bj = jobs(os.path.join(cdir, f"{stamp}-baseline.txt"))
    tally = {"done":0,"failed":0,"pending":0,"absent":0}
    for jl in cj:
        s = state_of(jl, qlines); tally[s] += 1; totals[s] += 1
    disagree = len([jl for jl in cj if jl not in bj])
    outcome = f"{tally['done']}done/{tally['failed']}failed/{tally['pending']}pend/{tally['absent']}gone; disagree={disagree}/{len(cj)}"
    out.append(f"| {stamp} |{m.group(2)}|{m.group(3)}|{m.group(4)}| {outcome} |")

open(ledger, "w").write("\n".join(out) + "\n")

appended = totals["done"] + totals["failed"] + totals["pending"] + totals["absent"]
print(f"audited {totals['waves']} council wave(s): {totals['done']} done, {totals['failed']} failed, "
      f"{totals['pending']} pending, {totals['absent']} gone (of {appended} council-appended jobs)")
if appended == 0:
    print("recommendation: NO DATA — council hasn't appended jobs yet; keep gathering.")
else:
    fail_rate = totals["failed"] / appended
    if fail_rate > 0.5:
        print(f"recommendation: KILL (COUNCIL_ENABLED=0) — {fail_rate:.0%} of council jobs quarantined; "
              f"it's steering worse than random. Revisit the prompt/models before re-enabling.")
    else:
        print(f"recommendation: KEEP for now — {fail_rate:.0%} quarantine rate. Compare council vs baseline "
              f"disagreement + the done-rate over more waves before trusting it with promotions.")
PY
