# Sandbox Architecture

> Source: `src/utils/sandbox/sandbox-adapter.ts` (985 lines), `src/utils/sandbox/sandbox-ui-utils.ts`, `src/utils/swarm/permissionSync.ts` (928 lines), `src/utils/swarm/spawnUtils.ts`, `@anthropic-ai/sandbox-runtime` (external package)

## Overview

Claude Code uses **`@anthropic-ai/sandbox-runtime`** as its sandbox isolation layer. The `SandboxManager` class wraps this external package with Claude Code-specific integrations including settings conversion, permission rule translation, violation tracking, and network restrictions. The sandbox provides file system isolation, network restrictions, and process containment for tool execution.

## Sandbox Architecture

### Adapter Layer

`sandbox-adapter.ts` is the bridge between `@anthropic-ai/sandbox-runtime` and Claude Code:

```typescript
import {
  SandboxManager as BaseSandboxManager,
  SandboxRuntimeConfigSchema,
  SandboxViolationStore,
} from '@anthropic-ai/sandbox-runtime'
```

The adapter:
1. Converts Claude Code permission rules into sandbox filesystem restrictions
2. Translates settings into `SandboxRuntimeConfig`
3. Provides a violation store for tracking sandbox violations
4. Manages sandbox lifecycle (create, configure, destroy)

### Sandbox Runtime Configuration

```typescript
type SandboxRuntimeConfig = {
  fsReadRestrictions?: FsReadRestrictionConfig
  fsWriteRestrictions?: FsWriteRestrictionConfig
  networkRestrictions?: NetworkRestrictionConfig
  ignoreViolations?: IgnoreViolationsConfig
  // ... other sandbox-runtime options
}
```

### Path Pattern Resolution

Claude Code has its own path conventions that must be translated for the sandbox:

```typescript
// Claude Code-specific path patterns:
//   //path  → absolute from filesystem root (/path)
//   /path   → relative to settings file directory ($SETTINGS_DIR/path)
//   ~/path  → home directory (sandbox-runtime handles)
//   ./path  → relative (sandbox-runtime handles)

export function resolvePathPatternForSandbox(
  pattern: string,
  source: SettingSource,
): string {
  // Handle // prefix → absolute path
  if (pattern.startsWith('//')) return pattern.slice(1)
  // Handle / prefix → relative to settings dir
  if (pattern.startsWith('/') && !pattern.startsWith('//')) {
    const settingsDir = getSettingsRootPathForSource(source)
    return join(settingsDir, pattern.slice(1))
  }
  return pattern  // Pass through for sandbox-runtime to handle
}
```

### Permission Rule Translation

Claude Code permission rules are converted to sandbox filesystem restrictions:

```typescript
// Permission rules like "Bash(prompt:deploy*)" are parsed into:
type PermissionRuleValue = {
  toolName: string
  ruleContent?: string  // e.g., "prompt:deploy*"
}

// Then translated to sandbox FS restrictions based on tool type:
// - Bash tool → execute restrictions
// - FileReadTool → read restrictions
// - FileEditTool/FileWriteTool → write restrictions
```

### Network Restrictions

```typescript
type NetworkRestrictionConfig = {
  allowedHosts?: NetworkHostPattern[]
  blockedHosts?: NetworkHostPattern[]
}
```

Network access is restricted based on settings and tool permissions. WebFetch/Bash tools may have different network policies.

### Violation Tracking

```typescript
import { SandboxViolationStore } from '@anthropic-ai/sandbox-runtime'

type SandboxViolationEvent = {
  tool: string
  action: string
  path?: string
  timestamp: number
}
```

Violations are tracked and surfaced to the user when a tool attempts an action outside the sandbox policy.

## Swarm Permission Synchronization

For multi-agent scenarios (swarms/teammates), permissions must be synchronized between workers and the team leader.

### Permission Request Flow

```
1. Worker encounters permission prompt
2. Worker sends permission_request to leader's mailbox
3. Leader polls mailbox, detects request
4. User approves/denies via leader's UI
5. Leader sends permission_response to worker's mailbox
6. Worker polls mailbox, continues execution
```

### Request Schema

```typescript
const SwarmPermissionRequestSchema = z.object({
  id: z.string(),                    // Unique request ID
  workerId: z.string(),              // Worker's agent ID
  workerName: z.string(),            // Worker's display name
  workerColor: z.string().optional(),
  teamName: z.string(),              // Team routing
  toolName: z.string(),              // Tool needing permission
  toolUseId: z.string(),             // Original tool use ID
  description: z.string(),           // Human-readable description
  input: z.record(z.string(), z.unknown()),
  permissionSuggestions: z.array(z.unknown()),
  status: z.enum(['pending', 'approved', 'rejected']),
  resolvedBy: z.enum(['worker', 'leader']).optional(),
  feedback: z.string().optional(),
  updatedInput: z.record(z.string(), z.unknown()).optional(),
  permissionUpdates: z.array(z.unknown()).optional(),
  createdAt: z.number(),
})
```

### Mailbox-Based Communication

Permissions are communicated via filesystem-based mailboxes:

```typescript
import { writeToMailbox } from '../teammateMailbox.js'
// Workers write to leader's mailbox directory
// Leader writes responses to worker's mailbox directory
```

## Teammate Spawning

### Spawn Utilities

`spawnUtils.ts` handles propagating configuration to spawned teammates:

```typescript
export function buildInheritedCliFlags(options?): string {
  const flags: string[] = []
  // Propagate permission mode
  if (permissionMode === 'bypassPermissions') {
    flags.push('--dangerously-skip-permissions')
  } else if (permissionMode === 'acceptEdits') {
    flags.push('--permission-mode acceptEdits')
  }
  // Propagate model, settings, plugins
  if (modelOverride) flags.push(`--model ${quote([modelOverride])}`)
  if (settingsPath) flags.push(`--settings ${quote([settingsPath])}`)
  // Propagate teammate mode
  flags.push(`--teammate-mode ${sessionMode}`)
  return flags.join(' ')
}
```

### Environment Variable Forwarding

Tmux-spawned teammates need explicit env var forwarding:

```typescript
const TEAMMATE_ENV_VARS = [
  'CLAUDE_CODE_USE_BEDROCK',
  'CLAUDE_CODE_USE_VERTEX',
  // ... API provider selection, auth tokens, etc.
]
```

Without these, teammates default to first-party API and send requests to the wrong endpoint.

## Key Insights for Harness Engineers

1. **Sandbox is external, not built-in** — `@anthropic-ai/sandbox-runtime` is an external Anthropic package. Claude Code wraps it with settings translation and permission conversion.

2. **Path conventions differ between systems** — Claude Code's `//` (absolute) and `/` (settings-relative) conventions must be translated for the sandbox runtime.

3. **Permission rules become FS restrictions** — Claude Code's permission system (allow/deny rules per tool) is translated into sandbox filesystem read/write/execute restrictions.

4. **Swarm permissions use mailbox pattern** — Filesystem-based mailboxes enable permission synchronization between leader and worker agents without direct network communication.

5. **Environment forwarding is critical for teammates** — Tmux creates new login shells that don't inherit parent env. API provider, auth tokens, and feature flags must be explicitly forwarded.

6. **Violation tracking surfaces to UI** — Sandbox violations are tracked via `SandboxViolationStore` and displayed to the user when tools attempt restricted actions.
