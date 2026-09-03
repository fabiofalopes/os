---
tags: [value, quant, forecasting, pilot, precommitment, ledger-row-1]
date: 2026-07-21
status: draft (Z2) — LOCKED pre-commitment; forecasts frozen at capture (hash-locked), never edited after; methodology hardened pre-resolution by Critic 2026-07-22; resolution-range prose corrected 2026-07-27 at 0/21 resolved (factual, evidence-linked — forecasts/hashes/protocol untouched)
related:
  - "[[critic-forecast-pilot-01-2026-07-22]]"
  - "[[forecast-scorer-harness-smoke-2026-07-22]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[the-alpha-illusion]]"
  - "[[Bootstrap to Self-Funding — The Agent Life Arc]]"
---

# Forecast Pilot 01 — First Falsification Test of Ledger Row 1

> Tests [[ledger]] row 1 ("we are ahead of the curve on a class of questions; calibration is directly measurable"). 21 binary prediction-market questions, 3 domains, resolving **2026-08-07 → 2026-08-31** (live API-verified 2026-07-27; 08-04 → 09-01 was the *selection window*, not the batch's resolution range — see Deviations). Forge probabilities **locked at capture (2026-07-21 ~07:50 UTC)** and scored against the real-money market baseline by Brier score. $0, public odds, no accounts, no capital.

## ☠ KILL CRITERION (pre-committed — do not move after seeing outcomes)

**Metric:** Brier score `BS = (1/N) Σ (pᵢ − oᵢ)²`, oᵢ ∈ {0,1}, lower is better, over all resolved questions.
**Forecasters:** `F` = Forge (table below, frozen) · `M` = market baseline (Polymarket YES price at capture) · `C` = constant 0.5.

| Verdict | Condition (applied in order — **guard first**, per [[critic-forecast-pilot-01-2026-07-22]]; note ≡ scorer harness) | Consequence for [[ledger]] row 1 |
|---|---|---|
| **INCONCLUSIVE** (precondition guard) | `N_resolved < 15`, **OR** ≥2 voids (void = closed with `outcomePrices` not exactly `["1","0"]`/`["0","1"]`, **including still-unresolved at the single score run**) | Redesign the batch; no verdict. (Infra failure, not thesis failure.) Evaluated FIRST: BS is meaningless below N=15, and this guard can only ever mask a KILL/NO-EVIDENCE — never manufacture a PROMOTE (which requires N≥15 itself). |
| **KILL** | `BS_F ≥ 0.25` (worse than a coin — effectively a dead backstop branch, see Critic F2) **OR** `BS_F ≥ BS_M` (fails to beat the real-money market — the **operative** kill) | Row 1 → `killed` as stated (with current information access). Revival requires a **new** ledger row + new Critic review — NOT the NO-EVIDENCE redesign allowance. |
| **NO EVIDENCE** | `0.90 × BS_M < BS_F < BS_M` (tie; noise-dominated at effective N≈12, see Critic F4) | Row 1 stays `idea`. **One** redesign allowed, only with a *dated, linked capability-change artifact* (e.g., a real-time news feed) **AND** Critic + human (Z2) sign-off — never a re-run on the same information. |
| **PROMOTE** | `BS_F ≤ 0.90 × BS_M` **AND** `BS_F < 0.25` **AND** `N_resolved ≥ 15` | Row 1 → `paper`: full 50–100-question test with **cluster-robust (effective-N) counting pre-committed**, domain-focused per the diagnostics below. Noise-scale signal at N=21 — "worth a bigger test," not edge proven. |

**Anti-fooling commitments** (per [[López de Prado — Backtest Overfitting Guards]] and [[Operating Principle — Test Don't Wonder]]):
- The kill/promote decision is on the **full batch only**. Per-domain splits are diagnostics, never a basis for promotion — no post-hoc "we're good at geopolitics" cherry-picking.
- Forecasts in this note are frozen. Corrections go in the RESULT note, never here.
- A PROMOTE at N=21 is "signal worth a bigger test," **not** "edge proven" — N=21 (effective N≈12 under the acknowledged clusters, Critic F4) cannot establish significance; the 50–100-question test is where that lives.
- **Exclusion lock (Critic 2026-07-22):** after the Critic review verified all 21 criteria falsifiable on public sources (live API), **no question may be removed** from the batch except for a documented falsifiability failure (criterion proven non-public or non-deterministic) — never for score or price-drift reasons. Zero exclusions as of that review; the Critic note records the 07-22 drift snapshot so the no-exclusion decision is auditable as drift-blind (several markets moved *against* Forge's frozen positions and were kept).
- **Single score run (Critic 2026-07-22):** exactly one scoring run, on the first scheduled opportunity on/after 2026-09-02, never re-run; markets unresolved at that moment are voids per the guard above.
- **Integrity lock (Critic 2026-07-22):** frozen vectors hash-locked — Forge `4c8dfc20456a8918`, market `292c90f9c917b4df` (sha256/16 of the ordered value lists, #1→#21). The scorer verifies the harness's embedded values hash-match before scoring; on mismatch, refuse to score and flag.

## What is being tested — and the honest caveat

Thesis under test: *Forge's probability judgments, formed from resolution criteria + base rates + market-aggregated information, beat the real-money market on calibration.*

**Known handicap (logged, not hidden):** this environment has no working real-time news access (WebSearch returned garbage traces on test; Metaculus is auth-gated — see Deviations). Forge therefore forecasts *through* the market's information, making only small structural adjustments (mean |F−M| = 0.023). Beating an efficient real-money market from inside its own information set is structurally hard — **a KILL here is the most likely honest outcome, and is the point**: it converts row 1 from aspiration to evidence. A future redesign must first fix information access.

**Test-power honesty (Critic 2026-07-22):** by construction this batch **falsifies** the strong claim — "Forge beats a real-money market from inside its information set" — but **cannot confirm** the deeper row-1 thesis, which requires an *independent* information source. A KILL therefore kills the row **as stated**, not forecasting as such; the info-access fix is a new hypothesis (new row, new Critic review), per the amended KILL consequence above.

## The batch (captured 2026-07-21 ~07:50 UTC — FROZEN)

Baseline 2 (constant 0.5) applies to every row: `BS_C = 0.25` exactly. Reference: if `M` is calibrated, its expected BS ≈ mean(p(1−p)) = **0.142**; for `F`, **0.144**. F's higher reference is the mechanical cost of perturbing a calibrated forecast (bias–variance: E[BS_F] = E[BS_M] + E[(F−M)²] under the null) — i.e., the test is **structurally biased against Forge**, which is the honest direction; the coin branch (`BS_F ≥ 0.25`) is effectively a dead backstop, and `BS_F ≥ BS_M` is the operative kill (Critic F2). Stage-2 caveat: Brier mid-vs-mid ignores spread — a *tradeable* edge must beat M by more than half the spread; carry this into the 50–100-question pre-registration.

### Domain A — Geopolitics (7)

| # | Question | Resolves | ID | Mkt p | Forge p | Why (one line) |
|---|---|---|---|---|---|---|
| 1 | US–Iran final nuclear deal by Aug 31? | 08-31 | 2633430 | 0.075 | **0.06** | "Final" deal in ~6 wks amid active operations; JCPOA-class deals take months — market slightly over-rates speed. |
| 2 | Strait of Hormuz traffic returns to normal by Aug 31? | 08-31 | 2774056 | 0.14 | **0.13** | Criterion = IMF Portwatch 7-day MA transit calls ≥60 on *any* day; low trigger bar but needs blockade de-escalation. |
| 3 | US × Iran effective ceasefire by Aug 31? | 08-31 | 2937527 | 0.515 | **0.45** | Needs 14 *continuous* days with no qualifying US action — one strike resets the streak; below market. |
| 4 | Iran full airspace closure by Aug 31? | 08-31 | 2686771 | 0.465 | **0.45** | "Any time" trigger during active conflict; June-2025 precedent; roughly fair. |
| 5 | Russia × Ukraine ceasefire agreement by Aug 31? | 08-31 | 2602052 | 0.075 | **0.07** | No breakthrough priced anywhere in the cluster; 2025–26 talks repeatedly collapsed. |
| 6 | Israel withdraws from Lebanon by Aug 31? | 08-31 | 2641010 | 0.0315 | **0.03** | Full withdrawal in 6 wks; 2024–25 framework has been implemented glacially. |
| 7 | Bab el-Mandeb Strait effectively closed by Aug 31? | 08-31 | 2911874 | 0.165 | **0.14** | Houthi campaign deterred since mid-2025; escalation to full closure tail, not base case. |

### Domain B — Macro / Finance (7)

| # | Question | Resolves | ID | Mkt p | Forge p | Why (one line) |
|---|---|---|---|---|---|---|
| 8 | US annual CPI inflation = 3.4% in July? | 08-12 | 2925075 | 0.445 | **0.40** | Modal bucket of rounded YoY CPI; a single 0.1-pt bucket typically holds 0.35–0.40 — market slightly hot. |
| 9 | US annual CPI inflation = 3.5% in July? | 08-12 | 2925076 | 0.27 | **0.25** | Upside (tariff) tail of a distribution centered at 3.4%. |
| 10 | US Core CPI MoM = 0.3% in July? | 08-12 | 2810507 | 0.2505 | **0.27** | 0.3% is the typical core MoM print; exact-bucket mass ~0.25–0.30. |
| 11 | US July unemployment rate = 4.3%? | 08-07 | 2775407 | 0.395 | **0.38** | Modal rounded bucket; U-3 moves slowly month-to-month. |
| 12 | RBA: no rate change at August meeting? | 08-11 | 2234098 | 0.92 | **0.90** | Market prices hike ~8%, cut ~0%; eve-of-meeting holds are highly priced — small surprise discount. |
| 13 | US monthly CPI increases ≥0.1% in July? | 08-12 | 2925106 | 0.665 | **0.65** | With YoY running ~3.4%, MoM ≥0.1% is the central case. |
| 14 | Japan Q2 GDP (annualized) between 0.8% and 1.6%? | 08-17 | 2321905 | 0.365 | **0.35** | 0.8-pt band around center; quarterly GDP is noisy. Thin market ($3.7k liq). |

### Domain C — AI / Tech (7)

| # | Question | Resolves | ID | Mkt p | Forge p | Why (one line) |
|---|---|---|---|---|---|---|
| 15 | Anthropic has best AI model end of August? | 08-31 | 2955043 | 0.905 | **0.85** | Resolves by arena.ai Text-Overall rank on Aug 31; 6 wks is enough for a rival flagship to flip #1 — below market. |
| 16 | Google has best AI model end of August? | 08-31 | 2955045 | 0.052 | **0.06** | Needs both an Anthropic slip and a Google surge to #1. |
| 17 | OpenAI has best AI model end of August? | 08-31 | 2955048 | 0.0265 | **0.03** | Only if GPT-6 ships *and* takes #1 by the Aug-31 check. |
| 18 | GPT-6 released by Aug 31? | 08-31 | 2850825 | 0.26 | **0.22** | A flagship in any given 6-wk window; OpenAI timing notoriously slips — slightly below market. |
| 19 | Next Claude Opus model released by Aug 31? | 08-31 | 2761627 | 0.946 | **0.90** | Market near-certain (public rollout signals); standard ship-slip discount. |
| 20 | NVIDIA largest company by market cap on Aug 31? | 08-31 | 2941315 | 0.68 | **0.65** | Top-cap leadership flipped repeatedly 2024–25; single-date resolution. |
| 21 | GPT-6 released by Aug 14? | 08-14 | 2853384 | 0.044 | **0.04** | ~3.5 wks out; flagships rarely ship with no visible run-up. |

**Liquidity note:** all markets ≥ $3.5k liquidity, most ≥ $10k; IDs 2321905 ($3.7k) and 2850825 ($3.5k) are the thin ones — their market baseline is the weaker for it (logged, not excluded).

## Scoring protocol (mechanical — for the scorer session)

**Queue this job:** `[Quant] SCORE forecast-pilot-01 — on/after 2026-09-02` (worker may not edit [[queue]]; runner/Curator to add).

0. **First:** verify the harness's embedded F/M vectors hash-match the Integrity lock above (`4c8dfc20456a8918` / `292c90f9c917b4df`); on mismatch, refuse to score and flag (Critic F6).
1. For each ID above: `GET https://gamma-api.polymarket.com/markets?id=<ID>` (public, no auth; **send a browser User-Agent — bare clients get 403**, Critic 2026-07-22). Read `closed` and `outcomePrices` — the live gamma API has **no `isResolved` field** (confirmed by Critic fetch + harness). Resolution = `closed: true` with `outcomePrices` exactly `["1","0"]` (YES) or `["0","1"]` (NO). Fallback: open `https://polymarket.com/market/<slug>` and read the resolution banner.
2. Outcome mapping: YES → o=1, NO → o=0. **Void** → o=0.5 for **all three** forecasters (pre-committed; flag it), where void = closed without extreme `outcomePrices`, **or still unresolved (`closed: false`) at the single score run**; ≥2 voids → INCONCLUSIVE per the guard.
3. Compute `BS_F`, `BS_M`, `BS_C` over resolved questions; also per-domain splits, hit rate, and mean forecast vs mean outcome (calibration check).
4. Apply the verdict table **exactly as written**. Write `wiki/value/forecast-pilot-01-RESULT.md` (append-only relative to this note) and update [[ledger]] row 1's Result + Status (status change is Z2 — flag for human/Critic sign-off).

## Deviations & clean negatives (evidence attached)

- **Metaculus → Polymarket pivot.** Task specified Metaculus; on 2026-07-21 its API returned `Permission Error: The API is only available to authenticated users` and the site 403'd (Cloudflare challenge) — unreachable under the no-accounts rule. Ledger row 1 explicitly names "Metaculus → Kalshi/**Polymarket**," so the pivot is in-scope. Polymarket's real-money odds are a *stronger* baseline than Metaculus crowd forecasts, making this a harder, more honest test. Manifold (play-money) API also verified working; not used — weaker baseline.
- **WebSearch broken in this environment** (returned model reasoning traces, zero sources — tested 3×). Hence the information-handicap caveat above.
- **Selection method:** top-400 markets by volume in the 2026-08-04→09-01 window, filtered to liquidity ≥ $3.5k, then hand-picked for clean binary criteria (BLS, RBA, IMF Portwatch, arena.ai — all public resolution sources) and domain balance. Sports-player and mutually-redundant clusters excluded; within-domain correlation (Iran cluster; CPI buckets; best-model cluster) acknowledged and capped at 7/domain.
- **Resolution-range correction (2026-07-27).** The header previously read "resolving 2026-08-04 → 2026-09-01" — that is the **selection window** (bullet above), not the batch's resolution range. Live gamma-API verification of all 21 IDs (2026-07-27, browser UA, $0): first end **08-07** (#11, 2775407), last end **08-31** (13 markets), **zero drift** vs the 2026-07-23 snapshot; the per-market table below was already correct. Score day unchanged: on/after **2026-09-02** (frozen). Executed at **0/21 resolved** (live-verified same day — no outcome information exists); forecasts, integrity hashes, kill criterion, and protocol untouched — a factual prose correction under the Critic-amendment precedent below. Evidence: [[quant-row1-date-reconciliation-2026-07-27]]. **Side finding (Z2 call owed before 09-02):** market #19 (2761627) has been **pulled from Polymarket** (gamma API empty by id ×4 and by slug, 2026-07-27; the replacement listing is a different question) — the monitor now exits 1 (partial) and at score time the harness silently drops it (20-market verdict + WARNING); void/exclude/redesign is a human/Critic decision, per the exclusion lock.

## Verdict

`—` untested. Resolves on/after **2026-09-02**. Until the RESULT note exists, this row is aspiration with a scheduled execution date.

## Critic Amendment — 2026-07-22 (pre-resolution hardening)

Full adversarial review: [[critic-forecast-pilot-01-2026-07-22]]. **Legitimacy of in-place amendment:** executed while **0/21 markets were resolved** (verified live: all `active`, `closed: false`), so no outcome information entered; every change strictly **tightens** the pre-registration or fixes a factual protocol error — none loosen the KILL, and the frozen forecast tables are hash-proven untouched (batch block `a07a2b8b2a48b32b`, identical before/after). This is pre-registration hardening, not post-hoc correction; the forecasts remain frozen per the status line.

Amended: (1) verdict table — INCONCLUSIVE guard moved **first** (note ≡ harness); exact void threshold; unresolved-at-score-run = void; KILL consequence = killed as stated with revival only as a **new** row; NO-EVIDENCE redesign requires Critic + human sign-off on a dated artifact; PROMOTE carries the effective-N caveat. (2) Anti-fooling — exclusion lock, single-score-run lock, integrity-hash lock added. (3) Protocol — `isResolved` field error corrected (API has no such field), void definition made exact, hash-verify step 0 added, browser-UA flag. (4) Falsifiability verdict — all 21 verified falsifiable on public sources (live API descriptions), **zero exclusions**.

Scorer-harness follow-ups (flag for the SCORE job): score-time-unresolved → void (~5 lines); hash-verify embedded forecasts (~5 lines); browser User-Agent on the gamma API. Guard-first ordering already implemented.
