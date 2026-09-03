---
id: CTX-me
type: context
---

# Me — environment and preferences

## Machines
- **Kali laptop server** (this machine, `7.0.12+kali-amd64`) — remote-access
  workstation, the permanent home of everything the mission produces.

## Harness & routing
- Claude Code harness run through **upb** (universal provider bridge):
  `~/bin/upb` CLI + `~/.config/upb/routes.yaml` + UPB proxy dist
  (`~/shared-local/reports/claude-universal`, systemd user service
  `universal-router.service` on :8705 — never stop it).
- Providers live: zai (default glm-5.2, anthropic-native), zen (free),
  opencode-go, models-ai, prime-intellect (metered, never default),
  pi-own (ephemeral GPU deploys via gpu-deploy skill).
- GPU doctrine: Q4 quants always; download-first; GPU off when idle.
- Other harnesses on rig: OpenCode, Hermes. Teamwork/swarm tooling available
  (tmux panes, cron engine in the Forge vault).

## Key local assets
- `~/research/claude-code-original` — leaked source tree (2026-03-31).
- `~/obsidian-vault-kali` — the Forge vault (sibling system; human-facing
  research layer, has its own constitution — don't mix ledgers).
- `~/projects/upb` — gateway source.

## Preferences (standing)
- Test, don't wonder. Grade everything. Clean, explicit, simple — no theatrics.
- Persist to vault/repo with IDs; nothing only in scrollback.
- Destructive/irreversible actions get confirmed first.
- Working language English; principal is PT/EN bilingual.

## Missing / to supply (human)
- Anthropic **tester account** credentials — not on disk, needed for any
  authenticated-run hypothesis.
- Standing sandbox desktop environment (currently: on-host + snapshots).
