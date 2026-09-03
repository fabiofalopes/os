
# Spec: Unified Agent Harness CLI

> **⚑ 2026-08-05 DECISION — this spec is the north star, not the starting point.**
> Stage 1 was implemented thin around the existing UPB proxy: `upb` CLI + `~/.config/upb/routes.yaml`
> (see [[Claude Code Routes — upb CLI Decision & Runbook]]). Naming settled: the tool is `upb`,
> NOT `harness` (collides with the `_harness/` cron-swarm vocabulary). Stage 2 (JSON route API for
> the swarm, session ledger, picker) and Stage 3 (phases 3–5 below) proceed only on evidence.
> Superseded in part: Phase 0 inventory + Phase 1 "minimum viable router" are DONE as `upb`.

**Status:** Draft v0.1 (north star; Stage 1 shipped thin)  
**Working name:** ~~`harness`~~ → `upb` (decided 2026-08-05)  
**Primary interface:** `claude` compatibility shim  
**Scope:** A provider-agnostic, policy-controlled coding-agent launcher that replaces static provider/model aliases with dynamic discovery, routing, session continuity, and auditable execution.

***

## 1. Problem statement

The current environment has accumulated many static launchers:

```text
claude-ollama
claude-ollama-kimi26
claude-ollama-minimax3
claude-ollama-qwen3c480
claude-deepseek
claude-zen
...
```

This is operational debt, not a control plane.

Each alias hard-codes a provider, endpoint, model, credential assumption, and sometimes model-specific behavior. It becomes stale when:

- A provider key expires or has no usable quota.
- A model is removed, renamed, rate-limited, or becomes too expensive.
- A local endpoint is offline.
- A tunnel, GPU node, or llama.cpp server moves.
- A model is unsuitable for the current coding task.
- The underlying coding harness changes its environment-variable contract.

The target is one command that makes a live decision from verified runtime state:

```bash
claude
```

or explicitly:

```bash
harness run
```

The command should discover usable providers, present an intelligent interactive selection when needed, choose a policy-approved model, export the correct compatibility variables, launch the underlying coding harness, and record what happened.

The system must preserve user control. It must never silently send source code to an unapproved remote provider.

Your local OpenAI-compatible endpoints, including llama.cpp, are a first-class provider category—not a hack or fallback.[1]

***

## 2. Product definition

`harness` is a local control-plane CLI for coding agents.

It is **not**:

- A new foundation model.
- A cloud service.
- A provider reseller.
- A hidden proxy that captures prompts.
- A replacement for OpenCode, Claude Code, Codex CLI, or other harnesses.
- A permanently hard-coded list of model aliases.

It **is**:

- A declarative provider and model registry.
- A health-aware endpoint resolver.
- A policy engine for privacy, cost, capabilities, and locality.
- A compatibility adapter for different coding-agent harnesses.
- A session ledger and local observability layer.
- An interactive TUI and scriptable JSON CLI.
- A stable UX boundary around volatile upstream tools.

The architecture separates:

1. **Harness:** the coding-agent executable and its native behavior.
2. **Provider:** an inference account, gateway, local server, or cloud endpoint.
3. **Endpoint:** a concrete reachable API base URL.
4. **Model:** a model identifier exposed by an endpoint.
5. **Profile:** a named user intent such as `local`, `private`, `cheap`, `fast`, or `best`.
6. **Policy:** mandatory constraints that may not be bypassed accidentally.
7. **Session:** a continuity record linking project, harness, provider, model, run metadata, and outcomes.

***

## 3. Design principles

### One command, many routes

A person should not need to remember which of thirty scripts maps to a model. The CLI resolves capability and availability at runtime.

```bash
claude
claude --profile local
claude --profile private
claude --model qwen3-coder
claude --provider llama-local
```

### Declarative over aliases

All routing data belongs in versionable configuration, not shell aliases.

```text
~/.config/harness/
├── config.yaml
├── providers.yaml
├── policies.yaml
├── secrets.env
├── cache/
├── sessions/
└── logs/
```

### Local-first and explicit egress

A local model or LAN endpoint must be selectable and preferred by policy. Any request that would leave the machine or trusted LAN must be visible in the UI and recorded in logs.

### Health is evidence, not hope

A configured provider is not “available” merely because an API key exists. Availability requires recent successful discovery and/or a bounded live probe.

### Capability-aware routing

A coding task is not just “chat completion.” Models may differ in tool use, context size, streaming reliability, structured outputs, reasoning, vision, and cost.

### Fail closed on ambiguity

If routing cannot determine whether an endpoint is compliant with policy, it should not silently choose it.

### Keep the agent harness replaceable

The provider router must not depend on one vendor’s private client internals. Adapters translate the canonical route into each harness’s configuration and environment.

***

## 4. User experience

## Core commands

```bash
# Start using the policy-selected best route
claude

# Open an interactive provider/model picker
claude pick

# Show live service and model state
claude status

# List only genuinely usable routes
claude models

# Start a session explicitly
claude --profile local
claude --profile private
claude --profile cheap
claude --profile fast
claude --profile best

# Force a known route, still subject to hard policy
claude --provider llama-local --model glm-4.7-flash

# Explain selection without launching
claude route --explain

# Continue an earlier session
claude resume
claude resume <session-id>

# Probe all endpoints now
claude doctor
claude doctor --deep

# Machine-readable interfaces
harness status --json
harness models --json
harness route --profile private --json
```

## Default flow

Running:

```bash
claude
```

should perform the following:

1. Load configuration and policy.
2. Identify project context, Git repository, branch, and directory.
3. Load cached health state.
4. Probe stale or unknown candidates within a bounded time budget.
5. Build the eligible route set.
6. Apply hard policies: egress, privacy, disabled providers, cost ceilings, model deny-lists.
7. Rank remaining models by profile and task characteristics.
8. If confidence is high, show the selected route and launch.
9. If multiple routes are similarly appropriate, open a compact TUI picker.
10. Export temporary adapter-specific environment variables.
11. Launch the configured agent harness as a child process.
12. Capture only operational metadata unless content logging is explicitly enabled.
13. Record session outcome and update health state.

Example terminal output:

```text
Harness route selected

  Harness:    Claude-compatible adapter
  Profile:    private
  Provider:   llama-local
  Endpoint:   http://127.0.0.1:8080/v1
  Model:      glm-4.7-flash
  Privacy:    local machine
  Health:     healthy, 18 ms probe
  Context:    32k
  Tools:      adapter-compatible
  Cost:       local / unmetered

Launching session: hs_20260729_0001
```

If no valid route exists:

```text
No eligible route for profile "private".

Healthy but blocked:
  prime-inference / model-x    blocked: remote egress prohibited
  zen / model-y                blocked: provider privacy policy unknown

Unhealthy:
  llama-local                  connection refused
  cloud-provider-a             authentication failed

Try:
  claude doctor
  claude --profile best
  claude pick
```

***

## 5. Canonical configuration

Use YAML for the user-edited control plane and JSON only where an upstream tool requires it.

```yaml
# ~/.config/harness/config.yaml
version: 1

defaults:
  harness: claude-compatible
  profile: balanced
  health_ttl_seconds: 300
  probe_timeout_seconds: 4
  max_parallel_probes: 6
  session_retention_days: 90

paths:
  state_dir: ~/.local/state/harness
  cache_dir: ~/.cache/harness
  logs_dir: ~/.local/state/harness/logs

ui:
  color: auto
  interactive_when_ambiguous: true
  show_route_before_launch: true
  remember_project_selection: true

telemetry:
  enabled: false
  log_prompt_content: false
  log_tool_content: false
  local_only: true
```

```yaml
# ~/.config/harness/providers.yaml
providers:
  llama-local:
    kind: openai-compatible
    enabled: true
    trust_zone: local
    base_url: http://127.0.0.1:8080/v1
    auth:
      type: none
    discovery:
      models_path: /models
    healthcheck:
      type: models
    tags: [local, llama-cpp, gpu]
    models:
      glm-4.7-flash:
        capabilities: [chat, code, stream]
        context_window: 32768
        cost:
          input_per_million: 0
          output_per_million: 0
        aliases: [glm-fast, local-fast]

  lan-vllm:
    kind: openai-compatible
    enabled: true
    trust_zone: lan
    base_url: http://192.168.80.8:8000/v1
    auth:
      type: env
      env: LAN_VLLM_API_KEY
    discovery:
      models_path: /models
    healthcheck:
      type: models
    tags: [lan, vllm, nvidia]
    models: auto

  opencode-zen:
    kind: openai-compatible
    enabled: true
    trust_zone: remote-approved
    base_url: https://opencode.ai/zen/v1
    auth:
      type: env
      env: ZEN_API_KEY
    discovery:
      models_path: /models
    healthcheck:
      type: models
    tags: [remote, shared-account]
    models: auto

  prime-inference:
    kind: openai-compatible
    enabled: false
    trust_zone: remote-approved
    base_url: https://api.pinference.ai/api/v1
    auth:
      type: env
      env: PRIME_API_KEY
    discovery:
      models_path: /models
    healthcheck:
      type: models
    tags: [remote, on-demand]
    models: auto
```

OpenAI-compatible provider definitions fit local llama.cpp and remote inference services under the same interface, while retaining metadata that matters for routing.[1][2]

```yaml
# ~/.config/harness/policies.yaml
policies:
  default:
    allowed_trust_zones:
      - local
      - lan
      - remote-approved
    max_input_cost_per_million: 20
    max_output_cost_per_million: 60
    require_streaming: true
    require_tool_compatibility: true

  local:
    allowed_trust_zones: [local]
    fallback: deny

  private:
    allowed_trust_zones: [local, lan]
    fallback: deny
    require_no_training_retention: true

  cheap:
    allowed_trust_zones: [local, lan, remote-approved]
    max_estimated_session_cost: 2.00
    prefer_low_cost: true

  fast:
    allowed_trust_zones: [local, lan, remote-approved]
    max_p95_probe_latency_ms: 1200
    prefer_latency: true

  best:
    allowed_trust_zones: [local, lan, remote-approved]
    prefer_capability: true
    require_tool_compatibility: true

  restricted-project:
    match:
      paths:
        - "~/work/client-a/**"
        - "~/secrets/**"
    allowed_trust_zones: [local]
    fallback: deny
```

***

## 6. Provider model

Every provider gets normalized into a canonical runtime record:

```json
{
  "provider_id": "llama-local",
  "endpoint_id": "llama-local/default",
  "kind": "openai-compatible",
  "trust_zone": "local",
  "base_url": "http://127.0.0.1:8080/v1",
  "auth_state": "available",
  "health_state": "healthy",
  "last_checked_at": "2026-07-29T00:05:00+01:00",
  "models": [
    {
      "id": "glm-4.7-flash",
      "capabilities": ["chat", "code", "stream"],
      "context_window": 32768,
      "tool_compatibility": "adapter-tested",
      "cost": {
        "input_per_million": 0,
        "output_per_million": 0,
        "currency": "EUR"
      }
    }
  ]
}
```

## Health states

| State | Meaning | Eligible for default routing |
|---|---|---|
| `healthy` | Authenticated/discovered and recent probe succeeded | Yes |
| `degraded` | Reachable but elevated latency, partial capability, or recent transient errors | Only if policy permits |
| `unknown` | Never probed or health cache expired | Probe before use |
| `auth_failed` | Key missing, expired, rejected, or wrong scope | No |
| `unreachable` | DNS, tunnel, network, or connection failure | No |
| `rate_limited` | Provider returned rate or quota exhaustion | No until retry window |
| `disabled` | Intentionally disabled in config | No |
| `policy_blocked` | Technically valid but excluded by project/profile rules | No |

A route is only “available” when **configuration, credentials, reachability, model discovery, and policy eligibility** all succeed.

***

## 7. Health-check strategy

The router must not spam providers or burn quota merely to populate a menu.

### Probe tiers

1. **Tier 0: configuration validation**  
   Parse config, resolve secret references, validate URLs, detect duplicate IDs.

2. **Tier 1: passive cache**  
   Reuse a recent successful model inventory and health record until TTL expires.

3. **Tier 2: cheap liveness probe**  
   Prefer `GET /v1/models`, provider status endpoint, or a non-billable metadata endpoint.

4. **Tier 3: capability probe**  
   Optional minimal request for streaming, tools, JSON mode, or endpoint quirks. Cached far longer and invoked only on setup, upgrade, or failure.

5. **Tier 4: real task fallback**  
   If a route fails during execution, classify the failure and retry only when the policy allows a fallback.

### Circuit breaker

For every `(provider, endpoint, model)` route:

```text
closed  -> normal operation
open    -> temporarily excluded after repeated failures
half-open -> one controlled retry after cooldown
```

Suggested defaults:

```yaml
health:
  failures_before_open: 3
  open_cooldown_seconds: 120
  degraded_latency_ms: 2000
  quota_retry_seconds: 900
```

No endless automatic retry loops. A failed cloud provider should not turn a simple coding session into uncontrolled request churn.

***

## 8. Routing engine

## Eligibility stage

The engine first eliminates routes that violate non-negotiable rules:

```text
enabled
AND credential usable
AND health is acceptable
AND trust zone allowed
AND model capability requirements met
AND estimated spend within limits
AND adapter supports selected harness
AND project policy permits route
```

## Ranking stage

After eligibility, score routes based on the selected profile.

A generic scoring function:

\[
S(r) =
w_c C(r) +
w_l L(r) +
w_p P(r) +
w_q Q(r) +
w_k K(r) -
w_e E(r)
\]

Where:

- \(C(r)\): model capability fit.
- \(L(r)\): latency and availability score.
- \(P(r)\): privacy and locality preference.
- \(Q(r)\): quota headroom.
- \(K(r)\): cost efficiency.
- \(E(r)\): expected failure or instability penalty.

The exact coefficients belong in config, not source code:

```yaml
routing:
  profiles:
    balanced:
      weights:
        capability: 0.35
        latency: 0.20
        privacy: 0.20
        quota: 0.10
        cost: 0.10
        reliability: 0.05

    local:
      weights:
        capability: 0.30
        latency: 0.25
        privacy: 0.40
        quota: 0.00
        cost: 0.05
```

## Task classification

Routing should begin simple and become more sophisticated only with evidence.

Initial task classes:

- `interactive`: normal coding loop, low startup latency matters.
- `small-edit`: focused changes, cheap and fast is preferred.
- `repository-analysis`: large context and code comprehension matter.
- `implementation`: tool reliability, edit quality, and context matter.
- `debugging`: reasoning and iterative tool usage matter.
- `planning`: long context and structured output matter.
- `review`: strong reasoning and diff comprehension matter.
- `sensitive`: hard local/LAN policy regardless of capability.

Input sources:

- Explicit flags: `--task review`, `--profile local`.
- Project rules and repository labels.
- Lightweight local classifier or deterministic heuristics.
- Never remote classification by default, because classifying the prompt remotely itself leaks the prompt.

The system should explain why it chose a route:

```bash
claude route --explain
```

```text
Selected: llama-local / glm-4.7-flash

Why:
  + Profile "private" permits local endpoints only
  + Endpoint reachable and healthy, 18 ms probe
  + Model supports streaming and tested tool protocol
  + Context window satisfies repository-analysis minimum
  + Local cost is zero

Excluded:
  - opencode-zen: remote trust zone not permitted
  - prime-inference: provider disabled
  - lan-vllm: endpoint health stale and unavailable
```

***

## 9. Harness adapters

The router must produce a canonical launch contract, then adapters convert it into the harness-specific invocation.

```go
type ResolvedRoute struct {
    Harness       string
    ProviderID    string
    EndpointURL   string
    APIKeyRef     string
    ModelID       string
    ModelAlias    string
    TrustZone     string
    Capabilities  []string
    SessionID     string
    ProjectRoot   string
}
```

```go
type HarnessAdapter interface {
    Name() string
    Validate(route ResolvedRoute) error
    BuildCommand(route ResolvedRoute, args []string) (exec.Cmd, error)
    ParseEvents(stream io.Reader) (<-chan HarnessEvent, error)
    Resume(session SessionRecord) (exec.Cmd, error)
}
```

## Adapter categories

| Adapter | Purpose |
|---|---|
| `claude-compatible` | Launches a Claude-like CLI using an OpenAI/Anthropic-compatible endpoint mapping where supported |
| `opencode` | Writes or overlays provider configuration and launches OpenCode with the resolved model |
| `codex` | Maps a route into Codex-compatible environment/config semantics |
| `aider` | Injects OpenAI-compatible endpoint, model, and key configuration |
| `generic-openai` | For any CLI that accepts `base_url`, API key, and model |

OpenCode is already designed to consume OpenAI-compatible APIs, including custom local providers, so it should be an early adapter target.  The router should not assume that every provider endpoint supports identical chat-completions semantics; endpoint validation and per-adapter capability flags are required.[3][1]

## Launch isolation

Never mutate global shell state permanently.

Instead:

1. Build a temporary per-run directory.
2. Materialize any adapter config there.
3. Pass secrets through inherited environment variables or a file descriptor where supported.
4. Launch the harness child process.
5. Remove temporary config on exit.
6. Retain only redacted metadata in the session record.

Example:

```bash
harness exec \
  --adapter opencode \
  --provider llama-local \
  --model glm-4.7-flash \
  -- opencode
```

***

## 10. Session model

Sessions are the bridge between raw CLI invocation and a real orchestrated development environment.

```yaml
# ~/.local/state/harness/sessions/hs_20260729_0001.yaml
id: hs_20260729_0001
created_at: "2026-07-29T00:05:18+01:00"
ended_at: null

project:
  root: "/home/fabio/src/project-x"
  git_remote_hash: "sha256:..."
  branch: "main"
  worktree: "/home/fabio/src/project-x"

harness:
  adapter: opencode
  binary: "/usr/local/bin/opencode"
  version: "captured-at-launch"

route:
  provider: llama-local
  endpoint_fingerprint: "sha256:..."
  model: glm-4.7-flash
  trust_zone: local
  profile: private

policy:
  effective_policy_hash: "sha256:..."
  egress_allowed: false

outcome:
  exit_code: null
  failure_class: null
  fallback_used: false

metrics:
  started_latency_ms: 18
  duration_seconds: null
  token_usage: null
  estimated_cost_eur: 0
```

## Session principles

- Default logs contain metadata, not prompts, code, tool payloads, or secrets.
- A session binds to a project and worktree so `resume` does not accidentally cross-contaminate projects.
- A route changes only with explicit user approval unless a pre-declared fallback policy authorizes it.
- Session history supports debugging: “Which provider/model was used when this change was made?”
- The system must record fallback events distinctly.

***

## 11. Fallback policy

Fallback is useful only when it is controlled.

```yaml
fallback:
  default:
    enabled: true
    require_same_trust_zone: true
    require_user_confirmation_on_remote_egress: true
    max_attempts: 2

  local:
    enabled: true
    allowed_providers: [llama-local, lan-vllm]
    never_escalate_to_remote: true

  private:
    enabled: true
    same_trust_zone_only: true

  best:
    enabled: true
    require_user_confirmation_on_trust_zone_change: true
```

Example:

```text
llama-local stopped responding during tool execution.

Fallback candidate:
  lan-vllm / qwen3-coder
  Trust zone: LAN
  Reason: same private-policy boundary, healthy, tool-compatible

[Enter] switch   [s] stay/retry   [q] quit
```

The router must never silently switch from `local` to a remote provider. That transition is an egress event and requires an explicit policy allowance plus visible confirmation.

***

## 12. TUI requirements

The TUI is an enhancement, not the only interface. Every function must work through noninteractive flags and JSON output.

## Model picker

```text
Select route: profile=balanced project=project-x

  Provider        Model                Zone       Health      Context   Cost
> llama-local     glm-4.7-flash        local      healthy     32k       local
  lan-vllm        qwen3-coder          lan        healthy     64k       local
  opencode-zen    kimi-k2.6            remote     healthy     128k      quota
  prime-inference model-x              remote     disabled    --        --

Filter: code + tools
Sort: capability
```

## Status dashboard

```text
HARNESS STATUS                                      Updated 00:05:20

LOCAL
  llama-local       healthy   18 ms     1 model      GPU node available
  lan-vllm          degraded  920 ms    4 models     elevated latency

REMOTE APPROVED
  opencode-zen      healthy   210 ms    8 models     quota unknown
  prime-inference   disabled  --        --           disabled by config

POLICY
  Default profile: balanced
  Current project: restricted-project
  Effective egress: local only
```

## UX rules

- Never show providers with invalid auth as normal selectable choices.
- Allow a `--show-blocked` diagnostic mode.
- Display trust zone prominently, not as a hidden detail.
- Distinguish `unknown cost` from `zero cost`.
- Show why a model is unavailable.
- Preserve keyboard-first flow.
- Do not require a TUI when stdin is not a terminal.

***

## 13. Security model

## Secret handling

- Credentials are referenced by environment variable, OS keychain, `age`-encrypted file, `pass`, or a secret manager adapter.
- Plain API keys must not be written to session logs, generated configs, shell history, or process arguments.
- Redact bearer tokens and known credential patterns in diagnostics.
- Provide `harness secrets doctor` to identify insecure references.

## Egress control

The router owns an explicit trust-zone model:

```text
local            loopback / local Unix socket
lan              configured RFC1918 or trusted overlay networks
remote-approved  provider explicitly accepted by user policy
remote-unknown   denied unless explicitly approved
```

Optional enforcement modes:

- `advisory`: annotate and log route trust zone.
- `strict`: deny policy-violating selection.
- `enforced`: run the harness in a network namespace, firewall group, or proxy-only environment that permits only the resolved endpoint.

## Command execution

The agent harness itself may execute commands. The router does not magically make that safe.

The router must:

- Keep provider routing separate from shell-execution approval.
- Pass through the harness’s native permission model.
- Record which adapter and permission mode was used.
- Support a global restrictive mode such as:

```bash
claude --permissions ask
claude --permissions workspace-only
claude --permissions read-only
```

It must not claim that endpoint routing protects against unsafe tool execution.

***

## 14. Data model and API

## Local API

A small local Unix-socket API enables other tools, dashboards, and orchestration agents to query state without parsing terminal output.

```text
~/.local/state/harness/harness.sock
```

Example operations:

```text
GET  /v1/status
GET  /v1/models
POST /v1/route
POST /v1/healthcheck
GET  /v1/sessions
GET  /v1/sessions/{id}
POST /v1/sessions/{id}/resume
```

Request:

```json
{
  "profile": "private",
  "task": "repository-analysis",
  "project_root": "/home/fabio/src/project-x",
  "requirements": {
    "stream": true,
    "tools": true,
    "min_context": 24000
  }
}
```

Response:

```json
{
  "eligible": true,
  "route": {
    "provider": "llama-local",
    "model": "glm-4.7-flash",
    "base_url": "http://127.0.0.1:8080/v1",
    "trust_zone": "local"
  },
  "explanation": [
    "Matches private policy",
    "Healthy endpoint",
    "Meets 24k context requirement"
  ],
  "alternatives": []
}
```

## Orchestrator integration

The orchestrator should call the router, not bypass it.

```text
Orchestrator
      |
      v
Harness local API
      |
      v
Policy + registry + health cache
      |
      v
Resolved route
      |
      v
Harness adapter
      |
      v
Coding agent process
```

The orchestrator may request a route but cannot override hard policy without an explicit privileged mode.

Example orchestration prompt contract:

```text
You are an orchestration agent operating through Harness.

Rules:
1. Never invent provider endpoints, credentials, or model IDs.
2. Resolve execution routes through the Harness API before launching work.
3. Respect the effective project policy and trust-zone restrictions.
4. Use `task`, `requirements`, and `profile` fields to express needs.
5. Treat a denied route as a hard stop; propose alternatives rather than bypassing policy.
6. Persist work artifacts in the project workspace, not in hidden global state.
7. Record major decisions in the task ledger.
8. Do not request or expose provider secrets.
9. Before a trust-zone change, surface the egress implication to the user.
10. Prefer existing sessions for continuity when project and worktree match.
```

***

## 15. Command specification

## `harness status`

```bash
harness status
harness status --json
harness status --watch
```

Outputs provider state, model inventory summary, current project policy, health freshness, and current active sessions.

## `harness models`

```bash
harness models
harness models --available
harness models --profile private
harness models --provider llama-local
harness models --json
```

By default it lists only eligible models, not every configured fantasy endpoint.

## `harness route`

```bash
harness route
harness route --profile fast
harness route --task repository-analysis
harness route --explain
harness route --json
```

Resolves but does not launch.

## `harness doctor`

```bash
harness doctor
harness doctor --deep
harness doctor --provider llama-local
```

Checks:

- Config schema and duplicate route IDs.
- Binary availability and versions.
- Secret references without revealing values.
- Endpoint reachability.
- `/models` discovery.
- Auth response classification.
- Adapter compatibility.
- Trust-zone classification.
- Session storage health.
- Optional minimal capability test.

## `harness config`

```bash
harness config init
harness config validate
harness config edit
harness config migrate
```

## `harness session`

```bash
harness session list
harness session show <id>
harness session resume <id>
harness session gc
```

## Compatibility wrapper

The user-facing `claude` command should be a thin wrapper:

```bash
#!/usr/bin/env sh
exec harness run --adapter claude-compatible "$@"
```

Do not encode provider or model selection in this wrapper.

***

## 16. Implementation plan

## Phase 0: inventory and deletion plan

Goal: understand existing aliases before replacing them.

- Export shell aliases, shell functions, scripts, and PATH-discovered `claude-*` executables.
- Identify which endpoint, model, and credentials each one maps to.
- Create a migration table.
- Mark known-dead routes.
- Keep legacy commands behind an opt-in compatibility package for one release cycle.
- Remove aliases only after `harness route` can reproduce each useful route.

Deliverable:

```text
docs/legacy-command-inventory.md
config/imported-providers.yaml
```

## Phase 1: minimum viable router

Implement:

- YAML config loader and validation.
- OpenAI-compatible provider adapter.
- Environment-secret references.
- `/models` health probe.
- Health cache.
- `status`, `models`, `route`, `doctor`.
- One harness adapter.
- Route explanation.
- JSON output.
- No autonomous fallback yet.

Success criterion:

```bash
claude --provider llama-local --model glm-4.7-flash
```

works through the router without static alias scripts.

## Phase 2: interactive usability

Implement:

- TUI provider/model selector.
- Profiles: `local`, `private`, `cheap`, `fast`, `best`.
- Project-aware policy selection.
- Session records.
- `resume`.
- Per-project remembered selection, subject to policy revalidation.

Success criterion: a normal session starts with `claude` and requires no memorized aliases.

## Phase 3: reliability and policy

Implement:

- Circuit breakers.
- Error classification.
- Controlled fallback.
- Egress confirmation.
- Cost/quota metadata where available.
- Capability probes.
- Strong secret redaction.
- Audit events.

Success criterion: a broken provider is quickly excluded, explained, and never silently replaced with an unapproved remote route.

## Phase 4: orchestrator API

Implement:

- Unix-socket API.
- Task-aware routing.
- Session query/resume endpoints.
- Event stream.
- Signed or capability-scoped local access tokens if multiple local processes/users require separation.
- Agent-facing SDK in Go and Python.

Success criterion: the orchestrator can request a compliant route and launch an agent without owning any provider credential or endpoint logic.

## Phase 5: hardened execution

Implement optional:

- Network namespace or local egress proxy.
- Per-project provider allowlists.
- Local encrypted session metadata.
- Team policy support.
- Reproducible route snapshots attached to CI or task artifacts.

***

## 17. Suggested repository layout

```text
harness/
├── cmd/
│   ├── harness/
│   └── claude/
├── internal/
│   ├── config/
│   ├── provider/
│   │   ├── openaicompat/
│   │   ├── anthropiccompat/
│   │   └── registry/
│   ├── health/
│   ├── route/
│   ├── policy/
│   ├── adapter/
│   │   ├── opencode/
│   │   ├── claudecompat/
│   │   ├── aider/
│   │   └── generic/
│   ├── session/
│   ├── secrets/
│   ├── api/
│   └── tui/
├── pkg/
│   └── client/
├── configs/
│   └── example/
├── docs/
│   ├── architecture.md
│   ├── security.md
│   ├── provider-contract.md
│   ├── adapter-contract.md
│   └── migration.md
├── tests/
│   ├── integration/
│   └── fixtures/
├── go.mod
└── README.md
```

Go is a sensible implementation choice here: static binaries, clean process control, strong concurrency primitives for bounded health checks, and straightforward Unix-socket services.

***

## 18. Test plan

## Unit tests

- Config validation and migration.
- Secret reference resolution.
- Trust-zone classification.
- Policy precedence.
- Route eligibility.
- Profile scoring.
- Circuit-breaker state transitions.
- Redaction behavior.
- Adapter command generation.

## Integration tests

Use mock OpenAI-compatible servers for:

- Healthy `/v1/models`.
- Authentication failure.
- Timeout.
- Malformed JSON.
- Rate limit.
- Streaming unsupported.
- Model missing.
- Slow response.
- Tool-call incompatibility.

## End-to-end tests

- Local llama.cpp route discovery.
- OpenCode adapter launches a configured local endpoint.
- Profile blocks remote provider.
- User accepts/rejects fallback.
- Session resumes in the correct project worktree.
- No secret appears in logs, command lines, session files, or TUI screenshots.
- Legacy alias migration correctly maps supported old commands.

***

## 19. Non-goals

The first versions should deliberately avoid:

- Fine-grained automatic model benchmarking across paid APIs.
- Automatic secret acquisition.
- Autonomous cloud GPU provisioning.
- A centralized SaaS control plane.
- Remote telemetry.
- Sending prompts to a “router model” for classification.
- Reimplementing the coding harness itself.
- Claiming model quality rankings that are not backed by local evaluation data.
- One universal fake protocol that pretends every model supports tools equally well.

Prime Intellect’s inference offering can be treated as another OpenAI-compatible route if enabled, but GPU provisioning and infrastructure control should be a separate provider-control module rather than part of the critical interactive routing path.[2]

***

## 20. Acceptance criteria

The project is successful when all of the following are true:

- `claude` is the only daily command required for normal use.
- No daily workflow depends on `claude-ollama-*` aliases.
- Every displayed provider/model has passed a recent health check or is clearly marked stale.
- Every route has an explicit trust zone.
- Local/private profiles cannot silently route source code to a remote endpoint.
- The selected route is explainable before launch.
- Provider failure results in a clear diagnosis and bounded fallback behavior.
- Sessions record route metadata without recording prompts or secrets by default.
- The orchestrator receives a stable local API and never needs raw provider keys.
- New providers can be added through config plus a provider adapter, without creating new shell commands.
- New coding harnesses can be supported through adapters, without rewriting routing, policy, health, or session logic.
- The system is useful with only one local llama.cpp endpoint and scales cleanly to local, LAN, OpenCode-compatible, and cloud inference routes. OpenCode-style custom OpenAI-compatible configuration already demonstrates the endpoint pattern this router standardizes.[1][3]

***

# Activation prompt for the build agent

```text
You are the principal engineer for a local-first AI coding-agent control plane named Harness.

Your task is to implement the repository described in SPEC.md. Work in small, verified increments. Do not invent provider APIs, model capabilities, CLI arguments, or upstream harness behavior. If an integration detail is uncertain, isolate it behind an adapter interface, add a documented TODO with a reproducible verification command, and continue with the verified core.

Mission:
Replace a graveyard of static provider/model shell aliases with one dynamic `harness` CLI and a thin `claude` compatibility wrapper. The system must discover and health-check configured inference routes, apply locality/privacy/cost/capability policy, resolve an explainable route, launch a coding-agent harness through adapters, and persist redacted session metadata.

Non-negotiable rules:
1. Local-first: remote egress is never silent.
2. Secrets must never appear in argv, logs, generated session files, JSON output, or error text.
3. A configured API key is not proof that a provider is usable. Only verified health state can make a route eligible.
4. Route policy is enforced before ranking. No scoring may override a deny rule.
5. A fallback that changes trust zone requires explicit confirmation unless policy explicitly authorizes it.
6. Do not mutate global provider or harness configuration during normal launches. Use per-run temporary config.
7. All user-facing output must explain unavailable, blocked, degraded, and selected routes.
8. The CLI must support noninteractive operation and JSON output; TUI is optional enhancement, never the only interface.
9. Build the provider router and harness adapter layers independently.
10. Preserve prompts, source code, tool payloads, and raw provider responses by default only in the underlying harness—not in Harness logs.

Implementation order:
1. Create Go module, command skeleton, config schema, sample config, and docs.
2. Implement provider registry and the OpenAI-compatible provider adapter.
3. Implement health checks with cached `/models` discovery, bounded timeouts, and typed failures.
4. Implement policy evaluation and route resolution with `--explain` and `--json`.
5. Implement `status`, `models`, `route`, `doctor`, and config validation commands.
6. Implement one tested harness adapter and `harness run`.
7. Add the `claude` wrapper that delegates only to Harness, with no model aliases.
8. Implement redacted session persistence and session listing.
9. Add a mock-server integration test suite.
10. Add controlled fallback and then a TUI.

Required initial deliverables:
- README.md with quickstart using a local OpenAI-compatible llama.cpp endpoint.
- SPEC.md copied from the approved design.
- configs/example/config.yaml
- configs/example/providers.yaml
- configs/example/policies.yaml
- `harness config validate`
- `harness doctor`
- `harness status --json`
- `harness models --available`
- `harness route --profile private --explain`
- `harness run --provider llama-local --model <model>`
- Unit tests for policy and routing.
- Integration tests using a mock OpenAI-compatible `/v1/models` server.
- A security document covering secrets, egress, logging, and fallback.

Definition of done for the first milestone:
A user can configure a local llama.cpp server, run `claude --profile local`, see the chosen endpoint/model/trust-zone before launch, and start the selected underlying agent without relying on any static `claude-ollama-*` command. When the endpoint is unavailable, the user receives a typed diagnosis and no remote fallback occurs.

At every milestone:
- Run formatting, linting, unit tests, and integration tests.
- Update the architecture and migration documents.
- Record decisions in docs/adr/ using concise ADRs.
- Report completed work, remaining uncertainty, exact verification commands, and any blocked upstream integration detail.  
  
