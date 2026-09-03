# Tool System — Complete Reference

> Every tool in Claude Code v2.1.88, its schema, prompt, execution logic, feature gates, and access control.

---

## 1. Tool Architecture

### 1.1 Tool Type System (`Tool.ts`, 792 lines)

```typescript
type Tool = {
  name: string                           // Unique identifier
  description: string                    // Prompt description for the model
  inputSchema: ToolInputJSONSchema       // JSON Schema for tool inputs
  execute(params, context): Promise<ToolResult>
  isEnabled?(): boolean                  // Feature gate check
  maxResultSizeChars?: number            // Budget for tool output
  backfillObservableInput?(input): void  // Expand paths for SDK stream
  validateInput?(input): string | null   // Pre-execution validation
}
```

### 1.2 Tool Registration (`tools.ts`, 389 lines)

The tool pool is assembled in a strict pipeline:

```
getAllBaseTools()
  → Filter by deny rules (filterToolsByDenyRules)
  → Filter by isEnabled()
  → getTools(permissionContext)  [built-in only]
  → assembleToolPool(permissionContext, mcpTools)  [built-in + MCP]
    → Sort built-ins alphabetically (cache stability)
    → Sort MCP tools alphabetically
    → Dedup by name (built-in wins)
```

### 1.3 Tool Access Control Tiers

| Tier | Tools | Who Gets It |
|------|-------|-------------|
| **Simple mode** (`CLAUDE_CODE_SIMPLE`) | Bash, Read, Edit (+ Agent/TaskStop for coordinator) | `--bare` mode |
| **Default** | All enabled built-in tools | Normal sessions |
| **Async agent** | Read, WebSearch, TodoWrite, Grep, WebFetch, Glob, Bash/Edit/Write, NotebookEdit, Skill, ToolSearch, Worktree tools | Spawned subagents |
| **In-process teammate** | Async agent + Task CRUD + SendMessage + Cron tools | tmux teammates |
| **Coordinator** | Agent, TaskStop, SendMessage, SyntheticOutput | Coordinator mode |

---

## 2. Complete Tool Catalog

### 2.1 Core Tools (Always Available)

#### `Bash` (BashTool)
- **Purpose**: Execute shell commands
- **Feature Gate**: None (always available)
- **Key Parameters**: `command`, `timeout`, `run_in_background`, `description`
- **Special Behaviors**:
  - Sandbox support (Docker/gVisor)
  - 23 security checks on commands
  - Background task execution
  - Git commit/PR instructions embedded in description
  - Undercover mode instructions (ant-only)
  - Timeout: configurable, default 2 minutes
- **Prompt**: 369 lines — includes git workflow, attribution text, security rules

#### `Read` (FileReadTool)
- **Purpose**: Read file contents
- **Key Parameters**: `file_path`, `offset`, `limit`
- **Special Behaviors**:
  - Line-numbered output
  - Offset/limit for partial reads
  - Image and PDF support
  - Max 2000 lines per read
  - Truncation for lines > 2000 chars

#### `Edit` (FileEditTool)
- **Purpose**: String replacement in files
- **Key Parameters**: `file_path`, `old_string`, `new_string`, `replace_all`
- **Special Behaviors**:
  - Exact string matching (not regex)
  - Fail on multiple matches (unless `replace_all`)
  - Must read file before editing
  - Creates backup snapshots

#### `Write` (FileWriteTool)
- **Purpose**: Create or overwrite files
- **Key Parameters**: `file_path`, `content`
- **Special Behaviors**:
  - Creates parent directories
  - Must read existing files before overwriting
  - Not allowed for directories

#### `Glob` (GlobTool)
- **Purpose**: Fast file pattern matching
- **Key Parameters**: `pattern`, `path`
- **Feature Gate**: Excluded when embedded search tools (bfs/ugrep) are in binary
- **Note**: Ant-native builds alias find/grep in shell, making this tool unnecessary

#### `Grep` (GrepTool)
- **Purpose**: Content search with regex
- **Key Parameters**: `pattern`, `path`, `include`, `output_mode`
- **Feature Gate**: Excluded when embedded search tools present
- **Output Modes**: `content`, `files_with_matches`, `count`

#### `WebFetch` (WebFetchTool)
- **Purpose**: Fetch and parse web content
- **Key Parameters**: `url`, `format`, `timeout`
- **Formats**: `markdown`, `text`, `html`

#### `WebSearch` (WebSearchTool)
- **Purpose**: Search the web
- **Key Parameters**: `query`, `numResults`

### 2.2 Agent & Orchestration Tools

#### `Agent` (AgentTool)
- **Purpose**: Spawn subagents for parallel work
- **Feature Gate**: None (always available, blocked from subagents for non-ant)
- **Key Parameters**: `description`, `prompt`, `subagent_type`, `model`
- **Subagent Types**: `"general"`, `"worker"` (coordinator mode)
- **Special Behaviors**:
  - Creates forked agent with own context
  - Returns `task_id` for continuation
  - Blocked from recursion (except ant internal agents)
  - Model override support

#### `SendMessage` (SendMessageTool)
- **Purpose**: Continue an existing agent with follow-up
- **Key Parameters**: `to` (agent ID), `message`
- **Feature Gate**: Lazy-loaded to break circular dependency

#### `TaskOutput` (TaskOutputTool)
- **Purpose**: Get output from a completed agent
- **Key Parameters**: `task_id`
- **Blocked in subagents**: Prevents recursion

#### `TaskStop` (TaskStopTool)
- **Purpose**: Stop a running agent
- **Key Parameters**: `task_id`

### 2.3 Task Management Tools (TodoV2)

Feature gate: `isTodoV2Enabled()`

#### `TaskCreate`
- **Parameters**: `title`, `description`, `status`, `priority`

#### `TaskGet`
- **Parameters**: `task_id`

#### `TaskList`
- **Parameters**: Filters and pagination

#### `TaskUpdate`
- **Parameters**: `task_id`, `status`, `priority`, etc.

### 2.4 Plan Mode Tools

#### `EnterPlanMode` (EnterPlanModeTool)
- **Purpose**: Enter plan-only mode (read-only tools)
- **Note**: Plan mode restricts available tools to read-only operations

#### `ExitPlanModeV2` (ExitPlanModeTool)
- **Purpose**: Exit plan mode back to normal execution

### 2.5 Memory & Persistence Tools

#### `TodoWrite` (TodoWriteTool)
- **Purpose**: Create/update todo lists
- **Key Parameters**: `todos` (array of {content, status, priority})
- **Note**: Original todo system, still available alongside TaskCreate

#### `Skill` (SkillTool)
- **Purpose**: Execute slash commands / skills
- **Key Parameters**: `name`, `arguments`

### 2.6 MCP Tools

#### `ListMcpResources` (ListMcpResourcesTool)
- **Purpose**: List available MCP resources

#### `ReadMcpResource` (ReadMcpResourceTool)
- **Purpose**: Read a specific MCP resource

#### `ToolSearch` (ToolSearchTool)
- **Purpose**: Search for tools when tool pool is too large
- **Feature Gate**: `isToolSearchEnabledOptimistic()`
- **Used when**: Total tool descriptions exceed token budget

### 2.7 Feature-Gated Tools

#### `Sleep` (SleepTool)
- **Feature Gate**: `PROACTIVE` or `KAIROS`
- **Purpose**: Wait for notifications/events
- **Note**: Only for long-lived assistant sessions

#### `Brief` (BriefTool)
- **Purpose**: Send user message (KAIROS mode)
- **Feature Gate**: `KAIROS` or `KAIROS_BRIEF`
- **Requires opt-in**: `--tools SendUserMessage`

#### `SendUserFile` (SendUserFileTool)
- **Feature Gate**: `KAIROS`
- **Purpose**: Send file to user in assistant mode

#### `PushNotification` (PushNotificationTool)
- **Feature Gate**: `KAIROS` or `KAIROS_PUSH_NOTIFICATION`
- **Purpose**: Send push notification to user

#### `SubscribePR` (SubscribePRTool)
- **Feature Gate**: `KAIROS_GITHUB_WEBHOOKS`
- **Purpose**: Subscribe to GitHub PR events

### 2.8 Cron & Trigger Tools

#### `CronCreate`, `CronDelete`, `CronList` (ScheduleCronTool)
- **Feature Gate**: `AGENT_TRIGGERS`
- **Purpose**: Schedule recurring agent executions

#### `RemoteTrigger` (RemoteTriggerTool)
- **Feature Gate**: `AGENT_TRIGGERS_REMOTE`
- **Purpose**: Register HTTP webhook triggers for agents

### 2.9 Worktree Tools

#### `EnterWorktree`, `ExitWorktree`
- **Feature Gate**: `isWorktreeModeEnabled()`
- **Purpose**: Git worktree management for parallel work

### 2.10 Team Management Tools

#### `TeamCreate` (TeamCreateTool)
- **Feature Gate**: `isAgentSwarmsEnabled()`
- **Purpose**: Create a team of agents in tmux

#### `TeamDelete` (TeamDeleteTool)
- **Feature Gate**: `isAgentSwarmsEnabled()`
- **Purpose**: Disband an agent team

### 2.11 Ant-Only Tools

#### `REPL` (REPLTool)
- **Feature Gate**: `USER_TYPE === 'ant'`
- **Purpose**: Full REPL environment (REPL mode wraps Bash/Read/Edit)

#### `Config` (ConfigTool)
- **Feature Gate**: `USER_TYPE === 'ant'`
- **Purpose**: Manage Claude Code configuration

#### `Tungsten` (TungstenTool)
- **Feature Gate**: `USER_TYPE === 'ant'`
- **Purpose**: Virtual terminal interaction (conflicts between agents)

#### `SuggestBackgroundPR` (SuggestBackgroundPRTool)
- **Feature Gate**: `USER_TYPE === 'ant'`
- **Purpose**: Suggest creating a background PR

### 2.12 Special/Internal Tools

#### `SyntheticOutput` (SyntheticOutputTool)
- **Feature Gate**: Structured output mode (`--json-schema`)
- **Purpose**: Validate output against JSON Schema
- **Excluded from normal filtering** — added after `getTools()`

#### `AskUserQuestion` (AskUserQuestionTool)
- **Purpose**: Ask user a clarifying question during execution
- **Blocked in subagents**: No direct user interaction from agents

#### `NotebookEdit` (NotebookEditTool)
- **Purpose**: Edit Jupyter notebooks

#### `LSP` (LSPTool)
- **Feature Gate**: `ENABLE_LSP_TOOL` env var
- **Purpose**: Language Server Protocol operations (goto definition, references, etc.)

#### `PowerShell` (PowerShellTool)
- **Feature Gate**: `isPowerShellToolEnabled()` (Windows)
- **Purpose**: PowerShell-specific command execution

#### `Monitor` (MonitorTool)
- **Feature Gate**: `MONITOR_TOOL`
- **Purpose**: Monitor long-running tasks

#### `Workflow` (WorkflowTool)
- **Feature Gate**: `WORKFLOW_SCRIPTS`
- **Purpose**: Execute predefined workflow scripts

#### `Snip` (SnipTool)
- **Feature Gate**: `HISTORY_SNIP`
- **Purpose**: Manual context snip operation

#### `ListPeers` (ListPeersTool)
- **Feature Gate**: `UDS_INBOX`
- **Purpose**: List connected peers via Unix domain socket

#### `CtxInspect` (CtxInspectTool)
- **Feature Gate**: `CONTEXT_COLLAPSE`
- **Purpose**: Inspect context collapse state

#### `TerminalCapture` (TerminalCaptureTool)
- **Feature Gate**: `TERMINAL_PANEL`
- **Purpose**: Capture terminal output

#### `WebBrowser` (WebBrowserTool)
- **Feature Gate**: `WEB_BROWSER_TOOL`
- **Purpose**: Browser automation (Playwright)

#### `OverflowTest` (OverflowTestTool)
- **Feature Gate**: `OVERFLOW_TEST_TOOL`
- **Purpose**: Test context overflow handling

#### `VerifyPlanExecution` (VerifyPlanExecutionTool)
- **Feature Gate**: `CLAUDE_CODE_VERIFY_PLAN === 'true'`
- **Purpose**: Verify plan execution compliance

#### `TestingPermission` (TestingPermissionTool)
- **Feature Gate**: `NODE_ENV === 'test'`
- **Purpose**: Test-only permission management

---

## 3. Tool Pool Assembly Pipeline

```
┌────────────────────────────────────────────────────────────────┐
│ getAllBaseTools()                                               │
│ ┌──────────────────────────────────────────────────────────┐   │
│ │ Always: Agent, TaskOutput, Bash, ExitPlanMode, Read,     │   │
│ │         Edit, Write, Notebook, WebFetch, TodoWrite,      │   │
│ │         WebSearch, TaskStop, AskUserQuestion, Skill,     │   │
│ │         EnterPlanMode, Brief, ListMcpResources,          │   │
│ │         ReadMcpResource, SendMessage                     │   │
│ │                                                          │   │
│ │ Conditional (embedded search tools absent):              │   │
│ │         Glob, Grep                                       │   │
│ │                                                          │   │
│ │ Feature-gated (require build flag):                      │   │
│ │         WebBrowser, Sleep, Monitor, Cron*, RemoteTrigger │   │
│ │         SendUserFile, PushNotification, SubscribePR      │   │
│ │         Snip, CtxInspect, TerminalCapture, ListPeers     │   │
│ │         Workflow, OverflowTest, ToolSearch               │   │
│ │                                                          │   │
│ │ Ant-only (USER_TYPE === 'ant'):                          │   │
│ │         REPL, Config, Tungsten, SuggestBackgroundPR      │   │
│ │                                                          │   │
│ │ TodoV2 gate:                                             │   │
│ │         TaskCreate, TaskGet, TaskUpdate, TaskList         │   │
│ │                                                          │   │
│ │ Worktree gate:                                           │   │
│ │         EnterWorktree, ExitWorktree                       │   │
│ │                                                          │   │
│ │ Swarm gate:                                              │   │
│ │         TeamCreate, TeamDelete                            │   │
│ └──────────────────────────────────────────────────────────┘   │
│                           ↓                                     │
│ filterToolsByDenyRules() — remove blanket-denied tools          │
│                           ↓                                     │
│ filter by isEnabled() — remove tools whose gate is off          │
│                           ↓                                     │
│ getTools(permissionContext) — final built-in set                 │
│                           ↓                                     │
│ assembleToolPool(permissionContext, mcpTools)                    │
│   ├── Sort built-ins alphabetically                             │
│   ├── Filter MCP tools by deny rules                            │
│   ├── Sort MCP tools alphabetically                             │
│   └── Dedup by name (built-in wins)                             │
│                           ↓                                     │
│ Final tool pool sent to API                                     │
└────────────────────────────────────────────────────────────────┘
```

---

## 4. Tool Execution Flow

### 4.1 Permission Check

Before any tool executes:

```
1. Check deny rules → blanket deny = reject
2. Check allow rules → explicit allow = approve
3. Permission mode check:
   ├── bypassPermissions → always approve
   ├── auto → YOLO classifier decides
   ├── default → prompt user
   └── plan → read-only tools only
4. Sandbox check → if sandbox enabled, auto-approve safe commands
```

### 4.2 Streaming vs Batch Execution

```
StreamingToolExecutor (feature gate: streamingToolExecution)
├── Tools execute as they're discovered during streaming
├── Multiple tools can run concurrently
├── Results yielded incrementally
└── On fallback: discard results, create fresh executor

Traditional Batch Execution
├── All tool_use blocks collected first
├── Tools execute sequentially
└── Results yielded after all complete
```

### 4.3 Tool Result Processing

```
1. Execute tool → raw result
2. Apply maxResultSizeChars truncation if set
3. Apply tool result budget (aggregate size limit)
4. Normalize for API (create user message with tool_result blocks)
5. Yield to consumer (REPL/headless)
6. Add to message history for next API call
```

---

## 5. Key Design Patterns

### 5.1 Dead Code Elimination (DCE)

Ant-only tools use `process.env.USER_TYPE === 'ant'` which is replaced at build time with `'ant'` (internal) or `'external'` (external). The bundler eliminates the dead branch:

```typescript
const REPLTool = process.env.USER_TYPE === 'ant'
  ? require('./REPLTool/REPLTool.js').REPLTool
  : null  // Eliminated in external builds
```

### 5.2 Feature-Gated Lazy Require

Tools behind feature flags use lazy `require()` to avoid importing code that would be tree-shaken anyway:

```typescript
const SleepTool = feature('PROACTIVE') || feature('KAIROS')
  ? require('./SleepTool/SleepTool.js').SleepTool
  : null
```

### 5.3 Cache-Stable Tool Ordering

Tools are sorted alphabetically before being sent to the API. This ensures the tool description portion of the system prompt is deterministic across sessions, maximizing Anthropic's prompt cache hit rate.

### 5.4 SyntheticOutputTool

This tool is special — it's not in the normal tool pool. It's added after `getTools()` filtering when `--json-schema` is provided. It validates the model's output against a JSON Schema and acts as an output constraint mechanism.

---

## 6. Tool Count Summary

| Category | Count | Always Available |
|----------|-------|-----------------|
| Core tools | 8 | Bash, Read, Edit, Write, WebFetch, WebSearch, NotebookEdit, AskUserQuestion |
| Search tools | 2 | Glob, Grep (unless embedded search) |
| Agent tools | 4 | Agent, SendMessage, TaskOutput, TaskStop |
| Plan tools | 2 | EnterPlanMode, ExitPlanMode |
| Memory tools | 1 | TodoWrite |
| Skill tool | 1 | Skill |
| MCP tools | 3 | ListMcpResources, ReadMcpResource, ToolSearch |
| Feature-gated | 15+ | Sleep, Brief, Monitor, Cron*, Workflow, WebBrowser, etc. |
| Ant-only | 4 | REPL, Config, Tungsten, SuggestBackgroundPR |
| Team tools | 2 | TeamCreate, TeamDelete (swarm gate) |
| Task v2 tools | 4 | TaskCreate, TaskGet, TaskUpdate, TaskList |
| Worktree tools | 2 | EnterWorktree, ExitWorktree |
| Special | 3 | SyntheticOutput, VerifyPlanExecution, TestingPermission |
| **Total unique tools** | **~50+** | |
