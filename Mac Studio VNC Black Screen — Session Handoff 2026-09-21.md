---
title: Mac Studio VNC Black Screen — Session Handoff 2026-09-21
date: 2026-09-21
tags: [infra, handoff, mac-studio, vnc, remmina, ssh, headless]
status: handoff — continue in clean session
related: "[[csis-mac-studio]]"
---

# Mac Studio VNC Black Screen — Session Handoff (2026-09-21)

> Pick-up doc for a clean session. Machine facts live in [[csis-mac-studio]]; this note is the investigation state + what's next.

## TL;DR

Goal: GUI access to the Mac Studio from `li` via VNC (Remmina). **SSH bridge: solved and verified.** **VNC: connects and authenticates, but renders a black screen.** Strongest root-cause hypothesis after this session: **the Mac is headless** (HDMI physically disconnected, network-only) — macOS 26.2 keeps a cached/virtual display config but renders nothing into any framebuffer a VNC client can mirror. Next session should re-test at the desk with HDMI connected, then decide the permanent headless strategy.

## Solved this session

1. **SSH key exchange (li → Mac Studio)** — built and hardened a reusable tool, `ssh-bridge` at `~/projects/ssh-key-bridge/` (symlinked into `~/.local/bin/`). Password never touches argv/env/history; host keys pinned; retries on wrong password; only claims success after a proven passwordless login. Three bugs found and fixed during the session: it used to guess the remote username (the Mac's only user is `csi` — any `fabio@` attempt could never work), a `^C` mid-`ssh-copy-id` produced a false success message, and the verify step didn't name the key explicitly.
2. **Access state** — `ssh mac-studio` works passwordless; host key pinned in `known_hosts`; `~/.ssh/config` block: `mac-studio` → `csi@100.94.171.75`.
3. **Tooling installed** — Remmina 1.4.43 (flatpak, `org.remmina.Remmina`), TigerVNC viewer (apt) as an independent second client for isolation testing.

## Evidence gathered (VNC investigation)

- VNC server answers: port 5900 open, RFB 3.889 handshake, Apple-proprietary auth only (types 30/33/35/36 — no legacy VNC password auth).
- Remmina authenticates successfully → session established → **black framebuffer**.
- `pmset -g log`: display cycles "turned on → turned off" every ~30 s after each `caffeinate -u` wake; `screensharingd` holds only *system*-sleep prevention ("Remote user is connected"), never display-sleep.
- `ioreg` shows **zero IODisplayEDID** when "off" — consistent with no monitor connected.
- `screencapture -x` over SSH fails with "could not create image from display" — no real framebuffer content.
- `system_profiler` still reports a 1920×1080 "Main Display" — cached/virtual config, misleading.
- Ruled out: wrong username, wrong password, network/firewall (Tailscale path clean), display sleep *timing* (black even with `caffeinate -dis` holding the display awake), Remmina auth handling.

## Next session plan

1. **At the desk, HDMI connected** → retest Remmina → `vnc://csi@100.94.171.75`. If desktop appears, root cause confirmed as headless-only.
2. **Headless strategy** (pick one):
   - **HDMI dummy plug** (~5 €, DisplayPort/HDMI emulator) — most reliable, makes macOS render a real framebuffer 24/7.
   - **BetterDisplay** (or similar virtual display driver) — software virtual screen; verify VNC mirrors it on macOS 26.
   - If TigerVNC renders where Remmina doesn't → client-side encoding bug; keep TigerVNC as the driver.
3. **Permanent power settings** once GUI works: `sudo pmset -a displaysleep 0` (or high value) + System Settings → Displays → Advanced → "Wake for network access".
4. **Alternative worth considering**: Tailscale SSH on the Mac for terminal access without key management; VNC remains for GUI only.

## Session arc (what got fixed along the way)

- Flatpak flathub remote + Remmina install (remote-add had run before flatpak existed — ordering bug).
- Diagnosed and hardened `ssh-bridge` (see `~/projects/ssh-key-bridge/README.md` for design rules).
- Cleaned stale artifacts: old `exchange-keys` script, unused `id_ed25519_100.94.171.75` key.