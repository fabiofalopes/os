# Hermes Agent — Full System Capability Map

> **Generated:** 2026-06-30 — complete scan of kali-raspberry-pi
> **Host:** Raspberry Pi 4, Kali Linux ARM64 2026.1, kernel 6.12.34+rpt-rpi-v8
> **User:** ken (sudoer, in netdev group)
> **Hermes:** v0.17.0, model deepseek-v4-pro via ollama-cloud

---

## THE STACK — Three Harnesses, One Rig

```
┌─────────────────────────────────────────────────────────────┐
│                    KALI RASPBERRY PI 4                      │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  CLAUDE CODE │  │   OPENCODE   │  │    HERMES    │      │
│  │  (Anthropic) │  │  (Terminal)  │  │  (Nous)      │      │
│  │              │  │              │  │              │      │
│  │ Lusófona EP  │  │ Lusófona EP  │  │ ollama-cloud │      │
│  │ harmonic-9b  │  │ + slim/OMO   │  │ deepseek-v4  │      │
│  │              │  │ + z.ai GLM   │  │              │      │
│  │ DeepSeek EP  │  │              │  │ 68 skills    │      │
│  │ V4 Pro/Flash │  │ 9,455 skills │  │ 24 toolsets  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │               │
│         └─────────┬───────┴─────────┬───────┘               │
│                   │                 │                       │
│         ┌─────────▼─────────────────▼─────────┐            │
│         │        SHARED INFRASTRUCTURE          │            │
│         │                                       │            │
│         │  ~/shared-local/  (Diane framework)   │            │
│         │  ~/obsidian-vault/ (knowledge base)   │            │
│         │  ~/rpi-net/        (MITM rig)         │            │
│         │  ~/pi-orchestrator/ (agent mgmt)      │            │
│         │  ~/camera-server/   (IMX219 cam)      │            │
│         │  ~/m5stack-dial/    (IoT sensor)      │            │
│         └───────────────────────────────────────┘            │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              ANDROID PHONE (ADB)                      │   │
│  │  GAAZCY072652MLB — connected via USB                 │   │
│  │  Rooted? ADB shell available                         │   │
│  │  Target device for rpi-net MITM interception         │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## HARNESS 1: Claude Code (2 endpoints)

### Lusófona Endpoint (primary, active)
- **Binary:** `~/.local/bin/claude` v2.1.75 (npm global)
- **Config:** `~/.claude/settings.json`
- **Endpoint:** `https://modelos.ai.ulusofona.pt`
- **Model:** `harmonic-hermes-9b`
- **Auth:** `sk-wNL...4DJA` (plaintext in 4 files)
- **Effort:** high, dangerous-mode skipped
- **Sessions:** `~/.claude/projects/` (JSONL per project)
- **History:** `~/.claude/history.jsonl` (58KB)
- **Legacy config:** `~/.openclaude/` (same endpoint, older sessions)

### DeepSeek Endpoint (wrapper, needs API key)
- **Wrapper:** `~/bin/claude-deepseek` (Pro primary, Flash subagents)
- **Wrapper:** `~/bin/claude-deepseek-flash` (Flash primary, Pro subagents)
- **Endpoint:** `https://api.deepseek.com/anthropic` (native Anthropic format)
- **Models:** `deepseek-v4-pro[1m]` (1.6T/49B active), `deepseek-v4-flash` (284B/13B active)
- **Key file:** `~/.config/deepseek/api_key` (0600, placeholder currently)
- **Pricing:** Pro $0.435/$0.87 in/out per 1M · Flash $0.14/$0.28
- **Caveats:** redacted_thinking round-trip 400, no image support, nonstreaming fallback disabled

---

## HARNESS 2: OpenCode + Slim/OMO

- **Config:** `~/.opencode/opencode.json`
- **Plugin:** `oh-my-opencode-slim` (pinned @1.14.29)
- **Provider:** Lusófona (`@ai-sdk/openai-compatible` → `https://modelos.ai.ulusofona.pt/v1`)
- **Slim config:** `~/.config/opencode/oh-my-opencode-slim.jsonc`
- **z.ai models:** GLM-5.2 (orchestrator/oracle/designer/redteam), GLM-5-turbo (librarian/explorer/fixer)
- **Sessions:** `~/opencode-sessions/` (16 sessions exported as JSON + MD)
- **MCP:** kali-tools (dormant, enabled on-demand)
- **Skill vault:** `~/.opencode/skill-vault/` (9,327 symlinks → 9,455 indexed skills)
- **Startup optimization:** pointers-only (37 pointers, ~255 tokens), no eager loading

---

## HARNESS 3: Hermes Agent (this session)

- **Version:** v0.17.0
- **Model:** deepseek-v4-pro via ollama-cloud
- **68 skills** across 14 categories
- **24 toolsets** (16 enabled)
- **70+ bundled plugins** (all not enabled)
- **Memory:** enabled (2200 char limit)
- **Delegation:** max 3 concurrent children, depth 1
- **Cron:** idle (no jobs)
- **MCP:** none configured
- **Profiles:** single (default)

---

## THE RIG: rpi-net (portable MITM platform)

### Physical Architecture
```
TP-Link M7000 (4G LTE) ──wlan0──▶ Raspberry Pi 4 ──wlan1──▶ Phone (target)
                  (the line)       (the rig)        (the net)
```

### Interface Map (authoritative)
| Interface | Hardware | Mode | Role |
|-----------|----------|------|------|
| wlan0 | Onboard BCM43455 | client | WAN uplink → M7000 |
| wlan1 | TP-Link T3U Plus (RTL8822BU) | AP | Capture point `><>` |
| eth0 | RPi Ethernet | — | Docked LAN only |

### Capture Stack
| Goal | Tool | Layer |
|------|------|-------|
| Live packet view | tcpdump -i wlan1 / Wireshark | L2-L4 |
| DNS from clients | dnsmasq logs | L7 queries |
| TLS/HTTPS payloads | mitmproxy (transparent) + CA | L7 decrypted |
| Runtime hooks | frida / objection | in-app |
| BLE analysis | btmon / bettercap | 2.4 GHz |

### Wireless Pentest (wlan1 dedicated)
- Monitor mode + packet injection: ✅ (no sudo needed)
- 4-layer privilege stack: polkit + setcap + udev + NM drop-in
- Bands: 2.4 GHz + 5 GHz (incl. DFS)
- Tools with caps: iw, ip, airodump-ng, aireplay-ng, airmon-ng, wifite

### Bolt Security Research (Phase 2 target)
- `~/rpi-net/Bolt-Security-Research/`
- Shared e-scooter app security assessment
- APK decompiled (jadx), static analysis done
- MITM pipeline drafted, ready for field exercise
- Token extraction, BLE analysis planned

### Session Discipline
- Lab vs Field modes (different risk profiles)
- L1 (rig infra) / L2 (interception) / L3 (research tooling)
- CONTEXT-UPDATE.md as live briefing
- Capture-first, build-second

---

## THE VAULT: Obsidian Knowledge Base

`~/obsidian-vault/` — 8 markdown files, interlinked

| Note | Content |
|------|---------|
| Claude Code + OpenCode Setup | Full inventory of AI tooling stack, backup manifest |
| DeepSeek V4 Claude Code Harness | Second Claude Code endpoint, wrapper docs |
| RPi-Net Session Log | Living session log, decisions, progress |
| Bolt Security Research — MITM | Bolt app MITM attack capability research |
| Wireless Pentesting Infrastructure | wlan1 pentest setup, privilege stack |
| RPi Reliability — Zombie State | Watchdog, swap, tmux-continuum hardening |
| Agent Loop Skill — Iterate-Until | Behavior pattern for iterative agent tasks |
| Next Session Pickup | Pre-reboot handoff note |

---

## THE FRAMEWORK: Diane (shared-local)

`~/shared-local/` — cross-harness pentesting framework

### Structure
```
shared-local/
├── hub/
│   ├── AGENTS.md              ← Entry point for agents
│   ├── skill-architecture.md  ← Zero-compute design (13.7K)
│   ├── curated/               ← Curated skill notes
│   └── notes/                 ← Misc notes
├── skills/
│   ├── index.json             ← 75,645 lines, 9,455 indexed skills
│   └── native/                ← aws-iam-privesc, c2-infra, llm-prompt-injection
├── scripts/
│   ├── kali-mcp-server.py     ← FastMCP server (25KB, 844 lines)
│   ├── skillpointer-migrate.py ← Skill index migration
│   ├── ledger.py              ← Session ledger
│   └── handoff-schema.json    ← Session handoff format
└── reports/
    ├── claude-universal/      ← Main produced project (TypeScript tool)
    └── wireless-infra-001/    ← Wireless pentest engagement
```

### Agent Definitions (OpenCode)
- kali-recon: Reconnaissance (passive + active)
- kali-exploit: Exploitation (vulnerability validation)
- kali-red-team: General red-team operations
- kali-wireless: Wireless pentesting

---

## ANDROID: Connected Phone

- **Device:** GAAZCY072652MLB (Samsung? — ADB connected)
- **ADB:** v1.0.41, connected via USB
- **Status:** device authorized, shell available
- **Role:** Primary target device for rpi-net interception
- **Tools available:** frida, objection, apktool (on Pi)

---

## ORCHESTRATOR: pi-orchestrator

`~/pi-orchestrator/` — agent self-management framework

```
pi-orchestrator/
├── BACKLOG.md        ← Task tracking
├── vault/
│   ├── architectures/
│   ├── ideas/
│   ├── models/
│   ├── patterns/
│   ├── personas/
│   ├── tasks/
│   └── workflows/
├── scripts/
└── sessions/
```

Status: Initial setup, not yet operational. Health checks and dependency audits planned.

---

## KALI TOOLS INVENTORY (installed, available)

### Wireless
aircrack-ng, airodump-ng, aireplay-ng, airmon-ng, wifite, reaver, kismet (full suite), fern-wifi-cracker, bully, pixiewps, hcxdumptool, hcxtools

### Network Recon
nmap, zenmap, netcat (openbsd + traditional), socat, hping3, unicornscan, masscan, amass, dnsrecon, dnsenum, theharvester, spiderfoot

### Exploitation
metasploit-framework, sqlmap, hydra, john, hashcat, patator, commix, routersploit, set (Social Engineering Toolkit), powershell-empire, starkiller

### Web App
burpsuite, zaproxy, nikto, dirb, dirbuster, gobuster, ffuf, wpscan, whatweb, skipfish, davtest, wafw00f, sslyze, testssl.sh

### Windows / AD
impacket-scripts, crackmapexec → netexec, bloodhound.py, mimikatz, evil-winrm, enum4linux, smbclient, responder, certipy-ad, ldapdomaindump, powerview, powersploit

### Android / Mobile
adb, apktool, jadx, objection, frida, drozer, mobsf (if installed), androguard

### Forensics / Reverse
binwalk, bulk-extractor, sleuthkit, autopsy, volatility3, radare2, gdb, ghidra (if installed)

### MITM / Interception
mitmproxy, bettercap, ettercap, sslstrip, dnschef, proxychains4, tor

### Password / Hash
john, hashcat, hash-identifier, cewl, crunch, rsmangler, statsprocessor, maskprocessor, pipal

### Reporting
faraday (full suite), sparta, legion, magic-tree, dradis (if installed)

---

## PYTHON ECOSYSTEM (key packages)

```
numpy, pandas, scapy, requests, beautifulsoup4, playwright,
flask, fastapi, django, pydantic, rich, prompt_toolkit,
networkx, nltk, markdown, pyyaml, tomlkit, neo4j
```

---

## NPM GLOBAL PACKAGES

```
@gitlawb/openclaude@0.19.0     ← Claude Code fork (the `claude` binary)
@mariozechner/pi-coding-agent@0.70.6  ← Pi coding agent
agent-browser@0.27.0           ← Agent browser tool
```

---

## CUSTOM SCRIPTS (~/bin/)

| Script | Purpose |
|--------|---------|
| claude-deepseek | Claude Code → DeepSeek V4 Pro |
| claude-deepseek-flash | Claude Code → DeepSeek V4 Flash |
| pitemp | Pi temperature/health monitor |
| aapt2 + wrapper | Android APK tooling |

---

## CUSTOM TOOLS (~/.myscripts/)

Notable:
- `obsidian-polish` (31KB) — Obsidian note formatter
- `or-bench` (23KB) — OpenRouter benchmark tool
- `or-model-select` (16KB) — Model selection helper
- `mfab` (17KB) + `mfab.env` — Multi-fabric pattern runner
- `fabric-custom-patterns/` (41 patterns) — Daniel Miessler fabric patterns
- `fabric-graph-agents/` — Graph-based agent patterns
- `deploy-searxng.sh` — Self-hosted search deployment
- `ocr-quick-start.sh` — OCR pipeline

---

## CAPABILITY GAPS & OPPORTUNITIES

### What's Missing (to wire up)
1. **DeepSeek API key** — `~/.config/deepseek/api_key` has placeholder; get key at platform.deepseek.com
2. **Hermes SOUL.md** — currently empty; needs red-team agent identity
3. **Hermes provider** — currently ollama-cloud; could point at Lusófona or DeepSeek directly
4. **pi-orchestrator** — initial setup only; health checks not running
5. **MCP kali-tools** — dormant; enable for on-demand Kali tool access
6. **Cron jobs** — none scheduled; could automate health checks, session summaries
7. **Gateway** — not configured; could expose Hermes on Telegram/Discord

### What's Powerful (already working)
1. **Three independent AI harnesses** on one Pi — Claude Code, OpenCode, Hermes
2. **Two LLM providers** — Lusófona (harmonic-hermes-9b) + DeepSeek (V4 Pro/Flash)
3. **Full Kali toolchain** — every major pentest tool installed and ready
4. **Wireless pentest** — wlan1 with monitor mode + injection, no sudo
5. **Android target** — phone connected via ADB, ready for mobile assessment
6. **MITM rig** — rpi-net with transparent proxy, capture stack, field-ready
7. **9,455 indexed skills** — massive pentest knowledge base
8. **Obsidian vault** — interlinked knowledge, session continuity
9. **Cross-harness shared infrastructure** — Diane framework works across all agents

---

## RECOMMENDED HERMES CONFIGURATION

### SOUL.md (red-team agent identity)
Hermes should embody a red-team operator identity:
- Knows the full Kali toolchain
- Understands the rpi-net rig architecture
- Can operate across all three harnesses
- Uses the Obsidian vault as persistent memory
- Follows rpi-net WORKING-AGREEMENT.md discipline
- Can spawn sub-agents for parallel recon/exploit/report tasks

### Skills to preload for red-team sessions
```
hermes -s wireless-pentesting,github,obsidian,plan,systematic-debugging
```

### Toolsets to enable
```
hermes tools enable video     # for screen recording
hermes tools enable spotify   # if needed
```

### Memory to seed
- Rig architecture (interfaces, lexicon)
- Available tools and their paths
- Working agreement principles
- Session handoff protocol

---

*Map complete. This document is the authoritative index of every capability on this system as of 2026-06-30.*
