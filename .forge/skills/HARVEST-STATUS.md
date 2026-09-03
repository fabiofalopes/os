---
tags: [skills, harvest, smith, inventory, verdict, meta]
date: 2026-07-20
role: Smith
status: durable verdict — supersedes the OpenCode numbers in Skills Harvest
related:
  - "[[Skills Harvest — What's Here & What To Do Differently]]"
  - "[[Sources — Curated Seed Library]]"
  - "[[Agent Roles & Orchestrator — The Moat]]"
---

# HARVEST-STATUS — OpenCode Stubs & Pentest Library Verdict

> Smith pass over the OpenCode skill holdings, per [[Skills Harvest — What's Here & What To Do Differently]] actions #4 (fill-vs-kill the stubs) and #5 (domain-vs-archive the pentest library). **Method: test, don't wonder — every number below was measured on the filesystem, not read from the note.**

## TL;DR

1. **The note's OpenCode numbers are wrong.** There are **no 37 empty stubs** and not "40 pentest skills." Reality: a canonical store of **8,983 real skills** at `~/shared-local/hub/curated/skills/`, surfaced into OpenCode as a **39-category symlink farm** at `~/.config/opencode/skill-vault/` (9,343 links).
2. **Fill-vs-kill → clean negative result.** Zero empty stubs exist, so there is nothing to fill and nothing to kill. The premise does not survive contact with the disk.
3. **Pentest library → ARCHIVE (keep-in-place), promote to a domain queue only on a sanctioned security/bounty campaign.** Do not import the ~9k bulk cards into the vault. Do not delete them either.
4. **Bonus:** the note's open question — *"canonical skill-store path?"* — is **already answered by existing infra.** The store exists; the Forge should point its output at it, not build a new one.

---

## 1. Reality check — the note vs. the filesystem

| Note's claim | Measured reality | Verdict |
|---|---|---|
| Skills at `~/.config/opencode/skills/` | That path **does not exist.** Skills live at `~/.config/opencode/skill-vault/` (a symlink view) over `~/shared-local/hub/curated/skills/` (the real store). | ❌ wrong path |
| "40 pentest skills" | **38–39 domain categories**; **8,983** real SKILL.md behind them. | ❌ conflated categories with skills; undercount ~225× |
| "5 workflow skills" | **5 agent definitions** in `~/.config/opencode/agents/`: `hermes, kali-director, kali-exploit, kali-recon, mirror`. | ⚠️ roughly right — they are agents, not skills |
| "skill-vault/ = 37 empty stubs (unrealized)" | **0** empty dirs, **0** skill dirs missing a SKILL.md, all 9,343 links resolve to real files. | ❌ false — no empty stubs exist |
| "fleet-optimizer is the most valuable artifact" | Confirmed real: `loop.sh + AGENT.md + SKILL.md + state/ + reports/` (1 report). | ✅ confirmed |
| "Claude Code: 22 curation skills" | 22 dirs in `~/.claude/skills/`. | ✅ confirmed |

**Why the note got fooled (forensic note):** every `skill-vault/*/…/SKILL.md` is a **symlink**. `find -size` reports the *link-string length* (so ~8k files looked "<200 bytes") and `grep -r` does **not** follow symlinks (so content greps returned 0). Both made a fully-realized library look like a graveyard of stubs. Measuring with `-L` / `find -exec` reveals the truth.

---

## 2. The actual inventory

### Canonical store — `~/shared-local/hub/curated/skills/` (8,983 real skills, 19 collections)

| Collection | Skills | Character |
|---|---:|---|
| **cyberstrike** | **7,633** | **bulk auto-generated MITRE ATT&CK / CIS reference cards (85% of everything)** |
| anthropic-cyber-skills | 754 | security |
| awesome-offsec-skills | 194 | security |
| redhound-arsenal / -jph | 76 / 76 | tool-operating skills (e.g. `wifite`) |
| transilience-tools | 52 | security |
| craighewitt-skills | 49 | security |
| ultraship | 41 | security |
| claude-security-skills | 25 | security |
| supabase-pentest | 24 | security |
| superhackers / agile-v-skills | 22 / 22 | security |
| audn-ai / pownie / loopspell / drapala / codex-pentest | 7 / 4 / 2 / 1 / 1 | security |
| **thinking-skills / agentseal** | **0 / 0** | **empty collections (the only real "stubs" anywhere — see §3)** |

### OpenCode domain view — `~/.config/opencode/skill-vault/` (39 categories, 9,343 symlinks)
38 pentest/security categories + 1 workflow (`fleet-optimizer`). Largest: `cis-hardening` 5,004 · `compliance-governance` 1,000 · `other-pentest` 404 · `monitoring-auditing` 393 · `authentication-authz` 368. These are **re-groupings of the store above**, not independent skills (9,343 links > 8,983 files ⇒ some skills appear in >1 category).

### Agents — `~/.config/opencode/agents/` (the "5 workflow skills")
`hermes.md · kali-director.md · kali-exploit.md · kali-recon.md · mirror.md`

### Live loop — `~/.config/opencode/agent-loops/fleet-optimizer/`
`loop.sh · AGENT.md · SKILL.md · bin/ · state/ · reports/` — the working *cron→observe→self-tune→report* pattern the note correctly flags as the Conductor template.

---

## 3. Fill-vs-kill the "37 stubs" → **clean negative result**

**Requested:** list 37 empty stubs, recommend fill-vs-kill each. **Finding: the set is empty.**
- Empty dirs under `skill-vault/`: **0**. Skill dirs missing a SKILL.md: **0**. Stub/placeholder/TODO markers in any SKILL.md: **0**.
- Therefore there is **nothing to fill and nothing to kill.** This is the durable negative result — the Janitor need not prune here.

**What the note most likely mistook for stubs, and the verdict for each real thing:**

| Real artifact | Count | Fill or Kill? |
|---|---:|---|
| Domain **category folders** with no category-level SKILL.md (taxonomy, not stubs) | 38 | **Neither — leave as-is.** They are organizational. Optional low-priority: add a one-line category index SKILL.md later. |
| **Empty collections** in the canonical store: `thinking-skills`, `agentseal` | 2 | **Kill** (rmdir the two empty dirs) — or fill only if a real repeated task names them. Curate, don't hoard. |
| **Bulk reference cards** (`cyberstrike` 7,633 MITRE/CIS) | 7,633 | Not stubs (they're full) but **low-signal mass**. **Leave in place; do not surface into the vault or the active picker.** Mine selectively only if a security campaign needs a specific technique. |

---

## 4. Pentest library → **ARCHIVE (keep-in-place)**, conditional promotion

**Verdict: archive now; promote to a domain queue *only* if a security/bug-bounty campaign is sanctioned in `projects/`.**

Rationale (mission-weighted):
- **Curate, don't hoard.** 85% of the library (7,633 cards) is bulk auto-generated reference. Symlinking ~9k cards into `.forge/skills/` or git-tracking them is bloat with near-zero marginal signal. A smaller, sharper vault wins.
- **Stay vertical.** The active vertical is curation → quant/AI-ML → revenue. Security is not in the current plan; importing the library now is a side quest.
- **Don't delete — it's already "archived" correctly.** The library lives **outside the vault** in `~/shared-local/…` (zero cost to the vault, untracked, fully reversible), and the vault has a *real* security thread ([[Bolt Security Research — MITM Attack Capability]], [[Wireless Pentesting Infrastructure — Kali RPi]], [[RPi-Net Session Log]]). Bug bounties/audits are a legitimate revenue path — keep the option, don't pay the carrying cost.
- **Decide, don't leave ambient.** The decision is explicit and reversible, with a documented trigger (below).

**Promotion trigger:** when a `projects/<security-campaign>` is opened and human-sanctioned, the Smith (a) writes a thin `wiki/` pointer note cataloguing the 38 domains + store path, and (b) symlinks *only the handful of skills that campaign actually uses* into `.forge/skills/` for SkillOpt optimization — never the whole library.

**One flag (out of my scope, don't act):** 9k skills in OpenCode's active picker is noise. Whoever owns OpenCode config may want to point the picker at a *narrow* subset rather than the whole `skill-vault/` farm. Noted, not done.

---

## 5. The canonical-store open question is already solved

The note asks *"canonical skill-store path — vault `.forge/skills/` vs `~/.claude/skills/`?"* **Neither needs to be built: `~/shared-local/hub/curated/skills/` already is the cross-harness canonical store**, with `skill-vault/` as a domain-symlink view over it. Recommended division of labor:
- **`~/shared-local/hub/curated/skills/`** = imported/curated store (the seed catalog, already shared).
- **`.forge/skills/` (vault, git-observed)** = skills the Forge *forges and optimizes against our own usage* (the moat, per note §2.2). Symlink forged skills **out** into the shared store / each harness so Claude Code + OpenCode + Hermes all see them.

This realizes harvest action #1 without new infrastructure.

---

## 6. Next actions (handed back to the orchestrator)

1. **[Janitor]** `rmdir` the two empty collections `thinking-skills/`, `agentseal/` in the canonical store (the only real stubs). *Trivial, safe.*
2. **[Scribe]** Write the thin `wiki/` pointer note for the pentest library (38 domains + store path + promotion trigger) so the archive is *decided and documented*, not ambient.
3. **[Orchestrator]** Close harvest actions #4 (fill/kill) as a **clean negative result** and #5 (domain/archive) as **ARCHIVE-conditional** — update [[Skills Harvest — What's Here & What To Do Differently]] numbers to the measured ones above.
4. **[Smith, deferred]** When any role repeatedly performs a task, forge it into `.forge/skills/` and symlink out to the shared store; run SkillOpt on the 22 curation skills we actually use (the moat).

---

## Appendix — evidence (reproducible)

```bash
# real skills, following symlinks
find -L ~/shared-local/hub/curated/skills/ -name SKILL.md | wc -l        # 8983
# OpenCode domain view (symlinks)
find ~/.config/opencode/skill-vault -name SKILL.md | wc -l               # 9343
ls -d ~/.config/opencode/skill-vault/*/ | wc -l                          # 39 categories
# no empty stubs
find ~/.config/opencode/skill-vault -type d -empty | wc -l               # 0
find ~/.config/opencode/skill-vault -mindepth 2 -maxdepth 2 -type d \
     ! -name '_*' | while read d; do [ -f "$d/SKILL.md" ] || echo x; done | wc -l   # 0
# proof it's a symlink farm
ls -la ~/.config/opencode/skill-vault/wireless-rf/wifite/SKILL.md        # -> shared-local/.../wifite/SKILL.md
# agents = the "5 workflow skills"
ls ~/.config/opencode/agents/                                            # 5 files
```
*All counts measured 2026-07-20 on the Kali Lenovo.*
