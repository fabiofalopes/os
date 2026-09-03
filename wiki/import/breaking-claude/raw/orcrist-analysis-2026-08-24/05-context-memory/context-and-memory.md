# Context & Memory — Complete Reference

> The context compression pipeline (snip → microcompact → collapse → autocompact), persistent memory (memdir), auto-dream consolidation, and reactive compact in Claude Code v2.1.88.

---

## 1. Context Compression Pipeline

The context compression pipeline runs **at the start of every `while(true)` iteration** in `query.ts`. It has four stages, each progressively more aggressive:

```
┌─────────────────────────────────────────────────────────────┐
│              CONTEXT COMPRESSION PIPELINE                    │
│                                                             │
│  Stage 1: Tool Result Budget (applyToolResultBudget)        │
│  ├── Trim oversized individual tool results                 │
│  ├── Content replacement state tracking                     │
│  └── Persist replacements for session resume                │
│                                                             │
│  Stage 2: Snip (snipCompact) [HISTORY_SNIP feature gate]    │
│  ├── Remove old low-value tool results                      │
│  ├── Keep recent assistant/user messages                    │
│  ├── Track tokens freed for autocompact threshold           │
│  └── Yield boundary message                                 │
│                                                             │
│  Stage 3: Microcompact (cachedMicrocompact)                 │
│  ├── Cache-editing compression (no API call)                │
│  ├── Modify cached prefix in-place                          │
│  ├── Deferred boundary message (uses API-reported tokens)   │
│  └── Zero-cost on cache miss                                │
│                                                             │
│  Stage 4: Context Collapse [CONTEXT_COLLAPSE feature gate]  │
│  ├── Read-time projection over full history                 │
│  ├── Summary messages in collapse store (not REPL array)    │
│  ├── Persists across turns via commit log replay            │
│  ├── Runs BEFORE autocompact (cheaper, keeps granular ctx)  │
│  └── recoverFromOverflow on API 413 errors                  │
│                                                             │
│  Stage 5: Autocompact (autoCompact)                         │
│  ├── Full conversation summary via LLM call                 │
│  ├── Creates summary messages replacing full history        │
│  ├── Circuit breaker: consecutiveFailures tracking          │
│  ├── Resets turnCounter/turnId after compact                │
│  └── Carries task_budget remaining across compacts          │
└─────────────────────────────────────────────────────────────┘
```

### 1.1 Stage Details

#### Tool Result Budget
Each tool has a `maxResultSizeChars` limit. When exceeded, content is truncated. The `contentReplacementState` tracks these truncations so they persist across session resumes.

#### Snip (HISTORY_SNIP)
Snip removes old tool results that are unlikely to be needed. It preserves:
- Recent assistant messages
- Recent user messages
- Tool results referenced by recent messages
- Compact boundary markers

Returns `snipTokensFreed` which feeds into autocompact's threshold calculation.

#### Microcompact
Cache-editing compression modifies the API's cached prefix without sending a full new prompt. Uses `cache_deleted_input_tokens` from the API response to measure effectiveness. Only works when prompt cache is hit.

#### Context Collapse
A projection-based system that maintains summary messages in a separate store. `projectView()` replays the commit log on every entry. Archival is lazy — collapsed messages stay in the full history but are hidden from the API view.

#### Autocompact
The most aggressive compression. Calls a secondary LLM to summarize the full conversation:
- Input: All messages since last compact
- Output: Summary messages + attachments + hook results
- Cost: One LLM call (typically Haiku)
- Trigger: When token count exceeds threshold (adjusted by snipTokensFreed)

### 1.2 Reactive Compact

When the API returns a 413 (prompt_too_long) error:
1. **Withhold** the error from the stream
2. **Try context collapse drain** (cheapest recovery)
3. **Try reactive compact** (full summary + retry)
4. **Surface error** if both fail

### 1.3 Blocking Limit

When autocompact is OFF and context exceeds the hard limit:
```
calculateTokenWarningState(tokenCount - snipTokensFreed)
  → isAtBlockingLimit = true
  → Yield error, return { reason: 'blocking_limit' }
```

Skipped when:
- Compaction just happened
- Query source is `compact` or `session_memory` (would deadlock)
- Reactive compact is enabled and autocompact is on
- Context collapse owns the recovery

---

## 2. Persistent Memory System (memdir)

### 2.1 Architecture

Claude Code has a file-based persistent memory system:

```
~/.claude/projects/<cwd-slug>/memory/
├── MEMORY.md           ← Index file (max 200 lines, 25KB)
├── user_role.md        ← Individual memory files
├── feedback_testing.md
├── project_context.md
├── reference_api.md
└── ...
```

### 2.2 Memory Types

The memory taxonomy is a **closed four-type system**:

| Type | Description | Example |
|------|-------------|---------|
| `user` | User identity, preferences, communication style | "Prefers terse responses" |
| `feedback` | Corrections, behaviors to avoid/repeat | "Don't use `as any`" |
| `project` | Non-derivable project context (deadlines, decisions) | "Deploy to staging by Friday" |
| `reference` | Pointers to external systems, docs | "Dashboard at grafana.internal" |

**What NOT to save**:
- Code patterns (derivable from codebase)
- Architecture (derivable from codebase)
- Git history (derivable from `git log`)
- Anything derivable from current project state

### 2.3 Memory File Format

Each memory file uses frontmatter:

```markdown
---
name: User Role
description: The user is a senior backend engineer
type: user
---

[Memory content in markdown]
```

### 2.4 MEMORY.md Index

The `MEMORY.md` file is an **index**, not a memory itself:
- Max 200 lines, 25KB
- Each entry: `- [Title](file.md) — one-line hook`
- Truncated if exceeding limits with warning appended
- Always loaded into conversation context

### 2.5 Memory Loading

```
loadMemoryPrompt()
├── Check isAutoMemoryEnabled()
├── KAIROS mode → buildAssistantDailyLogPrompt()
├── Team memory enabled → buildCombinedMemoryPrompt()
└── Auto memory enabled → buildMemoryLines()
    ├── ensureMemoryDirExists() (idempotent mkdir)
    ├── Read MEMORY.md (truncate if needed)
    ├── Build type taxonomy instructions
    └── Return prompt string
```

### 2.6 Memory Prefetch

`startRelevantMemoryPrefetch()` fires **once per user turn**:
1. Scan memory directory for files relevant to current conversation
2. Run in parallel with the entire model API call
3. Results consumed non-blocking after tool execution
4. Filter out memories the model already Read/Wrote/Edited
5. Attach as memory attachment messages

### 2.7 Team Memory (TEAMMEM feature gate)

When enabled, adds a second memory directory:
```
~/.claude/projects/<cwd-slug>/memory/team/
├── MEMORY.md
└── ...
```

Both directories are available. Team memory syncs across team members.

### 2.8 KAIROS Daily Log Mode

In assistant (KAIROS) mode, memories use a **daily log** pattern instead of MEMORY.md:

```
~/.claude/projects/<cwd-slug>/memory/logs/2025/04/2025-04-16.md
```

- Append-only log entries
- Separate nightly `/dream` skill distills into MEMORY.md
- MEMORY.md is still loaded as the distilled index

---

## 3. Auto-Dream Consolidation

### 3.1 Overview

Auto-dream is a **background memory consolidation** system that fires as a forked subagent when conditions are met:

```
initAutoDream()  ← Called at startup
  → executeAutoDream()  ← Called after each turn (from stopHooks)
    → Gate checks (time, sessions, lock)
    → Fork subagent with consolidation prompt
    → Subagent reviews sessions, writes/updates memory files
```

### 3.2 Gate System (3 gates)

```
Gate 1: Time Gate
├── hours since lastConsolidatedAt >= minHours (default: 24h)
└── Cheapest: one stat() call

Gate 2: Session Gate
├── transcript count with mtime > lastConsolidatedAt >= minSessions (default: 5)
├── Excludes current session
├── Scan throttle: max once per 10 minutes
└── Moderate cost: directory listing

Gate 3: Lock Gate
├── No other process mid-consolidation
├── Uses file-based lock (consolidationLock)
├── Rollback on failure
└── File I/O
```

### 3.3 Configuration (tengu_onyx_plover)

```typescript
AutoDreamConfig = {
  minHours: 24,      // Hours between consolidations
  minSessions: 5,    // Minimum new sessions since last consolidation
}
```

### 3.4 Consolidation Process

1. Build consolidation prompt with:
   - Memory root path
   - Transcript directory
   - List of sessions since last consolidation
   - Tool constraints (read-only Bash)
2. Fork a subagent (`runForkedAgent`) with:
   - `querySource: 'auto_dream'`
   - `canUseTool: createAutoMemCanUseTool(memoryRoot)` — restricted permissions
   - `skipTranscript: true` — don't write to session transcript
3. Watch progress via `makeDreamProgressWatcher`:
   - Track text blocks (agent reasoning)
   - Count tool use blocks
   - Collect file paths from Edit/Write operations
4. On completion:
   - Complete DreamTask
   - Show inline completion summary
   - Log cache usage stats

### 3.5 Lock Management

```
tryAcquireConsolidationLock()
  ├── Check if lock file exists
  ├── If locked: return null (skip)
  ├── If not locked: create lock file, return priorMtime
  └── On failure: rollbackConsolidationLock(priorMtime)
```

### 3.6 Failure Handling

- **Abort**: If user kills from bg-tasks dialog, DreamTask.kill handles rollback
- **Fork failure**: Fail DreamTask, rollback lock mtime, scan throttle is the backoff
- **Session scan failure**: Silent return, try again next turn

---

## 4. Extract Memories

`extractMemories` is a separate system from auto-dream:

```
initExtractMemories()  ← Called at startup
  → executeExtractMemories()  ← Called after each turn
    → Check if turn produced memorable content
    → Write individual memory files
    → Show "Saved N memories" message
```

This runs **every turn** (not gated by time/sessions like auto-dream) and handles the user's explicit "remember this" requests.

---

## 5. Context Window Management

### 5.1 Token Tracking

```
tokenCountWithEstimation(messages)
  → Uses API-reported usage when available
  → Falls back to client-side estimation (~4 chars per token)
```

### 5.2 Warning States

```typescript
calculateTokenWarningState(tokenCount, model)
  → { isAtWarningLimit, isAtBlockingLimit }
```

### 5.3 Max Output Tokens Recovery

When `max_output_tokens` is hit:
1. **Escalate**: Retry at 64k output tokens (from default 8k)
2. **Recovery message**: "Output token limit hit. Resume directly — no apology, no recap..."
3. **Retry**: Up to 3 times
4. **Surface error**: After exhausting recovery attempts

### 5.4 Task Budget

API-side task budget tracks across compaction boundaries:
```typescript
taskBudget: {
  total: number,      // Total budget for the agentic turn
  remaining: number,  // Pre-compact remaining (calculated by subtracting final context)
}
```

After each compact, `taskBudgetRemaining` is updated by subtracting the pre-compact context window size.

---

## 6. Key Design Patterns

### 6.1 Cache-Safe Compression

Microcompact uses **cache editing** — modifying the API's cached prompt prefix without sending a full new prompt. This is orders of magnitude cheaper than a full prompt resend.

### 6.2 Progressive Aggression

The pipeline is ordered by cost:
1. Budget trimming (free — just truncation)
2. Snip (cheap — just removes old results)
3. Microcompact (cheap — cache edit)
4. Context collapse (moderate — projection-based)
5. Autocompact (expensive — full LLM call)
6. Reactive compact (very expensive — LLM call + retry)

### 6.3 Circuit Breaker

Autocompact tracks `consecutiveFailures` to prevent infinite retry loops:
```
if (consecutiveFailures > threshold) → skip autocompact, try other recovery
```

### 6.4 Non-Blocking Prefetch

Memory and skill prefetches run in parallel with the model API call, consuming zero additional latency when they complete before tool execution finishes.
