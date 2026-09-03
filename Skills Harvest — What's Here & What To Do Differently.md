---
tags: [skills, harvest, inventory, meta, harness]
date: 2026-07-21
status: living inventory + evaluation
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
---

# Skills Harvest — What's Here & What To Do Differently

> The initial skills harvest. The user's ask: *yes to HF ML skills — but also look at the other harnesses already here, and think what we could do differently with all of it.* This box has **years/months of accumulated capability across three harnesses.** Before importing anything new, map and mine what exists.

## Change Log

### 2026-07-21 — Full Harvest Pass
**Added:** 10 new active skills from vault-wide search (session digests, INDEX.md maintenance, LOG.md append, session log management, knowledge consolidation, inbox triage, prompt template management, skill forging, research workflow, vault structure decisions)
**Retired:** None this pass — all were new entries
**Merged:** N/A
**Demoted:** N/A

---

## 1. Inventory — three harnesses, one box

### Claude Code (`~/.claude/skills/`) — 22 installed, all vault-curation
`broken-link-healer, defuddle, fleeting-processor, glossary-builder, ig-transcribe-yandex, instagram-transcribe, interactive-quiz, json-canvas, markdown-linter, moc-builder, obsidian-bases, obsidian-cli, obsidian-markdown, obsidian-stats, orphan-connector, serendipity-engine, smart-tagger, smart-web-clipper, toc-generator, todoist-integration, youtube-transcribe, zettel-atomizer`

**Verdict:** this is almost a *complete curation/Janitor/Curator/Scribe toolkit already.* The swarm's hygiene + organizing + clipping + atomizing roles can run **today** on these. What's *missing*: research-depth, ML, quant, and skill-forging skills.

### OpenCode (`~/.config/opencode/skills/`) — ~45 (40 pentest + 5 workflow) + `agent-loops/`
- 40 pentest skills + 5 workflow skills; `skill-vault/` = 37 empty stubs (unrealized).
- **`agent-loops/fleet-optimizer/`** — the LIVE self-tuning cron. This is the most valuable artifact here: a working pattern of *cron → observe → self-tune → report* with `tuning.json`/`metrics.json`/`reports/`.

**Verdict:** the pentest skills are a domain library we're *not* currently using in this plan — either fold pentest/security into a domain queue or archive. The **fleet-optimizer loop is the template for the Conductor's scheduler** — copy its state/metrics/report shape. The 37 empty stubs are a *graveyard of good intentions* — the Janitor should prune or the Smith should fill them.

### Hermes (`~/.hermes/`, 561M) — its own skills + 3-phase "dreaming"
**Verdict:** Hermes already has native sleep-time consolidation (Forge §6 cites it). Rather than rebuild dreaming, **unify on one vault + constitution** and let each harness contribute its strength (Forge §8 portability). Don't run three brains; run one brain with three hands.

---

## 2. What to do differently (the actual insight)

1. **Stop treating skills as three separate collections.** One skill store, one format (Anthropic `SKILL.md` — the open standard), symlinked into each harness. Forge §8 already says this; the harvest makes it concrete. A skill forged by the Smith should be usable by Claude Code *and* OpenCode *and* Hermes.

2. **Mine, don't just import.** HF skills are a *seed catalog* — but the higher-value move is running **SkillOpt over the skills we already use** so the 22 curation skills get *measurably better* at *our* vault. Imported skills are generic; optimized-against-our-usage skills are the moat.

3. **Turn the fleet-optimizer pattern into the Conductor.** It already solves: cadence, state, self-tuning knobs, health reports. Generalize it from "watch infra" to "run the cast." Don't write a new scheduler from scratch.

4. **Harvest the pentest library as a domain, or sunset it.** 40 skills sitting idle is dead capital. Either add "security/pentest" to the domain queue (it *is* a value-creating skill set — bounties, audits) or archive it cleanly. Decide; don't leave it ambient.

5. **Fill or kill the 37 stubs.** Empty stubs are noise the Janitor should surface; the Smith fills the ones that map to real repeated tasks, deletes the rest.

6. **The HF ML skills unlock the Quant + Smith roles specifically:** `huggingface-datasets`, `huggingface-llm-trainer`, `huggingface-local-models`, `hf-mem`, `huggingface-community-evals` → these are what let us *train/eval locally and cheaply*, which is the backbone of "validate don't wonder" without burning API tokens.

---

## 3. Harvest → role mapping

| Existing asset | Feeds which role |
|---|---|
| 22 Claude curation skills | Curator, Janitor, Scribe, Scout (clipper) |
| fleet-optimizer loop | **Conductor** (scheduler template) + Steward (health) |
| Hermes dreaming | Distiller (consolidation pattern) |
| 40 OpenCode pentest skills | a Security domain queue (or archive) |
| HF ML skills (to add) | Quant, Smith (local train/eval) |
| SkillOpt (to add) | Smith (forge/optimize) |

---

## 4. Active Skills Harvest — 10 Candidates

### 1. Session Digest Generation
- **Trigger:** Each cron session closes
- **Source evidence:** `CLAUDE.md:40`, `Daily Cron Sessions — Swarm Harness Master Plan.md:90`, `The Forge — OpenCode Knowledge Governance Design.md:77`
- **Rationale:** Every session must produce structured digest (goal, files touched, decisions, outcomes, tokens/$) → `journal/sessions/<id>.md` + append `LOG.md`. Currently manual/templated each time.
- **Confidence:** high
- **Status:** new

### 2. INDEX.md Auto-Maintenance
- **Trigger:** Any write to vault
- **Source evidence:** `CLAUDE.md:9`, `The Forge — OpenCode Knowledge Governance Design.md:51`
- **Rationale:** Catalog of all notes maintained each session. Must update wikilinks + summaries after every note change. Currently manual.
- **Confidence:** high
- **Status:** new

### 3. LOG.md Append Automation
- **Trigger:** Any write to vault
- **Source evidence:** `CLAUDE.md:40`, `The Forge — OpenCode Knowledge Governance Design.md:77`
- **Rationale:** Audit trail must append on any write. Currently manual.
- **Confidence:** high
- **Status:** new

### 4. RPi-Net Session Log Management
- **Trigger:** Each session with networking work
- **Source evidence:** `RPi-Net Session Log.md`, `project-map.md:67`, `Hermes Agent — Full System Capability Map.md:157`
- **Rationale:** Living session log for rpi-net + Bolt: decisions, lab-vs-field rules, APK analysis progress. Must update each session.
- **Confidence:** high
- **Status:** new

### 5. Knowledge Consolidation / Distillation
- **Trigger:** N new session digests accumulate
- **Source evidence:** `Daily Cron Sessions — Swarm Harness Master Plan.md:90`, `wiki/` folder references, `The Forge — OpenCode Knowledge Governance Design.md:77`
- **Rationale:** Converting session digests into durable knowledge (wiki notes, skill candidates). Currently manual staging.
- **Confidence:** high
- **Status:** new

### 6. Inbox Triage & Processing
- **Trigger:** New items appear in `inbox/`
- **Source evidence:** `CLAUDE.md`, `The Forge — OpenCode Knowledge Governance Design.md:77`, `journal/sessions/README.md`
- **Rationale:** Raw capture must be read, categorized, tagged, moved. Currently manual triage.
- **Confidence:** high
- **Status:** new

### 7. Prompt Template Management
- **Trigger:** New agent task or workflow identified
- **Source evidence:** `Hermes Agent — Full System Capability Map.md`, `The Forge — OpenCode Knowledge Governance Design.md:33`
- **Rationale:** Creating and maintaining prompt templates for agent tasks. Currently manual writing and refinement.
- **Confidence:** medium
- **Status:** new

### 8. Skill Forging & Optimization
- **Trigger:** Any task performed 2+ times across sessions
- **Source evidence:** `HARVEST-STATUS.md:93`, `Daily Cron Sessions — Swarm Harness Master Plan.md:90`
- **Rationale:** Converting repeated manual tasks into reusable `.forge/skills/` SKILL.md files. Currently manual identification and creation.
- **Confidence:** medium
- **Status:** new

### 9. Research Lead Discovery & Evaluation
- **Trigger:** New research question or topic area
- **Source evidence:** `projects/trading-agents/Moon Dev — Research Brief & Leads.md`, `forensic-timeline.md`
- **Rationale:** Finding, evaluating, and organizing research resources (leads, sources, methods). Currently manual search and filtering.
- **Confidence:** medium
- **Status:** new

### 10. Vault Structure Decision Support
- **Trigger:** New project or knowledge area needs organization
- **Source evidence:** `CLAUDE.md:26`, `The Forge — OpenCode Knowledge Governance Design.md`, `project-map.md`
- **Rationale:** Deciding on file naming, folder structure, MOC creation. Currently manual decisions without pattern reference.
- **Confidence:** medium
- **Status:** new

---

## 5. Watchlist — Insufficient Evidence

### 11. Manual Data Sync Patterns
- **Trigger:** Uncertain — needs more evidence
- **Source evidence:** `grep -ri "sync\|backup\|mirror"` returned limited matches
- **Rationale:** Potential for automated sync/backup workflows but insufficient recurrence evidence yet.
- **Confidence:** low
- **Status:** watchlist

### 12. Cross-Harness Skill Portability
- **Trigger:** Any skill needs to be used by multiple harnesses
- **Source evidence:** `HARVEST-STATUS.md:33`, `Forge §8 portability`
- **Rationale:** Symlinking skills across harnesses is a pattern but hasn't been implemented yet. Needs more evidence of repeated cross-harness usage.
- **Confidence:** medium
- **Status:** watchlist

---

## 6. Immediate harvest actions

1. Symlink the 22 Claude skills + chosen HF skills into one canonical store; point all harnesses at it.
2. Copy `fleet-optimizer/loop.sh` structure into the new Conductor wrapper.
3. `hf skills add huggingface-datasets huggingface-local-models hf-mem huggingface-community-evals` (the eval/local quartet first — they enable cheap validation).
4. Janitor pass: list the 37 OpenCode stubs + decide fill/kill.
5. Decide the pentest-library fate (domain vs. archive).

---

## Open questions

- Canonical skill-store path (vault `.forge/skills/` vs. `~/.claude/skills/`)? Recommend vault-resident + symlinked out, so skills are git-observed like everything else.
- Do we unify all three harnesses on one vault now, or let Claude Code lead and fold the others later? (Recommend: Claude Code leads this plan; Hermes/OpenCode contribute patterns, unify later.)
