# Hook System Architecture

> Source: `src/utils/hooks.ts` (5,022 lines), `src/types/hooks.ts` (290 lines), `src/services/tools/toolHooks.ts`, `src/utils/hooks/` directory

## Overview

Hooks are user-defined shell commands, callbacks, HTTP endpoints, or agent-based handlers that execute at defined lifecycle points in Claude Code's operation. The hook system is the primary extensibility mechanism — it allows users to inject custom logic before/after tool use, on session lifecycle events, on permission decisions, and more.

The system supports **25+ event types**, **4 execution modes** (shell, callback, HTTP, agent), **async hooks** that run in the background, and a **Zod-validated JSON protocol** for structured hook output.

## Hook Event Types (Complete Taxonomy)

Defined in `src/entrypoints/agentSdkTypes.ts`, imported via `src/types/hooks.ts`:

### Tool Lifecycle Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `PreToolUse` | Before a tool executes | `tool_name`, `tool_input`, `session_id`, `transcript_path` |
| `PostToolUse` | After successful tool execution | `tool_name`, `tool_input`, `tool_output`, `session_id` |
| `PostToolUseFailure` | After tool execution failure | `tool_name`, `tool_input`, `error`, `session_id` |

### Session Lifecycle Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `SessionStart` | Session initialization | `session_id`, `transcript_path`, `cwd` |
| `SessionEnd` | Session termination | `session_id`, `exit_reason`, `session_duration` |
| `Setup` | One-time setup on first run | `session_id`, `transcript_path` |

### Prompt & User Interaction Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `UserPromptSubmit` | User submits a prompt | `prompt`, `session_id`, `cwd` |
| `Elicitation` | Model asks user a question | `elicitation_id`, `message`, `options` |
| `ElicitationResult` | User responds to elicitation | `elicitation_id`, `action`, `content` |

### Permission Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `PermissionDenied` | User denies a permission | `tool_name`, `tool_input`, `session_id` |
| `PermissionRequest` | System requests permission | `tool_name`, `tool_input`, `permission_type` |

### Subagent Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `SubagentStart` | Subagent spawned | `agent_id`, `agent_type`, `task_description` |
| `SubagentStop` | Subagent completes | `agent_id`, `agent_type`, `result` |
| `TeammateIdle` | Teammate agent goes idle | `agent_id`, `session_id` |

### Task Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `TaskCreated` | Background task created | `task_id`, `task_description` |
| `TaskCompleted` | Background task finished | `task_id`, `task_result` |

### System Hooks
| Event | Trigger | Input Fields |
|---|---|---|
| `Stop` | Agent stops naturally | `stop_reason`, `session_id` |
| `StopFailure` | Agent stops due to error | `error`, `session_id` |
| `Notification` | System notification sent | `message`, `notification_type` |
| `FileChanged` | Watched file changes | `file_path`, `change_type` |
| `CwdChanged` | Working directory changes | `old_cwd`, `new_cwd` |
| `InstructionsLoaded` | CLAUDE.md files loaded | `instructions`, `memory_type` |
| `ConfigChange` | Configuration changes | `config_key`, `old_value`, `new_value` |
| `WorktreeCreate` | Git worktree created | `worktree_path` |

## Hook Execution Modes

### 1. Shell Command Hooks (Primary)

The most common hook type. Spawns a child process with the hook command:

```typescript
// Shell resolution: hook.shell → DEFAULT_HOOK_SHELL
const shellType = hook.shell ?? DEFAULT_HOOK_SHELL

if (shellType === 'powershell') {
  child = spawn(pwshPath, buildPowerShellArgs(finalCommand), { env, cwd })
} else {
  // On Windows: Git Bash explicitly. On Unix: shell: true
  const shell = isWindows ? findGitBashPath() : true
  child = spawn(finalCommand, [], { env, cwd, shell })
}
```

Hook input is piped via stdin as JSON. Hook output is parsed from stdout.

### 2. Callback Hooks (Internal)

TypeScript functions registered programmatically:

```typescript
export type HookCallback = {
  type: 'callback'
  callback: (
    input: HookInput,
    toolUseID: string | null,
    abort: AbortSignal | undefined,
    hookIndex?: number,
    context?: HookCallbackContext,
  ) => Promise<HookJSONOutput>
  timeout?: number
  internal?: boolean  // Excluded from analytics metrics
}
```

### 3. HTTP Hooks

Executed via `execHttpHook()` — sends HTTP requests to configured endpoints with hook input as JSON body.

### 4. Agent Hooks

Executed via `execAgentHook()` — delegates hook execution to an AI agent for complex decision-making.

## Hook Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "my-script.sh" }]
      }
    ],
    "PostToolUse": [...],
    "SessionStart": [...]
  }
}
```

### Matcher System

Hooks can match specific tools via the `matcher` field:
- String matcher: `"Bash"` — matches exact tool name
- No matcher: matches all tools for that event

### Plugin Hooks

Hooks from plugins use `PluginHookMatcher` with additional fields:
- `pluginName`: identifies the plugin
- `pluginRoot`: directory path (substituted as `${CLAUDE_PLUGIN_ROOT}`)
- Variables: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${user_config.X}`

### Skill Hooks

Skill-defined hooks use `SkillHookMatcher` with `skillRoot` for path substitution.

## PreToolUse Lifecycle

1. **Match**: Find all hooks whose matcher matches the tool name
2. **Execute**: Run each matched hook sequentially with tool input as JSON
3. **Process output**: Parse JSON response
4. **Decision**: Hook can return `approve`, `block`, or `ask`
5. **Input mutation**: Hook can return `updatedInput` to modify tool parameters
6. **Additional context**: Hook can inject `additionalContext` visible to the model

```typescript
// PreToolUse specific output schema
{
  hookEventName: 'PreToolUse',
  permissionDecision: 'allow' | 'deny' | 'ask',  // optional
  permissionDecisionReason: string,               // optional
  updatedInput: Record<string, unknown>,          // optional - mutate tool input
  additionalContext: string,                      // optional
}
```

## PostToolUse Lifecycle

1. **Execute**: Run after tool completes successfully
2. **Tool output inspection**: Hook receives `tool_output`
3. **Output mutation**: Can return `updatedMCPToolOutput` for MCP tools
4. **Additional context**: Inject context visible to the model

## Async Hooks

Hooks can run asynchronously via two mechanisms:

### Config-based async (`hook.async: true`)

```typescript
// Hook declares itself async:
{ "type": "command", "command": "...", "async": true }
```

Process is spawned and immediately backgrounded. Stdin is written before backgrounding. The hook's stdout/stderr are captured in-memory via `TaskOutput`.

### Async Rewake (`hook.asyncRewake: true`)

Similar to async but on completion, if exit code is 2 (blocking error), enqueues a task notification that **wakes the model** via the queue processor. This allows long-running hooks to interrupt an ongoing conversation.

```typescript
if (result.code === 2) {
  enqueuePendingNotification({
    value: wrapInSystemReminder(
      `Stop hook blocking error from command "${hookName}": ${stderr || stdout}`,
    ),
    mode: 'task-notification',
  })
}
```

## Hook JSON Output Protocol

Hooks communicate results via JSON on stdout. The output is validated against a Zod schema:

```typescript
// Sync response schema
{
  continue?: boolean,        // Default: true. false = stop conversation
  suppressOutput?: boolean,  // Hide stdout from transcript
  stopReason?: string,       // Message shown when continue=false
  decision?: 'approve' | 'block',
  reason?: string,
  systemMessage?: string,    // Warning shown to user
  hookSpecificOutput?: {     // Event-specific fields
    hookEventName: string,
    ...eventSpecificFields
  }
}

// Async response schema
{ async: true, asyncTimeout?: number }
```

### Validation

All hook output is validated via Zod:

```typescript
function validateHookJson(jsonString: string) {
  const parsed = jsonParse(jsonString)
  const validation = hookJSONOutputSchema().safeParse(parsed)
  if (validation.success) return { json: validation.data }
  // Format validation errors with expected schema hint
  return { validationError: `Hook JSON output validation failed:\n${errors}` }
}
```

## Hook Timeout Management

```typescript
const TOOL_HOOK_EXECUTION_TIMEOUT_MS = 10 * 60 * 1000  // 10 minutes
const SESSION_END_HOOK_TIMEOUT_MS_DEFAULT = 1500        // 1.5 seconds

// SessionEnd timeout is configurable via env:
const raw = process.env.CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS
```

SessionEnd hooks have a much tighter timeout because they run during shutdown — the process needs to exit quickly.

## Workspace Trust Requirement

**ALL hooks require workspace trust** — a defense-in-depth security measure:

```typescript
export function shouldSkipHookDueToTrust(): boolean {
  const isInteractive = !getIsNonInteractiveSession()
  if (!isInteractive) return false  // SDK mode: trust implicit
  return !checkHasTrustDialogAccepted()
}
```

Historical vulnerabilities that prompted this:
- SessionEnd hooks executing when user declines trust dialog
- SubagentStop hooks executing before trust established

## Hook Base Input

All hooks receive a common base input:

```typescript
function createBaseHookInput(permissionMode?, sessionId?, agentInfo?): {
  session_id: string
  transcript_path: string
  cwd: string
  permission_mode?: string
  agent_id?: string      // Present for subagent calls
  agent_type?: string    // Subagent type or main-thread agent type
}
```

## Environment Variables for Hooks

Hooks receive these environment variables:

| Variable | Purpose |
|---|---|
| `CLAUDE_PROJECT_DIR` | Stable project root (not worktree path) |
| `CLAUDE_PLUGIN_ROOT` | Plugin directory path |
| `CLAUDE_PLUGIN_DATA` | Plugin data directory |
| `CLAUDE_PLUGIN_OPTION_*` | Plugin user config values |
| `CLAUDE_ENV_FILE` | Path to env var file (SessionStart/Setup/CwdChanged/FileChanged only) |

On Windows, all paths are converted to POSIX format (`C:\Users\foo` → `/c/Users/foo`) for Git Bash compatibility, unless the hook uses `shell: 'powershell'`.

## Hook Result Aggregation

Multiple hooks for the same event are aggregated:

```typescript
type AggregatedHookResult = {
  message?: HookResultMessage
  blockingErrors?: HookBlockingError[]
  preventContinuation?: boolean
  stopReason?: string
  permissionBehavior?: PermissionResult['behavior']
  additionalContexts?: string[]
  updatedInput?: Record<string, unknown>
  updatedMCPToolOutput?: unknown
  permissionRequestResult?: PermissionRequestResult
  watchPaths?: string[]
  retry?: boolean
}
```

If ANY hook blocks, the entire operation is blocked. Additional contexts from all hooks are collected into an array.

## Hook-Permission System Integration

Hooks can override the permission system's decisions:

- `permissionBehavior: 'allow'` — Bypass permission prompt
- `permissionBehavior: 'deny'` — Block the operation
- `permissionBehavior: 'ask'` — Force a permission prompt
- `permissionBehavior: 'passthrough'` — Use default permission behavior

This allows hooks to implement custom security policies that augment or override the built-in permission system.

## Key Insights for Harness Engineers

1. **Hooks are the primary extension mechanism** — Nearly every lifecycle event can be intercepted and modified by hooks.

2. **Four execution modes** cover different use cases: shell scripts (simple), callbacks (internal), HTTP (remote services), agents (AI-powered decisions).

3. **Async rewake is unique** — It's the only mechanism that can interrupt an ongoing model conversation from outside the query loop.

4. **JSON protocol with Zod validation** — Prevents malformed hook output from corrupting the conversation. Every output field is validated.

5. **Workspace trust gates everything** — No hook executes in an untrusted workspace. This prevents malicious hooks from checked-in `.claude/settings.json`.

6. **Input mutation is powerful** — PreToolUse hooks can modify tool inputs before execution, enabling request sanitization, parameter injection, or input validation.

7. **Windows PowerShell support** — Hooks can opt into PowerShell via `shell: 'powershell''`, with separate path handling (native paths, no Git Bash conversion).
