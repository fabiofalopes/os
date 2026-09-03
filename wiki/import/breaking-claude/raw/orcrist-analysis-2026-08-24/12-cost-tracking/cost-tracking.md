# 12 — Cost Tracking, Billing & Rate Limits

Complete deconstruction of Claude Code's cost tracking, pricing, rate limiting, overage, and policy enforcement systems.

---

## 1. Architecture Overview

```
User sends query
      │
      ▼
┌──────────────────┐     ┌──────────────────┐
│  QueryEngine     │────▶│  Anthropic API   │
│  (query.ts)      │     │  Response        │
└──────┬───────────┘     └────────┬─────────┘
       │                          │
       ▼                          ▼
┌──────────────┐        ┌─────────────────────┐
│ costTracker  │        │ Response Headers     │
│ addToTotal   │        │ (rate limit info)    │
│ SessionCost  │        └──────────┬──────────┘
└──────┬───────┘                   │
       │                           ▼
       ▼                ┌─────────────────────┐
┌──────────────┐       │ claudeAiLimits.ts   │
│ modelCost.ts │       │ extractQuotaStatus   │
│ calculateUSD │       │ FromHeaders          │
└──────────────┘       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │ rateLimitMessages.ts │
                       │ UI warning/error     │
                       │ generation           │
                       └─────────────────────┘
```

---

## 2. Pricing Tiers (`utils/modelCost.ts`)

Every model has a `ModelCosts` record with per-million-token rates:

```typescript
type ModelCosts = {
  inputTokens: number              // $ per M input tokens
  outputTokens: number             // $ per M output tokens
  promptCacheWriteTokens: number   // $ per M cache write tokens
  promptCacheReadTokens: number    // $ per M cache read tokens
  webSearchRequests: number        // $ per web search request
}
```

### Pricing Tiers (per million tokens)

| Tier | Input | Output | Cache Write | Cache Read | Models |
|------|-------|--------|-------------|------------|--------|
| `COST_TIER_3_15` | $3 | $15 | $3.75 | $0.30 | Sonnet 3.5v2, 3.7, 4, 4.5, 4.6 |
| `COST_TIER_15_75` | $15 | $75 | $18.75 | $1.50 | Opus 4, 4.1 |
| `COST_TIER_5_25` | $5 | $25 | $6.25 | $0.50 | Opus 4.5, 4.6 (normal) |
| `COST_TIER_30_150` | $30 | $150 | $37.50 | $3.00 | Opus 4.6 (fast mode) |
| `COST_HAIKU_35` | $0.80 | $4 | $1.00 | $0.08 | Haiku 3.5 |
| `COST_HAIKU_45` | $1 | $5 | $1.25 | $0.10 | Haiku 4.5 |

Web search: $0.01 per request (all tiers).

**Unknown model fallback**: Uses `COST_TIER_5_25` ($5/$25) as default. Sets `hasUnknownModelCost` flag.

### Cost Calculation

```typescript
function tokensToUSDCost(modelCosts, usage): number {
  return (usage.input_tokens / 1_000_000) * modelCosts.inputTokens
       + (usage.output_tokens / 1_000_000) * modelCosts.outputTokens
       + (usage.cache_read_input_tokens / 1_000_000) * modelCosts.promptCacheReadTokens
       + (usage.cache_creation_input_tokens / 1_000_000) * modelCosts.promptCacheWriteTokens
       + (usage.web_search_requests * modelCosts.webSearchRequests)
}
```

Opus 4.6 fast mode: Dynamically selects `COST_TIER_30_150` when `usage.speed === 'fast'`.

---

## 3. Session Cost Accumulator (`cost-tracker.ts`)

### State Structure

```typescript
type StoredCostState = {
  totalCostUSD: number
  totalAPIDuration: number
  totalAPIDurationWithoutRetries: number
  totalToolDuration: number
  totalLinesAdded: number
  totalLinesRemoved: number
  lastDuration: number | undefined
  modelUsage: { [modelName: string]: ModelUsage } | undefined
}
```

### ModelUsage Per-Model Tracking

```typescript
type ModelUsage = {
  inputTokens: number
  outputTokens: number
  cacheReadInputTokens: number
  cacheCreationInputTokens: number
  webSearchRequests: number
  costUSD: number
  contextWindow: number
  maxOutputTokens: number
}
```

### Key Functions

| Function | Purpose |
|----------|---------|
| `addToTotalSessionCost(cost, usage, model)` | Main entry — adds cost + usage to session total, recurses for advisor usage |
| `saveCurrentSessionCosts(fpsMetrics?)` | Persists to project config (called on session switch) |
| `restoreCostStateForSession(sessionId)` | Restores from project config on resume |
| `formatTotalCost()` | Human-readable summary for CLI output |

### Persistence Strategy

Costs are saved to **project config** (`getCurrentProjectConfig()`) with fields like `lastCost`, `lastAPIDuration`, `lastModelUsage`, `lastSessionId`. On resume, only restores if `sessionId` matches — prevents stale data.

### Cost Output Hook (`costHook.ts`)

```typescript
function useCostSummary(getFpsMetrics?): void {
  // On process exit:
  // 1. If console billing access → print cost summary to stdout
  // 2. Always → saveCurrentSessionCosts() to project config
}
```

Only prints costs if `hasConsoleBillingAccess()` — API key users see costs; Claude.ai subscribers don't (they have subscription-based billing).

### Advisor Cost Tracking

The system recursively tracks "advisor" tool costs — when the model uses an internal advisor model (e.g., for classification), those tokens are also accumulated into the session cost.

---

## 4. Rate Limiting System (`services/claudeAiLimits.ts`)

### Rate Limit Types

```typescript
type RateLimitType =
  | 'five_hour'       // Session limit (5h window)
  | 'seven_day'       // Weekly limit
  | 'seven_day_opus'  // Weekly Opus-specific limit
  | 'seven_day_sonnet'// Weekly Sonnet-specific limit
  | 'overage'         // Extra usage spending limit
```

### Quota Status

```typescript
type QuotaStatus = 'allowed' | 'allowed_warning' | 'rejected'
```

### Limit State Object

```typescript
type ClaudeAILimits = {
  status: QuotaStatus
  unifiedRateLimitFallbackAvailable: boolean  // Can fall back to cheaper model?
  resetsAt?: number                           // Unix timestamp
  rateLimitType?: RateLimitType               // Which limit window
  utilization?: number                        // 0-1 fraction used
  overageStatus?: QuotaStatus                 // Overage window status
  overageResetsAt?: number                    // Overage reset timestamp
  overageDisabledReason?: OverageDisabledReason
  isUsingOverage?: boolean                    // In overage mode?
  surpassedThreshold?: number                 // Server-side threshold crossed
}
```

### Overage Disabled Reasons

```typescript
type OverageDisabledReason =
  | 'overage_not_provisioned'      // Not set up for org/tier
  | 'org_level_disabled'           // Org-level toggle off
  | 'org_level_disabled_until'     // Temporarily disabled
  | 'out_of_credits'               // No credits left
  | 'seat_tier_level_disabled'     // Tier doesn't allow overage
  | 'member_level_disabled'        // Account-specific disable
  | 'seat_tier_zero_credit_limit'  // Zero credit limit on tier
  | 'group_zero_credit_limit'      // Group has zero limit
  | 'member_zero_credit_limit'     // Member has zero limit
  | 'org_service_level_disabled'   // Org service disabled
  | 'org_service_zero_credit_limit'// Org service zero limit
  | 'no_limits_configured'         // No limits set up
  | 'unknown'                      // Fallback
```

### How Limits Are Extracted

**From API response headers:**

| Header | Maps To |
|--------|---------|
| `anthropic-ratelimit-unified-status` | `status` (allowed/allowed_warning/rejected) |
| `anthropic-ratelimit-unified-reset` | `resetsAt` |
| `anthropic-ratelimit-unified-fallback` | `unifiedRateLimitFallbackAvailable` |
| `anthropic-ratelimit-unified-representative-claim` | `rateLimitType` |
| `anthropic-ratelimit-unified-overage-status` | `overageStatus` |
| `anthropic-ratelimit-unified-overage-reset` | `overageResetsAt` |
| `anthropic-ratelimit-unified-overage-disabled-reason` | `overageDisabledReason` |
| `anthropic-ratelimit-unified-{5h\|7d}-utilization` | Raw utilization |
| `anthropic-ratelimit-unified-{5h\|7d}-surpassed-threshold` | Early warning trigger |

**From 429 errors:**
Same header extraction, but `status` is forced to `'rejected'`.

### Early Warning System

Two-layer early warning to alert users before they hit limits:

**Layer 1: Server-side (`surpassed-threshold` header)**
- API sends `anthropic-ratelimit-unified-{claim}-surpassed-threshold` header
- Directly maps to `allowed_warning` status

**Layer 2: Client-side time-relative fallback**
```typescript
const EARLY_WARNING_CONFIGS = [
  {
    rateLimitType: 'five_hour',
    windowSeconds: 5 * 60 * 60,   // 18,000s
    thresholds: [{ utilization: 0.9, timePct: 0.72 }]
    // Warn if 90%+ used and less than 72% of window elapsed
  },
  {
    rateLimitType: 'seven_day',
    windowSeconds: 7 * 24 * 60 * 60,  // 604,800s
    thresholds: [
      { utilization: 0.75, timePct: 0.6 },   // 75% at 60% time
      { utilization: 0.5,  timePct: 0.35 },  // 50% at 35% time
      { utilization: 0.25, timePct: 0.15 },  // 25% at 15% time
    ]
  }
]
```

Logic: warn if `utilization >= threshold.utilization AND timeProgress <= threshold.timePct`. Catches users burning through quota faster than the window allows.

### Quota Check Flow

1. On startup (interactive mode): `checkQuotaStatus()` sends a minimal API request (`max_tokens: 1`, message: `"quota"`) just to read response headers
2. Every subsequent API response updates limits via `extractQuotaStatusFromHeaders()`
3. On 429 errors: `extractQuotaStatusFromError()` updates limits
4. Status change listeners (`statusListeners`) notify UI components

### Status Listener Pattern

```typescript
const statusListeners: Set<StatusChangeListener> = new Set()

function emitStatusChange(limits: ClaudeAILimits) {
  currentLimits = limits
  statusListeners.forEach(listener => listener(limits))
  // Also logs telemetry: tengu_claudeai_limits_status_changed
}
```

---

## 5. Rate Limit Messages (`services/rateLimitMessages.ts`)

### Message Classification

```typescript
const RATE_LIMIT_ERROR_PREFIXES = [
  "You've hit your",
  "You've used",
  "You're now using extra usage",
  "You're close to",
  "You're out of extra usage",
]
```

### Message Flow

```
getRateLimitMessage(limits, model)
  ├── isUsingOverage? → check overageStatus for warning
  ├── status === 'rejected'? → getLimitReachedText()
  ├── status === 'allowed_warning'?
  │   ├── utilization < 0.7? → suppress (stale data after reset)
  │   ├── Team/Enterprise + overage enabled + non-billing? → suppress
  │   └── getEarlyWarningText()
  └── else → null (no message)
```

### Error Messages

- `"You've hit your {limit} · resets {time}"` — general limit reached
- `"You're out of extra usage · resets {time}"` — overage exhausted
- Internal Ant employees get: `"...post in #briarpatch-cc. /reset-limits"`

### Warning Messages

- `"You've used {X}% of your {limit} · resets {time}"`
- `"Approaching {limit} · resets {time}"`
- Upsell commands: `/upgrade` (Pro/Max), `/extra-usage` (Team/Enterprise)

### Overage Transition

When entering overage: `"You're now using extra usage · Your {limit} resets {time}"`

---

## 6. Rate Limit Mocking (`services/rateLimitMocking.ts` + `mockRateLimits.ts`)

Internal testing system for Ant employees (`/mock-limits` command):

- `shouldProcessMockLimits()` — checks if mock mode is active
- `applyMockHeaders(headers)` — replaces real headers with mock data
- `checkMockRateLimitError()` — simulates 429 errors
- Special handling: Opus limits only trigger for Opus models (allows Sonnet fallback simulation)
- Fast mode mock rate limits with countdown/expiry
- 882-line `mockRateLimits.ts` provides detailed mock scenarios

---

## 7. Policy Limits (`services/policyLimits/`)

Enterprise/org-level feature restrictions fetched from a remote API.

### API

- **Endpoint**: `{BASE_API_URL}/api/claude_code/policy_limits`
- **Method**: GET with ETag-based caching (`If-None-Match`)
- **Auth**: API key or OAuth Bearer token
- **Response schema**:
  ```typescript
  type PolicyLimitsResponse = {
    restrictions: Record<string, { allowed: boolean }>
  }
  ```

### Eligibility

| User Type | Eligible? |
|-----------|-----------|
| Console (API key) | Yes |
| OAuth (Claude.ai) Team | Yes |
| OAuth (Claude.ai) Enterprise | Yes |
| OAuth (Claude.ai) Pro/Max | No |
| Third-party provider | No |
| Custom base URL | No |

### Caching Strategy

1. **Session cache** (in-memory): Checked first
2. **File cache** (`~/.claude/policy-limits.json`): Disk backup with SHA-256 checksums
3. **ETag**: Server-side 304 Not Modified support
4. **Background polling**: Every 60 minutes
5. **Fail open**: If fetch fails and no cache exists → all policies allowed
6. **Exception**: `allow_product_feedback` fails **closed** during essential-traffic-only mode

### Retry Logic

- Max 5 retries with exponential backoff
- Auth errors → no retry (skipRetry: true)
- Network/timeout → retry
- 404 → empty restrictions (no policies configured)

### Policy Check

```typescript
function isPolicyAllowed(policy: string): boolean {
  const restrictions = getRestrictionsFromCache()
  if (!restrictions) {
    // Fail open (except HIPAA policies during essential-traffic-only)
    return true
  }
  return restrictions[policy]?.allowed ?? true  // Unknown policy = allowed
}
```

### Lifecycle

1. `initializePolicyLimitsLoadingPromise()` — called during init
2. `loadPolicyLimits()` — fetch + cache + start background polling
3. `refreshPolicyLimits()` — on auth state change
4. `clearPolicyLimitsCache()` — on logout

---

## 8. Token Estimation (`services/tokenEstimation.ts`)

495-line module for counting tokens before sending to API.

### Key Features

- **Multi-provider support**: Direct API, AWS Bedrock, Google Vertex
- **Thinking block handling**: Strips thinking blocks before counting (separate budget)
- **Tool search field stripping**: Removes `caller` and `tool_reference` fields that only work with tool search beta
- **Attachment normalization**: Converts attachments before counting
- **VCR integration**: `withTokenCountVCR()` for replay in tests

### Constants

```typescript
const TOKEN_COUNT_THINKING_BUDGET = 1024  // Minimal thinking budget for count
const TOKEN_COUNT_MAX_TOKENS = 2048       // Must be > thinking budget
```

---

## 9. Key Takeaways

1. **6 pricing tiers** ranging from $0.80/$4 (Haiku 3.5) to $30/$150 (Opus 4.6 fast mode)
2. **Overage system** with 12+ disable reasons — complex org/team/seat/credit hierarchy
3. **Dual early warning** — server-side threshold headers + client-side time-relative calculation
4. **Policy limits** — enterprise admin-configured restrictions, cached locally with 1-hour polling
5. **Fail-open design** — if limits can't be fetched, continues without restrictions (except HIPAA policies)
6. **Cost persistence** — saved to project config per session, restored on resume
7. **Mock system** — internal `/mock-limits` command for testing rate limit UX
8. **Advisor cost recursion** — sub-model calls (classifiers, etc.) are accumulated into session cost
