---
tags: [critic, certification, quant, ledger-row-4, kill, clean-rerun, z2-proposal, inbox]
date: 2026-08-01
status: CERTIFIED — adversarial pass complete; KILL is the exact frozen-table row applied guard-first on the clean sample; [[ledger]] row-4 KILL proposal endorsed + staged (Z2 — NOT flipped; human sign-off required)
related:
  - "[[quant-pilot-02-RESULT]]"
  - "[[quant-pilot-02]]"
  - "[[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]]"
  - "[[critic-quant-pilot-02-RESULT-certification-2026-07-29]]"
  - "[[critic-mask-fix-audit-2026-08-01]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# [Critic] CERTIFICATION — quant-pilot-02 KILL (row 4, clean-fetch re-run 2026-08-01)

## VERDICT: **CERTIFIED.** KILL is the exact frozen-table row, applied guard-first on the clean sample. Ledger proposal: endorse (two verdict-neutral corrections, applied in place).

Same certification pattern as [[critic-quant-pilot-02-RESULT-certification-2026-07-29]] (the pass that earned the INCONCLUSIVE its addendum): every claim below was **reproduced from primary artifacts this session**, none trusted on the notes' authority. **Read-only throughout** — nothing in the frozen pipeline was run in a writing mode (`mode_verdict` writes `results.json` at run_pilot.py:341, so it was never invoked; the re-score was reproduced *in memory* instead). Evidence root: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`.

## (a) Guard-first verdict trace — CONFIRMED (guard evaluated and cleared BEFORE KILL fired)

- **Code order verified** (`run_pilot.py:apply_verdict` 217-231): `if guard_inconclusive: return "INCONCLUSIVE"` (219-220) → KILL (222-223) → NO EVIDENCE (225-226) → PROMOTE (228-230), each an early return. The KILL clause `(sr_x_ew <= 0) or (pbo >= 0.5) or (rho < 0.5)` (:222) matches the frozen table ([[quant-pilot-02]], verdict row 2) exactly.
- **Guard computed first** in `mode_verdict` (:276-283), before `apply_verdict` is called. Clean-run clause values (from `results.json:guard` + my reproduction): panel `frac_under_100` = 0.0; `n_oos` = 42 ≥ 30; `breadth_fail` = FALSE (reproduced 0/138, below); `failure_fail` = FALSE (116/55,679 = 0.21% ≤ 20%); `rho` = 0.776 ≠ None (CLI). → `guard_inconclusive = FALSE`: **all five sub-guards evaluated and cleared**, so the table reaches the thesis for the first time.
- **KILL then fired on the first clause alone:** `SR_X(EW) = −0.8566323264 ≤ 0`. PBO 0.2908 < 0.5 and ρ 0.776 ≥ 0.5 correctly did not fire. Empirically reproduced: `apply_verdict(..., guard=False)` → **KILL** (= recorded verdict); `apply_verdict(..., guard=True)` → INCONCLUSIVE (the spurious path — see (c)).
- **NO EVIDENCE / PROMOTE never evaluated** (early return at :222-223). The addendum's counterfactual is code-true: had SR_X been positive, `sr_x ≤ 1.377`, `DSR p 0.9977 ≥ 0.05`, and `ρ 0.776 < 0.8` would each independently give NO EVIDENCE (PBO 0.291 < 0.3 would not).
- The 07-29 denominator-invariance debate (138 vs 42 window months) is **moot**: breadth is now 0/138 — the guard clears under every reading.

## (b) Independent reproduction — ALL OK to 1e-9; two verdict-neutral corrections applied

- **Status counts** from `data/extractions.full.jsonl` (55,681 records): ok **55,563** / model_fail **116** / parse_fail **0** / fetch_fail **2** — exact match to `results.json:guard.extraction.status_counts`. Both fetch_fails are `http_503` (2/55,681 = 0.0036%); malformed rate 116/55,679 = 0.21%.
- **Breadth** (exact code filter, TRAIN[0]→OOS[1] = 138 window months): **0/138 months < 100 ok tickers** (min 159 / max 381 per month; first train month 2015-01 = 267, last OOS month 2026-06 = 196) — matches `n_months_under_100_extracted: 0` exactly.
- **In-memory re-score** (imported the frozen `run_pilot`/`sig`/`harness`, recomputed from `extractions.full.jsonl` + frozen panel, **wrote nothing**): n_used 55,563; selected L1Q5; `SR_X(EW)` **−0.8566323264**; gross **−0.6510672391**; `SR_X(SPY)` −0.5885429197; DSR p **0.9976835159**; PBO **0.2907536908**; **all six family `SR_X(EW)` + train SRs** — every figure matches `results.json` to 1e-9. Family mean −0.626470 → −0.627 ✓.
- **Correction 1 (applied in RESULT addendum + step-2 note):** `run_utc` is **2026-08-01T05:36:09+00:00** (`results.json` field; file mtime 06:36:09 WEST = 05:36:09Z), not 05:34Z — 05:34Z is the step-2 **wave start** (RUNSTATE:175). Verdict-neutral record error.
- **Correction 2 (applied in both notes):** the family best is **L3D +0.012**, not L2D −0.266 — both notes' prose mis-read their own tables (L3D +0.0123 > L2D −0.2659). So **5/6 configs negative**, not "the whole family wrong-sign." Verdict-neutral twice over: KILL fires on the *selected* L1Q5 −0.857 ≤ 0 regardless, and the A8 conclusion stands — even the family best (+0.012) sits **1.365 Sharpe below** the rung-0 bar 1.377.
- Everything else in the addendum verified: MDD −11.01%, turnover 25.6%/mo, val SR 0.633, mean excess −2.55%/yr, DSR skew +0.046 / kurt 3.384 / SR0 0.711 ann., PBO cumret 0.5721, L1Q5 IS-best 9,234/12,870, `beats_rung0` false, model digest `ef495d63…090c` (same A6 lock as the 07-28 run).

## (c) `run_pilot.py` ρ-ordering workaround — TESTED HONEST (bias toward the softer verdict; workaround reveals the harsher)

- **Bug confirmed at the exact lines:** `mode_verdict` computes `guard_inconclusive` (:281-283) testing `rho is None` on the **CLI argument**, and loads ρ from `probe.{tag}.json` only afterward (:313-315). The self-contradictory guard block is *derivable from the code*: `rho_missing` (:332) is evaluated after the load, so `verdict --tag full` without `--rho` yields literally `inconclusive=true AND rho_missing=false` — exactly what RUNSTATE:180 and the step-2 note record.
- **Bias direction (the adversarial question):** the bug can only flip a verdict **to** INCONCLUSIVE (softer) — `(rho is None)` can only add TRUE to the guard-OR when the arg is omitted; it can never suppress a guard that should fire. The workaround passes `0.7760188168361031` — **byte-identical to the content of `probe.full.json`** (verified) — i.e. exactly the value the frozen computation would itself have loaded; it is a manual hoist of the :313-315 load above the guard with **zero degrees of freedom**. On this dataset every possible `--rho` value gives KILL (ρ ≥ 0.5 → `SR_X ≤ 0` fires; ρ < 0.5 is itself a KILL clause) or the spurious INCONCLUSIVE (omission) — the harshest reachable verdict is the frozen-correct one. **No gaming direction.** Empirically reproduced: `apply_verdict(guard=True)` → INCONCLUSIVE, `(guard=False)` → KILL.
- **Bytecode preservation:** `run_pilot.py` mtime 2026-07-27T14:46:50 (predates both the 07-28 INCONCLUSIVE run and the 08-01 re-score — the bug was present in both; on 07-28 it was *inert*, because `breadth_fail`=TRUE fired legitimately on the real outage), `sig.py` 07-27T09:29, `common.py` 07-27T07:57, `backtests/harness.py` 07-23T05:17 — no scoring-layer file touched since the freeze. The only 08-01 code change is `mask.py` 01:08 — masking-only, bytecode-verified, A4-sanctioned per [[critic-mask-fix-audit-2026-08-01]].
- **Prior-verdict preservation:** `results.inconclusive.2026-07-28.json` (mtime 07-31T20:23, copied before the overwrite) contains exactly the 07-29 Critic-certified figures — 78/138 = 0.5652 `breadth_fail`, SR_X −0.3494, DSR p 0.9743, PBO 0.1851, ρ null, verdict INCONCLUSIVE. Literal byte-identity is not re-verifiable after an overwrite; **content-identity with the independently certified predecessor is the strongest post-hoc evidence, and it holds.** (The addendum's "verified byte-identical pre-overwrite" is the scoring session's contemporaneous record; left as-is, labeled here.)
- The recommended A9b patch (load probe ρ above the guard) is correctly **logged as future work, not applied** — patching frozen scoring code mid-verdict would itself be a scope violation.

## (d) Leaky-vs-fixed ρ reconciliation — CONFIRMED, with my own independent leak re-count

- `probe.full.json`: ρ **0.7760188168361031**, p 3.599e-310, n_pairs **1540**, n_sample 1607. `probe.leaky.2026-08-01.json`: ρ **0.767988337191806**, p 0.0, n_pairs = n_sample **1607**. **Δρ = +0.0080305** ✓; n_pairs −67 = 4.17% ≈ 4.2% ✓. `probe_rerun_2026-08-01.log` matches the note's quote verbatim (`done 2026-08-01T04:12:51+00:00 | rho=0.7760188168361031 n_pairs=1540 | 1607 fetched, 0 fetch-fail`).
- **Independent mask-audit re-count** (my own regexes — word-boundary + dot/hyphenless ticker variants; ISO / "Month DD, YYYY" / "MM/DD/YYYY" date patterns): fixed dump → **ticker leaks 0/30, absolute dates 0/30, `[PERSON]` 0/30, `[COMPANY]` 30/30, `[DAY±n]` 30/30** — exactly the step-2 note's re-audit (0/30 = 0.0% ≤ 10%). Same count on the archived leaky dump → **11/30 = 36.7%** (e.g. MMM's `mmm:` XBRL prefixes) — exactly [[critic-mask-fix-audit-2026-08-01]]'s 11/30 (MMM×5 / ABBV×5 / AES×1).
- The reading holds: closing the 36.7% identity leak moved ρ by **+0.008 — the leaks were not inflating ρ**; both readings land in `[0.5, 0.8)` (~78% of rank info survives masking — not identity-collapsed, short of the 0.8 PROMOTE bar). The −67 pairs are all masked-parse-drops (0 fetch-fail end-to-end; `run_probe` appends a pair only on successful parse — per the mask-fix audit's code read; arithmetic verified here), directionally **conservative** per A5 (more masking cannot push ρ toward 0.8). Moot regardless: KILL fires before ρ is consulted.

## (e) Z2 staging note — ENDORSED, amended in place (two corrections)

[[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]]'s staged proposal is correct: **Result = KILL, Status `idea` → `killed`, revival requires a NEW ledger row + new Critic review** — this is the frozen KILL consequence verbatim ([[quant-pilot-02]], verdict row 2: *"Row 4 → killed as stated… Revival requires a new ledger row + new Critic review. NOT the NO-EVIDENCE redesign allowance."*). **A KILL grants no redesign allowance** — confirmed against the frozen text; the note itself says so. Corrections 1–2 above (+ the "whole family wrong-sign" → "5/6" wording) applied in place in both the step-2 note and the RESULT addendum — verdict-neutral; the recorded KILL untouched. RESULT frontmatter + a certification pointer added (Z1 links).

## [[ledger]] row-4 update proposal (Z2 — apply ONLY after human approval; ledger NOT touched here)

Endorses the staged proposal in [[quant-pilot-02-step2-clean-rerun-kill-2026-08-01]] with the family-best correction. Current row 4 (`wiki/value/ledger.md`): Result `—` (aspiration), Risk-adj `n/a`, Status `idea`.

- **Result:** `KILL — clean-fetch re-run 2026-08-01 (Critic-certified): SR_X(EW) = −0.857 net ≤ 0 (L1Q5, frozen config, never re-selected — A9b); gross −0.651 (wrong-sign BEFORE costs); family mean −0.627 (5/6 negative, family best L3D +0.012); DSR p = 0.998 (trials 6); PBO 0.291; ρ = 0.776 (fixed mask, leak audit 0/30). All INCONCLUSIVE guards cleared on the re-extracted sample (ok 55,563/55,681, fetch_fail 0.0036%, breadth 0/138); KILL on the wrong-sign-after-costs clause. ≈2.0 Sharpe below the rung-0 bar (+1.377). [[quant-pilot-02-RESULT]] · [[critic-quant-pilot-02-KILL-certification-2026-08-01]].`
- **Status:** `idea` → **`killed`** (as stated; revival = new ledger row + new Critic review, NOT the redesign allowance).
- **Risk-adj. score (proposed):** ≈ **3.5** — evidence 4/5 (full OOS, overfitting-guarded, Critic-certified clean re-run), edge 0 (moot: killed), capital efficiency 5/5 ($0), killability high. Mirrors row 3's scored-KILL precedent (3.5); human to finalize.
- **Capital:** $0, paper only, no capital touched, no live trading. Cost to date: token-plan inference + free EDGAR across two detached runs (~22h outage-run + ~18h re-extract/probe/re-score wall).

## Process findings (flagged, not verdict-affecting)

1. **The two factual errors propagated from RUNSTATE shorthand:** RUNSTATE:175/185 labels the wave "~05:34Z" and repeats it as `run_utc`; both vault notes inherited it. Fixed in the vault (in place); RUNSTATE is pipeline-side (outside the vault, read-only discipline) — discrepancy recorded here, not edited there.
2. **"Verified byte-identical pre-overwrite" is unprovable post-hoc** — the evidence that holds is content-identity with the 07-29-certified INCONCLUSIVE (section (c)). Addendum wording left as the scoring session's contemporaneous record.
3. **The ρ-ordering bug remains live in the frozen executor** (patch correctly deferred). Any future verdict-mode run on this pipeline must pass `--rho` explicitly or reproduce the same spurious INCONCLUSIVE — logged for the A9b patch queue.

---

*Critic method: code read (guard order :217-231, bug lines :281-283 vs :313-315, bias-direction proof), in-memory re-score of the frozen code (no writes — `mode_verdict`:341 writes results.json and was never invoked), jsonl/json re-counts (status counts, 138-month breadth, leak audit ×2), mtime sweep (bytecode preservation), archived-predecessor cross-check. All five attack surfaces ((a)–(e)) tested against primary artifacts; none asserted on the notes' authority. $0, paper only, no capital, ledger untouched, pipeline unmodified.*
