---
tags: [value, tool-skill, pilot, ledger-row-2, handoff, human-gated, z2]
date: 2026-07-23
status: handoff (Z2) — one-screen go/no-go for the human. Nothing here is published; the human decides and posts.
related:
  - "[[tool-pilot-01]]"
  - "[[tool-pilot-01-outreach]]"
  - "[[ledger]]"
---

# Tool Pilot 01 — PUBLISH Go/No-Go (5-minute human decision)

> **The decision:** approve publishing `cron-agent-swarm` (free, $0) to the 3 frozen channels to
> test [[ledger]] row 2 — *"what we build is wanted by others."* Everything is staged and
> copy-paste ready in [[tool-pilot-01-outreach]]. This sheet collapses it to one screen.
> **You only decide go/no-go — the agent never publishes (Z2/outward).**

## What you're approving (one line each)

- **Artifact:** `cron-agent-swarm` — the forged skill at `.forge/skills/cron-agent-swarm/` (SKILL.md + README.md + `templates/`, verified on disk 2026-07-23). Given away at **$0**; demand is the signal.
- **Test:** publish to the **frozen N=3** channels, count qualified-interest signals `Q` for 21 days, apply the frozen verdict (NOT SEEN → KILL → PROMOTE → WEAK). A **KILL is a live, honest outcome**.
- **Why now:** row 1 (forecasting) is static until **2026-08-04**; this verdict lands ~3 weeks after publish — the **fastest revenue evidence available**. This is the highest-leverage unblock.

## The 3 frozen channels — exact targets (HN is OUT; it's the redesign lever only)

| # | Channel | Post at this URL | Copy from [[tool-pilot-01-outreach]] |
|---|---|---|---|
| 1 | **r/ClaudeAI** (primary) | https://www.reddit.com/r/ClaudeAI/submit | §2a (title + body) |
| 2 | **r/ObsidianMD** (secondary) | https://www.reddit.com/r/ObsidianMD/submit | §2b (title + body) |
| 3 | **Obsidian forum — Share & Showcase** (tertiary) | https://forum.obsidian.md/c/share-showcase/9 | §2c (title + body) |

*(Forum URL verified 2026-07-23. HN draft sits in outreach Appendix A — **not** part of T0.)*

## Publish commands (run in this order — ~5 min)

```sh
# 1. Create the public repo, then SECRET-SCAN before anything ships (must print no real keys):
cd .forge/skills/cron-agent-swarm
git grep -iE 'api[_-]?key|sk-|token'        # ⚠️ the Lusófona key must NEVER leave — clean = go
# 2. Push SKILL.md + README.md + templates/ to the new repo; use outreach §1 as the repo README.
#    (add a LICENSE file — MIT — before push)
# 3. Replace every <REPO_URL> in the 3 posts with the live repo URL.
# 4. Check each community's self-promo rules; post §2a → §2b → §2c as honest show-and-tell.
# 5. Record T0 = date/time of the FIRST post. Screenshot + save baseline ↑/💬 for each (Table A).
```

**No CLI posts to Reddit/forum — steps 4–5 are manual, by you.** Honesty rule (non-negotiable): no hype, no ROI claims, no astroturfing, no solicited friends, organic only.

## Where the clock + scoring live (you don't maintain these — the scorer does)

- **T0 tracking sheet:** [[tool-pilot-01-outreach]] **§3** — Table A (visibility), Table B (Q-signal tally), verdict box. **T0 = first publish; verdict at T0+21d.** Scorer writes `tool-pilot-01-RESULT.md` and updates [[ledger]] row 2 (a Z2 status change — flagged back to you).

## FROZEN qualified-interest definition (one line — never edited, only restated)

> **`Q` = count, once per distinct person, of: an install/usage report · a substantive setup question · a fork/clone (or a star+comment) · a DM/comment requesting help or a feature · stated intent to use · any offer to pay** — upvotes, "cool" comments, silence, and anything from our own alts/friends do NOT count.

## Verdict thresholds (frozen, applied in order at T0+21d)

`NOT SEEN` (all removed/locked, or Σ↑+Σ💬 < 10 → one redesign, clock resets) → `KILL` (seen & Q=0 → row 2 killed) → `PROMOTE` (Q≥3 or ≥1 direct pay request → row 2 `paper`, test price in tool-pilot-02) → `WEAK` (Q∈{1,2} → one documented redesign).

---

**☐ GO** — approve publish of the 3 posts · **☐ NO-GO** — hold (state reason in [[ledger]] log)

*Prepared 2026-07-23 by a Janitor cron worker from [[tool-pilot-01-outreach]] + [[tool-pilot-01]]; skill files + forum URL verified on disk/web same day. Nothing published.*
