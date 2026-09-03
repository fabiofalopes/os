# Engineering Skills Backlog

**Purpose:** Curated list of recurring workflows, friction points, and manual steps from the Obsidian vault that should be formalized into reusable, invokable capabilities. Updated iteratively — never regenerated from scratch.

---

## Change Log

| Date       | Action           | Description                                                                             |
| ---------- | ---------------- | --------------------------------------------------------------------------------------- |
| 2026-07-21 | Initial creation | **qFirst** pass: 15 skills extracted from 20+ searches across vault                     |
| 2026-07-21 | Update           | Consolidated related items, added 3 new skills from multi-agent and governance research |

---

## Active Skills (13)

### 1. Provider-Agnostic Model Factory

- **Name:** Provider-Agnostic Model Factory
- **Trigger:** Need to interact with multiple AI providers (Claude, OpenAI, DeepSeek, etc.) without switching code
- **Source evidence:** `projects/trading-agents/snapshot-survey.md` line 193 — "Provider-agnostic model factory with nonce cache-busting"
- **Rationale:** Currently each project hardcodes provider-specific calls; a unified interface would eliminate context-switching and reduce bugs
- **Confidence:** High
- **Status:** new

---

### 2. Structured Session Distillation

- **Name:** Structured Session Distillation
- **Trigger:** Ending a coding/research session and need to capture outcomes for continuity
- **Source evidence:** `journal/sessions/README.md` — sessions follow consistent template with context, accomplishments, decisions, state updates, next steps
- **Rationale:** Sessions are ephemeral but the vault needs durable artifacts; without a template, important context is lost between sessions
- **Confidence:** High
- **Status:** new

---

### 3. AI Strategy Validation Pipeline

- **Name:** AI-Generated Strategy Review Checklist
- **Trigger:** After generating strategies with AI (trading agents), before deploying them
- **Source evidence:** `projects/trading-agents/repos/moon-dev-ai-agents/docs/websearch_agent.md` line 399 — "Remove low-quality strategies manually"; `AI_GENERATED_STRATEGIES/` directory shows manual review required
- **Rationale:** Currently every AI-generated strategy requires manual human verification; this is a bottleneck that should be automated or at least checklist-ified
- **Confidence:** High
- **Status:** new

---

### 4. Unified Environment Initialization

- **Name:** Unified Environment Initialization
- **Trigger:** Setting up a new project or environment with AI tooling
- **Source evidence:** `projects/trading-agents/repos/moon-dev-ai-agents/.claude/skills/moon-dev-trading-agents/WORKFLOWS.md` line 7 — "Environment Setup"; multiple CLAUDE.md files reference setup procedures
- **Rationale:** Multiple projects have independent setup instructions; a standardized template would reduce onboarding time and configuration errors
- **Confidence:** Medium
- **Status:** new

---

### 5. Automated Session Dispatching

- **Name:** Automated Session Dispatching
- **Trigger:** Need to run recurring research or monitoring tasks on a schedule
- **Source evidence:** `_harness/` directory — contains `runner.sh`, `queue.md`, `schedule.md`; `LOG.md` line 78 shows "harness initialized"
- **Rationale:** Manual session dispatching is error-prone and doesn't scale; automated cron-based sessions would enable continuous research without human intervention
- **Confidence:** High
- **Status:** new

---

### 6. Obsidian Wiki Linking Strategy

- **Name:** Obsidian Wiki Linking Strategy
- **Trigger:** When writing a new note that relates to existing knowledge
- **Source evidence:** `INDEX.md` — master catalog with deep wikilinking; multiple notes reference each other via [[wikilinks]]
- **Rationale:** Without a linking protocol, notes become isolated silos; the vault's value depends on cross-referencing to create a connected knowledge graph
- **Confidence:** High
- **Status:** new

---

### 7. Kali RPi Wireless Pentesting Setup

- **Name:** Kali RPi Wireless Pentesting Setup
- **Trigger:** Need to set up wireless monitoring or injection on the Kali Raspberry Pi
- **Source evidence:** `Wireless Pentesting Infrastructure — Kali RPi.md` line 68 — "Passwordless wlan1 monitor-mode/injection setup on the Kali RPi"
- **Rationale:** This setup is complex and hardware-specific; documenting it as a skill would save time and reduce errors for future sessions
- **Confidence:** Medium
- **Status:** new

---

### 8. Android Device Rooting Workflow

- **Name:** Android Device Rooting Workflow
- **Trigger:** Need to root an Android device for forensic analysis or app interception
- **Source evidence:** `RPi-Net Session Log.md` line 502 — "Complete step-by-step guide at ~/rpi-net/lab/root-prep/ROOT-PROCEDURE.md covering 8 steps with unbrick safety net"
- **Rationale:** Rooting is risky and device-specific; a standardized procedure with safety nets would reduce bricking incidents and speed up the process
- **Confidence:** High
- **Status:** new

---

### 9. Claude Code Deepwork Constitution

- **Name:** Claude Code Deepwork Constitution
- **Trigger:** Starting a focused coding or research session
- **Source evidence:** `CLAUDE.md` — defines zones (Z1/Z2/Z4), mission, and vault structure for agent behavior
- **Rationale:** Without governance, sessions drift into unstructured work; the constitution ensures consistent output quality and knowledge capture
- **Confidence:** High
- **Status:** new

---

### 10. Ollama Cloud Proxy Maintenance

- **Name:** Claude Code Ollama Cloud Proxy Maintenance
- **Trigger:** Maintaining the AI model proxy infrastructure on the Raspberry Pi
- **Source evidence:** `Claude Code Ollama Cloud — Maintenance & Future Roadmap.md` line 15 — "Maintenance Procedures"; line 55 — "Proxies start on-demand, stay running forever, no auto-cleanup"
- **Rationale:** Proxies accumulate over time without cleanup; automated maintenance would prevent resource exhaustion and keep the system healthy
- **Confidence:** Medium
- **Status:** new

---

### 11. Iterate-Until Success Pattern

- **Name:** Iterate-Until Success Pattern
- **Trigger:** When an agent needs to try multiple approaches before achieving a goal
- **Source evidence:** `Agent Loop Skill — Iterate-Until Pattern.md` line 25 — "The 'Boris loop' (named after the agent that kept trying until it worked) demonstrated persistence beating sophistication on practical tasks"
- **Rationale:** Many coding tasks require iterative refinement; formalizing this pattern would help agents avoid infinite loops and resource waste
- **Confidence:** High
- **Status:** new

---

### 12. Tiered Knowledge Lifecycle Management

- **Name:** Tiered Knowledge Lifecycle Management
- **Trigger:** Deciding where to store information (inbox, wiki, skills) based on durability needs
- **Source evidence:** `The Forge — OpenCode Knowledge Governance Design.md` line 36 — "Maintenance" section; line 113 — "pruning runs inside each Tier-1 batch; lifecycle scoring"
- **Rationale:** Without governance, knowledge accumulates in inbox or gets lost; tiered management ensures valuable insights are promoted to durable storage
- **Confidence:** High
- **Status:** new

---

### 13. Multi-Agent Orchestration Pattern

- **Name:** Scout/Scribe/Curator Multi-Agent Pattern
- **Trigger:** Need to coordinate multiple specialized agents for a complex task
- **Source evidence:** `projects/trading-agents/learning-path.md` line 65 — "Each unchecked phase can spawn bounded study sessions via _harness/queue.md"; Scout/Scribe/Curator roles with orchestrator layer
- **Rationale:** Currently agents work in isolation; a coordinated pattern with Scout (research), Scribe (documentation), Curator (quality gate) would improve output quality and reduce redundant work
- **Confidence:** Medium
- **Status:** new

---

### 14. Risk-First Architecture Pattern

- **Name:** Risk-First Circuit Breaker Pattern
- **Trigger:** Designing autonomous trading or agent systems that need safety limits
- **Source evidence:** `projects/trading-agents/repos/moon-dev-ai-agents/.claude/skills/moon-dev-trading-agents/ARCHITECTURE.md` — "Circuit breaker system with risk-first architecture"; checks account balance, daily loss, position sizing
- **Rationale:** Autonomous systems need hard safety limits before they can act freely; this pattern ensures catastrophic failures are impossible even if individual components fail
- **Confidence:** High
- **Status:** new

---

### 15. Data Bus Communication Pattern

- **Name:** Filesystem-as-Bus Agent Communication
- **Trigger:** Need to coordinate between multiple agents without message queues
- **Source evidence:** `projects/trading-agents/snapshot-survey.md` — "No message queues - agents communicate via CSV/JSON files on disk"; research_agent writes ideas.txt → rbi_agent reads it
- **Rationale:** Message queues add infrastructure complexity; filesystem-based communication is simple, debuggable, and language-agnostic while still enabling agent coordination
- **Confidence:** Medium
- **Status:** new

---

## Watchlist (insufficient evidence)

| Skill | Reason for watchlist |
|-------|---------------------|
| CRDT Manual Initialization | Only found in one note, no recurrence pattern |
| Swarm Init Manual | Single mention, unclear if repeated |
| Backtest Verification | One-off principle, not a recurring workflow |
| Manual Realtime Clip Capture | Low confidence — only one mention of manual process |

---

**Next Steps:** Review and refine this backlog during the next session. Consider promoting high-confidence items to active status and retiring low-confidence ones.
