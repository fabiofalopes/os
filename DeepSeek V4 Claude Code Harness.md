# DeepSeek V4 Claude Code Harness

> **Multiple Claude Code harnesses on this RPi (Kali, ARM64).**
> Sits alongside the existing Lusófona setup. Three ways to get DeepSeek V4
> into Claude Code — two are live, one needs a key.
>
> **Status:** `claude-ollama` ✅ LIVE · `claude-opencode` ✅ LIVE · `claude-deepseek` ⏳ needs API key

---

## TL;DR

- **Models:** `deepseek-v4-pro[1m]` (primary) and `deepseek-v4-flash` (subagents)
- **Endpoint:** `https://api.deepseek.com/anthropic` (Anthropic-format, native)
- **Auth:** Bearer token from `~/.config/deepseek/api_key` (0600 perms)
- **Use:** `claude-deepseek` (interactive) or `claude-deepseek "prompt"` (one-shot)
- **Lusófona setup untouched** — bare `claude` still routes to Ulusofona

---

## How it works

Claude Code (v2.1.75, npm global at `~/.local/bin/claude`) reads its provider config from env vars. **Shell env beats settings files** in precedence, so a wrapper script that exports `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` + `ANTHROPIC_MODEL` and then `exec`s the same `claude` binary is the cleanest way to run a second provider alongside the existing one. No global config is mutated; the Lusófona setup in `~/.claude/settings.json` continues to work when you call bare `claude`.

DeepSeek natively exposes an Anthropic-format API at `/anthropic` (accepts the same `x-api-key` header, `POST /v1/messages` shape, `anthropic-version` header). It also maps incoming Anthropic model aliases — `claude-opus*` → Pro, `claude-sonnet*`/`claude-haiku*` → Flash — so Claude Code's internal Opus/Sonnet/Haiku references all resolve.

---

## Files created

| Path | Purpose | Perms |
|---|---|---|
| `~/bin/claude-deepseek` | Wrapper: Pro primary, Flash subagents | 0755 |
| `~/bin/claude-deepseek-flash` | Wrapper: Flash primary, Pro subagents (cheaper) | 0755 |
| `~/.config/deepseek/api_key` | DeepSeek API key (placeholder currently) | 0600 |
| `~/.config/deepseek/` | Config dir | 0700 |

### `~/bin/claude-deepseek` (excerpt)

```bash
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"          # read from api_key file
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export API_TIMEOUT_MS="3000000"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
export CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK="1"     # see Caveats
export CLAUDE_CODE_EFFORT_LEVEL="max"
exec claude "$@"
```

The `claude-deepseek-flash` variant is identical except it flips primary/subagent to Flash/Pro.

---

## Model line — V4 (April 2026)

DeepSeek V4 was released **April 24, 2026** as a preview. Both V4 models are Mixture-of-Experts (MoE) with 1M context / 384K max output.

| Model | Total params | Active params | Input ($/1M) | Output ($/1M) | Cache hit ($/1M) | Tier |
|---|---|---|---|---|---|---|
| `deepseek-v4-pro` | 1.6T | 49B | $0.435 | $0.87 | $0.003625 (120× off) | Frontier |
| `deepseek-v4-flash` | 284B | 13B | $0.14 | $0.28 | $0.0028 (50× off) | Default |

**Concurrency limits:** Pro 500 RPS · Flash 2,500 RPS.

### Legacy aliases (retire 2026-07-24 15:59 UTC)

| Legacy name | Routes to |
|---|---|
| `deepseek-chat` | `deepseek-v4-flash` (non-thinking) |
| `deepseek-reasoner` | `deepseek-v4-flash` (thinking) |

Both legacy aliases route to **Flash**, not Pro. If you were using `deepseek-reasoner` and assumed it was the premium tier, it wasn't.

---

## Pricing comparison vs. Lusófona

| Tier | Lusófona `harmonic-hermes-9b` | DeepSeek V4 Pro | DeepSeek V4 Flash |
|---|---|---|---|
| Input $/1M | (custom pricing, see Lusófona dashboard) | $0.435 | $0.14 |
| Output $/1M | — | $0.87 | $0.28 |
| Cache hit | — | $0.003625 | $0.0028 |
| Context | (provider-defined) | 1M | 1M |
| Max output | — | 384K | 384K |

DeepSeek pricing is public and per-token; Lusófona's `harmonic-hermes-9b` is custom-proxied through `https://modelos.ai.ulusofona.pt` and bills via your Lusófona dashboard.

---

## Usage

```bash
# Set the key first (only once)
$EDITOR ~/.config/deepseek/api_key
# Replace PASTE_YOUR_DEEPSEEK_API_KEY_HERE with your sk-... string
chmod 600 ~/.config/deepseek/api_key

# Interactive session with V4 Pro
claude-deepseek

# One-shot
claude-deepseek "refactor this script to use async"

# Override the model for one session
claude-deepseek --model deepseek-v4-flash

# Cheap mode — Flash primary, Pro only for subagents
claude-deepseek-flash "summarize /var/log/syslog"

# Bare `claude` still uses Lusófona
claude "quick question"
```

### Per-project override (optional)

If you want a specific project to always use DeepSeek, drop a `.claude/settings.local.json` in the project root:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-...",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]"
  },
  "model": "deepseek-v4-pro[1m]"
}
```

But the wrapper approach is simpler — just `cd ~/project && claude-deepseek`.

---

## Verification (already done)

| Check | Result |
|---|---|
| Bash syntax (`bash -n`) | ✅ Both wrappers parse |
| `claude` binary on PATH | ✅ `~/.local/bin/claude` v2.1.75 |
| Endpoint reachability | ✅ `https://api.deepseek.com/anthropic/v1/messages` → HTTP 401 (unauth, as expected without key) |
| Placeholder guard | ✅ Wrapper exits 2 with clear error when key is the placeholder |
| Env var plumbing | ✅ Stderr banner prints `ANTHROPIC_BASE_URL=… model=…` on every launch |

The 401 is correct — DeepSeek's `/anthropic` route exists, the network path works, we just don't have a valid key yet.

---

## Caveats (DeepSeek V4 + Claude Code)

1. **`redacted_thinking` blocks fail on round-trip.** Claude Code faithfully replays all thinking blocks from prior turns. DeepSeek's `/anthropic` endpoint understands `thinking` blocks but **not** `redacted_thinking`, and returns HTTP 400 mid-conversation. **Mitigation:** `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK=1` (set in both wrappers).

2. **`tool_choice="required"` fails on the OpenAI endpoint** (HTTP 400). We don't hit this — Claude Code uses the `/anthropic` endpoint which accepts `{"type":"any"}` correctly.

3. **Image/document content not supported** on DeepSeek's `/anthropic` endpoint. Claude Code features that paste images or PDFs will silently lose that content.

4. **Anthropic-format fields DeepSeek ignores:** `anthropic-beta`, `container`, `mcp_servers`, `service_tier`, `top_k`, `metadata` (except `user_id`), `cache_control` on tools/messages, `thinking.budget_tokens`, `is_error` on tool results. None of these are required for Claude Code to work.

5. **In thinking mode** (default for V4), `temperature`, `top_p`, `presence_penalty`, `frequency_penalty` are silently ignored. We don't set these, so no impact.

6. **Pricing is post-promo** — Pro was 75% off through May 31, 2026. The numbers above are the regular rates.

---

## Getting the API key

1. Go to **https://platform.deepseek.com** (separate from chat.deepseek.com)
2. Sign up — email + verification, no credit card required initially
3. **API Keys** (left sidebar) → **Create new API key**
4. Copy the `sk-...` string immediately (shown only once)
5. Top up **Billing** before first production call
6. New accounts get **5M free tokens** with no credit card

Then paste the key into `~/.config/deepseek/api_key`, replacing the placeholder.

---

## Backup notes

The new harness has three new files to back up:

```bash
# Critical (contains the API key)
~/.config/deepseek/api_key           # ← SECRET, handle carefully

# Mechanical (re-creatable from this note)
~/bin/claude-deepseek
~/bin/claude-deepseek-flash
```

The key file is `0600`, owned by `ken:ken`. When backing up, treat it the same as `~/.claude/settings.json` — encrypt the archive, or strip the key from the backup and re-enter on restore.

---

## Related

- [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]] — the existing Lusófona setup
- [[Next Session Pickup — Pre-Reboot 2026-06-26]] — pre-reboot handoff
- [[RPi-Net Session Log]] — networking work
- `oh-my-opencode-slim.RUNBOOK.md` — the slim/OMO config runbook (separate from Claude Code)

---

*Built 2026-06-30. DeepSeek V4 (preview) / Claude Code 2.1.75 / no proxy required.*
*Endpoint: `https://api.deepseek.com/anthropic`. Wrapper pattern preserves the Lusófona global config intact.*
