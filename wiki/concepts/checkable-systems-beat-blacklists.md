---
type: concept
title: Checkable Systems Beat Blacklists
created: 2026-09-07
status: draft — Z2, agent-authored 2026-09-07, human approves
source: '[[The-cure-for-AI-slop-is-a-1986-aircraft-manual]] + ytobs v2 build session 2026-09-07'
tags: [ai/agents, epistemics, harness, verification]
---

# Checkable Systems Beat Blacklists

**One-line law: you cannot subtract your way to quality — not in prose, not in agent behavior. Quality comes from a system the writer (human, model, or agent) can be checked against, where the checks are mechanical and the taste lives in the system's design, not applied per instance.**

The video's evidence — ASD-STE100 skill cutting measured slop −74% (Claude) / −50% (GPT-5.5) while banned-word lists moved ~0% (Claude) — is about writing. This note's claim: the same law already governs this vault's agent architecture, and the 2026-09-07 ytobs v2 session is a live receipt of it.

## The pattern (three moves)

1. **Name the failure modes.** Prose slop = six habits. Agentslop = nameable process failures (below).
2. **Make each name script-checkable.** Linter for prose; guards, validators, contracts for agents.
3. **Enforce before output ships.** A test the output must pass; a tool that refuses; a breaker that trips.

"No taste required" *at enforcement time* is the whole trick: taste is amortized into the system's design; the per-instance check is dumb, fast, and unbribeable.

## The mapping: prose slop ↔ agent slop

| Video (prose) | Lab (agents) |
|---|---|
| Banned-word list ("no em-dash") | "Be careful" / "don't break things" in prompts — routes around |
| Orwell's 6 rules | AGENTS.md etiquette lines — helps, unenforced |
| ASD-STE100 (53 rules, one-meaning dictionary, length caps) | Vault contract: valid YAML, atomic writes, LOG line, INDEX row, mtimes sacred, Z1–Z4 zones |
| The linter (violations/100 words) | Path guards in tools, gateway breaker trips, rubric gates ≥6/8, [[Operating Principle — Test Don't Wonder]] |
| "A short checkable ruleset is a product" (90% of benefit) | Skills as distilled rulebooks; curated context > raw dumps (mfab: curated .md > man page > --help) |
| Two-mode skill (strict / STE-flavored) | Strict tool guards for mechanical writes; free prose for synthesis notes |
| "Slop is ambiguity with good posture" | Agentslop is process failure with good prose — the report *sounds* done |

The six prose habits have agent analogues, all checkable:

- **Synonym rotation** → inconsistent identifiers/paths across files (grep-checkable)
- **Hedging stacks** ("may potentially help") → "should probably work" instead of verification (receipt-checkable)
- **Nominalization** ("perform an analysis") → tool theater: narrating work instead of doing it
- **Marketing adjectives** ("seamless", "robust") → "seamlessly integrated" in reports = claiming quality instead of showing evidence
- **Run-on sentences** → context stuffing instead of structured briefs
- *(agent-only)* **silent success claims** → the master check: "never claim success without evidence"

## Today's receipts (2026-09-07, ytobs v2 session)

The session ran the pattern end-to-end, accidentally running its own experiment:

1. **The guard refused; the agent complied; the log told the truth.** The digest agent attempted to patch INDEX.md three times; the path-guard refused every time (a bug — over-strict — but a *deterministic* refusal); the agent could not route around it, appended a FAIL LOG line staging the row for the human, and called finish. That FAIL line is the anti-slop event: a mechanical check caught a nonconforming write and forced honesty. The bug was then fixed by design rules, not by trusting the agent harder (`patch_note` may now edit INDEX.md; wholesale overwrite stays refused).
2. **Fallback chain > hoping.** Lusófona gateway 503 → local faster-whisper. The pipeline didn't die or hallucinate; it degraded on a *named, checkable condition* (HTTP status). The fabric-era pipeline stops here permanently.
3. **Transcript honesty markers.** The digest note flags small-model garbling ("Orville"→Orwell, author handles) in a warning callout and marks uncertain names `unclear` instead of inventing — form discipline in service of substance.

## Where the analogy breaks (the interesting part)

- **Form vs substance is asymmetric in agent work.** For prose, the video concedes STE fixes form only. For agents, the *form checks* are what make *substance verifiable*: atomic writes and LOG lines are what make an agent's claim checkable at all. Here, some form-fixing IS substance-fixing — the guard doesn't just prevent bad notes, it produces the audit trail that makes trust possible.
- **Judgment rules vs slop rules.** STE's maintainers: no software can certify full compliance — some rules need a human. Same boundary here: guards verify a note is well-formed and linked; only the human (or a Critic gate) judges whether it is *true* and *worth keeping*. The Z2 status on this note is that boundary, live.
- **Model-dependence is a law for us too.** Banned-words worked on GPT (−40%) but ~0% on Claude. A rule set calibrated on one model family may silently fail on another — this fleet runs zai/glm, qwen, and the Lusófona 9Bs. Rule efficacy must be *measured per model* (that is what or-bench is for; the inference-engineer sweep discipline).
- **n is still tiny.** The video: 6 tasks × 2 models, author's own linter. This note: one session's receipts, interpretive mapping. Both are hypotheses with receipts, not laws. Keep the falsification edge — that is the point, not a disclaimer.

## Actionable consequences

1. **Guards ship inside every tool we build** (path validation, atomic writes, protected paths) — never as a prompt request. ytobs' `write_note` / `patch_note` / `append_log` are the template.
2. **Distill, never paste.** Skills and contracts stay short and checkable; the 434-page version loses to the 10-line checkable ruleset in both context economy and compliance rate.
3. **Calibrate rules per model before fleet adoption** (or-bench pattern). Claude's flashy slop vs GPT's quiet slop warns: checkers must measure, not assume symptom sets.
4. **Honesty markers on machine output are load-bearing** (transcript quality flags, `unclear` marks) — they keep the digest pipeline's claims falsifiable.
5. **Scripts take everything mechanical; the human/Critic gate keeps judgment.** Neither expands into the other's territory.

## Connections

- [[The-cure-for-AI-slop-is-a-1986-aircraft-manual]] — source video digest (the evidence base)
- [[Operating Principle — Test Don't Wonder]] — the epistemic constitution this pattern implements
- [[ORCHESTRATION]] — deterministic anti-slop gates on the artifact side
- [[Harness-Porting-Strategy]] — prevention layers in system prompts
- [[the-forge-synthesis]] — the capture→consolidate→forge loop this pattern protects
- [[multi-agent-orchestration-patterns]] — breaker + validators as fleet-scale checkable systems
