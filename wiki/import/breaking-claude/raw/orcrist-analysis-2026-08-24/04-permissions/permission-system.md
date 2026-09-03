# Permission System — Complete Reference

> The 6-layer permission stack, YOLO classifier, Bash security patterns, dangerous file protections, and auto-mode architecture in Claude Code v2.1.88.

---

## 1. Permission Modes

### 1.1 Mode Hierarchy

| Mode | Symbol | Color | Description |
|------|--------|-------|-------------|
| `default` | (none) | text | Prompt user for every dangerous operation |
| `plan` | ⏸ | planMode | Read-only tools only |
| `acceptEdits` | ⏵⏵ | autoAccept | Auto-accept file edits, prompt for commands |
| `auto` | ⏵⏵ | warning | YOLO classifier decides (TRANSCRIPT_CLASSIFIER feature gate) |
| `dontAsk` | ⏵⏵ | error | Auto-accept everything (dangerous) |
| `bypassPermissions` | ⏵⏵ | error | No permission checks at all |

External users see: `default`, `plan`, `acceptEdits`, `bypassPermissions`, `dontAsk`
Ant-only: `auto` (YOLO classifier), `bubble` (internal)

### 1.2 Mode Resolution

```
CLI flag (--permission-mode)
  → settings.json defaultMode
    → Settings default (default)
```

`--dangerously-skip-permissions` sets mode to `bypassPermissions` (requires `--allow-dangerously-skip-permissions`).

---

## 2. The 6-Layer Permission Stack

When a tool is about to execute, it passes through these layers:

```
Layer 1: Deny Rules
├── Check blanket deny rules (no content = deny all)
├── Check pattern deny rules (Bash(rm:*) = deny specific)
└── Matched deny → REJECT immediately

Layer 2: Allow Rules
├── Check blanket allow rules (no content = allow all)
├── Check pattern allow rules (Bash(git:*) = allow specific)
├── Check session-level allow (granted during session)
└── Matched allow → APPROVE

Layer 3: Permission Mode Check
├── bypassPermissions → APPROVE everything
├── auto → YOLO classifier decides
├── dontAsk → APPROVE everything (no prompts)
├── acceptEdits → APPROVE file edits, prompt commands
└── plan → REJECT writes, APPROVE reads

Layer 4: Sandbox Check
├── If sandbox enabled (Docker/gVisor)
├── Auto-approve commands within sandbox
└── Reject unsandboxed commands unless explicitly allowed

Layer 5: Dangerous Pattern Check
├── Check command against dangerous patterns
├── Strip dangerous permissions in auto mode
└── Warn about overly broad patterns

Layer 6: User Prompt
├── Default mode: show permission dialog
├── User can: Allow Once, Allow Session, Deny
└── Decision stored for future similar operations
```

---

## 3. YOLO Classifier (Auto Mode)

### 3.1 Architecture

The YOLO classifier is the heart of "auto mode" — it uses a **secondary LLM call** (typically Haiku) to classify whether a tool operation should be allowed, denied, or prompted.

```
User turn → Model produces tool_use
  → YOLO classifier invoked
    ├── Build classifier prompt (tool name, input, context)
    ├── Call sideQuery (secondary model, usually Haiku)
    ├── Parse classifier response
    └── Decision: allow / deny / ask
```

### 3.2 Classifier Prompts

The YOLO classifier uses template files:
- `auto_mode_system_prompt.txt` — Base system prompt for classification
- `permissions_external.txt` — External user permission rules
- `permissions_anthropic.txt` — Internal Anthropic permission rules (ant-only)

### 3.3 AutoMode Rules

```typescript
type AutoModeRules = {
  allow: string[]      // Patterns to always allow
  soft_deny: string[]  // Patterns to always deny
  environment: string[] // Context about the environment
}
```

These rules are customizable via `settings.autoMode` and are embedded in the classifier prompt.

### 3.4 Bash Command Classification

For Bash commands specifically, the classifier:
1. Checks against allow descriptions (e.g., "running tests", "viewing git log")
2. Checks against deny descriptions (e.g., "installing packages", "modifying system config")
3. Falls through to LLM classification for ambiguous cases

---

## 4. Bash Security — 23+ Checks

### 4.1 Dangerous Patterns

```typescript
DANGEROUS_BASH_PATTERNS = [
  // Interpreters (arbitrary code execution)
  'python', 'python3', 'node', 'deno', 'tsx', 'ruby', 'perl', 'php', 'lua',
  // Package runners
  'npx', 'bunx', 'npm run', 'yarn run', 'pnpm run', 'bun run',
  // Shells
  'bash', 'sh', 'zsh', 'fish',
  // Meta-execution
  'eval', 'exec', 'env', 'xargs', 'sudo',
  // Ant-only additions
  'fa run', 'coo', 'gh', 'gh api', 'curl', 'wget',
  'git', 'kubectl', 'aws', 'gcloud', 'gsutil',
  // Remote execution
  'ssh',
]
```

Any allow rule matching these prefixes (e.g., `Bash(python:*)`) is stripped in auto mode because it grants arbitrary code execution.

### 4.2 Dangerous Files

```typescript
DANGEROUS_FILES = [
  '.gitconfig', '.gitmodules',        // Git config (hooks = code exec)
  '.bashrc', '.bash_profile',          // Shell init (code exec on login)
  '.zshrc', '.zprofile', '.profile',   // Shell init
  '.ripgreprc',                         // Ripgrep config
  '.mcp.json',                          // MCP server config (code exec)
  '.claude.json',                       // Claude settings
]
```

### 4.3 Dangerous Directories

```typescript
DANGEROUS_DIRECTORIES = [
  '.git',      // Git internals (hooks = code exec)
  '.vscode',   // VS Code settings (tasks = code exec)
  '.idea',     // JetBrains settings
  '.claude',   // Claude config directory
]
```

### 4.4 Sandbox Integration

Claude Code supports sandboxing Bash commands:
- **Docker** — Container-based isolation
- **gVisor** — Kernel-level sandboxing
- **Auto-allow within sandbox** — Commands inside sandbox are auto-approved

```typescript
SandboxManager.isSandboxingEnabled()
SandboxManager.areUnsandboxedCommandsAllowed()
SandboxManager.isAutoAllowBashIfSandboxedEnabled()
```

### 4.5 Path Validation

All file operations validate paths against:
- **Path traversal** (`../../etc/passwd`)
- **Vulnerable UNC paths** (Windows)
- **Case-insensitive bypass** (`.cLauDe/Settings.locaL.json`)
- **Working directory confinement**
- **Allowed directories** (`--add-dir`)

---

## 5. Permission Rules

### 5.1 Rule Format

```
ToolName                  — Allow all uses of this tool
ToolName(pattern)         — Allow uses matching pattern
ToolName(prefix:*)        — Allow all commands starting with prefix
ToolName(pattern:*)       — Allow all commands matching prefix pattern
```

Examples:
```
Bash(git:*)               — Allow all git commands
Bash(npm test:*)          — Allow `npm test ...`
Edit                      — Allow all file edits
Read                      — Allow all file reads
mcp__servername           — Allow all tools from MCP server
```

### 5.2 Rule Sources

| Source | Location | Priority |
|--------|----------|----------|
| CLI `--allowedTools` | Command line | Highest |
| CLI `--disallowedTools` | Command line | Highest |
| CLI `--tools` | Command line | Restrictive |
| `.claude/settings.json` | Project settings | High |
| `.claude/settings.local.json` | Local overrides | High |
| `~/.claude/settings.json` | User global | Medium |
| Session grants | User prompts | Low |

### 5.3 Shadowed Rule Detection

The system detects when a higher-priority allow rule shadows a lower-priority deny rule, and vice versa:

```
Warning: Allow rule "Bash(git:*)" in settings.json shadows deny rule "Bash(git push:*)" in .claude/settings.json
```

---

## 6. Killswitch System

### 6.1 Bypass Permissions Killswitch

`bypassPermissionsKillswitch.ts` — Enterprise admins can remotely disable `bypassPermissions` mode:

```
Enterprise policy → loadPolicyLimits() → check bypass permissions killswitch
  → If killed: force downgrade to default mode
```

### 6.2 Auto-Mode Gate

`verifyAutoModeGateAccess()` — GrowthBook gate `tengu_auto_mode` controls whether auto mode is available:

```
isAutoModeEnabled()
  → GrowthBook gate check (cached, max 5s for fresh)
  → If gate denied: fall back to default mode
  → Notify user that auto mode is unavailable
```

---

## 7. Permission Setup Flow

```
main.tsx action handler
  └── initializeToolPermissionContext({
        allowedToolsCli,
        disallowedToolsCli,
        baseToolsCli,
        permissionMode,
        allowDangerouslySkipPermissions,
        addDirs,
      })
        ├── Parse CLI tool lists
        ├── Load permission rules from all sources
        ├── Resolve conflicts (higher source wins)
        ├── Check dangerous patterns
        ├── Strip dangerous permissions (auto mode)
        ├── Initialize filesystem permissions
        └── Return { toolPermissionContext, warnings, dangerousPermissions }
```

---

## 8. Scratchpad (Ant-Only)

When `tengu_scratch` GrowthBook gate is enabled, a scratchpad directory is available:

```
Scratchpad directory: <temp>/claude-scratchpad-<session>/
  → Workers can read and write here without permission prompts
  → Used for durable cross-worker knowledge
  → Coordinator passes path via user context
```

---

## 9. MCP Permission Filtering

Enterprise policy filters MCP tools:

```
filterMcpServersByPolicy(mcpConfigs)
  → Check allowedMcpServers / deniedMcpServers
  → Block servers not in allowlist
  → Return { allowed, blocked }
```

MCP server names are also checked against reserved names (Claude in Chrome, Computer Use MCP).
