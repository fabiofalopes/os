# Session Lifecycle Management

> Source: `src/utils/sessionStorage.ts` (5,105 lines), `src/utils/cleanupRegistry.ts`, `src/utils/concurrentSessions.ts`

## Overview

Session management in Claude Code is built around a **JSONL-based append-only log** with a `parentUuid` chain forming a tree structure. The `Project` class is a singleton that manages all session persistence through a buffered write queue with 100ms flush intervals. Sessions survive across process restarts via `--resume` and can branch via worktree-based isolation.

## Session Data Model

### Storage Location

Sessions are stored in `~/.claude/projects/<sanitized-path>/<session-id>.jsonl`:

```typescript
export const getProjectDir = memoize((projectDir: string): string => {
  return join(getProjectsDir(), sanitizePath(projectDir))
})
```

- `getProjectsDir()` → `~/.claude/projects/`
- `sanitizePath()` converts path separators to safe characters
- Memoized: called 12+ times per turn via hooks

### Transcript Types

```typescript
type Transcript = (
  | UserMessage
  | AssistantMessage
  | AttachmentMessage
  | SystemMessage
)[]
```

### Entry Types in JSONL

The JSONL file contains multiple entry types beyond transcript messages:

| Entry Type | Purpose |
|---|---|
| `user`, `assistant`, `attachment`, `system` | Transcript messages (chain participants) |
| `progress` | **Legacy only** — no longer written, bridged on load |
| `custom-title` | User-defined session name |
| `tag` | Session tag for categorization |
| `last-prompt` | Last user message text (for --resume picker) |
| `agent-name`, `agent-color`, `agent-setting` | Agent display config |
| `mode` | Coordinator vs normal mode |
| `worktree-state` | Worktree isolation tracking |
| `pr-link` | PR number/URL/repository |
| `file-history-snapshot` | File state at point in time |
| `context-collapse-snapshot` | Compaction boundary |
| `content-replacement` | Diff-based edit tracking |
| `attribution-snapshot` | Commit attribution state |

### Chain Structure

Messages are linked via `parentUuid` forming a tree:

```typescript
interface TranscriptMessage extends Message {
  parentUuid: UUID | null      // Previous message in chain
  logicalParentUuid?: UUID      // Compact boundary parent
  isSidechain: boolean          // Subagent vs main chain
  sessionId: string
  userType: string
  entrypoint: string
  cwd: string
  version: string              // MACRO.VERSION at write time
  gitBranch?: string
  slug?: string                // Plan slug
  agentId?: string
  promptId?: string            // User messages only
}
```

**Progress messages are excluded from the chain** (line 154):

```typescript
export function isChainParticipant(m: Pick<Message, 'type'>): boolean {
  return m.type !== 'progress'
}
```

Historical bug (#14373, #23537): Progress entries in the parentUuid chain caused chain forks that orphaned real messages on resume.

## Session Creation

1. **Session ID**: Generated as UUID on startup, stored in bootstrap state
2. **Lazy materialization**: Session file is NOT created until the first user/assistant message
3. **Pending buffer**: Before materialization, entries accumulate in `pendingEntries[]`
4. **Metadata caching**: Title, tag, agent settings cached in `Project` singleton

```typescript
async insertMessageChain(messages, isSidechain, agentId, startingParentUuid) {
  // First user/assistant message materializes the session file
  if (this.sessionFile === null &&
      messages.some(m => m.type === 'user' || m.type === 'assistant')) {
    await this.materializeSessionFile()
  }
}
```

## Session Persistence

### Write Queue Architecture

The `Project` class uses a **per-file write queue** with batched flushing:

```typescript
class Project {
  private writeQueues = Map<string, Array<{ entry: Entry, resolve: () => void }>>()
  private flushTimer: ReturnType<typeof setTimeout> | null = null
  private activeDrain: Promise<void> | null = null
  private FLUSH_INTERVAL_MS = 100  // 100ms batch window
  private readonly MAX_CHUNK_BYTES = 100 * 1024 * 1024  // 100MB per write
}
```

Flow:
1. `appendEntry()` → `enqueueWrite()` → adds to queue, schedules drain
2. After 100ms, `drainWriteQueue()` runs
3. All queued entries are serialized as JSONL lines and appended in one `fs.appendFile` call
4. Chunks split at 100MB boundary to avoid memory issues
5. Each entry's resolve callback fires after write completes

### File Creation

```typescript
private async appendToFile(filePath: string, data: string): Promise<void> {
  try {
    await fsAppendFile(filePath, data, { mode: 0o600 })  // Owner read/write only
  } catch {
    await mkdir(dirname(filePath), { recursive: true, mode: 0o700 })
    await fsAppendFile(filePath, data, { mode: 0o600 })
  }
}
```

Permission mode `0o600` ensures only the owner can read/write session files.

### Flush & Cleanup

```typescript
async flush(): Promise<void> {
  if (this.flushTimer) clearTimeout(this.flushTimer)
  if (this.activeDrain) await this.activeDrain
  await this.drainWriteQueue()
  // Wait for tracked operations (e.g. removeMessageByUuid)
  if (this.pendingWriteCount === 0) return
  return new Promise(resolve => this.flushResolvers.push(resolve))
}
```

Registered as cleanup handler:

```typescript
registerCleanup(async () => {
  await project?.flush()
  project?.reAppendSessionMetadata()
})
```

## Session Resume

### Loading Strategy

Sessions can be multi-GB. The loader uses a **tail-read optimization**:

```typescript
export const MAX_TRANSCRIPT_READ_BYTES = 50 * 1024 * 1024  // 50MB cap
const LITE_READ_BUF_SIZE = 64 * 1024  // 64KB tail read for metadata
```

1. **Metadata read**: `readLiteMetadata()` reads only the last 64KB to extract title, tag, last-prompt
2. **Full transcript read**: `readTranscriptForLoad()` reads up to 50MB
3. **Progress bridging**: Legacy progress entries are bridged — their parentUuid is skipped and children point to the next real chain participant

### Legacy Progress Bridging

```typescript
function isLegacyProgressEntry(entry: unknown): entry is LegacyProgressEntry {
  return typeof entry === 'object' && entry !== null &&
    'type' in entry && entry.type === 'progress' &&
    'uuid' in entry && typeof entry.uuid === 'string'
}
```

When loading, if a legacy progress entry is found in the chain, its parentUuid is used to bridge the gap — the next real message's parentUuid is set to the progress entry's parentUuid.

## Session Title Generation

Titles are generated from the first meaningful user message:

```typescript
// Skip non-meaningful messages (IDE context, hook output, etc.)
const SKIP_FIRST_PROMPT_PATTERN =
  /^(?:\s*<[a-z][\w-]*[\s>]|\[Request interrupted by user[^\]]*\])/

// Cache last prompt for reAppendSessionMetadata
this.currentSessionLastPrompt =
  flat.length > 200 ? flat.slice(0, 200).trim() + '…' : flat
```

Custom titles can be set via:
- CLI `/rename` command
- SDK `renameSession()` API
- Written as `{"type":"custom-title","customTitle":"..."}` entry

## Session Metadata Re-Append

`reAppendSessionMetadata()` ensures metadata stays within the tail window that `readLiteMetadata()` reads:

```typescript
reAppendSessionMetadata(skipTitleRefresh = false): void {
  // Read tail to refresh SDK-mutable fields
  const tail = readFileTailSync(this.sessionFile)
  
  // Absorb fresher SDK-written title/tag
  const titleLine = tailLines.findLast(l => l.startsWith('{"type":"custom-title"'))
  if (titleLine) {
    const tailTitle = extractLastJsonStringField(titleLine, 'customTitle')
    if (tailTitle !== undefined) this.currentSessionTitle = tailTitle || undefined
  }
  
  // Re-append all metadata fields to end of file
  if (this.currentSessionLastPrompt) appendEntryToFile(...)
  if (this.currentSessionTitle) appendEntryToFile(...)
  if (this.currentSessionTag) appendEntryToFile(...)
  // ... agent-name, agent-color, agent-setting, mode, worktree-state, pr-link
}
```

Called from two contexts:
1. **Compaction**: Just before boundary marker emission
2. **Session exit**: Via cleanup handler, ensures metadata at EOF

## Subagent Session Storage

Subagent transcripts are stored in subdirectories:

```typescript
export function getAgentTranscriptPath(agentId: AgentId): string {
  const subdir = agentTranscriptSubdirs.get(agentId)
  const base = subdir
    ? join(projectDir, sessionId, 'subagents', subdir)
    : join(projectDir, sessionId, 'subagents')
  return join(base, `agent-${agentId}.jsonl`)
}
```

### Agent Metadata

Sidecar `.meta.json` file stores agent launch configuration:

```typescript
export type AgentMetadata = {
  agentType: string
  worktreePath?: string       // If agent was spawned with worktree isolation
  description?: string        // Original task description for resume display
}
```

This enables resume to route correctly when `subagent_type` is omitted — without it, a resumed fork silently degrades to general-purpose.

### Remote Agent Metadata

Remote agents (CCR tasks) have separate metadata:

```typescript
export type RemoteAgentMetadata = {
  taskId: string
  remoteTaskType: string
  sessionId: string           // CCR session ID
  title: string
  command: string
  spawnedAt: number
  toolUseId?: string
  isLongRunning?: boolean
  isUltraplan?: boolean
  isRemoteReview?: boolean
}
```

## Message Tombstoning

Failed streaming attempts can leave orphaned messages. `removeMessageByUuid()` removes them via surgical file edit:

```typescript
async removeMessageByUuid(targetUuid: UUID): Promise<void> {
  // Fast path: read last 64KB, find UUID, truncate + rewrite tail
  const needle = `"uuid":"${targetUuid}"`
  const matchIdx = tail.lastIndexOf(needle)
  if (matchIdx >= 0) {
    await fh.truncate(absLineStart)
    if (afterLen > 0) await fh.write(tail, lineEnd, afterLen, absLineStart)
    return
  }
  
  // Slow path: full file rewrite (guarded by MAX_TOMBSTONE_REWRITE_BYTES = 50MB)
  if (fileSize > MAX_TOMBSTONE_REWRITE_BYTES) {
    logForDebugging(`Skipping tombstone removal: session file too large`)
    return
  }
  // ... full read + filter + rewrite
}
```

## Ephemeral Progress Types

High-frequency tool progress ticks are UI-only — not persisted:

```typescript
const EPHEMERAL_PROGRESS_TYPES = new Set([
  'bash_progress',
  'powershell_progress',
  'mcp_progress',
  ...(feature('PROACTIVE') ? ['sleep_progress'] : []),
])
```

## Session Persistence Skip Conditions

```typescript
private shouldSkipPersistence(): boolean {
  return (
    (getNodeEnv() === 'test' && !allowTestPersistence) ||
    getSettings_DEPRECATED()?.cleanupPeriodDays === 0 ||
    isSessionPersistenceDisabled() ||
    isEnvTruthy(process.env.CLAUDE_CODE_SKIP_PROMPT_HISTORY)
  )
}
```

## Key Insights for Harness Engineers

1. **JSONL append-only with parentUuid chain** — Enables tree-structured conversations, branching, and compact boundary markers without rewriting the file.

2. **Lazy materialization** — Session file isn't created until the first real message. This avoids empty session files from metadata-only operations.

3. **100ms buffered write queue** — Balances responsiveness (writes don't block the query loop) with durability (entries are flushed regularly).

4. **Tail-read optimization** — Metadata (title, tag, last-prompt) is always in the last 64KB. `reAppendSessionMetadata()` keeps it there even after compaction.

5. **Progress messages are poison** — They must never enter the parentUuid chain. The loader has special bridging logic for legacy transcripts that included them.

6. **Surgical tombstoning** — Failed messages are removed by truncating + rewriting the tail, not rewriting the entire file. Falls back to full rewrite only if the UUID isn't in the last 64KB.

7. **Subagent isolation** — Each subagent gets its own JSONL file in a subdirectory. Metadata sidecars enable correct routing on resume.

8. **External writer coordination** — The SDK can rename/tag sessions concurrently. The re-append logic reads the tail first to absorb any fresher external values.
