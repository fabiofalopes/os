#!/usr/bin/env bash
# ── Forge session SUCCESS evaluator ──
# Judges each session by WHETHER IT ACTUALLY DID ITS JOB — i.e. produced a durable
# artifact — NOT by its exit code or its error string. "Test, don't wonder": a session
# is a SUCCESS only if a file really appeared under the durable tree (wiki/ projects/
# journal/ inbox/ .forge/) during that session's time window. Deterministic, no tokens.
#
# Buckets (per session):
#   SUCCESS — verdict ok AND >=1 durable .md written in the session window
#   EMPTY   — verdict ok BUT nothing written (exit-0 no-op; the silent token burn)
#   INFRA   — failed for harness/infra reasons (proxy/429/timeout/routing) — NOT the
#             session's fault; reported separately, EXCLUDED from the success-rate denom
#   FAIL    — real content/behavior failure (non-infra exit, substrate violation)
#
# Success rate = SUCCESS / (SUCCESS + EMPTY + FAIL). This is the number to report to the
# human — never a raw error count. Run on demand (`bash evaluate.sh [YYYY-MM-DD]`) or via
# the health.sh watchdog so every wave is scored while its mtimes are still fresh.
#
# Caveat: per-session attribution is best-effort — parallel workers in one wave have
# overlapping windows, so a file can land in a neighbour's window. Accurate when scored
# fresh (cron every 15 min); a retroactive run on a day with re-touched files can
# under-count early sessions as EMPTY.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
mkdir -p "$HARNESS/state"
OUT="$HARNESS/state/evaluate.txt"
day="${1:-$(date -u +%F)}"

LOG="$LOG" VAULT="$VAULT" DAY="$day" python3 - "$OUT" <<'PY'
import os, re, sys, datetime

log   = os.environ["LOG"]
vault = os.environ["VAULT"]
day   = os.environ["DAY"]
out   = sys.argv[1]
MARGIN = 90  # s of slack each side of the window (clock skew + write latency)

# durable trees a real artifact lands in (shared substrate is excluded on purpose)
DURABLE = ["wiki", "projects", "journal", "inbox", ".forge"]

def iso_to_epoch(s):
    return datetime.datetime.strptime(s, "%Y-%m-%dT%H:%M:%SZ").replace(
        tzinfo=datetime.timezone.utc).timestamp()

# one durable-file scan: (mtime, relpath) for every .md under the durable trees
files = []
for d in DURABLE:
    root = os.path.join(vault, d)
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if fn.endswith(".md"):
                p = os.path.join(dp, fn)
                try: files.append((os.stat(p).st_mtime, os.path.relpath(p, vault)))
                except OSError: pass

infra_re = re.compile(
    r"ConnectionRefused|Unable to connect|Connection closed|mid-response|PROXY_DOWN|"
    r"429|rate.?limit|overloaded|quota|too many requests|503|upstream|ROUTING_FAIL|TIMEOUT", re.I)
# "- <date> <ISO> | <dur> | <verdict> | <model> | <job> | <summary>"
line_re = re.compile(
    r"^- \S+ (\S+) \| (\S+) \| ([^|]*?) \| ([^|]*?) \| ([^|]*?) \| (.*)$")

S = E = F = I = 0
rows = []
with open(log, encoding="utf-8", errors="replace") as fh:
    for raw in fh:
        if not raw.startswith("- " + day): continue
        m = line_re.match(raw.rstrip("\n"))
        if not m: continue                       # manual / malformed ops notes
        ts, dur_s, verdict, model, job, summary = m.groups()
        verdict = verdict.strip()
        if verdict.startswith("SKIP(") or verdict in ("QUARANTINED", "BRIDGE", "REAPED", "ok(DEFERRED)", "TIMEOUT(BUT_ARTIFACT)", "DEFERRED_HOLD"):
            continue                             # bookkeeping, not a session (REAPED/ok(DEFERRED): FM-8; TIMEOUT(BUT_ARTIFACT): FM-6 credit — the work landed; DEFERRED_HOLD: FM-8-follow-up per-job hold latch — all excluded from the success-rate denom)
        try: end = iso_to_epoch(ts)
        except ValueError: continue
        dur = int(re.sub(r"[^0-9]", "", dur_s) or 0)
        start = end - dur

        if verdict == "ok":
            lo, hi = start - MARGIN, end + MARGIN
            hits = sorted(p for mt, p in files if lo <= mt <= hi)
            if hits:
                S += 1; bucket = "SUCCESS"; note = hits[0] + (f" (+{len(hits)-1})" if len(hits) > 1 else "")
            else:
                E += 1; bucket = "EMPTY"; note = "exit-0, no artifact written"
        elif infra_re.search(verdict) or infra_re.search(summary):
            I += 1; bucket = "INFRA"; note = verdict
        else:
            F += 1; bucket = "FAIL"; note = verdict

        role = (job.strip()[:10] or "?")
        rows.append(f"  {ts[11:19]}  {bucket:<7} {role:<10} {note}")

real = S + E + F
rate = (100.0 * S / real) if real else 0.0
hdr = (
    f"Forge session SUCCESS — {day}\n"
    f"SUCCESS {S}   EMPTY {E}   FAIL {F}   | INFRA {I} (harness, excluded)\n"
    f"Success rate (did its job): {S}/{real} = {rate:.0f}%   "
    f"[{real} real sessions, {I} infra fails apart]\n"
)
body = "\n".join(rows) if rows else "  (no sessions this day)"
text = hdr + body + "\n"
sys.stdout.write(text)
with open(out, "w") as fh: fh.write(text)
PY
