---
tags:
  - forensics
  - timeline
  - analysis
date: 2026-07-02
---

# Forensic Timeline — Pi Activity Analysis

Reconstructed from git logs, shell history, session files, and file timestamps.

---

## Overview

The Pi (`kali-raspberry-pi`) was active from **mid-2024 to July 2026**. Work clusters around distinct project phases, with the heaviest activity in the last 6 months (2026 Q1–Q2).

**3,432 packages installed · 1,264 zsh history entries · 7 git repos tracked**

---

## Phase 1: Foundation (2024-05 to 2025-09)

The Pi starts as a general Kali box. First scripts appear.

| Date | Event |
|------|-------|
| 2024-05-13 | `~/.myscripts` repo initialized — `286a726 first` |
| 2024-07-06 | First sync tooling |
| 2024-07-10 | Droid emulation scripts |
| 2024-09-08 | General updates |
| 2024-10-31 | `to_clip` + `wav-to-mp3` utilities added |
| 2024-11-05 | `concat-any` script replaces all concat variants |
| 2024-12-30 | Tmux configuration work |

**Character:** Setup phase. Building foundational scripts, tmux environment, keyboard-driven workflow.

---

## Phase 2: Fabric AI + Obsidian Tooling (2025-09 to 2025-12)

The Pi becomes a creative scripting powerhouse. Heavy investment in AI-assisted workflows.

| Date | Event |
|------|-------|
| 2025-09-28 | Tmux green color scheme — cohesive setup |
| 2025-10-06 | First fabric custom patterns + workflow scripts |
| 2025-10-08 | Fabric patterns explosion: voice tools, scripts, repo organization |
| 2025-10-09 | `voice_note.sh` — voice-to-text pipeline |
| 2025-10-17 | Pattern additions |
| 2025-10-21 | Fabric cross-platform clipboard fixes |
| 2025-11-25 | Fabric ecosystem expansion: 10+ patterns, graph agents, OCR, image analysis |
| 2025-12-09 | `youtube-obsidian` V3.0 — smart cache system |
| 2025-12-11 | youtube-obsidian improvements |
| 2025-12-17 | `to_note` journaling tool, more obsidian fabric patterns, shell enhancement |
| 2025-12-19 | `obsidian-polish` — rename + validation |
| 2025-12-21 | **Sprint system begins:** Sprints 1-3 (datetime capture, cache, category detection) |
| 2025-12-21 | Sprint 4-8 planning docs, kanban setup |
| 2025-12-21 | `view-kanban.sh` added |
| 2025-12-30 | Bugfixes in obsidian-polish |

**Character:** Most creative period. Building an AI-augmented note-taking/scripting ecosystem. The sprint system shows attempts to organize the chaos.

---

## Phase 3: Hardware Projects (2026-01 to 2026-03)

New hardware arrives. The Pi drives physical devices.

| Date | Event |
|------|-------|
| 2026-01-03 | Python venv management, mlx-ecosystem |
| 2026-01-16 | JumpServer v4 deployment, observability tooling |
| 2026-01-23 | `heic2jpg.sh` — bulk HEIC converter |
| 2026-01-24 | **Circuit board knowledge extractor** (phases 1-2) |
| 2026-02-27 | Device extractor HANDOFF document |
| 2026-03-02 | Token counters (`tokcount`, `or-bench`, `or-model-select`), mfab tool, research reports |

**Character:** Diversification into hardware (circuit boards, M5Stack). Tooling becomes more specialized.

---

## Phase 4: M5Stack Dial + Camera (2026-04 to 2026-05)

Two hardware projects peak simultaneously.

### M5Stack Dial

| Date | Event |
|------|-------|
| 2026-04-21 | M5Stack Dial project initialized (HANDOFF, INDEX, knowledge base) |
| 2026-04-29 | Firmware, daemon scripts, troubleshooting docs |
| 2026-05-18 | Firmware updates |
| 2026-05-24 | Full project structure: data, docs, ideas, journal, reference |

### Camera Server

| Date | Event |
|------|-------|
| 2026-03-17 | First camera scripts (fix_cma.sh, requirements.txt) |
| 2026-04-29 | README, archive of camera attempts |
| 2026-05-04 | Static templates |
| 2026-05-15 | Production `camera_server.py` + `camera.py` |

### Opencode Sessions — 2026-05-15

On **2026-05-15**, a burst of opencode sessions were exported:

| Session | Topic |
|---------|-------|
| `ses_1d3ce5e1cffe` | New session init (May 15, 15:11) |
| `ses_1d3ce148effe` | Ping all agents |
| `ses_1d3b3f9fbffe` | Resuming previous work context |
| `ses_1a823f65cffe` | **Tmux agent coordination system** |
| `ses_215e5c346ffe` | Camera streaming: to serve or not |
| `ses_2273f50d7ffe` | Camera server recap + achievements |
| `ses_2274acccdffe` | M5Dial project status + next steps |
| `ses_1ae4eced3ffe` | **Grove hub M5 Dial sensor verification** |
| `ses_1c523b2c4ffe` | Grove hub M5 Dial sensor verification (2nd session) |
| `ses_22a4cd591ffe` | RPi 4 Kali internet access intermittent |
| `ses_1d3dc0d02ffe` | OhMyOpenAgent Zen custom endpoint setup |
| `ses_1a0a4f78dffe` | Converting opencode sessions to markdown (meta) |

**Character:** Heavy hardware tinkering. Multiple projects in flight. Agent orchestration begins (tmux coord system).

---

## Phase 5: Security Research (2026-05 to 2026-07)

The Pi becomes a portable security rig. This is the most intense, longest-running phase.

### RPi-Net / Bolt Research

| Date | Event |
|------|-------|
| 2026-05-28 | Wireless pentesting infrastructure deployment |
| 2026-06-02 | Bolt Security Research initialized — MITM attack capability |
| 2026-06-19 | AGENTS.md, CHARTER.md, ROADMAP.md — formal project structure |
| 2026-06-20 | Certificate server (certserve), archive |
| 2026-06-26 | **APK analysis begins:** jadx, apktool — Bolt Android app reverse engineering |
| 2026-06-30 | Lab work: apktool-clean, apktool-fresh, apktool-meta, root-prep |
| 2026-07-01 | CONTEXT-UPDATE.md (31KB) — latest research context |

### RPi Reliability Hardening

| Date | Event |
|------|-------|
| 2026-06-26 | Watchdog enabled, swap configured, tmux-continuum + resurrect installed |
| 2026-06-26 | Pre-reboot checklist (13 health checks) |
| 2026-06-30 | Zombie state prevention document |

**Character:** Systematic security research. Formal project docs (charters, roadmaps, session logs). The Bolt APK analysis consumed significant compute (1.7 GB of artifacts).

---

## Phase 6: Multi-Agent Era (2026-06 to 2026-07)

Multiple AI agents deployed simultaneously. The Pi becomes a harness workstation.

### Hermes Agent

| Date | Event |
|------|-------|
| 2026-06-19 | Hermes agent cloned (git: `a7983d5`) |
| 2026-06-20 | Configuration begins (auth, logs, cron) |
| 2026-06-30 | Full system capability map generated (Hermes scan of entire Pi) |
| 2026-06-30 | Multiple skills added (~19 skill directories) |
| 2026-07-01 | Last Hermes sessions (request dumps) |

### Claude Code Activity

| Date | Event |
|------|-------|
| 2026-06-30 | Heavy session day: 15+ JSONL files, multiple model switches |
| 2026-06-30 | Session `7ee84806` — 827KB of conversation (largest Claude session) |
| 2026-06-30 | Session `3f230df3` — 267KB |
| 2026-07-01 | Session `187bf93e` — 216KB (Claude Code work) |
| 2026-07-01 | Sessions `c831fa79` + `11c9c453` — final Claude activity |

### Opencode

| Date | Event |
|------|-------|
| 2026-05-15 | Main session burst exported to markdown |
| 2026-06-30 | Last opencode usage from history |

### Claude-Ollama Wrappers

From shell history, the user actively tested **multiple model endpoints**:

| Wrapper Script | Model |
|----------------|-------|
| `claude-ollama-dsv4-pro` | DeepSeek V4 Pro |
| `claude-ollama-dsv4-flash` | DeepSeek V4 Flash |
| `claude-ollama-glm52` | GLM-5-2 |
| `claude-ollama-glm51` | GLM-5-1 |
| `claude-ollama-minimax3` | MiniMax-3 |
| `claude-ollama-kimi27c` | Kimi K2.7c |
| `claude-ollama-devstral2` | Devs-tral-2 |
| `claude-ollama-gemma4` | Gemma-4 |
| `claude-ollama-qwen35` | Qwen-3.5 |
| `claude-ollama-qwen3c480` | Qwen-3c-480 |

**Character:** Explosion of AI agent usage. Multiple agents (opencode, claude-code, hermes) running simultaneously, each with different strengths. Heavy model switching to find best performance per task.

---

## Project Heatmap

```
2024  |▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁|  .myscripts (foundation)
2025 Q1|▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁|  .myscripts (early)
2025 Q2|▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁|  
2025 Q3|▁▁▁▁▁▁▁▁▁▁▁▁▂▃▄▅▆▇█▇▆▅▄▃▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁|  Fabric AI patterns
2025 Q4|▁▁▁▁▁▁▁▁▁▁▂▃▄▅▆▇████████████▇▆▅▄▃▂▁▁▁▁▁|  Obsidian tooling
2026 Q1|▁▁▁▁▁▂▃▄▅▆▇████▇▆▅▄▃▂▁▁▁▁▁▁▁▁▂▃▄▅▆▇█▇▆|  Hardware + camera
2026 Q2|▅▆▇█████████████████████████████████████|  Security research + multi-agent
```

---

## Key Insights

### What Was the Pi Used For?
1. **Scripting & automation** (`.myscripts`) — longest-running project, 2+ years
2. **Security research** (`rpi-net`) — most data-heavy, structured approach
3. **AI agent experimentation** — intense burst in last 2 months
4. **Hardware tinkering** — M5Stack, camera, Arduino
5. **Tool building** — custom CLI wrappers for every model endpoint

### What's Valuable to Preserve
- The `.myscripts` git history — 2 years of evolution
- The obsidian vault notes — synthesized thinking
- Agent configs (`claude.json`, `openclaude.json`, hermes env) — took time to tune
- Claude session logs — capture specific engineering decisions
- The `rpi-net` docs/charters — structured research methodology

### What's Ephemeral
- APK build artifacts (`lab/`) — regeneratable
- Model caches — auto-rebuild
- `node_modules` — `npm install` away

---

## Related

- [[pi-backup-session-2026-07-02]]
- [[organization-plan]]
- [[opencode-sessions]]
