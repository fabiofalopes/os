---
tags: [critic, certification, quant, ledger-row-4, z2-proposal, inbox]
date: 2026-07-29
status: CERTIFIED — adversarial pass complete; [[ledger]] row-4 proposal staged below (Z2 — NOT flipped; human sign-off required)
related:
  - "[[quant-pilot-02-RESULT]]"
  - "[[quant-pilot-02]]"
  - "[[critic-quant-pilot-02-RESULT-2026-07-29]]"
  - "[[janitor-gateway502-preflight-probe-2026-07-29]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# [Critic] CERTIFICATION — quant-pilot-02-RESULT (row 4, verdict INCONCLUSIVE)

## VERDICT: **CERTIFIED.** INCONCLUSIVE is the exact frozen-table row, applied guard-first. Ledger proposal: endorse (one addition).

This note is the durable adversarial review the RESULT note's 07:43Z addendum linked to but never wrote (dangling `[[critic-quant-pilot-02-RESULT-certification-2026-07-29]]` — resolved by this file). Every claim below was **reproduced from primary artifacts this session**, not trusted from the note. Evidence root: `~/Projects/trading-agents/quant-research/pilots/quant_pilot_02/`.

## (a) Guard exactness — CONFIRMED, and verdict-invariant to clause reading

- **Code order verified** (`run_pilot.py`): `guard_inconclusive = (frac_under_100 > 0.20) or (n_oos < 30) or xg["breadth_fail"] or xg["failure_fail"] or (rho is None)` is computed in `mode_verdict` **before** `apply_verdict` is called; `apply_verdict` line 219: `if guard_inconclusive: return "INCONCLUSIVE"` — then KILL, NO EVIDENCE, PROMOTE. **No early exit to KILL** despite `SR_X(EW) = −0.349 ≤ 0` (which would fire KILL at line ~222). The `rho is None` clause carries the comment *"missing probe is infra-incompleteness, not a thesis result → INCONCLUSIVE"* — exactly RUNSTATE logged deviation #2, pre-execution, mask-only.
- **Breadth number reproduced independently** from `data/extractions.full.jsonl` (55,681 records): ok tickers per `acc_month` → **78/138 months < 100 = 56.5%**, all 78 = 2020-01→2026-06 contiguous, **zero** train months under 100 (min train month = 177 tickers; max valoos month = 42). Matches `results.json:guard.extraction` exactly.
- **Denominator invariance (adversarial):** the frozen clause says "> 20% of *window months*". The code uses TRAIN[0]→OOS[1] = 138 months — the **conservative** denominator (dilutes with healthy train months). On the strict OOS-only reading (42 months, 2023-01→2026-06) it is **42/42 = 100%**. The guard fires under either reading; the verdict does not depend on the interpretation.
- **Failure-rate clause invariance:** frozen text = "malformed output after 1 structured retry" → code counts `(parse_fail + model_fail)/definitive` = 21/27,948 = **0.075%** → not fired (correct — `fetch_fail` is infra, not malformed output; code comment documents this). Adversarial counter-reading: if `fetch_fail` counted, the rate is 49.8% → the clause **also** fires → same verdict, different clause. INCONCLUSIVE is robust to every clause reading I could construct.
- **Third clause** (EDGAR unreachable = submissions AND full-text both fail): submissions 503/503 ok, `fetch_errors = {}` → correctly reported not-fired.
- `results.json:guard.extraction.months_under_100_extracted` shows only 12 months because `run_pilot.py:216` writes `under[:12]` — a deliberate head preview; the count field (78) is authoritative and reproduced. The addendum's disclosure is correct.

## (b) Step-6 checklist — COMPLETE; one honest gap, correctly handled

| Item | Verified against | Result |
|---|---|---|
| Frozen prompt verbatim | `data/extraction_log.full.json:prompt_template` | byte-identical to the note's quote ✓ |
| Model lock + digest | same log + `data/stage0_verdict.json` | one digest `ef495d63…090c`, stage0 == full ✓ (one lock, never swapped) |
| Masking procedure | note quotes the 4 frozen rules (A4) | present ✓ |
| **≥30-sample leak audit** | `data/mask_audit.full.json` | `[]` — **NOT PERFORMED** (probe re-fetched 0/160 pairs in the same outage → no samples exist). The only real gap. The note logs it honestly and binds it on the re-run before any ρ is trusted; the frozen ">10% leaks → fix + probe re-run" rule is vacuously unmet, not waived. **Not a kill — an audit cannot run on zero samples; deferral is the only honest option.** |
| Extraction stats | jsonl reproduction | 55,681 = ok 27,927 + model_fail 21 + parse_fail 0 + fetch_fail 27,733 ✓ |
| A7 (failures by item/year) | jsonl reproduction | by-item ff shares **33.8/25.2/20.0/11.0/7.2%** (2.02/7.01/5.02/1.01/2.03) — matches the Critic-corrected addendum exactly; per-item fail rates 0.490–0.525 uniform; max share 33.8% < 50% → no flag ✓. Per-year rates 0.898–0.915 uniform → no year flag ✓ |
| A8 (rung-0 reconcile) | `results.json` | bar +1.377 vs pilot-01 family mean 1.363 (+1.0%) → not luck-inflated ✓; this family: all 6 configs negative, mean −0.369 ✓ |
| Measured numbers | `results.json:oos/dsr/pbo/family` | SR_X(EW) −0.349 / gross −0.336 / SR_X(SPY) −0.365 / mean excess −1.05%/yr / MDD −9.92% / turnover 1.69%/mo / val SR 0.573 / DSR p = 0.974 (skew −0.61, kurt 4.31, SR0 0.676, trials 6) / PBO 0.185 (cumret 0.281) / L1Q5 IS-best 8,530/12,870 / all 6 family rows — **every figure matches the note** ✓ |
| Config freeze | `data/config_freeze.json` | L1Q5, train SR 1.288, frozen **2026-07-27T22:15:08Z** — before the first valoos record (orchestrate.log line 328) ✓ anti-peeking intact |

## (c) "Confined to the valoos phase" — TESTED, holds (with the note's own labels preserved)

- **Phase split (content-based, timestamp-independent):** of 27,733 `fetch_fail`, **1 is train** (MLM 2016-05, `http_503` — an isolated transient, 1/24,974 = 0.004%) and **27,732 are valoos** (27,732/30,707 = 90.3% of the phase; 99.996% of all failures). Error kinds reproduced: `fetch_error:ConnectionError` 27,732 + `http_503` 1; zero 429/403 anywhere → not rate-limiting.
- **Step-function onset reproduced** from `data/orchestrate.log`: the ok-counter's last value below 27,927 is line 358 (`records=27874, ok=27859`); line 359 (`records=27974`) already shows the final `ok=27927`, which then flatlines for the remaining ~27,700 records. I.e., the first ~2,968 valoos extractions succeeded (~3,000 records in), then total failure — the signature of an egress step-function, not content attrition. (The log carries no wall-clock per line; the addendum's "onset ≈22:25Z" is throughput-derived from the 22:15:08Z freeze — its "~10 min precise" hedge is honest.)
- **Gateway journal cross-check (the job's "204 upstream fails"):** `journalctl --user` 07-27T22:00→07-28T20:30 = **210** `fetch failed|502` lines in **5 bursts**: one at **23:xx UTC (~29 lines) INSIDE the SEC storm window** (22:15→00:00Z — the addendum's 23:12Z burst, confirmed), and four **after** extraction ended (00:49/07:04/13:04/19:04Z ≈ 45 lines each = the 4 Steward deaths, per [[janitor-gateway502-preflight-probe-2026-07-29]]). Reading: one burst overlaps the storm (consistent with a common local-egress root); four postdate it (the gateway instability outlived the SEC storm). The note's label — **suspected common root, direct causation NOT proven** — is exactly right: SEC traffic never traverses :8705 (janitor verified no proxy env in `common.py:http_session`), and the model path through :8705 stayed 99.8% healthy during the damage window. I found no evidence to upgrade or downgrade that label.

## (d) Frozen consequence of INCONCLUSIVE — read, not invented: **clean-fetch re-run, NOT record-and-advance**

- Frozen table ([[quant-pilot-02]], verbatim): *"No verdict — infra/compute failure, not thesis failure. Fix the path, re-run. This guard can only ever mask a KILL/NO-EVIDENCE — never manufacture a PROMOTE."* RUNSTATE.md agrees ("INCONCLUSIVE pause… do NOT swap models").
- The note's fix path stays inside the frozen **A9b carve-out**: re-extract the **27,733 failed filings only** (`resume_extract.py` per-filing resume); config freeze L1Q5 (pre-OOS) never re-selected — "a bug discovered after OOS extraction may trigger re-extraction of the affected filings only — never config re-selection." The outage defines the affected set exactly. The NO-EVIDENCE one-redesign allowance remains **unspent** (this is infra-resume, not redesign). Defensible — certified.
- **Endorsed Critic finding from the 07:43Z pass:** RUNSTATE Guard-5 probes the :8705 model gateway, which was 99.8% healthy while SEC fetch was ~90% dead — a green gateway probe would NOT imply a green SEC fetch. **The re-run must gate on a direct `www.sec.gov` full-text egress probe** (steward staged job #2), not the gateway.
- **Honest expectation (the note states it; I concur):** if the clean sample resembles the decimated one (wrong-sign family, DSR p = 0.974), the unmasked verdict is **KILL** (`SR_X(EW) ≤ 0`). The re-run buys a *clean* verdict, not a hopeful one.

## Process findings (flagged, not verdict-affecting)

1. **The CERTIFIED addendum in the RESULT note preceded its own evidence.** File mtime 07:43Z > the 01:38Z landing → a prior session (a Critic pass) amended the note in place (A7 correction, sharpenings, addendum) but **died before writing this review**, leaving the dangling link and the certification claim unsupported. The claim is now supported: I independently reproduced every number the addendum asserts. No amendment to the RESULT note needed — no gap survives in it; this file supplies the missing durable artifact.
2. **The dispatch premise is stale:** the job says the SCORE re-run "NEVER DID" stage a [Critic] review + ledger proposal. It did — [[critic-quant-pilot-02-RESULT-2026-07-29]] (inbox, staged 01:38Z) contains both; `proposals.md` merely doesn't carry it. I endorse that proposal below with one addition rather than duplicating it.

## [[ledger]] row-4 update proposal (Z2 — apply ONLY after human approval; ledger NOT touched here)

Endorses the staged proposal in [[critic-quant-pilot-02-RESULT-2026-07-29]], plus the egress-probe gate:

- **Result:** `INCONCLUSIVE (extraction breadth guard 78/138 months = 56.5% > 20%; 49.8% fetch_fail ConnectionError storm, valoos phase 07-27T22:15→07-28T00:00Z; measured sub-guard on the 9.7% sample: all 6 configs SR_X(EW) ≤ 0, family mean −0.369 (selected L1Q5 −0.349), DSR p = 0.974, PBO 0.185, ρ unmeasured — no statistical verdict valid). Critic-certified 2026-07-29.`
- **Status:** stays **`idea`** — INCONCLUSIVE is no verdict. Explicitly NOT `killed` (requires a guard-clearing KILL) and NOT a redesign (allowance unspent).
- **Next:** pre-dispatch **direct `www.sec.gov` full-text egress probe** (NOT the :8705 gateway probe — certified gap above) → re-extract the 27,733 failed filings only, frozen config L1Q5 untouched → probe + **≥30-sample leak audit actually performed** → re-apply the verdict table exactly. Modal expectation unchanged: KILL on a clean sample.
- **Evidence:** [[quant-pilot-02-RESULT]] · this note · `results.json` · `data/extractions.full.jsonl` · `data/orchestrate.log` · `data/extraction_log.full.json` · `data/config_freeze.json` · `data/mask_audit.full.json` (empty — the audit debt).
- **Cost to date:** $0, paper only (token-plan inference, free EDGAR). ~10.5h wall of a ~22h detached run produced a guard-level result; re-run scoped to failed filings only.

---

*Critic method: all four attack surfaces tested against primary artifacts (code read, jsonl reproduced, journal cross-checked) — none asserted on the note's authority. $0, paper only, no capital, ledger untouched.*
