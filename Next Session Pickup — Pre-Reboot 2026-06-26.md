# Next Session Pickup — Pre-Reboot 2026-06-26

> **Read this first.** 30-second scan to know what you're walking into.
> Rig state after: watchdog + swap + tmux-continuum hardening. About to reboot.

---

## TL;DR

The Pi is getting a planned reboot to activate `dtparam=watchdog=on` in `/boot/config.txt`. Before that, we hardened everything so sessions survive reboot:

- **tmux persistence wired up** (resurrect + continuum + systemd unit)
- **Watchdog active** (30s hardware reset on hang)
- **1GB swap active** (OOM insurance)
- **`validate-boot.sh`** now has 13 checks (up from 12 — added watchdog + swap + throttle)

When you SSH in after reboot, run the checklist below. Takes 60 seconds. Then continue APK analysis.

---

## Post-Reboot Checklist

```bash
# 1. Validate rig health (13 checks)
sudo bash ~/rpi-net/scripts/validate-boot.sh

# 2. Check throttle (should be 0x0 on clean boot)
vcgencmd get_throttled

# 3. Watchdog + swap
systemctl is-active watchdog
swapon --show

# 4. tmux auto-restored?
tmux list-sessions
# (should show opencode session from before reboot)
tmux attach   # or tmux attach -t <name>

# 5. Re-authorize phone
adb devices
# If "unauthorized" → tap "Allow" on phone screen
```

---

## What Survives the Reboot

### ✅ On disk (permanent)
- All APKs in `~/rpi-net/Bolt-Security-Research/apk/`
- apktool output (48,875 smali files) in `~/rpi-net/lab/apktool-output/`
- All vault notes in `~/obsidian-vault/`
- All project docs in `~/rpi-net/`
- All configs: watchdog (`/etc/watchdog.conf`), tmux (`~/.tmux.conf.local`), swap (`/etc/fstab`), systemd units

### ✅ On boot (automatic)
- **watchdog** starts via systemd → 30s hardware reset on hang
- **swap** mounts via fstab → 1GB available
- **tmux server** starts via systemd → continuum auto-restores last session

### ⚠️ Needs re-auth after reboot
- **adb USB debugging** on the ASUS phone — always requires on-screen tap
- **mitmproxy cert** stays on phone (already trusted), but capture services may need restart

---

## Key Findings from Tonight

| Finding | Detail |
|---------|--------|
| **Package name** | `ee.mtakso.client` (NOT `com.taxify.core` — OSINT was wrong) |
| **Attack model** | **Server-side unlock** — no direct phone↔scooter BLE. The old `bolt4free.py` BLE MITM approach is ~2022. The actual attack surface is the API. |
| **BuildConfig** | `APPLICATION_ID=ee.mtakso.client`, `BOLT_SERVER_URI=https://user.live.boltsvc.net/`, `FLAVOR=liveGooglePlayBolt` |
| **No SNSC SDK** | No Ninebot/Segway BLE SDK found in APK — confirms server-side unlock model |
| **BLE code** | `AndroidBluetoothServiceHelper` handles **car-sharing offline BLE**, not scooters |
| **No SSL pinning** | No `network_security_config.xml` in manifest — consistent with community reports |
| **Throttle status** | `0xe0008` → 0xe0000 (improved after USB re-plug). Under-voltage cleared, only historical soft-temp-limit remains. |
| **Temp** | 81.3°C — hot, needs physical cooling, not blocking |
| **jadx** | Killed by OOM on 27MB APK. Using apktool smali instead — memory efficient. |

---

## Next Priorities (from CONTEXT-UPDATE.md)

1. **Verify** reboot validation passes
2. **Re-authorize** phone via adb
3. **Continue APK analysis** — find actual ride/rental endpoints in smali
4. **Update** `api-surface-reference.md` with correct package name (`ee.mtakso.client`)
5. **Update** `Mission.md` to reflect server-side unlock model
6. **Plan** the iPhone traffic capture

---

## tmux Persistence Details

| Component | Purpose |
|-----------|---------|
| **TPM** | Plugin manager for tmux |
| **tmux-resurrect** | Saves/restores sessions, windows, panes, working dirs, programs |
| **tmux-continuum** | Auto-saves every 15min, auto-restores on tmux start |
| **systemd unit** | `tmux-server.service` — starts tmux at boot, restart on failure |
| **Save location** | `~/.local/share/tmux/resurrect/` (XDG path, NOT `~/.tmux/resurrect/`) |

**Keybindings:**

| Binding | Action |
|---------|--------|
| `Ctrl-b + Ctrl-s` | Manual save |
| `Ctrl-b + Ctrl-r` | Manual restore |
| continuum | Auto-save every 15min (background) |

**After reboot flow:** systemd starts tmux → continuum detects → triggers restore → `tmux attach` → opencode session is back.

---

## Pi Health Snapshot

| Check | Value | Status |
|-------|-------|--------|
| Watchdog | active, timeout=30 | ✅ |
| Swap | 1024MB, 0B used | ✅ |
| tmux | plugins installed, continuum active | ✅ |
| Throttle | 0xe0000 (improved — no under-voltage) | ⚠️ historical flag |
| Temp | 81.3°C | ⚠️ hot, needs cooling |
| Load | healthy | ✅ |
