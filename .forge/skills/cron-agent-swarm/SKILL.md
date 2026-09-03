---
name: cron-agent-swarm
description: Stand up a cron-driven parallel-agent swarm over any markdown/Obsidian vault — one clock, N parallel role-tagged workers per tick each writing one durable artifact, with cost guards, model fallback, substrate protection, and a self-tuning review loop. Extracted from a production engine (15/15 ok sessions). Agent-CLI-agnostic (Claude Code / opencode / any headless CLI).
version: 1.0.0
tags: [cron, orchestration, multi-agent, claude-code, opencode, obsidian, pkm, automation]
metadata:
  kind: pattern
  status: draft (Z2) — built for the tool-pilot-01 demand test; publish is human-approved
---

# cron-agent-swarm

Turn one cron line into a **self-compounding agent swarm** over a directory of markdown
notes (an Obsidian vault, a wiki, a research log). Every tick, a dispatcher claims the
top jobs from a queue and runs them as **parallel, bounded, headless agent sessions** —
each worker writes exactly one durable artifact, the dispatcher logs one verdict line per
worker, and a recurring review job re-tunes the engine from its own log. No framework, no
daemon, no database: `bash` + `cron` + your agent CLI.

## Mental model

```
cron (*/15) ──▶ runner.sh  ── flock (one wave at a time)
                 │           ── daily cap · proxy preflight · poisoned-job breaker
                 │
                 ├─ claims up to WORKERS_PER_TICK jobs from queue.md (target de-dup)
                 │     ├─ setsid worker.sh 0  ─▶ agent CLI ─▶ writes ONE artifact
                 │     ├─ setsid worker.sh 1  ─▶ agent CLI ─▶ writes ONE artifact
                 │     └─ setsid worker.sh 2  ─▶ agent CLI ─▶ writes ONE artifact
                 │           (model fallback chain; whole loop bounded by WORKER_BUDGET)
                 ├─ snapshot/REVERT shared substrate (INDEX/MEMORY are read-only to workers)
                 ├─ logs ONE verdict line per worker to LOG.md; checks off the ok ones
                 └─ every Nth wave: a serial "builder" session (deeper job, bigger budget)
                    — and your council.sh if you drop one in (hook is inert without it)

queue empty ──▶ at most one [steward] reflection per REFLECT_EVERY (default 6h);
                it stages jobs in proposals.md; the runner bridge-merges them into the
                queue (workers never write the queue) ── the swarm feeds itself.
```

## What's in the box

```
cron-agent-swarm/
├── SKILL.md                 ← this document (the pattern)
├── README.md                ← 10-minute quickstart + troubleshooting
└── templates/
    ├── runner.sh            ← wave dispatcher (cron entry point)
    ├── worker.sh            ← one bounded agent session + model fallback
    ├── config.env           ← every path/model/bound is a parameter (3 EDIT-ME lines)
    ├── queue.md             ← job queue format + bootstrap jobs + self-review job
    ├── schedule.md          ← cadence: how to pick and re-tune the tick from evidence
    └── CONSTITUTION.md      ← governance template (install as CLAUDE.md / AGENTS.md)
```

## The pattern (why it holds together)

1. **One clock, tiered by wave count.** A single `*/15` cron line drives everything; a
   persistent wave counter decides when the deeper "builder" session (or an optional
   council) runs. No second scheduler, no drift.
2. **Parallel independent WORK, not debate.** Value comes from N workers each finishing a
   distinct job per tick — not from agents arguing. Concurrency is cheap; coordination is
   the only tax (target de-dup + serial logging).
3. **Bounded everywhere.** `--max-turns`, per-model `SESSION_TIMEOUT`, a whole-cascade
   `WORKER_BUDGET`, and a `MAX_SESSIONS_PER_DAY` ceiling — a hung model or poisoned job
   can never wedge the cron or drain your quota.
4. **Substrate integrity.** Workers are prompted read-only on shared files (log, index,
   memory, queue) AND enforced: the runner snapshots those files pre-wave and reverts any
   change, logging a `SUBSTRATE_VIOLATION`. Parallel writers can't corrupt shared state.
5. **Observable + self-tuning.** Every tick lands as one pipe-delimited line in LOG.md
   (format below). The recurring [steward] META-REVIEW job reads that log and rewrites the
   queue + config — the harness tunes its own cadence from measured session lengths.
6. **Model fallback, spend-safe.** `MODEL_CHAIN` cascades cheap/free → stronger; if
   nothing routes, the worker logs `ROUTING_FAIL` instead of silently spending paid quota.

## LOG.md line format (the API everything parses)

```
- YYYY-MM-DD HH:MM:SSZ | <dur>s | <verdict> | <model> | <job text> | <one-line summary>
```

Verdicts: `ok` · `exit<N>` · `TIMEOUT(<s>s)` · `ROUTING_FAIL` · `SKIP(PROXY_DOWN)` ·
`SKIP(EMPTY_QUEUE)` · `QUARANTINED` (breaker tripped) · `BRIDGE` (proposal merged) ·
`SUBSTRATE_VIOLATION` (worker touched shared state — auto-reverted).

## Governance (what keeps workers from trashing things)

Ship a constitution (`CONSTITUTION.md` → `CLAUDE.md`) with three zones: **Z1** agent-owned
(links, index, triage) · **Z2** agent-drafts/human-approves (synthesis, anything
outward-facing) · **Z4** human-only (the constitution, spend ceilings, irreversible acts).
Workers are told to obey it, write one new artifact each, and never touch git or capital.

## Requirements

`bash ≥ 4` (associative arrays) · `flock`, `setsid`, `timeout` (util-linux/coreutils) ·
`python3` (atomic queue edits) · a headless agent CLI (Claude Code `claude -p`, opencode,
or anything that takes a prompt + model flag — see the flag-dialect dials in config.env).

## Tuning dials (config.env)

`WORKERS_PER_TICK` (parallelism; drop if you see 429s) · `MAX_SESSIONS_PER_DAY` ·
`MAX_TURNS` / `SESSION_TIMEOUT` / `WORKER_BUDGET` (the three bounds) · `BUILDER_EVERY` ·
`MODEL_CHAIN` · `REFLECT_EVERY`. See `templates/schedule.md` for how to pick the tick from
measured session lengths instead of vibes.

## Extensions (bring your own)

- **Council** — drop a `council.sh` in the harness dir; the runner calls it every
  `COUNCIL_EVERY`-th wave with the wave number. Keep it probationary: only leave it on
  while it beats the single-agent baseline on a measured A/B.
- **Curator/committer** — a serial job (not a worker) that catalogs new notes into the
  index and makes small git commits. Workers deliberately never run git.

## Evidence (test, don't wonder)

- **Provenance:** de-vaulted from a production engine that ran **15/15 ok sessions → one
  durable artifact each**, plus a live proposals-bridge round-trip (2026-07-22). No
  Forge-specific names, paths, or secrets shipped; vault path + agent CLI + models are
  parameters; the plaintext API key in the source vault was never copied.
- **`bash -n` clean** on `runner.sh`, `worker.sh`, `config.env` (2026-07-22).
- **Dry-run PASS** (stub agent CLI, scratch workspace, 2026-07-22): 6 ticks executed
  end-to-end — 3-worker parallel wave → queue drain → empty-queue reflection →
  `SKIP(EMPTY_QUEUE)` throttle → bridge merge → bridged job ran `ok`. 6 `ok` lines +
  1 throttle SKIP in LOG.md; 5 jobs checked off; proposal flipped `[>]`; substrate files
  byte-identical after every wave; wave counter advanced to 6.
- **Clean-room install test PASS** (Critic, fresh `mktemp -d` workspace, no prior vault
  knowledge, 2026-07-23): README quickstart followed verbatim → 12+ ticks end-to-end
  covering 3-worker wave, builder wave, queue drain, reflection, throttle SKIP, proposal
  bridge round-trip, `SUBSTRATE_VIOLATION` detect-and-revert (rogue stub), model cascade
  (`modelA`→`modelB`), `ROUTING_FAIL`, `TIMEOUT`, and edited-`config.env` (no env
  override) path. The test caught and fixed: doubled-date LOG timestamps (code now
  matches the documented format), a space in `(none routed)` corrupting `ROUTING_FAIL`
  log fields, the cron-redirect chicken-and-egg on `state/`, and pipe-injection from
  agent output into the log. Findings list in README §Clean-room findings.
