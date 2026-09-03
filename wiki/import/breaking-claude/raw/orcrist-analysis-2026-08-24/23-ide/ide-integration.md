# IDE Integration

> Source: `src/utils/ide.ts` (1,494 lines), `src/hooks/useIde*.ts`, `src/services/mcp/vscodeSdkMcp.ts`, `src/services/lsp/LSPClient.ts`, `src/utils/idePathConversion.ts`

## Overview

Claude Code integrates with IDEs (VS Code, JetBrains) through a **lockfile-based discovery** mechanism and an **MCP-compatible communication channel**. The IDE runs a lightweight extension that starts a local HTTP/WebSocket server, writes a lockfile, and communicates with Claude Code via JSON-RPC over that channel.

## IDE Detection

### Lockfile Discovery

IDE extensions write lockfiles that Claude Code discovers at startup:

```typescript
type IdeLockfileInfo = {
  workspaceFolders: string[]
  port: number
  pid?: number
  ideName?: string
  useWebSocket: boolean  // 'ws' or 'sse' transport
  runningInWindows: boolean
  authToken?: string
}
```

Detection algorithm (ide.ts):
1. Check ancestor process chain for known IDE process names
2. Scan for lockfiles in well-known locations
3. Validate lockfile content (port reachable, PID still running)
4. Return `DetectedIDEInfo` with connection details

```typescript
export type DetectedIDEInfo = {
  name: string           // "VS Code", "JetBrains", etc.
  port: number           // Local server port
  workspaceFolders: string[]
  url: string            // Connection URL
  isValid: boolean
  authToken?: string
  ideRunningInWindows?: boolean  // WSL scenario
}
```

### Ancestor PID Lookup

Claude Code walks its parent process tree to detect which IDE launched it:

```typescript
function makeAncestorPidLookup(): () => Promise<Set<number>> {
  let promise: Promise<Set<number>> | null = null
  return () => {
    if (!promise) {
      promise = getAncestorPidsAsync(process.ppid, 10).then(pids => new Set(pids))
    }
    return promise
  }
}
```

Traverses up to 10 ancestor levels.

### Supported IDEs

| IDE | Detection Method | Transport |
|---|---|---|
| **VS Code** | Lockfile + process name | WebSocket/SSE |
| **JetBrains** | Lockfile + plugin check | WebSocket/SSE |
| **Cursor** | VS Code-compatible lockfile | WebSocket/SSE |
| **Windsurf** | VS Code-compatible lockfile | WebSocket/SSE |

## VS Code Integration

### Extension Architecture

The VS Code extension:
1. Starts a local HTTP server on a random port
2. Writes lockfile to `~/.claude/ide/` with port, PID, workspace folders
3. Registers as an MCP server named `claude-in-chrome`
4. Provides IDE-specific tools (openFile, showDiff, diagnostics)

### Communication Protocol

JSON-RPC over WebSocket or SSE:

```typescript
// RPC call from Claude Code to IDE
const result = await callIdeRpc('openFile', { path: '/path/to/file.ts', line: 42 })

// RPC notification from IDE to Claude Code
// (file changes, selection changes, diagnostics updates)
```

### MCP Integration

VS Code registers as an MCP server via `vscodeSdkMcp.ts`:

```typescript
const CLAUDE_IN_CHROME_MCP_SERVER_NAME = 'claude-in-chrome'
```

This provides IDE-specific tools like:
- File opening and navigation
- Diff viewing
- Selection tracking
- Diagnostic information

## JetBrains Integration

### Plugin Detection

JetBrains plugin installed status is cached:

```typescript
import { isJetBrainsPluginInstalledCached } from '../jetbrains.js'
```

Uses the same lockfile + MCP communication pattern as VS Code.

### JetBrains-Specific Features

- Project model integration (source roots, libraries)
- Run configuration awareness
- VCS integration (built-in Git support)

## Context Sharing

### Open File & Selection

`useIdeSelection` hook tracks the currently active editor selection:

```typescript
// IDE sends selection updates via MCP
// Claude Code injects selection context into the system prompt
```

### Diagnostics

LSP diagnostics (errors, warnings) are shared from IDE to Claude Code:
- Used for context in the system prompt
- Available for error-aware code suggestions

### Path Conversion

WSL scenarios require path conversion between Windows and Linux paths:

```typescript
import { checkWSLDistroMatch, WindowsToWSLConverter } from './idePathConversion.js'
```

## IDE-Specific Hooks

| Hook | Purpose |
|---|---|
| `useIdeConnectionStatus` | Track IDE connection state |
| `useIdeSelection` | Track active editor selection |
| `useIdeLogging` | Forward logs to IDE output panel |
| `useIdeAtMentioned` | Handle @-mention context from IDE |
| `useDiffInIDE` | Show file diffs in IDE editor |

## Terminal vs IDE Mode

When running inside an IDE:
- **Permissions**: Some permissions are auto-approved (file reads within workspace)
- **UI**: Simplified — no terminal UI, uses IDE's output channels
- **Context**: IDE provides open files, selections, diagnostics
- **Navigation**: File/line references open in IDE editor instead of terminal

## Direct Connect Mode

For headless/SDK usage, Claude Code can connect to an IDE without being launched from it:

```typescript
// Configure via environment or CLI flags
// Lockfile specifies transport (ws/sse), port, auth token
```

## Key Insights for Harness Engineers

1. **Lockfile-based discovery** — No explicit configuration needed. The IDE writes a lockfile, Claude Code finds it. This is zero-config for users.

2. **MCP as the communication backbone** — IDE integration uses the same MCP protocol as other tool servers, making IDE features available as tools.

3. **Ancestor PID walking** — Claude Code determines its IDE context by checking its parent process tree, not environment variables.

4. **Path conversion for WSL** — Windows/Linux path translation is handled transparently, enabling Claude Code to run in WSL while the IDE runs on Windows.

5. **Selection context injection** — The IDE's active editor selection is injected into the conversation context, enabling "edit what I'm looking at" workflows.
