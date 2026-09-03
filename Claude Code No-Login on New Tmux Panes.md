---
tags:
  - claude-code
  - tmux
  - troubleshooting
  - teamwork
date: 2026-07-22
---

# Claude Code No-Login on New Tmux Panes

> **⚑ 2026-08-05 update:** the `claude-alibaba-*` launchers below were removed in the upb consolidation. The current equivalent launch is `upb run alibaba/qwen3.8-max-preview` (or `upb run default`) — see [[Claude Code Routes — upb CLI Decision & Runbook]]. The failure mode itself is unchanged (fresh pane has no `ANTHROPIC_*` in its env); `upb` is now the wrapper that provides them.

## Symptom
A fresh `claude` session (new tmux pane/window) answers the first prompt with:

> ⎿  Not logged in · Please run /login
> ✻ Crunched for 0s

Status line shows `Not logged in · Run /login`. No API call is made; the session looks up but is dead.

## Root cause
Auth on this machine is **wrapper-provided, not account-based**: there is no `~/.claude/.credentials.json`. The endpoint (Alibaba token plan, qwen3.8-max-preview via the Universal Provider Bridge proxy on :8705, key read from `~/.local/share/opencode/auth.json`) is configured by the launcher wrapper. Plain `claude` gets none of that → every request is refused.

Sessions that *were* started with the wrapper keep working, which is why the failure looks intermittent ("sometimes no login").

## The command (always)

```bash
claude-alibaba-qwen38m --effort low --allow-dangerously-skip-permissions --dangerously-skip-permissions
```

The two permission flags are **not redundant**: `--allow-dangerously-skip-permissions` only *enables* bypass (makes shift+tab cycling available — this is why some sessions show "bypass permissions on" only after a manual toggle); `--dangerously-skip-permissions` *activates* bypass at launch. With only the first flag, autonomous agents stall at the first permission dialog ("Yes, allow reading from … / No · Esc to cancel") — the second failure mode observed in the same incident.

**Rescue without restart** (session stuck at a permission dialog): send shift+tab (tmux `BTab`) until the footer shows `⏵⏵ bypass permissions on`, then continue.

## Detection
- `tr '\0' '\n' < /proc/<claude-pid>/environ | grep ANTHROPIC` → empty = affected
- teamwork registry: session binds, then goes idle instantly after a prompt; capture-pane shows the `/login` line

## Rescue a running pane

```
/exit            # quit the dead claude
claude-alibaba-qwen38m --effort low --allow-dangerously-skip-permissions
# then re-send the prompt (a new session is created; teamwork rebinds automatically)
```

## Automation idea (teamwork v0.2)
Manager detects the `Not logged in · Please run /login` response pattern in the transcript → auto-rescue (exit + relaunch with wrapper + resend) or at least surface it in STATUS.md.

## Related
- [[Claude Code Proxy Pattern — Master Reference]]
- [[Claude Code + OpenCode Setup — Lusófona Endpoint Map]]
- Incident: 2026-07-22 17:37, hive window (0:4) — agents 1–3 stalled at kickoff; fixed by relaunching with the wrapper.
