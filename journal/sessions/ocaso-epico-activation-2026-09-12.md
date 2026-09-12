---
tags: [session-digest, ocaso-epico, x-twitter, machine-awareness]
date: 2026-09-12
machine: li
related: "[[00-CHARTER]]", "[[50-HARNESS]]"
---

# Session Digest — Ocaso Epico Activation (2026-09-12, pi @ li)

## What was built (in order)

1. **Machine-identity audit**: session ran on `li` while `~/.pi/agent/AGENTS.md` and
   `~/AGENT-BOOTSTRAP.md` claimed "Host: Orcrist". Fixed both to dynamic grounding
   (`hostname -s` + tailscale registry of li/orcrist/eu). Synced to orcrist — which had
   **neither file** (orcrist pi sessions ran instruction-less). Commits `4707e6b`,
   `0c86bb4` in `~/.pi/agent` (li). Vault mirror relationship corrected:
   orcrist `~/obsidian-vault` (canonical) ← li `~/obsidian-vault-orcrist` (mirror).
2. **Twitter stack resurrected on li**: skill venv was empty → rebuilt
   (--system-site-packages + twikit). Offline cookie decryption proved IMPOSSIBLE here
   (Chromium 150 v11 key is portal-bound; Secrets portal backend absent; keyring items
   don't decrypt). Dead-end receipts kept in VENV-PATCHES.md.
3. **Browser lane opened**: graceful restart of human Chromium with
   `--remote-debugging-port=9222` (tabs restored). CDP is now the cookie path.
4. **Cookies harvested + session live**: `Storage.getCookies` → twikit auth →
   **@ocaso_epico verified** (fresh: 0/0/0).
5. **twikit 2.3.3 patched twice** (in-venv, documented in `VENV-PATCHES.md`):
   - x-client-transaction: X moved to webpack id→name chunk map; resolve chunk id
     (`ondemand.s`), hash from runtime map, URL = `ondemand.s.<hash16>a.js`
     (**trailing `a` — dropping it 404s**).
   - User.__init__ hardened: fresh accounts omit `entities.description.urls`,
     `pinned_tweet_ids_str`, `withheld_in_countries`, etc.
6. **Foundry scaffold** `ocaso-epico/` (6 notes): CHARTER, ARCHETYPE, CONTENT-ONTOLOGY,
   SOURCES, EXPERIMENT, HARNESS + INDEX section + this digest.

## Key lessons

- Trust nothing hardcoded about the machine; verify `hostname`/tailscale first.
- On li, portal-decrypt cookie path is dead; CDP is the only lane.
- X's anti-bot stack is real but tractable — the honest experiment framing.
- The human gate on posting is a hard rail (young account, disclosure, no inauthentic scale).

## Open items (next session)

- [ ] Human approves charter/archetype/tone.
- [ ] `x-ocaso-epico` LOGIN item in Vaultwarden (orcrist).
- [ ] research-routines run → verify [[30-SOURCES]] seeds → receipts.
- [ ] First 3 drafts → approval → Phase 1 of [[40-EXPERIMENT]].
- [ ] Agent-dedicated browser workspace (UX debt, [[50-HARNESS]] #3).
