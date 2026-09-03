# Claude Code Harness Architecture — Master Deconstruction

> Source: Claude Code v2.1.88 leaked source — 1,902 TypeScript files, 512K lines
> Location: `/home/fabio/research/claude-code-original/src/`
> Analysis date: 2026-04-10

---

## Table of Contents

1. [What Is a "Harness"?](#1-what-is-a-harness)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Boot Sequence](#3-boot-sequence)
4. [The Core Loop: QueryEngine](#4-the-core-loop-queryengine)
5. [System Prompt Pipeline](#5-system-prompt-pipeline)
6. [Tool System](#6-tool-system)
7. [Permission System](#7-permission-system)
8. [Context & Memory Management](#8-context--memory-management)
9. [Multi-Agent Orchestration](#9-multi-agent-orchestration)
10. [MCP Integration Layer](#10-mcp-integration-layer)
11. [Feature Flag Architecture](#11-feature-flag-architecture)
12. [Build & Dead Code Elimination](#12-build--dead-code-elimination)
13. [Key Takeaways for Harness Builders](#13-key-takeaways-for-harness-builders)

---

## 1. What Is a "Harness"?

In the LLM agent world, a **harness** is the software layer that sits between the user and the LLM. It's NOT the model itself — it's everything else:

```
User ↔ [HARNESS] ↔ LLM API
              │
              ├── System prompt construction
              ├── Tool definitions & execution
              ├── Permission & safety gates
              ├── Context window management
              ├── Memory & session persistence
              ├── Multi-agent orchestration
              ├── Streaming & error handling
              └── UI/UX layer
```

Claude Code is one of the most sophisticated harnesses ever built. The leaked source reveals exactly how Anthropic engineers solved every hard problem in agent design.

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLI Entry (main.tsx)                   │
│  Commander.js → Auth → MCP init → Settings → Feature flags │
│                    ↓                                     │
│              REPL (React/Ink terminal UI)                │
│                    ↓                                     │
│               QueryEngine (core loop)                    │
│         ┌──────────┼──────────┐                         │
│         ↓          ↓          ↓                         │
│   System Prompt  Tool System  Context Manager           │
│   Pipeline       Registry     (compact/memory)          │
│         │          │          │                         │
│         └──────────┼──────────┘                         │
│                    ↓                                     │
│              Claude API (messages.create)                │
│                    ↓                                     │
│         Stream Response → Parse Tool Use                │
│                    ↓                                     │
│         Permission Check → Execute Tool → Return Result │
│                    ↓                                     │
│         Feed result back → Continue tool loop            │
│                    ↓                                     │
│         Final text response → Display to user            │
└─────────────────────────────────────────────────────────┘
```

### Codebase Scale

| File | Lines | Purpose |
|------|------:|---------|
| `main.tsx` | 4,683 | CLI entry, Commander.js setup, session orchestration |
| `query.ts` | 1,729 | Core query loop, tool execution, message management |
| `QueryEngine.ts` | 1,295 | Engine class wrapping the query loop, streaming, retry |
| `Tool.ts` | 792 | Base tool types, schemas, execution interface |
| `commands.ts` | 754 | Slash command registry (50+ public, 15 hidden, 25 internal) |
| `setup.ts` | 477 | Session initialization, UDS messaging, git worktrees |
| `tools.ts` | 389 | Tool pool assembly, getAllBaseTools() |
| `constants/prompts.ts` | 914 | System prompt construction (all sections) |

### Directory Map

```
src/
├── main.tsx              (4,683 lines — the monolith entry point)
├── QueryEngine.ts        (1,295 lines — core LLM loop wrapper)
├── query.ts              (1,729 lines — the actual query loop)
├── Tool.ts               (792 lines — tool type system)
├── tools.ts              (389 lines — tool pool assembly)
├── commands.ts           (754 lines — slash command registry)
├── setup.ts              (477 lines — session init)
│
├── tools/                (184 files, 38 directories — every tool)
│   ├── BashTool/
│   ├── FileReadTool/
│   ├── FileEditTool/
│   ├── FileWriteTool/
│   ├── GlobTool/
│   ├── GrepTool/
│   ├── AgentTool/
│   ├── WebFetchTool/
│   ├── LSPTool/
│   └── ... (30+ more)
│
├── constants/            (21 files — system prompt, betas, config)
│   ├── prompts.ts        (914 lines — THE system prompt)
│   ├── betas.ts          (beta headers for API)
│   └── systemPromptSections.ts
│
├── utils/                (564 files — utilities, permissions, auth)
├── components/           (389 files — React/Ink UI components)
├── services/             (130 files — MCP, analytics, compact, dream)
├── hooks/                (104 files — React hooks, permission checks)
├── coordinator/          (multi-agent orchestration)
├── memdir/               (persistent memory system)
├── buddy/                (Tamagotchi companion)
├── assistant/            (KAIROS daemon mode)
├── bridge/               (IDE integration)
├── voice/                (voice input)
├── vim/                  (full vim emulation)
└── ... (37 total directories)
```

---

## 3. Boot Sequence

### Phase 1: Pre-import Side Effects (before ANY module loads)
```typescript
// main.tsx lines 1-20
profileCheckpoint('main_tsx_entry')     // Performance profiling
startMdmRawRead()                        // Fire MDM subprocess (parallel)
startKeychainPrefetch()                  // Fire keychain reads (parallel)
```
These run as side-effect imports — they fire subprocess reads BEFORE the 135ms of module imports complete.

### Phase 2: Commander.js CLI Parsing
```typescript
// main.tsx ~line 150+
const program = new CommanderCommand('claude')
  .description('...')
  .argument('[prompt]', '...')
  .option('-p, --print', '...')
  .option('-c, --continue', '...')
  .option('-r, --resume', '...')
  .option('--model <model>', '...')
  .option('--system-prompt <prompt>', '...')
  .option('--allowedTools <tools>', '...')
  .option('--disallowedTools <tools>', '...')
  .option('--max-turns <n>', '...')
  .option('--permission-mode <mode>', '...')
  // ... 40+ more options
```

### Phase 3: Initialization (parallel)
```typescript
// Fired in parallel:
await Promise.all([
  init(),                              // Auth, settings, telemetry
  initializeGrowthBook(),              // Feature flags
  loadRemoteManagedSettings(),         // Enterprise remote config
  loadPolicyLimits(),                  // Usage policy
  prefetchFastModeStatus(),            // Fast mode check
  prefetchAwsCredentialsIfSafe(),      // AWS Bedrock
  prefetchGcpCredentialsIfSafe(),      // Google Vertex
  prefetchOfficialMcpUrls(),           // MCP registry
  prefetchPassesEligibility(),         // Subscription checks
])
```

### Phase 4: Session Setup
```typescript
setup(cwd, permissionMode, allowDangerously, worktreeEnabled, ...)
  → Node.js version check (>=18)
  → UDS messaging server (Unix Domain Sockets for teammates)
  → Git worktree setup
  → Terminal backup checks (macOS Terminal/iTerm2)
  → Session memory initialization
  → Hooks configuration snapshot
  → File changed watcher
```

### Phase 5: MCP Server Startup
```typescript
getMcpToolsCommandsAndResources(mcpConfigs)
  → Parse MCP configs (project + user + enterprise)
  → Start MCP servers (stdio/SSE)
  → Discover tools, commands, resources
  → Filter by policy
```

### Phase 6: Tool Pool Assembly
```typescript
getTools(permissionMode, mcpTools, enabledFeatures, agentDefs)
  → getAllBaseTools() — 40+ built-in tools
  → Add MCP tools
  → Add synthetic output tool
  → Filter by permission mode
  → Filter by feature flags
```

### Phase 7: REPL Launch
```typescript
launchRepl(config)
  → React/Ink terminal renderer
  → AppState initialization
  → User input capture
  → First prompt ready
```

---

## 4. The Core Loop: QueryEngine

The heart of Claude Code is the **tool loop** — a cycle that continues until the LLM stops requesting tools:

```
User Message → Build System Prompt → Call Claude API (stream)
    ↓
Parse Stream → Text blocks? → Display to user
    ↓
Tool Use blocks? → Permission check → Execute tool → Feed result back
    ↓
Continue calling API with tool results → Repeat until no more tool_use
    ↓
Final text response → Display → Check auto-compact → Save session
```

### QueryEngine Architecture (from QueryEngine.ts)

```typescript
class QueryEngine {
  config: QueryEngineConfig
  mutableMessages: Message[]
  abortController: AbortController
  
  async *submitMessage(prompt, options): AsyncGenerator<SDKMessage> {
    // 1. Build system prompt (5-layer priority)
    const { defaultSystemPrompt, userContext, systemContext } = 
      await fetchSystemPromptParts(...)
    
    // 2. Determine model & thinking config
    const model = userSpecifiedModel || getMainLoopModel()
    const thinkingConfig = shouldEnableThinkingByDefault() 
      ? { type: 'adaptive' } 
      : { type: 'disabled' }
    
    // 3. Add user message to conversation
    this.mutableMessages.push(createUserMessage(prompt))
    
    // 4. Call query() — the actual API loop
    yield* query({
      systemPrompt, userContext, systemContext,
      messages: this.mutableMessages,
      tools, commands, mcpClients,
      canUseTool: wrappedCanUseTool,
      thinkingConfig, model,
      // ... 20+ more config options
    })
  }
}
```

### The query() Function (query.ts — 1,729 lines)

This is where the actual LLM interaction happens. Key flow:

1. **Build API messages** — normalize messages for Anthropic API format
2. **Call `messages.create(stream: true)`** — streaming API call
3. **Parse stream events**:
   - `content_block_start` → begin text or tool_use
   - `content_block_delta` → accumulate text or tool input
   - `content_block_stop` → complete block
4. **If tool_use block completed**:
   - Find tool in registry by name
   - Run permission check (`canUseTool()`)
   - If allowed → execute tool → create tool_result message
   - If denied → create error message → continue loop
5. **Continue calling API** with accumulated messages + tool results
6. **When no more tool_use**: final text response → yield to UI

### Key Configuration

```typescript
type QueryEngineConfig = {
  cwd: string
  tools: Tools
  commands: Command[]
  mcpClients: MCPServerConnection[]
  agents: AgentDefinition[]
  canUseTool: CanUseToolFn
  customSystemPrompt?: string
  appendSystemPrompt?: string
  userSpecifiedModel?: string
  thinkingConfig?: ThinkingConfig
  maxTurns?: number
  maxBudgetUsd?: number
  taskBudget?: { total: number }
  jsonSchema?: Record<string, unknown>
  verbose?: boolean
  // ... more
}
```

---

## 5. System Prompt Pipeline

**See full analysis**: [`02-prompts/system-prompt-architecture.md`](./02-prompts/system-prompt-architecture.md)

### 5-Layer Priority
```
P0: Override   → Complete replacement (loop mode, testing)
P1: Coordinator → Multi-worker orchestration
P2: Agent       → Subagent/built-in agent (in proactive: append; else: replace)
P3: Custom      → --system-prompt flag
P4: Default     → Standard Claude Code prompt
```

### Cache Boundary
```
[STATIC — cached globally]     ← Can use scope:'global'
__SYSTEM_PROMPT_DYNAMIC_BOUNDARY__
[DYNAMIC — per-session]        ← Recomputed each turn
```

### Default Prompt Structure (9 sections)
1. Identity + Cyber Risk Instruction
2. System Rules
3. Doing Tasks (core behavioral rules)
4. Executing Actions with Care
5. Using Your Tools
6. Tone and Style
7. Output Efficiency
8. === BOUNDARY ===
9. Dynamic: Session guidance, Memory, Env, Language, MCP, Scratchpad, etc.

---

## 6. Tool System

### Tool Registry (40+ tools)

```
FileOps:     Read, Edit, Write, Glob, Grep
Execution:   Bash, PowerShell, REPL
Web:         WebFetch, WebSearch, WebBrowser
Search:      Glob, Grep, LSP (Language Server)
Agent:       AgentTool (spawn subagents)
Task:        TaskCreate, TaskGet, TaskList, TaskUpdate, TaskOutput, TaskStop
Team:        SendMessage, TeamCreate, TeamDelete
Memory:      TodoWrite
MCP:         ListMcpResources, ReadMcpResource, MCPTool
UI:          AskUserQuestion
Plan:        EnterPlanMode, ExitPlanMode
Utility:     Sleep, Snip, Brief, Skill, ToolSearch, NotebookEdit
Internal:    ConfigTool, TungstenTool, SyntheticOutputTool
```

### Tool Type System (from Tool.ts)
Every tool defines:
- `name` — unique identifier
- `inputSchema` — JSON Schema for inputs
- `prompt` — description shown to LLM in tool definitions
- `execute()` — the actual implementation
- `canUse()` — permission check (optional override)
- `riskLevel` — LOW, MEDIUM, HIGH

### Tool Execution Flow
```
LLM returns tool_use block
    ↓
Parse: { id, name, input }
    ↓
Find tool in registry
    ↓
canUseTool() → Permission check
    ↓ ALLOW          ↓ DENY
Execute tool        Create error message
    ↓               ↓
Create tool_result  Feed back to LLM
    ↓
Feed back to LLM → Continue loop
```

---

## 7. Permission System

### 4 Permission Modes
| Mode | Behavior |
|------|----------|
| **Default** | Interactive prompts for each tool call |
| **Plan** | Read-only — no writes without explicit approval |
| **Auto** | ML-based auto-approval (YOLO classifier) |
| **Bypass** | Skip all checks (requires special auth) |

### Risk Classification
| Level | Auto-Allow | Examples |
|-------|-----------|----------|
| 0 (LOW) | Always | Read, Glob, Grep, LSP, TaskGet |
| 1 (MEDIUM) | First-time confirm | Write, Edit, WebFetch, Bash (safe) |
| 2 (HIGH) | Every-time confirm | Bash (dangerous: rm, git push, chmod) |
| 3 (BLOCK) | Block + warn | rm -rf /, git push --force main, DROP TABLE |

### Protected Files (auto-edit blocked)
`.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`

### 6-Layer Permission Stack
```
1. Config allowlist — project and user settings
2. Auto-mode classifier — ML determines if safe for autonomous execution
3. Coordinator gate — validates against orchestration layer
4. Swarm worker gate — checks permissions for sub-agent execution
5. Bash classifier — analyzes shell commands for safety (23 checks)
6. Interactive user prompt — final human confirmation
```

---

## 8. Context & Memory Management

### Context Window Management
```
Total context: 200,000 tokens
Auto-compact trigger: ~167,000 tokens (200K - 20K output - 13K buffer)
Manual compact buffer: 3,000 tokens
Default max_output: 8,000 tokens (escalates to 64,000)
```

### Memory Hierarchy
```
~/.claude/CLAUDE.md          → Global user instructions (loaded every request)
project/CLAUDE.md            → Project-level instructions
.claude/CLAUDE.md            → Directory-level instructions
    ↓
MEMORY.md                    → Session memory (loaded into dynamic section)
    ↓
memdir/                      → Persistent memory files (topic-based)
    ↓
autoDream/                   → Background consolidation (dream system)
```

### The Dream System
- **Trigger**: 24 hours + 5 sessions + lock acquired (all 3 must pass)
- **4 Phases**: Orient → Gather → Consolidate → Prune
- **Constraints**: Read-only bash — cannot modify project
- **Purpose**: Reflective memory consolidation between sessions

### Auto-Compact
When context approaches limits:
1. Summarize conversation so far
2. Keep recent messages + system prompt
3. Replace old messages with summary
4. Restore up to 5 files (5K tokens each) post-compact

---

## 9. Multi-Agent Orchestration

### Coordinator Mode
```
Coordinator (main thread)
    ├── Worker 1 (parallel) — Research
    ├── Worker 2 (parallel) — Research
    └── Worker 3 (parallel) — Research
    ↓
Coordinator synthesizes → Creates implementation specs
    ↓
    ├── Worker 4 — Implement spec A
    └── Worker 5 — Implement spec B
    ↓
    ├── Worker 6 — Verify A
    └── Worker 7 — Verify B
```

### Agent Tool (Subagents)
- Spawns fresh context (isolated from parent)
- Can use different model (`CLAUDE_CODE_SUBAGENT_MODEL`)
- Can run in git worktree (isolated filesystem)
- Reports back via concise text summary

### Fork Subagents
- Background execution — doesn't block main context
- Tool output stays OUT of parent context
- Parent can continue chatting with user while fork works

### Agent Teams/Swarm
- In-process teammates via `AsyncLocalStorage`
- Process-based teammates via tmux/iTerm2
- Team memory synchronization
- Color assignments for visual distinction

---

## 10. MCP Integration Layer

MCP (Model Context Protocol) servers extend Claude Code's capabilities:

```
MCP Config Sources:
1. Project: .claude/mcp.json
2. User: ~/.claude/mcp.json
3. Enterprise: managed settings
4. Claude.ai: synced MCP configs
5. Official registry: auto-discovered
```

MCP tools are injected into:
- Tool pool (available to LLM)
- System prompt (MCP server instructions section)
- Command registry (MCP-exposed slash commands)

---

## 11. Feature Flag Architecture

### Compile-Time Flags (bun:bundle feature())
```typescript
feature('KAIROS')           → Autonomous daemon
feature('BUDDY')            → Companion pet
feature('COORDINATOR_MODE') → Multi-agent
feature('VOICE_MODE')       → Voice I/O
feature('DAEMON')           → Background daemon
feature('NATIVE_CLIENT_ATTESTATION') → Client verification
// 80+ more flags
```

### Runtime Flags (GrowthBook, tengu_* obfuscated)
```
tengu_frond_boric       → Analytics killswitch
tengu_slate_prism        → Connector text summarization
tengu_amber_json_tools   → Token-efficient tool format
tengu_penguins_off       → Fast mode killswitch
// 50+ more gates
```

### Obfuscation Pattern
Runtime flags use `tengu_` + random word pairs to hide purpose:
```typescript
// Not: tengu_analytics_enabled
// But: tengu_frond_boric (deliberately meaningless)
```

---

## 12. Build & Dead Code Elimination

### How It Works
`process.env.USER_TYPE === 'ant'` is a **build-time `--define`**. The Bun bundler:
1. Constant-folds the check to `false` in external builds
2. Eliminates all ant-only branches
3. Removes entire modules via lazy `require()` + `feature()` guard

```typescript
// External build: feature('KAIROS') → false → entire module eliminated
const assistantModule = feature('KAIROS')
  ? require('./assistant/index.js')
  : null  // ← external builds get null

// External build: undercover.ts → every function returns '' or false
export function isUndercover(): boolean {
  if (process.env.USER_TYPE === 'ant') { /* ELIMINATED */ }
  return false  // ← all that remains in external builds
}
```

### 108 Modules Eliminated from External Builds
The npm build contains ~1,900 files. The internal monorepo has ~2,000+ — 108 modules are dead-code-eliminated, including:
- Entire `proactive/` directory (KAIROS)
- Entire `voice/` pipeline
- Entire `buddy/` system
- `coordinator/` orchestration
- `services/autoDream/` consolidation
- `services/skillSearch/`
- Internal-only tools and commands

---

## 13. Key Takeaways for Harness Builders

### 1. The System Prompt Is Everything
Claude Code's prompt is 914 lines of carefully engineered instructions covering identity, behavioral rules, tool usage, tone, safety, and efficiency. Every section has been A/B tested.

### 2. The Tool Loop Is the Core Pattern
```
LLM decides → Harness executes → Result feeds back → LLM decides again
```
The LLM is the "brain"; the harness is the "body". The `while(true)` tool loop in `query.ts` is the heartbeat.

### 3. Permission System Enables Autonomy
The 4-mode permission system (default → plan → auto → bypass) lets users trade safety for speed. The ML-based YOLO classifier enables true autonomous operation.

### 4. Context Management Is the Hardest Problem
- 200K token window
- Auto-compact at 167K
- Memory hierarchy (CLAUDE.md → MEMORY.md → memdir → dream)
- Cache boundary for prompt optimization
- This is where most harness implementations fail

### 5. Feature Flags Enable Gradual Rollout
Compile-time + runtime flags let Anthropic ship code that's dormant. KAIROS, BUDDY, Coordinator — all fully built, all hidden behind flags.

### 6. The Harness Is Model-Agnostic Architecture
While optimized for Claude, the architecture patterns (tool loop, prompt pipeline, context management, permission system) work with ANY LLM. The harness doesn't need Claude — Claude needs the harness.

### 7. MCP Is the Extension Mechanism
Instead of hardcoding every capability, MCP provides a plugin architecture. Tools, commands, resources — all extensible via MCP servers.

### 8. Multi-Agent Is System-Prompt Engineering
The coordinator mode doesn't use a special API — it uses a carefully crafted system prompt that teaches the LLM how to orchestrate workers. The "multi-agent" is really "multi-turn with parallel tool calls."

---

## File Index for Detailed Analysis

### Core Systems
| Document | Location | Lines |
|----------|----------|------:|
| System Prompt Architecture | `02-prompts/system-prompt-architecture.md` | 514 |
| Entry Flow & Query Engine | `01-architecture/entry-flow-and-query-engine.md` | 458 |
| Tool System Complete | `03-tools/tool-system-complete.md` | 470 |
| Permission System | `04-permissions/permission-system.md` | 304 |
| Context & Memory | `05-context-memory/context-and-memory.md` | 364 |
| Multi-Agent Orchestration | `06-multi-agent/multi-agent-orchestration.md` | 377 |

### Infrastructure & Integration
| Document | Location | Lines |
|----------|----------|------:|
| Commands Complete | `07-commands/commands-complete.md` | 275 |
| Feature Flags Complete | `08-feature-flags/feature-flags-complete.md` | 208 |
| MCP Integration | `09-mcp/mcp-integration.md` | 213 |
| Misc Systems (Buddy, Telemetry, etc.) | `11-misc/misc-systems.md` | 278 |

### Extended Analysis (Session 2)
| Document | Location | Lines |
|----------|----------|------:|
| **Cost Tracking & Billing** | `12-cost-tracking/cost-tracking.md` | 428 |
| Pricing tiers, rate limiting, overage, policy limits, token estimation | | |
| **Remote Session Control** | `13-remote/remote-control.md` | 245 |
| WebSocket sessions, CCR containers, permission bridge, SDK message adapter | | |
| **TUI Architecture** | `14-tui/tui-architecture.md` | 321 |
| React/ink stack, component hierarchy, REPL monolith, design system, DCE | | |
| **Assistant Daemon & History** | `15-assistant/assistant-daemon.md` | 233 |
| Prompt history (JSONL), session events (API), daemon mode, paste storage | | |

### Deep Analysis (Session 3)
| Document | Location | Lines |
|----------|----------|------:|
| **Resilience & Retry** | `16-resilience/retry-error-handling.md` | 373 |
| AsyncGenerator retry engine, error classification, graceful shutdown, unattended mode | | |
| **Streaming Architecture** | `17-streaming/streaming-architecture.md` | ~400 |
| SSE event parsing, tool use detection mid-stream, thinking blocks, partial message state, watchdog | | |
| **Provider Abstraction** | `18-api-client/provider-abstraction.md` | 230 |
| 4-provider architecture (first-party/Bedrock/Vertex/Azure), auth, client factory, model resolution | | |
| **Hook System Architecture** | `19-hooks/tool-hooks.md` | ~400 |
| 25+ hook event types, 4 execution modes (shell/callback/HTTP/agent), async hooks, JSON protocol, Zod validation | | |
| **Session Lifecycle** | `20-session/session-lifecycle.md` | ~400 |
| JSONL append-only storage, parentUuid chain, buffered write queue, title generation, tombstoning | | |
| **Configuration & Settings** | `21-config/settings-hierarchy.md` | ~400 |
| CLAUDE.md 4-tier hierarchy, @include directives, frontmatter globs, 5-source settings merge, policy settings | | |
| **Message Type System** | `22-messages/message-type-system.md` | ~350 |
| Full message taxonomy, normalization pipeline, tool use/result pairing, UI reordering, tombstones | | |
| **IDE Integration** | `23-ide/ide-integration.md` | ~250 |
| Lockfile discovery, VS Code/JetBrains MCP channel, ancestor PID walking, WSL path conversion | | |
| **Sandbox Architecture** | `24-sandbox/sandbox-architecture.md` | ~250 |
| @anthropic-ai/sandbox-runtime adapter, FS restriction translation, swarm permission sync, violation tracking | | |
| **Architectural Patterns** | `25-patterns/architectural-patterns.md` | ~500 |
| WeakRef abort hierarchy, Zod everywhere, generator-based architecture, telemetry pipeline, caching | | |
