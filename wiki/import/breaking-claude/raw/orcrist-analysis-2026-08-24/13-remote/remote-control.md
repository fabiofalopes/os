# 13 — Remote Session Control

Complete deconstruction of Claude Code's remote session system — the architecture that allows the CLI to connect to a CCR (Claude Code Remote) container running elsewhere, stream messages, and manage permissions over WebSocket.

---

## 1. Architecture Overview

```
┌─────────────────────┐         WebSocket          ┌──────────────────┐
│   Local CLI (REPL)  │◄──────────────────────────▶│   CCR Container  │
│                     │         wss://api...         │                  │
│  RemoteSession      │                             │  Agent Loop      │
│  Manager            │    HTTP POST (messages)      │  Tools           │
│                     │───────────────────────────▶ │  LLM Calls       │
│  SessionsWebSocket  │                             │                  │
│  sdkMessageAdapter  │◄─── SDKMessage stream ──────│  Stream Events   │
│  Permission Bridge  │─── Permission responses ──▶│  Permission Req  │
└─────────────────────┘                             └──────────────────┘
        │                                                    │
        │                                                    │
        ▼                                                    ▼
  ┌──────────────┐                                  ┌──────────────┐
  │  Anthropic   │                                  │  Anthropic   │
  │  API         │                                  │  API         │
  │  (subscribe) │                                  │  (inference) │
  └──────────────┘                                  └──────────────┘
```

**Key insight**: The local CLI doesn't call the LLM. It connects to a CCR container that runs the agent loop remotely. The CLI is a thin client that renders UI and forwards permissions.

---

## 2. SessionsWebSocket (`remote/SessionsWebSocket.ts`)

### Connection Protocol

```
1. Connect: wss://api.anthropic.com/v1/sessions/ws/{sessionId}/subscribe?organization_uuid={uuid}
2. Auth: Via HTTP headers (Bearer token + anthropic-version)
3. Receive: Streaming SDKMessage, SDKControlRequest, SDKControlResponse
4. Send: Control responses (permission decisions), control requests (interrupts)
5. Keepalive: Ping every 30 seconds
```

### Reconnection Strategy

| Scenario | Behavior |
|----------|----------|
| Normal close | Reconnect up to 5 attempts, 2s delay |
| Code 4001 (session not found) | Retry up to 3 times (may be transient during compaction) |
| Code 4003 (unauthorized) | **Permanent close** — stop reconnecting |
| Max retries exceeded | Fire `onClose` callback |

### Dual Runtime Support

- **Bun**: Uses native `globalThis.WebSocket` with headers/proxy/tls options
- **Node.js**: Uses `ws` package with agent-based proxy

### Message Parsing

```typescript
function isSessionsMessage(value: unknown): value is SessionsMessage {
  // Accept any message with a string `type` field
  // No hardcoded allowlist — new backend message types pass through
  return typeof value === 'object' && value !== null 
    && 'type' in value && typeof value.type === 'string'
}
```

### Message Types Handled

```typescript
type SessionsMessage =
  | SDKMessage                  // LLM responses, tool results, etc.
  | SDKControlRequest           // Permission requests from CCR
  | SDKControlResponse          // Acknowledgments
  | SDKControlCancelRequest     // Server cancelling pending permission prompt
```

---

## 3. RemoteSessionManager (`remote/RemoteSessionManager.ts`)

### Configuration

```typescript
type RemoteSessionConfig = {
  sessionId: string
  getAccessToken: () => string
  orgUuid: string
  hasInitialPrompt?: boolean   // Session started with initial prompt
  viewerOnly?: boolean         // Pure viewer mode (claude assistant)
}
```

**`viewerOnly` mode**: Used by `claude assistant`. No Ctrl+C/Escape interrupt, no reconnect timeout, no session title updates.

### Callback Interface

```typescript
type RemoteSessionCallbacks = {
  onMessage: (message: SDKMessage) => void
  onPermissionRequest: (request, requestId) => void
  onPermissionCancelled?: (requestId, toolUseId?) => void
  onConnected?: () => void
  onDisconnected?: () => void
  onReconnecting?: () => void
  onError?: (error: Error) => void
}
```

### Message Handling Flow

```
WebSocket message received
      │
      ▼
  handleMessage()
      │
      ├── type === 'control_request'?
      │   └── inner.subtype === 'can_use_tool'?
      │       └── Store in pendingPermissionRequests Map
      │           └── Fire onPermissionRequest callback
      │
      ├── type === 'control_cancel_request'?
      │   └── Remove from pendingPermissionRequests
      │       └── Fire onPermissionCancelled
      │
      ├── type === 'control_response'?
      │   └── Log and ignore (acknowledgment)
      │
      └── Otherwise (SDKMessage)
          └── Fire onMessage callback → UI rendering
```

### Permission Response

```typescript
type RemotePermissionResponse =
  | { behavior: 'allow', updatedInput: Record<string, unknown> }
  | { behavior: 'deny', message: string }
```

Sent back via WebSocket as `SDKControlResponse`. Allow can modify tool input (e.g., user edits file path before allowing).

### User Message Sending

Messages sent via **HTTP POST** (not WebSocket):
```typescript
async sendMessage(content: RemoteMessageContent): Promise<boolean> {
  return sendEventToRemoteSession(sessionId, content, opts)
}
```

---

## 4. SDK Message Adapter (`remote/sdkMessageAdapter.ts`)

Converts CCR's `SDKMessage` format to REPL's internal `Message` types.

### Conversion Map

| SDKMessage Type | REPL Type | Notes |
|----------------|-----------|-------|
| `assistant` | `AssistantMessage` | Full message with content blocks |
| `stream_event` | `StreamEvent` | Streaming partial content |
| `result` (error) | `SystemMessage` | Only errors shown; success is noise |
| `system.init` | `SystemMessage` | "Remote session initialized (model: X)" |
| `system.status` | `SystemMessage` | "Compacting conversation…" etc. |
| `system.compact_boundary` | `SystemMessage` | Compaction boundary marker |
| `tool_progress` | `SystemMessage` | "Tool X running for Ys…" |
| `user` (tool results) | `UserMessage` | Only when `convertToolResults` enabled |
| `user` (text) | `UserMessage` | Only when `convertUserTextMessages` enabled |
| `auth_status` | Ignored | Handled separately |
| `tool_use_summary` | Ignored | SDK-only |
| `rate_limit_event` | Ignored | SDK-only |

### Conversion Options

```typescript
type ConvertOptions = {
  convertToolResults?: boolean      // For direct connect mode
  convertUserTextMessages?: boolean // For historical event rendering
}
```

- **CCR mode**: User messages are ignored (already added locally by REPL)
- **Direct connect mode**: Tool results from remote server need conversion for rendering
- **History mode**: All user text messages need rendering (not locally added)

---

## 5. Permission Bridge (`remote/remotePermissionBridge.ts`)

Creates synthetic objects when the local CLI doesn't have the real tool loaded.

### Synthetic Assistant Message

When CCR sends a permission request for a tool, the local CLI needs an `AssistantMessage` to render the permission dialog. Since the tool ran remotely, there's no real assistant message — so a synthetic one is created:

```typescript
function createSyntheticAssistantMessage(request, requestId): AssistantMessage {
  return {
    type: 'assistant',
    uuid: randomUUID(),
    message: {
      id: `remote-${requestId}`,
      content: [{ type: 'tool_use', id: request.tool_use_id, name: request.tool_name, input: request.input }],
      // ... minimal fields
    }
  }
}
```

### Tool Stub

When the CCR has tools the local CLI doesn't know about (e.g., MCP tools registered on the remote), a minimal stub is created:

```typescript
function createToolStub(toolName: string): Tool {
  return {
    name: toolName,
    inputSchema: {},
    isEnabled: () => true,
    userFacingName: () => toolName,
    renderToolUseMessage: (input) => /* first 3 key-value pairs */,
    call: async () => ({ data: '' }),
    needsPermissions: () => true,
    // ... minimal stubs for all required Tool interface methods
  }
}
```

---

## 6. Key Takeaways

1. **Thin client model**: Local CLI is a UI shell; LLM calls happen on CCR container
2. **Dual transport**: WebSocket for streaming + HTTP POST for user messages
3. **Permission proxy**: CCR requests permissions → local CLI shows dialog → response sent back via WS
4. **Graceful degradation**: Unknown tools get stubs; unknown message types pass through silently
5. **Resilient reconnection**: 5 retries for normal disconnects, 3 for session-not-found (compaction), permanent close on auth failure
6. **Viewer mode**: `claude assistant` connects as read-only — no interrupts, no reconnection timeout
7. **SDKMessage adapter**: Clean separation between wire format (SDK) and UI format (REPL Messages)
