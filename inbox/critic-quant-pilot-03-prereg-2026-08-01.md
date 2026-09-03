---
tags: [critic, quant, ledger-row-5, preregistration, hardening, inbox]
date: 2026-08-01
status: HARDENED — adversarial pre-sign-off pass on [[quant-pilot-03]]; 8 amendments applied in place; frozen kill math (all verdict thresholds) byte-identical; attacks (a)–(e) all survived; sign-off is now meaningful
related:
  - "[[quant-pilot-03]]"
  - "[[quant-pilot-01-RESULT]]"
  - "[[quant-pilot-02-RESULT]]"
  - "[[critic-quant-pilot-02-KILL-second-confirmation-2026-08-01]]"
  - "[[ktd-fin]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# [Critic] ATTACK THE ROW-5 PRE-REGISTRATION — quant-pilot-03 hardened pre-sign-off

## VERDICT: **HARDENED, endorsable.** I tried to break the pre-registration on the five named surfaces plus everything else I could reach; the design survived, and I applied **8 amendments in place** to [[quant-pilot-03]] (recorded below). **Every verdict threshold is byte-identical** — KILL (`SR_X(EW)_ensemble ≤ 0` OR `PBO ≥ 0.5`), NO-EVIDENCE (`≤ +1.377` OR `DSR p ≥ 0.05` OR `PBO ∈ [0.3, 0.5)`), PROMOTE (`> +1.377` ∧ `DSR p < 0.05` ∧ `PBO < 0.3` ∧ `N ≥ 30` ∧ `SR_X(SPY) > 0` ∧ Critic). Two table-text changes are strictly *tightening*: the INCONCLUSIVE guard now names the integrity checks that actually exist (F8), and the NO-EVIDENCE redesign allowance now requires its own new pre-registration note (F6). [[ledger]] untouched (row added on human sign-off). $0, design-only.

Evidence root: `~/Projects/trading-agents/quant-research/` (read-only) + vault notes. Every claim below re-tested against primary artifacts, not trusted.

## Per-surface verdicts

**(a) One factor named + justified up front, unshoppable — SURVIVES.** 1-month reversal is frozen with formula, sign (long losers), grid (H∈{1,2,3}×Q∈{D,Q5}), and endpoint (m−1) all fixed before any computation. Justification chain verified against sources: `backtests/strategies.py:47` carries the quoted skip-month rationale **verbatim** ("Skipping the most recent month avoids the short-term reversal contamination documented by Jegadeesh & Titman"); `strategies/HYPOTHESES.md:16` lists H04 Short-Term Reversal; recursive grep of the repo finds **no** reversal backtest anywhere (the docstring is the only hit) and `backtests/RESULTS.md` is the 3-asset FRED set only — the prior-observation disclosure is honest. Decisive anti-shopping check: the vault note `Short-Term Reversal (1-Month).md` is `status: proposed`, `created: 2026-07-23` — it **predates** the rung-0 KILL (2026-07-26), so "design-named complement of rung-0" is theory succession, not result-shopping. The ktd-fin scoping is the honest move: the table ranks 18 *ML models on Alpha9 features*, not individual factors, and the note says so — it justifies the *family*, published precedence picks the factor. Residual shopping channels I tried: sign flip → forbidden (new pre-reg required); grid/horizon/quantile expansion → "no silent extra factors" + trials = 6 counts the grid; endpoint drift → frozen at m−1; tie-break → frozen table order. All closed.

**(b) Config family carries a pre-committed selection rule — SURVIVES.** Pilot-01's death is reproduced exactly from its RESULT table: the 18 family OOS `SR_X(EW)` values average **+1.363** (I summed them: 24.529/18 = 1.3627 ✓) while the train-best selection won only 265/12,870 CSCV splits (PBO 0.7723). Pilot-03's answer — the **equal-weight ensemble as verdict, train-best demoted to diagnostic** — removes the searched degree of freedom entirely. I attacked the ensemble itself: uniform weights chosen a priori carry no data information (F4 now forces them to be a literal `1/6` constant in code); DSR with trials = 6 deflates the ensemble *as if* the best of 6 were reported (strictly conservative vs the truthful trials = 1 for a fixed statistic); and the PBO ≥ 0.5 → KILL clause still binds even if the ensemble looks good — the disclosed tension resolves **conservatively**, never in our favor.

**(c) Rung-0 gate inherited intact, kill binding up front — SURVIVES.** `SR_X`(EW) = +1.377 net matches pilot-01's RESULT verbatim (selected F9H3Q5, line 40); the ☠ KILL CRITERION section sits **above** the design it governs. The job's inherited gate "beat +1.377 AND DSR + PBO < 0.5" is satisfied verbatim and then some: PROMOTE demands PBO < **0.3** (stricter than < 0.5), and the bar itself is stricter than pilot-01's own frozen PROMOTE threshold (which was `SR_X ≥ 0.5`). Nothing moved.

**(d) ρ-ordering bug fixed in NEW pipeline only, frozen code untouched — SURVIVES.** Verified in `pilots/quant_pilot_02/run_pilot.py`: `guard_inconclusive` (lines **281–283**) includes `or (rho is None)` evaluated on the **CLI** value, while `probe.{tag}.json` is loaded only at lines **313–315** — exactly as the note claims. Direction confirmed one-way: `apply_verdict` (217–231) returns INCONCLUSIVE→KILL→NO EVIDENCE→PROMOTE as early returns, and the second Critic's ρ-sweep proved KILL at ρ = 0.0, 0.49, and 0.9 alike — the bug can only soften KILL→INCONCLUSIVE by omission, never the reverse. `pilots/quant_pilot_03/` does **not exist yet** (new code to build at execution), and `git status` on `pilots/` + `backtests/` is **clean** — frozen code unmodified. The note's architectural fix (all stats in-process, no CLI statistic flags, missing input → hard error) removes the entire failure class, not just this instance.

**(e) "Zero new fetch" honest, no look-ahead via the reused panel — SURVIVES after F1/F8.** `fetch_log.json` stamps the panel fetch at 2026-07-26T14:24Z — frozen **before** this pre-registration (2026-08-01); panel `df.shape == (150, 504)`, ends 2026-06, coverage 468/504 ok (468/503 + SPY) — all as claimed. Signal uses bars through m−1 → point-in-time; the final 2026-06 return earns weights set from 2026-05 bars (no last-bar peek). `auto_adjust` look-ahead is non-differential (strategy and EW/SPY benchmarks use the same adjusted series). Universe non-PIT bias is disclosed and, for the modal KILL/NO-EVIDENCE, conservative. **But** the integrity machinery had two real holes — fixed below: the frozen digest's preimage was unspecified (F1), and the INCONCLUSIVE guard referenced a panel hash that does not exist (F8).

## Amendments applied in place (8 — kill math untouched)

| # | Gap found (evidence) | Fix applied to [[quant-pilot-03]] |
|---|---|---|
| **F1** | **Executor trap (would-have-fired):** the frozen digest `c1f80ec6f12e83f8` is over `"\n".join(symbols)` of the ordered `symbol` column — I reproduced it exactly. The CSV **file bytes** hash to `844c8968127f6d2a`. An executor hashing the file would fire a spurious INCONCLUSIVE on byte-frozen data. | Exact preimage specified in the anti-fooling bullet **and** execution step 1, with the wrong hash named as a trap ("hashing the file bytes is WRONG"). |
| **F8** | **Unimplementable guard:** no panel hash exists anywhere in pilot-01's artifacts (`universe_meta.json` holds only the universe digest; `fetch_log.json` has none) — yet the INCONCLUSIVE row said "frozen panel **or universe hash** mismatch vs `universe_meta.json`". Panel integrity was actually frozen as shape + contiguity + end date (pilot-01 `audit_verify.py:57-62`). | Guard rewritten to name the checks that exist: universe digest (exact preimage) vs meta, AND panel `(150, 504)` + contiguous monthly index + end 2026-06. Same failure modes → INCONCLUSIVE; strictly more executable. Thresholds untouched. |
| **F2** | **Two factual errors vs [[ktd-fin]]'s own verified numbers:** best *agent* Sharpe is **1.15** (Doubao-Seed-2.0), not 1.13 (1.13 = Qwen, the top-*return* agent); and SFM MDD −7.41% vs best-agent MDD −15.62% is **~½**, not ~¼ (0.47). (The ~¼ error is inherited from the ktd-fin note itself — Curator flag below.) | Intro corrected: "best agent SR 1.15, at ~½ the drawdown — MDD −7.4% vs −15.6%". Conclusion unchanged (2.02 ≫ 1.15). |
| **F3** | **Off-by-one in the buffer claim:** H = 3 at train month 2015-01 uses cohorts 2014-12/11/10; `f(2014-10) = −(P[2014-09]/P[2014-08]−1)` → earliest bar needed is **2014-08**, not 2014-09. | Corrected (conclusion unchanged — panel starts 2014-01, 7 bars of buffer). |
| **F4** | The "implicit 7th config" disclosure argued uniform weights carry no data information — but nothing *forced* that in code. | Anti-fooling bullet (i) now requires the weights hardcoded as the literal constant `1/6`; any deviation = pipeline bug (A9b re-run), never a result. |
| **F5** | The first-128-month PBO trim (2015-01→2025-08, verified frozen in pilot-01 RESULT + pilot-02's `assert len == 128`) covers only the first **32 of 42** OOS months — undisclosed. | Disclosed: 2025-09→2026-06 enters the SR_X/DSR verdict but not the PBO matrix; inherited frozen for comparability; PBO is a family-stability statistic over the trimmed full period, not an OOS-only test. |
| **F6** | The NO-EVIDENCE redesign allowance accepted any "dated, linked artifact" — thin cover for re-shopping. | Tightened (strictly): redesign must be its **own** new pre-registration note with factor + sign + grid frozen before any computation, never an amendment to this note. |
| **F7** | Provenance. | Frontmatter: "Critic-hardened 2026-08-01 (8 amendments, frozen kill math byte-identical)" + related-link to this note — same pattern as pilot-01's 8-amendment Critic. |

## What I could NOT break (honest record)

- **Sign-shopping after a KILL:** long-winners (the flipped sign) is momentum — already KILLED on row 3 — and the note forbids the flip anyway (new pre-reg required).
- **Ensemble-as-luck:** a fixed uniform mean of a 6-config grid is not a searched statistic; DSR trials = 6 treats us as best-of-6 regardless; PBO ≥ 0.5 kills the family even if the ensemble shines.
- **The m−1 endpoint deviation vs pilot-01's m−2:** the +1.377 bar is the EW-universe return series, independent of any signal convention — comparability survives; the deviation is disclosed and correct for reversal (no skip month).
- **PBO metric dependence** (pilot-01's sharpe 0.77 vs cumret 0.34 split): the note freezes sharpe-primary + cumret-logged, and under neither metric is PROMOTE reachable without also clearing +1.377 ∧ DSR p < 0.05.
- **Motivation ≠ shopping:** the *decision to test reversal now* is motivated by rung-0's KILL — legitimate, because factor + sign + grid are pinned by 1990-vintage published precedence and the hypothesis note predates the KILL. Logged in the note's guard-#4 disclosure; verified, not just claimed.

Residuals no design amendment can close (already disclosed in the note): T = 42 is underpowered to *confirm* (modal NO-EVIDENCE/KILL); attribution is partial until Stage-2 Barra; universe non-PIT. These are the honest price of the zero-fetch rung, and they bias toward the conservative outcome.

## Endorsement

The pre-registration is **endorsed for human sign-off as amended**. It is, if anything, stricter than the gates that killed rows 3 and 4: a higher bar (+1.377 vs 0.5), a selection rule with nothing to select, and a verdict path architected against the exact softening bug pilot-02 exposed. The modal outcome remains NO-EVIDENCE/KILL — which is the point: the cheapest falsification the ledger has queued, buying either a live rung or a clean cheap negative.

## Curator flags

- INDEX entry for this note; link from [[quant-pilot-03]] (already added via F7) and beside the pilot-01/02 Critic notes.
- **[[ktd-fin]] carries the same ~¼-drawdown error** (line 35: "roughly a quarter"; its own verified numbers give 7.41/15.62 ≈ ½). Out of this job's scope — Z2 wiki fix owed.
- Ledger row 5 stays untouched; added on human sign-off only.

---

*Method: independent re-computation (universe digest from symbol join; family mean from pilot-01's 18-row table; panel shape/coverage from the CSVs), code reads at the exact cited lines (run_pilot.py 217–231/281–283/313–315, strategies.py:47, fetch_universe.py:42–43, audit_verify.py:50–62), repo-wide reversal grep, git-status freeze check, mtime/fetch_log dating, and cross-checks against [[critic-quant-pilot-02-KILL-second-confirmation-2026-08-01]]'s ρ-sweep. Read-only on all pipeline code; in-place amendments on the Z2 draft only; ledger and shared substrate untouched. $0, paper only, no capital.*
