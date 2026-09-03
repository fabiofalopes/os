---
tags: [value, quant, tool-skill, pilot, outreach, ledger-row-2, staged]
date: 2026-07-22
status: draft (Z2) — STAGED, human publishes. Nothing here is posted. Outward publish is human-approved per [[tool-pilot-01]].
related:
  - "[[tool-pilot-01]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
---

# Tool Pilot 01 — Outreach Pack (STAGED — human publishes)

> The ready-to-ship outreach for [[tool-pilot-01]] (ledger row 2: "what we build is wanted by
> others"). **Nothing here is published.** A human approves and posts each item (Z2/outward);
> the clock (T0) starts at first publish and is recorded in the RESULT note. This pack's job is
> to make publish a copy-paste, and to make scoring at T0+21d mechanical.
>
> **Artifact under test:** `cron-agent-swarm` — the forged skill at `.forge/skills/cron-agent-swarm/`
> (SKILL.md + README.md + `templates/`). Give it away free at **$0**; demand is the signal.

## Channel decision (follows the FROZEN set — read this first)

The pilot note's kill math is **pre-committed and frozen**. It fixes **N = 3 public posts + 1
internal listing**, and **deliberately excludes HN** (high-variance lottery; a redesign lever,
not part of the kill math). This pack therefore ships **three** posts, to the frozen channels:

| # | Channel | Role | Fit rationale |
|---|---|---|---|
| 1 | **r/ClaudeAI** | primary | Buyer-primary = Claude-Code / coding-agent power users who want autonomous background agents without designing the orchestration. The artifact is agent-CLI-agnostic but Claude Code is the flagship dialect. |
| 2 | **r/ObsidianMD** | secondary | Buyer-secondary = PKM tinkerers who want "an agent that grows my vault." Markdown-native, no lock-in. |
| 3 | **Obsidian forum — Share & Showcase** | tertiary | Same buyer-secondary, longer-lived, search-indexed; lower variance than Reddit. |

> **Deviation from the job ticket, logged per [[Operating Principle — Test Don't Wonder]]:** the
> dispatch ticket named "r/ObsidianMD, r/ClaudeAI, HN Show" as candidates. The frozen
> pre-commitment in [[tool-pilot-01]] supersedes that list: HN is **out** of the T0 batch (it is
> the redesign lever if a post returns NOT SEEN), and the **Obsidian forum** is the frozen third
> channel. A pre-commitment that bends to a later suggestion is not a pre-commitment — so this
> pack honors the frozen N=3. An HN post is nonetheless drafted in **Appendix A**, clearly marked
> **NOT part of T0**, so the redesign lever is ready if needed. The internal listing
> (`~/shared-local/hub/curated/skills/`) is a bonus adoption signal, not one of the 3 public posts.

**Honesty rule for every post (non-negotiable, mirrors the pilot's anti-fooling commitments):**
no hype, no fabricated demand, no performance/ROI claims, no "market-proven." We have *internal*
evidence only (engine proven: 15/15 ok sessions → one artifact each; dry-run verified; `bash -n`
clean). Whether *others* want it is exactly what this test measures — a KILL is a live, honest
outcome. **No astroturfing, no solicited friends, no alt accounts — organic only.**

---

## 0. Publisher checklist (human — do these in order)

1. **Create the public repo** and push `.forge/skills/cron-agent-swarm/` (SKILL.md, README.md,
   `templates/`). Use the README in **§1** as the repo's root `README.md`.
   - ⚠️ **Secret scan before push:** confirm NO plaintext API key ships (the Lusófona key flagged
     in [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]] must never leave). Confirm all
     paths are parameters, no vault-specific names. `git grep -iE 'api[_-]?key|sk-|token' ` → must
     be clean of real secrets.
2. **Replace every `<REPO_URL>` placeholder** below with the live repo URL.
3. **Check each community's self-promo rules** before posting (r/ClaudeAI + r/ObsidianMD flair/
   rules; Obsidian forum Share & Showcase rules). Post as genuine open-source show-and-tell.
4. **Post the 3 channels** (§2a → §2b → §2c). Record T0 = the date/time of the **first** post.
5. **At publish, snapshot each post** (screenshot + save the raw upvote/comment count) — this is
   the baseline row in **Table A**. (HN appendix, if ever used, gets its own baseline.)
6. **Fill Table A + Table B** as signals arrive; the scorer session at T0+21d applies the verdict
   box. Do **not** edit the frozen Q definition or kill thresholds — changes go in the RESULT note.

---

## 1. GitHub README (repo root `README.md`)

*Copy from the line below through the end of §1 into the repo's `README.md`.*

---

# cron-agent-swarm

**One cron line → a parallel agent swarm that compounds work into your markdown vault while you sleep.**

Turn a single `*/15` cron entry into a self-compounding swarm of **headless coding-agent
sessions** over any directory of markdown notes — an Obsidian vault, a wiki, a research log.
Every tick, a dispatcher claims the top jobs from a queue and runs them as **parallel, bounded**
agent sessions. Each worker writes exactly one durable artifact. A recurring review job re-tunes
the engine from its own log.

**No framework. No daemon. No database.** Just `bash` + `cron` + the agent CLI you already use.

## What this is / isn't

**Is:** a ~400-line bash engine (dispatcher + worker + config) that runs bounded headless agent
sessions on a job queue — parallel workers, model fallback, cost guards, shared-file protection,
and a self-tuning review loop.

**Isn't:** a framework, a daemon, a chatbot, or anything that touches your money. Local markdown
+ cron + your agent CLI. Nothing phones home.

## Why it exists

Running one agent session by hand is easy. Running a *fleet* of them on a schedule, without a
hung model wedging your cron, a poisoned job draining your quota, or parallel writers corrupting
shared state — that's the hard part. This is the pattern that runs a real production vault,
packaged so you can stand it up over your own notes in ~10 minutes.

```
cron (*/15) ──▶ runner.sh ── flock (one wave at a time)
                 │          ── daily cap · proxy preflight · poisoned-job breaker
                 ├─ claims up to WORKERS_PER_TICK jobs from queue.md
                 │     ├─ worker 0 ─▶ agent CLI ─▶ writes ONE artifact
                 │     ├─ worker 1 ─▶ agent CLI ─▶ writes ONE artifact
                 │     └─ worker 2 ─▶ agent CLI ─▶ writes ONE artifact
                 │          (model fallback chain; whole loop bounded by WORKER_BUDGET)
                 ├─ snapshot/REVERT shared substrate (index/memory are read-only to workers)
                 ├─ logs ONE verdict line per worker to LOG.md; checks off the ok ones
                 └─ every Nth wave: a deeper "builder" session (and your council.sh, if you add one)

queue empty ──▶ at most one reflection per REFLECT_EVERY (default 6h); it stages jobs the
                runner merges back into the queue — the swarm feeds itself.
```

## Features

- **Parallel independent work, not debate** — N workers each finish a distinct job per tick. Value
  comes from parallel *work*, not agents arguing.
- **Bounded everywhere** — `--max-turns`, per-model session timeout, a whole-cascade worker
  budget, and a daily session ceiling. A hung model or poisoned job can never wedge the cron or
  drain your quota.
- **Substrate integrity** — shared files (log, index, memory, queue) are snapshot before each wave
  and auto-reverted if a worker touches them. Parallel writers can't corrupt shared state.
- **Model fallback, spend-safe** — a cheap/free → stronger chain; if nothing routes, it logs
  `ROUTING_FAIL` instead of silently spending paid quota.
- **Observable + self-tuning** — every tick lands as one pipe-delimited line in `LOG.md`; a
  recurring review job rewrites the queue + config from that log, so the harness tunes its own
  cadence from measured session lengths.
- **Agent-CLI-agnostic** — Claude Code (`claude -p`), opencode, or any headless CLI that takes a
  prompt + model flag (flag-dialect dials in `config.env`).
- **Governance template included** — a constitution with three zones (agent-owned / agent-drafts-
  human-approves / human-only) that keeps workers from trashing shared state or doing irreversible
  things unsupervised.

## Requirements

- `bash ≥ 4` (associative arrays), `flock` + `setsid` (util-linux), `timeout` (coreutils), `python3`
- a headless agent CLI — Claude Code, opencode, or similar
- a workspace: an Obsidian vault or any directory of markdown notes (a git repo is ideal)

## Quickstart (10 minutes)

```sh
cd /path/to/your/workspace            # your vault
mkdir -p _harness
cp /path/to/skill/templates/{runner.sh,worker.sh,config.env,queue.md,schedule.md} _harness/
chmod +x _harness/runner.sh _harness/worker.sh
cp /path/to/skill/templates/CONSTITUTION.md CLAUDE.md   # fill in mission + zones
touch LOG.md INDEX.md MEMORY.md       # seed the shared substrate (or keep your existing)
```

Edit the **3 EDIT-ME lines** in `_harness/config.env`:

```sh
WORKSPACE="/path/to/your/workspace"           # your vault
AGENT_BIN="/home/you/.npm-global/bin/claude"  # absolute path — cron's PATH is minimal
MODEL_CHAIN="provider/cheap provider/strong"  # or leave empty for the CLI default
```

Add jobs as `- [ ]` lines in `_harness/queue.md`, then dry-run one tick by hand before trusting
cron (a stub CLI works — see the full README in-repo). Then schedule it:

```sh
crontab -e
# one wave every 15 min (flock prevents overlap)
*/15 * * * * /path/to/your/workspace/_harness/runner.sh >> /path/to/your/workspace/_harness/state/cron.log 2>&1
```

Full quickstart, the three operating dials (LOG / queue / config), and a troubleshooting table
(verdict words → fixes) live in the repo's `README.md`.

## What's in the box

```
cron-agent-swarm/
├── SKILL.md            ← the pattern (mental model, why it holds together, tuning dials)
├── README.md           ← 10-minute quickstart + troubleshooting
└── templates/
    ├── runner.sh       ← wave dispatcher (cron entry point)
    ├── worker.sh       ← one bounded agent session + model fallback
    ├── config.env      ← every path/model/bound is a parameter (3 EDIT-ME lines)
    ├── queue.md        ← job-queue format + bootstrap jobs + self-review job
    ├── schedule.md     ← how to pick and re-tune the tick from evidence
    └── CONSTITUTION.md ← governance template (install as CLAUDE.md / AGENTS.md)
```

## Provenance & honesty

Extracted from a production vault engine that ran **15/15 ok sessions → one durable artifact
each**, plus a live proposals-bridge round-trip. Dry-run verified end-to-end (stub CLI, scratch
workspace: parallel wave → queue drain → empty-queue reflection → bridge merge → bridged job `ok`;
substrate files byte-identical after every wave). `bash -n` clean on all scripts.

To be straight with you: this is v1, packaged from one working engine. It's proven on *our*
vault — whether it's useful on *yours* is what we're trying to find out. If you set it up, tell us
what broke, what's missing, or what you'd want it to do. That feedback is the whole point.

## License

MIT *(publisher: confirm/add a LICENSE file before push).*

---

## 2. Channel posts (the frozen 3)

*Each post is wrapped for clean copy-paste. Replace `<REPO_URL>` before posting. Tone is honest
show-and-tell — no hype, no fabricated demand. The closing question is a genuine ask for organic
feedback (install reports / setup questions / feature requests), never solicited signal.*

### 2a. r/ClaudeAI — primary (Show & Tell / guide)

**Suggested title:** `I put Claude Code on a cron schedule with parallel workers — it compounds work into my notes while I sleep (open source, ~400 lines of bash)`

```text
I got tired of babysitting individual Claude Code sessions, so I built a small engine that runs
a whole swarm of them on a schedule, unattended, over a folder of markdown notes (my Obsidian
vault).

The idea: one cron line fires every 15 minutes. A dispatcher claims the top few jobs from a
queue and runs them as PARALLEL, bounded headless Claude sessions. Each worker writes exactly
one artifact (a note, a summary, a research clip), the dispatcher logs one verdict line per
worker, and a recurring review job re-tunes the schedule from its own log. No framework, no
daemon, no database — bash + cron + the claude CLI.

The hard parts it handles, which are why I bothered packaging it:
- Bounded everywhere: max-turns, per-model timeout, a whole-cascade budget, and a daily session
  cap — a hung model or a poisoned job can't wedge the cron or burn my quota.
- Model fallback: a cheap/free -> stronger chain; if nothing routes it logs a failure instead of
  silently spending paid tokens.
- Substrate protection: shared files (index/memory/log) are snapshot before each wave and
  auto-reverted if a worker touches them, so parallel writers can't corrupt state.
- CLI-agnostic: it's flag-dialect dials, so opencode or another headless CLI works too.

It's ~400 lines of bash. It's extracted from the engine that actually runs my vault (15/15 clean
sessions -> one artifact each), and I dry-ran the packaged version end-to-end before sharing.

Being honest: it's v1 from one working setup. I don't know yet if it's useful on anyone else's
vault — that's genuinely what I'm trying to find out. It's free, no telemetry, nothing phones
home.

<REPO_URL>

If you stand it up, I'd actually love to know: what broke, what's missing, or what you'd want a
background agent swarm to do on your notes that this doesn't yet.
```

### 2b. r/ObsidianMD — secondary (share)

**Suggested title:** `An agent swarm that grows your vault while you sleep — open source, markdown-native, no plugin required`

```text
I built a way to have AI agents work on my Obsidian vault unattended, on a schedule, without a
plugin and without any lock-in.

It's not a plugin — it's a small bash engine that runs on cron. Every 15 minutes it picks the top
tasks from a queue and runs them as parallel, bounded headless agent sessions (Claude Code,
opencode, or any CLI agent). Each one writes exactly one note/artifact into your vault. A review
job periodically re-tunes the schedule from its own log. Everything is plain markdown + cron +
git — your vault stays yours, nothing phones home.

What it's for: the "I wish an agent would just do the boring vault work overnight" case —
triaging inbox notes, writing summaries, clipping and linking research, keeping an index current.
You feed it a job queue; it compounds the work while you sleep.

The guardrails, because an unattended agent in your vault is scary:
- Bounded sessions (max-turns, timeout, daily cap) so nothing runs away.
- Shared files (index/memory/log) are protected — snapshot before each wave, auto-reverted if a
  worker touches them, so parallel agents can't corrupt your vault.
- A governance template (a "constitution") that tells workers what they may and may not touch.

Honest caveats: it's v1, packaged from the one engine that runs my own vault (which has been
clean for 15/15 sessions). It's more "comfortable in a terminal" than turnkey — you copy a few
scripts, edit 3 config lines, add a cron entry. And I genuinely don't know yet if it's useful on
anyone else's vault; that's what I'm hoping to learn.

It's free and open source:
<REPO_URL>

If you try it on your vault, tell me what you'd want it to do that it doesn't yet — or what broke.
That feedback is the whole reason I'm sharing it.
```

### 2c. Obsidian forum — Share & Showcase (tertiary)

**Suggested title:** `[Share] cron-agent-swarm — a scheduled, parallel AI agent engine that works on your vault (open source, markdown-native)`

```text
Hi all — sharing a tool I built for myself and am releasing as open source. It runs a scheduled
swarm of AI agents that do work on your Obsidian vault unattended, and it's deliberately
markdown-native: no plugin, no proprietary format, no telemetry. Your vault stays plain markdown
+ git.

What it does
A single cron line fires on an interval (I use every 15 minutes). A dispatcher reads a job queue
you maintain and runs the top jobs as parallel, bounded headless agent sessions — Claude Code,
opencode, or any CLI agent. Each session writes exactly one artifact into your vault (a summary,
a research clip, inbox triage, an index update). A recurring review job re-tunes the schedule
from the engine's own log.

Why I built it this way
I wanted "an agent that grows my vault overnight" without handing my notes to a hosted service or
installing a plugin that owns the format. The whole thing is ~400 lines of bash + cron + git, so
it's auditable and portable.

Guardrails (because unattended agents in a vault are risky)
- Bounded sessions: max-turns, per-model timeout, whole-run budget, and a daily session cap.
- Substrate protection: shared files (index/memory/log) are snapshot before each wave and
  auto-reverted if a worker edits them, so parallel agents can't corrupt shared state.
- A governance template ("constitution") that defines what agents may touch vs. what stays
  human-only.

Honest status
This is v1, extracted from the single engine that runs my own vault (clean for 15/15 sessions)
and dry-run verified end-to-end as a package. It's more terminal-friendly than turnkey, and I
don't yet know whether it's useful on other people's vaults — that's exactly what I'd like to
find out from this community.

It's free and open source: <REPO_URL>

I'd welcome honest feedback: what would you want a scheduled agent swarm to do on your vault that
this doesn't handle yet? And if anyone sets it up, please report what breaks — that's the most
useful thing you can give me.
```

---

## 3. T0 tracking sheet (scorer fills this — mechanical)

> **T0 = date/time of the FIRST published post.** Record it in the RESULT note. Verdict at
> **T0 + 21 days.** The Q definition and kill thresholds below are **FROZEN** (copied verbatim
> from [[tool-pilot-01]]); the scorer classifies against them and never edits them.

**T0 (first publish):** `____` (fill at publish)  ·  **Verdict due (T0+21d):** `____`

### Table A — Visibility (feeds the NOT-SEEN check, applied FIRST)

*Snapshot baseline at publish; re-read at T0+21d. "Status" = live / removed / locked.*

| Channel | Post URL | Published (date/time) | Status @T0+21d | Baseline ↑ | Baseline 💬 | Final ↑ | Final 💬 |
|---|---|---|---|---|---|---|---|
| r/ClaudeAI (primary) | `<url>` | | | | | | |
| r/ObsidianMD (secondary) | `<url>` | | | | | | |
| Obsidian forum (tertiary) | `<url>` | | | | | | |
| **COMBINED (all channels)** | — | — | — | — | — | **Σ↑ =** | **Σ💬 =** |

**NOT-SEEN test (check FIRST):** every post removed/locked, **OR** combined (Σ↑ + Σ💬) `< 10`?
→ `____` (YES = NOT SEEN: no thesis verdict; one redesign allowed, clock resets at re-publish —
the HN lever in Appendix A is ready. NO = seen, proceed to Table B.)

### Table B — Q-signal tally (FROZEN qualified-interest definition)

**A signal counts ONCE per distinct person.** Add one row per candidate signal as it arrives.

**Qualifies (6 frozen categories):**
1. install / usage report ("I set this up and …")
2. a substantive setup question (more than "cool")
3. a fork / clone of the published repo, or a star accompanied by a comment
4. a DM or comment requesting help or a feature
5. a comment expressing intent to use ("going to try this for my vault")
6. any offer to pay, or request for paid help

**Does NOT count:** upvotes alone · "cool/nice" comments · downvotes · silence · **any signal from
our own alt accounts or solicited friends (none — organic only).**

| # | Date | Channel | Person/handle | Cat (1–6) | Verbatim evidence (quote/link) | Distinct person? (dedupe) | Qualifies? (Y/N) | If N, why | **DIRECT request / offer to pay?** |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |
| | | | | | | | | | |
| | | | | | | | | | |

**Q =** count of rows with `Qualifies? = Y`, deduped by distinct person = `____`
**Any DIRECT request / offer to pay / "would you set this up for me"?** (Y/N) = `____`

### Verdict box (apply IN ORDER — do not skip ahead)

| Step | Condition | Verdict | Consequence for [[ledger]] row 2 |
|---|---|---|---|
| 1 | NOT-SEEN test = YES (all removed/locked, OR Σ↑+Σ💬 < 10) | **NOT SEEN** | No thesis verdict. One redesign allowed (e.g. HN lever); clock resets at re-publish. |
| 2 | Seen AND `Q = 0` at T0+21d | **KILL** | Row 2 → `killed` for this artifact+buyer+channel. "What we build is wanted" falsified here. |
| 3 | `Q ≥ 3`, **OR** `≥ 1` direct request / offer to pay / "set this up for me" | **PROMOTE** | Row 2 → `paper`; test Stage-2 price hypothesis in `tool-pilot-02` ($50–150/setup or Pro bundle). |
| 4 | `Q ∈ {1,2}` and no direct request | **WEAK / INCONCLUSIVE** | One redesign allowed with a *documented change* — never a re-post of the same thing. |

**Verdict (fill at T0+21d):** `____`  ·  **Reasoning + step applied:** `____`

> Scorer: write the full result to `wiki/value/tool-pilot-01-RESULT.md` (append-only relative to
> [[tool-pilot-01]]) and update [[ledger]] row 2's Result + Status. A status change is **Z2** —
> flag for human/Critic sign-off. A PROMOTE at this scale is "a demand signal worth a bigger
> test," **not** "market proven."

---

## Appendix A — HN "Show HN" post (REDESIGN LEVER — **NOT posted at T0**)

> **Not part of the frozen T0 batch.** HN is excluded from the kill math (high-variance lottery);
> it is the documented redesign lever if a frozen-channel post returns **NOT SEEN**. Staged here
> so the lever is ready — a human decides whether/when to pull it, and only as the *one* allowed
> redesign (clock resets at that publish).

**Title:** `Show HN: cron-agent-swarm – a parallel AI agent swarm over your markdown vault, in ~400 lines of bash`

```text
I run a fleet of headless coding-agent sessions on a cron schedule over a folder of markdown
notes (an Obsidian vault), and I've packaged the engine as open source.

One cron line fires every 15 minutes. A dispatcher claims the top jobs from a queue and runs them
as parallel, bounded agent sessions (Claude Code, opencode, or any headless CLI). Each worker
writes exactly one artifact; the dispatcher logs one verdict line per worker; a recurring review
job re-tunes the schedule from its own log. No framework, daemon, or database — bash + cron +
your agent CLI.

The problems it solves are the reason it exists:
- Bounded everywhere (max-turns, per-model timeout, whole-run budget, daily cap) so a hung model
  or poisoned job can't wedge cron or drain quota.
- Model fallback chain, cheap/free -> stronger; logs a failure rather than silently spending.
- Substrate integrity: shared files are snapshot pre-wave and auto-reverted if a worker edits
  them, so parallel writers can't corrupt state.

It's extracted from the engine that runs my own vault (15/15 clean sessions -> one artifact each)
and dry-run verified end-to-end as a package. Honest caveat: it's v1 from one working setup, and
whether it's useful on anyone else's vault is an open question I'd like feedback on.

<REPO_URL>

Happy to answer how it works or what broke when you try it.
```

---

## Provenance of this pack

- Drafted 2026-07-22 by a Quant cron worker, grounded in the forged skill at
  `.forge/skills/cron-agent-swarm/` (SKILL.md + README.md, read in full) and the frozen
  pre-commitment in [[tool-pilot-01]].
- Channel set follows the **frozen N=3** (r/ClaudeAI, r/ObsidianMD, Obsidian forum); HN staged
  only as the redesign lever (Appendix A). Deviation from the dispatch ticket's candidate list is
  logged above, per the test-don't-wonder principle.
- All public claims are limited to the skill's documented evidence (15/15 provenance, dry-run
  PASS, `bash -n` clean). No demand, performance, or ROI claims — demand is what the pilot tests.
- **Nothing published.** Staged for human approval (Z2/outward).
