# 18 — API Client & Multi-Provider Architecture

Complete deconstruction of how Claude Code abstracts across 4 cloud providers (first-party, AWS Bedrock, Google Vertex, Azure Foundry) with unified authentication.

---

## 1. Provider Architecture

```
getAPIProvider()
  ├── CLAUDE_CODE_USE_BEDROCK? → 'bedrock'
  ├── CLAUDE_CODE_USE_VERTEX?  → 'vertex'
  ├── CLAUDE_CODE_USE_FOUNDRY? → 'foundry'
  └── (default)                → 'firstParty'
```

```typescript
type APIProvider = 'firstParty' | 'bedrock' | 'vertex' | 'foundry'
```

Detection is pure env-var based. A single binary supports all providers — no build-time branching.

---

## 2. Client Factory (`services/api/client.ts`, 389 lines)

### Unified Client Creation

```typescript
async function getAnthropicClient({
  apiKey?, maxRetries, model?, fetchOverride?, source?
}): Promise<Anthropic>
```

Returns an `Anthropic`-typed client regardless of provider. The actual SDK class differs:
- First-party: `new Anthropic(args)`
- Bedrock: `new AnthropicBedrock(args) as unknown as Anthropic`
- Vertex: `new AnthropicVertex(args) as unknown as Anthropic`
- Foundry: `new AnthropicFoundry(args) as unknown as Anthropic`

**Type system note**: The cast `as unknown as Anthropic` is intentional — the provider SDKs have incompatible types but identical runtime APIs.

### Common Client Config

All providers share:
```typescript
{
  defaultHeaders: {
    'x-app': 'cli',
    'User-Agent': getUserAgent(),
    'X-Claude-Code-Session-Id': getSessionId(),
    // + custom headers from ANTHROPIC_CUSTOM_HEADERS
    // + container/session IDs for CCR mode
    // + client app ID for SDK consumers
  },
  maxRetries,           // SDK-level retries (separate from withRetry)
  timeout: API_TIMEOUT_MS || 600_000,  // 10 min default
  fetchOptions: getProxyFetchOptions(), // Proxy support
}
```

### Per-Provider Details

#### First-Party (Anthropic Direct)
```typescript
new Anthropic({
  apiKey: subscriber ? null : (apiKey || getAnthropicApiKey()),
  authToken: subscriber ? oAuthAccessToken : undefined,
  ...
})
```

- OAuth subscribers use `authToken` (Bearer token)
- API key users use `apiKey`
- `null` apiKey + no authToken triggers error

#### AWS Bedrock
```typescript
new AnthropicBedrock({
  awsRegion: model === smallFastModel
    ? ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION || getAWSRegion()
    : getAWSRegion(),
  awsAccessKey: cachedCredentials.accessKeyId,
  awsSecretKey: cachedCredentials.secretAccessKey,
  awsSessionToken: cachedCredentials.sessionToken,
  skipAuth: CLAUDE_CODE_SKIP_BEDROCK_AUTH,
  ...
})
```

- Per-model region override for small/fast model (Haiku on different region)
- Bearer token support via `AWS_BEARER_TOKEN_BEDROCK`
- Credential refresh before client creation

#### Google Vertex AI
```typescript
new AnthropicVertex({
  region: getVertexRegionForModel(model),  // Per-model regions
  googleAuth: new GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    projectId: ANTHROPIC_VERTEX_PROJECT_ID,  // Fallback only
  }),
  ...
})
```

- Per-model region env vars: `VERTEX_REGION_CLAUDE_*`
- Falls back to `CLOUD_ML_REGION`, then `us-east5`
- Project ID only used as fallback to prevent 12s metadata server timeout
- `CLAUDE_CODE_SKIP_VERTEX_AUTH` for testing/proxy scenarios

#### Azure Foundry
```typescript
new AnthropicFoundry({
  azureADTokenProvider: !ANTHROPIC_FOUNDRY_API_KEY
    ? getBearerTokenProvider(new DefaultAzureCredential(), 'https://cognitiveservices.azure.com/.default')
    : undefined,
  ...
})
```

- API key auth via `ANTHROPIC_FOUNDRY_API_KEY`
- Azure AD auth via `DefaultAzureCredential` (env vars, managed identity, CLI)
- Resource name or full base URL support

---

## 3. Authentication System (`utils/auth.ts`, 2,002 lines)

### Auth Decision Tree

```
isAnthropicAuthEnabled()?
  │
  ├── YES → Check for OAuth tokens
  │   ├── getClaudeAIOAuthTokens() → has accessToken?
  │   │   ├── YES → isOAuthTokenExpired()?
  │   │   │   ├── YES → refreshOAuthToken()
  │   │   │   └── NO → use existing token
  │   │   └── NO → no auth available
  │   └── Subscription types: pro, max, team, enterprise
  │
  └── API Key path
      ├── ANTHROPIC_AUTH_TOKEN env var
      ├── getApiKeyFromApiKeyHelper() (external process)
      ├── ANTHROPIC_API_KEY env var
      ├── Secure storage (macOS Keychain, etc.)
      └── Legacy config file
```

### Managed vs User Context

```typescript
function isManagedOAuthContext(): boolean {
  return CLAUDE_CODE_REMOTE || CLAUDE_CODE_ENTRYPOINT === 'claude-desktop'
}
```

CCR and Claude Desktop sessions **never fall back** to user's API key config — prevents cross-org credential leakage.

### Token Refresh Flow

1. Check `isOAuthTokenExpired(accessToken)`
2. If expired: `refreshOAuthToken(refreshToken)` → new access + refresh tokens
3. On 401: `handleOAuth401Error(failedAccessToken)` → force refresh even if not expired
4. On 403 "token revoked": Same as 401 (another process may have refreshed)

### API Key Helper

External process that provides API keys dynamically:
```typescript
async function getApiKeyFromApiKeyHelper(isNonInteractive): Promise<string | null>
// Memoized with 5-minute TTL
// Spawns command from config: apiKeyHelper setting
```

### Secure Storage

Platform-specific key storage:
- **macOS**: Keychain (`security` command)
- **Linux**: Secret Service API (libsecret)
- **Windows**: Credential Manager
- **Fallback**: Encrypted file in `~/.claude/`

---

## 4. Model Resolution

### Provider → Region Mapping

| Provider | Region Config |
|----------|-------------|
| First-party | `ANTHROPIC_BASE_URL` (default: `api.anthropic.com`) |
| Bedrock | `AWS_REGION` / `AWS_DEFAULT_REGION` (default: `us-east-1`), per-model override |
| Vertex | `VERTEX_REGION_CLAUDE_*` → `CLOUD_ML_REGION` → `us-east5` |
| Foundry | `ANTHROPIC_FOUNDRY_RESOURCE` / `ANTHROPIC_FOUNDRY_BASE_URL` |

### Model String Normalization

Model strings are normalized to canonical short names (e.g., `claude-sonnet-4-20250514` → `claude-sonnet-4`). The system handles:
- First-party model IDs (e.g., `claude-3-5-sonnet-20241022`)
- Bedrock inference profiles (e.g., `arn:aws:bedrock:...:inference-profile/...`)
- Vertex model paths (e.g., `publish/google/models/claude-sonnet-4`)

---

## 5. Custom Headers & Request ID

```typescript
// Per-request unique ID for correlation
headers.set('x-client-request-id', randomUUID())

// Custom headers via environment
ANTHROPIC_CUSTOM_HEADERS = "X-Custom: value\nX-Another: value2"
```

Custom headers support newline-separated curl-style format. Only injected for first-party API (not Bedrock/Vertex/Foundry — unknown headers risk rejection).

---

## 6. Key Takeaways

1. **Single binary, 4 providers** — No build variants; provider selection is runtime via env vars
2. **Type erasure** — All provider SDKs cast to `Anthropic` type; compatible runtime APIs, incompatible types
3. **Auth-aware retry** — The retry loop handles token refresh, credential cache clearing, and client re-creation transparently
4. **Per-model region** — Bedrock and Vertex allow different regions for different models (e.g., Haiku closer to user)
5. **Metadata server protection** — Vertex client provides projectId fallback to prevent 12s GCE metadata timeout
6. **Managed context isolation** — CCR/Desktop sessions never use user's API key, preventing credential leakage
7. **API key helper** — External process integration for dynamic key provisioning (enterprise SSO, vault systems)
8. **Request correlation** — Every API call gets a UUID for log correlation between client and server
