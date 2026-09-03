# 16 — Resilience, Retry & Error Handling

Complete deconstruction of Claude Code's error handling architecture — the multi-layer system that makes an LLM-powered CLI reliable enough for production use.

---

## 1. Architecture Overview

```
                        API Call
                           │
                    ┌──────▼──────┐
                    │  withRetry  │  ◄── 822-line retry orchestrator
                    │  (Generator)│
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │classify  │ │should    │ │handle    │
        │APIError  │ │Retry     │ │Fallback  │
        └──────────┘ └──────────┘ └──────────┘
              │            │            │
              ▼            ▼            ▼
        ┌──────────────────────────────────────┐
        │         Error Recovery Actions       │
        │  • Backoff & retry                   │
        │  • Token refresh (401/403)           │
        │  • Credential cache clear (AWS/GCP)  │
        │  • Keep-alive disable (ECONNRESET)   │
        │  • max_tokens adjustment (overflow)  │
        │  • Model fallback (529 overload)     │
        │  • Fast mode cooldown (429)          │
        │  • Context compaction (prompt long)  │
        └──────────────────────────────────────┘
```

---

## 2. Retry Engine (`services/api/withRetry.ts`, 822 lines)

### Core Design

```typescript
async function* withRetry<T>(
  getClient: () => Promise<Anthropic>,
  operation: (client, attempt, context) => Promise<T>,
  options: RetryOptions,
): AsyncGenerator<SystemAPIErrorMessage, T>
```

**Key insight**: The retry engine is an `AsyncGenerator` that **yields status messages** during waits. The UI shows "Retrying in Xs (attempt Y/Z)..." while waiting.

### Retry Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `DEFAULT_MAX_RETRIES` | 10 | Normal operation retry cap |
| `BASE_DELAY_MS` | 500 | Exponential backoff base |
| `MAX_529_RETRIES` | 3 | Consecutive overload before fallback |
| `FLOOR_OUTPUT_TOKENS` | 3,000 | Minimum output tokens after overflow adjustment |
| `PERSISTENT_MAX_BACKOFF_MS` | 300,000 | Unattended mode max backoff (5 min) |
| `PERSISTENT_RESET_CAP_MS` | 21,600,000 | Unattended mode max wait (6 hours) |
| `HEARTBEAT_INTERVAL_MS` | 30,000 | Keep-alive chunk interval |

### Backoff Calculation

```typescript
function getRetryDelay(attempt, retryAfterHeader?, maxDelayMs = 32000): number {
  // Server directive takes priority
  if (retryAfterHeader) return parseInt(retryAfterHeader, 10) * 1000
  
  // Exponential with jitter
  const baseDelay = Math.min(500 * Math.pow(2, attempt - 1), maxDelayMs)
  const jitter = Math.random() * 0.25 * baseDelay
  return baseDelay + jitter
}
```

| Attempt | Base Delay | Jitter Range | Total Range |
|---------|-----------|-------------|-------------|
| 1 | 500ms | 0-125ms | 500-625ms |
| 2 | 1,000ms | 0-250ms | 1,000-1,250ms |
| 3 | 2,000ms | 0-500ms | 2,000-2,500ms |
| 4 | 4,000ms | 0-1,000ms | 4,000-5,000ms |
| 5 | 8,000ms | 0-2,000ms | 8,000-10,000ms |
| 6+ | 16,000ms | 0-4,000ms | 16,000-20,000ms |
| Cap | 32,000ms | 0-8,000ms | 32,000-40,000ms |

---

## 3. Error Classification

### `shouldRetry()` Decision Tree

```
APIError caught
  ├── Mock rate limit? → NO (testing command)
  ├── Persistent mode + 429/529? → YES
  ├── CCR mode + 401/403? → YES (infrastructure JWTs are transient)
  ├── overloaded_error in message? → YES (529 disguised)
  ├── max_tokens context overflow? → YES (auto-adjustable)
  ├── x-should-retry header?
  │   ├── 'true' + (non-subscriber OR enterprise)? → YES
  │   └── 'false' + (ant + 5xx)? → YES (ants override for server errors)
  ├── APIConnectionError? → YES (network failure)
  ├── 408 Request Timeout? → YES
  ├── 409 Conflict? → YES (lock timeout)
  ├── 429 Rate Limit?
  │   ├── Non-subscriber? → YES
  │   └── Enterprise? → YES
  │   └── Pro/Max subscriber? → NO (wait for reset)
  ├── 401 Unauthorized? → YES (clear API key cache, refresh token)
  ├── 403 OAuth revoked? → YES (refresh OAuth token)
  ├── 5xx Server Error? → YES
  └── Otherwise → NO
```

### Error Classes (`utils/errors.ts`)

| Error Class | Purpose |
|-------------|---------|
| `ClaudeError` | Base application error |
| `MalformedCommandError` | Invalid slash command |
| `AbortError` | User-requested cancellation |
| `ConfigParseError` | Config file parse failure (includes filePath + defaultConfig) |
| `ShellError` | Shell command failure (stdout, stderr, exitCode, interrupted) |
| `TeleportSafeError_I_VERIFIED...` | Error safe for telemetry (PII-free) |
| `CannotRetryError` | Retry exhausted (wraps original error + RetryContext) |
| `FallbackTriggeredError` | Model fallback activated (original → fallback model) |

### Axios Error Classification

```typescript
type AxiosErrorKind = 'auth' | 'timeout' | 'network' | 'http' | 'other'

function classifyAxiosError(e): { kind, status?, message }
// 401/403 → auth
// ECONNABORTED → timeout
// ECONNREFUSED/ENOTFOUND → network
// Other axios → http
// Non-axios → other
```

---

## 4. Specialized Recovery Patterns

### 4.1 Context Overflow Recovery

When the API returns `400: input length and max_tokens exceed context limit`:

```
1. Parse: "188059 + 20000 > 200000" → inputTokens=188059, maxTokens=20000, contextLimit=200000
2. Calculate: availableContext = contextLimit - inputTokens - 1000 (safety buffer)
3. Check: availableContext >= 3,000 (FLOOR_OUTPUT_TOKENS)?
4. Adjust: maxTokensOverride = max(FLOOR_OUTPUT_TOKENS, availableContext, minRequired)
5. Retry with adjusted max_tokens
```

This is **reactive context management** — the harness auto-shrinks the output window to fit within context limits.

### 4.2 Model Fallback (529 Overload)

When Opus models hit repeated 529 (overloaded):

```
1. Track consecutive 529 errors
2. After MAX_529_RETRIES (3): check if fallbackModel is configured
3. Throw FallbackTriggeredError(originalModel → fallbackModel)
4. Caller catches and retries with cheaper model (e.g., Opus → Sonnet)
```

Only triggers for non-subscriber users or custom Opus models.

### 4.3 Fast Mode Cooldown

When fast mode hits rate limits:

```
1. Check Retry-After header
2. If < 20s: wait and retry with fast mode still active (cache preservation)
3. If ≥ 20s or unknown: enter cooldown for min(30min, retryAfterMs, 10min minimum)
4. During cooldown: switch to standard speed model
5. After cooldown: resume fast mode
```

### 4.4 Stale Connection Recovery

```
1. Detect ECONNRESET or EPIPE from keep-alive pool
2. Disable keep-alive via disableKeepAlive()
3. Force new client creation (client = null)
4. Retry with fresh connection
```

Controlled by GrowthBook flag `tengu_disable_keepalive_on_econnreset`.

### 4.5 Auth Recovery

| Error | Action |
|-------|--------|
| 401 (first-party) | Clear API key cache, force new client |
| 403 "OAuth token revoked" | Call `handleOAuth401Error()`, force new client |
| Bedrock 403 | Clear AWS credentials cache, force new client |
| Vertex 401 | Clear GCP credentials cache, force new client |
| Google auth "Could not load credentials" | Same as Vertex 401 |

### 4.6 Unattended/Persistent Mode

For CI/CD and daemon deployments (`CLAUDE_CODE_UNATTENDED_RETRY`):

- **Infinite retry** on 429/529 — never gives up
- **Backoff cap**: 5 minutes max between retries
- **Total wait cap**: 6 hours per retry cycle
- **Heartbeat**: Yields status messages every 30s to prevent idle detection
- **Rate limit reset**: Honors `anthropic-ratelimit-unified-reset` header to wait until window resets

---

## 5. Foreground vs Background Retry

```typescript
const FOREGROUND_529_RETRY_SOURCES = new Set([
  'repl_main_thread',           // Interactive user queries
  'repl_main_thread:outputStyle:*', // Styled outputs
  'sdk',                        // SDK calls
  'agent:*',                    // Agent tool calls
  'compact',                    // Context compaction
  'hook_agent', 'hook_prompt',  // Hook-triggered calls
  'verification_agent',         // Security verification
  'side_question',              // Clarification questions
  'auto_mode',                  // YOLO classifier
  'bash_classifier',            // Bash safety classifier (ant-only)
])
```

**Background sources** (session titles, suggestions, summaries) **never retry 529** — they bail immediately to avoid amplifying capacity cascades. The user never sees these fail.

---

## 6. Graceful Shutdown (`utils/gracefulShutdown.ts`, 529 lines)

### Shutdown Sequence

```
Signal received (SIGINT/SIGTERM/SIGHUP)
  │
  ├── Set shutdownInProgress flag (prevents double-shutdown)
  ├── Arm failsafe timer: max(5s, hookTimeout + 3.5s)
  │
  ├── [SYNC] cleanupTerminalModes()
  │   ├── Disable mouse tracking (ASAP — terminal needs round-trip)
  │   ├── Unmount Ink (exits alt screen properly)
  │   ├── Drain stdin (catch in-flight events)
  │   ├── Disable Kitty keyboard protocol
  │   ├── Disable focus events
  │   ├── Disable bracketed paste
  │   ├── Show cursor
  │   ├── Clear iTerm2 progress bar
  │   ├── Clear tab status
  │   └── Clear terminal title
  │
  ├── [SYNC] printResumeHint()
  │   └── "Resume this session with: claude --resume {id}"
  │
  ├── [ASYNC] runCleanupFunctions() — 2s timeout
  │
  ├── [ASYNC] executeSessionEndHooks() — bounded by hookTimeout
  │
  ├── [ASYNC] profileReport() — startup perf logging
  │
  ├── [ASYNC] Log cache eviction hint
  │
  ├── [ASYNC] Flush analytics — 500ms cap
  │   ├── shutdown1PEventLogging()
  │   └── shutdownDatadog()
  │
  └── forceExit(exitCode)
      ├── process.exit(code)
      └── If EIO (dead terminal): process.kill(SIGKILL)
```

### Orphan Detection

On macOS, terminal close revokes TTY file descriptors instead of delivering SIGHUP:

```typescript
// Check every 30s if stdout/stdin are still valid
setInterval(() => {
  if (!process.stdout.writable || !process.stdin.readable) {
    gracefulShutdown(129) // Same as SIGHUP
  }
}, 30_000)
```

### Signal Exit Codes

| Signal | Exit Code |
|--------|-----------|
| SIGINT (Ctrl+C) | 0 (graceful) |
| SIGTERM | 143 (128 + 15) |
| SIGHUP | 129 (128 + 1) |
| Orphan detected | 129 (same as SIGHUP) |

### Bun Bug Workaround

signal-exit v4's `unload()` calls `removeListener` which resets kernel sigaction in Bun. Fixed by pinning a no-op `onExit()` callback that keeps the subscriber count > 0.

---

## 7. Error Utilities (`services/api/errorUtils.ts`, 260 lines)

### SSL/TLS Error Hints

When API connections fail with TLS errors, the harness provides actionable hints:

```
"SSL handshake failed" → Check corporate proxy, try NODE_EXTRA_CA_CERTS
"unable to verify the first certificate" → Self-signed cert in chain
"certificate has expired" → Check system clock
```

### HTML Sanitization

CloudFlare and other CDNs return HTML error pages. The harness strips HTML:

```typescript
function sanitizeAPIError(message: string): string {
  // Strip HTML tags, extract text content
  // Prevents HTML from appearing in terminal output
}
```

---

## 8. Streaming Error Recovery (SSE Transport)

From `cli/transports/SSETransport.ts`:

- **Auto-reconnection** with exponential backoff (base 1s, max 30s)
- **Liveness detection**: 45s timeout for silent connections
- **Sequence number resumption**: Replays from last received event
- **Streaming → non-streaming fallback**: If streaming fails, retries as non-streaming request

---

## 9. Error Shortening for Context Efficiency

```typescript
function shortErrorStack(e: unknown, maxFrames = 5): string {
  // Full stack traces are 500-2000 chars of irrelevant internal frames
  // Keep: error message + top 5 stack frames
  // Saves context tokens when error flows back to model as tool_result
}
```

This is a **harness-specific optimization** — errors that feed back to the LLM are compressed to save context window budget.

---

## 10. Key Takeaways for Harness Builders

1. **Generator-based retries** — `AsyncGenerator` lets the retry engine yield status messages to the UI while waiting
2. **Error classification determines retryability** — Not all errors are equal; 429 for subscribers means "wait" while 429 for API-key users means "retry"
3. **Auth errors trigger credential refresh** — The retry loop handles OAuth token refresh, AWS credential cache clearing, and GCP credential rotation transparently
4. **Context overflow auto-adjusts** — The harness catches `max_tokens + input > context_limit` and shrinks the output window dynamically
5. **Model fallback on overload** — 3 consecutive 529s trigger automatic downgrade from Opus to Sonnet
6. **Fast mode has its own retry strategy** — Short waits preserve cache; long waits trigger cooldown to standard speed
7. **Background sources don't amplify** — Session titles and suggestions never retry on 529 to prevent cascading during capacity events
8. **Unattended mode is infinite** — CI/CD sessions retry forever with 5-min backoff cap and 6-hour total cap
9. **Graceful shutdown is ordered** — Terminal cleanup first (sync), then session persistence, then hooks, then analytics flush, all with timeouts
10. **Error messages are token-optimized** — Stack traces are truncated before feeding back to the LLM to save context window
