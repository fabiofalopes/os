---
source: https://www.youtube.com/watch?v=uJblcC4lKYw
title: The cure for AI slop is a 1986 aircraft manual
channel: Ege Vusal Chelebi
date: 2026-07-24
duration: 16m41s
type: video-note
tags: [ytobs, ai-writing, prompt-engineering, technical-writing]
status: raw-import
---

> [!warning] Transcript quality
> Machine transcript (faster-whisper **small**) — proper nouns and numbers are garbled in places (e.g. "Orville" → Orwell, "Ranowns" → run-ons, "down 7.4%" → almost certainly −74%, "Joe Grissel/Hustler" → @geogristle/@mikehostetler per the video description). Restored where certain, marked `unclear` where not.

## TL;DR

Banning "delve" and em-dashes fails because it is whack-a-mole against a model that never chose those words on purpose — it has no writing system, so it defaults to the average of the internet. The video's bet: ASD-STE100, the 1986 aerospace controlled-English spec (53 rules + a ~900-word one-meaning dictionary), kills AI slop by design because its rules are *machine-checkable* — no taste required. The author distilled all 434 pages into an agent skill + a linter and ran the test nobody had run: 6 real dev writing tasks × 4 conditions × 2 models. Result: STE cut linter-measured slop ~74% on Claude (best by far) and 50% on GPT-5.5 (tied with Orwell's rules), while the banned-words list moved Claude by 3% — a slop paragraph that merely lost its em-dashes. Verdict: any real, checkable writing system halves slop; STE fixes the **form** of slop, never the substance — use it where invisible clarity is the whole job, and nowhere voice matters.

## Key ideas

- **Blacklists lose by construction.** The model "was never choosing those words on purpose"; banning surface tokens routes slop elsewhere. The damning data point: the banned-words list killed Claude's em-dashes (6 → 1) while total slop barely moved (4.36 → 4.21 violations/100 words) — "you banned the em-dashes and you got a slop paragraph with no em-dash in it" [11:47].
- **Slop is six mechanical habits, and nameable = checkable.** Synonym rotation (the user/the customer/the client), hedging stacks ("may potentially help to improve" — five verbs, zero verb), nominalization ("perform an analysis" instead of "analyze"), marketing adjectives ("seamless", "robust"), run-on sentences stitched with em-dashes/semicolons, and overused phrasal verbs ("spin up", "reach out") [02:22–03:43]. Anything you can name, a script can ban.
- **ASD-STE100 maps 1:1 onto all six.** One name per thing + one-meaning dictionary (rule 1.11; "fall" only means gravity, "start" replaces begin/commence/initiate), no complicated verb constructions (3.4), verb for the action not the noun (3.7), unapproved adjectives simply don't exist in the dictionary, hard caps of 20 words per instruction (5.1) and 25 per descriptive sentence (6.3) with the semicolon banned outright, no phrasal verbs (9.3) [05:53–06:50]. Spec: free download, issue 9 (Jan 2025) via asd-ste100.org.
- **The human evidence is real but bounded.** 1996 (Sherbak/Dury/Volet — *names as transcribed*): 175 technicians, comprehension 76% → 86%, and for non-native speakers 69% → 87% — the constraint pulled struggling readers up to native level. Microsoft 2007: controlled English beat normal English in translation into all four languages tested (odds of luck < 1/1000); the single most effective rule was cutting flowery informal phrasing. Caveats the video gives honestly: translation gains were small (tenths of a point on a 4-point scale), an Airbus study found oversimplifying can backfire, and every study measures *understanding*, not memory [08:34–10:09].
- **The unrun test, run.** 6 tasks (readme, PR description, API docs, error message, getting-started guide, deprecation notice) × 4 conditions (baseline / banned-words list / Orwell's 6 rules / STE skill) × 2 models, scored by a custom linter in violations per 100 words [10:13]. Claude: 4.36 → 2.48 with Orwell (−43%) → **1.12 with STE (−74%)**. GPT-5.5: STE −50%, banned-words −40%, Orwell tied STE — so the brutal 3% for blacklists was a Claude quirk, not a law.
- **Models slop differently — which is why systems beat lists.** Claude's slop is flashy (em-dashes, "seamless", long run-ons); GPT's is quiet (clean-looking sentences that are just too long and too passive) [12:35]. The finding that survives both: give the model a real writing system and slop drops by half or more, every time tried.
- **Deploy it distilled, not pasted.** The spec is copyrighted and its 900-word dictionary burns context for nothing. Two-mode skill: *strict* (full rules + hard caps) for procedures and error messages; *STE-flavored* (sentence/paragraph discipline, no phrasal verbs, no dictionary lockdown) for normal prose [13:56]. A 10-line checkable ruleset gets ~90% of it — "the standard is one option; a short checkable rule set is a product."
- **The boundary: form, not substance.** A linter produces "a clean, confident, well-punctuated hollow paragraph. It cannot make it true" — slop is two problems wearing one coat: bad writing and nothing to say [14:46]. Keep STE away from anything with a voice: "running your marketing copy through STE is a torque-wrench spec applied to a poem" (*image as garbled in transcript*).

## Notable quotes

- "AI slop is just ambiguity with good posture." — on why a 40-year ambiguity-killing spec transfers to AI output [06:50]
- "Everything it deleted was slop. Nothing it deleted was information. The gap between what you cut and what you lose is the entire game." — the STE-rewritten error message that scored a perfect zero [08:20]
- "You will not fix AI writing by banning [delve] … You fix it by giving the model a system it can check itself against instead of a blacklist it will always route around." [15:54]
- "Constrain the writer and you free the reader." — the closing principle [16:04]

## Connections

- [[Operating Principle — Test Don't Wonder]] — The video *is* this principle aimed at prose: the viral claim was "a guess by analogy," so the author built a falsifiable gate (violations/100 words) and published the numbers that weaken his own headline (GPT-5.5's banned-words −40%).
- [[Skill-Candidate-Map-2026-07]] — Tracks an already-built `ai-deslop` skill (CC+OMX, "✅ built"); this video supplies the evidence base and the content such a skill should distill — plus the warning that a tiny checkable ruleset captures most of the benefit.
- [[ORCHESTRATION]] — The foundry's anti-slop gate defines slop from the artifact side ("predictable-in-shape") and rejects it with a deterministic check; the video does the same from the prose side. Both refuse taste-based judgment in favor of script-checkable rules.
- [[Harness-Porting-Strategy]] — Names "anti-slop rules in system prompt" as the prevention layer; this video is the first controlled A/B of exactly that lane (skill file vs blacklist vs nothing).

## Open questions

- **n is tiny and the judge is the author's own linter.** 6 tasks per model, one linter, one author — the −74% vs −43% gap is indicative, not significant; and no human evaluation of the *AI* output was run (the human studies are on aircraft manuals, not model text).
- Verify the study details against sources before citing: the 1996 author names ("Sherbak, Dury and Volet" — likely garbled) and the rule numbers (1.11, 3.4, 3.7, 5.1, 6.3, 9.3) came from a small-model transcript.
- The Boeing claim — a simplified-English checker with a 350-rule parser shipped since ~1990 — is the video's, unverified here.
- Would the GPT-5.5 result (banned-words working, −40%) hold on other model families (Llama, Mistral, Gemini)? Untested; only Claude and GPT were sampled.
- Skill + linter + full numbers live at the author's site (chele.bi/videos/the-cure-for-ai-slop) — pull and audit if we build the `ai-deslop` skill upgrade.
