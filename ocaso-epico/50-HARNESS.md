---
tags: [project, foundry, x-twitter, harness, ops]
date: 2026-09-12
status: LIVE — stack verified working 2026-09-12
related: "[[40-EXPERIMENT]]", "[[00-CHARTER]]"
---

# Harness — @ocaso_epico Technical Stack

## Live components (as of 2026-09-12, machine `li`)

| Layer | What | Where |
|-------|------|-------|
| Hands | `tweet.py` (post/reply/search/DM/etc.), `archive.py` | `~/.agents/skills/twitter-integration/scripts/` |
| Session | cookies at `~/.config/opencode/workspace/twikit_cookies.json` (0600); harvest via `scripts/cdp_cookies.py` | same skill |
| Browser lane | Chromium w/ `--remote-debugging-port=9222` (relaunched 2026-09-12, tabs restored) | this machine |
| Lib | twikit 2.3.3 + hand patches — see `VENV-PATCHES.md` in skill dir | skill `.venv` |
| Account | @ocaso_epico (carlos cordeiro, "assessor dos assessores") — 0/0/0 untouched | x.com |

## Known debts & traps

1. **Venv rebuild wipes the patches** → re-apply from `VENV-PATCHES.md`
   (x-client-transaction chunk-map fix + User-parse hardening).
2. **Chromium 150 cookie crypto is unrecoverable offline on li** (portal-bound key;
   keyring has no usable os_crypt entry). CDP is the only cookie path here.
   `chromium_cookies.py` (portal-decrypt) only works where Secrets portal backend runs.
3. **Browser UX debt (human-flagged 2026-09-12)**: agent shares the human's browser —
   agent-driven tabs pop in the human's face. PLAN: dedicated agent browser workspace:
   separate Chromium profile + CDP port (e.g. :9223) possibly on a separate desktop
   workspace, or headless instance when no human-visibility needed. NOT BUILT YET.
4. **Account credentials exist nowhere durable** — not in any vault (searched), not in
   Vaultwarden (which lives on orcrist, reachable via tailscale `100.68.225.53:8443`).
   TODO: store as LOGIN item `x-ocaso-epico` when on Vaultwarden. Until then, cookie
   refresh is the only session path (and the human's browser login is the master key).

## Session refresh runbook

```bash
# 1. Chromium must run with CDP (check):
curl -s localhost:9222/json/version | head -2
# 2. If not: close chromium, relaunch:
DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  setsid nohup /usr/lib/chromium/chromium --remote-debugging-port=9222 --restore-last-session >/tmp/chromium.log 2>&1 &
# 3. Harvest:
~/.agents/skills/twitter-integration/scripts/cdp_cookies.py
# 4. Verify:
~/.agents/skills/twitter-integration/scripts/tweet.py me
```

## Research integration (next)

- `research-routines` skill (keyless DDG/arXiv/Crossref) → feeds [[30-SOURCES]] receipts.
- `archive.py search/user` → engagement data → `~/twitter-archive.db` → weekly metric
  snapshots for [[40-EXPERIMENT]].

## Future architecture (per human's vision, not built)

- Each posting agent = own vertical ontology loop (this folder is the template).
- Agent-dedicated browser workspace (debt #3).
- Swarm/cron cadence once human-gated workflow has ≥ 30 approved posts of pattern.
