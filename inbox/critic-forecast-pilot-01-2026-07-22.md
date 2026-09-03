---
tags: [critic, gate, quant, forecasting, precommitment, review, ledger-row-1]
date: 2026-07-22
role: Critic
status: reviewed — 5 gaming vectors closed via in-place amendments to [[forecast-pilot-01]]; zero questions killed (all 21 falsifiable); Curator: link from pilot note (done in amendment) + INDEX
related:
  - "[[forecast-pilot-01]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[ledger]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Critic — Adversarial Review of Forecast Pilot 01 (Pre-Registration Hardening)

> **Mandate:** attack [[forecast-pilot-01]] on three surfaces before the first market resolves — (1) are all 21 questions genuinely falsifiable on PUBLIC odds? (2) is the baseline choice (market vs 0.5) fair and consistent? (3) does the pre-committed KILL actually bind, or can a favorable score be gamed via question selection / cherry-picking? Kill or fix each failing item; amend the pilot note in place.
>
> **Blindness certification (test, don't wonder):** live gamma-api fetch 2026-07-22 → **21/21 reachable, all `active: true`, `closed: false` — 0/21 resolved.** This review was conducted with zero outcome information. Earliest endDate verified 2026-08-07 (#11); review is 16 days before first resolution.

## Evidence base

- Live fetch of all 21 market descriptions/criteria from `gamma-api.polymarket.com` (public, no auth; needed a browser User-Agent — bare urllib 403s, flag for scorer cron).
- Independent recomputation of the note's numeric claims: mean|F−M| = **0.0225** (note: 0.023 ✓); expected BS if calibrated: M = **0.1423** (note: 0.142 ✓), F = **0.144** (✓); BS_C = 0.25 exact (✓). The note's math is honest.
- Integrity hashes (sha256/16 of ordered value lists): Forge vector `4c8dfc20456a8918` · market vector `292c90f9c917b4df` · batch-tables block `a07a2b8b2a48b32b` (re-verified identical after in-place amendments).

## Findings (each with verdict)

**F1 — Falsifiability: all 21 PASS, zero kills.** Every live market description carries a crisp public resolution source: BLS releases (#8–11, #13), RBA statement (#12), Japan Cabinet Office GDP first preliminary (#14), IMF Portwatch 7-day-MA thresholds (#2 ≥60, #7 ≤10), arena.ai Text-Arena-Overall leaderboard at a named URL/check-time with tie-breakers (#15–17), explicit "named product, public access incl. open beta; closed beta doesn't count" definitions (#18, #19, #21), market-cap-at-close (#20), signed-written-instrument / announcement definitions (#1, #6) and defined "qualifying military action" / general-closure criteria (#3, #4, #5). **Verdict: no exclusions.** Residual (accepted) risk: UMA-oracle judgment on news markets (#1, #3, #5, #6) — mitigated by the void rule, not a falsifiability failure.

**F2 — Baselines are fair, and the test is structurally biased AGAINST Forge (the honest direction).** M = YES mid at capture (matches the API's `outcomePrices`; capture values cross-checked against the scorer note's drift figures). C = 0.5 floor. Two honest caveats, now in the note: (a) the coin-KILL branch (`BS_F ≥ 0.25`) is **effectively dead** — F is a 0.0225-perturbation of M with E[BS_F]≈0.144; the *operative* kill is `BS_F ≥ BS_M`; (b) under the null "M calibrated, F = M + noise," E[BS_F] = E[BS_M] + E[(F−M)²] > E[BS_M] **mechanically** (verified: 0.144 > 0.142) — the test can only be won if Forge's adjustments are systematically right, not lucky. Void → o=0.5 for all three is consistent (identical mapping per forecaster) and conservative (penalizes confidence). Stage-2 caveat carried forward: Brier mid-vs-mid ignores spread; a *tradeable* edge must beat M by more than half the spread — belongs in the 50–100-question pre-registration. **Verdict: fair; no baseline change; caveats appended.**

**F3 — The KILL was gameable five ways; all five now closed by amendment.**
- **G1 verdict-order bug.** Note said "applied in order" but listed the INCONCLUSIVE guard (N<15 / ≥2 voids) *last* — read literally, a meaningless N=3 Brier could fire KILL. The harness already evaluates the guard first (scorer flagged the note≠code mismatch). Pre-registration integrity requires note ≡ code. **FIX:** guard moved to row 1.
- **G2 score-timing game.** "on/after 2026-09-02" invited choosing a favorable score day. **FIX:** exactly one run, first scheduled opportunity on/after 2026-09-02, never re-run; markets still unresolved at that moment = voids (folded into the ≥2-void guard). Check: can voids manufacture a PROMOTE? One void (1/21 weight) cannot produce a 10% Brier win; ≥2 voids → INCONCLUSIVE (no verdict). Safe.
- **G3 self-judged redesign.** NO-EVIDENCE's "documented capability change" was graded by the agent itself. **FIX:** capability change must be a dated, linked vault artifact, and the redesign needs Critic + human (Z2) sign-off.
- **G4 zombie revival.** KILL said "killed as stated" while the handicap caveat hinted at a future redesign — a killed row could sneak back as a "redesign." **FIX:** KILL binds on row 1 as stated; revival = a **new** ledger row with new Critic review, explicitly not the NO-EVIDENCE allowance. (Strictly tighter than status quo.)
- **G5 question-selection cherry-picking — the big one.** Any pre-resolution removal motivated by expected score = gaming. **LOCK:** after this review, no question may be removed except for a documented falsifiability failure (criterion proven non-public/non-deterministic), never for score or drift; 21/21 verified falsifiable → zero exclusions. Drift snapshot below makes the no-exclusion decision auditable as drift-blind — note several markets moved *against* Forge's frozen positions and were kept anyway.

**F4 — N=21 overstates the evidence; effective N ≈ 12.** Clusters: Iran (#1,2,3,4,7) ≈ 2 underlying factors (diplomacy vs escalation); CPI (#8/#9 mutually-exclusive buckets; #10/#13 same print) ≈ 2; best-model (#15,16,17) = 1 event; GPT-6 (#18,21) nested = 1; plus ~6 near-independents (#5, #6, #11, #12, #14, #19-partially, #20). **Effective N ≈ 12** → a 10% Brier win is ~1σ-scale noise. PROMOTE's consequence ($0 bigger test) is cheap, so a false PROMOTE costs little — but the note now says PROMOTE-at-21 is noise-scale signal, and the 50–100 test must pre-commit to cluster-robust (effective-N) counting. On the KILL side: under the F=M+noise null, KILL is the *expected* outcome, so a noise-KILL is not unfair — the row stays aspiration and the new-row path remains open.

**F5 — Protocol factual error (confirmed).** The live gamma API has **no `isResolved` field** (my fetch confirms: `closed`/`active`/`outcomePrices` only), as the scorer harness found. **FIX:** protocol corrected — resolution = `closed: true` + `outcomePrices` exactly `["1","0"]` (YES) or `["0","1"]` (NO); any other closed state, or still-open at score time, = void. Factual correction, not a forecast change.

**F6 — Forecast-integrity lock.** Frozen vectors hash-locked (above). The scorer must verify the harness's embedded F/M values hash-match **before** scoring; all amendments this session are provably outside the frozen block (batch block hash identical before/after).

**F7 — Test-power honesty.** Given the logged information handicap (Forge forecasts *through* the market's information), this batch tests "Forge beats a real-money market from inside its information set" — close to a test of market efficiency. It can **falsify** the strong claim; it **cannot confirm** the deeper row-1 thesis (which needs an independent information source). Now stated in the note so a KILL is read honestly: it kills the row as stated, not forecasting as such; the info-access fix is a new hypothesis.

## Drift snapshot 07-21 capture → 07-22 (diagnostic; forecasts FROZEN)

Moves ≥0.02: #12 −0.025, #13 +0.04, #14 −0.08, #18 +0.085, #20 +0.045, #21 +0.0205. Of these, **#13, #14, #18, #20, #21 moved AGAINST Forge's frozen positions** (market away from F) — and all were retained. Liquidity ≥ $4.3k on every market now (note's thin ones grew: 2321905 $3.7k→$4.3k, 2850825 $3.5k→$6.4k). The zero-exclusion decision is therefore demonstrably not score-motivated.

## Verdict

**PILOT SURVIVES — hardened.** Falsifiability: 21/21 pass, zero kills. Baselines: fair, structurally adversarial to the thesis (correct). KILL: now genuinely binding — five gaming vectors closed by in-place amendments to [[forecast-pilot-01]] (guard-first ordering, single score run + unresolved=void, redesign sign-off, zombie-revival block, exclusion lock with drift-blind audit trail) plus hash-locked forecasts and a corrected protocol. Most-likely outcome remains KILL or NO-EVIDENCE (by construction — F = M + noise), and that is the point: row 1's fate is now a real test, not a ritual.

**Scorer-harness follow-ups (flag for the SCORE job / Curator):** (1) treat score-time-unresolved markets as voids counting toward the ≥2-void guard (~5 lines); (2) hash-verify embedded F/M vectors before scoring (~5 lines); (3) guard-first ordering already implemented. (4) Scorer cron must send a browser User-Agent on the gamma API (bare client 403s).
