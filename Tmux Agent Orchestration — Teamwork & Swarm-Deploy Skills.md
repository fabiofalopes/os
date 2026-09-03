---
tags:
  - harness
  - orchestration
  - tmux
  - multi-agent
  - skills
date: 2026-07-23
status: living
---

# Tmux Agent Orchestration — Teamwork & Swarm-Deploy Skills

A two-skill layer for running multiple AI coding agents (Claude Code, opencode) as
parallel tmux panes that coordinate **through files, not screen-scraping**. Distinct
from the `_harness/` cron wave-engine ([[multi-agent-orchestration-patterns]]) — this
one drives live interactive agent sessions in tmux panes.

## The two skills (`~/.claude/skills/`)

### teamwork — tracking & supervision
Maps each tmux pane → agent process → on-disk session (Claude transcript `.jsonl`, or
`opencode.db` `session` row keyed by its `directory`), keeps per-session goals/track
records, and a manager that judges **continue / done / carry-over** per session per tick.
- `registry.py` — pane↔session map; stable `bindings.json` (argv > binding > recency)
- `manager.py` — `status / report / watch / drive / spawn / carry / done / stop`
- State: `~/.claude/teamwork/<window>/` — `registry.json`, `bindings.json`, `track/<session>.json`, `STATUS.md`, `manager.log`
- Verdicts: `skip / leave / review / stale` — computed from files only, never TUI parsing.
- Process state overrides liveness: `no-session / stopped / zombie`.

### swarm-deploy — the team launcher
Given a goal + N roles, deploys an N-pane tmux team (one cwd per role → clean binding),
labels by role, launches the wrapper, then hands off to teamwork for tracking.
- `swarm.py <window> <workspace-root> role1 ... roleN` → prints a JSON role→pane map
- Bakes in the hard-won pitfalls: >5-pane window sizing, cwd-based (not positional)
  labeling, two-flag bypass, per-role cwd. Self-tested.

## The launch command (always)
```
claude-alibaba-qwen38m --effort low --allow-dangerously-skip-permissions --dangerously-skip-permissions
```
See [[Claude Code No-Login on New Tmux Panes]] for why plain `claude` fails and why the
two permission flags are not redundant.

## Live instances
- **window 2 `tinigrad`** — orchestrator + scout + bounty; the original proving ground.
- **window 4 `hive`** — 3 agents that completed the skill ecosystem (freebuff-tui +
  tmux-pane-interaction manifests, teamwork test suite 14/14 PASS).
- **window 5 `quant`** — 8-role research→deployment pipeline for trading knowledge
  (cartographer / theory / microstructure / alpha / data / backtest / risk / synthesizer),
  writing notes to `quant/` in this vault; supervised by a durable cron (`:13`,`:43`).

## Coordination model
Agents coordinate **only through files** (shared workspace + vault notes). A `watch`
supervisor logs transitions; a durable cron periodically runs `manager.py report`,
nudges stale sessions, and reports progress. `drive` mode (opt-in) is the only mode that
sends keystrokes.

## Related
- [[multi-agent-orchestration-patterns]] — the `_harness/` cron wave-engine (file-queue system)
- [[Agent Roles & Orchestrator — The Moat]] — the orchestration-layer-is-the-moat thesis
- [[Claude Code No-Login on New Tmux Panes]] — launch/auth failure modes + rescue
- [[Claude Code Proxy Pattern — Master Reference]] — the proxy the wrapper drives
