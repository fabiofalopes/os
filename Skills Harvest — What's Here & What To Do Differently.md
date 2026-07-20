---
tags: [skills, harvest, inventory, meta, harness]
date: 2026-07-20
status: living inventory + evaluation
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
  - "[[Daily Cron Sessions — Swarm Harness Master Plan]]"
---

# Skills Harvest — What's Here & What To Do Differently

> The initial skills harvest. The user's ask: *yes to HF ML skills — but also look at the other harnesses already here, and think what we could do differently with all of it.* This box has **years/months of accumulated capability across three harnesses.** Before importing anything new, map and mine what exists.

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

## 2. What to do differently (the actual insight)

1. **Stop treating skills as three separate collections.** One skill store, one format (Anthropic `SKILL.md` — the open standard), symlinked into each harness. Forge §8 already says this; the harvest makes it concrete. A skill forged by the Smith should be usable by Claude Code *and* OpenCode *and* Hermes.

2. **Mine, don't just import.** HF skills are a *seed catalog* — but the higher-value move is running **SkillOpt over the skills we already use** so the 22 curation skills get *measurably better* at *our* vault. Imported skills are generic; optimized-against-our-usage skills are the moat.

3. **Turn the fleet-optimizer pattern into the Conductor.** It already solves: cadence, state, self-tuning knobs, health reports. Generalize it from "watch infra" to "run the cast." Don't write a new scheduler from scratch.

4. **Harvest the pentest library as a domain, or sunset it.** 40 skills sitting idle is dead capital. Either add "security/pentest" to the domain queue (it *is* a value-creating skill set — bounties, audits) or archive it cleanly. Decide; don't leave it ambient.

5. **Fill or kill the 37 stubs.** Empty stubs are noise the Janitor should surface; the Smith fills the ones that map to real repeated tasks, deletes the rest.

6. **The HF ML skills unlock the Quant + Smith roles specifically:** `huggingface-datasets`, `huggingface-llm-trainer`, `huggingface-local-models`, `hf-mem`, `huggingface-community-evals` → these are what let us *train/eval locally and cheaply*, which is the backbone of "validate don't wonder" without burning API tokens.

## 3. Harvest → role mapping

| Existing asset | Feeds which role |
|---|---|
| 22 Claude curation skills | Curator, Janitor, Scribe, Scout (clipper) |
| fleet-optimizer loop | **Conductor** (scheduler template) + Steward (health) |
| Hermes dreaming | Distiller (consolidation pattern) |
| 40 OpenCode pentest skills | a Security domain queue (or archive) |
| HF ML skills (to add) | Quant, Smith (local train/eval) |
| SkillOpt (to add) | Smith (forge/optimize) |

## 4. Immediate harvest actions
1. Symlink the 22 Claude skills + chosen HF skills into one canonical store; point all harnesses at it.
2. Copy `fleet-optimizer/loop.sh` structure into the new Conductor wrapper.
3. `hf skills add huggingface-datasets huggingface-local-models hf-mem huggingface-community-evals` (the eval/local quartet first — they enable cheap validation).
4. Janitor pass: list the 37 OpenCode stubs + decide fill/kill.
5. Decide the pentest-library fate (domain vs. archive).

## Open questions
- Canonical skill-store path (vault `.forge/skills/` vs. `~/.claude/skills/`)? Recommend vault-resident + symlinked out, so skills are git-observed like everything else.
- Do we unify all three harnesses on one vault now, or let Claude Code lead and fold the others later? (Recommend: Claude Code leads this plan; Hermes/OpenCode contribute patterns, unify later.)
