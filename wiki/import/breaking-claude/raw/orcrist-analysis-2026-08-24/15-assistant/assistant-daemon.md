# 15 — Assistant Daemon, Session History & Prompt History

Complete deconstruction of Claude Code's background daemon system, session event history, and prompt history management.

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│  Prompt History (history.ts)                         │
│  ┌──────────────────────────────────────────────┐   │
│  │  ~/.claude/history.jsonl                     │   │
│  │  ├── Per-project entries                     │   │
│  │  ├── Paste content (inline or hash refs)     │   │
│  │  └── Session-scoped, newest-first            │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  Session History (assistant/sessionHistory.ts)       │
│  ┌──────────────────────────────────────────────┐   │
│  │  API: /v1/sessions/{id}/events               │   │
│  │  ├── Paginated event fetching                │   │
│  │  ├── cursor-based pagination (before_id)     │   │
│  │  └── Used by claude assistant (daemon mode)  │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

---

## 2. Prompt History System (`history.ts`, 464 lines)

### Storage Format

History is stored as **JSONL** (one JSON object per line) at `~/.claude/history.jsonl`:

```typescript
type LogEntry = {
  display: string                           // The text shown in history
  pastedContents: Record<number, StoredPastedContent>  // Paste content refs
  timestamp: number                         // Unix timestamp
  project: string                           // Project root path
  sessionId?: string                        // Session UUID
}
```

### Paste Content Handling

Two storage strategies based on content size:

```typescript
type StoredPastedContent = {
  id: number
  type: 'text' | 'image'
  content?: string         // Inline for ≤1KB
  contentHash?: string     // Hash reference for >1KB (stored in pasteStore)
  mediaType?: string
  filename?: string
}
```

**Threshold**: 1,024 characters. Small content is stored inline in the JSONL entry; large content is stored in a separate paste store with a hash reference.

### Reference Format

Parsed from user input using regex:

```
[Pasted text #1]              — Text paste, 0 newlines
[Pasted text #2 +5 lines]     — Text paste, 5 newlines
[Image #3]                    — Image paste
[...Truncated text #4]        — Truncated content
```

Pattern: `/\[(Pasted text|Image|\.\.\.Truncated text) #(\d+)(?: \+\d+ lines)?(\.)*\]/g`

### History Reading

Three access patterns:

#### 1. Up-Arrow History (`getHistory()`)
```
1. Current session entries first (newest-first)
2. Other session entries after
3. MAX_HISTORY_ITEMS = 100 window
4. Project-scoped (only current project)
```

#### 2. Ctrl+R Search (`getTimestampedHistory()`)
```
1. Current-project entries
2. Deduplicated by display text
3. Includes timestamps
4. Lazy content resolution via resolve()
5. MAX_HISTORY_ITEMS = 100 window
```

#### 3. Raw Reader (`makeLogEntryReader()`)
```
1. Start with pending (unflushed) entries
2. Read history.jsonl in reverse (newest-first)
3. Skip entries in skippedTimestamps set
4. Async generator for streaming reads
```

### Write Pipeline

```
addToHistory(command)
  │
  ├── Check CLAUDE_CODE_SKIP_PROMPT_HISTORY env → skip if set
  ├── Register cleanup handler (first call only)
  │
  └── addToPromptHistory(command)
       ├── Serialize paste content (inline or hash)
       ├── Create LogEntry with timestamp + project + sessionId
       ├── Push to pendingEntries buffer
       └── Trigger async flush:
            └── flushPromptHistory(retries=0)
                 ├── Acquire file lock
                 ├── Append JSONL to history.jsonl
                 ├── Release lock
                 └── If failed: retry up to 5 times with 500ms delay
```

### Undo Support

```typescript
function removeLastFromHistory(): void {
  // Fast path: entry still in pending buffer → splice out
  // Slow path: entry already flushed → add timestamp to skippedTimestamps set
  // Readers check skippedTimestamps and skip matching entries
}
```

Used by auto-restore-on-interrupt: when Esc rewinds the conversation before any response arrives, the history entry is also removed.

### File Locking

Uses `lockfile` package with:
- `stale: 10000` — 10s stale lock timeout
- `retries: 3` — 3 lock acquisition attempts
- Mode `0o600` — Owner read/write only

---

## 3. Session Event History (`assistant/sessionHistory.ts`, 87 lines)

### Purpose

Fetches historical events from a remote session via the Anthropic API. Used by `claude assistant` (daemon mode) to display past conversation events.

### API

```
GET /v1/sessions/{sessionId}/events
Headers:
  Authorization: Bearer {accessToken}
  anthropic-beta: ccr-byoc-2025-07-29
  x-organization-uuid: {orgUUID}
Params:
  limit: 100 (default page size)
  anchor_to_latest: true (for newest page)
  before_id: {cursor} (for older pages)
```

### Pagination

```typescript
type HistoryPage = {
  events: SDKMessage[]      // Chronological within page
  firstId: string | null    // Cursor for next-older page
  hasMore: boolean          // Older events exist?
}
```

Two fetch modes:
- `fetchLatestEvents(ctx, limit)` — Gets the most recent `limit` events with `anchor_to_latest: true`
- `fetchOlderEvents(ctx, beforeId, limit)` — Gets events before the cursor with `before_id: beforeId`

### Auth Context

```typescript
type HistoryAuthCtx = {
  baseUrl: string           // API endpoint
  headers: Record<string, string>  // Auth headers
}

async function createHistoryAuthCtx(sessionId): Promise<HistoryAuthCtx> {
  const { accessToken, orgUUID } = await prepareApiRequest()
  return { baseUrl, headers: { Authorization, anthropic-beta, x-organization-uuid } }
}
```

### Page Size

```typescript
export const HISTORY_PAGE_SIZE = 100
```

---

## 4. "claude assistant" Daemon Mode

Based on the codebase analysis, the assistant mode connects to a remote session as a **viewer-only client**:

### Key Characteristics

1. **`viewerOnly: true`** in RemoteSessionConfig — No interrupt capability, no reconnect timeout
2. **Session history** — Fetches past events via `sessionHistory.ts` for display
3. **WebSocket subscription** — Streams live events via `SessionsWebSocket`
4. **SDKMessage adaptation** — Converts remote messages to local format via `sdkMessageAdapter.ts`
5. **Background operation** — Designed to run as a daemon/service, not interactive CLI

### Hook Integration

The REPL uses `useAssistantHistory` hook to:
1. Fetch initial history from the remote session
2. Render historical events
3. Subscribe to live events via WebSocket
4. Handle compaction boundaries in the event stream

---

## 5. Key Takeaways

1. **Prompt history** is JSONL-based with file locking, 100-item window, project-scoped, with paste content deduplication
2. **Session events** are API-fetched with cursor-based pagination (100 events/page)
3. **Assistant mode** is a viewer-only remote client designed for background/daemon operation
4. **History undo** supports fast-path (pending buffer) and slow-path (timestamp skip set)
5. **Paste storage** uses dual strategy: inline for ≤1KB, hash-referenced for larger content
6. **Skip environment** (`CLAUDE_CODE_SKIP_PROMPT_HISTORY`) prevents tmux worker sessions from polluting user history
7. **Session-scoped ordering** — Current session entries always appear first in Up-arrow navigation
