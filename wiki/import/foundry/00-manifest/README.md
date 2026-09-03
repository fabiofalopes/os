# THE FOUNDRY

**Craft:** dimensional translation — making high-dimensional systems walkable-through.
**Artifact:** the vault ontology. Videos are exhaust.
**Gate:** an artifact ships only if the user could NOT have predicted it.

```
00-manifest/      the law: orchestration prompt, README (this file), decisions log
10-canon/         the book's chapters — concept notes, each with spatial intuition
                  + visual-representation candidates. Sources: primary literature.
20-grammar/       the invented visual language. Nothing renders before this
                  survives review. Includes the JSON schema scenes consume.
30-ground-truth/  real data from real runs: attention maps, SVD projections,
                  loss curves, quantization error fields. Provenance notes
                  with every dataset.
40-skills/        the craft made executable: manim-artist, ground-truth-binder,
                  scrollytelling. Source of truth for ~/.claude/skills/ installs.
50-artifacts/     shipped work + reference-101/ (the slop-floor baseline we
                  must always beat)
90-sessions/      one file per working session: what was learned, what changed,
                  what the next artist needs. The loop's memory.
```

## Method (the loop)

1. **Read before write** — 00-manifest → 10-canon → 20-grammar. Never invent what the foundry already holds.
2. **Canon before grammar, grammar before render.** G1→G2 gate everything; renders without approved grammar are 101-tier by definition.
3. **Ground truth or it didn't happen** — every number on screen traces to 30-ground-truth/.
4. **Every session writes back** — a session that doesn't grow the vault produced nothing.
5. **Log decisions** — anything decided goes in 00-manifest/DECISIONS.md, with why.

## State

- **Phase:** G1 (canon) — pre-grammar, no rendering authorized
- **Toolchain:** `~/bin/manim` (rootless; see memory `manim-local-setup`), GPU via PrimeIntellect
- **Vault:** `~/obsidian-vault-kali` (canon notes mirror into `vault/transformers/`)
- **Reference floor:** `50-artifacts/reference-101/` — beat this or don't ship
