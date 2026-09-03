# Commands & Skills — Complete Reference

> All slash commands in Claude Code v2.1.88: public, hidden (feature-gated), and internal (ant-only).

---

## 1. Command Architecture

### 1.1 Command Types

```typescript
type Command = {
  type: 'prompt' | 'local'           // Prompt = inject into conversation, Local = execute directly
  name: string                         // Slash command name
  description: string                  // Help text
  aliases?: string[]                   // Alternative names
  availability?: ('claude-ai' | 'console')[]  // Auth requirements
  isEnabled?(): boolean                // Feature gate
  source: 'builtin' | 'skill' | 'plugin' | 'workflow'
}
```

### 1.2 Command Loading Pipeline

```
getCommands(cwd)
├── loadAllCommands(cwd) [memoized]
│   ├── getSkills(cwd)
│   │   ├── getSkillDirCommands() — .claude/skills/ directory
│   │   ├── getPluginSkills() — Plugin-provided skills
│   │   ├── getBundledSkills() — Built-in skills (sync)
│   │   └── getBuiltinPluginSkillCommands() — Built-in plugin skills
│   ├── getPluginCommands() — Plugin commands
│   ├── getWorkflowCommands() — Workflow scripts
│   └── COMMANDS() — Hard-coded command list
├── getDynamicSkills() — Skills discovered during file operations
├── Filter by meetsAvailabilityRequirement()
├── Filter by isCommandEnabled()
└── Dedup dynamic skills
```

---

## 2. Public Commands (External Builds)

### 2.1 Session Management

| Command | Description | Type |
|---------|-------------|------|
| `/clear` | Clear conversation history | local |
| `/compact` | Compact conversation context | prompt |
| `/resume` | Resume a previous session | local |
| `/session` | Manage sessions | local |
| `/rename` | Rename current session | local |
| `/rewind` | Restore files to previous state | local |
| `/exit` | Exit Claude Code | local |
| `/tag` | Tag the current session | local |

### 2.2 File & Context

| Command | Description | Type |
|---------|-------------|------|
| `/add-dir` | Add directory to tool access | local |
| `/context` | Show current context files | local |
| `/diff` | Show recent file changes | local |
| `/files` | Manage file resources | local |
| `/copy` | Copy to clipboard | local |

### 2.3 Configuration

| Command | Description | Type |
|---------|-------------|------|
| `/config` | Manage settings | local |
| `/model` | Change model | local |
| `/effort` | Set effort level | local |
| `/fast` | Toggle fast mode | local |
| `/plan` | Enter plan mode | local |
| `/permissions` | Manage tool permissions | local |
| `/privacy-settings` | Privacy settings | local |
| `/hooks` | Manage hooks | local |
| `/env` | View environment variables | local |
| `/output-style` | Set output style | local |
| `/sandbox-toggle` | Toggle sandbox | local |
| `/theme` | Change color theme | local |
| `/color` | Toggle color output | local |
| `/keybindings` | Configure keybindings | local |
| `/terminalSetup` | Terminal setup wizard | local |
| `/vim` | Toggle vim keybindings | local |

### 2.4 Auth & Account

| Command | Description | Type |
|---------|-------------|------|
| `/login` | Authenticate | local |
| `/logout` | Sign out | local |
| `/cost` | Show session cost | local |
| `/usage` | Show token usage | local |
| `/status` | Show current status | local |
| `/stats` | Show usage statistics | local |
| `/passes` | Manage passes | local |
| `/upgrade` | Upgrade Claude Code | local |

### 2.5 Development

| Command | Description | Type |
|---------|-------------|------|
| `/commit` | Create git commit | prompt |
| `/review` | Review code changes | prompt |
| `/security-review` | Security-focused review | prompt |
| `/init` | Initialize project | prompt |
| `/doctor` | Diagnose issues | local |
| `/branch` | Git branch operations | local |
| `/pr-comments` | View PR comments | local |
| `/advisor` | Model advisor settings | local |

### 2.6 Skills & Plugins

| Command | Description | Type |
|---------|-------------|------|
| `/skills` | List/manage skills | local |
| `/agents` | Manage custom agents | local |
| `/plugin` | Manage plugins | local |
| `/reload-plugins` | Reload plugin cache | local |
| `/mcp` | Manage MCP servers | local |
| `/memory` | Manage memory files | local |
| `/tasks` | Manage tasks | local |

### 2.7 IDE & Integration

| Command | Description | Type |
|---------|-------------|------|
| `/ide` | IDE integration | local |
| `/desktop` | Desktop integration | local |
| `/mobile` | Mobile integration | local |
| `/chrome` | Chrome integration | local |
| `/install-github-app` | Install GitHub app | local |
| `/install-slack-app` | Install Slack app | local |

### 2.8 Misc Public

| Command | Description | Type |
|---------|-------------|------|
| `/help` | Show help | local |
| `/feedback` | Send feedback | local |
| `/version` | Show version | local |
| `/export` | Export session data | local |
| `/insights` | Generate usage report | prompt |
| `/btw` | Fun responses | prompt |
| `/stickers` | Fun stickers | local |
| `/good-claude` | Encouragement | prompt |
| `/summary` | Summarize conversation | prompt |
| `/thinkback` | Review thinking blocks | local |
| `/thinkback-play` | Replay thinking | local |
| `/statusline` | Statusline config | local |
| `/release-notes` | Show release notes | local |
| `/share` | Share session | local |

---

## 3. Hidden Commands (Feature-Gated)

| Command | Feature Gate | Description |
|---------|-------------|-------------|
| `/proactive` | `PROACTIVE` or `KAIROS` | Toggle proactive mode |
| `/brief` | `KAIROS` or `KAIROS_BRIEF` | Send brief to user |
| `/assistant` | `KAIROS` | Assistant mode commands |
| `/bridge` | `BRIDGE_MODE` | Bridge mode control |
| `/remote-control-server` | `DAEMON` + `BRIDGE_MODE` | Remote control server |
| `/voice` | `VOICE_MODE` | Voice mode control |
| `/force-snip` | `HISTORY_SNIP` | Force context snip |
| `/workflows` | `WORKFLOW_SCRIPTS` | Workflow management |
| `/remote-setup` | `CCR_REMOTE_SETUP` | Remote setup wizard |
| `/subscribe-pr` | `KAIROS_GITHUB_WEBHOOKS` | Subscribe to PR events |
| `/ultraplan` | `ULTRAPLAN` | Advanced planning |
| `/torch` | `TORCH` | Unknown (feature gate) |
| `/peers` | `UDS_INBOX` | List connected peers |
| `/fork` | `FORK_SUBAGENT` | Fork subagent |
| `/buddy` | `BUDDY` | Buddy/companion system |

---

## 4. Internal Commands (Ant-Only)

These commands are eliminated from external builds via dead code elimination:

| Command | Description |
|---------|-------------|
| `/backfill-sessions` | Backfill session metadata |
| `/break-cache` | Break prompt cache for testing |
| `/bughunter` | Bug hunting mode |
| `/commit` (ant version) | Enhanced commit with internal tools |
| `/commit-push-pr` | Commit, push, create PR |
| `/ctx-viz` | Context visualization |
| `/good-claude` | Internal encouragement |
| `/issue` | Create internal issue |
| `/init-verifiers` | Initialize verifier systems |
| `/force-snip` | Force context snip |
| `/mock-limits` | Mock API rate limits |
| `/bridge-kick` | Kick bridge connections |
| `/ultraplan` | Advanced planning |
| `/subscribe-pr` | Subscribe to PR webhooks |
| `/reset-limits` | Reset rate limits |
| `/onboarding` | Internal onboarding |
| `/share` | Internal sharing |
| `/summary` | Internal summary |
| `/teleport` | Teleport to remote |
| `/ant-trace` | Trace analysis |
| `/perf-issue` | Performance issue reporting |
| `/agents-platform` | Platform-specific agents |
| `/autofix-pr` | Auto-fix PR issues |
| `/debug-tool-call` | Debug tool call |
| `/oauth-refresh` | Refresh OAuth tokens |
| `/heapdump` | Take heap dump |

---

## 5. Command Sources

### 5.1 Skills Directory

`.claude/skills/` contains user-defined skills:
```
.claude/skills/
├── commit/
│   └── SKILL.md
├── review/
│   └── SKILL.md
└── custom-skill/
    └── SKILL.md
```

### 5.2 Bundled Skills

Built-in skills registered at startup (`initBundledSkills()`):
- `/commit` — Git commit with conventions
- `/commit-push-pr` — Commit + push + PR
- `/review` — Code review
- `/security-review` — Security review

### 5.3 Plugin Skills

Plugins can contribute commands via `getPluginCommands()` and `getPluginSkills()`.

### 5.4 Workflow Commands

Feature gate `WORKFLOW_SCRIPTS` enables script-based workflows as commands.

---

## 6. Command Execution

### 6.1 Prompt Commands

Prompt commands inject text into the conversation:
```
/commit → injects commit prompt → model generates commit message → tool executes
```

### 6.2 Local Commands

Local commands execute immediately without model interaction:
```
/clear → clears message array → no API call
/model → updates model setting → no API call
```

### 6.3 Availability Filtering

Commands declare auth requirements:
```typescript
availability: ['claude-ai']  // Only for claude.ai subscribers
availability: ['console']     // Only for 1P API key users
```

Non-matching commands are hidden from the command list.
