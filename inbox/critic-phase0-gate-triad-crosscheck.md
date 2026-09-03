---
tags: [critic, gate, trading, skepticism, phase-0, review]
date: 2026-07-21
role: Critic
status: reviewed — gate ratified & appended to [[learning-path]] Phase 0; findings below pending Curator triage
related:
  - "[[the-alpha-illusion]]"
  - "[[ktd-fin]]"
  - "[[reddit-crowd-wisdom]]"
  - "[[learning-path]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Critic Cross-Check — Skepticism Triad → ONE Phase 0→1 Gate

> **Mandate:** adversarially cross-check [[the-alpha-illusion]] P1–P6 vs [[ktd-fin]] vs [[reddit-crowd-wisdom]]; hunt contradictions, redundancy, unactionable items; distill ONE concrete, checkable Phase 0→1 gate; kill what doesn't survive. All three notes read in full this session.

## Findings (each with verdict — test, don't wonder)

**F1 — ktd-fin overclaims "P1 with a measurement attached."** The mask anonymizes *labels* (ticker/date) but "numeric features are computed on the original series — only labels change" (note's own line). A model that memorized price-curve *shapes* rather than identifiers is not audited by the ≤1.5% re-ID probe. **Verdict: real but minor gap** — the note discloses the mechanism, but the anchor sentence oversells: it is an *identifier-memory* audit, a partial P1 instrument, not a full temporal-integrity proof. Recommend scoping the sentence on promotion. (Mitigant: daily-length curves are far less memorizable than ticker names, so the directional conclusion holds.)

**F2 — ktd-fin may have its own P2 hole.** Design = "CSI300 constituents" over 2024-01→2026-04; the clip never says *point-in-time* constituents. If the present-day list was used backward, that is exactly the survivorship bias [[the-alpha-illusion]] P2 condemns. **Verdict: plausible, unverifiable from the clip** — queued for full-text check. Severity medium-low: all 18 baselines share the same universe, so the agent-vs-baseline domination survives; only the agent-vs-B&H framing is affected.

**F3 — Scope tension (not contradiction) on the "sanctioned" LLM use.** [[the-alpha-illusion]] §5 endorses LLM news-sentiment extraction (Lopez-Lira & Tang 2023) as the defensible edge; [[reddit-crowd-wisdom]] Q4 says alt-data alpha dies for retail on cost-to-exploit. **Verdict: consistent once P5 is applied universally** — the paper's is a *gross-correlation* claim, the crowd's a *net-of-cost* claim. Resolution: the upstream-extractor use earns no revenue language until it too passes P5 net-of-friction. This *strengthens* vault coherence: P5 gates everything, including the "safe" use.

**F4 — P3/P4/P6 are unactionable as an external-claim filter.** P3 (counterfactual flip-rates), P4 (ECE/reliability curves), P6 (disaggregation deltas) can only be *run* against your own agent; against someone else's paper you can only check *disclosure*. The §4 tiering table's "P1+P3 (light)" never defines "light." **Verdict: confirmed — KILLED from the Phase 0 gate** (disclosure-auditable subset only: P1/P2/P5 + crowd #1/#2/#3). P3/P4/P6 survive as Phase-4 capstone implementation checks, where [[learning-path]] already houses them ("no LLM verbal confidence in the sizing path").

**F5 — Redundancy is triangulation, not waste.** P5 ≡ crowd heuristic #3 ("net of what?"); the P1-layer ≡ crowd #1/#2 (IS/OOS, where the curve ends) ≡ [[López de Prado — Backtest Overfitting Guards]] instinct. Three independent evidence paths (position paper, benchmark, trench practitioners) to one filter. **Verdict: keep both sources; the gate cites the collapsed form.** The triad's convergence *is* the point — no kill.

**F6 — No numeric contradiction between the two papers.** Alpha Illusion: both flagship agents lose to B&H *net* (1-yr/5-ticker). ktd-fin: 5/10 beat B&H *raw* under blinding, yet selection alpha negative in 9/10. Consistent and mutually reinforcing: raw outperformance in a +37% bull window = beta, not skill. The gate's discount-to-zero rule must catch exactly this move.

**Phase 0 checklist survival audit:** all five existing items survive (3 reads evidenced by existing ★★★/verified notes; "watch a backtest lie" + artifact survive as the hands-on core). Nothing killed there — but the checklist had **no exit test**, which is the gap this gate fills. One sharpening noted for the artifact item: ktd-fin's baseline-ladder lesson says fooling *yourself* isn't the bar — the eventual artifact should also compare the overfit toy against a cheap classical baseline, not just its own OOS self (recommendation only; bounded scope, not rewritten here).

## THE gate (ratified, appended to [[learning-path]] Phase 0)

**Phase 0→1 GATE — the FOMO-filter exam.** Take ONE trading-agent claim never previously evaluated (paper/repo/video/post). In ≤1 page: (a) classify claim strength — extractor / backtest / deployable / autonomous ([[the-alpha-illusion]] §4 table); (b) audit the disclosure-checkable tests against the source's *own text* — **P1** (cutoff + ≥1 post-cutoff window disclosed?), **P2** (survivorship/delisting handled?), **P5** (fees+spread+token+latency charged? = crowd #3) — plus the crowd's window questions (IS or OOS? where does the curve end?); (c) verdict. **Pass =** the claim is classified to the strongest tier its disclosures actually support, **every P1/P2/P5 failure discounts its money claim to zero in writing**, and a Critic independently re-runs the classification and concurs. P3/P4/P6 killed here (own-agent only; they live in Phase 4). No Phase 1 before pass.

*Why this one:* it is the only candidate that is (i) a single pass/fail test on an unseen input — genuinely falsifiable; (ii) built solely from disclosure-auditable checks (F4); (iii) collapse of all three sources into one motion (F5); (iv) immune to the bull-market-beta move (F6).
