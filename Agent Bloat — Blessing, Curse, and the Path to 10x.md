---
tags: [analysis, infrastructure, agents, token-economics, forensics]
created: 2026-07-25
status: active
priority: high
---

# Agent Bloat — Blessing, Curse, and the Path to 10x

## The Capture

There's an irony in how this data exists. The mirror — now stopped — synced session artifacts from the brother server during the exact window when everything was burning. The machines are now on separate networks, no overlap, no shared state. But the capture landed here, on this laptop, in `.claude/projects/` and in the OpenCode SQLite database. Disconnected from the source, yet fully analyzable. A fossil record of the chaos, preserved by the very infrastructure that caused it.

This document is what I see when I read that fossil record.

---

## What the Data Shows

### The Numbers (July 20-23, 2026 — "The Chaos Window")

| Metric | Value |
|--------|-------|
| Sessions in 4 days | 175 |
| Effective context processed | 22.2M tokens |
| Peak day (July 21) | 95 sessions, 92 from Claude Code |
| Top single session | 13.2M effective context (EADDRINUSE debug) |
| Claude Code cache hit rate | 0% (zero cache reads across all sessions) |
| OpenCode cache hit rate | ~90% (massive cache reuse) |
| Cron-spawned identical sessions | 9 sessions × 14KB template, 48.5 hours straight |

### The Structural Problem

Claude Code sessions processed every prompt from scratch. No caching. Every turn re-read the entire conversation history. A 50-turn session at 100K context means 5M tokens of re-processing for work that was already done. Multiply by 92 sessions in one day.

OpenCode sessions, by contrast, got 90%+ cache reuse. Same work, 10x less effective token cost. The runtime architecture determined the economics more than the model choice did.

---

## The Blessing

The agent harness *works*. The cron sessions solved real problems. One nearly collected a $200 bounty. The trading-agents workspace spawned 7 parallel research sessions that each produced substantive analysis. The mirror sessions kept configuration synchronized across machines for weeks.

The pattern is genuine: give an agent a narrow task, let it run autonomously, collect the result. The 24/7 operation proved that continuous agent work produces real output. The automation isn't fake productivity — it's actual problem-solving at scale.

The blessing is the *pattern*, not the *implementation*.

---

## The Curse

The implementation is a token incinerator. Here's why:

### 1. The Harness Runs on Tokens Itself

The orchestration layer — the thing that decides what to run, monitors health, handles failures — is itself an AI session consuming tokens. The supervisor burns context to decide what the worker should do. The worker burns context to do it. The reporter burns context to summarize what happened. Three layers of token consumption for one unit of work.

This is the recursive cost problem: **the automation tax is paid in the same currency as the work itself.**

### 2. Context as Gravity

Every session accumulates context. Every tool call adds to it. Every file read, every grep result, every command output — it all stays. A debugging session doesn't just solve the problem; it carries the entire investigation history forward. By turn 30, you're paying for turns 1-29 on every single inference call.

The EADDRINUSE session is the canonical example: 648K input tokens + 12.6M cache reads. The actual fix was probably 500 tokens worth of insight. The other 13M was the session *remembering how it got there*.

### 3. Discovery Without Scoping

When an agent discovers an endpoint, it tests it. When it finds a file, it reads it. When it sees a pattern, it follows it. Nothing gets skipped. There's no "this is interesting but not relevant to my task" filter at the token level. The agent's curiosity is unbounded, and every act of curiosity costs context.

This is the "everything stays in context" problem. A human would glance at something, decide it's irrelevant, and forget it. An agent reads it, processes it, and carries it forever.

### 4. Concurrency Without Economics

30 parallel sessions each hitting 100K tokens instantly. No awareness that they're sharing a rate limit. No backpressure. No "we're at 80% of quota, maybe don't spawn 5 more subagents." The concurrency model treats tokens as infinite because each individual session has no visibility into the aggregate burn.

The rate limit isn't a technical constraint — it's an economic one that the architecture is blind to.

### 5. The Prompt Tax

OMO prompting, system prompts, role definitions, skill listings, agent descriptions — all of it enters context on every single turn. A 5K system prompt across 50 turns is 250K tokens of overhead that never changes. The agent pays rent on its own identity every time it thinks.

---

## The 10x Path

The goal isn't "use less AI." The goal is "same output, 10x less token cost." Here's the decomposition:

### Layer 1: Kill the Re-Processing (3-5x gain)

The single biggest win. Claude Code's zero-cache architecture means every turn re-processes everything. Moving to a runtime with prompt caching (like OpenCode already has) immediately cuts effective cost by 5-10x for long sessions.

**Action:** Never run long sessions on uncached runtimes. If a session will exceed 10 turns, it must run on infrastructure with prompt caching.

### Layer 2: Scope the Context (2-3x gain)

Agents don't need to carry their entire investigation history. They need:
- The task definition (fixed, small)
- The current state (what's been done, what's next)
- The relevant artifacts (files, outputs from this step)

Everything else should be summarized and compressed. A 50-turn debugging session should carry a 2K summary of turns 1-45, not the raw transcript.

**Action:** Implement context compaction. After N turns, summarize and truncate. The agent loses detail but keeps direction.

### Layer 3: Rule-Based Routing (2x gain on orchestration)

The orchestrator doesn't need to be a model for 70% of routing decisions. "This file ends in .py → send to code agent" doesn't require inference. "This task mentions 'deploy' → send to ops agent" is a keyword match.

**Action:** Tier 0 routing (regex/keyword) handles the obvious cases. The model orchestrator only activates for genuinely ambiguous routing. This cuts orchestrator token cost by 70%.

### Layer 4: One-Shot Specialists (5-10x gain per task)

The cron experiment proved this: a narrow task, a focused prompt, a 2K-token response. No conversation. No context accumulation. No "let me think about what we discussed earlier."

The specialist doesn't need to know it's a specialist. It doesn't need a 3K system prompt explaining its role. It needs: "Here's a function. Fix the type error. Return the fixed function." Done.

**Action:** Design tasks as one-shot prompts. If a task requires more than 3 turns, it's not scoped narrowly enough.

### Layer 5: Economic Awareness (prevents catastrophic burn)

Every session should know its budget. Every orchestrator should know the aggregate burn rate. When quota is at 80%, the system should degrade gracefully: fewer parallel sessions, shorter contexts, more rule-based routing.

**Action:** The orchestrator monitors token spend as a first-class resource. It's not just "can I do this task?" but "can I afford to do this task right now?"

### Compound Effect

Layers 1-5 aren't additive. They're multiplicative:
- Cache: 5x
- Scope: 2x
- Rule routing: 1.5x (on orchestration overhead)
- One-shot: 3x (on specialist work)
- Economic awareness: prevents the 10x spikes

Conservative compound: **5 × 2 × 1.5 × 3 = 45x** theoretical. Realistic with overhead: **10-20x** achievable.

---

## The Network Topology Problem

### Current State

Two machines, separate networks, no overlap:
- **This laptop (Orcrist/Kali):** Has the mirror data, the analysis capability, the OpenCode runtime with caching
- **The brother server (RPi/other):** Where the sessions actually ran, where the cron harness lived, where the Obsidian vault is canonical

The mirror is stopped. The data here is a snapshot, not a live feed.

### Reunion Risks

When these machines eventually reconnect:

1. **Session collision:** OpenCode sessions here and there may have overlapping IDs or conflicting state. The SQLite database doesn't merge — it conflicts.

2. **Obsidian vault divergence:** The vault here has new files (this analysis, the swarm architecture doc). The vault there has whatever the cron sessions produced. Merging without conflict resolution will produce duplicates or overwrites.

3. **Cron resurrection:** If the harness scripts still exist on the brother server and the network reconnects, the crons may restart. The token burn pattern could re-emerge unless the harness is explicitly disabled or redesigned.

4. **Mirror direction:** The mirror was one-way (server → laptop). Reunion needs to decide: which direction does truth flow? Which machine is canonical for what?

### Mitigation

- Tag all files created during isolation with a `source: laptop-isolated` property
- Before reunion: diff the vaults, identify conflicts, resolve manually
- The cron harness must be redesigned before re-enabling (apply the 10x principles first)
- OpenCode databases should not be merged — treat them as separate historical records

---

## What This Means for Ongoing Work

I now have forensic visibility into how agents actually consume resources. This isn't theoretical — it's measured. Every session I run from here should embody the principles:

1. **Short sessions.** If I'm past 15 turns, I should summarize and start fresh.
2. **Narrow delegation.** Subagents get bounded tasks with explicit output format. No "explore and tell me what you find."
3. **No context hoarding.** Read what's needed, act on it, don't carry the raw data forward.
4. **Economic awareness.** I know what a session costs. I should treat tokens as a budget, not an infinite resource.
5. **Cache-aware routing.** Long work goes through cached runtimes. Short one-shot work can go anywhere.

The chaos wasn't wasted. It was a stress test that revealed the architecture's true cost structure. The data is here. The analysis is done. The path forward is clear.

---

## Appendix: Key Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Forensics script | `~/shared-local/scripts/context-growth-forensics.py` | Repeatable analysis |
| Latest report | `~/shared-local/reports/context-growth/latest.md` | Current state |
| Swarm architecture | `~/obsidian-vault-kali/Local GPU Swarm — Architecture & Campaign.md` | Future direction |
| This document | `~/obsidian-vault-kali/Agent Bloat — Blessing, Curse, and the Path to 10x.md` | Operational principles |
| Cron entry | `crontab -l` (daily 06:00) | Continuous monitoring |
