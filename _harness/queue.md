# Session Queue

> The runner picks the **top unchecked** `- [ ]` job each tick, runs it, checks it off.
> Add jobs anywhere; order = priority. Keep each job to one bounded session's worth.
> Tag each with a role: [Scout] [Scribe] [Curator] [Janitor] [Distiller] [Smith] [Quant] [Steward] [Critic].

## Standing up the substrate (do first)
- [x] [Curator] Create INDEX.md at the vault root: catalog every existing .md note as a wikilink + one-line summary. This is the map every future session consults.
- [x] [Steward] Create MEMORY.md at the vault root (≤2000 chars): the always-in-context working memory. Seed it with the mission, the vault layout, and the current top priority. Keep it char-bounded.
- [x] [Janitor] Create inbox/, journal/sessions/, wiki/{concepts,research,value}/, projects/, .forge/skills/ per CLAUDE.md. Do not move existing notes yet — just scaffold empty dirs with a one-line README each.

## Knowledge harvest (Scout/Scribe)
- [x] [Scout] Work the ★★★ tier of [[Sources — Curated Seed Library]] §A (self-improving agents). Clip SEAL, Voyager, Reflexion, ADAS into wiki/research/ai-ml/ as atomic notes, each with a one-line "what it gives the harness" verdict. Confirm the to-verify arXiv ids as you fetch.
- [x] [Scout] Work [[Sources — Curated Seed Library]] §C (quant/finance). Clip the López de Prado overfitting guards + Kelly criterion into wiki/research/finance/ with verdicts. This is the anti-fooling-yourself foundation for the money mission.
- [x] [Scribe] Read the five 2026-07-20 planning notes (Master Plan, Roles & Orchestrator, Life Arc, Operating Principle, Skills Harvest, Sources) and write wiki/concepts/the-forge-synthesis.md: one tight page linking them into a single coherent picture.

## Skill harvest (Smith)
- [ ] [Smith] Per [[Skills Harvest — What's Here & What To Do Differently]]: list the 37 empty OpenCode skill stubs and the 40 pentest skills; write .forge/skills/HARVEST-STATUS.md recommending fill-vs-kill for each stub and domain-vs-archive for the pentest library.
- [ ] [Smith] Evaluate `hf skills add` for the eval/local quartet (huggingface-datasets, huggingface-local-models, hf-mem, huggingface-community-evals). Write wiki/research/ai-ml/hf-skills-eval.md: what each enables for cheap local validation. Do NOT install yet — recommend.

## Value groundwork (Quant)
- [ ] [Quant] Create wiki/value/ledger.md: the ranked hypothesis ledger (thesis, capital required, time-to-evidence, result, risk-adjusted score, status). Seed it with 3 candidate hypotheses from [[Bootstrap to Self-Funding — The Agent Life Arc]] Stage 1, ranked. No capital, ideas only.

## Trading-agents ongoing sweep (Scout/Critic) — see [[learning-path]] + [[legitimacy-ledger]]
> NOTE: WebSearch is broken this session — use WebFetch / GitHub API (curl) / old.reddit.com .json / web.archive.org directly. Judge code-not-personality; verdict every source; no capital.
- [ ] [Scout] FORK RECENCY: via GitHub API, enumerate forks of moondevonyt/moon-dev-ai-agents, sort by pushed_at, find any fork NEWER than our Dec-2025 snapshot. Also resolve the to-verify recency (pushed_at) for vectorbt, backtesting.py, Jesse, NirDiamant, Lean. Update [[legitimacy-ledger]] with real dates.
- [ ] [Scout] PHASE-0 STUDY: fetch + fully read The Alpha Illusion (arXiv:2605.16895); distill into wiki/research/trading/the-alpha-illusion.md — key claims + how it anchors our FOMO-filter. Advances [[learning-path]] Phase 0.
- [ ] [Scout] REDDIT MINE: fetch top practitioner threads from r/algotrading + r/quant on "AI trading agent"/"LLM backtest"/"freqtrade ml" (old.reddit.com or .json API). Capture the QUESTIONS people ask + vetted answers → wiki/research/trading/reddit-crowd-wisdom.md.
- [ ] [Scout] ARXIV TRACK: fetch recent q-fin + cs.MA papers on LLM trading agents (The Alpha Illusion follow-ups, TradingAgents lineage). Clip 2-3 with verdicts → wiki/research/trading/.
- [ ] [Scout] WAYBACK RECOVER: fetch historical algotradecamp.com + moondev.com from web.archive.org; recover any free curriculum/resources public before paywalling; verdict each → projects/trading-agents/wayback-recovery.md.
- [ ] [Critic] Adversarial pass over the "substantive" verdicts in [[legitimacy-ledger]] (top 5 resources): try to refute each before it's treated as trusted. Default to skepticism. Record outcomes in the ledger.

## Self-evaluation (recurring — the parent watching the child)
- [ ] [Steward] META-REVIEW: Read LOG.md since the last review. Answer: is the 20-min interval too fast/slow? Are sessions producing durable artifacts or burning tokens? What job types recur as failures? Then append 3-5 tuned jobs to this queue and adjust MAX_SESSIONS_PER_DAY in config.env if warranted. Write the review to journal/sessions/meta-review-$(date).md.

---
## Done jobs archive
*(runner checks jobs off in place above; move old checked jobs here periodically)*
