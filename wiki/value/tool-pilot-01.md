---
tags: [value, quant, tool-skill, pilot, precommitment, ledger-row-2]
date: 2026-07-22
status: draft (Z2) — LOCKED pre-commitment; the "qualified signal" definition and kill math are frozen before any post goes out; outward publish is human-approved
related:
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[multi-agent-orchestration-patterns]]"
  - "[[The Forge Harness — Runbook]]"
  - "[[HARVEST-STATUS]]"
  - "[[Skills Harvest — What's Here & What To Do Differently]]"
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
  - "[[forecast-pilot-01]]"
---

# Tool Pilot 01 — First Falsification Test of Ledger Row 2

> Tests [[ledger]] row 2 ("a tool/skill we can give away or sell … what we build is wanted by others"). **One** concrete artifact: `cron-agent-swarm`, a forged `.forge/skills/` skill that lets anyone stand up a cron-driven parallel-agent swarm over their own markdown/Obsidian vault (the pattern behind this vault's own engine, de-vaulted and packaged). Give it away free; **demand is the signal**, measured as *qualified-interest* signals after a fixed set of outreach posts. $0, no capital. Clock starts at first publish (T0), verdict at T0+21 days.

## ☠ KILL CRITERION (pre-committed — do not move after seeing any response)

**Metric:** `Q` = count of **qualified-interest signals** (definition frozen below) across **all** outreach channels, over the 21-day window starting at first publish (T0). `V` = visibility check (was it actually seen?).

| Verdict | Condition (applied in order) | Consequence for [[ledger]] row 2 |
|---|---|---|
| **NOT SEEN** (distribution failure, checked FIRST) | Every post removed/locked, **OR** combined upvotes + comments `< 10` across all channels | No verdict on the thesis — nobody saw it. **One** redesign allowed (different channel or framing); clock resets at re-publish. Mirrors row 1's "infra failure, not thesis failure." |
| **KILL** | Seen (passed NOT SEEN) **AND** `Q = 0` after 21 days | Row 2 → `killed` as stated for this artifact+buyer+channel. "What we build is wanted" is falsified here. |
| **PROMOTE** | `Q ≥ 3`, **OR** `≥ 1` direct request / offer to pay / "would you set this up for me" | Row 2 → `paper`: build the full version and test the Stage-2 price hypothesis in `tool-pilot-02` (paid setup service or Pro bundle). |
| **WEAK / INCONCLUSIVE** | `Q ∈ {1, 2}` and no direct request | Ambiguous. **One** redesign allowed with a *documented change* (sharper artifact or different buyer) — never a re-post of the same thing. |

**Qualified-interest signal (FROZEN — counts once per distinct person):**
- an install / usage report ("I set this up and …")
- a substantive setup question (more than "cool")
- a fork / clone of the published repo, or a star accompanied by a comment
- a DM or comment requesting help or a feature
- a comment expressing intent to use ("going to try this for my vault")
- any offer to pay, or request for paid help

**Does NOT count:** upvotes alone · "cool/nice" comments · downvotes · silence · **any signal from our own alt accounts or solicited friends (none — no astroturfing; organic only).**

**Anti-fooling commitments** (per [[Operating Principle — Test Don't Wonder]]):
- The verdict is on `Q` across the **full batch** of channels. No post-hoc "it worked on Reddit" cherry-picking.
- The qualified-signal definition is frozen now. Changes go in the RESULT note, never here.
- No astroturfing. Organic interest only; a small honest number beats a manufactured one.
- A PROMOTE at this scale is "a demand signal worth a bigger test," **not** "market proven."
- The clock starts at **first publish (T0)**, not at build-complete. Build delay is not evidence either way.

## What is being tested — and the honest caveat

Thesis under test: *the cron-swarm harness pattern we actually run is wanted by other Claude-Code / Obsidian users, enough that they will adopt it or ask for it.*

**Known handicaps (logged, not hidden):**
- **Zero prior external-demand evidence.** We have internal capability evidence (engine proven: 15/15 ok sessions → artifacts, per [[MEMORY]]; scripts exist — `runner.sh`, `worker.sh`, `council.sh`, `evaluate.sh`, `oracle.sh`, `rollup.sh`) and a *measured gap* ([[HARVEST-STATUS]]: the 8,983-skill canonical store is 85% security reference cards; no commodity "cron-swarm over a markdown vault" skill exists). A gap is not demand. **A KILL here is a live, honest outcome** — exactly as in [[forecast-pilot-01]].
- **The harness is coupled to this vault.** De-vaulting it into a turnkey skill is real work and may reveal it is less portable than hoped — a build risk stated up front, not discovered later.
- **Publishing is outward-facing (Z2).** A human approves each post; the clock cannot start until the first one ships.

## The artifact (ONE concrete thing)

**`cron-agent-swarm`** — a forged skill at `.forge/skills/cron-agent-swarm/` packaging the pattern this vault runs on, agent-CLI-agnostic (Claude Code / OpenCode / any CLI agent):

- `SKILL.md` — the pattern: a cron tick → `runner.sh` picks the top unchecked job from `queue.md` → spawns `WORKERS_PER_TICK` parallel role-tagged workers → each writes **one durable artifact** → `evaluate.sh` logs a per-session success verdict → `oracle.sh`/`rollup.sh` render a one-screen view. Plus the governance template (constitution + Z1/Z2/Z4 zones) that keeps workers from trashing shared state.
- `templates/` — de-vaulted `runner.sh`, `worker.sh`, `queue.md`, `schedule.md`, `config.env`, and a constitution template.
- `README.md` — a 10-minute quickstart + "what this is / isn't."
- **De-vaulting rule:** strip every vault-specific path and secret. The plaintext Lusófona API key flagged in [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]] must **never** ship; vault path + agent CLI are parameters.

Grounding: skill-backlog items #5 (Automated Session Dispatching, high confidence) and #13 (Multi-Agent Orchestration) show we ourselves recur to this pattern — an internal-demand proxy. Internal ≠ external; that gap is precisely what this pilot measures.

## Buyer / channel / price hypothesis

- **Buyer (primary):** Claude-Code / coding-agent power users who want autonomous background agents compounding work in a markdown knowledge base, but don't want to design the orchestration. Gather in **r/ClaudeAI**.
- **Buyer (secondary):** Obsidian PKM tinkerers who want "an agent that grows my vault." Gather in **r/ObsidianMD** + the **Obsidian forum**.
- **Channels (frozen N = 3 public posts + 1 listing):**
  1. r/ClaudeAI — Show & Tell / guide (primary)
  2. r/ObsidianMD — share (secondary)
  3. Obsidian forum — Share & Showcase (tertiary)
  4. Listing in the shared store `~/shared-local/hub/curated/skills/` (internal adoption = bonus signal; **not** one of the 3 public posts).
- **Price hypothesis:** pilot price = **$0 (give away)** — this test measures *demand existence*, not willingness-to-pay. Stage-2 hypothesis (only if PROMOTED, tested in `tool-pilot-02`): a done-for-you setup service at **$50–150/setup**, or a Pro skill bundle.

## Outreach & scoring protocol (mechanical — for the scorer session)

**Queue these jobs** (worker may not edit [[queue]]; runner/Curator to add):
1. `[Smith] FORGE cron-agent-swarm skill` — de-vault the harness into `templates/` + `SKILL.md` + `README.md` per the spec above.
2. `[Human — Z2/outward] APPROVE publish` of the 3 posts (each outward-facing post needs human sign-off).
3. `[Quant] SCORE tool-pilot-01 — at T0+21 days` (T0 = date of first publish, recorded in the RESULT note).

**Scorer steps:**
1. Record T0 (first publish date) and capture a screenshot/snapshot of each post at publish (baseline).
2. At T0+21d, re-read each channel; tally upvotes, comments, and every candidate signal.
3. Classify each candidate against the **frozen** qualified-signal definition; dedupe by person; count `Q`.
4. Apply the verdict table **in order** (NOT SEEN first). Write `wiki/value/tool-pilot-01-RESULT.md` (append-only relative to this note) and update [[ledger]] row 2's Result + Status (status change is Z2 — flag for human/Critic sign-off).

## Deviations & clean negatives (evidence attached)

- **Artifact chosen = the harness skill, not a data product.** Rationale (measured, not vibes): it is our most *demonstrated* asset (engine proven, scripts on disk) and a *measured gap* in the canonical store ([[HARVEST-STATUS]]). The available data products are weak right now — the [[forecast-pilot-01]] batch does not resolve until 2026-09-02, so it cannot be a fast demand artifact.
- **Why this is the fastest revenue evidence:** row 1 is static until 2026-08-04 (first resolution) and scores 2026-09-02. This pilot's verdict lands ~3 weeks after the first publish — earlier — so a KILL or PROMOTE here reaches the ledger sooner.
- **HN deliberately excluded from the frozen set** (high variance lottery); it is a redesign lever if a post returns NOT SEEN, not part of the kill math.

## Verdict

`—` untested. Clock starts at **first publish (T0)**; verdict at **T0 + 21 days**. Until the RESULT note exists, row 2 is aspiration with a defined execution path — build (Smith) → approve (human) → publish → score (Quant).
