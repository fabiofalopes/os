---
tags: [research, finance, quant, overfitting, backtesting, source-clip]
date: 2026-07-20
sources:
  - "SSRN:2326253 — The Probability of Backtest Overfitting (Bailey, Borwein, López de Prado, Zhu)"
  - "SSRN:2460551 — The Deflated Sharpe Ratio (Bailey, López de Prado, JPM 2014)"
  - "Pseudo-Mathematics and Financial Charlatanism (Notices of the AMS, 2014)"
  - "Online tools for demonstration of backtest overfitting (2015)"
  - "Advances in Financial Machine Learning (Wiley, 2018) — book, NOT fetched"
authors: [David H. Bailey, Jonathan M. Borwein, Marcos López de Prado, Qiji Jim Zhu]
status: clipped — 4 papers fetched & verified 2026-07-20; AFML book unverified
related:
  - "[[Sources — Curated Seed Library]]"
  - "[[Kelly Criterion — Position Sizing]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# López de Prado — Backtest Overfitting Guards

> **What it gives the harness:** the anti-fooling-yourself foundation for the money mission. A backtest that doesn't control for how many configurations were tried is *worthless regardless of how excellent the reported performance is* (DSR paper, verbatim). These are the guards that keep a paper-traded edge from being a statistical fluke.

## The core problem (proven, not vibes)
- Modern compute makes it trivial to try millions of strategy configurations on one dataset and pick the best in-sample (IS) performer. The IS "optimum" is the maximum of N noisy draws — it targets the *noise* of the training set.
- **Expected maximum SR under the null** (DSR paper, App. A.1; verified Python snippet in paper): even with true SR = 0, after N independent trials
  `E[max{SR}] ≈ σ_SR · ((1−γ)·Z⁻¹(1−1/N) + γ·Z⁻¹(1−1/(N·e)))`, γ ≈ 0.5772 (Euler–Mascheroni). Grows with N — good backtests are *expected* by pure chance.
- **Memory effects make it worse than useless:** financial series have memory, so the extreme random pattern the overfit rule profited from IS tends to *undo* OOS → overfitting leads to **loss maximization**, not just mean reversion (Pseudo-Mathematics paper: formal proof).

## The guards
1. **Report N (trials attempted).** "The most important piece of information missing from virtually all backtests… is the number of trials attempted." No N → no assessment possible. *(DSR)*
2. **Deflated Sharpe Ratio (DSR)** = PSR(SR*): the Probabilistic Sharpe Ratio with the rejection threshold set to the expected max SR above. Deflates for **five** things beyond mean/variance: skewness γ̂₃, kurtosis γ̂₄, track-record length T, variance of the SRs tried, and number of trials N. Worked example in paper: a good-looking strategy after N=88 trials → DSR = 0.9007 → **rejected** at 95%; the same discovery after N=46 trials → DSR = 0.9505 → would pass. *(DSR)*
3. **Probability of Backtest Overfitting (PBO) via CSCV.** PBO = probability that the IS-optimal configuration **ranks below the median OOS** across configurations. CSCV algorithm: (a) build T×N matrix M of P&L series from all N trials; (b) partition rows into an even number S of blocks; (c) form all C(S, S/2) IS/OOS splits (S=16 → 12,780 combos); (d) for each split pick the IS-best, measure its OOS rank; PBO = fraction where it lands below median. Model-free, nonparametric, needs only the P&L series. **PBO > 0.5 = the selection process is actively detrimental.** *(PBO paper, Def. 2.2 + Alg. 2.3)*
4. **Holdout is NOT a guard.** Five documented failures: researcher has seen the "holdout" period; OOS too short for small samples (>1,000 obs / ~20 yrs weekly minimum cited); consumes the most representative data; and — decisive — "as long as the researcher tries more than one strategy configuration, overfitting is always present"; holdout ignores trial count. *(PBO paper §1.x; DSR agrees)*
5. **Minimum Track Record / Backtest Length (MinTRL/MinBTL):** how long a record is needed before an estimated SR is statistically distinguishable from the multiple-testing threshold. Short records + many trials = guaranteed false positives. *(DSR keywords; MinTRL from Bailey & López de Prado 2012 PSR paper)*
6. **Optimal stopping rule (secretary problem / 1/e law):** cost every trial, because each one raises the false-positive rate. From the theoretically justifiable configurations, evaluate ~1/e (≈37%) without selecting, then take the first that beats everything seen so far. Investment theory — not compute power — should decide which experiments are worth running. *(DSR)*
7. **Online demos exist:** BODT (Backtest Overfitting Demonstration Tool) + TMST find "profitable" strategies with any desired SR on a *pure random walk*, which then flounder on a second random walk. *(Online tools paper; tool at datagrid.lbl.gov/backtest per DSR)*

## Book-level guards — *Advances in Financial ML* (Wiley 2018)
> **Evidence label: NOT fetched this session — from prior knowledge, verify before relying on any of it.**
- **Purged k-fold CV with embargo** — standard k-fold leaks through overlapping labels; purge training observations whose label window overlaps a test fold, embargo a buffer after it.
- **Meta-labeling** — a secondary model predicts whether the primary signal's bet wins; converts a precision problem into precision/recall and drives bet sizing.
- **Triple-barrier labeling** (profit-take/stop-loss/time) instead of fixed-horizon returns; **fractional differentiation** to get stationarity without destroying memory; **clustered feature importance** (MDI/MDA) against multicollinearity.

## Verdict
★★★ — foundational, and the papers are free and formal. Direct mapping to the Forge loop: our promotion gate (validation-score delta before inbox→wiki / skill promotion) is a text-space DSR; **we must log the number of configurations tried per hypothesis** or our own "Critic" is just holdout theater. Rule adopted: no strategy/hypothesis gets promoted on IS performance alone; record N, compute the multiple-testing-adjusted bar, paper before live. See [[Kelly Criterion — Position Sizing]] for what happens when an overfit edge estimate feeds position sizing (it amplifies ruin).

## Evidence ledger
- ✅ Fetched & read (PDF, 2026-07-20): `davidhbailey.com/dhbpapers/backtest-prob.pdf` (PBO/CSCV), `deflated-sharpe.pdf` (DSR, formula + numerical example + Python snippet), `backtest-pseudo.pdf` (Notices AMS, memory-effect claim), `overfit-tools.pdf` (BODT/TMST).
- ✅ arXiv IDs from memory (1509.08990, 1308.3670, 1404.0867) **checked and WRONG** — these papers are SSRN, not arXiv. Correct refs above.
- ⚠️ AFML book section: unverified this session (paywalled book).
- Sources: [SSRN 2326253](https://ssrn.com/abstract=2326253) · [SSRN 2460551](https://ssrn.com/abstract=2460551) · [Bailey papers index](https://www.davidhbailey.com/dhbpapers/)
