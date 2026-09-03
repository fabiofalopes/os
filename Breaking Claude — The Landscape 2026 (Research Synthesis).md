---
created: 2026-08-26
type: research-synthesis
tags: [breaking-claude, upb, harness, anthropic, geopolitics, sovereignty]
links: "[[Claude Code Routes — upb CLI Decision & Runbook]], [[Claude Code Proxy Pattern — Master Reference]], [[DeepSeek V4 Claude Code Harness]], [[Agent Roles & Orchestrator — The Moat]]"
---

# Breaking Claude — The Landscape 2026 (Research Synthesis)

*Web research sweep, 2026-08-26. Four parallel tracks: reverse-engineering, alt-model community, Anthropic behavior/finances, harness-vs-model + geopolitics. Companion practical artifact: the [[Claude Code Routes — upb CLI Decision & Runbook|upb runbook]].*

---

## 0. The Thesis, Now With Names and Citations

**Agent = Model × Harness. The harness is the separable, controllable, ownable variable.** What UPB does in practice (launching the Claude Code harness over third-party endpoints) the field has now formalized in theory:

- Martin Fowler, [Harness Engineering for Coding Agent Users](https://martinfowler.com/articles/harness-engineering.html) — canonical definition: harness = everything except the model.
- arXiv 2603.25723 ([Natural-Language Agent Harnesses](https://arxiv.org/html/2603.25723v1)) and [Harness Engineering for Language Agents](https://www.preprints.org/manuscript/202603.1756) — the harness layer as first-class research object, 2026.
- Empirics: small scaffolded Qwen3 agents rival a single large LLM on GAIA ([arXiv 2601.11327](https://arxiv.org/html/2601.11327v1)); a 3B "cognitive core" reaches ~65% of frontier scores ([seangoedecke.com](https://www.seangoedecke.com/cognitive-core/)).
- Community measurement: same Anthropic models go ~50% → ~90% correctness under different harnesses ([r/ClaudeCode empirical test](https://www.reddit.com/r/ClaudeCode/comments/1syvsz7/the_harness_problem_why_anthropics_models_are/)).
- "The moat is the harness, not the model" is now mainstream analysis: [Aakash Gupta](https://aakashgupta.medium.com/2025-was-agents-2026-is-agent-harnesses-heres-why-that-changes-everything-073e9877655e), [AlphaSignal](https://alphasignalai.substack.com/p/claude-codes-real-moat-probably-isnt), [UncoverAlpha](https://www.uncoveralpha.com/p/the-harness-the-moat-for-ai-model). HN: *"Claude Code is a lock-in... decouple frontend and API and they are one benchmark away from losing half their users."*

Anthropic itself shipped two engineering papers (Nov 2025–Mar 2026) formalizing "harness" as the key IP. **UPB sits exactly on the fault line of this thesis.**

---

## 1. April 2026 — The Month Everything Surfaced

The month that shaped our trajectory, in order:

| Date | Event | Source |
|---|---|---|
| **Mar 4** | Claude Code default reasoning effort silently changed `high` → `medium` (cost/latency optimization). Intelligence dropped. Reverted Apr 7. | [Official postmortem](https://www.anthropic.com/engineering/april-23-postmortem) |
| **Mar 26** | Caching bug dropped prior reasoning after idle → "forgetful Claude"; also drained usage limits faster via cache misses. Fixed Apr 10. | same |
| **Mar 31** | **The Great Leak**: v2.1.88 npm package shipped a 59.8 MB source map → ~512,000 lines of readable TypeScript reconstructable. Mirrors (ghuntley, dnakov/anon-kode, leeyeel) DMCA'd within days. Revealed `undercover.ts` (strips Anthropic-internal refs in external repos) and internal multi-model routing. | [Zscaler](https://www.zscaler.com/blogs/security-research/anthropic-claude-code-leak), [InfoQ](https://www.infoq.com/news/2026/04/claude-code-source-leak/), [dev.to timeline](https://dev.to/varshithvhegde/the-great-claude-code-leak-of-2026-accident-incompetence-or-the-best-pr-stunt-in-ai-history-3igm) |
| **Apr 4** | **Third-party harness ban**: Pro/Max subscriptions no longer cover OpenClaw etc.; usage must go through API billing. <24h notice for the earlier Jan 9 OAuth block. | [HN](https://news.ycombinator.com/item?id=47633396), [TNW](https://thenextweb.com/news/anthropic-openclaw-claude-subscription-ban-cost) |
| **Apr 16** | Verbosity prompt change ("≤25 words between tool calls") → **measured 3% intelligence drop**. Reverted Apr 20. | postmortem |
| **Apr 23** | Official postmortem published; all three degradations traced to **harness-level changes, not the model**. Usage limits reset. | [postmortem](https://www.anthropic.com/engineering/april-23-postmortem), [Simon Willison](https://simonwillison.net/2026/Apr/24/recent-claude-code-quality-reports/), [VentureBeat](https://venturebeat.com/technology/mystery-solved-anthropic-reveals-changes-to-claudes-harnesses-and-operating-instructions-likely-caused-degradation) |

**Why it matters for us:** the postmortem is inadvertent proof of the thesis — a month of "Claude got worse" was entirely the *harness* degrading intelligence (effort defaults, caching, prompt instructions), zero model changes. Two of the three were intentional engineering decisions (cost optimizations) that backfired, not bugs ([jakubkontra analysis](https://jakubkontra.com/en/blog/anthropic-admitted-month-of-claude-code-degradation)).

---

## 2. The Countermeasure Ladder (Documented)

Anthropic's escalation against non-official use, each step documented:

1. **Hidden telemetry (v2.1.91, Apr 2026)** — obfuscated proxy-detection code disguised in date-formatting functions; proxy fingerprints exfiltrated via **invisible Unicode alterations in the system prompt**; specific flagging of **China-linked users** via obfuscated domains. v2.1.196 disabled remote control when proxying detected. Rolled back June 2026 after viral r/ClaudeAI exposé. ([SecurityOnline](https://securityonline.info/claude-code-telemetry-rollback/), [TechStartups](https://techstartups.com/2026/06/30/anthropics-claude-code-accused-of-hiding-proxy-fingerprints-inside-system-prompts-to-identify-china-linked-users/), [Zscaler](https://www.zscaler.com/blogs/security-research/anthropic-claude-code-leak)) — *some specifics from community analysis; treat with calibrated confidence, but the rollback confirms substance.*
2. **Subscription-auth block (Jan 9, 2026)** — server-side block of third-party tools using Claude subscription OAuth tokens (<24h notice). Then **Apr 4** formal policy: subscriptions ≠ API.
3. **Legal action against OpenCode** — for impersonating the official client (swapping templates, injecting headers, stripping temperature). ([HN](https://news.ycombinator.com/item?id=47444748))
4. **Protocol friction** — Anthropic-specific beta headers and tool-result formats break generic proxies (LiteLLM broken for this, [issue #22963](https://github.com/BerriAI/litellm/issues/22963)). Possibly unintentional; effectively a moat.
5. **Ban scale**: ~690k (H1'25) → ~1.45M (H2'25) → **~11.4M accounts (H1'26)** per Anthropic's own [Transparency Hub](https://www.anthropic.com/transparency/system-trust-reporting). ~67% attributed to cyberattack prep ([Cointelegraph](https://www.tradingview.com/news/cointelegraph:28e19cbcf094b:0-about-67-of-banned-accounts-used-ai-to-prep-for-cyberattacks/)); appeal reversal rate ~3%. March 2026 ban wave hit Chinese developers specifically ([ban-prevention guides](https://help.apiyi.com/en/claude-account-ban-prevention-china-2026-guide-en.html)).
6. **Peak-hour throttling** (5–11 AM PT) for Pro/Max, enterprise exempt; users hitting limits at 6% of stated quota. Walked back May 6, 2026 (limits doubled, SpaceX compute deal announced). ([BBC](https://www.bbc.com/news/articles/ce8l2q5yq51o))

**The pattern: detect → degrade → ban → sue.** The architecture *permits* targeted sabotage; selective deployment is documented (telemetry, throttling, differential enterprise treatment) even where the strongest claims stay unverified.

---

## 3. The People Doing What We Do

A whole ecosystem runs the Claude Code harness over non-Anthropic models:

- **Routers/gateways**: [claude-code-router](https://github.com/musistudio/claude-code-router) (musistudio), [NVIDIA Switchyard](https://github.com/NVIDIA-NeMo/Switchyard) (Anthropic→OpenAI translation, Rust), [Bifrost](https://github.com/maximhq/bifrost) (Go, ~11µs overhead), [Antomix](https://github.com/unclecode/antomix), LiteLLM (currently broken, see above). y-router archived — **OpenRouter now offers native `ANTHROPIC_BASE_URL` integration** ([docs](https://openrouter.ai/docs/cookbook/coding-agents/claude-code-integration)).
- **Models inside the harness**: GLM-5.x ("works best specifically in Claude Code"), DeepSeek, Qwen 3.6/3.8 (27B local, Q8), Kimi K2.x/K3, Nemotron 120B (free on NVIDIA NIM), Grok, GPT-5.6, Gemini.
- **Independent harnesses**: OpenCode (~172k stars; Anthropic took legal action over subscription auth), Aider (4.2× more token-efficient, ~71% vs 78% first-pass success), Goose (Block), Crush (Charm), Pi (minimalist; users report beating Claude Code with the same model via better context management — [mariozechner](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/)).
- **What breaks**: complex agentic loops through generic proxies (header/format mismatch); models receiving Claude-tuned system prompts they weren't trained on. **What works**: direct BASE_URL redirect to Anthropic-compatible endpoints (exactly UPB's lane), hybrid workflows (expensive model plans, cheap model executes).
- Motivations mirror ours: cost (GLM 5–8× cheaper), rate-limit exhaustion, vendor-lock-in aversion, local/air-gapped sovereignty.

**Our lane is the defensible one:** UPB routes a *paid Z.ai coding-plan key* through an Anthropic-native endpoint — no subscription impersonation, no OAuth games, nothing for the countermeasure ladder to grip. The one architecture they have the least leverage over.

---

## 4. Harness Internals (What the Leak + RE Established)

From the source map leak and prior reverse-engineering ([Yuyz0112/claude-code-reverse](https://github.com/Yuyz0112/claude-code-reverse), [cablate/claude-code-research](https://github.com/cablate/claude-code-research), [Kir Shatrov](https://kirshatrov.com/posts/claude-code-internals), [VILA-Lab 40-page paper](https://arxiv.org/abs/2604.14228)):

- **Thin loop, fat prompt**: quota check → topic detection → agent loop → auto-compaction. The model has no memory; the harness manufactures continuity. The "personality"/Tamagotchi effect is *scaffolded* — interstitial `system-reminder` injections, tool schemas, response-style instructions — not native to the model.
- **Full tool schemas + system prompts** public in [x1xhlol/system-prompts-and-models-of-ai-tools](https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools) (123k stars).
- **Internal multi-model routing confirmed** in leaked source (e.g., fast classifier + strong coder). Mechanism exists; no proof Anthropic serves small models for Opus-tier requests (that remains speculation — though OpenAI *was* caught routing paid queries to GPT-4o-mini, [Fortune](https://fortune.com/2025/08/12/openai-gpt-5-model-router-backlash-ai-future/)).
- **30 hook events**, subagent architecture, IDE integration — all mapped. The harness is fully legible now; "breaking Claude" as an epistemic program is essentially complete. What remains is the *owning*.

**Codex sidebar**: the *desktop app* died (merged into ChatGPT, Jul 9 2026) but the **Codex CLI is still open-source and alive** (v0.129+, third-party models supported). A "breaking Codex" track is viable — and easier, since the harness is legitimately on GitHub. Community forks (Open Codex) and 50-line provider proxies already exist.

---

## 5. Money and Geopolitics

**Anthropic's books (self-reported/leaked, private company):**
- 2025: ~$4.5B revenue vs ~$7B compute. Cumulative losses ~$15B. Total raised ~$65B.
- 2026: Q1 $4.8B → Q2 projected $10.9B with $559M "operating profit"; ARR narrative $14B→$65B in five months; $380B Series G (Apr) → approaching $1T valuation talk; $1.25B/month SpaceX compute deal.
- [Ed Zitron's critique](https://www.wheresyoured.at/anthropics-profitability-swindle/): the profitable quarter coincides with a SpaceX ramp-up discount suppressing compute costs; CFO's sworn ">$5B to date" (Mar 9, 2026) is hard to reconcile with $14–19B ARR claims; no IPO despite claimed profitability. Unproven but substantive.
- The structural read: **a company burning ~33% of revenue, dependent on AWS (26–30% of AWS revenue by some estimates), must lock the harness** — the model layer is commoditizing underneath it. The countermeasure ladder in §2 is what that looks like from the user side.

**China / open-weights:**
- Chinese open-weight models: ~1% → **~30% of global model usage** in ~18 months. Bloomberg/CNBC (Aug 2026): US lead on usage/cost metrics "essentially vanished."
- GLM-5.2 matched Opus on 45 Terminal-Bench tasks at 5.7× lower cost ([r/ClaudeAI analysis](https://www.reddit.com/r/ClaudeAI/comments/1uen56t/glm52_matched_claude_opus_on_45_terminalbench/)); DeepSeek V4-Pro beats Claude on Terminal-Bench at 7× lower cost. On absolute SWE-bench Verified, Claude Opus 5 still leads ~97% vs GLM-5.2 ~63%.
- Anthropic accused DeepSeek/Moonshot/MiniMax of industrial-scale distillation (~24k fraudulent accounts, Feb 2026) — the "sauce war" is literal. Chinese labs train on Huawei Ascend under sanctions; HBS documents the sanctions-driven "innovation surge."
- **Framing discipline**: open-weights publishing is also strategic (ecosystem capture, sanctions workaround), not pure virtue. The sovereignty argument for open weights holds on architecture alone — it doesn't need the moral framing. US keeps the absolute frontier; China is taking the price-performance and openness frontier; the harness thesis says the latter is where users actually live.

---

## 6. Synthesis — Where UPB Sits

1. **UPB is the practical half of a thesis the field has now validated.** Running GLM-5.2 through the Claude Code harness isn't a hack around the product — it *is* the product thesis of 2026, stated by Fowler, arXiv, and (inadvertently) by Anthropic's own April postmortem.
2. **"Breaking Claude" as epistemics is nearly complete.** The source leaked, the community mapped all 7 components, and the countermeasure ladder is documented. The remaining frontier is ownership: stable sovereign routes (done — upb + zai coding plan), own-instance loops (done — Path B, ~$0.65/run), and eventually a first-class sovereign harness (deferred north star: `spec-unified-agent-harness-cli`).
3. **The escalation is structural, not personal.** Bans, telemetry, throttling, lawsuits — all of it flows from a simple position: model commoditizing + harness = moat + burn-rate pressure ⇒ the harness must be locked. Expect more, not less. Design for it: legitimate keys only (already doctrine), no OAuth impersonation (already true), Anthropic-native endpoints (already UPB's approach).
4. **The April feeling was correct.** The harness degraded for everyone, secretly, for six weeks — two of three causes were intentional cost optimizations. What you experienced as "Claude Code turning on users" was that, plus the telemetry and ban waves landing in the same window. Not paranoia; documented.
5. **What's next if we want it**: the Codex CLI track (open-source, alive, third-party-friendly) as a second harness to lounge; OpenCode Zen / Pi as reference architectures for the sovereign harness; and keeping the GLM/Qwen/DeepSeek route matrix current as the price-performance frontier moves.

---

*Research sweep artifacts: four parallel web-research tracks, 2026-08-26. Claims graded inline: documented / community-reported / speculation.*
