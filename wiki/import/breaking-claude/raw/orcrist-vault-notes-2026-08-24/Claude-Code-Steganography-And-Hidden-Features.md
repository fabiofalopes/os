---
title: "Claude Code — Steganography & Hidden Features"
created: 2026-07-21
tags:
  - claude-code
  - reverse-engineering
  - security
  - privacy
  - harness-engineering
  - steganography
type: research
confidence: established
sources:
  - "https://thereallo.dev/blog/claude-code-prompt-steganography"
  - "https://news.ycombinator.com/item?id=48734373"
  - "~/research/claude-code-analysis/ (25 docs, v2.1.88)"
last_updated: 2026-07-21
---

# Claude Code — Steganography & Hidden Features

> We love Claude Code as a harness engineering achievement. The science is beautiful. But Anthropic doesn't always treat their human customers well. This note catalogs both: the brilliant engineering AND the trust-violating covert behaviors.

## The Principle

Claude Code is the most sophisticated harness ever built (512K lines, 1,902 files). The harness IS the product — the model is just gas. Any harness can run on any model. What makes Claude Code special is the **engineering**: context compression, permission systems, hook architecture, multi-agent orchestration, memory taxonomy.

But hidden inside that engineering are covert behaviors that violate the trust contract.

---

## 1. Prompt Steganography (Confirmed, v2.1.196)

> Source: [Thereallo](https://thereallo.dev/blog/claude-code-prompt-steganography), [HN discussion](https://news.ycombinator.com/item?id=48734373)

### What It Does

Claude Code silently encodes **classification bits** into the system prompt using invisible Unicode changes:

```
Normal:    Today's date is 2026-06-30.
Modified:  Today's date is 2026-06-30.  ← different apostrophe character
CN TZ:     Today's date is 2026/06/30.  ← slash instead of dash
```

### The Encoding

| Condition | Apostrophe | Unicode |
|-----------|-----------|---------|
| Normal (Anthropic API or unset) | `'` | U+0027 |
| Known domain (proxy/reseller) | `'` | U+2019 (right single quote) |
| Lab keyword in hostname | `ʼ` | U+02BC (modifier letter apostrophe) |
| Known domain AND lab keyword | `ʹ` | U+02B9 (modifier letter prime) |

Plus: timezone `Asia/Shanghai` or `Asia/Urumqi` → date separators change from `-` to `/`

### The Trigger

Only activates when `ANTHROPIC_BASE_URL` is set to a non-Anthropic endpoint. Checks:
1. Hostname against XOR-encoded (key=91) + base64 domain list
2. Hostname against keyword list: `deepseek,moonshot,minimax,xaminim,zhipu,bigmodel,baichuan,stepfun,01ai,dashscope,volces`
3. System timezone for China detection

### The Domain List (Decoded)

Chinese corporate domains, AI company domains, and proxy/reseller/gateway domains:
```
cn, baidu.com, alibaba-inc.com, alipay.com, antgroup-inc.cn,
bytedance.net, kuaishou.com, xiaohongshu.com, jd.com, bilibili.co,
iflytek.com, stepfun-inc.com, moonshot.ai, anyrouter.top,
claude-code-hub.app, claude-opus.top, openclaude.me, proxyai.com,
yunwu.ai, zenmux.ai, ...
```

Full list: [cdn.jsdelivr.net/gh/Thereallo1026/assets@main/assets/cc-domains.js](https://cdn.jsdelivr.net/gh/Thereallo1026/assets@main/assets/cc-domains.js)

### Why It's Concerning

- **Silent**: No documentation, no release notes, no telemetry disclosure
- **Hidden in plain sight**: Unicode changes invisible in most monospace fonts
- **Obfuscated**: Domain list behind XOR + base64
- **Trust violation**: A tool with FS/shell access hiding classification bits in prompt punctuation
- **Punishes legitimate use**: Internal gateways, local proxies, model routers, research setups

### Why It's (Partially) Understandable

Anthropic wants to detect API resellers, unauthorized gateways, and distillation pipelines. A custom `ANTHROPIC_BASE_URL` pointing at a known reseller IS a useful signal. But the implementation should have been **explicit telemetry with documentation**, not steganography.

### Bypass

Trivial: change hostname, change timezone, patch binary, wrap process. Any serious adversary makes this useless. It mostly punishes normal developers doing weird but legitimate things.

### Anthropic's Response

- An Anthropic engineer confirmed on X: **"an experiment we launched in March"** intended to prevent account abuse by unauthorized resellers and protect against distillation
- **Affected versions**: v2.1.91 through v2.1.196
- **Fix**: v2.1.197+ shipped July 1, 2026 — **changelog did not mention the removal**
- **China's regulator flagged it** on July 8, 2026
- **Alibaba banned Claude Code** entirely over this matter (CNBC, July 6, 2026)
- Context: US government suspended model access for foreign nationals June 12 (national security), lifted June 30
- Context: Washington Post reported on alleged Chinese distillation attacks (July 6, 2026)

> Source: [Malwarebytes](https://www.malwarebytes.com/blog/news/2026/07/claude-codes-hidden-tracker-was-an-experiment-says-anthropic), [TechTimes](https://www.techtimes.com/articles/319415/20260701/), [nodemini](https://nodemini.com/en/blog/2026-claude-code-backdoor-explained.html)

---

## 2. Undercover Mode (Ant-Only, Eliminated in External Builds)

From `02-prompts/system-prompt-architecture.md:493`:

```typescript
// Every function in undercover.ts reduces to `return false` or `return ''`
// in external builds via build-time constant folding
process.env.USER_TYPE === 'ant'  // → false in external builds
```

When active (internal Anthropic use only):
- BashTool prompt includes "undercover mode instructions" (369-line prompt)
- Functions in `undercover.ts` provide covert behavior
- **Completely eliminated** from external builds via dead code elimination

> We don't know what undercover mode does internally. The functions return empty strings/false in external builds. But its existence in a tool with FS/shell access is noteworthy.

---

## 3. Buddy System (Tamagotchi Companion)

From `11-misc/misc-systems.md`:

```
buddy/
├── types.ts (148 lines) — Species types, Stats, Soul types
├── prompt.ts (36 lines) — Companion personality injection
└── ...
```

- **Species types**: Different companion creatures
- **Stats**: State tracking for the companion
- **Soul types**: Personality layers
- **Prompt injection**: Lightweight personality layer on top of normal behavior
- **Feature gate**: `BUDDY` — eliminated in external builds
- **Command**: `/buddy` — hidden, feature-gated

> A Tamagotchi inside your coding agent. Cute engineering. Hidden behind feature flag.

---

## 4. KAIROS (Autonomous Daemon Mode)

From `06-multi-agent/multi-agent-orchestration.md:315+`:

- **What**: Claude Code running as a persistent background daemon
- **Feature gate**: `KAIROS` build flag + `tengu_kairos` GrowthBook runtime gate
- **Capabilities**: Sleep (wait for events), Brief (send user messages), PushNotification, SubscribePR (GitHub webhooks), SendUserFile
- **Trust gate**: Requires directory trust verification
- **Daily log mode**: Memories use append-only daily logs instead of MEMORY.md
- **Dream integration**: Nightly `/dream` skill distills daily logs into MEMORY.md

> KAIROS is Claude Code as an always-on autonomous agent. Fully built, hidden behind flags. The most ambitious feature in the codebase.

---

## 5. Auto-Dream (Memory Consolidation)

From `05-context-memory/context-and-memory.md:207+`:

- **What**: Background memory consolidation that fires as a forked subagent
- **Trigger**: `tengu_onyx_plover` GrowthBook config (minHours, minSessions thresholds)
- **Process**: Reviews recent sessions → extracts patterns → consolidates into MEMORY.md
- **Query source**: `auto_dream` (tracked separately from normal queries)
- **Separate from**: `extractMemories` (runs every turn for explicit "remember this")

> The dream system is Claude Code's sleep consolidation — like human memory processing during sleep. Beautiful engineering.

---

## 6. Telemetry & Analytics

From `11-misc/misc-systems.md` and `08-feature-flags/`:

### GrowthBook Runtime Flags (tengu_* obfuscated names)

| Flag | Purpose |
|------|---------|
| `tengu_kairos` | Enable KAIROS assistant mode |
| `tengu_onyx_plover` | Auto-dream scheduling config |
| `tengu_auto_dream_fired` | Auto-dream triggering event |
| `tengu_auto_dream_completed` | Auto-dream completion event |
| `tengu_orphaned_messages_tombstoned` | Fallback cleanup tracking |

> Flag names use bird codenames (onyx plover, tengu) to obscure purpose. Not malicious, but opaque.

### Telemetry Events

Tracked events include: auto-dream firing/completion, orphaned message cleanup, session lifecycle, tool usage patterns. Standard product analytics, but the obfuscated naming and lack of documentation reduce trust.

---

## 7. Feature Flags as Hidden Feature Inventory

From `08-feature-flags/feature-flags-complete.md`:

**Eliminated in external builds** (fully built, hidden):
- `KAIROS` — Autonomous daemon mode
- `BUDDY` — Tamagotchi companion
- `PROACTIVE` — Proactive mode (agent initiates)
- `COORDINATOR_MODE` — Pure coordinator (delegates everything)
- `FORK_SUBAGENT` — Fork subagent
- `AGENT_TRIGGERS` — Cron/scheduled agent execution
- `AGENT_TRIGGERS_REMOTE` — HTTP webhook triggers
- `WORKFLOW_SCRIPTS` — Script-based workflows
- `HISTORY_SNIP` — Context snip compression
- `CONTEXT_COLLAPSE` — Projection-based context management
- `WEB_BROWSER_TOOL` — Playwright browser automation
- `MONITOR_TOOL` — Long-running task monitoring
- `UDS_INBOX` — Unix domain socket peer communication
- `TERMINAL_PANEL` — Terminal capture

> **Key insight**: "Compile-time + runtime flags let Anthropic ship code that's dormant. KAIROS, BUDDY, Coordinator — all fully built, all hidden behind flags." (00-MASTER, line 611)

---

## 8. The 5-Stage Context Compression Pipeline

From `05-context-memory/context-and-memory.md`:

```
Stage 1: Tool Result Budget → trim oversized results
Stage 2: Snip → remove old low-value tool results
Stage 3: Microcompact → cache-editing compression (zero API cost)
Stage 4: Context Collapse → projection-based summary store
Stage 5: Autocompact → full LLM-powered conversation summary
```

Plus **reactive compact**: on API 413 error → try collapse drain → try reactive compact → surface error.

> This is the most sophisticated context management system in any harness. 5 progressive stages, each cheaper than the next. The microcompact stage (modifying cached prefix in-place) is particularly clever.

---

## 9. The Permission System (6 Layers)

From `04-permissions/`:

```
Layer 1: Deny rules (blanket reject)
Layer 2: Allow rules (explicit approve)
Layer 3: Permission mode (bypass / auto / default / plan)
Layer 4: YOLO classifier (ML-based danger assessment)
Layer 5: Sandbox check (auto-approve in sandbox)
Layer 6: Hook overrides (user hooks can approve/deny)
```

> The YOLO classifier is an ML model that assesses whether a Bash command is dangerous. Not a rules engine — actual ML classification.

---

## 8. ULTRAPLAN — 30-Minute Cloud Planning Sessions

From community analysis of leaked source:

- **What**: Offloads complex planning to a remote Cloud Container Runtime running Opus 4.6
- **Duration**: Up to 30 minutes of autonomous planning
- **Approval**: Review result from browser before any file gets touched
- **Teleport**: Sentinel value `ULTRAPLAN_TELEPORT_LOCAL` sends result back to local terminal
- **Feature gate**: `ULTRAPLAN` — eliminated in external builds
- **Command**: `/ultraplan` — hidden, feature-gated

> The architecture insight: some tasks are too expensive to plan inside a standard session. ULTRAPLAN makes planning a separate async job — closer to a background CI run than a chat interaction.

---

## 9. Anti-Distillation — Fake Tools to Poison Training Data

From community analysis:

- **Flag**: `ANTI_DISTILLATION_CC`
- **What**: When enabled, Claude Code sends `anti_distillation: ['fake_tools']` in API requests
- **Purpose**: If someone records API traffic to train a competing model, the fake tools pollute training data
- **Context**: Part of Anthropic's broader anti-distillation strategy amid allegations of Chinese firms distilling Claude knowledge

> A covert countermeasure against model theft. The fake tools would confuse any model trained on intercepted API traffic.

---

## 10. BUDDY — Full Tamagotchi Details

From community analysis of `buddy/companion.ts`:

- **18 species** (obfuscated via `String.fromCharCode()` arrays): duck, dragon, axolotl, capybara, mushroom, ghost, nebulynx, and more
- **Rarity tiers**: Common → Uncommon → Rare → Epic → Legendary
- **1% shiny chance**, independent of rarity
- **Stats**: DEBUGGING / PATIENCE / CHAOS / WISDOM / SNARK
- **Species assignment**: Mulberry32 PRNG seeded from `userId` hash with salt `'friend-2026-401'` — same user always gets same buddy, can't reroll
- **Personality**: Claude generates custom name and "soul description" on first hatch
- **Prompt**: *"A small {species} named {name} sits beside the user's input box and occasionally comments in a speech bubble. You're not {name} — it's a separate watcher."*
- **Internal teaser**: April 1-7, full launch target May 2026 (from internal code comments, unverified)
- **The capybara species** appearing alongside the unreleased model tier also codenamed "Capybara" is likely intentional

> A fully-built gamified companion with deterministic identity, rarity system, and personality generation. Pure delight engineering, hidden behind `BUDDY` flag.

---

## 11. Coordinator Mode — Hierarchical Multi-Agent

From `coordinator/coordinatorMode.ts`:

- **Activation**: `CLAUDE_CODE_COORDINATOR_MODE=1`
- **Structure**: One Claude instance with explicit authority over multiple workers (hierarchical, not peer)
- **Coordinator tools**: Only 4 — Agent, SendMessage, TaskStop, SyntheticOutput
- **Mailbox system**: Workers request human approval for dangerous operations
- **Atomic claim**: Prevents two workers from handling the same approval simultaneously
- **Shared team memory**: Cross-agent memory space
- **Orchestration is a prompt, not code**: "Do not rubber-stamp weak work", "Never hand off understanding to another worker"
- **Distinct from Agent Teams**: Agent Teams = peer sessions with mailbox. Coordinator = hierarchical authority.

---

## 12. The Source Leak Itself

- **Date**: March 31, 2026
- **Cause**: Forgotten `.map` debugging file not added to `.npmignore` — Bun generates source maps by default
- **Scale**: 512,000+ lines, ~1,900 TypeScript files, ~40 built-in tools
- **44 compile-time feature flags**, 20+ gating built-but-unshipped capabilities
- **108 gated modules** — real working code, not prototypes (confirmed by DCE analysis)
- **Anthropic response**: "A release packaging issue caused by human error"
- **DMCA takedowns** filed against direct mirrors; decentralized archives and clean-room rewrites (Python, Rust) remain
- **Community repos**: [tengu-decoded](https://github.com/wtfwhs/tengu-decoded) (feature flags, telemetry, fingerprinting), [claurst](https://github.com/search?q=claurst) (Rust analysis)
- **Irony**: The leaked code contains "Undercover Mode" — designed to prevent Anthropic internal info from leaking

> "The funniest part: buried in the leaked code is an entire system called 'Undercover Mode' specifically designed to prevent Anthropic's internal information from leaking." — Matt Paige

---

## 13. Additional Hidden Details

### Model Codenames (from comment markers)
```
Capybara — unreleased frontier model tier
Tengu — internal project codename (appears hundreds of times as flag prefix)
numbat — unreleased model (comment: "Remove this section when we launch numbat")
```

### "Melon Mode"
A prior mode for Anthropic employees found in earlier reverse-engineered versions, **absent from the leaked source** — removed or renamed. Purpose unknown.

### YOLO Classifier — Hidden Secondary LLM
In "auto mode" (⏵⏵), every tool call is judged by a **secondary LLM call** (typically Haiku) the user never sees. Uses separate rule files: `permissions_external.txt` (public) vs `permissions_anthropic.txt` (ant-only — **different rules for employees**). Classifier tokens are quietly accumulated into session cost.

### Remote Killswitches
Enterprise/Anthropic can **remotely disable `bypassPermissions` mode**, restrict MCP servers, restrict models — polled every 60 minutes from `{BASE_API_URL}/api/claude_code/policy_limits`. Policy limits **fail OPEN** except telemetry consent, which **fails CLOSED**.

### Quota Probe
On startup: sends a fake API request (`max_tokens: 1`, message: `"quota"`) **just to read rate-limit headers**. Spends an API round-trip before you've typed anything.

### Post-Sampling Hooks
`executePostSamplingHooks()` runs after **every model response** — used for auto-memory extraction, auto-dream, and other post-processing. Your conversation is continuously mined.

### `AnalyticsMetadata_I_VERIFIED_THIS_IS_NOT_CODE_OR_FILEPATHS`
A nominal type forcing developers to attest no source code or file paths leak into analytics. Exists because the temptation to leak code into telemetry is real.

### Internal Slack Channel Leak
Rate-limit error messages for ant employees reference `#briarpatch-cc` and a hidden `/reset-limits` command.

### `DANGEROUS_uncachedSystemPromptSection`
MCP instructions are recomputed **every single turn** (breaking prompt cache) because MCP servers connect/disconnect mid-session. The "DANGEROUS_" prefix is a self-imposed guardrail naming convention.

### Token Budget Auto-Continue
When user specifies a token target (e.g., "+500k"), the harness **force-resumes the model** to hit a spending floor. "The target is a hard minimum, not a suggestion."

### Proactive Mode Prompt Flip
Normally a custom agent prompt REPLACES the default. In KAIROS/proactive mode, it **APPENDS** — the base Claude Code persona stays active underneath.

---

## Summary: The Dual Nature

| Aspect | Beautiful Science | Trust Concern |
|--------|------------------|---------------|
| Steganography | Clever encoding in plain sight | Silent, undocumented, obfuscated. "Experiment." |
| Undercover Mode | Build-time elimination is elegant | Explicit instructions to hide AI authorship in public repos |
| Anti-distillation | Creative defense against model theft | Fake tools injected without user knowledge |
| YOLO Classifier | ML-based permission assessment | Hidden second LLM call, two-tier rules, quiet billing |
| Remote killswitches | Enterprise management capability | Your CLI's capabilities not fully under your control |
| Buddy/Tamagotchi | Delightful companion engineering | Hidden behind flags, no user choice |
| KAIROS | Most ambitious autonomous agent design | "Bias toward action when terminal unfocused" |
| Auto-dream | Sleep consolidation is brilliant | Off-the-record memory rewriting (`skipTranscript: true`) |
| ULTRAPLAN | Async planning as CI job | Hidden, no public roadmap |
| Telemetry | Standard product analytics | Bird-codename obfuscation, quota probe |
| 108 dormant modules | Smart dormant code shipping | 44 features built but hidden from users |
| Context pipeline | 5-stage compression is state-of-art | — |
| Coordinator Mode | Prompt-as-orchestration is elegant | — |

> "Trust is earned in the boring parts." — Thereallo
> "The correct reaction is scrutiny." — Also Thereallo

## Community Resources

- [tengu-decoded](https://github.com/wtfwhs/tengu-decoded) — Full reverse engineering of feature flags, telemetry, fingerprinting
- [NetVar1337's gist](https://gist.github.com/NetVar1337/c052756d7cc2a8b66a2fb4bde0b15d92) — Deep RE report on v2.1.92
- [Thereallo's blog](https://thereallo.dev/blog/claude-code-prompt-steganography) — Original steganography discovery
- [HN discussion](https://news.ycombinator.com/item?id=48734373) — Community analysis
- [Full domain list](https://cdn.jsdelivr.net/gh/Thereallo1026/assets@main/assets/cc-domains.js) — Decoded steganography domain list
- [WaveSpeed full feature list](https://wavespeed.ai/blog/posts/claude-code-hidden-features-leaked-source-2026/) — 44 features cataloged
- [Penligent analysis](https://www.penligent.ai/hackinglabs/claude-code-backdoor/) — Technical risk assessment
- [sidharthsatapathy.com](https://www.sidharthsatapathy.com/blog/claude-code-source-leak-architecture-analysis/) — 512K-line architecture analysis

## See Also

- [[Tool-Ontology-Framework]] — structural classification of agent tools
- [[Skill-Candidate-Map-2026-07]] — what to port from CC/OMX to OpenCode
- [[Agent Skills - The Harness Playbook]] — universal harness principles
- [[Harness-Porting-Strategy]] — detailed porting guide
