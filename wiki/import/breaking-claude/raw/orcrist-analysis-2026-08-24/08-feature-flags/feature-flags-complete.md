# Feature Flags — Complete Reference

> Compile-time `feature()` flags, runtime `tengu_*` GrowthBook gates, and dead code elimination patterns in Claude Code v2.1.88.

---

## 1. Two-Tier Feature Flag System

### 1.1 Compile-Time Flags (`feature()` from `bun:bundle`)

These flags are resolved at **build time** via `bun:bundle`. The bundler eliminates dead branches in external builds:

```typescript
// In 'ant' builds: feature('KAIROS') → true, module is imported
// In 'external' builds: feature('KAIROS') → false, module is eliminated
if (feature('KAIROS')) {
  const module = require('./assistant/index.js')
}
```

### 1.2 Runtime Flags (GrowthBook `tengu_*` gates)

These flags are fetched from **Statsig GrowthBook** at runtime:

```typescript
getFeatureValue_CACHED_MAY_BE_STALE('tengu_auto_mode', false)
checkStatsigFeatureGate_CACHED_MAY_BE_STALE('tengu_scratch')
```

These can change mid-session and are re-evaluated per-turn.

---

## 2. Compile-Time Feature Flags

### 2.1 Major Feature Flags

| Flag | Purpose | External Build |
|------|---------|---------------|
| `KAIROS` | Assistant/daemon mode | Eliminated |
| `COORDINATOR_MODE` | Multi-worker coordinator | Eliminated |
| `TRANSCRIPT_CLASSIFIER` | Auto-mode YOLO classifier | Present |
| `CONTEXT_COLLAPSE` | Progressive context compression | Present |
| `REACTIVE_COMPACT` | Reactive context compression | Present |
| `HISTORY_SNIP` | Old tool result removal | Present |
| `CACHED_MICROCOMPACT` | Cache-editing compression | Present |
| `PROACTIVE` | Proactive/long-lived agents | Eliminated |
| `AGENT_TRIGGERS` | Cron-based agent triggers | Eliminated |
| `AGENT_TRIGGERS_REMOTE` | HTTP webhook triggers | Eliminated |
| `BG_SESSIONS` | Background session management | Present |
| `MONITOR_TOOL` | Long-running task monitor | Eliminated |
| `WEB_BROWSER_TOOL` | Playwright browser automation | Present |
| `WORKFLOW_SCRIPTS` | Script-based workflows | Eliminated |
| `CHICAGO_MCP` | Computer Use MCP (ant-only) | Eliminated |
| `LODESTONE` | Deep link protocol handler | Eliminated |
| `DIRECT_CONNECT` | cc:// URL connection | Eliminated |
| `SSH_REMOTE` | SSH remote sessions | Eliminated |
| `TEAMMEM` | Team memory sync | Eliminated |
| `BUDDY` | Companion/buddy system | Eliminated |
| `VOICE_MODE` | Voice interaction | Eliminated |
| `BRIDGE_MODE` | Bridge mode control | Eliminated |
| `DAEMON` | Daemon process mode | Eliminated |
| `TOKEN_BUDGET` | Token budget tracking | Present |
| `OVERFLOW_TEST_TOOL` | Context overflow testing | Eliminated |
| `TERMINAL_PANEL` | Terminal capture | Eliminated |
| `UDS_INBOX` | Unix domain socket messaging | Eliminated |
| `FORK_SUBAGENT` | Subagent forking | Eliminated |
| `ULTRAPLAN` | Advanced planning | Eliminated |
| `TORCH` | Unknown internal feature | Eliminated |
| `CCR_REMOTE_SETUP` | Remote setup wizard | Eliminated |
| `EXPERIMENTAL_SKILL_SEARCH` | Skill discovery | Present |
| `TEMPLATES` | Job classification | Eliminated |
| `UPLOAD_USER_SETTINGS` | Settings sync to cloud | Present |
| `KAIROS_CHANNELS` | MCP push notifications | Eliminated |
| `KAIROS_GITHUB_WEBHOOKS` | GitHub webhook subscriptions | Eliminated |
| `KAIROS_BRIEF` | Brief tool for KAIROS | Eliminated |
| `KAIROS_PUSH_NOTIFICATION` | Push notifications | Eliminated |
| `WEB_BROWSER_TOOL` | Browser automation | Present |

### 2.2 Dead Code Elimination Pattern

The standard pattern for feature-gated code:

```typescript
// Lazy require — module not imported if feature is off
const module = feature('FLAG')
  ? require('./module.js') as typeof import('./module.js')
  : null

// Usage with null check
if (feature('FLAG') && module) {
  module.doSomething()
}
```

### 2.3 `process.env.USER_TYPE` Pattern

Ant-only code uses a different DCE mechanism:

```typescript
// Build-time replacement: 'ant' for internal, 'external' for public
if (process.env.USER_TYPE === 'ant') {
  // Internal-only code here — eliminated in external builds
}
```

---

## 3. Runtime GrowthBook Gates (tengu_*)

### 3.1 Auto Mode

| Gate | Purpose |
|------|---------|
| `tengu_auto_mode` | Enable auto permission mode |
| `tengu_auto_mode_config` | Auto-mode rules and settings |
| `tengu_otk_slot_v1` | Output token escalation |

### 3.2 Context & Memory

| Gate | Purpose |
|------|---------|
| `tengu_onyx_plover` | Auto-dream scheduling config (minHours, minSessions) |
| `tengu_moth_copse` | Skip MEMORY.md index |
| `tengu_coral_fern` | Enable past context searching |
| `tengu_herring_clock` | Team memory cohort tracking |
| `tengu_scratch` | Scratchpad directory for coordinator |

### 3.3 Features & Experiments

| Gate | Purpose |
|------|---------|
| `tengu_kairos` | Enable KAIROS assistant mode |
| `tengu_streaming_tool_execution` | Streaming tool execution |
| `tengu_emit_tool_use_summaries` | Haiku-generated tool summaries |

### 3.4 Analytics & Telemetry

| Gate | Purpose |
|------|---------|
| `tengu_managed_settings_loaded` | Track enterprise settings |
| `tengu_memdir_disabled` | Track memory disabled state |
| `tengu_team_memdir_disabled` | Track team memory disabled |

---

## 4. Environment Variable Flags

### 4.1 User-Facing

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_SIMPLE` | Minimal mode (--bare) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable persistent memory |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background Bash |
| `CLAUDE_CODE_COORDINATOR_MODE` | Activate coordinator mode |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock provider |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex provider |
| `CLAUDE_CODE_ENTRYPOINT` | Override entrypoint type |
| `CLAUDE_CODE_REMOTE` | Remote session mode |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | Don't set terminal title |
| `CLAUDE_CODE_EXIT_AFTER_FIRST_RENDER` | Startup benchmark mode |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Override max output tokens |
| `ENABLE_LSP_TOOL` | Enable LSP tool |
| `CLAUDE_CODE_VERIFY_PLAN` | Enable plan verification |
| `NODE_ENV` | Test mode when 'test' |

### 4.2 Internal (Ant-Only)

| Variable | Purpose |
|----------|---------|
| `USER_TYPE` | Build type: 'ant' or 'external' |
| `IS_DEMO` | Demo mode flag |
| `CLAUDE_CODE_AGENT` | Current agent name |
| `CLAUDE_CODE_ACTION` | GitHub Action detection |
| `CLAUDE_CODE_TASK_LIST_ID` | Tasks mode list ID |
| `CLAUDE_CODE_ENVIRONMENT_KIND` | Session source tracking |
| `CLAUDE_CODE_SESSION_ACCESS_TOKEN` | Remote session auth |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | Remote session ID |

---

## 5. Settings Sources

Settings are loaded from multiple sources with priority:

1. **CLI flags** (`--settings`, `--setting-sources`)
2. **Dynamic** (`--mcp-config` runtime configs)
3. **Policy settings** (enterprise MDM/remote managed)
4. **Local settings** (`.claude/settings.local.json`)
5. **Project settings** (`.claude/settings.json`)
6. **User settings** (`~/.claude/settings.json`)
7. **Bundled defaults**

`--setting-sources` controls which sources are active:
```
--setting-sources user,project,local
```

---

## 6. Build Variants

| Build | `USER_TYPE` | Features | Purpose |
|-------|------------|----------|---------|
| **ant** | `'ant'` | All flags available | Internal Anthropic use |
| **external** | `'external'` | Subset of flags | Public npm package |
| **sdk** | varies | Minimal flags | SDK/embedded use |
