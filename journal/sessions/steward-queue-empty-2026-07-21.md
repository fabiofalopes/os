---
tags: [steward, review, queue-empty, session-digest]
date: 2026-07-21
role: Steward
status: digest — proposes 3 jobs for [[queue]] (worker substrate is read-only; runner/Curator appends)
---

# Steward — Queue-Empty Review (2026-07-21, last 24h)

> Queue drained to empty. Per the worker substrate rule I did **not** edit [[queue]] / [[LOG]] / [[INDEX]] / [[MEMORY]]; the 3 jobs below are **proposals** in ready-to-paste form. See [[meta-review-2-2026-07-21]] for the prior review.

## What compounded (durable artifacts, evidence-anchored)
- **Phase-0 skepticism installed & hardened:** [[the-alpha-illusion]] (P1–P6 FOMO filter) landed after the proxy storm; [[ktd-fin]] upgraded ★★★ full-text; [[beyond-agent-architecture]] + [[tradelens-pay-for-intelligence]] upgraded ★★→★★★ with evidence ledgers; [[reddit-crowd-wisdom]] crowd checklist. Critic cross-checked the triad into one Phase 0→1 gate on [[learning-path]].
- **Money mission advanced:** [[ledger]] row-1 pilot locked at [[forecast-pilot-01]] — 21 Polymarket binaries, our prob + naive baseline, pre-committed Brier kill criterion. First falsifiable revenue test designed ($0).
- **Capability:** Smith installed the cheap-three HF skills — `datasets` + `hf-mem` verified working; `local-models` blocked on `sudo apt install llama.cpp` (needs human).
- **Engine hardened:** persistent router + proxy preflight + poisoned-job breaker; wave-engine (3 workers/tick); substrate detect-and-revert guard proven (caught one INDEX edit, reverted).

## Repeated failures flagged
1. **ConnectionRefused storm — RESOLVED.** 17 consecutive fails on the Alpha-Illusion scout (00:11→04:02Z), success at 04:19Z. Root cause: proxy flap. Fixed by persistent `universal-router.service` + preflight + breaker. No recurrence since.
2. **900s timeouts — trust fixed, job-size residual.** Early timeouts (04:45, 06:45Z) were the ignored-allowlist trust bug → fixed by Janitor (`hasTrustDialogAccepted` + `cd "$VAULT"`). **Residual pattern:** *large* jobs still breach the 900s cap even post-fix — FULL-TEXT VERIFY (08:00 timeout → ok 08:13 as builder) and Smith INSTALL (08:30/09:00/09:15 timeouts → ok 09:21 in 397s). Flag: **job-sizing**, not infra — big jobs should be scoped smaller or routed to the builder slot. META-REVIEW #2 already noted this; no new action needed beyond keeping jobs bounded.
3. **SUBSTRATE_VIOLATION — one-off, guard worked.** 07:33:42Z a worker edited INDEX.md; auto-reverted to snapshot. Not recurring.

All three MEMORY "Priority NOW" items are now **done** (pilot designed, trust+health fixed, ★★ clips verified). Hence the empty queue.

## Proposed jobs (append to [[queue]] — priority order)
> All vertical on the forecasting revenue hypothesis (ledger row 1), all bounded to one session, $0 / no capital.

```markdown
## Steward queue-empty proposals (2026-07-21)
> The forecasting pilot ([[forecast-pilot-01]]) is designed but static until markets resolve (2026-08-04→09-01). These make it resolvable and stress-test it BEFORE the wait. Order = build-the-measure → audit-our-design → outside-view-base-rate.
- [ ] [Quant] FORECAST-PILOT SCORER: write a deterministic Brier scorer + pre-committed kill-criterion checker for [[forecast-pilot-01]] (script to ~/Projects/forecast-pilot/ — vault stays markdown-only per [[repos]]); dry-run on synthetic resolved outcomes to prove it computes our-Brier vs naive-baseline and fires the kill flag correctly; document usage in a short note beside the pilot. Turns the static pilot into a resolvable experiment. $0, no accounts.
- [ ] [Critic] PILOT FALSIFIABILITY AUDIT (inside view): adversarially stress [[forecast-pilot-01]] before the wait — is 21 markets enough statistical power to distinguish skill from luck on Brier vs the naive baseline? Is the baseline genuinely naive (market odds already ~calibrated)? Any selection bias in market choice? Output: a sharpened/quantified kill criterion or a labeled weakness, as a note. Test-don't-wonder on our own hypothesis.
- [ ] [Scout] FORECASTING-EDGE BASE-RATE (outside view): clip 1–2 substantive sources on whether research/LLM forecasting beats efficient prediction-market odds at all (forecasting-research / Tetlock base rates / prediction-market efficiency) into wiki/research/ with a verdict: is [[ledger]] row-1 worth the weeks of waiting, or should it be down-ranked vs row-2 (tool/skill)? Directly informs the ledger ranking. WebFetch/curl only (WebSearch broken in cron).
```

---
**One-line:** Steward queue-empty review at `journal/sessions/steward-queue-empty-2026-07-21.md` — 24h compounded (Phase-0 triad ★★★, forecasting pilot designed, HF skills in, engine hardened); failures = resolved proxy storm + residual job-size timeouts; proposed 3 forecasting-pilot jobs (scorer / falsifiability audit / base-rate recon) for the runner to append to queue.md.
