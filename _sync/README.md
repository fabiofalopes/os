# _sync — Vault Mirror & Sync Engine

> One-screen. Lineage: **Ordo** (rclone bisync + inotify, `fabiofalopes/OrdoMount`) × **vaultcraft** (sync.sh mediation, zero-git-in-vault rule, `fabiofalopes/vaultcraft`). This folder makes the vault the **canonical hub**: GitHub above, system folders around, agents inside.

## The three layers

| Layer | Engine | Script | Status |
|---|---|---|---|
| **GitHub** (vault ↔ remote) | git pull/commit/push | `vault-sync.sh run` | ready (needs `git remote add origin …` — human, credentials) |
| **Pairs** (vault ↔ system folders/cloud) | rclone bisync, robust flags | `pairs-sync.sh run` | staged — needs `sudo apt install rclone` + pairs in `pairs.conf` |
| **Harness** (agents ↔ vault) | write-back contract | `../AGENTS.md` | active — every session leaves LOG + artifact |

## Commands

```bash
bash _sync/vault-sync.sh run      # GitHub: pull --rebase → commit → push
bash _sync/vault-sync.sh status   # remote + dirty + last-run
bash _sync/pairs-sync.sh list     # show configured pairs
bash _sync/pairs-sync.sh init P1  # first-time bisync for pair P1 (human run)
bash _sync/pairs-sync.sh run      # all enabled pairs (cron/systemd calls this)
bash _sync/pairs-sync.sh status   # per-pair last result (also in _sync/STATUS.md)
```

## Anti-resurrection guards (the Ordo bug, fixed by config)

1. **Never auto-`--resync`.** Resync is human-only (`init` verb, interactive).
2. Robust set on every run: `--resilient --recover --max-lock 2m --conflict-resolve newer` (official rclone set-and-forget recommendation).
3. `--max-delete 20%` + `--backup-dir` per side → deleted/lost files land in `_sync/backups/`, never gone.
4. Filters exclude `.git`, `.obsidian/`, `_harness/state`, `.trash` — no sync loops with Obsidian state.
5. `flock` per pair — no concurrent bisync state corruption.
6. Aggressive 100s interval was Ordo's amplifier — default cadence here is **cron 10 min** (opt-in), inotify daemon optional.

## Auto-hook (choose ONE, human enables — resource decision)

**A. cron (default, zero idle cost):**
```
*/10 * * * * /usr/bin/flock -n /tmp/vault-sync.lock bash /home/fabio/obsidian-vault-kali/_sync/vault-sync.sh run >> /home/fabio/obsidian-vault-kali/_sync/state/vault-sync.log 2>&1
*/10 * * * * sleep 300 && bash /home/fabio/obsidian-vault-kali/_sync/pairs-sync.sh run >> /home/fabio/obsidian-vault-kali/_sync/state/pairs-sync.log 2>&1
```

**B. systemd user timer** — units staged in `_sync/systemd/`, `systemctl --user enable --now vault-sync.timer`.

**C. inotify live-feel** (only if 10 min feels slow): one `inotifywait -m` daemon per side debouncing 10s → `run`. Near-zero idle CPU, but keep it last.

## UX surface

- `_sync/STATUS.md` — rewritten by every run; Dashboard reads it (inline fields, no JS).
- 5-pin cockpit unchanged: sync state is a Dashboard section, not a sixth pin.

## Rules (from vaultcraft, enforced here)

- Zero git artifacts inside mirrored folders (bisync side never sees `.git` — filters).
- Real files only, never symlink outside `.md` into the vault.
- `--resync`, `pairs.conf` edits, daemon installs = human-approved (Z2 proposals staged here).
