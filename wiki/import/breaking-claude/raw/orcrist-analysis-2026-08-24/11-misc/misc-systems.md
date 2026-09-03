# Miscellaneous Systems — Buddy, Telemetry, Killswitches

> The Buddy companion system, telemetry architecture, remote control killswitches, undercover mode, and other miscellaneous systems in Claude Code v2.1.88.

---

## 1. Buddy Companion System (BUDDY feature gate)

### 1.1 Overview

The Buddy system is an internal companion/pet system for Anthropic employees. Feature-gated behind `BUDDY`.

### 1.2 Types (`buddy/types.ts`, 148 lines)

```typescript
// Species types for buddy companions
type Species = string

// Stats for buddy state
type Stats = {
  happiness: number
  experience: number
  level: number
}

// Soul types for buddy personality
type Soul = {
  name: string
  traits: string[]
}
```

### 1.3 Buddy Prompt (`buddy/prompt.ts`, 36 lines)

The buddy system injects companion-related instructions into the conversation. This is a lightweight personality layer that sits on top of the normal Claude Code behavior.

---

## 2. Telemetry System

### 2.1 Event Logging Architecture

All telemetry flows through a sink-based system:

```
logEvent('event_name', { metadata })
  → Event queue
    → Sink attached (initSinks())
      → Statsig analytics
        → Internal logging (ant-only)
```

### 2.2 Key Telemetry Events

| Event | Purpose |
|-------|---------|
| `tengu_startup_telemetry` | Session startup (git status, sandbox, platform) |
| `tengu_query_error` | Query loop errors |
| `tengu_auto_compact_succeeded` | Autocompact success metrics |
| `tengu_model_fallback_triggered` | Model fallback events |
| `tengu_auto_dream_fired` | Auto-dream triggering |
| `tengu_auto_dream_completed` | Auto-dream completion |
| `tengu_memdir_loaded` | Memory directory stats |
| `tengu_streaming_tool_execution_used` | Streaming tool usage |
| `tengu_token_budget_completed` | Token budget events |
| `tengu_orphaned_messages_tombstoned` | Fallback cleanup |
| `tengu_coordinator_mode_switched` | Mode switching |
| `tengu_managed_settings_loaded` | Enterprise settings |
| `tengu_code_prompt_ignored` | Single-word 'code' prompt |
| `tengu_claude_in_chrome_setup` | Chrome MCP setup |
| `tengu_structured_output_enabled` | JSON schema output |
| `tengu_mcp_channel_flags` | MCP channel usage |

### 2.3 Analytics Metadata

All metadata is typed as `AnalyticsMetadata_I_VERIFIED_THIS_IS_NOT_CODE_OR_FILEPATHS` — a nominal type that ensures no code or file paths leak into analytics.

### 2.4 Privacy Controls

- `isAnalyticsDisabled()` — User can disable analytics
- `CLAUDE_CODE_DISABLE_ANALYTICS` — Environment variable override
- PII is stripped from all events before logging

---

## 3. Undercover Mode

### 3.1 Overview

Undercover mode prevents Claude Code from revealing its identity when making commits, PRs, or other public-facing outputs.

```typescript
isUndercover() → boolean
getUndercoverInstructions() → string
```

### 3.2 Instructions

When undercover mode is active:
- Don't use internal codenames in commit messages
- Don't attribute changes to "Claude" or "Anthropic"
- Hide model ID information
- Strip attribution text from git operations

---

## 4. Remote Control Killswitches

### 4.1 Bypass Permissions Killswitch

Enterprise admins can remotely disable `bypassPermissions` mode:

```typescript
checkAndDisableBypassPermissions()
  → loadPolicyLimits()
  → If killswitch active: force downgrade to default mode
```

### 4.2 Remote Managed Settings

Enterprise settings are loaded remotely:
```
loadRemoteManagedSettings() → non-blocking, fail-open
refreshRemoteManagedSettings() → hot reload on change
```

### 4.3 Policy Limits

Enterprise policy limits control:
- `allowedMcpServers` / `deniedMcpServers`
- `bypassPermissions` killswitch
- Model restrictions
- Feature availability

```
loadPolicyLimits() → non-blocking
waitForPolicyLimitsToLoad() → blocking (max 5s)
isPolicyAllowed() → check specific policy
```

---

## 5. Startup Profiler

### 5.1 Architecture

```typescript
profileCheckpoint('name') // Mark timestamp
profileReport()           // Generate report
```

Key checkpoints:
```
main_tsx_entry
main_tsx_imports_loaded
main_warning_handler_initialized
main_client_type_determined
main_before_run
run_function_start
run_commander_initialized
preAction_start
preAction_after_init
action_handler_start
action_tools_loaded
action_before_setup
action_after_setup
```

### 5.2 Headless Profiler

```typescript
headlessProfilerCheckpoint('query_started')
```

Tracks latency for non-interactive sessions.

---

## 6. Session Start Hooks

### 6.1 Hook Types

```typescript
processSetupHooks()        // Setup trigger (init/maintenance)
processSessionStartHooks() // SessionStart:startup trigger
```

### 6.2 Hook Lifecycle

```
Session start →
  ├── Setup hooks (init trigger) -- if --init flag
  ├── SessionStart:startup hooks
  └── Continue to REPL
```

### 6.3 Post-Sampling Hooks

```typescript
executePostSamplingHooks(messages, systemPrompt, ...)
```

Run after every model response — used for auto-memory extraction, auto-dream, and other post-processing.

---

## 7. Graceful Shutdown

### 7.1 Shutdown Flow

```typescript
gracefulShutdown(exitCode)
  ├── Stop all running tools
  ├── Flush pending messages
  ├── Close MCP connections
  ├── Save session transcript
  ├── Reset terminal state
  └── process.exit(exitCode)

gracefulShutdownSync(exitCode)
  // Synchronous version for emergency shutdown
```

### 7.2 Cleanup Registry

```typescript
registerCleanup(() => { /* cleanup callback */ })
```

All subsystems register cleanup callbacks for orderly shutdown.

---

## 8. Sandbox System

### 8.1 Sandbox Types

| Type | Implementation | Isolation Level |
|------|---------------|-----------------|
| Docker | Container runtime | Full filesystem isolation |
| gVisor | Kernel-level sandboxing | syscall filtering |
| None | Direct execution | No isolation |

### 8.2 Configuration

```typescript
SandboxManager.isSandboxingEnabled()
SandboxManager.areUnsandboxedCommandsAllowed()
SandboxManager.isAutoAllowBashIfSandboxedEnabled()
```

---

## 9. Concurrent Sessions

```typescript
countConcurrentSessions()
registerSession(name)
updateSessionName(sessionId, name)
```

Claude Code tracks concurrent sessions across the process to prevent resource conflicts.

---

## 10. Debug Mode

```typescript
isDebugMode() → boolean
logForDebugging(message, { level })
```

Debug mode is enabled via `-d` / `--debug` flags:
- `--debug` — Enable with optional category filter
- `--debug-to-stderr` — Route debug output to stderr
- `--debug-file <path>` — Write debug logs to file

Category filters: `"api,hooks"` or `"!1p,!file"` (exclude patterns)
