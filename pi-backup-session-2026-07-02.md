---
tags:
  - backup
  - pi-migration
  - session-log
date: 2026-07-02
---

# Pi Backup Session — 2026-07-02

**Goal:** Full harvest of RPi (`192.168.108.101`) onto Kali Lenovo laptop.

---

## What Was Done

### Phase 1 — Reconnaissance
- SSH access confirmed (passwordless)
- Full filesystem map: agent harnesses, projects, scripts, dotfiles, system state
- Pi: `kali-raspberry-pi`, 3,432 dpkg packages

### Phase 2 — Transfer
All data rsync'd into two local trees:

| Location | Size | Contents |
|----------|------|----------|
| `~/rpi-backup/from-pi/` | 7.7 GB | Full raw mirror of `/home/ken/` on Pi |
| `~/rpi-backup/curated/` | 1.5 GB | Essentials only |

### Phase 3 — Curation
Stripped all replaceable bloat from `curated/`:

**Removed:**
- `rpi-net/lab/` — 1.7 GB APK build artifacts
- `.local/` — 962 MB pip/cache/trash
- `.bun/` — 628 MB Bun runtime
- `.npm-global/` — 489 MB global npm
- All `node_modules/` — ~1.6 GB deps
- `__pycache__` / `.pyc` — bytecode
- `.hermes/` caches (model cache, image/audio, logs)

**Kept in curated/ (1.5 GB):**

| Category | Items | Size |
|----------|-------|------|
| **Agent Harness** | `.hermes/`, `.opencode/`, `.config/opencode/`, `.claude/`, `.openclaude/`, `opencode-sessions/` | ~830 MB |
| **Projects** | `diane-agent-kit/`, `shared-local/`, `rpi-net/` (docs), `camera-server/`, `m5stack-dial/`, `pi-orchestrator/`, `claude-dashboard/` | ~405 MB |
| **Tools & Scripts** | `bin/`, `.myscripts/`, `.tmux/` | ~67 MB |
| **Dotfiles & Config** | `.zshrc`, `.bash*`, `.profile`, `.ssh/`, `.npmrc`, `.claude.json`, `.openclaude.json`, `.agents/`, `.pi/`, `.slim/`, `.chelper/`, `.mitmproxy/` | ~10 MB |
| **System Snapshots** | dpkg list, sshd_config, dhcpcd.conf, system info | ~1 MB |

---

## Organization Plan

### Option A: Merge into Live Locations

Agent harness expects paths like `~/.hermes/`, `~/.claude/` — merge these first:

```bash
# Dry-run first, always
rsync -avzP --dry-run ~/rpi-backup/curated/home/ken/.hermes/ ~/.hermes/

# Then merge with backup
rsync -avzP --backup --backup-dir=~/rsync-backups/ \
  ~/rpi-backup/curated/home/ken/.hermes/ ~/.hermes/
```

Projects are straightforward:

```bash
rsync -avzP ~/rpi-backup/curated/home/ken/diane-agent-kit/ ~/diane-agent-kit/
```

Dotfiles need care — diff first:

```bash
diff ~/rpi-backup/curated/home/ken/.zshrc ~/.zshrc
```

### Option B: Restructure for Clarity

Instead of mirroring the Pi's flat `~/` layout:

```
~/agents/
  ├── opencode/          ← curated/.opencode/
  ├── opencode-config/   ← curated/.config/opencode/
  ├── claude-code/       ← curated/.claude/
  ├── openclaude/        ← curated/.openclaude/
  ├── hermes/            ← curated/.hermes/
  └── sessions/          ← curated/opencode-sessions/

~/projects/
  ├── diane-agent-kit/
  ├── camera-server/
  ├── m5stack-dial/
  ├── pi-orchestrator/
  ├── claude-dashboard/
  ├── rpi-net/
  └── shared-workspace/  ← curated/shared-local/

~/scripts/
  ├── bin/               ← curated/bin/
  └── myscripts/         ← curated/.myscripts/

~/configs/
  ├── shell/
  ├── tmux/
  ├── ssh/
  └── agent-configs/
```

**Best approach:** Agent harness stays in `~/.hermes/` etc. (Option A) — agents hardcode these paths. Projects, scripts, and configs get the Option B treatment.

---

## Tips

### 1. Keep `from-pi/` as cold archive
```bash
tar czf ~/rpi-backup/pi-backup-2026-07-02.tar.gz ~/rpi-backup/from-pi/
```
Store on external drive or cloud, then delete the live copy.

### 2. Run agents locally first
Fire up each agent on the laptop to generate fresh configs, *then* layer Pi history on top. Avoids config conflicts.

### 3. Git for dotfiles
```bash
cd ~/configs && git init && git add -A && git commit -m "initial: dotfiles from pi"
```
Every tweak gets committed. Your personal dotfiles v2 — better organized than the Pi ever was.

### 4. Weekly rsync pipeline
```bash
# save as ~/scripts/sync-from-pi.sh
rsync -avzP --delete --exclude='node_modules' --exclude='__pycache__' \
  rpi:/home/ken/ ~/rpi-backup/from-pi/home/ken/
```

### 5. Tag sessions in Obsidian
Create notes that link back to exported sessions:
- `[[pi-backup-session-2026-07-02]]`
- Link to [[opencode-sessions]] transcripts

### 6. Laptop-first
Pi is secondary now. All new agent work happens on the laptop. Reverse-sync Pi ← Laptop only if needed for ARM-specific testing.

---

## Files Created

| Path | Purpose |
|------|---------|
| `~/rpi-backup/from-pi/` | Full backup (7.7 GB) |
| `~/rpi-backup/curated/` | Essentials (1.5 GB) |
| `~/rpi-backup/system/` | dpkg list, sshd_config, dhcpcd.conf |
| `~/rpi-backup/rpi-manifest.md` | Pi discovery |
| `~/rpi-backup/laptop-manifest.md` | Transfer list |
| `~/rpi-backup/mission.md` | Phase 1 ✅ |

---

## Related

- [[opencode-sessions]]
- `~/rpi-backup/AGENTS.md`
- `~/rpi-backup/mission.md`
