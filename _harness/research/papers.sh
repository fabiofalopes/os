#!/usr/bin/env bash
# ── papers.sh — academic reference search, local-first, keyless (v0 2026-09-06) ──
# usage: papers.sh "query" [--n 5] [--json out.json]
# Sources: arXiv API (Atom) + Crossref (DOI/year). No API keys. Output: markdown
# table + optional raw JSON for staging/gate. Feed a distill agent with this, not
# with raw HTML. Routine doc: wiki/concepts/vault-embedded-research-routines.md
set -uo pipefail
Q="${1:?usage: papers.sh \"query\" [--n N] [--json out.json]}"; N=5; OUT=""
for a in "${@:2}"; do case $a in --n) :;; --json) :;; esac; done
while [[ $# -gt 1 ]]; do case $2 in --n) N="$3"; shift 2;; --json) OUT="$3"; shift 2;; *) shift;; esac; done

arxiv() { curl -sm 20 "https://export.arxiv.org/api/query?search_query=all:%22${Q// /+}%22&max_results=$N&sortBy=relevance" 2>/dev/null | python3 -c '
import sys,xml.etree.ElementTree as ET
ns={"a":"http://www.w3.org/2005/Atom"}
try: root=ET.fromstring(sys.stdin.read())
except Exception: sys.exit(0)
for e in root.findall("a:entry",ns):
    t=" ".join(e.findtext("a:title","",ns).split())
    u=e.findtext("a:id","",ns); d=e.findtext("a:published","",ns)[:10]
    s=" ".join((e.findtext("a:summary","",ns) or "").split())[:180]
    print("| " + t + " | " + d + " | " + u.rsplit("/",1)[-1] + " | " + s + "… |")
'; }

crossref() { curl -sm 20 "https://api.crossref.org/works?query=${Q// /+}&rows=$N&select=DOI,title,issued" 2>/dev/null | python3 -c '
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
for it in d.get("message",{}).get("items",[]):
    t=(it.get("title") or ["(untitled)"])[0][:110].replace("|","/")
    y=(it.get("issued",{}).get("date-parts") or [[""]])[0][0]
    doi=it.get("DOI","")
    print("| " + str(t) + " | " + str(y) + " | doi:" + doi + " | journal/other |")
'; }

[[ -n "$OUT" ]] && { { echo "{\"query\":\"$Q\",\"generated\":\"$(date -u +%FT%TZ)\""; echo ",\"arxiv\":"; curl -sm 20 "https://export.arxiv.org/api/query?search_query=all:%22${Q// /+}%22&max_results=$N" 2>/dev/null | head -c 20000; } > "$OUT"; }
echo "## papers — \"$Q\" ($(date -u +%FT%TZ), n=$N per source)"
echo; echo "### arXiv"; echo "| title | date | id | summary |"; echo "|---|---|---|---|"
A=$(arxiv); [[ -n "$A" ]] && echo "$A" || echo "| (no results / source down) | | | |"
echo; echo "### Crossref"; echo "| title | year | doi | kind |"; echo "|---|---|---|---|"
C=$(crossref); [[ -n "$C" ]] && echo "$C" || echo "| (no results / source down) | | | |"
