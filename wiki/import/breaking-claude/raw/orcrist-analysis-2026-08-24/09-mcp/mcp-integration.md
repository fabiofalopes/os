# MCP Integration — Complete Reference

> MCP (Model Context Protocol) server configuration, tool injection, resource management, and the official registry in Claude Code v2.1.88.

---

## 1. MCP Architecture

### 1.1 Overview

Claude Code supports MCP servers as a first-class extension mechanism. MCP servers provide additional **tools**, **resources**, and **prompts** to the agent.

```
┌───────────────────────────────────────────────────────────┐
│                    Claude Code                             │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              MCP Client Manager                     │  │
│  │                                                     │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐           │  │
│  │  │ Server A │  │ Server B │  │ Server C │           │  │
│  │  │ (stdio)  │  │ (http)   │  │ (sdk)    │           │  │
│  │  └─────────┘  └─────────┘  └─────────┘           │  │
│  │       │             │             │                  │  │
│  │  ┌────▼─────────────▼─────────────▼─────────────┐  │  │
│  │  │         Tool Pool Assembly                    │  │  │
│  │  │  Built-in tools + MCP tools → Sorted, deduped │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### 1.2 Configuration Sources

MCP configs are loaded from:

1. **CLI flag**: `--mcp-config <file-or-json>`
2. **User settings**: `~/.claude/settings.json` → `mcpServers`
3. **Project settings**: `.claude/settings.json` → `mcpServers`
4. **Local settings**: `.claude/settings.local.json` → `mcpServers`
5. **Claude.ai connectors**: `fetchClaudeAIMcpConfigsIfEligible()`
6. **Enterprise config**: Managed MCP configuration
7. **Dynamic**: Runtime-discovered MCP configs
8. **Special**: Claude in Chrome, Computer Use MCP (built-in)

---

## 2. MCP Config Format

### 2.1 Standard Config

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"],
      "env": {
        "API_KEY": "..."
      },
      "scope": "user|project|local|dynamic"
    }
  }
}
```

### 2.2 Transport Types

| Type | Config | Description |
|------|--------|-------------|
| `stdio` | `command` + `args` | Subprocess via stdin/stdout |
| `http` | `url` | HTTP-based MCP server |
| `sdk` | `type: 'sdk'` | In-process SDK transport |

### 2.3 Scope

| Scope | Source | Priority |
|-------|--------|----------|
| `user` | `~/.claude/settings.json` | User-wide |
| `project` | `.claude/settings.json` | Project-specific |
| `local` | `.claude/settings.local.json` | Local overrides |
| `dynamic` | `--mcp-config` CLI flag | Session-only |

---

## 3. Tool Injection Pipeline

### 3.1 Assembly

```
assembleToolPool(permissionContext, mcpTools)
├── getTools(permissionContext) → built-in tools
│   ├── filterToolsByDenyRules()
│   └── filter by isEnabled()
├── filterToolsByDenyRules(mcpTools) → allowed MCP tools
├── Sort built-ins alphabetically (cache stability)
├── Sort MCP tools alphabetically
├── Concatenate: [...builtIn, ...mcp]
└── Dedup by name (built-in wins)
```

### 3.2 MCP Tool Naming

MCP tools are prefixed with `mcp__<servername>__<toolname>`:
- Example: `mcp__filesystem__read_file`
- Deny rules: `mcp__servername` strips ALL tools from that server

### 3.3 Reserved Names

These MCP server names are reserved and cannot be used in `--mcp-config`:
- Claude in Chrome MCP server name
- Computer Use MCP server name (`CHICAGO_MCP`)

---

## 4. Enterprise Policy Filtering

### 4.1 Allowed/Denied Servers

Enterprise admins can control MCP server access:

```json
{
  "allowedMcpServers": ["server-a", "server-b"],
  "deniedMcpServers": ["dangerous-server"]
}
```

### 4.2 Filtering Pipeline

```
filterMcpServersByPolicy(configs)
├── If allowedMcpServers defined: only allow listed
├── If deniedMcpServers defined: block listed
└── Return { allowed, blocked }
```

### 4.3 Strict Mode

`--strict-mcp-config` ignores all auto-discovered MCP configs:
- Only `--mcp-config` servers are used
- Enterprise config check enforced
- Claude.ai connectors skipped

### 4.4 Bare Mode

`--bare` mode skips ALL auto-discovered MCP:
- Only explicit `--mcp-config` works
- No Claude.ai proxy servers
- No project settings MCP

---

## 5. MCP Resource Management

### 5.1 Resources

MCP servers can expose resources:
- `ListMcpResourcesTool` — List available resources
- `ReadMcpResourceTool` — Read a specific resource
- Resources are prefetched at startup: `prefetchAllMcpResources()`

### 5.2 Official Registry

`prefetchOfficialMcpUrls()` — Fetches the official MCP server registry for discovery.

---

## 6. Special MCP Integrations

### 6.1 Claude in Chrome

When enabled:
- Auto-configures Chrome browser MCP server
- Provides browser automation tools
- Adds allowed tools from Chrome
- Injects system prompt hint

### 6.2 Computer Use MCP (CHICAGO_MCP)

Ant-only, macOS-only:
- App allowlist + frontmost gate
- SCContentFilter screenshots
- Only in interactive mode
- Auto-hide/unhide on turn start/end

---

## 7. MCP Connection Lifecycle

### 7.1 Two-Phase Loading

**Interactive mode**: Uses `useManageMCPConnections` hook
- Phase 1: Load configs (fast, file I/O only)
- Phase 2: Connect to servers (slow, subprocess spawn)

**Headless mode** (`-p`): Inline loading
- Both phases run before `runHeadless()`
- `claudeaiConfigPromise` overlaps with `setup()`

### 7.2 Hot Reload

MCP connections support hot reload:
- `settingsChangeDetector` watches MCP config files
- On change: disconnect old servers, connect new ones
- Tool pool is refreshed via `refreshTools()` callback

### 7.3 Pending State

Servers start in `pending` state:
- `appState.mcp.clients.some(c => c.type === 'pending')`
- The API call proceeds even with pending servers
- Tools from pending servers are included optimistically
