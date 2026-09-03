# 14 — TUI Architecture (React/ink)

Complete deconstruction of Claude Code's terminal UI layer — a React application rendered via ink (React for CLI) running in a Bun runtime.

---

## 1. Rendering Stack

```
┌─────────────────────────────────────────────┐
│  Bun Runtime                                │
│  ├── ink renderer (custom fork in src/ink/) │
│  │   ├── React reconciler                  │
│  │   ├── Terminal output (ANSI/YAML)       │
│  │   └── Layout engine (yoga-layout)       │
│  └── React 19 (with compiler runtime)       │
│      ├── Compiler optimization (_c caches)  │
│      └── Concurrent features               │
└─────────────────────────────────────────────┘
```

**Key observation**: All compiled components show `import { c as _c } from "react/compiler-runtime"` — the React compiler is active, producing memo cache instructions.

---

## 2. Component Hierarchy

```
<Root> (ink)
  └─ <App> (src/components/App.tsx, 55 lines)
       ├─ <FpsMetricsProvider>
       ├─ <StatsProvider>
       └─ <AppStateProvider>
            ├─ <MailboxProvider>
            ├─ <VoiceProvider> (DCE: ant-only)
            └─ <REPL> (src/screens/REPL.tsx, 5,006 lines)
                 │
                 ├─ LAYOUT
                 │  ├─ <FullscreenLayout>
                 │  │   ├─ <VirtualMessageList> (1,081 lines)
                 │  │   │   └─ <Messages> → <Message> → <MessageResponse>
                 │  │   └─ <PromptInput> (2,338 lines)
                 │  │       ├─ <ShimmeredInput>
                 │  │       ├─ <PromptInputFooter>
                 │  │       ├─ <PromptInputHelpMenu>
                 │  │       ├─ <HistorySearchInput>
                 │  │       ├─ <VoiceIndicator> (DCE)
                 │  │       └─ <Notifications>
                 │  │
                 │  └─ <StatusLine> (323 lines)
                 │
                 ├─ DIALOGS (overlay)
                 │  ├─ <PermissionRequest>
                 │  ├─ <ElicitationDialog> (MCP)
                 │  ├─ <PromptDialog> (hooks)
                 │  ├─ <CostThresholdDialog>
                 │  ├─ <IdleReturnDialog>
                 │  ├─ <SkillImprovementSurvey>
                 │  └─ <WorkerPendingPermission> (swarm)
                 │
                 ├─ PICKERS
                 │  ├─ <MessageSelector>
                 │  ├─ <ModelPicker>
                 │  ├─ <HistorySearchDialog>
                 │  ├─ <GlobalSearchDialog>
                 │  └─ <QuickOpenDialog>
                 │
                 └─ HOOKS (invisible, ~40+ active)
                    ├─ useQueueProcessor
                    ├─ useRemoteSession
                    ├─ useDirectConnect
                    ├─ useSSHSession
                    ├─ useCancelRequest
                    ├─ useGlobalKeybindings
                    ├─ useCommandKeybindings
                    ├─ useSwarmInitialization
                    ├─ useCostSummary
                    ├─ useMailboxBridge
                    ├─ useReplBridge
                    ├─ useFrustrationDetection (DCE: ant-only)
                    ├─ useVoiceIntegration (DCE: ant-only)
                    └─ ... 50+ more
```

---

## 3. Screens

### REPL.tsx (5,006 lines — the monolith)

The REPL screen is the main interactive session. It is **the largest file in the entire codebase**.

**Responsibilities**:
- Message list rendering and virtual scrolling
- Prompt input handling (multiline, vim mode, paste)
- Permission request UI
- Tool execution coordination
- Session management (resume, switch)
- Command processing (slash commands)
- Background task management
- Cost tracking display
- Swarm/team coordination
- Remote session connection
- History navigation
- Keybinding management

**Why it's 5K lines**: The REPL component is the orchestrator of the entire interactive experience. Rather than splitting into dozens of smaller components, the Anthropic team chose a "God Component" pattern where the REPL holds all state and delegates through hooks.

### Doctor.tsx (574 lines)

Diagnostic/troubleshooting screen. Likely accessed via `/doctor` command.

### ResumeConversation.tsx (398 lines)

Session resume screen — shows previous sessions and allows picking one to continue.

---

## 4. Key Component Analysis

### VirtualMessageList.tsx (1,081 lines)

Custom virtual scrolling implementation for terminal rendering:
- Efficiently renders only visible messages
- Handles ANSI escape codes, colored output, diffs
- Jump-to-message functionality (JumpHandle)
- Search highlighting integration

### PromptInput.tsx (2,338 lines)

The main text input component:
- **Input modes**: Normal, Vim (with modal editing), Shell
- **Autocomplete**: File suggestions, command suggestions, context suggestions
- **Paste handling**: Image paste, text paste with dedup
- **History**: Up-arrow navigation, Ctrl+R reverse search
- **Queued commands**: Visual indicator for queued slash commands
- **Mode indicator**: Shows current input mode (vim: normal/insert, shell, etc.)

### StatusLine.tsx (323 lines)

Bottom status bar showing:
- Current model
- Token usage / cost
- Rate limit warnings
- Session duration
- Context window usage

### PermissionRequest.tsx

Tool permission dialog with:
- Tool name and input display
- Allow/Deny/Allow Always/Never Ask Again buttons
- Input editing before approval
- Plan mode permission handling

---

## 5. State Management

### AppStateStore (state/AppStateStore.ts)

External store pattern (Redux-like, no Redux dependency):

```typescript
type AppState = {
  messages: Message[]
  isLoading: boolean
  toolPermissionContext: ToolPermissionContext
  speculationState: SpeculationState
  // ... more fields
}
```

### Context Providers

| Provider | Purpose |
|----------|---------|
| `AppStateProvider` | Global app state store |
| `FpsMetricsProvider` | Terminal FPS tracking |
| `StatsProvider` | Usage statistics |
| `MailboxProvider` | Inter-agent communication |
| `VoiceProvider` | Voice input (DCE: ant-only) |
| `NotificationsProvider` | Desktop notifications |
| `ModalContext` | Modal dialog stack |
| `OverlayContext` | Overlay rendering |
| `PromptOverlayContext` | Prompt-specific overlays |
| `QueuedMessageContext` | Message queue management |

---

## 6. Design System (`components/design-system/`)

Reusable terminal UI primitives:

| Component | Purpose |
|-----------|---------|
| `Dialog.tsx` | Modal dialog container |
| `FuzzyPicker.tsx` | Fuzzy search picker |
| `Pane.tsx` | Split pane layout |
| `ProgressBar.tsx` | Progress indicator |
| `Ratchet.tsx` | Incremental progress |
| `Tabs.tsx` | Tab navigation |
| `ThemeProvider.tsx` | Terminal color theme |
| `ThemedBox.tsx` | Theme-aware box |
| `ThemedText.tsx` | Theme-aware text |
| `Divider.tsx` | Horizontal/vertical divider |
| `StatusIcon.tsx` | Status indicator icons |
| `ListItem.tsx` | List item rendering |
| `LoadingState.tsx` | Loading indicator |
| `Byline.tsx` | Author/timestamp line |
| `KeyboardShortcutHint.tsx` | Shortcut display |

### UI Primitives (`components/ui/`)

| Component | Purpose |
|-----------|---------|
| `OrderedList.tsx` | Numbered list |
| `OrderedListItem.tsx` | List item |
| `TreeSelect.tsx` | Tree selection widget |

---

## 7. ink Customization (`src/ink/`)

Claude Code maintains a **custom fork of ink** (60+ files) with significant modifications:

### Layout Engine
- Custom yoga-layout integration for terminal rendering
- Width calculation and text wrapping (ANSI-aware)
- Bidirectional text support (`bidi.ts`)
- Terminal querying (`terminal-querier.ts`)

### Rendering Pipeline
```
ink.tsx (entry point)
  → renderer.ts
    → render-node-to-output.ts
      → render-border.ts
      → wrap-text.ts / wrapAnsi.ts
    → render-to-screen.ts
      → squash-text-nodes.ts (optimization)
  → reconciler.ts (React custom reconciler)
```

### Terminal Features
- Search highlighting (`searchHighlight.ts`)
- Text selection (`selection.ts`)
- Focus management (`focus.ts`)
- Terminal notifications (`useTerminalNotification.ts`)
- Tab status tracking (`use-tab-status.ts`)
- Keypress parsing (`parse-keypress.ts`)
- Color support (`colorize.ts`, `supports-hyperlinks.ts`)

### Performance Optimizations
- **String width caching** (`stringWidth.ts`, `line-width-cache.ts`)
- **Node caching** (`node-cache.ts`)
- **Optimizer** (`optimizer.ts`) — reduces re-renders
- **Offscreen freeze** (`OffscreenFreeze.tsx`) — freezes components outside viewport
- **Max width calculation** (`get-max-width.ts`)

---

## 8. Keybinding System

### Architecture
```
keybindings/
  ├── KeybindingProviderSetup.ts    — Initializes keybinding context
  ├── useShortcutDisplay.ts         — Shows current shortcuts
  └── shortcutFormat.ts             — Format shortcuts for display

hooks/
  ├── useGlobalKeybindings.tsx      — Global shortcuts (Ctrl+C, Ctrl+L, etc.)
  ├── useCommandKeybindings.tsx     — Command-specific shortcuts
  └── useExitOnCtrlCD.ts            — Ctrl+C exit handler
```

### Input Modes
- **Normal**: Standard text input
- **Vim**: Modal editing (normal/insert/visual modes)
- **Shell**: Shell-like completion and history

---

## 9. Dead Code Elimination (DCE) in TUI

Several components are conditionally compiled via `feature()` or build-time constants:

```typescript
// Voice mode — only in ant builds
const useVoiceIntegration = feature('VOICE_MODE')
  ? require('../hooks/useVoiceIntegration.js').useVoiceIntegration
  : () => ({ stripTrailing: () => 0, handleKeyEvent: () => {}, resetAnchor: () => {} })

// Frustration detection — only in ant builds
const useFrustrationDetection = "external" === 'ant'
  ? require('../components/FeedbackSurvey/useFrustrationDetection.js').useFrustrationDetection
  : () => ({ state: 'closed', handleTranscriptSelect: () => {} })

// Coordinator mode — feature gated
const getCoordinatorUserContext = feature('COORDINATOR_MODE')
  ? require('../coordinator/coordinatorMode.js').getCoordinatorUserContext
  : () => ({})
```

This pattern ensures unused code is completely eliminated at build time via Bun's bundler.

---

## 10. Key Takeaways

1. **React for CLI** — The entire TUI is a React application with ink as the renderer
2. **5K-line REPL monolith** — The REPL screen is the largest file, orchestrating the entire interactive experience
3. **60+ custom hooks** — Business logic is delegated to hooks while components remain focused on rendering
4. **Custom ink fork** — Significant modifications for performance (caching, offscreen freeze, ANSI handling)
5. **Virtual scrolling** — Custom implementation optimized for terminal rendering constraints
6. **React Compiler active** — All compiled components show memo cache instructions
7. **Vim integration** — Full modal editing support within the prompt input
8. **Aggressive DCE** — Voice, frustration detection, coordinator mode eliminated at build time
9. **External store pattern** — AppStateStore follows Redux patterns without Redux dependency
10. **Terminal-native design system** — 16+ reusable components for terminal UI patterns
