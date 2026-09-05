---
tags: [session, tidal, supercollider, superdirt, vim, tmux, audio, scarlett, kali]
date: 2026-09-05
status: complete
project: TidalCycles headless rig
related:
  - "[[tidal-setup-2026-09-03]]"
  - "[[Tmux Agent Orchestration — Teamwork & Swarm-Deploy Skills]]"
  - "[[Claude Code No-Login on New Tmux Panes]]"
  - "[[RPi Reliability — Zombie State Prevention]]"
  - "[[Next Session Pickup — Pre-Reboot 2026-06-26]]"
  - "[[cecil-taylor-unit-structures]]"
  - "[[miles-davis-kind-of-blue]]"
  - "[[quincy-jones-walking-in-space]]"
---

# Session — TidalCycles + SuperDirt headless rig, sound on Scarlett (2026-09-05)

> Folder: `journal/sessions/tidal-headless-rig-2026-09-05/`
> Predecessor: [[tidal-setup-2026-09-03]] (install + vim/tmux engine v2). This session closes its two open items (JACK up, first live eval) and redesigns boot ownership.

**Verdict:** end-to-end loop green on a headless Kali container (no display server) — `tup` → vim `.tidal` → `<C-e>` → sound out the Focusrite Scarlett 2i4. Smoke test 2026-09-05: 218 sample banks, `d1 $ s "bd sn" # gain 0.6` audible, `tdown` leaves no procs/ports held.

## Quick-start (the only path)

1. `tup` in a tmux pane — that pane becomes THE ghci engine, sister pane auto-boots sclang/SuperDirt.
2. Open any `*.tidal` in vim, `<C-e>` sends to the one engine pane. `<leader>tc` shows the target, `<leader>h` hushes.
3. Sound comes out the Scarlett. `tstat` checks health, `tdown` kills clean.

## Rig

- ghci + tidal-1.10.3 (cabal global env) ↔ SuperDirt on UDP 57120, `s.options.device = "jack"`.
- Scarlett 2i4 (USB `1235:800a`, ALSA `hw:0`) via PipeWire's JACK shim at 48 kHz. RT-scheduling warnings are cosmetic (container limits).
- Canonical boot pair: `~/.config/tidal/BootSuperDirt.scd` + `~/.config/tidal/BootTidal.hs`. Nothing else boots anything.

## What broke → fix

1. **sclang died at startup** (`qt.qpa.xcb: could not connect to display`, missing xcb plugin) — headless box, expected. Fix: `xvfb-run -a sclang`; class library compiles, interpreter reaches `sc3>`.
2. **Audio device** — Scarlett confirmed `hw:0`; jackd auto-starts via PipeWire shim. No manual jackd needed.
3. **Ghost bug: two SuperDirts fighting over UDP 57120** (`Could not open UDP port 57120`). Root: duplicate boot files + re-running boot without killing the old one. Killed by: deleted `~/superdirt-boot.scd` and stray `~/tidal/BootTidal.hs`, ONE boot owner (`~/bin/tup`), `tdown` + `tup` guard checks (engine-pane alive? port 57120 busy? refuse).
4. **Stale pane-index addressing** — tmux `0:2.2`-style targets rot on layout change. Now stable `%N` pane IDs in `~/.config/tidal/engine-pane` + `sc-pane`. `~/.vimrc` resolves the engine lazily per send, loud error if missing (`run tup`), no silent fallback.
5. Removed the `sclang()` zsh wrapper (shadowed the real binary path).

## Files (post-redesign)

- `~/bin/tup` — sole boot owner (ghci here + split sclang pane, guards, pointer files).
- `~/bin/tdown` — kills engine + sclang panes, `sclang`/`scsynth`/`xvfb-run` strays, clears pointers.
- `~/bin/tstat` — pointers + `:5712x` listeners + `sclang|scsynth|ghci` procs.
- `~/.vimrc` — vim-tidal, `g:tidal_target = "tmux"`, lazy `TidalTarget()`, `.tidal` → `ft=tidal`.
- Supersedes: `~/bin/tidal-up`, `~/bin/tidal-vim` (predecessor's v2 launchers).

## Validation (2026-09-05, full loop)

`sclang` under xvfb → server on Scarlett → SuperDirt `start(57120)` → ghci `tidal>` prints "Connected to SuperDirt" → pattern plays → `tdown` clean (no procs, no port held).

## Open

- [ ] Orphan `Xvfb :99–:102` procs from today's experiments: `pkill Xvfb` when convenient.
- [ ] Predecessor's Lisbon-config item still open if the link ever surfaces.
