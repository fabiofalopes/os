# Claude Code + OpenCode Setup — Lusófona Endpoint Map

> **Inventory of the custom AI tooling stack on this RPi (Kali).**
> Two parallel setups share the `modelos.ai.ulusofona.pt` endpoint:
> **Claude Code** (Anthropic's CLI, re-pointed via env vars) and
> **OpenCode** (separate CLI, configured with a custom provider).
> This note is the map you need to back any of it up.

---

## TL;DR

- The "Anthropic Cloud Code" you set up is **Claude Code** with `ANTHROPIC_BASE_URL=https://modelos.ai.ulusofona.pt`.
- The API key `sk-wNLb8wi_dHqmvuX3wm4DJA` is in **plaintext in 4 files** — treat the backup as secret material.
- Sessions live in two places: `~/.claude/projects/<encoded-cwd>/*.jsonl` (Claude Code) and `~/opencode-sessions/ses_*` (OpenCode, already exported as JSON + Markdown).
- The main produced project is **claude-universal** under `~/shared-local/reports/claude-universal/`.
- Two parallel config trees exist: `~/.claude/` (current) and `~/.openclaude/` (legacy). Don't mix them up.

---

## The custom endpoint — the "special setup"

### Active config: `~/.claude/settings.json`

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-wNLb8wi_dHqmvuX3wm4DJA",
    "ANTHROPIC_BASE_URL":   "https://modelos.ai.ulusofona.pt",
    "API_TIMEOUT_MS":       "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "model": "harmonic-hermes-9b",
  "skipDangerousModePermissionPrompt": true,
  "effortLevel": "high"
}
```

| Field | Value |
|---|---|
| Base URL | `https://modelos.ai.ulusofona.pt` |
| Auth token | `sk-wNLb8wi_dHqmvuX3wm4DJA` (⚠️ plaintext) |
| Model | `harmonic-hermes-9b` |
| Effort | `high` |
| Dangerous-mode prompt | skipped |

---

## The three Claude-related configs (don't confuse them)

| Path | Role | Size | Notes |
|---|---|---|---|
| `~/.claude/` + `~/.claude.json` | **Current Claude Code** (since 2026-06-19) | 8.8M | `numStartups: 3`, `userID: e2866752…` |
| `~/.openclaude/` + `~/.openclaude.json` + `~/.openclaude-profile.json` | Legacy Claude Code (2026-04-28 → 2026-06-19) | 13M | `numStartups: 9`, has the old `providerProfiles[]` block with the same key |
| `~/.opencode/` + `~/.opencode/opencode.json` | **OpenCode CLI** (separate tool, also Lusófona) | 552M | Has the `oh-my-opencode-slim` plugin and a custom provider |

### Side-by-side endpoint references

**Claude Code current** — `~/.claude.json` (projects tracked):
- `/home/ken/shared-local` (last cost $1.07, last session `56f65535-…`)
- `/home/ken` (last session `e6e9550d-…`)
- `/` (last session `92f2e1b6-…`)

**Claude Code legacy** — `~/.openclaude.json`:
- Single provider profile `provider_6ca25b514efc` named `modelos.ai-anthropic` (anthropic provider, `harmonic-hermes-9b`, same baseUrl, same key)
- Projects: `/home/ken`, `/home/ken/claude-dashboard`, `/home/ken/rpi-net`
- GitHub repo path tracked: `seunggabi/claude-dashboard`

**OpenCode provider** — `~/.opencode/opencode.json`:
```json
{
  "plugin": ["oh-my-opencode-slim"],
  "agent": { "explore": { "disable": true }, "general": { "disable": true } },
  "lsp": true,
  "provider": {
    "ulusofona": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Lusófona AI",
      "options": { "baseURL": "https://modelos.ai.ulusofona.pt/v1" }
    }
  }
}
```

---

## Sessions & transcripts (the produced content)

### Claude Code sessions — JSONL per project

`~/.claude/projects/`

```
-home-ken/                   ← /home/ken project (older work)
  453bf89a-…jsonl  (2.0K)
  ce37d8f5-…jsonl  (15.8K)
  79397eb3-…/      (directory with session data)
  memory/

-home-ken-camera-server/
-home-ken--claude/            ← sessions that targeted ~/.claude itself
  b38baf77-…/   memory/
-home-ken-claude-dashboard/
-home-ken-m5stack-dial/
-home-ken-shared-local/       ← most recent, 6 sessions on 2026-06-19
  3bec1aa9-…jsonl  (4.1K)
  56f65535-…jsonl  (88.1K)  ← matches lastSessionId in ~/.claude.json
  90ef8660-…jsonl  (20.5K)
  e125199e-…jsonl  (4.5K)
  e1fac21c-…jsonl  (19.7K)
  f7eaeb4d-…jsonl  (2.1K)
  memory/
```

Empty: `~/.claude/sessions/` (no current session files there — sessions are all under `projects/`).

Other transcript sources:
- `~/.claude/history.jsonl` (58,693 bytes — full command/keystroke history)
- `~/.claude/transcripts/`
- `~/.claude/plans/` (empty)
- `~/.claude/tasks/` (2 task directories: `39cc7dd3-…`, `a25a8b85-…`)
- `~/.claude/session-env/`, `~/.claude/shell-snapshots/`

### OpenCode sessions — already exported as JSON + Markdown

`~/opencode-sessions/` (6.1M, 16 files + `convert.py`)

| Session ID | Topic | JSON | MD |
|---|---|---|---|
| `ses_1d3dc0d02ffeADQ5D5GxP1L8oe` | ohmyopenagent zen custom endpoint setup | 933K | 265K |
| `ses_1ae4eced3ffedpwIbvj0UEylSL` | grove hub m5 dial sensor verification | 1.8M | 495K |
| `ses_1c523b2c4ffenvmMc5B9N1X0zN` | grove hub m5 dial sensor verification | 290K | 58K |
| `ses_1a823f65cffeoR09bdd97bfGM4` | tmux agent coordination system | 224K | 56K |
| `ses_2274acccdffemcG09JHrG12296` | m5dial project status and next steps planning | 472K | 123K |
| `ses_2273f50d7ffetHp6NkG4J21kam` | camera server project recap and achievements so far | 163K | 70K |
| `ses_215e5c346ffegWlA1GVD2GLRlH` | streaming camera — to serve or not | 186K | 50K |
| `ses_22a4cd591ffe7DLFdyv9MlpOJe` | raspberry pi 4 kali internet access intermittent explanation | 109K | 31K |
| `ses_1d3b3f9fbffesROpGky2udRkP6` | resuming previous work context | 526K | 153K |
| `ses_1d3ce148effe6GWcWLwkKAVYAP` | ping all agents | 33K | 13K |
| `ses_1a0a4f78dffeNRVvzbibffnTjg` | current — converting sessions to markdown | 69K | 22K |
| `ses_1d3ce5e1cffekpfZ429h7Q3Rea` | new session 20260515t151150756z | 4.1K | 827 |

`convert.py` is the script used to convert JSON sessions to Markdown.

---

## Generated project artifacts (the "what got produced")

### Main project — claude-universal

`~/shared-local/reports/claude-universal/`

```
claude-universal/                       (engagement output)
  README.md          (11.3K)
  QUICKSTART.md      (3.4K)
  TECHNICAL.md       (8.3K)
  NOTES.md           (6.2K)
  architecture-spec-v0.1.md  (9.9K)
  architecture-spec-v0.2.md  (18.7K)
  package.json       (737)
  tsconfig.json      (450)
  package-lock.json  (16.4K)
  claude-universal   (4.5K binary)
  src/   (6 subdirs of source)
  dist/
  node_modules/
```

### Other deliverables

| Path | What |
|---|---|
| `~/shared-local/hub/AGENTS.md` | Agent instructions (entry point for OpenCode/Claude in the Diane framework) |
| `~/shared-local/hub/skill-architecture.md` | 13.7K — design of the skill system |
| `~/shared-local/hub/curated/` | Curated skill notes |
| `~/shared-local/hub/notes/` | Misc notes |
| `~/shared-local/reports/wireless-infra-001/` | Wireless pentest engagement report |
| `~/shared-local/scripts/` | Operational scripts |
| `~/shared-local/skills/` | Skill index (9,455 indexed per the Diane AGENTS.md) |
| `~/oh-my-opencode-slim.RUNBOOK.md` | 5.1K — config incident runbook (2026-06-17 fallout) |
| `~/.slim/deepwork/claude-universal.md` | 4.6K — deepwork trace for the project |
| `~/.opencode/node_modules/oh-my-opencode-slim/` | Plugin source on disk |
| `~/.cache/opencode/models.json` | Cached model list (used by runbook) |

### Project workspaces Claude worked on

- `~/camera-server/` — IMX219 + unicam, streaming research
- `~/m5stack-dial/` — M5Stack dial sensor work
- `~/claude-dashboard/` — Go-based dashboard (seunggabi origin)
- `~/rpi-net/` — Network reliability + watchdog work
- `~/diane-agent-kit/` — Pentest framework kit (80M zip + source)

---

## Slim / OMO orchestrator state

| Path | What | Size |
|---|---|---|
| `~/.config/opencode/oh-my-opencode-slim.jsonc` | **Live slim config** (z.ai-only models) | — |
| `~/.local/share/opencode/auth.json` | Auth storage (z.ai `Z.AI Coding Plan`) | — |
| `~/.cache/opencode/...@latest` | Live plugin cache | — |
| `~/.bun/install/cache/...@2.0.3` | Bun cache for plugin v2.0.3 | — |
| `~/.bun/install/cache/...@1.1.1` | Bun cache for plugin v1.1.1 (still has legacy `chains` key — do NOT use) | — |
| `~/.slim/` | Slim state | 16K |
| `~/.omo/run-continuation/` | OMO state | 12K |

### Auth backup

`~/.local/share/opencode/auth.json.bak` — old `opencode-go` (OpenCode Zen) provider was removed; **do not re-enable** without adding `OPENCODE_API_KEY` to auth.json (see runbook).

### z.ai models in use (per runbook 2026-06-17)

| Role | Primary | Fallback |
|---|---|---|
| orchestrator | `glm-5.2` | `glm-5-turbo` |
| oracle | `glm-5.2` | `glm-5.1` |
| librarian | `glm-5-turbo` | `glm-4.5-air` |
| explorer | `glm-5-turbo` | `glm-4.5-air` |
| designer | `glm-5.2` | `glm-5-turbo` |
| fixer | `glm-5-turbo` | `glm-4.5-air` |
| redteam | `glm-5.2` | `glm-5-turbo` |

The `fallback` block in the slim config must **NOT** contain a `chains` key — that was removed in v2.0.3 (commit `e7762e3`); legacy configs are rejected wholesale and silently default to GPT.

---

## Backup manifest (priority order)

### 🔴 Critical — cannot recreate, contains secrets

1. `~/.claude/settings.json` — API token
2. `~/.claude.json` — token + per-project state
3. `~/.openclaude.json` — token + provider profile
4. `~/.openclaude-profile.json` — token
5. `~/.config/opencode/oh-my-opencode-slim.jsonc` — slim config
6. `~/.opencode/opencode.json` — Lusófona provider
7. `~/.local/share/opencode/auth.json` — z.ai key

### 🟡 Produced content — recoverable but large

8. `~/.claude/` (8.8M — sessions, projects, history, memory, plugins)
9. `~/opencode-sessions/` (6.1M — exported sessions as JSON + MD)
10. `~/shared-local/` (hub, reports, scripts, skills — the Diane framework)
11. `~/oh-my-opencode-slim.RUNBOOK.md`
12. `~/.slim/deepwork/claude-universal.md`

### 🟢 Optional — regeneratable

13. `~/.opencode/` (552M — `node_modules` can be reinstalled)
14. `~/.opencode/opencode.json.bak.1779897917` (just a 421B backup of the JSON)
15. `~/claude-dashboard/`, `~/camera-server/`, `~/m5stack-dial/`, `~/rpi-net/` (project workspaces, also in their own git remotes if any)

### ⚠️ Security note before backing up

The API token `sk-wNLb8wi_dHqmvuX3wm4DJA` is stored in plaintext in **at least 4 files**. If the backup destination isn't encrypted:

- Rotate the key at `https://modelos.ai.ulusofona.pt` after restoring, **or**
- Strip the key from the archive (run a scrub over the `ANTHROPIC_AUTH_TOKEN`, `apiKey`, `OPENAI_API_KEY` fields) and re-add it on the new host.

### Suggested tar command (keeps perms, compresses)

```bash
cd /home/ken
tar --zstd -cvf /tmp/claude-opencode-backup-$(date +%Y%m%d).tar.zst \
  .claude .claude.json \
  .openclaude .openclaude.json .openclaude-profile.json \
  .config/opencode .local/share/opencode \
  .slim .omo \
  opencode-sessions \
  shared-local \
  oh-my-opencode-slim.RUNBOOK.md \
  2>&1 | tee /tmp/backup-$(date +%Y%m%d).log
```

Expected size before node_modules: ~30M compressed.
Skip `.opencode/node_modules` to keep the archive sane; reinstall with `bun install` from the saved `package.json` + `bun.lock` if needed.

---

## How to verify after restoring

```bash
# 1. Confirm endpoint is wired
grep -E "ANTHROPIC_BASE_URL|baseURL" ~/.claude/settings.json ~/.opencode/opencode.json

# 2. Confirm slim config validates against live schema
python3 - <<'PY'
import json, jsonschema, urllib.request
cfg = json.loads(open("/home/ken/.config/opencode/oh-my-opencode-slim.jsonc").read())
schema = json.load(urllib.request.urlopen("https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json", timeout=20))
jsonschema.validate(cfg, schema)
print("VALID")
PY

# 3. Confirm sessions are readable
ls ~/.claude/projects/-home-ken-shared-local/*.jsonl
ls ~/opencode-sessions/ses_*.md | head

# 4. Spot-check the most recent session
head -1 ~/.claude/projects/-home-ken-shared-local/56f65535-*.jsonl | python3 -m json.tool
```

---

## Cross-references

- `oh-my-opencode-slim.RUNBOOK.md` — config incident writeup (2026-06-17)
- `RPi-Net Session Log.md` — networking work that used these sessions
- `RPi Reliability — Zombie State Prevention.md` — watchdog work
- `Wireless Pentesting Infrastructure — Kali RPi.md` — wireless-infra-001 engagement
- `Bolt Security Research — MITM Attack Capability.md` — Bolt research notes
- `Next Session Pickup — Pre-Reboot 2026-06-26.md` — pre-reboot handoff
- `Agent Loop Skill — Iterate-Until Pattern.md` — agent loop pattern

---

*Generated 2026-06-30. Inventory taken on a live RPi (Kali, ARM64).*
*Three configs (current Claude Code, legacy Claude Code, OpenCode) all reference the same `modelos.ai.ulusofona.pt` endpoint with the same API key — keep them in sync when rotating.*
