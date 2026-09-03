# Cross-Cutting Architectural Patterns

> Synthesis from all source files in `src/` (1,902 TypeScript files, 44MB)

## Overview

This document captures cross-cutting patterns found across the entire Claude Code v2.1.88 codebase — patterns that don't fit into any single system document but are essential for understanding how the harness works as a whole.

## AbortController Architecture

### Memory-Safe Hierarchical Abort

Claude Code uses a **WeakRef-based hierarchical abort controller** system (src/utils/abortController.ts):

```typescript
export function createChildAbortController(
  parent: AbortController,
  maxListeners?: number,
): AbortController {
  const child = createAbortController(maxListeners)
  if (parent.signal.aborted) {
    child.abort(parent.signal.reason)
    return child
  }
  const weakChild = new WeakRef(child)
  const weakParent = new WeakRef(parent)
  const handler = propagateAbort.bind(weakParent, weakChild)
  parent.signal.addEventListener('abort', handler, { once: true })
  // Auto-cleanup on child abort
  child.signal.addEventListener('abort', removeAbortHandler.bind(weakParent, ...), { once: true })
  return child
}
```

Key design:
- **Parent → Child propagation**: When parent aborts, child aborts too
- **Child → Parent isolation**: Child abort does NOT affect parent
- **WeakRef prevents memory leaks**: Abandoned children can be GC'd
- **Auto-cleanup**: Child abort removes the parent listener
- **Default 50 max listeners**: Prevents `MaxListenersExceededWarning`

Used extensively across: streaming, tool execution, hooks, agent spawning, file watching.

## State Management

### Bootstrap State Pattern

Global state lives in `src/bootstrap/state.ts` — a centralized module with getter/setter functions:

```typescript
// Session identity
export function getSessionId(): string
export function setSessionId(id: string): void

// Project context
export function getOriginalCwd(): string
export function getProjectRoot(): string | undefined

// Feature state
export function getLastApiCompletionTimestamp(): number
export function setLastMainRequestId(id: string): void

// Permission state
export function getSessionBypassPermissionsMode(): boolean
export function getRegisteredHooks(): HookMatcher[]
```

This is NOT a flux/redux store — it's simple module-scoped mutable state with accessors. No subscriptions, no reactivity. React components re-render via hooks that poll or listen to events.

### React State in TUI

The TUI (React/ink) uses:
- **useState/useRef** for component-local state
- **Custom hooks** (50+ in `src/hooks/`) for shared state
- **No zustand** — Despite appearing in dependency analysis, state management is hook-based
- **React Compiler** active — All compiled components show `import { c as _c } from "react/compiler-runtime"`

## Zod Schema Validation

Zod is used **pervasively** throughout the codebase:

| Domain | Schema Usage |
|---|---|
| Hook input/output | `hookJSONOutputSchema`, `promptRequestSchema`, `syncHookResponseSchema` |
| Settings | `settingsSchema`, per-field validation |
| Permission rules | `permissionBehaviorSchema`, `permissionUpdateSchema` |
| Swarm permissions | `SwarmPermissionRequestSchema` |
| MCP messages | Channel validation, elicitation schemas |
| Plugin manifests | `schemas.ts` — extensive plugin validation |
| Tool inputs | Per-tool Zod schemas for parameter validation |

Pattern: **Lazy schema instantiation** via `lazySchema()` to avoid circular dependencies:

```typescript
import { lazySchema } from '../utils/lazySchema.js'
export const hookJSONOutputSchema = lazySchema(() => z.object({ ... }))
```

## Event-Driven Patterns

### Custom Event Emitter

`src/ink/events/emitter.ts` provides a typed event system for TUI communication:

```typescript
// Hook progress events
emitHookStarted({ hookId, hookEvent, hookName, command })
emitHookResponse({ hookId, hookName, output, outcome })

// Progress intervals for long-running hooks
startHookProgressInterval({ hookId, hookEvent, hookName })
```

### Message Queue Manager

`enqueuePendingNotification()` provides an async-safe way to inject messages into the conversation from background processes (async hooks, remote agents):

```typescript
enqueuePendingNotification({
  value: wrapInSystemReminder(message),
  mode: 'task-notification',  // Wakes model when idle
})
```

## Telemetry & Analytics Pipeline

### Event Logging

Every significant action generates an analytics event:

```typescript
import { logEvent } from 'src/services/analytics/index.js'
logEvent('tengu_streaming_stall', {
  stall_duration_ms: timeSinceLastEvent,
  stall_count: stallCount,
  model: options.model,
  request_id: streamRequestId,
})
```

Event naming convention: `tengu_<category>_<action>`

### GrowthBook Feature Flags

Feature flags are loaded from GrowthBook (analytics service) and cached:

```typescript
getFeatureValue_CACHED_MAY_BE_STALE('tengu_amber_prism', false)
checkStatsigFeatureGate_CACHED_MAY_BE_STALE('some_gate')
```

The `_CACHED_MAY_BE_STALE` suffix signals that the value may be up to 1 hour old.

### OpenTelemetry

Hook execution is traced via OpenTelemetry spans:

```typescript
import { startHookSpan, endHookSpan, isBetaTracingEnabled } from './telemetry/sessionTracing.js'
```

### Diagnostics Logging

Two-tier logging system:
- `logForDebugging()` — Verbose debugging info (always-on, gated by level)
- `logForDiagnosticsNoPII()` — PII-safe diagnostics for crash reports

## File Watching

### Settings Change Detection

`src/utils/settings/changeDetector.ts` watches settings files for external changes:

```typescript
import { settingsChangeDetector } from '../settings/changeDetector.js'
```

Uses chokidar (via ripgrep) to detect when settings files change, triggering hot-reload of configuration.

### File Changed Hooks

`FileChanged` hook event is triggered by file system watchers:

```typescript
// Hook output can request continued watching:
watchPaths?: string[]  // Absolute paths to continue watching
```

### Skill Change Detection

`src/utils/skills/skillChangeDetector.ts` monitors skill files for changes.

## Process Spawning & Management

### Shell Command Wrapping

`src/utils/ShellCommand.ts` provides a structured wrapper around child processes:

```typescript
class ShellCommand {
  background(processId: string): boolean
  result: Promise<ExitResult>
  taskOutput: TaskOutput
  cleanup(): void
}
```

Used by hooks, tool execution, and agent spawning.

### Teammate Process Spawning

Teammates are spawned as separate processes (tmux windows or in-process):

```typescript
export function getTeammateCommand(): string {
  if (process.env[TEAMMATE_COMMAND_ENV_VAR]) return process.env[TEAMMATE_COMMAND_ENV_VAR]
  return isInBundledMode() ? process.execPath : process.argv[1]!
}
```

### Subprocess Environment

`subprocessEnv()` constructs a clean environment for child processes:

```typescript
import { subprocessEnv } from './subprocessEnv.js'
// Filters out sensitive env vars, adds CLAUDE_* vars
```

## Environment Detection

### Platform Detection

```typescript
import { getPlatform, type Platform } from '../platform.js'
// Returns: 'mac' | 'linux' | 'windows'
```

### Environment Utilities

```typescript
import { isEnvTruthy, getClaudeConfigHomeDir } from './envUtils.js'

// Boolean env var parsing (handles "1", "true", "yes", etc.)
isEnvTruthy(process.env.CLAUDE_CODE_SKIP_PROMPT_HISTORY)

// Config home directory (respects XDG, falls back to ~/.claude)
getClaudeConfigHomeDir()
```

### Bundled Mode Detection

```typescript
import { isInBundledMode } from '../bundledMode.js'
// Returns true when running as compiled binary vs npm package
```

## Concurrency Patterns

### Async Generators

The entire query loop is built on `async function*` generators:

```typescript
async function* query(deps) {
  for await (const message of deps.callModel({...})) {
    yield message
  }
}
```

Utility functions for working with generators:

```typescript
import { returnValue, all } from './generators.js'
// returnValue() — wrap value in a single-yield generator
// all() — collect all values from a generator
```

### Write Queue with Batching

The session storage write queue batches writes on a 100ms timer, coalescing multiple append operations into single filesystem writes.

### Streaming Tool Executor Concurrency

Tools are classified as concurrency-safe or not:

```typescript
private canExecuteTool(isConcurrencySafe: boolean): boolean {
  const executingTools = this.tools.filter(t => t.status === 'executing')
  return executingTools.length === 0 ||
    (isConcurrencySafe && executingTools.every(t => t.isConcurrencySafe))
}
```

## Error Handling Patterns

### Error Stack Truncation

Stack traces are truncated to 5 frames before feeding back to the LLM:

```typescript
// From 16-resilience analysis
// Error stack traces truncated to 5 frames to save context tokens
```

### Error Classification

`src/utils/errors.ts` provides typed error checking:

```typescript
export function errorMessage(error: unknown): string
export function getErrnoCode(error: unknown): string | undefined
export function isFsInaccessible(error: unknown): boolean
```

### Graceful Degradation

Multiple systems follow a fail-safe pattern:
- Policy settings: fail-open (if server unreachable, existing policy stands)
- File watching: silently skip on permission errors
- Session metadata: best-effort re-append, don't crash on failure
- Hook execution: non-blocking errors don't halt the conversation

## Caching Strategies

### Memoization

lodash `memoize` is used extensively for expensive lookups:

```typescript
export const getProjectDir = memoize((projectDir: string): string => { ... })
export const getMemoryFiles = memoize(async (): Promise<MemoryFileInfo[]> => { ... })
```

### Feature Flag Caching

GrowthBook values are cached with `_CACHED_MAY_BE_STALE` suffix:

```typescript
getFeatureValue_CACHED_MAY_BE_STALE('flag_name', defaultValue)
```

### Lazy Module Loading

Heavy modules are loaded on-demand to reduce startup time:

```typescript
const autoModeStateModule = feature('TRANSCRIPT_CLASSIFIER')
  ? require('../../utils/permissions/autoModeState.js')
  : null
```

Feature-gated requires prevent loading unused code paths.

## CLI Architecture

### Entry Points

Multiple entry points for different usage modes:
- `src/entrypoints/cli.ts` — Interactive CLI
- `src/entrypoints/sdk.ts` — SDK/programmatic usage
- `src/entrypoints/mcp.ts` — MCP server mode
- `src/entrypoints/agentSdkTypes.ts` — SDK type definitions

### Argument Parsing

Arguments are parsed and validated before bootstrap:

```typescript
// From 01-architecture analysis
// CLI args → flags → settings → bootstrap → REPL
```

## Key Insights for Harness Engineers

1. **WeakRef abort controllers are essential** — The hierarchical abort pattern with WeakRef prevents memory leaks in long-running sessions with many concurrent operations.

2. **Zod everywhere** — Schema validation is not optional. Every external input (hooks, settings, MCP, plugins) is validated through Zod schemas with lazy loading for circular dependency avoidance.

3. **Bootstrap state is simple mutable state** — No flux, no redux, no observables. Just module-scoped variables with getter/setter functions. React components re-render via hooks.

4. **Analytics events are first-class** — Nearly every user-visible action generates a telemetry event. Event names follow `tengu_<category>_<action>` convention.

5. **Lazy loading via feature gates** — Code paths are gated by `feature('FLAG_NAME')` checks that prevent unused modules from loading. This reduces startup time and memory.

6. **Generator-based architecture** — The query loop, streaming, and tool execution all use async generators. This enables backpressure, lazy evaluation, and clean composability.

7. **Fail-safe by default** — Network errors, permission failures, and filesystem issues are handled gracefully without crashing the session.
