---
tags:
  - harness
  - planning
  - cron
  - swarm
  - forge
  - meta
date: 2026-07-20
status: design v1 — research + plan
related:
  - "[[The Forge — OpenCode Knowledge Governance Design]]"
  - "[[Agent Loop Skill — Iterate-Until Pattern]]"
  - "[[alibaba-token-plan-20-07-2026]]"
---

# Daily Cron Sessions — Swarm Harness Master Plan

> **Status: DESIGN v1 (2026-07-20).** Research + architecture for turning the vault into a self-compounding "child brain" run by a daily cron swarm. Builds on [[The Forge — OpenCode Knowledge Governance Design]] (capture→consolidate→forge) and the live `fleet-optimizer` loop, and pulls in two new external engines: **microsoft/SkillOpt** (skill *optimization*) and **huggingface/skills** (skill *catalog*). Living doc.

---

## 0. North star

The vault is the durable mind; sessions are ephemeral thoughts. We want a harness that, **every day and largely unattended**:

1. **Researches** domains we care about (AI/ML, computer engineering, finance/markets, automation, modeling, edge) and writes findings into the vault.
2. **Curates / organizes / cleans** what accumulates — dedupe, link, tag, MOC, prune rot.
3. **Distills** sessions and research into durable knowledge (wiki) and reusable **skills**.
4. **Forges and optimizes skills** so the agents get measurably better at the tasks they repeat.
5. **Creates value** — the hard constraint: *the harness must make money or it fails.* Every loop should trace to an asset (a skill, a note, a signal, a tool) that compounds toward that.

The mind starts as a child brain mapped by the harness, and is nurtured to grow toward a "quant"-grade capability: robust, self-improving, able to use the whole vault in every session to write notes, spawn ideas, discover, curate, and interact with humans.

**Design tension to hold the whole way:** run *as much as possible* **without** token-burning. The answer is not "fewer loops" — it is **cheap models at cheap hours + tight caps + validation gates** (see §6, §7).

---

## 1. Grounded inventory (what already exists — do not rebuild)

| Asset | State | Role in the new plan |
|---|---|---|
| **The Forge design** (`The Forge — OpenCode…`) | Design v2, Oracle-reviewed, MVP deferred | The governance + 3-tier loop backbone. Reuse verbatim; only the *adapter* changes (this session is Claude Code, Forge was specced for OpenCode). |
| **`fleet-optimizer` cron** (`~/.config/opencode/agent-loops/fleet-optimizer/loop.sh`) | **LIVE**, hourly, self-tuning (`tuning.json`), checks proxy/rpi/vault_sync/providers | The **infra-health** loop. Keep it. It is the template for "self-tuning cron with state + metrics + reports." |
| **Iterate-Until loop pattern** | Design proposal, not yet a SKILL.md | The persistence primitive every swarm worker uses (GOAL/CONDITION/MAX/ACTIONS/EVAL/ADJUST). |
| **22 Obsidian skills** in `~/.claude/skills/` | Installed (moc-builder, smart-tagger, orphan-connector, zettel-atomizer, glossary-builder, serendipity-engine, fleeting-processor, obsidian-stats, smart-web-clipper, …) | The **curation toolkit** the swarm wields. Already covers most clean/organize/distill jobs. |
| **Alibaba/Qwen token plan** (`alibaba-token-plan-20-07-2026`) | Active 30d, Anthropic-compatible endpoint, **night 22:00–08:00 = 0.2× price** | The **cheap compute** for overnight swarm runs. This is the key to "run a lot, spend little." |
| **Proxy pattern** (`Claude Code Proxy Pattern — Master Reference`) | Documented | Lets cron sessions target cheap/local providers transparently. |

**Gap:** nothing yet does *daily knowledge work* on a schedule. `fleet-optimizer` watches infra; Forge is designed but unbuilt; no skill-optimization loop exists. This plan fills those three gaps.

---

## 2. The two new engines

### 2a. microsoft/SkillOpt — the skill *forge/optimizer*

A "text-space optimizer" for **frozen** LLM agents: it trains the **skill document**, not the weights.

- **Loop:** `rollout → reflect → aggregate → select → update → evaluate`.
- **Gate:** an edit is kept **only if it raises a held-out validation score** (validation-gated). This is exactly the "promote only above threshold" discipline Forge already wants — SkillOpt gives us a battle-tested implementation of it.
- **Stability knobs:** textual learning-rate budget, rejected-edit buffer, epoch-wise slow/meta update → safe to run unattended.
- **Output:** a compact `best_skill.md` (≈300–2000 tokens) deployed with **zero extra inference calls**.
- **`SkillOpt-Sleep`** (v0.2.0): **offline self-evolution CLI** — designed to run while idle. This is our **overnight skill-forging engine**.
- **Harnesses:** direct chat, Codex CLI, **Claude Code CLI**. Backends incl. Qwen. `pip install skillopt`.

**What it gives us:** the "skill forging" the vision asks for, done *rigorously* — skills improve against measured tasks, not vibes. It is the Tier-2 Forge "extract/refine a skill" step, made automatic and gated.

### 2b. huggingface/skills — the skill *catalog / seed stock*

A catalog of standardized **Agent Skills** (folder + `SKILL.md` + YAML frontmatter + scripts), consumed by Claude Code / Codex / Gemini / Cursor.

- Install with `hf skills add <skill-name>`; bootstrap with `hf-cli`.
- Domains: datasets, papers, Gradio/Spaces, LLM/vision/sentence-transformer training, local models, evals, SageMaker deploy, tool-building.

**What it gives us:** (1) **seed skills** so the swarm isn't starting from zero in ML/finance-adjacent tooling; (2) a **format standard** to forge our own skills into, so they're portable across harnesses (matches Forge §8 portability goal).

---

## 3. The daily cron swarm — roles

One scheduled "day" fans out into specialized workers. Each is an **Iterate-Until** loop with a bounded budget and a validation gate. Roles map to the verbs in the vision: *researching, writing, curating, organizing, cleaning, distilling.*

| Role | Fires | Does (with existing tools) | Writes to |
|---|---|---|---|
| **Scout** (research) | daily | Web/web-search a domain queue; clip clean markdown (`smart-web-clipper`, `defuddle`) | `inbox/`, `wiki/research/` |
| **Scribe** (write) | on new research/ideas | Turns raw clips + session sparks into atomic notes (`zettel-atomizer`), drafts idea notes | `wiki/`, `projects/` |
| **Curator** (organize) | daily | Tag (`smart-tagger`), link orphans (`orphan-connector`), build/refresh MOCs (`moc-builder`), glossary (`glossary-builder`) | frontmatter, links, `INDEX.md` |
| **Janitor** (clean) | daily | Lint markdown (`markdown-linter`), heal broken links (`broken-link-healer`), dedupe, prune rot | vault-wide |
| **Distiller** (distill) | on N new session digests | Session→digest→durable knowledge; stage skill candidates (Forge Tier-1) | `journal/sessions/`, `wiki/`, `.forge/skills/` |
| **Smith** (forge/optimize) | nightly (cheap hours) | Runs **SkillOpt / SkillOpt-Sleep** over staged skill candidates vs. a task benchmark; promotes `best_skill.md` only if validation improves | `.forge/skills/`, `LOG.md` |
| **Steward** (govern/health) | daily | Contiguity check on `LOG.md`, cap enforcement, cost report, surfaces dead timers | `LOG.md`, health flag |

**Orchestration:** a thin scheduler (cron → shell wrapper, same shape as `fleet-optimizer/loop.sh`) runs the roles in dependency order: `Scout → Scribe → Curator/Janitor (parallel) → Distiller → Smith → Steward`. Each role is its own agent invocation with a **per-role token cap** and reads/writes only its governed folders (Forge §4 zones).

**Mega-practice crossover:** the same swarm pattern runs at two altitudes — (a) *on the vault* (knowledge work, above) and (b) *on the skills themselves* (Smith optimizing the workers' own skills). The harness improves the harness. This is the "healthy spurious-like growth" made concrete: a feedback loop where better skills → better research/curation → better material to forge from.

---

## 4. Reconciling the three loops (one brain, three clocks)

| Loop | Clock | Model tier | Purpose |
|---|---|---|---|
| **fleet-optimizer** (exists) | hourly | tiny/none (shell + tiny model) | Infra alive? (proxy, rpi, vault_sync, providers) |
| **Forge Tier-0/1** (capture/consolidate) | per-session + nightly | cheap (Qwen flash) | Lose nothing; compact + promote knowledge |
| **Forge Tier-2 + SkillOpt** (forge/optimize) | nightly, cheap hours | capable (Qwen max / Claude via proxy) | Deliberate skill forging, validation-gated |

They share **one vault, one `LOG.md`, one `INDEX.md`, one constitution (`AGENTS.md`)**. `fleet-optimizer` is the heartbeat; Forge is the metabolism; SkillOpt is the learning. No loop writes another loop's governed files without going through the governance zones.

---

## 5. The compounding brain model

```
sessions (ephemeral) ──capture──▶ digests ──consolidate──▶ wiki/MEMORY (durable knowledge)
                                              │
                                              └──stage──▶ skill candidates ──SkillOpt(gated)──▶ best_skill.md
                                                                                      │
        better skills ◀──────────── deployed into next day's workers ◀────────────────┘
```

- **Knowledge compounds** via wiki + char-bounded `MEMORY.md` (loaded each session → every session starts smarter).
- **Capability compounds** via SkillOpt: each skill is a validated, versioned artifact; rejected edits are buffered, not lost.
- **Child→quant:** early days the swarm mostly *maps and organizes* what exists (the 20+ notes, 22 skills, transcripts). As wiki density + skill quality rise, the same loops do higher-altitude work (cross-domain synthesis, signal generation). Growth is emergent from the loop, not front-built.

---

## 6. Domains & the value imperative (must make money)

The harness fails if it doesn't create value. So every domain queue must have a **value hypothesis**, not just "learn X."

| Domain | Compounding asset | Value path |
|---|---|---|
| AI/ML + agent harnesses | skills, the harness itself | sellable tooling / consulting / the product this *is* |
| Finance / markets | wiki of models + signals, backtests | trading signals, strategies (paper→live, gated) |
| Automation / edge / CE | reusable skills + scripts | products, internal leverage, bounties |
| Modeling | distilled frameworks in wiki | decision leverage across all the above |

**Rule:** the Steward's daily report must show, per domain, *what durable asset was added* and *its distance to value*. Token spend with no asset = a flagged failure. This keeps "run as much as possible" honest against "or harness fails."

---

## 7. Lite / anti-token-burn design (the constraint that shapes everything)

1. **Cheap hours:** heavy roles (Smith, Distiller, deep Scout) run **22:00–08:00 on Qwen at 0.2× price** (Alibaba plan). SkillOpt-Sleep is built for exactly this window.
2. **Tiered models:** infra/health = shell + tiny; capture/consolidate = Qwen flash; forge/synthesis = capable model only where validation demands it. Route via the existing proxy pattern.
3. **Hard caps per role per day** (Forge `.forge/steering/config`): ≤ N sessions, ≤ M chars/session, ≤ $X. Steward enforces + reports actual spend.
4. **Validation gates, not retries:** SkillOpt + Forge both promote only on measured improvement → no spend on non-improving work.
5. **Grep + wikilinks, no vector DB** (Forge non-goal) → zero infra cost for retrieval.
6. **Frozen `MEMORY.md` at session start** → prefix-cache friendly, no re-read churn.
7. **Local-first option:** where a role is low-stakes (tag, lint, link), prefer a local model via the proxy → ~$0.

---

## 8. MVP build plan (concrete, ordered)

**Phase 0 — reconcile adapters (this is Claude Code, Forge was OpenCode)**
1. Install Forge constitution at vault root: `AGENTS.md`, `INDEX.md`, `LOG.md`, `MEMORY.md`, `.forge/steering/config` (caps).
2. Scaffold `inbox/ journal/sessions/ wiki/ projects/ .forge/skills/` and **index the existing notes** (Forge §3 migration map) — zero content loss.

**Phase 1 — the daily cron (knowledge work)**
3. Write one scheduler wrapper modeled on `fleet-optimizer/loop.sh` (state dir, run counter, metrics.json, reports, race-guard on file mtime).
4. Implement **Curator + Janitor + Steward** first (they use already-installed skills, lowest risk, immediate vault hygiene).
5. Add **Scout + Scribe** with a 3-domain queue and the clipper.
6. Add **Distiller** (session→digest, Forge Tier-0/1) once session capture source is confirmed for Claude Code.
7. Cron it: daily at a cheap hour; Steward writes cost+asset report to `LOG.md`.

**Phase 2 — the forge (skill optimization)**
8. `pip install skillopt`; wire a backend (Qwen via proxy) + one benchmark per skill candidate.
9. Add **Smith** running `SkillOpt-Sleep` nightly over staged candidates; promote `best_skill.md` into `.forge/skills/` only on validation gain; log to `LOG.md`.
10. Seed stock: `hf skills add` a handful of HF skills relevant to the domain queues; adopt the SKILL.md format as our forge output standard.

**Phase 3 — value loops**
11. Stand up one finance signal pipeline (paper-traded, gated) as the first hard value test of the whole harness.

**Acceptance (end of Phase 1):** a day runs unattended → ≥3 clean research notes clipped+tagged+linked, `INDEX.md`/`LOG.md` updated, orphans connected, a cost+asset report in `LOG.md`, no secret patterns sent to any provider, spend within caps.
**Acceptance (end of Phase 2):** ≥1 skill shows a measured validation-score improvement from SkillOpt and is promoted; the improved skill is used by a worker the next day.

---

## 9. Open decisions (resolve before build)

- **Session-capture source for Claude Code:** where do this harness's transcripts live for the Distiller? (`~/.claude/projects/…/*.jsonl`? `~/.claude/sessions`?) — confirm before Phase 1 step 6.
- **Domain queue v1:** pick the first 3 domains + a value hypothesis each (§6).
- **Caps:** concrete N / M / $X per role; nightly budget ceiling.
- **SkillOpt benchmark design:** what task + validation set per skill candidate (this is the crux of "measurably better").
- **Provider routing:** which roles go to Qwen-night vs local vs Claude-via-proxy.
- **Finance risk gate:** paper-only until what threshold?

---

## 10. Provenance

- [[The Forge — OpenCode Knowledge Governance Design]] — 3-tier loop, governance zones, vault layout, scoring, anti-rot.
- [[Agent Loop Skill — Iterate-Until Pattern]] — worker persistence primitive.
- [[alibaba-token-plan-20-07-2026]] — cheap-night compute basis.
- `microsoft/SkillOpt` — validation-gated text-space skill optimization + SkillOpt-Sleep.
- `huggingface/skills` — Agent Skills catalog + format standard.
- `fleet-optimizer/loop.sh` — live self-tuning cron template.
