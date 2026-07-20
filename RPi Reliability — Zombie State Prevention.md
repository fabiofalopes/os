# RPi Reliability — Zombie State Prevention

> Hardware: Raspberry Pi 4, Kali Linux ARM64
> Project: `rpi-net` (portable traffic-interception rig)
> Status: **watchdog enabled, swap active, physical fixes pending**
> Last reviewed: 2026-06-26

---

## TL;DR

The Pi periodically enters a "zombie" state — lights blinking, powered on, completely unreachable (no SSH, no network response). Root cause: USB power budget exceeded. Peripherals (WiFi adapter, phone charging, USB drive, hub) draw more than the Pi's 5V rail can supply, causing SoC instability that hangs the kernel and kills the network stack. The hardware watchdog (`bcm2835_wdt`) now auto-reboots the Pi within 30 seconds of any soft hang. A 1GB swap file provides OOM insurance. Remaining fixes are physical: powered USB hub, separate phone charger, better cooling.

---

## Problem

The Raspberry Pi 4 is the brain of the `rpi-net` rig. In field conditions, it's headless — accessed only via SSH over the `><>` WiFi AP running on `wlan1`. If the Pi goes unreachable, there is no way to recover it remotely. No serial console. No BMC. No IPMI.

**The zombie state:**
- LEDs blinking normally (PMU is alive)
- Device responds to nothing — no SSH, no ping, no ARP
- No crash logs, no kernel panic on console — the kernel simply stops scheduling
- Only recovery: physical power cycle (unplug/replug USB-C)

**Why it happens:** The Pi 4's 5V rail has a finite current budget. USB devices connected to its ports draw from that same rail:

| Device | Approx. draw |
|--------|-------------|
| TP-Link Archer T3U Plus (RTL8822BU) | 200–400 mA |
| VIA Labs USB hub | 100–200 mA |
| Kingston DataTraveler USB drive | 100–300 mA |
| ASUS Android phone (charging) | 500–1500 mA |
| **Total** | **900–2400 mA** |

When total draw exceeds the power supply's capability (or causes voltage droop on the 5V rail), the SoC doesn't die — it becomes **unstable**. The kernel continues running threads in a degraded state until something (often memory pressure from jadx decompilation or concurrent I/O) pushes it over the edge. The network stack is the first casualty.

---

## Diagnosis

Captured at the time of fix (Pi was in throttled but operational state):

### `vcgencmd get_throttled` — 0xe0008

```
Binary: 1110 0000 0000 0000 1000
        │││          │
        │││          └─ Bit 3: Soft temperature limit occurred
        ││└──────────── Bit 7: Currently throttled
        │└───────────── Bit 8: ARM frequency capping occurred
        └────────────── Bit 9: Under-voltage occurred
```

| Flag | Meaning |
|------|---------|
| Under-voltage occurred | Voltage dropped below 4.63V at some point |
| ARM frequency capping | SoC reduced clock speed to protect itself |
| Currently throttled | Still throttling at time of reading |
| Soft temp limit occurred | Hit 80°C+ and triggered soft throttle |

Non-zero `get_throttled` = something is wrong. This was **never checked** before the first zombie event.

### Voltage

| Measurement | Value | Normal range |
|-------------|-------|-------------|
| `vcgencmd measure_volts` | 0.8500V | 0.87–0.90V |
| `vcgencmd measure_temp` | 82.7°C | < 80°C |

SoC voltage at the low end and temperature above the 80°C throttle threshold. The Pi was simultaneously under-powered and overheating.

### System state

- Swap: **0** (no swap configured — any OOM event is fatal)
- `/dev/watchdog` and `/dev/watchdog0`: **exist** (hardware watchdog available but unused)
- `watchdog` daemon: **not installed**
- `/boot/config.txt`: **no `dtparam=watchdog=on`**
- Load at fix time: 1.38 (healthy — the zombie state is intermittent, not constant)

---

## Fixes Applied

### 1. Hardware watchdog (primary fix)

The SoC has a built-in watchdog timer that resets the entire system if the kernel stops responding. This is the single most important reliability fix for a headless Pi.

**Installation:**
```bash
apt install watchdog       # version 5.16-1.2
```

**`/etc/watchdog.conf` configuration:**
```ini
watchdog-device    = /dev/watchdog
watchdog-timeout    = 30
interval           = 10
max-load-1         = 24
max-load-5         = 18
max-load-15        = 12
min-memory         = 1
check              = yes
realtime           = yes
```

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `watchdog-timeout` | 30 | SoC resets if not petted for 30 seconds |
| `interval` | 10 | Daemon pets the watchdog every 10 seconds |
| `max-load-1` | 24 | Reboot if 1-minute load average exceeds 24 |
| `max-load-5` | 18 | Reboot if 5-minute load exceeds 18 |
| `max-load-15` | 12 | Reboot if 15-minute load exceeds 12 |
| `min-memory` | 1 | Reboot if free memory drops below 1 page |
| `realtime` | yes | Reboot on timeout (don't just stop) |

**`/boot/config.txt` enable (takes effect on next reboot):**
```
dtparam=watchdog=on
```

**Immediate activation (no reboot needed):**
```bash
modprobe bcm2835_wdt                    # load kernel module now
systemctl enable watchdog               # persist across boots
systemctl restart watchdog              # start immediately
```

**Post-fix verification:**
```bash
systemctl is-active watchdog            # → active
systemctl status watchdog               # → running, no errors
```

### 2. Swap file (OOM insurance)

The Pi had **zero swap**. Under memory pressure (which happens when jadx processes a 27MB APK, or during concurrent mitmproxy + tcpdump sessions), the kernel invokes the OOM killer. On a Pi, OOM-killing a critical process cascades into a system hang. Swap buys time.

```bash
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

**`/etc/fstab` entry for persistence:**
```
/swapfile none swap sw 0 0
```

**Post-fix state:**
```bash
swapon --show
# NAME       TYPE SIZE USED PRIO
# /swapfile  file 1024M   0B   -2
```

1GB swap, 0B used at time of creation — available for peak loads.

### 3. Kernel module persistence

The `bcm2835_wdt` module must load at boot. If `/etc/modules` exists, verify it's listed:

```bash
grep bcm2835_wdt /etc/modules
bcm2835_wdt
```

---

## Post-Fix State

| Check | Value | Status |
|-------|-------|--------|
| Watchdog daemon | active (running) | ✅ |
| Swap | 1GB active, 0B used | ✅ |
| Temperature | 81.8°C | ⚠️ Still hot — needs physical cooling |
| `get_throttled` | 0xe0008 (sticky) | ⚠️ Clears on reboot or when power improves |
| Load | 1.38 | ✅ Healthy |

The throttled flags (`0xe0008`) are **sticky** — they persist until cleared by a reboot or until the underlying condition (voltage/temp) stays normal for a sustained period. Non-zero flags don't mean the Pi is currently throttling, just that it has throttled at some point since last reset.

---

## Physical Fixes Still Needed

These cannot be solved in software. They require hardware changes:

- **Powered USB hub** — isolates peripheral power draw from the Pi's 5V rail. The TP-Link adapter, USB drive, and phone charger all draw from the Pi today. A powered hub means the Pi only powers the hub's logic, not the peripherals.
- **Stop charging phone from Pi** — the ASUS phone pulls up to 1.5A when charging. Use a separate phone charger or a power bank with dual outputs.
- **Better thermal solution** — 82°C is above the 80°C throttle threshold. A heatsink + fan on the SoC (or at minimum, passive airflow in the case) keeps the Pi at full clock speed.
- **Verify power supply** — ensure the Pi is powered by an official 5.1V/3A adapter, not a phone charger (which may deliver 5.0V or sag under load). The M7000 4G hotspot has a pass-through charging limitation — verify the Pi isn't running off a degraded power source.

---

## Detection Commands

Quick-reference for checking zombie risk factors:

```bash
# Power and throttling
vcgencmd get_throttled       # non-zero = under-voltage or thermal issue
vcgencmd measure_volts       # SoC core voltage (should be 0.87-0.90V)
vcgencmd measure_temp         # should be < 80°C

# System health
cat /proc/loadavg            # load averages (1, 5, 15 min)
swapon --show                # swap status and usage
free -h                      # memory usage summary

# Watchdog
systemctl is-active watchdog # active = running
systemctl status watchdog    # full status with last pet time

# Previous boot (if watchdog rebooted)
journalctl -b -1 --no-pager  # logs from the boot before the current one
```

### What to look for

| Check | Bad signal | Action |
|-------|------------|--------|
| `get_throttled` | Non-zero | Check power supply, reduce USB draw |
| `measure_volts` | < 0.87V | Power supply sagging, check cables |
| `measure_temp` | > 80°C | Throttling active — needs cooling |
| `loadavg` (1 min) | > 8 | Heavy load — watch for OOM |
| `swapon --show` | Used > 0 | Memory pressure, investigate |
| `is-active watchdog` | inactive | Watchdog not running — fix immediately |

---

## Future Maintenance

### After next reboot
- The `dtparam=watchdog=on` in `/boot/config.txt` takes effect
- Verify with: `ls /dev/watchdog*` and `systemctl is-active watchdog`
- The `0xe0008` throttled flags will clear on clean boot if the power/thermal conditions are resolved

### If watchdog reboots the Pi
- The current session is lost (the watchdog resets the SoC — no graceful shutdown)
- Run `journalctl -b -1` to see the previous boot's logs
- Look for the last kernel messages before the reset — they may indicate what hung
- Check `/var/log/watchdog.log` for watchdog daemon messages

### Regular checks
- Add `vcgencmd get_throttled` to the field session startup checklist
- Monitor temperature during heavy work (jadx decompilation, long captures)
- If the Pi reboots unexpectedly and the watchdog was active, the watchdog likely fired — investigate the root cause, don't just dismiss it

### If zombie state recurs despite watchdog
- The watchdog only handles **soft hangs** (kernel still scheduling, network stack dead)
- Hard hangs (kernel panic, SoC lockup) may not trigger the watchdog — the SoC must still be running to reset
- If the Pi stops responding AND the watchdog doesn't reboot it within 60 seconds, the hang is below the watchdog level — needs hardware debugging (serial console, HDMI)
- Most likely remaining cause: power supply failure causing complete brownout (watchdog can't help — the SoC has no power)

---

## Why This Matters to the Project

- The zombie state loses field sessions — the rig is the phone's only internet path during capture
- No auto-recovery meant every zombie event required physical access to the Pi
- The hardware watchdog is the single most important reliability fix for a headless/remote Pi
- This affects **any** project on this Pi, not just `rpi-net`
- A Pi that self-recovers from hangs is field-worthy; one that doesn't is a lab toy
