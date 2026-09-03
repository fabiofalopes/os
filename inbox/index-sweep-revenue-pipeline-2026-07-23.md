---
tags: [meta, index, curator, handoff]
date: 2026-07-23
status: ready-to-apply — paste-ready INDEX entries; serial Curator applies (workers may not edit INDEX.md)
related:
  - "[[INDEX]]"
  - "[[tool-pilot-01]]"
  - "[[tool-pilot-01-outreach]]"
  - "[[tool-pilot-01-publish-checklist]]"
  - "[[cron-agent-swarm]]"
  - "[[forecast-pilot-01]]"
---

# INDEX Sweep — Revenue Pipeline + Forged Skill (2026-07-23)

> Curator worker artifact. The map in [[INDEX]] stops at 2026-07-21; the closest-to-revenue
> artifacts (ledger rows 1 & 2 and the forged skill under test) are invisible to future
> sessions. Entries below are verified against the notes on disk and written in INDEX style
> (wikilink + one dense line). **Not applied here** — the shared substrate is read-only for
> parallel workers; the serial Curator/runner pastes them in.

## Where each entry goes

| Entry | INDEX section | Insert after |
|---|---|---|
| `forecast-pilot-01` | `## Value (wiki/value/)` | `[[ledger]]` |
| `tool-pilot-01` | `## Value (wiki/value/)` | `forecast-pilot-01` |
| `tool-pilot-01-outreach` | `## Value (wiki/value/)` | `tool-pilot-01` |
| `tool-pilot-01-publish-checklist` | `## Value (wiki/value/)` | `tool-pilot-01-outreach` |
| `cron-agent-swarm` | `## Harness & Operations (the cron swarm)` | `[[HARVEST-STATUS]]` (the other `.forge/skills/` entry) |

## Paste-ready entries

```markdown
- [[forecast-pilot-01]] — Ledger row-1 calibration test (LOCKED pre-commitment, hash-frozen vectors): 21 binary prediction-market questions, 3 domains, resolving 2026-08-04 → 09-01; Forge vs the real-money market by Brier score, verdict ladder INCONCLUSIVE-guard → KILL (BS_F ≥ BS_M, the operative kill) → NO EVIDENCE → PROMOTE. Critic-hardened 2026-07-22 (precondition guard first, single score run ≥2026-09-02, exclusion lock, integrity hashes). Honest caveat: no independent news access, so the batch falsifies but cannot confirm the thesis. First resolution 2026-08-04; scored once on/after 2026-09-02.
- [[tool-pilot-01]] — Ledger row-2 demand test (LOCKED pre-commitment): give away the forged [[cron-agent-swarm]] skill at $0 on a frozen N=3 channels and count qualified-interest signals `Q` over 21 days from first publish (T0); frozen verdict ladder NOT SEEN (checked first) → KILL (seen & Q=0) → PROMOTE (Q≥3 or ≥1 direct pay request) → WEAK. Qualified-signal definition + anti-fooling commitments frozen pre-publish; a KILL is a live, honest outcome. Untested — clock starts at first (human-approved) publish; the fastest revenue evidence available (row 1 is static until 2026-08-04).
- [[tool-pilot-01-outreach]] — STAGED outreach pack for [[tool-pilot-01]] (nothing published; human posts, Z2/outward): GitHub repo README + the 3 frozen channel posts (r/ClaudeAI primary, r/ObsidianMD secondary, Obsidian forum tertiary — HN deliberately excluded, staged in Appendix A as the one redesign lever) + a mechanical T0 tracking sheet (Table A visibility/NOT-SEEN check, Table B frozen Q-tally, in-order verdict box) so the T0+21d scorer session is copy-paste. Honesty rule: no hype, no ROI claims, organic-only signals.
- [[tool-pilot-01-publish-checklist]] — One-screen human go/no-go handoff for [[tool-pilot-01]]: exact submit URLs for the 3 frozen channels, the ~5-minute secret-scan-then-publish command sequence (Lusófona key must never ship), and the frozen Q definition + verdict thresholds restated verbatim; ends in a ☐ GO / ☐ NO-GO checkbox. Skill files + forum URL verified on disk/web 2026-07-23. Nothing published.
- [[cron-agent-swarm]] — Forged skill (`.forge/skills/cron-agent-swarm/`, v1.0.0, draft Z2): this vault's own cron engine de-vaulted and packaged — one cron line → dispatcher claims queue jobs → N parallel bounded agent workers per tick each writing one durable artifact, with model fallback chain, substrate snapshot/revert, self-tuning review loop, and a Z1/Z2/Z4 governance template; agent-CLI-agnostic (Claude Code / opencode). Evidence: 15/15 production provenance, `bash -n` clean, dry-run PASS, Critic clean-room install PASS 2026-07-23 (caught + fixed 4 real bugs). The artifact under test in [[tool-pilot-01]] — publish is human-approved.
```

## Adjacent finding (Curator's call)

- `wiki/value/forecast-pilot-01.md` carries `date: 2026-07-21` (forecasts captured then) but was
  Critic-hardened 2026-07-22 (file mtime 07-22 14:53) and is **unmapped** — strictly it predates
  the "since 2026-07-22" cutoff by its own date field, so it wasn't in the ticket's named list.
  Included above anyway: it is ledger row 1, the other half of the revenue pipeline, already
  wikilinked from `tool-pilot-01` as a dangling `[[forecast-pilot-01]]`, and exactly the
  closest-to-revenue invisibility this sweep targets. Drop the entry if the cutoff is strict.

## Verification (test, don't wonder)

- All 5 notes read in full (or frontmatter+kill-criterion for the long ones) on disk 2026-07-23;
  summaries above restate their own frontmatter status + frozen verdicts, not inference.
- `wiki/value/` and `.forge/skills/` listed: no other unmapped notes in those dirs
  (`ledger.md` already mapped; `README.md` files are stubs; `HARVEST-STATUS.md` already mapped).
- INDEX.md confirmed to stop at 2026-07-21 (last Value entry = `[[ledger]]`, seeded 2026-07-21).
