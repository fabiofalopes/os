#!/usr/bin/env bash
# ── userbase-fetch.sh — mirror the legacy TidalCycles userbase wiki (v0 2026-09-06) ──
# Purpose: preservation + published-asset foundation. Source is CC BY-SA 4.0
# (https://creativecommons.org/licenses/by-sa/4.0/) — attribution preserved in
# LICENSE-NOTE.md; derived publications must share alike.
# Enumerates: Userbase.html index + Category pages (API is 404-dead).
# Output: $STAGING/<Page>.{html,md} + LICENSE-NOTE.md + inventory.tsv
set -uo pipefail
BASE="https://userbase.tidalcycles.org"
STAGING="${1:-/tmp/userbase-staging}"
mkdir -p "$STAGING"
SEEDS=("Userbase.html" "Category:Functions.html" "Category:Control_Functions.html" "Category:Transitions.html" "Category:Elemental_patterns.html")

skip() { case "$1" in index.php*|TidalCycles_userbase:*|Special:*|Main_Page*|Category:*.html#*|*#*|javascript:*) true;; *) false;; esac; }

# pass 1: seeds → page set
declare -A PAGES=()
for s in "${SEEDS[@]}"; do
  f="$STAGING/$(echo "$s" | tr ':/' '__').html"
  [[ -f "$f" ]] || curl -sm 25 "$BASE/$s" -o "$f"
  [[ -s "$f" ]] && PAGES["$s"]=1
  grep -oE 'href="[A-Za-z0-9$_%().+-]+\.html"' "$f" 2>/dev/null | sed 's/href="//;s/"//' | while read -r p; do echo "$p"; done >> "$STAGING/.links1"
done
[[ -f "$STAGING/.links1" ]] || { echo "seeds failed"; exit 1; }

# pass 2: fetch every discovered page (dedup, skip meta)
n=0; fails=0
sort -u "$STAGING/.links1" | grep -v '^Category:' > "$STAGING/.list"
total=$(wc -l < "$STAGING/.list"); echo "corpus: $total pages (+5 seeds)"
while read -r p; do
  skip "$p" && continue
  out="$STAGING/$(echo "$p" | tr ':/$%' '___').html"
  [[ -s "$out" ]] || curl -sm 25 "$BASE/$p" -o "$out" || true
  if [[ -s "$out" ]]; then n=$((n+1)); printf '%s\t%s\t%s\n' "$p" "$(stat -c%s "$out")" "$BASE/$p" >> "$STAGING/inventory.tsv"; else fails=$((fails+1)); printf '%s\tFAIL\t%s\n' "$p" "$BASE/$p" >> "$STAGING/inventory.tsv"; fi
done < "$STAGING/.list"

# html → readable md (title + text content, links kept)
python3 - "$STAGING" <<'PYEOF'
import sys, os, re, html as H, urllib.parse
st = sys.argv[1]
for fn in sorted(os.listdir(st)):
    if not fn.endswith('.html'): continue
    raw = open(os.path.join(st, fn), encoding='utf-8', errors='replace').read()
    title = re.search(r'<title>([^<]*)</title>', raw)
    body = re.search(r'<div[^>]*(?:id="content"|class="mw-body|mw-parser-output)[^>]*>(.*)', raw, re.S)
    t = body.group(1) if body else raw
    t = re.sub(r'<script.*?</script>|<style.*?</style>', '', t, flags=re.S)
    t = re.sub(r'<h([1-6])[^>]*>', lambda m: '\n' + '#' * int(m.group(1)) + ' ', t)
    t = re.sub(r'</h[1-6]>', '\n', t)
    t = re.sub(r'<li[^>]*>', '\n- ', t)
    t = re.sub(r'<br[^>]*>|</p>', '\n', t)
    t = re.sub(r'<a [^>]*href="([^"]*)"[^>]*>(.*?)</a>', lambda m: '[' + re.sub('<[^>]+>','',m.group(2)) + '](' + m.group(1) + ')', t, flags=re.S)
    t = re.sub(r'<[^>]+>', '', t)
    t = H.unescape(t)
    t = re.sub(r'\n{3,}', '\n\n', t)
    src = 'https://userbase.tidalcycles.org/' + urllib.parse.unquote(fn[:-5]).replace('_',' ').replace('.html','')
    md = '---\nsource: "%s"\ntitle: "%s"\nlicense: CC BY-SA 4.0\n---\n%s\n' % (src, H.unescape(title.group(1)) if title else fn, t.strip())
    open(os.path.join(st, fn[:-5] + '.md'), 'w', encoding='utf-8').write(md)
print('md conversion done')
PYEOF

cat > "$STAGING/LICENSE-NOTE.md" <<'EOF'
# Source & License
- Source: TidalCycles userbase wiki (https://userbase.tidalcycles.org/), MediaWiki snapshot frozen ~2022-03.
- License: CC BY-SA 4.0 — content may be remixed/published with attribution; derivatives share alike.
- Each .md carries per-page source frontmatter. Inventory in inventory.tsv (page, bytes, url).
EOF
echo "fetched: $n ok · $fails fail → $STAGING (gate next: bash _harness/ingest/gate.sh $STAGING)"
