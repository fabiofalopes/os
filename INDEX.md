---
tags: [index, map, meta]
date: 2026-07-20
status: living — Curator maintains this
---

# INDEX — Vault Catalog

> The map every session consults first. Every `.md` note as a wikilink + one-line summary, grouped by domain. Agent-maintained (Z1). See [[CLAUDE]] for the constitution, [[LOG]] for the audit trail.

## Constitution & Governance
- [[CLAUDE]] — The Forge agent constitution: mission, core directives, vault structure, governance zones (Z1/Z2/Z4). Human-governed, do not edit.
- [[Operating Principle — Test Don't Wonder]] — Epistemic constitution: every durable claim must survive falsification; the five laws and the Critic gate.
- [[The Forge — OpenCode Knowledge Governance Design]] — DESIGN v2 for the capture→consolidate→forge loop making the vault the durable "brain"; governance architecture (build deferred).

## Harness & Operations (the cron swarm)
- [[the-forge-synthesis]] — One-page Scribe synthesis (`wiki/concepts/`): links Master Plan, Roles, Life Arc, Operating Principle, Skills Harvest, and Sources into a single picture (arc/engine/cast/method/material/fuel). Draft, Z2.
- [[Daily Cron Sessions — Swarm Harness Master Plan]] — Master plan for the self-compounding "child brain" run by a daily cron swarm; pulls in SkillOpt + HF skills.
- [[Agent Roles & Orchestrator — The Moat]] — Defines the role cast (Scout/Scribe/Curator/…) + orchestrator; the orchestration layer is the moat.
- [[Bootstrap to Self-Funding — The Agent Life Arc]] — Staged, gated arc: map → prove-one-thing → earn-a-little → cover-own-cost → compound.
- [[The Forge Harness — Runbook]] — Human-facing manual to operate/observe/tune the cron engine (the three dials: LOG, queue, git log).
- [[Skills Harvest — What's Here & What To Do Differently]] — Inventory of existing skills across three harnesses + what to mine vs. import.
- [[Agent Loop Skill — Iterate-Until Pattern]] — Design proposal (not yet a SKILL.md) for the bounded iterate-until agentic loop: success check, attempt cap, retry strategy.
- [[Sources — Curated Seed Library]] — Scout's pre-evaluated reading list (self-improving agents, SkillOpt, SEAL); the fetch-and-curate queue.

## AI/ML Research — self-improving agents (`wiki/research/ai-ml/`)
- [[SEAL — Self-Adapting Language Models]] — arXiv:2506.10943 (MIT). Model writes self-edits → SFT → persistent weight updates; RL rewards downstream performance. The generate→measure→keep north star we realize in text via SkillOpt.
- [[Voyager — Open-Ended Embodied Agent]] — arXiv:2305.16291. Auto-curriculum + executable skill library + env-feedback refinement; the blueprint for our growing `.forge/skills/` loop.
- [[Reflexion — Verbal Reinforcement Learning]] — arXiv:2303.11366. Verbal self-reflection in an episodic memory buffer, no weight change; cheap self-improvement = session-digest → next-session recall.
- [[ADAS — Automated Design of Agentic Systems]] — arXiv:2408.08435. Meta-agent searches over agent designs in code, keeps the best; formalizes "the harness improves the harness," informs the orchestrator/moat.

## Quant / Finance Research (`wiki/research/finance/`)
- [[López de Prado — Backtest Overfitting Guards]] — SSRN-verified paper cluster (PBO/CSCV, Deflated Sharpe Ratio, Pseudo-Mathematics): why backtests lie and the guards (report N, deflate the SR, PBO < 0.5, holdout is not a guard). The anti-fooling-yourself foundation for the money mission.
- [[Kelly Criterion — Position Sizing]] — Kelly 1956 + Thorp: maximize geometric growth; f* = p/l − q/g; fractional Kelly + garbage-in-garbage-out caveats. How not to go bust; inseparable from the overfitting guards.

## AI Tooling & Proxy Setups (this RPi)
- [[Claude Code Proxy Pattern — Master Reference]] — Canonical pattern: local proxy translating Anthropic Messages API to any OpenAI-compatible provider.
- [[Claude Code Proxy Pattern — Ollama Cloud]] — Proxy instance routing Claude Code → Universal Provider Bridge → ollama.com/v1.
- [[Claude Code Ollama Cloud — Maintenance & Future Roadmap]] — Architecture summary + maintenance/roadmap for the ollama-cloud proxy.
- [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]] — Inventory of the Lusófona (`modelos.ai.ulusofona.pt`) stack; flags plaintext API key as secret material.
- [[DeepSeek V4 Claude Code Harness]] — Three ways to get DeepSeek V4 into Claude Code (claude-ollama ✅, claude-opencode ✅, claude-deepseek ⏳ needs key).
- [[Hermes Agent — Full System Capability Map]] — Full scan of the Kali RPi: three harnesses (Claude Code / OpenCode / Hermes) on one rig.

## Security Research (rpi-net / Bolt / wireless)
- [[Bolt Security Research — MITM Attack Capability]] — Bolt e-scooter MITM research: rig proven to decrypt HTTPS, API surface mapped, app capture never executed (next step).
- [[RPi-Net Session Log]] — Living session log for rpi-net + Bolt: decisions, lab-vs-field rules, APK analysis progress.
- [[Wireless Pentesting Infrastructure — Kali RPi]] — Passwordless `wlan1` monitor-mode/injection setup on the Kali RPi; hardware characterized, real targets pending.

## Pi Infrastructure, Reliability & Migration
- [[RPi Reliability — Zombie State Prevention]] — Root-causes the Pi "zombie" hang (USB power budget); watchdog + swap active, physical fixes pending.
- [[Next Session Pickup — Pre-Reboot 2026-06-26]] — Pre-reboot state + 60-second post-reboot checklist (watchdog, swap, tmux persistence).
- [[pi-backup-session-2026-07-02]] — Full harvest of the RPi onto the Kali Lenovo laptop; recon + filesystem map.
- [[forensic-timeline]] — Reconstructed Pi activity timeline (mid-2024→2026-07) from git/shell/session/timestamp evidence.
- [[project-map]] — Index of everything found on the Pi during backup, organized by domain.
- [[organization-plan]] — Plan to clean `~/` from 60+ entries down to what matters; lists hardcoded paths to leave in place.
- [[opencode-sessions]] — Index of exported OpenCode sessions (by topic) from the Pi backup.

## Session Records & Plans (transient)
- [[alibaba-token-plan-20-07-2026]] — Clipping of the Alibaba ModelStudio Pro token-plan console (active, 30 days remaining).

## Harness Config (`_harness/`)
- [[queue]] — Session queue: runner picks the top unchecked job each tick; role-tagged, order = priority.
- [[schedule]] — Cron cadence (20 min) and the reasoning; re-tuned by the META-REVIEW job.

---
**Note:** [[LOG]] (audit trail) and [[MEMORY]] (working memory) are root operational files, not catalogued as knowledge notes. MEMORY.md does not yet exist (queued as a [Steward] job).
