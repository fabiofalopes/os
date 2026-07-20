---
tags:
  - index
  - projects
  - map
date: 2026-07-02
---

# Project Map — Everything on the Pi

An index of every significant thing found during the backup, organized by domain.

---

## AI Agent Harness

### Opencode
- Location: `~/.opencode/`, `~/.config/opencode/`
- Sessions: `~/opencode-sessions/` (8 exported, JSON+MD)
- Agents: `kali-director`, `kali-exploit`, `kali-recon` (in `.config/opencode/agents/`)
- Skills: 30+ skills in `.config/opencode/skills/`, 39 in `skill-vault/`
- Config: `opencode.json`, `tui.json`
- Binary: `bin/opencode`

### Claude Code
- Location: `~/.claude/`
- Sessions: 2 active (`3650999`, `3801378`), ~20 recent JSONL logs
- Projects: 7 project dirs with memory + session logs
- Config: `.claude.json`, model endpoint setup for Lusófona + Ollama Cloud
- Model wrappers: 25+ `claude-ollama-*` scripts in `~/bin/`

### OpenClaude
- Location: `~/.openclaude/`
- Sessions: active sessions + history
- Config: `.openclaude.json`, `.openclaude-profile.json`
- Structure mirrors `.claude/` — separate instance

### Hermes Agent
- Location: `~/.hermes/`
- Sessions: 2 request dumps (Jul 1)
- Agent repo: `hermes-agent/` (cloned Jun 19)
- Skills: ~19 directories
- State: 13MB SQLite DB (`state.db`)
- Config: `config.yaml`, `.env` (API keys), `SOUL.md` (personality)
- Binaries: `tirith`, `uv`, `uvx` in `bin/`
- Docs: `Hermes Agent — Full System Capability Map` (Pi vault note)

---

## Security Research

### RPi-Net (Portable Traffic-Interception Rig)
- Location: `~/rpi-net/`
- Size: 1.8 GB total (30 MB essential docs + 1.7 GB lab artifacts)
- **Bolt Security Research:** MITM attack capability against Bolt e-scooter app
  - APK reverse engineering (jadx, apktool)
  - Certificate manipulation
  - Traffic interception
- **Wireless Pentesting:** Monitor mode, deauth, handshake capture
- **Lab artifacts (stripped from curated):**
  - `apktool-clean/` (838 MB) — decompiled APK
  - `apktool-fresh/` (217 MB)
  - `apktool-meta/` (87 MB)
  - `apktool-output/` (523 MB)
  - `root-prep/` (82 MB)
- Docs: CHARTER.md, ROADMAP.md, AGENTS.md, CONTEXT-UPDATE.md
- See: `RPi-Net Session Log`, `Bolt Security Research — MITM Attack Capability` (Pi vault notes)

---

## Hardware Projects

### M5Stack Dial
- Location: `~/m5stack-dial/`
- I2C sensor verification with Grove Hub
- Firmware (Arduino .ino files)
- Python daemon for sensor reading
- Docs: HANDOFF.md, INDEX.md, knowledge base
- Sessions: [[opencode-sessions]] (`ses_2274acccdffe`, `ses_1ae4eced3ffe`)

### Camera Server
- Location: `~/camera-server/`
- Python Flask server for RPi camera
- Multiple camera backends tried (direct, v4l, libcamera)
- Archive of 15+ experimental scripts
- See: [[opencode-sessions]] (`ses_215e5c346ffe`, `ses_2273f50d7ffe`)

### Arduino
- Location: `~/Arduino/`
- Size: 338 MB (all libraries)
- No user sketches found — just installed library collection

---

## Custom Scripts & Tools

### CLI Tools (`~/bin/`)
- 29 executables, 34 MB total
- **Model wrappers:** 25+ `claude-ollama-*` scripts (dsv4-pro, glm52, minimax3, etc.)
- **Android:** `aapt2`, `aapt2-wrapper`, `arduino-cli`
- **Agent bridge:** `hermes-bridge`
- **Hardware:** `pitemp`

### Scripts Repo (`~/.myscripts/`)
- Git repo, ~60 files, 2+ years of history (2024-05 to 2026-03)
- **Obsidian tools:** `youtube-obsidian`, `obsidian-polish`, `to_note`
- **Fabric AI:** custom patterns, graph agents, image analysis
- **Media:** `heic2jpg.sh`, `wav-to-mp3`, `flac2mp3.sh`, `ocr-ing.sh`
- **DevOps:** `deploy-searxng.sh`, `dockerfiles`, JumpServer
- **Utilities:** `tokcount`, `or-bench`, `or-model-select`, `to_clip`, `slugfile`
- **Git history:** 59 commits

---

## Infrastructure & Config

### Tmux
- Custom config (`~/.tmux/`, `~/.tmux.conf`)
- Plugins: `tmux-resurrect`, `tmux-continuum`, `tpm`
- Dashboard: `claude-dashboard` (Go TUI, git repo), actively developed

### Shell
- Zsh with history (1,264 lines)
- `.bashrc.d/` with custom aliases (claude-ollama, hermes-bridge autostart)
- `.myscripts` on PATH

### Network Config
- SSH key access setup
- `dhcpcd.conf`, `hostapd`, `iodine` (DNS tunnel)
- Pi acts as WiFi access point

---

## Obsidian Vault

Location: `~/obsidian-vault/` on Pi (now here as `~/obsidian-vault-kali/`)

| Note | Topic |
|------|-------|
| Agent Loop Skill — Iterate-Until Pattern | General agent behavior |
| Bolt Security Research — MITM Attack Capability | RPi-Net security research |
| Claude Code Ollama Cloud — Maintenance | Model proxy maintenance |
| Claude Code + OpenCode Setup — Lusófona | AI endpoint configuration |
| Claude Code Proxy Pattern — Ollama Cloud | Proxy architecture |
| DeepSeek V4 Claude Code Harness | Model integration |
| Hermes Agent — Full System Capability Map | System inventory |
| Next Session Pickup — Pre-Reboot | Session handoff |
| RPi-Net Session Log | Security research log |
| RPi Reliability — Zombie State Prevention | Hardware hardening |
| The Forge — OpenCode Knowledge Governance | Vault curation design |
| Wireless Pentesting Infrastructure | Pentest methodology |

---

## System Snapshot

| Metric | Value |
|--------|-------|
| Hostname | `kali-raspberry-pi` |
| OS | Kali Linux ARM64 2026.1 |
| Kernel | 6.12.34+rpt-rpi-v8 |
| Packages | 3,432 dpkg |
| User | `ken` (sudoer, netdev) |
| CPU | Raspberry Pi 4, ARM64 |
| Uptime (at backup) | Active since at least 2024-05 |

---

## Related

- [[pi-backup-session-2026-07-02]]
- [[forensic-timeline]]
- [[organization-plan]]
