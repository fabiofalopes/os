# cron-agent-swarm — 10-minute quickstart

One cron line → a parallel agent swarm that compounds work into your markdown vault while
you sleep. See [SKILL.md](SKILL.md) for the full pattern; this gets you running.

## What this is / isn't

**Is:** a ~400-line bash engine (dispatcher + worker + config) that runs bounded headless
agent sessions on a job queue — parallel workers, model fallback, cost guards, shared-file
protection, self-tuning review. **Isn't:** a framework, a daemon, a chatbot, or anything
that touches your money. Local markdown + cron + your agent CLI.

## Requirements

- `bash ≥ 4`, `flock` + `setsid` (util-linux), `timeout` (coreutils), `python3`
- a headless agent CLI — Claude Code (`claude -p`), opencode, or similar
- a workspace: an Obsidian vault or any directory of markdown notes (a git repo is ideal)

## Install (5 min)

```sh
cd /path/to/your/workspace            # your vault
mkdir -p _harness/state               # state/ must pre-exist: the crontab redirect below
                                      # opens _harness/state/cron.log BEFORE the runner runs
cp /path/to/skill/templates/{runner.sh,worker.sh,config.env,queue.md,schedule.md} _harness/
chmod +x _harness/runner.sh _harness/worker.sh
[ -f CLAUDE.md ] || cp /path/to/skill/templates/CONSTITUTION.md CLAUDE.md
    # ^ don't clobber an existing constitution — merge the zones by hand instead; fill in mission + zones
touch LOG.md                          # runner appends verdicts here (or keep your existing)
    # INDEX.md + MEMORY.md: the bootstrap jobs create them on the first waves — no need to
    # touch them (workers are told not to overwrite notes, so empty stubs just get in the way)
```

If the workspace is a git repo, keep runtime state and secrets out of it:

```sh
printf '_harness/state/\n_harness/secrets.env\n' >> .gitignore
```

Edit the **3 EDIT-ME lines** in `_harness/config.env` — change the *default inside `:-`*,
and keep the `${VAR:-…}` wrapper (it's what lets the dry-run below override via env vars):

```sh
WORKSPACE="${WORKSPACE:-/path/to/your/workspace}"             # your vault
AGENT_BIN="${AGENT_BIN:-/home/you/.npm-global/bin/claude}"    # absolute path — cron's PATH is minimal
MODEL_CHAIN="${MODEL_CHAIN:-provider/cheap provider/strong}"  # or leave empty for the CLI default
```

Using opencode or another CLI? Adjust the flag-dialect dials right below those lines
(`AGENT_RUN_ARGS`, `AGENT_TURNS_FLAG`, `AGENT_MODEL_FLAG`), point `ORIENT_FILES` at your
constitution if it isn't `CLAUDE.md` (opencode reads `AGENTS.md`), and adapt the
`is_routing_failure` grep in `worker.sh` to your CLI's "model unavailable" error text —
it ships matching Claude Code's, and the `MODEL_CHAIN` cascade only fires on a match
(otherwise a dead model surfaces as `exit<N>` instead of cascading). API keys go in
`_harness/secrets.env` (sourced if present — **gitignore it**), one `KEY=value` per line,
e.g. `ANTHROPIC_API_KEY=…` or your proxy's `OPENAI_BASE_URL` / `OPENAI_API_KEY`.

## Add jobs + dry-run (3 min)

Jobs are `- [ ]` lines in `_harness/queue.md` (the template ships with bootstrap jobs).
Test one tick by hand before trusting cron — with the real CLI, or a stub:

```sh
printf '#!/usr/bin/env bash\necho "fake artifact done"\nexit 0\n' > /tmp/stub && chmod +x /tmp/stub
WORKSPACE="$PWD" AGENT_BIN=/tmp/stub MODEL_CHAIN="" bash _harness/runner.sh
cat LOG.md          # expect: one `| ok |` line per claimed job
grep '^- \[x\]' _harness/queue.md   # ok jobs checked off
```

Then run it once with the real `AGENT_BIN` (no env overrides) and read the artifact your
agent actually produced.

## Schedule (1 min)

```sh
crontab -e
# ── agent swarm: one wave every 15 min (runner cd's itself; flock prevents overlap) ──
*/15 * * * * /path/to/your/workspace/_harness/runner.sh >> /path/to/your/workspace/_harness/state/cron.log 2>&1
```

Pick the tick from measured session lengths, not vibes — `schedule.md` explains how.

## Operate (three dials)

1. **LOG.md** — one verdict line per worker; mostly `ok`, each naming an artifact.
2. **queue.md** — feed it; order = priority; one bounded job per line, role-tagged.
3. **config.env** — the bounds. The recurring `[steward] META-REVIEW` job (in the queue
   template) re-tunes these from LOG evidence — that's the self-correcting loop.

## Troubleshooting (read the verdict word)

| Verdict in LOG.md | Meaning | Fix |
|---|---|---|
| `SKIP(PROXY_DOWN)` | preflight TCP probe failed | set/fix `PREFLIGHT_URL`; jobs preserved |
| `TIMEOUT(900s)` | a session hung | raise `SESSION_TIMEOUT` only if sessions are genuinely long |
| `ROUTING_FAIL` | nothing in `MODEL_CHAIN` routed | fix model names/provider; paid default is opt-in |
| `QUARANTINED` | job failed `MAX_JOB_RETRIES` times (real fails only) | job is `[!]` — fix or delete it, queue advanced |
| `SUBSTRATE_VIOLATION` | a worker edited INDEX/MEMORY/etc. | auto-reverted; tighten the job wording |
| `SKIP(EMPTY_QUEUE)` | queue empty, reflection throttled | normal — feed the queue or wait for the 6h review |

## Clean-room findings (2026-07-23 Critic install test)

Installed into a fresh `mktemp -d` workspace following ONLY this quickstart, then ran
fake ticks end-to-end (stub CLI). Every gap found was fixed in place and the full flow
re-verified clean:

1. **LOG lines didn't match the documented format** — runner wrote a doubled date
   (`- 2026-07-23 2026-07-23T01:17:23Z | …`). Fixed: the timestamp is now assembled once
   in `log_line`, producing exactly `- YYYY-MM-DD HH:MM:SSZ | …`.
2. **`ROUTING_FAIL` lines were corrupted** — `used_model="(none routed)"` contains a
   space, so the runner's `read verdict model dur` split it wrong and shifted every
   field. Fixed: `(none-routed)`.
3. **Cron chicken-and-egg** — the crontab line redirects to `_harness/state/cron.log`,
   but `state/` only existed after a first manual run; a fresh clone + crontab died
   silently (exit 2) every tick. Fixed: Install now does `mkdir -p _harness/state`.
4. **Pipe injection** — a `|` in agent output would shift the pipe-delimited LOG fields.
   Fixed: summaries are `tr '|' '/'` before logging. (Still keep `|` out of job text.)
5. **`touch INDEX.md MEMORY.md` contradicted the bootstrap jobs** ("Create INDEX.md")
   and the workers' "don't overwrite notes" rule. Fixed: touch only `LOG.md`; bootstrap
   jobs now say "Create (or fill in, if it already exists)".
6. **`cp CONSTITUTION.md CLAUDE.md` clobbered an existing constitution.** Fixed: guarded
   copy (`[ -f CLAUDE.md ] || cp …`).
7. **No gitignore guidance** for runtime state/secrets. Fixed: Install adds a
   `.gitignore` snippet (`_harness/state/`, `_harness/secrets.env`).
8. **Claude-only assumptions were undocumented** — the `is_routing_failure` grep and the
   `CLAUDE.md` orient file. Fixed: README + `config.env` now say what to adapt for
   opencode/other CLIs (flag dialect, that grep, `ORIENT_FILES`).
9. **`secrets.env` had no example vars.** Fixed: README shows `ANTHROPIC_API_KEY` /
   proxy `OPENAI_*` examples.
10. **META-REVIEW job embedded a literal `$(date -u +%F)`** passed verbatim to the agent.
    Fixed: `<today, YYYY-MM-DD>` placeholder.
11. **EDIT-ME example broke env overrides** — the README showed bare assignments while
    `config.env` uses `${VAR:-…}`; rewriting the line as shown would make the dry-run's
    `AGENT_BIN=/tmp/stub` override silently lose (real CLI invoked). Fixed: the example
    now shows the real `${VAR:-…}` form and says to edit the default inside it.

Known minor (not fixed): on a builder wave, a job that already failed as a worker can be
re-run as the builder the same wave — harmless (it only hastens quarantine).

## Provenance

Extracted from a production vault engine: 15/15 ok sessions → one artifact each, plus a
live proposals-bridge round-trip. Dry-run verified end-to-end, and clean-room install
test passed (see SKILL.md §Evidence).
