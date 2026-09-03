# Configuration & Settings Hierarchy

> Source: `src/utils/claudemd.ts` (1,479 lines), `src/utils/config.ts` (1,817 lines), `src/utils/systemPrompt.ts`, `src/utils/settings/` directory

## Overview

Claude Code's configuration system has two main pillars: **CLAUDE.md memory files** that provide instructions to the model, and **settings** that control tool behavior, permissions, and system configuration. Both systems have layered hierarchies with clear priority rules.

## CLAUDE.md System

### 4-Tier Hierarchy

CLAUDE.md files are loaded in this order (reverse priority — later = higher priority):

```
1. Managed  → /etc/claude-code/CLAUDE.md (enterprise admin)
2. User     → ~/.claude/CLAUDE.md (private global)
3. Project  → CLAUDE.md, .claude/CLAUDE.md, .claude/rules/*.md (checked in)
4. Local    → CLAUDE.local.md (gitignored, per-project private)
```

From the source (claudemd.ts:1-26):
```
Files are loaded in the following order:
1. Managed memory - Global instructions for all users
2. User memory - Private global instructions for all projects
3. Project memory - Instructions checked into the codebase
4. Local memory - Private project-specific instructions

Files are loaded in reverse order of priority, i.e. the latest files are
highest priority with the model paying more attention to them.
```

### File Discovery

Project and Local files are discovered by **traversing from CWD up to root**:

```typescript
const dirs: string[] = []
let currentDir = originalCwd
while (currentDir !== parse(currentDir).root) {
  dirs.push(currentDir)
  currentDir = dirname(currentDir)
}
// Process from root downward to CWD
for (const dir of dirs.reverse()) {
  // CLAUDE.md, .claude/CLAUDE.md, .claude/rules/*.md
}
```

Files closer to CWD have higher priority (loaded later).

### Per-Directory Files

At each directory level, the system looks for:
- `CLAUDE.md` — Project-level (checked into git)
- `.claude/CLAUDE.md` — Project-level alternative location
- `.claude/rules/*.md` — Project-level rule files (recursive, supports subdirectories)
- `CLAUDE.local.md` — Local-level (gitignored, private)

### @include Directive

Memory files can include other files using `@` notation:

```
@include syntax:
  @path          → relative path (same as @./path)
  @./relative    → relative to including file
  @~/home/path   → absolute from home directory
  @/absolute     → absolute path
```

**Implementation** (claudemd.ts:451-535):

```typescript
function extractIncludePathsFromTokens(tokens, basePath): string[] {
  const includeRegex = /(?:^|\s)@((?:[^\s\\]|\\ )+)/g
  // For each match:
  // 1. Strip fragment identifiers (#heading)
  // 2. Unescape spaces
  // 3. Validate path format
  // 4. Resolve via expandPath()
}
```

Constraints:
- **Max depth**: `MAX_INCLUDE_DEPTH = 5` — prevents infinite recursion
- **Circular references**: Prevented via `processedPaths` set
- **Non-existent files**: Silently ignored
- **Code blocks excluded**: `@` paths inside code blocks/code spans are skipped
- **Text file extensions only**: Binary files are rejected (70+ extensions whitelisted)

### Frontmatter Globs

Rule files in `.claude/rules/` can have YAML frontmatter with path patterns:

```yaml
---
paths: src/**/*.ts
---
Only apply this rule to TypeScript files in src/.
```

Implementation:

```typescript
function parseFrontmatterPaths(rawContent: string): {
  content: string
  paths?: string[]
} {
  const { frontmatter, content } = parseFrontmatter(rawContent)
  if (!frontmatter.paths) return { content }
  const patterns = splitPathInFrontmatter(frontmatter.paths)
    .map(p => p.endsWith('/**') ? p.slice(0, -3) : p)
  if (patterns.every(p => p === '**')) return { content }  // Match-all = no globs
  return { content, paths: patterns }
}
```

### HTML Comment Stripping

Block-level HTML comments are stripped using the marked lexer:

```typescript
function stripHtmlCommentsFromTokens(tokens): { content, stripped } {
  for (const token of tokens) {
    if (token.type === 'html') {
      const trimmed = token.raw.trimStart()
      if (trimmed.startsWith('<!--') && trimmed.includes('-->')) {
        const residue = token.raw.replace(/<!--[\s\S]*?-->/g, '')
        stripped = true
        // Keep residual content after comment removal
      }
    }
  }
}
```

This preserves comments inside code blocks and inline positions.

### Character Limit

```typescript
export const MAX_MEMORY_CHARACTER_COUNT = 40000
```

AutoMem and TeamMem entrypoints are truncated to this limit via `truncateEntrypointContent()`.

### Exclude Patterns

The `claudeMdExcludes` setting can exclude specific CLAUDE.md paths:

```typescript
function isClaudeMdExcluded(filePath: string, type: MemoryType): boolean {
  if (type !== 'User' && type !== 'Project' && type !== 'Local') return false
  const patterns = getInitialSettings().claudeMdExcludes
  return picomatch.isMatch(normalizedPath, expandedPatterns, { dot: true })
}
```

Symlink-aware: patterns are resolved via `realpathSync` to handle macOS `/tmp` → `/private/tmp`.

### Additional Directories

`--add-dir` flag adds extra directories for CLAUDE.md discovery (gated by `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` env var).

### Worktree Handling

In nested worktrees (worktree inside main repo), Project-type files from the main repo are skipped to prevent duplicate loading:

```typescript
const isNestedWorktree = gitRoot !== null && canonicalRoot !== null &&
  normalizePathForComparison(gitRoot) !== normalizePathForComparison(canonicalRoot) &&
  pathInWorkingPath(gitRoot, canonicalRoot)
```

### Setting Source Gates

Each tier can be disabled by the settings system:

```typescript
if (isSettingSourceEnabled('userSettings')) { ... }      // User tier
if (isSettingSourceEnabled('projectSettings')) { ... }    // Project tier
if (isSettingSourceEnabled('localSettings')) { ... }      // Local tier
```

Managed, AutoMem, and TeamMem types are always loaded regardless of setting sources.

## Settings Sources

### 5-Source Merge Order

Settings are merged from 5 sources with this priority (highest to lowest):

1. **userSettings** — `~/.claude/settings.json` (user's global config)
2. **projectSettings** — `.claude/settings.json` (checked into repo)
3. **localSettings** — `.claude/settings.local.json` (gitignored)
4. **flagSettings** — CLI flags and env vars
5. **policySettings** — Enterprise admin policy (overrides everything for restrictions)

### What Settings Control

| Category | Examples |
|---|---|
| **Permissions** | `allowedTools`, `blockedTools`, permission rules |
| **Model** | `model`, `smallModelOverride` |
| **Behavior** | `autoCompact`, `contextWindow`, `maxTurns` |
| **Hooks** | Hook definitions per event type |
| **MCP** | MCP server configurations |
| **UI** | `theme`, `verbose`, `outputFormat` |
| **Memory** | `claudeMdExcludes`, `autoMemEnabled` |
| **Policy** | Enterprise restrictions, feature flags |

### Policy Settings

Enterprise admin-configured restrictions with special properties:
- **1-hour polling interval** for updates
- **Fail-open design**: if policy server is unreachable, existing policy stands
- **Override authority**: policy restrictions cannot be overridden by user/project settings
- **Managed hooks only**: `shouldAllowManagedHooksOnly()` can restrict hooks to managed-only

### Settings Schema

Settings are validated against a Zod schema with typed access:

```typescript
// Each setting has explicit type and source tracking
interface Setting<T> {
  value: T
  source: 'user' | 'project' | 'local' | 'flag' | 'policy'
}
```

### Merge Algorithm

```typescript
// Simplified merge — highest-priority source wins per key
function mergeSettings(sources: SettingSource[]): MergedSettings {
  const result = {}
  for (const source of sources) {
    // Each source can override individual keys
    Object.assign(result, source.settings)
  }
  return result
}
```

## System Prompt Assembly

The system prompt is assembled from multiple sources:

1. **Prefix**: Version, platform, environment info
2. **CLAUDE.md files**: All memory files in priority order
3. **Tool definitions**: Generated from registered tools
4. **Settings-injected context**: Permission mode, agent type
5. **Special instructions**: Auto-memory, MCP instructions

The assembled prompt is passed to `normalizeMessagesForAPI()` before sending to the API.

## Configuration Validation

### Environment Variable Validation

```typescript
function validateBoundedIntEnvVar(name, min, max, defaultValue): number {
  const raw = process.env[name]
  if (!raw) return defaultValue
  const parsed = parseInt(raw, 10)
  if (!Number.isFinite(parsed) || parsed < min || parsed > max) return defaultValue
  return parsed
}
```

### Feature Flags

Feature flags from GrowthBook (analytics service) control experimental behavior:
- `getFeatureValue_CACHED_MAY_BE_STALE()` — cached feature flag values
- `checkStatsigFeatureGate_CACHED_MAY_BE_STALE()` — gate checks
- Flags are loaded at startup and refreshed periodically

## .claude/ Directory Structure

```
~/.claude/
├── CLAUDE.md                    # User-level memory (global)
├── settings.json                # User-level settings
├── rules/                       # User-level rule files
├── projects/                    # Session storage
│   └── <sanitized-path>/
│       ├── <session-id>.jsonl   # Session transcript
│       └── <session-id>/
│           ├── subagents/       # Subagent transcripts
│           └── remote-agents/   # Remote agent metadata
└── credentials/                 # OAuth tokens

<project>/
├── CLAUDE.md                    # Project-level memory (checked in)
├── CLAUDE.local.md              # Local memory (gitignored)
└── .claude/
    ├── CLAUDE.md                # Alternative project memory
    ├── settings.json            # Project settings (checked in)
    ├── settings.local.json      # Local settings (gitignored)
    └── rules/                   # Project rule files
        ├── typescript.md        # Always-applied rules
        ├── react.md
        └── testing.md
```

## Key Insights for Harness Engineers

1. **4-tier CLAUDE.md with upward traversal** — Files closer to CWD override those higher in the tree. This enables repo-root defaults with per-directory overrides.

2. **@include with depth limiting** — 5-level recursion cap prevents include bombs. Circular references are tracked via a processed set.

3. **Frontmatter globs enable conditional rules** — `.claude/rules/typescript.md` can be scoped to only apply when editing `.ts` files.

4. **70+ whitelisted file extensions** — The @include system only loads text files, preventing binary injection into the prompt.

5. **HTML comment stripping is AST-aware** — Uses the marked lexer, not regex, to correctly handle comments inside code blocks.

6. **Policy settings are enterprise-first** — They can restrict what users can configure, with fail-open design for network issues.

7. **Lazy CLAUDE.md loading** — `getMemoryFiles` is memoized, so the filesystem walk only happens once per session.

8. **Worktree-aware** — In nested worktrees, checked-in files from the parent repo are skipped to prevent duplicate instructions.
