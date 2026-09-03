# Vault AGENTS.md — conventions for the Breaking Claude vault

AI-orientation-first vault: sessions boot by reading a fixed file set and
close by writing state back. Knowledge compounds because nothing learned stays
in chat scrollback.

## Boot protocol (before ANY work, in order)
1. `~/.agents/AGENTS.md` (who I serve, standing rules)
2. `~/breaking-claude/AGENTS.md` (project standards)
3. This file
4. `MASTER_INDEX.md`
5. `handoff.md`
6. `00-context/` — mission, me, timeline
7. `80-solved/` index, then `90-open/` index

Then output a **five-line orientation summary** (what I know, mission state,
what I'm about to do) BEFORE acting. A wrong boot is cheaper to fix than wrong
work — if corrected, that's a V4 data point.

## Structure
`00-context` charter/env/timeline · `10-moc` hubs · `20-claims` typed claims ·
`30-sources` sources w/ trust tier · `40-versions` one note per version ·
`50-experiments` · `60-decisions` append-only · `70-sessions` one per session ·
`80-solved` registry · `90-open` queue · `raw/` COLLECTOR drops · `_templates`.

Every non-trivial folder carries `index.md` (purpose, key files, status).

## Note schema
Every note is typed with YAML frontmatter. Claim grades: `4 DEMONSTRATED /
3 DOCUMENTED / 2 CLAIMED / 1 SPECULATION`. Grade may only rise on new
evidence; reaching 4 requires an experiment note that reproduces. Status:
`unverified → verified | refuted`; `superseded` always links its successor via
`superseded_by`. IDs at creation (`CLM-####`, `SRC-####`, `VER-####`,
`EXP-####`, `DEC-####`, `SES-####`, `SOL-####`, `Q-####`), referenced by ID
thereafter. Templates in `_templates/` — copy, don't improvise.

## Mutability rules
- `raw/` IMMUTABLE. Never modified after drop.
- `log.md` append-only.
- `60-decisions/` append-only — overturned by a NEW note that links and
  supersedes, never by editing.
- Stale material moves to an `archive/` folder marked do-not-search.
- Naming: kebab-case, no spaces.

## Graph rules
Link aggressively with `[[wikilinks]]`; tags secondary. MOCs are the hubs —
every note reachable from a MOC in ≤2 hops. An orphaned note is a defect:
every new note gets linked from its MOC in the same cycle. The graph is a
deliverable: clusters should mirror the mission, not a hairball.

## Write-back ritual (session close, in order)
1. Session note → `70-sessions/` (work, models used, cycle metrics, failures)
2. Create/update every touched claim; bump `last_confirmed`; grades per rules
3. Solved → `80-solved/` (with proof links); new questions → `90-open/`
4. Decisions → `60-decisions/` (context, options, rationale)
5. Append `log.md`
6. Rewrite `handoff.md`: completed / needs human review / deferred / next
7. Update `MASTER_INDEX.md` + MOC links. No orphans.

A session that ends without rewriting `handoff.md` is incomplete and gets
flagged at next boot.

## Anti-amnesia
- Check before work: search `80-solved/` and `60-decisions/` first. Never redo
  solved work; never re-litigate a decision without citing new evidence.
- The vault is the memory. If it isn't written here, it didn't happen — an
  agent that "remembers" something the vault doesn't is wrong by definition.

## Vault health metrics (OPTIMIZER-owned, reported every retrospective)
V1 verified ratio (% claims grade ≥3, up) · V2 orphan rate (→0) ·
V3 link density (up) · V4 boot accuracy (→100%) · V5 re-investigation
incidents (→0; every incident is a defect in THIS layer, not the agent).
