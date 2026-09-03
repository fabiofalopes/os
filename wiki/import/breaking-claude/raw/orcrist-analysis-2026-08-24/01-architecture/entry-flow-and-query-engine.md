# Entry Flow & Query Engine Deep Dive

> Complete code walkthrough of Claude Code v2.1.88's boot sequence, the QueryEngine class, and the `while(true)` tool loop in `query.ts`.

---

## 1. Boot Sequence — `main.tsx` (4,683 lines)

### 1.1 Module-Level Side Effects (Before `main()` runs)

The first ~200 lines of `main.tsx` fire **before** `main()` is even called. These are critical performance optimizations:

```
Lines 1-20: Module-evaluation-time side effects
├── profileCheckpoint('main_tsx_entry')      // Startup profiler mark
├── startMdmRawRead()                         // MDM subprocess (plutil/reg query) — parallel with imports
├── startKeychainPrefetch()                   // macOS keychain reads (OAuth + API key) — parallel with imports
└── ~135ms of remaining imports
```

**Key insight**: These side effects are explicitly marked with `// eslint-disable-next-line custom-rules/no-top-level-side-effects`. They fire during module evaluation, overlapping subprocess spawns with the remaining import chain.

### 1.2 Anti-Debug Protection

```typescript
// Line 266: Dead-code eliminated in 'ant' builds
if ("external" !== 'ant' && isBeingDebugged()) {
  process.exit(1);  // Kill process if debugger detected
}
```

The `"external"` string is a **build-time constant**. In internal 'ant' builds, this becomes `'ant' !== 'ant'` (always false → skip). In external builds, it's `'external' !== 'ant'` (always true → check for debuggers).

`isBeingDebugged()` checks:
- `process.execArgv` for `--inspect` / `--inspect-brk` flags
- `process.env.NODE_OPTIONS` for inspect flags
- `inspector.url()` — if the V8 inspector is active

### 1.3 The `main()` Function (Line 585)

```
main()
├── 1. Security: Set NoDefaultCurrentDirectoryInExePath (Windows PATH hijacking prevention)
├── 2. Initialize warning handler
├── 3. Process SIGINT handler
├── 4. Parse cc:// deep link URLs (DIRECT_CONNECT feature)
├── 5. Parse --handle-uri / macOS URL handler (LODESTONE feature)
├── 6. Parse 'assistant' subcommand (KAIROS feature)
├── 7. Parse 'ssh' subcommand (SSH_REMOTE feature)
├── 8. Determine interactive vs non-interactive mode
├── 9. Initialize entrypoint type (cli/sdk-cli/mcp/claude-code-github-action)
├── 10. Determine client type (cli/sdk-typescript/sdk-python/vscode/etc.)
├── 11. Eager-load settings flags (--settings, --setting-sources)
└── 12. await run()
```

### 1.4 The `run()` Function (Line 884)

```
run()
├── Create Commander program with sorted help config
├── Hook 'preAction' →
│   ├── await ensureMdmSettingsLoaded()
│   ├── await ensureKeychainPrefetchCompleted()
│   ├── await init()                    // Core initialization
│   ├── process.title = 'claude'
│   ├── initSinks()                     // Analytics logging sinks
│   ├── setInlinePlugins()              // Plugin directory setup
│   ├── runMigrations()                 // CURRENT_MIGRATION_VERSION = 11
│   ├── loadRemoteManagedSettings()     // Enterprise settings (non-blocking)
│   ├── loadPolicyLimits()              // Enterprise policy (non-blocking)
│   └── uploadUserSettingsInBackground() // Settings sync (non-blocking)
│
├── Define CLI options (~60+ flags)
│   ├── Standard: -p, --print, --model, --continue, --resume
│   ├── Hidden: --init, --init-only, --maintenance, --task-budget
│   ├── Feature-gated: --assistant (KAIROS), --worktree, --tmux
│   └── Expert: --bare, --settings, --mcp-config, --permission-mode
│
└── .action() handler (Line 1006) — the main session setup:
    ├── 1. Parse --bare mode (sets CLAUDE_CODE_SIMPLE=1)
    ├── 2. KAIROS assistant mode initialization
    ├── 3. Extract CLI options (tools, permissions, MCP, system prompts)
    ├── 4. Handle system prompt overrides (--system-prompt, --append-system-prompt)
    ├── 5. MCP config loading & enterprise policy filtering
    ├── 6. Claude in Chrome setup
    ├── 7. Computer Use MCP (CHICAGO_MCP, ant-only)
    ├── 8. Channel server configuration (KAIROS_CHANNELS)
    ├── 9. Permission mode initialization
    ├── 10. Tool permission context setup
    ├── 11. Deferred context prefetches (git status, user context)
    ├── 12. initBuiltinPlugins() + initBundledSkills()
    ├── 13. setup() — session initialization (CWD, worktree, etc.)
    │   └── Parallel: getCommands() + getAgentDefinitionsWithOverrides()
    ├── 14. Download file resources (--file flag)
    ├── 15. For interactive: showSetupScreens() → trust dialog
    ├── 16. For headless: runHeadless() → print.ts
    └── 17. For interactive: launchRepl() → REPL.tsx
```

### 1.5 Migration System

`CURRENT_MIGRATION_VERSION = 11` — sync migrations run once per version bump:

| Migration | Purpose |
|-----------|---------|
| `migrateAutoUpdatesToSettings` | Move auto-update config to settings.json |
| `migrateBypassPermissionsAcceptedToSettings` | Move bypass-permissions flag |
| `migrateEnableAllProjectMcpServersToSettings` | Move MCP enablement |
| `resetProToOpusDefault` | Reset Pro users to Opus default |
| `migrateSonnet1mToSonnet45` | Model name migration |
| `migrateLegacyOpusToCurrent` | Opus version migration |
| `migrateSonnet45ToSonnet46` | Sonnet version migration |
| `migrateOpusToOpus1m` | Opus model migration |
| `migrateReplBridgeEnabledToRemoteControlAtStartup` | Feature rename |
| `resetAutoModeOptInForDefaultOffer` | Auto-mode opt-in reset (TRANSCRIPT_CLASSIFIER) |
| `migrateFennecToOpus` | Internal model migration (ant-only) |

### 1.6 Deferred Prefetches (`startDeferredPrefetches`)

Called **after** first REPL render. Skipped in `--bare` mode and `CLAUDE_CODE_EXIT_AFTER_FIRST_RENDER`:

| Prefetch | Purpose | Cost |
|----------|---------|------|
| `initUser()` | User identity/subscription | Child process |
| `getUserContext()` | CLAUDE.md files, memory | Disk I/O |
| `getSystemContext()` | Git status, platform info | Child process (git) |
| `getRelevantTips()` | Onboarding tips | Disk I/O |
| `prefetchAwsCredentialsAndBedRockInfoIfSafe()` | Bedrock auth | AWS SDK |
| `prefetchGcpCredentialsIfSafe()` | Vertex auth | GCP SDK |
| `countFilesRoundedRg()` | File count for context display | ripgrep |
| `initializeAnalyticsGates()` | GrowthBook feature flags | Network |
| `prefetchOfficialMcpUrls()` | MCP registry URLs | Network |
| `refreshModelCapabilities()` | Model capability cache | Network |
| `settingsChangeDetector.initialize()` | Watch settings files | fs.watch |
| `skillChangeDetector.initialize()` | Watch skill files | fs.watch |

---

## 2. QueryEngine — `QueryEngine.ts` (1,295 lines)

### 2.1 Class Architecture

`QueryEngine` is the high-level orchestrator that wraps the `query()` generator. It manages:

- Message persistence (session transcript)
- User input processing (slash commands, interrupts)
- Tool permission context
- System prompt assembly
- Multi-turn conversation state

### 2.2 Key Methods

```
QueryEngine
├── constructor(options)
│   ├── Initialize message arrays
│   ├── Setup abort controller
│   ├── Configure tool pool
│   └── Setup message queue processing
│
├── submitMessage(userInput) → void
│   ├── Process slash commands (/compact, /clear, etc.)
│   ├── Create user message from input
│   ├── Enqueue message for processing
│   └── Trigger query cycle if idle
│
├── processUserInput(input) → Promise<void>
│   ├── Parse input (text, attachments, images)
│   ├── Handle interrupt signal
│   ├── Create UserMessage
│   └── Add to message history
│
├── runQueryCycle() → AsyncGenerator
│   ├── Assemble system prompt (5-layer priority)
│   ├── Build user context (CLAUDE.md files)
│   ├── Build system context (git status, platform)
│   ├── Call query() generator
│   ├── Yield messages to REPL/headless consumer
│   └── Persist messages to session transcript
│
└── persistMessages() → void
    └── Append to session JSONL file
```

### 2.3 Message Persistence

Session transcripts are stored as JSONL files:
- Location: `~/.claude/projects/<cwd-slug>/<session-id>.jsonl`
- Each line is a JSON-encoded message
- Messages include: type, content, timestamps, tool use results, attachments

---

## 3. The Core Tool Loop — `query.ts` (1,729 lines)

### 3.1 Architecture Overview

```
query(params) → AsyncGenerator<StreamEvent | Message>
└── queryLoop(params, consumedCommandUuids)
    └── while (true) { ... }  ← The heart of Claude Code
```

The `query()` function is an **async generator** — it yields messages as they arrive, allowing the REPL/headless consumer to process them incrementally.

### 3.2 State Object

```typescript
type State = {
  messages: Message[]                              // Full conversation history
  toolUseContext: ToolUseContext                    // Tool execution context
  autoCompactTracking: AutoCompactTrackingState    // Compaction state
  maxOutputTokensRecoveryCount: number             // Output limit retry counter
  hasAttemptedReactiveCompact: boolean             // Reactive compact guard
  maxOutputTokensOverride: number | undefined      // Escalated output limit
  pendingToolUseSummary: Promise<...> | undefined  // Async summary generation
  stopHookActive: boolean | undefined              // Stop hook state
  turnCount: number                                // Current turn number
  transition: Continue | undefined                 // Why the previous iteration continued
}
```

### 3.3 The Loop — Step by Step

```
while (true) {
  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 1: CONTEXT COMPRESSION PIPELINE                  ║
  ╚══════════════════════════════════════════════════════════╝

  1a. Apply tool result budget     — Trim oversized tool results
  1b. Apply snip (HISTORY_SNIP)    — Remove old low-value tool results
  1c. Apply microcompact            — Cache-editing compression
  1d. Apply context collapse        — Progressive context summarization
  1e. Apply autocompact             — Full conversation summary

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 2: BLOCKING CHECK                                ║
  ╚══════════════════════════════════════════════════════════╝

  2a. Check if context exceeds blocking limit
      → If yes and no recovery available: yield error, return

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 3: MODEL API CALL                                ║
  ╚══════════════════════════════════════════════════════════╝

  3a. Resolve model (permission mode, plan mode, 200k threshold)
  3b. Call deps.callModel() → streaming API response
      │
      ├── For each streamed message:
      │   ├── If tool_use block: collect for execution
      │   ├── If streaming tool executor: execute immediately
      │   ├── If error (prompt_too_long): withhold for recovery
      │   └── If max_output_tokens: withhold for recovery
      │
      ├── On FallbackTriggeredError:
      │   ├── Switch to fallback model
      │   ├── Clear accumulated messages
      │   ├── Strip thinking signatures (ant-only)
      │   └── Retry API call
      │
      └── On generic error:
          ├── Yield error messages for all pending tool_uses
          └── Return { reason: 'model_error' }

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 4: RECOVERY CHECKS (if no tool_use)              ║
  ╚══════════════════════════════════════════════════════════╝

  4a. Context collapse drain — drain staged collapses on prompt_too_long
  4b. Reactive compact — compact and retry on prompt_too_long
  4c. Max output tokens recovery:
      ├── First: escalate to 64k output tokens
      ├── Then: inject recovery message + retry (up to 3 times)
      └── Finally: surface the withheld error
  4d. Stop hooks — run user-defined hooks, maybe block/retry
  4e. Token budget check — continue if budget allows

  If none of these cause a `continue`, return { reason: 'completed' }

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 5: TOOL EXECUTION                                ║
  ╚══════════════════════════════════════════════════════════╝

  5a. Execute tools (streaming or batch):
      ├── StreamingToolExecutor: tools run as they're discovered
      └── runTools(): tools run after all streaming completes
  5b. Generate tool use summary (Haiku, async, non-blocking)
  5c. Handle aborts (Ctrl+C during tool execution)

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 6: POST-TOOL ATTACHMENTS                          ║
  ╚══════════════════════════════════════════════════════════╝

  6a. Drain queued commands (user prompts, task notifications)
  6b. Collect attachment messages (file changes, memory, skills)
  6c. Consume memory prefetch results
  6d. Inject skill discovery results
  6e. Generate periodic task summaries (for `claude ps`)

  ╔══════════════════════════════════════════════════════════╗
  ║  PHASE 7: CONTINUE                                      ║
  ╚══════════════════════════════════════════════════════════╝

  7a. Check maxTurns limit
  7b. Update state with new messages
  7c. Continue to next iteration (back to Phase 1)
}
```

### 3.4 The Rules of Thinking

From the code comments (line 151-163):

> *"The rules of thinking are lengthy and fortuitous. They require plenty of thinking of most long duration and deep meditation for a wizard to wrap one's noggin around."*

The three rules:
1. A message that contains a `thinking` or `redacted_thinking` block must be part of a query whose `max_thinking_length > 0`
2. A thinking block may not be the last message in a block
3. Thinking blocks must be preserved for the duration of an assistant trajectory (a single turn, or if that turn includes a `tool_use` block then also its subsequent `tool_result` and the following assistant message)

### 3.5 Fallback Model Strategy

When the primary model is overloaded (FallbackTriggeredError):

1. Switch to `fallbackModel`
2. Clear accumulated assistant messages and tool results
3. Discard streaming tool executor, create fresh one
4. Strip thinking signatures (ant-only) — protected-thinking blocks from one model cause 400 errors when replayed to another
5. Log the fallback event
6. Yield a system message about the switch
7. Retry the entire API call

### 3.6 Recovery Paths Summary

| Error | Recovery | Max Attempts |
|-------|----------|--------------|
| `prompt_too_long` | Context collapse drain → Reactive compact → Surface error | 1 each |
| `max_output_tokens` | Escalate to 64k → Recovery message + retry | 3 |
| `FallbackTriggered` | Switch to fallback model | 1 |
| Stop hook blocking | Retry with hook error messages | ∞ (until hooks pass) |
| Token budget exceeded | Continue with nudge message | Until budget exhausted |
| Image/media size error | Strip oversized media via reactive compact | 1 |

### 3.7 Streaming Tool Execution

The `StreamingToolExecutor` runs tools **as they're discovered during streaming**, rather than waiting for the entire response to complete:

```
Traditional:  Stream → [wait for end] → Execute all tools
Streaming:    Stream → Tool A discovered → Execute A → Stream continues → Tool B → Execute B
```

This significantly reduces latency for multi-tool responses.

### 3.8 Memory Prefetch

`startRelevantMemoryPrefetch()` fires once per user turn (before the loop starts). It:
- Scans the memory directory for relevant files
- Runs in parallel with the entire model API call
- Consumes results non-blocking after tool execution
- Uses `settledAt` to check if prefetch completed without blocking
- Filters out memories the model already Read/Wrote/Edited

### 3.9 Tool Use Summary

After tool execution completes, a summary is generated **asynchronously** by calling a Haiku model:

```
generateToolUseSummary({
  tools: toolInfoForSummary,
  signal: abortController.signal,
  isNonInteractiveSession,
  lastAssistantText,
})
```

This fires in the background and is consumed on the next iteration as `pendingToolUseSummary`.

---

## 4. QueryConfig — Snapshot of Immutable State

`buildQueryConfig()` captures all gates and settings once at loop entry:

```typescript
{
  sessionId,
  gates: {
    isAnt,
    streamingToolExecution,
    fastModeEnabled,
    emitToolUseSummaries,
    // ... more feature gates
  }
}
```

Feature gates are intentionally excluded from the snapshot — they're checked live each iteration since GrowthBook cache can update mid-session.

---

## 5. Key Performance Optimizations

### 5.1 Prompt Cache Stability

The tool pool is **sorted alphabetically** before being sent to the API. This ensures the system prompt's tool descriptions are in a deterministic order, maximizing cache hit rates:

```typescript
const byName = (a: Tool, b: Tool) => a.name.localeCompare(b.name)
return uniqBy(
  [...builtInTools].sort(byName).concat(allowedMcpTools.sort(byName)),
  'name',
)
```

### 5.2 Settings Path Content Hash

The `--settings` flag generates a content-hash-based temp file path instead of random UUID. This prevents cache invalidation from changing tool descriptions:

```typescript
settingsPath = generateTempFilePath('claude-settings', '.json', {
  contentHash: trimmedSettings,  // Hash of settings content
});
```

### 5.3 Parallel Startup

Multiple independent operations run in parallel:
- `setup()` + `getCommands()` + `getAgentDefinitionsWithOverrides()`
- `initUser()` + `getUserContext()` + `getSystemContext()` + `getRelevantTips()`
- `fetchClaudeAIMcpConfigsIfEligible()` + `getClaudeCodeMcpConfigs()`

### 5.4 Microcompact Cache Editing

The `CACHED_MICROCOMPACT` feature uses API-reported `cache_deleted_input_tokens` to measure compression effectiveness, rather than client-side estimates. This deferred boundary message is yielded after the API response.

---

## 6. Exit Reasons

The query loop terminates with these reasons:

| Reason | Trigger |
|--------|---------|
| `'completed'` | Normal completion (no tool_use, no hooks) |
| `'blocking_limit'` | Context too large, no compaction possible |
| `'prompt_too_long'` | API 413 error, recovery failed |
| `'image_error'` | Image size/resize error |
| `'model_error'` | Unhandled API error |
| `'aborted_streaming'` | User interrupted during streaming |
| `'aborted_tools'` | User interrupted during tool execution |
| `'max_turns'` | `--max-turns` limit reached |
| `'hook_stopped'` | Hook prevented continuation |
| `'stop_hook_prevented'` | Stop hook blocked the turn |
| `'token_budget_continuation'` | (Continues, doesn't exit) |
