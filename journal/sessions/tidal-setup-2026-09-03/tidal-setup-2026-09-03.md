---
tags: [session, tidal, supercollider, vim, tmux, kali]
date: 2026-09-03
status: complete
project: TidalCycles Haskell setup
---

# Session — TidalCycles install + vim/tmux engine (2026-09-03)

> Folder: `journal/sessions/tidal-setup-2026-09-03/`
> Full validation checklist: `~/tidal/VALIDATE.md` (L0→L8, all green 2026-09-02).

## Goal
Install old-school Haskell TidalCycles from its new home (off GitHub), wire an
optimized vim + tmux workflow around ONE shared tidal process running in
parallel with SuperCollider, and validate bottom-up.

## What happened
1. **Repo move confirmed** — GitHub `tidalcycles/Tidal` archived 2025-06-13
   (issue #1210); canonical is now `https://codeberg.org/uzu/tidal`, v1.10.3.
   Docs: `tidalcycles.org/docs/getting-started/linux_install/`,
   `.../editor/Vim/`, `.../configuration/boot-tidal/`.
2. **Local audit** — Kali 2026.3 clean slate: no ghc/cabal/SC, no `~/.vimrc`,
   vim 9.2, tmux 3.7b (base-index 1). "Lisbon config" not on disk (only
   Lisbon-transit notes — unrelated). Still open: paste link if found.
3. **Install** — `sudo bash /tmp/tidal-install.sh` (apt: ghc 9.10.3,
   cabal 3.12.1.0, SC 3.14.1, jack; then `cabal install tidal --lib` as user).
   SuperDirt v1.7.4 + Dirt-Samples + Vowel installed headless via
   `/tmp/install-superdirt.scd`.
4. **Editor design, two iterations**
   - v1: fixed layout (engine = `tidal:1.0`, editors = windows 2..N).
   - v2 (simpler, current): `tidal-up` turns **the pane you run it in** into
     ghci, splits sclang alongside, records address in
     `~/.config/tidal/engine-pane`; `.vimrc` reads the pointer (fallback
     `tidal:1.0`); `tidal-vim` opens editors in the engine's session.
5. **sclang log diagnosis (tmux `0:2.2`)** — three stacked failures:
   `No more buffer numbers` (1024 default < Dirt library) →
   `DelayC_Ctor: alloc failed` (RT mem too small) → JACK xrun →
   `JackTemporaryException`, scsynth dead. Fixed in
   `~/.config/tidal/BootSuperDirt.scd` (numBuffers 1024*256,
   memSize 8192*32, maxNodes 1024*32 **before** `s.boot`).

## Files
- `~/.vimrc` — vim-tidal, tmux target, engine-pane pointer, `<C-e>` eval,
  `<leader>h` hush, `<leader>tc` re-point, `.tidal` abbreviations
- `~/.vim/pack/tidal/start/vim-tidal/` — plugin clone
- `~/.config/tidal/BootTidal.hs` — fallback boot (`:script`s plugin Tidal.ghci)
- `~/.config/tidal/BootSuperDirt.scd` — boots server + SuperDirt :57120
- `~/bin/tidal-up`, `~/bin/tidal-vim` — engine + editor launchers
- `~/tidal/daily/` — daily `.tidal` files · `~/tidal/VALIDATE.md` — checklist

## Validation (2026-09-02, L0→L8 ALL GREEN)
ghci import exit 0 · `:t d1` → `Pattern ValueMap -> IO ()` · `SUPERDIRT_CLASS_OK` ·
vim `ft=tidal target=tmux` · pointer-file follow + fallback verified ·
tmux plumbing verified. Quirk: banner prints 1.10.1, store is 1.10.3 (harmless).

## Open / next
- [ ] JACK up → restart sclang pane → confirm no buffer/alloc errors → `d1 $ sound "bd sn"`
- [ ] First live eval from two vim windows into the one process
- [ ] Lisbon guy's config — integrate if link surfaces
