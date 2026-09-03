# Multi-Agent Orchestration — Complete Reference

> Coordinator mode, AgentTool spawning, forked subagents, team/swarm architecture, worktree isolation, and message routing in Claude Code v2.1.88.

---

## 1. Agent Spawning Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                    Main Thread                           │
│  (REPL.tsx / print.ts / QueryEngine)                     │
│                                                          │
│  ┌──────────────┐    ┌──────────────┐                    │
│  │  Coordinator  │    │   Normal     │                    │
│  │  Mode (env)   │    │   Mode       │                    │
│  └──────┬───────┘    └──────┬───────┘                    │
│         │                    │                            │
│  AgentTool calls        AgentTool calls                   │
│         │                    │                            │
│    ┌────▼────┐          ┌───▼────┐                       │
│    │ Workers │          │ Agents │                       │
│    │ (async) │          │ (fork) │                       │
│    └─────────┘          └────────┘                       │
│                                                          │
│  ┌────────────────────────────────────────────┐          │
│  │         Team/Swarm (tmux)                   │          │
│  │  ┌────────┐ ┌────────┐ ┌────────┐         │          │
│  │  │Agent A │ │Agent B │ │Agent C │         │          │
│  │  │tmux win│ │tmux win│ │tmux win│         │          │
│  │  └────────┘ └────────┘ └────────┘         │          │
│  └────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Coordinator Mode

### 2.1 Activation

```bash
CLAUDE_CODE_COORDINATOR_MODE=1 claude
```

When active, the main thread becomes a **coordinator** that delegates all work to workers:

```typescript
isCoordinatorMode()
  → Checks CLAUDE_CODE_COORDINATOR_MODE env var
  → Feature gate: COORDINATOR_MODE build flag
```

### 2.2 Coordinator Tools

The coordinator has access to only 4 tools:

| Tool | Purpose |
|------|---------|
| `Agent` | Spawn a new worker |
| `SendMessage` | Continue an existing worker |
| `TaskStop` | Stop a running worker |
| `SyntheticOutput` | Structured output |

### 2.3 Coordinator System Prompt

The coordinator receives a specialized system prompt (369 lines) that defines:

1. **Your Role** — You are a coordinator. Direct workers. Answer questions directly when possible.
2. **Your Tools** — AgentTool, SendMessage, TaskStop, SubscribePR
3. **Workers** — Workers have access to standard tools + MCP tools + skills
4. **Task Workflow** — Research → Synthesis → Implementation → Verification
5. **Writing Worker Prompts** — Workers can't see your conversation. Every prompt must be self-contained.
6. **Example Session** — Full example of parallel research → synthesis → implementation

### 2.4 Key Coordinator Rules

- **Never fabricate agent results** — results arrive as separate messages
- **Never use one worker to check on another** — workers notify when done
- **Always synthesize findings** — read worker results, understand them, then direct follow-up
- **Never say "based on your findings"** — this delegates understanding to the worker
- **Choose continue vs spawn by context overlap**:
  - High overlap → Continue (SendMessage)
  - Low overlap → Spawn fresh (AgentTool)

### 2.5 Worker Tool Access

Workers in `--bare` mode get: Bash, Read, Edit (+ MCP tools)
Workers in normal mode get: All `ASYNC_AGENT_ALLOWED_TOOLS` + MCP tools + Skills

```typescript
ASYNC_AGENT_ALLOWED_TOOLS = {
  Read, WebSearch, TodoWrite, Grep, WebFetch, Glob,
  Bash/Edit/Write, NotebookEdit, Skill,
  SyntheticOutput, ToolSearch, EnterWorktree, ExitWorktree
}
```

**Blocked from workers**:
- `AgentTool` (prevents recursion, except ant)
- `TaskOutputTool` (prevents recursion)
- `ExitPlanModeTool` (main thread abstraction)
- `TaskStopTool` (requires main thread state)
- `TungstenTool` (singleton virtual terminal conflicts)

---

## 3. AgentTool — Spawning Subagents

### 3.1 Tool Schema

```json
{
  "name": "Agent",
  "parameters": {
    "description": "Brief task description",
    "prompt": "Full task instructions (self-contained)",
    "subagent_type": "general" | "worker",
    "model": "optional model override"
  }
}
```

### 3.2 Execution Flow

```
AgentTool.execute()
├── Validate subagent_type
├── Create agent definition from prompt
├── Call runForkedAgent()
│   ├── Create cache-safe params
│   ├── Setup tool permissions (restricted set)
│   ├── Setup abort controller
│   ├── Call query() generator
│   ├── Collect all messages
│   └── Return result + usage stats
├── Format result as <task-notification> XML
└── Return tool result
```

### 3.3 Forked Agent Architecture

```
runForkedAgent({
  promptMessages,
  cacheSafeParams,
  canUseTool,
  querySource,
  forkLabel,
  skipTranscript,
  overrides,
  onMessage,
})
```

The forked agent:
- Gets its own `query()` loop (full while(true))
- Has restricted tool access
- Runs in the same process (not a subprocess)
- Shares the abort signal (can be killed by parent)
- Returns usage statistics (tokens, duration)

---

## 4. Team/Swarm Architecture

### 4.1 Activation

```bash
claude --worktree --tmux
```

Feature gates: `isWorktreeModeEnabled()`, `isAgentSwarmsEnabled()`

### 4.2 Architecture

Teams spawn multiple Claude instances in **tmux windows**, each working on isolated git worktrees:

```
tmux session
├── Window 0: Leader (main thread)
├── Window 1: Agent "researcher"
├── Window 2: Agent "implementer"
└── Window 3: Agent "verifier"
```

### 4.3 Teammate Options

```typescript
TeammateOptions = {
  agentId: string,
  agentName: string,
  teamName: string,
  agentColor: string,
  planModeRequired: boolean,
  parentSessionId: string,
  teammateMode: string,
}
```

### 4.4 Communication

Teammates communicate via:
- **SendMessage tool** — Direct agent-to-agent messages
- **Shared message queue** — Process-global singleton
- **Team memory** — Shared memory directory
- **File system** — Shared scratchpad/worktree

### 4.5 In-Process Teammates

In-process teammates (not spawned via tmux) get additional tools:

```typescript
IN_PROCESS_TEAMMATE_ALLOWED_TOOLS = {
  TaskCreate, TaskGet, TaskList, TaskUpdate,
  SendMessage,
  CronCreate, CronDelete, CronList,  // AGENT_TRIGGERS
}
```

### 4.6 Worktree Isolation

Each teammate works in a separate git worktree:
- Prevents file conflicts between agents
- Each worktree is a full copy of the repo
- Changes are committed independently
- Leader coordinates merges

---

## 5. Message Routing

### 5.1 Queue Architecture

```typescript
MessageQueueManager (process-global singleton)
├── Enqueue commands with priority and mode
│   ├── 'prompt' — User prompts (main thread only)
│   ├── 'task-notification' — Agent completion messages
│   └── 'slash-command' — Slash commands
├── Priority: 'next' (drain mid-turn) vs 'later' (after turn)
├── Agent scoping: main thread drains agentId===undefined
│   └── Subagents drain their own agentId only
└── Filter by mode (slash commands excluded from mid-turn drain)
```

### 5.2 Task Notification Format

Worker results arrive as XML user messages:

```xml
<task-notification>
  <task-id>{agentId}</task-id>
  <status>completed|failed|killed</status>
  <summary>{human-readable status summary}</summary>
  <result>{agent's final text response}</result>
  <usage>
    <total_tokens>N</total_tokens>
    <tool_uses>N</tool_uses>
    <duration_ms>N</duration_ms>
  </usage>
</task-notification>
```

### 5.3 Coordinator User Context

The coordinator receives worker tool information via user context:

```typescript
getCoordinatorUserContext(mcpClients, scratchpadDir)
  → "Workers spawned via the Agent tool have access to these tools: Bash, Edit, FileRead, ..."
  → "Workers also have access to MCP tools from connected MCP servers: ..."
  → "Scratchpad directory: <path> — Workers can read and write here without permission prompts."
```

---

## 6. Agent Definitions

### 6.1 Loading Agents

```typescript
getAgentDefinitionsWithOverrides(cwd)
  ├── Read .claude/agents/ directory
  ├── Parse agent .md files
  ├── Merge with CLI --agents JSON
  ├── Filter active vs inactive
  └── Return { activeAgents, allowedAgentTypes }
```

### 6.2 Agent Types

| Type | Description | Tool Access |
|------|-------------|-------------|
| `general` | General-purpose agent | Async allowed tools |
| `worker` | Coordinator worker | Coordinator-specified tools |
| Custom | User-defined via .claude/agents/ | Customizable |

### 6.3 Custom Agents

Users can define custom agents in `.claude/agents/`:

```markdown
---
name: reviewer
description: Reviews code for quality
tools: [Read, Grep, Glob]
---

You are a code reviewer. Focus on...
```

---

## 7. KAIROS (Assistant/Daemon Mode)

### 7.1 Activation

```bash
claude --assistant
# or via settings.json: { "assistant": true }
```

Feature gate: `KAIROS` build flag + `tengu_kairos` GrowthBook gate

### 7.2 Key Differences

- **Proactive mode**: Agent can initiate conversations (SleepTool + PushNotification)
- **Brief tool**: Send messages to user via SendUserMessage
- **Daily log memory**: Append-only logs instead of MEMORY.md
- **Team pre-seeding**: `initializeAssistantTeam()` creates team before setup
- **Channel subscriptions**: MCP-based push notifications

### 7.3 KAIROS Trust Gate

KAIROS mode requires directory trust:
```
checkHasTrustDialogAccepted() === false
  → "Assistant mode disabled: directory is not trusted"
```

### 7.4 Sleep Tool

SleepTool is only available in proactive/KAIROS mode:
- Waits for notifications (task completions, PR updates, cron triggers)
- Returns when a notification arrives
- Enables long-lived agent sessions

---

## 8. Session Persistence & Resume

### 8.1 Session Storage

```
~/.claude/projects/<cwd-slug>/
├── <session-id>.jsonl     ← Session transcript
├── settings.json           ← Project settings
├── settings.local.json     ← Local overrides
└── memory/                 ← Persistent memory
```

### 8.2 Resume Modes

- `--continue` — Resume most recent session
- `--resume <id>` — Resume specific session
- `--resume <search>` — Search and pick session
- `--from-pr <number>` — Resume session linked to PR

### 8.3 Teammate Mode Snapshot

Teammate mode is captured at setup time and persisted:
```typescript
getTeammateModeSnapshot().setCliTeammateModeOverride(mode)
```

This ensures resumed sessions maintain their original mode.
