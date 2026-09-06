#!/usr/bin/env bash
# ── websearch.sh — keyless web search fallbacks (v0 2026-09-06) ──
# usage: websearch.sh "query" [--n 6]
# Lanes: DuckDuckGo html (POST — lite GET is 202-blocked) + GitHub repos API.
# Why: cron WebSearch tool unreliable; queue precedent = curl direct APIs.
# Future: local SearxNG (~/mcp-servers/simple-searxng wrapper ready, deploy pending).
set -uo pipefail
Q="${1:?usage: websearch.sh \"query\" [--n N]}"; N=6
while [[ $# -gt 1 ]]; do case $2 in --n) N="$3"; shift 2;; *) shift;; esac; done
UA='Mozilla/5.0 (X11; Linux x86_64) Firefox/128.0'

ddg() { curl -sm 15 -A "$UA" -d "q=${Q// /+}" "https://html.duckduckgo.com/html/" 2>/dev/null | python3 -c '
import sys,re,html,urllib.parse
t=sys.stdin.read()
for m in re.finditer(r"<a[^>]*class=\"result__a\"[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>",t):
    u=html.unescape(m.group(1))
    if "uddg=" in u:
        u=urllib.parse.parse_qs(urllib.parse.urlparse(u).query).get("uddg",[u])[0]
    txt=html.unescape(re.sub("<[^>]+>","",m.group(2)))
    if u.startswith("http"): print("- " + txt[:100] + " — " + u[:120])
' | head -"$N"; }

gh() { curl -sm 15 "https://api.github.com/search/repositories?q=${Q// /+}&sort=stars&per_page=$N" 2>/dev/null | python3 -c '
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
for r in d.get("items",[]):
    print("- " + r["full_name"] + " (st:" + str(r["stargazers_count"]) + ", push " + (r.get("pushed_at","") or "")[:10] + ") " + (r.get("description") or "")[:110])
'; }

echo "## websearch — \"$Q\" ($(date -u +%FT%TZ))"
echo; echo "### web (DDG html)"
D=$(ddg); [[ -n "$D" ]] && echo "$D" || echo "(no results / blocked — use direct APIs or searxng)"
echo; echo "### github"
G=$(gh); [[ -n "$G" ]] && echo "$G" || echo "(no results / rate-limited)"
