---
name: research-routines
description: Keyless local research routines — web search (DDG-html + GitHub API), academic papers (arXiv + Crossref DOIs), page reading, and the bounded deep-research loop with gate + receipts. Triggers on 'search the web', 'find papers', 'arxiv', 'academic references', 'deep research', 'look this up'.
---

Deterministic-first research: scripts fetch and parse ($0, keyless); the LLM only enters at distillation. Doc: `wiki/concepts/vault-embedded-research-routines.md`.

## When to use

- "Search for X" / "find papers on Y" / "deep research Z" in any session (interactive or cron)
- Feeding a distill agent with structured sources instead of raw HTML

## Commands (all live-verified)

```bash
bash _harness/research/websearch.sh "query" --n 6     # DDG html (POST; lite endpoint is blocked) + GitHub repos (stars/push)
bash _harness/research/papers.sh "query" --n 5        # arXiv (MUST be https; http returns empty) + Crossref DOIs; --json out for staging
bash _harness/research/userbase-fetch.sh <staging>    # mirror a MediaWiki (example: legacy tidal userbase, 228p)
```

Reading a page: use the `defuddle` skill (clean markdown from any URL). Local exploration: `universal-finder`.

## The deep-research loop (bounded — this is the contract)

```
question (from queue/Sources/a real gap — NEVER "just because")
→ websearch.sh + papers.sh  (max 8 sources total)
→ defuddle top URLs → staging dir
→ ingest-gate skill on staging
→ distill ONE note wiki/research/… with receipts (url/arxiv-id per claim) + verdict ★ or DOWNGRADE
→ INDEX row + LOG line
STOP: 1 note per job, verdict mandatory, no note without receipts
```

## Guards

- DDG may rate-limit datacenter IPs at volume → deploy SearxNG when scaling.
- GitHub API unauthenticated = 10 req/min.
- LLM distillation is gateway-gated (router :8705); fetch/parse/gate work offline.
