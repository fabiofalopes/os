---
tags: [research, trading, ai-agents, llm, reproducibility, friction, audit, source-clip]
date: 2026-07-21
sources:
  - "arXiv:2606.08285v1 [cs.AI, cs.CE, q-fin.CP], 2026-06-06 — Beyond Agent Architecture: Execution Assumptions and Reproducibility in LLM-Based Trading Systems"
authors: [Junyi Yao, Zihao Zheng]
status: full-text verified 2026-07-21 (ar5iv HTML + PDF, 7 pp) — verdict ★★★
related:
  - "[[fulltext-verify-2026-07-21]]"
  - "[[the-alpha-illusion]]"
  - "[[ktd-fin]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[learning-path]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Beyond Agent Architecture — Execution Realism Audit of LLM Trading Research

> **What it gives the harness:** the *field-wide* evidence for [[the-alpha-illusion]]'s confound #2 (friction). Alpha Illusion audited 5 flagship frameworks (35/40 friction cells unmodeled); this audits **30 trade-relevant primary studies** with a coded evidence matrix — same diagnosis at population scale. Its conclusion is also our harvest rule, stated academically: the bottleneck is not better agents, it's reporting standards for execution realism.

## What they did
Targeted topical review + reproducibility audit of execution realism in LLM-based trading research. Coded evidence matrix over 30 trade-relevant primary studies, scoring: point-in-time controls, split transparency, held-out evaluation, cost & turnover treatment, execution semantics, universe definition, artifact release.

## What they found
- **Architecture reporting is generally clearer than the evaluation assumptions** needed to judge whether a result is economically interpretable or reproducible. (I.e., papers tell you the agent design in detail and the thing that would let you believe the number in vague or not at all — exactly the "graph stops before the tariffs" pattern [[reddit-crowd-wisdom]] found practitioners complaining about.)
- A 10-equity worked example (explicitly a *methodological scaffold*, not evidence) shows explicit friction + timing choices **materially compress active-strategy results**.
- Conclusion: the next useful step for LLM trading research is **not only better agent design, but clearer reporting standards** for execution realism, reproducibility, and evaluation comparability.

## How it anchors us
1. **External validation of "discount the money claim, harvest the architecture."** The field's own auditors say the architecture is the well-reported part and the money numbers are the under-evidenced part. That is precisely the stance [[learning-path]] takes on Moon Dev and the flagship frameworks — now backed by a 30-study coded matrix rather than one paper's 5-framework audit.
2. **The evidence matrix is a ready-made clip checklist.** Its seven coded dimensions (point-in-time, splits, held-out, cost/turnover, execution semantics, universe, artifacts) slot directly under [[the-alpha-illusion]]'s P1/P2/P5 as the operational audit form. When we clip the next trading paper, score it on these seven before assigning a verdict.
3. **Composes, doesn't duplicate.** KTD-Fin ([[ktd-fin]]) attacks contamination (P1); this attacks friction/reporting (P5). Together with [[López de Prado — Backtest Overfitting Guards]] (multiple-testing/deflation) they form the three-pillar anti-fooling screen: *was the data clean, were the costs real, was the search accounted for?*

## Verdict
★★★ (full-text verified 2026-07-21 — see [[fulltext-verify-2026-07-21]]). The matrix is a real per-paper scorecard: 30 studies × Y/P/NR codes, and the column totals reconcile with the paper's own aggregate snapshot. **One correction, test-don't-wonder:** the operational matrix codes **five fields**, not seven separate dimensions — point-in-time and split transparency are merged ("Split/PiT") and universe definition is not scored per study. The "7-dimension checklist" survives as 5 scored gates + 2 prose questions. Headline numbers: cost/turnover is the field's weakest report (0/30 full, 14/30 partial); execution the best (26/30). Worked example is illustrative but now quantified: at 25 bps the structured-only ablation goes net-negative (0.8971) while buy-and-hold is untouched — friction alone erases the gross edge. Still a review (no new experimental evidence), two authors, no venue — but the asset it promised is real.

## Evidence ledger
- ✅ Fetched & read 2026-07-21: arXiv API metadata + full abstract for 2606.08285v1 (cs.AI, cs.CE, q-fin.CP, 2026-06-06).
- ✅ Full-text verified 2026-07-21 (ar5iv HTML + PDF, 7 pp): 30-study Y/P/NR matrix extracted in full — recoverable counts Split/PiT 25/30, held-out 21/30, costs 14/30 (0 full), execution 26/30, artifacts 18/30; totals reconcile with the paper's aggregate snapshot. Worked-example cost-sensitivity table extracted (0/10/25 bps × 4 strategies). Correction logged: 5 coded fields, not 7. Full evidence in [[fulltext-verify-2026-07-21]].
- Sweep context: arXiv q-fin+LLM recency sweep (30 entries, 2026-07-21).
