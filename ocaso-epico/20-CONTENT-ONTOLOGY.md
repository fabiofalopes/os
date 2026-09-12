---
tags: [project, foundry, x-twitter, ontology, content]
date: 2026-09-12
status: Z2 DRAFT — agent-authored from human brainstorm, human approves
related: "[[00-CHARTER]]", "[[10-ARCHETYPE]]", "[[30-SOURCES]]"
---

# Content Ontology — @ocaso_epico

The ontology this agent runs on: entities (claims, sources, pillars, formats, posts,
metrics), relations (claim ← sources; post → pillar; metric → post), and the loop that
grows it (research → draft → post → measure → learn). Each posting agent is its own
vertical ontology loop; this file is @ocaso_epico's.

## Pillars (v0)

| # | Pillar | What it is | Seed claim-cluster |
|---|--------|-----------|--------------------|
| P1 | **Mito / Realidade** | Two-liners correcting the global myth ("drugs are legal in PT") vs. what Lei 30/2000 actually did: decriminalized consumption, kept the market criminal. | The format IS the brand. |
| P2 | **Arquivo da Hipocrisia** | Receipts side-by-side: tobacco/alcohol state revenue vs. cannabis arrests; Bernays' "Torches of Freedom"; China Tobacco as the state-monopoly mirror. | Punch the structure, not people. |
| P3 | **Mercado Ilícito em Aberto** | What decriminalization never touched: the bunk-drug scam economy, open-air scenes that persist, the loop that keeps people on the street. | Consumer-protection angle of regulation. |
| P4 | **Evidência** | Studies, official data (EMCDDA/SICAD/DGS), both supportive AND critical evaluations — we cite our critics too. | Trust built by balance. |
| P5 | **Meta / Experimento** | Calm, technical documentation of this account being an agentic experiment. | See [[40-EXPERIMENT]]. |

## Formats (v0)

- **Two-liner** (P1 bread and butter): `MITO: … / REALIDADE: …` + source link.
- **Receipt-thread** (P2/P4): 5–8 tweets, one receipt per tweet, no editorializing until the last tweet.
- **Street-realism short post** (P3): one observation, no melodrama, one source.
- **Meta-log post** (P5): what the machine did this week; what broke; what it cost.

## Language

PT-first (the discourse to shift is Portuguese). EN only for globally-viral receipts.
No jargon walls. Plain speech, dry humor.

## Editorial workflow (hard rule)

draft (agent) → **human approval** → queue → post (`tweet.py post`) → log row →
weekly metric snapshot. Nothing posts without the human gate while the account is
young (< 90 days or < 1k followers, whichever later).

## Cadence & algorithm discipline (v0, until research says otherwise)

- 1 post/day max for weeks 1–2 (fresh account — rate-limit & suspension risk is real).
- Replies > broadcasts early: 2–3 thoughtful replies/day in PT policy/cannabis discourse.
- No hashtags stuffing; 0–2 relevant PT hashtags max.
- TO RESEARCH (open): current X algorithm weighting (reply-to-repost ratio, dwell,
  external-link penalty, timing windows for PT audience). Research routine task —
  [[50-HARNESS]] § research integration.

## The loop (weekly cycle)

1. **Research**: gather + verify sources → append to [[30-SOURCES]].
2. **Draft**: 3–7 drafts mapped to pillars → human picks/approves.
3. **Post**: approved queue, spaced ≥ 6h.
4. **Measure**: impressions/replies/profile visits → post-log.
5. **Learn**: what earned reach → adjust pillar mix + formats. Ontology updated HERE.
