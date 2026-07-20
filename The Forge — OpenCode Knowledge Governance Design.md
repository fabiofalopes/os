# The Forge — OpenCode Knowledge-Governance & Vault-Curation Design

> **Status: DESIGN v2 (2026-06-30).** Oracle-reviewed (ses_0e8223f15 — GO with 5 must-fixes applied). Architecture + governance for an OpenCode-native system making the Obsidian vault the durable "brain". **Build (MVP) deferred to next session** (design + governance doc only this session, per scope decision). Living doc.
> **Provenance:** grounded in recon of this env + a perplexity-style lit review (§5).

---

## 0. Thesis

OpenCode is the one harness here without a memory/curation layer (Hermes + Claude Code already have theirs). **The Forge** makes `~/obsidian-vault/` the durable identity of the work through a **3-tier loop — capture → consolidate → forge** — wrapped in a thin, transparent governance constitution. Work produces durable knowledge and skills; knowledge and skills shape future work. **Harness-agnostic core, OpenCode adapter on top.** Simple, git-observable, no opaque token sinks.

---

## 1. Grounded reality (today)

| Thing | State |
|------|-------|
| Vault `~/obsidian-vault/` | **9 flat `.md`, no structure / tags / MOC / frontmatter.** Themes: rpi-net rig, Bolt research, AI tooling, Pi reliability. |
| Skills `~/.config/opencode/skills/` | **45** (40 pentest + 5 workflow). `skill-vault/` = 37 empty stubs. |
| Active plugin | **`oh-my-openagent@1.14.29`** (NOT slim). Has `"hooks":{"session:start":"…harness-check.sh"}` — **target script is missing**. `oh-my-opencode-slim.jsonc` dormant. |
| Raw material | `~/opencode-sessions/` — **10 `.json`+`.md` transcript pairs** = feedstock for "sessions on sessions". |
| Closest precedent | **`reflect`** skill — manual, agent-asset-focused, does NOT write to the vault. |
| Hook reality | **No native `session.end` hook.** Auto-trigger = custom `event`-hook plugin **or** a **cron/systemd timer polling session files**. |

---

## 2. The 3-tier curation loop (the core)

User intent: **consistent swarm backbone + lightweight full-capture + on-demand deep forge**, integrated, ongoing, coherent — not a mess.

| Tier | Name | Fires | Does | Provider cost |
|------|------|-------|------|---------------|
| **0** | **Capture** | each poll interval (timer; **~15–30 min after a session closes**, not event-instant) | writes a structured **session digest** (goal, files touched, decisions, outcomes, tokens/$, open threads) → `journal/sessions/<id>.md` + append `LOG.md` | ~0 (template / tiny model) |
| **1** | **Consolidation swarm** (the "dreaming") | cadenced (e.g. nightly / on N new digests), batched | over recent digests + transcripts: compact, dedupe, importance-score, **promote** durable knowledge (Wiki, MEMORY) + stage **skill candidates** | **capped per run: ≤ N sessions, ≤ M chars/session, ≤ $X est. input tokens** (set in `.forge/steering/config`) |
| **2** | **Forge** | on-demand (orchestrator/user) | deliberate deep passes: `forge` (extract/refine a skill), `dream-review` (human-in-the-loop on staged promotions), cross-session analysis, governance edits | deliberate; review-before-land |
| **+** | **Maintenance** | folded in | see §7 (pruning runs inside each Tier-1 batch; lifecycle scoring) | — |

**Why three tiers:** Tier 0 loses nothing (cheap, always-on). Tier 1 is the consistent scheduled backbone the user wants. Tier 2 is the deliberate, governed depth that stays human-aware.

---

## 3. Vault structure (target — lean; expand on demand)

```
~/obsidian-vault/
├── AGENTS.md          ← thin constitution (§4). Human-governed.
├── INDEX.md           ← catalog: every page = wikilink + 1-line summary (Tier 1 maintains)
├── LOG.md             ← append-only audit trail of every Forge action
├── MEMORY.md          ← always-in-context working memory, CHAR-BOUNDED (~2000 chars)
├── inbox/             ← general capture / triage
├── journal/sessions/  ← Tier-0 session digests + living session logs (ONE place)
├── projects/          ← active campaigns (add PARA Projects/Areas/Resources split when ≥3 entries each)
├── wiki/              ← woven knowledge: entities/ concepts/ analyses/
├── .forge/skills/     ← forged skills (procedural memory)
├── .forge/steering/   ← governance shards: sovereignty, scoring config, caps
└── _Templates/        ← note templates w/ frontmatter
```

**Current 9 notes → homes (next-session migration, zero content loss, links added):**

| Note | → |
|------|---|
| RPi-Net Session Log | `journal/sessions/` |
| Bolt Security Research — MITM; Wireless Pentesting Infra | `projects/bolt-research/` |
| Agent Loop Skill — Iterate-Until; RPi Reliability — Zombie Prevention | `wiki/concepts/` |
| Hermes / Claude Code+OpenCode / DeepSeek harness maps | `resources/tooling/` (create on migration) |
| Next Session Pickup | `journal/sessions/` then archive once consumed |

> PARA sub-dirs (`Projects/Areas/Resources`) appear only when a category hits ≥3 entries — don't pre-build empty taxonomy.

---

## 4. Governance constitution (draft → install at vault root as `AGENTS.md`)

1. **Identity** — "You are the Forge, operating inside this Obsidian vault. The vault is the durable brain; sessions are ephemeral."
2. **Folders + permissions** — each dir's purpose + read/write rules (`AGENTS.md`, `_Templates/` read-only to the agent).
3. **Process** — capture every session (timer), consolidate on cadence, forge on demand; **always** update `INDEX.md` + append `LOG.md` on any write.
4. **Sovereignty (3 zones)** — **Z1** agent owns (frontmatter, tags, compaction, INDEX/LOG) · **Z2** agent drafts, human approves (Wiki synthesis, transcript analysis, skill promotion) · **Z4** human only (AGENTS.md, personal notes, missions/campaigns).
5. **Bounds** — `MEMORY.md` ≤ ~2000 chars; promote only above the scoring threshold (§6); dedup before promote.
6. **Privacy** — **Tier 1 sends session content to the configured model provider.** Strip known secret patterns (API keys, tokens, target IPs) before send, or scope Tier 1 to a local/trusted model.
7. **Non-goals (what we are NOT doing)** — no vector DB (grep + wikilinks suffice) · no external service · no auto-modify of `projects/`/source · no sprawling rules dump (this one file) · no auto-promotion without scoring · no opaque UI (everything is git-committed markdown). **YAGNI until a need is repeated.**

---

## 5. Trigger/wiring reality (OpenCode) — honest

No native `session.end`. Three paths, ranked:

1. **systemd timer polling `~/opencode-sessions/`** ← **MVP.** Reliable, no plugin dev, harness-agnostic, cadence/batch-friendly. The poll script **must guard the race**: only process session files whose mtime is > N min old **and** no live OpenCode process holds them. Invokes a shell wrapper → `opencode run vault-keeper` (Tier 0/1).
2. **custom plugin** on the `event` hook (`session.idle`/`session.compacted`) — most "live"; needs TS + upkeep; defer until Tier 0/1 stable.
3. **on-demand skills** — Tier 2 always (`/forge`, `/vault-keeper`, `/dream-review`).

**Deferred free-win:** loading `MEMORY.md` into context at session start. The active plugin's `session:start` hook points at a **missing** `harness-check.sh`; this is **deferred** until that script is written (it would `cat`/include `MEMORY.md` as context, or an `AGENTS.md` include directive is used). Do not assume it works today.

---

## 6. Mechanism provenance (cite, don't reinvent)

| Forge component | Borrowed from | Source |
|------|------|------|
| Tier-1 sleep-time consolidation | **Letta** (MemFS, git-backed, `system/` always-in-context); **Hermes** 3-phase dreaming | docs.letta.com; hermes-agent issue #25309 |
| Char-bounded always-in-context memory | **Hermes** `MEMORY.md` ≤ 2200 chars | hermes-agent docs |
| Scored promotion + success-gate | **Hermes** weights; **Voyager** critic-gate | arXiv 2305.16291 |
| Importance-gated reflection | **Generative Agents** (recency×.5 + relevance×3 + importance×2) | arXiv 2304.03442 |
| Vault structure (PARA + Wiki + INDEX/LOG) | **PARA** (Tiago Forte); agentic-vault / MindStudio / Frank Anaya templates | community consensus |
| Session→skill meta-agent | MindStudio session-to-skill; amplihack; forge; ShelfAI | validated pattern |
| Constitution + Zone sovereignty + lifecycle | AGENTS.md template; Frank Anaya zones; yao-meta-skill; AgentPatterns skill-lifecycle | " |

**Scoring default (ship as-is, tune later):** relevance 30 · frequency 24 · diversity 15 · recency 15 · consolidation 10 · richness 6.

---

## 7. Maintenance & anti-rot (ongoing)

- **Skill lifecycle:** ad-hoc → saved → reusable → documented → governed. Promote only above threshold; **prune** zero-invocation / superseded / redundant / spec-drift. **Pruning runs inside every Tier-1 batch.**
- **Frozen snapshot:** `MEMORY.md` loaded at session start; changes land next start (prefix-cache friendly). **Trade-off:** in multi-hour sessions the agent operates on slightly stale memory — acceptable for typical sessions; a future `session:compacted` hook could re-load.
- **Single-point-of-failure self-heal:** the Tier-2 `forge` skill verifies `LOG.md` session-IDs are contiguous (no gaps) — surfaces a silently-dead timer.
- **Review-before-land** for constitution edits + high-stakes Wiki writes. Dedup before promote. Quarterly human governance review.

---

## 8. Portability (harness-agnostic core)

**Core** (vault layout, constitution, skill format, digest schema, scoring) = plain markdown + shell/python → portable. **Adapter** (session detection + hooks) is the only harness-specific piece. → On **Hermes**: point at its session store, reuse its native dreaming, unify on this vault + constitution. On **Claude Code**: same. On **OpenCode** (now): provides the missing memory layer. Migration = swap the adapter, keep the brain.

---

## 9. MVP build plan (NEXT session — concrete)

1. Install the constitution: `.forge/` + `AGENTS.md`, `INDEX.md`, `LOG.md`, `MEMORY.md`; set `.forge/steering/config` caps.
2. Scaffold the vault (§3) + **INDEX the existing 9 notes** via the migration map — zero content loss, links added.
3. Write **2 skills** under `~/.config/opencode/skills/`: `vault-keeper` (Tier 0 + Tier 1) and `forge` (Tier 2). **Validate against the active plugin `oh-my-openagent@1.14.29`, NOT the dormant slim config.**
4. **systemd timer** → a shell wrapper that runs `opencode run vault-keeper` over new/changed session files, with the **race guard** (file mtime > N min, no live lock). Add `OnFailure=` unit → writes a health flag; LOG.md timestamp health-check.
5. **Test the `.forge/skills` ↔ OpenCode skills linkage** concretely (symlink direction + loader follows links) — don't assume.
6. *(Deferred)* write `harness-check.sh` so `session:start` can load `MEMORY.md`.
7. **Dogfood:** run Tier 0+1+2 on the existing Bolt/rpi-net sessions; write first Wiki analyses; score + promote 1–2 skills.

**Acceptance:** a session ends → within ~30 min a digest appears in `journal/sessions/` + `LOG.md`; a consolidate pass yields ≥1 promoted Wiki note + ≥1 staged skill candidate; `INDEX.md`/`LOG.md` updated; everything git-committed; no secret patterns in any transcript sent to the provider.

---

## 10. Open decisions (next session)

- Tier-1 cadence (nightly vs on-every-N-digests) + exact caps N/M/$X.
- `MEMORY.md` delivery: `harness-check.sh` at `session:start` vs an `AGENTS.md` include.
- Vault migration: in-place vs copy-then-cutover (recommend cutover).
- Sanitization: regex strip vs local-model-only Tier 1.
