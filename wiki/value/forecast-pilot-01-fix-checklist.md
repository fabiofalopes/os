---
tags: [value, forecasting, pilot, ledger-row-1, handoff, human-gated, z2]
date: 2026-08-02
status: handoff (Z2) — one-screen go/no-go for the human. The fix is staged + Critic-endorsed, NOT applied; the human checks the box and the precondition-gated apply job self-executes on GO.
related:
  - "[[forecast-pilot-01]]"
  - "[[quant-forecast-pilot01-preverdict-smoke-2026-08-01]]"
  - "[[critic-forecast-closedmarket-fix-review-2026-08-02]]"
  - "[[tool-pilot-01-publish-checklist]]"
  - "[[ledger]]"
---

# Forecast Pilot 01 — ROW-1 FIX Go/No-Go (5-minute human decision)

> **The decision:** approve the two-stage closed-market fetch fix so verdict day (≥2026-09-02)
> can actually score [[ledger]] row 1 — *"is Forge calibrated against the real-money market?"*
> Without it the pipeline **exits 2 on score day and row 1 gets no verdict at all.** The fix is
> staged, fully tested, and Critic-endorsed ([[critic-forecast-closedmarket-fix-review-2026-08-02]]);
> it is **NOT applied** — that is Z2, gated on this box. **You only decide go/no-go.**

## What you're approving (one line each)

- **The bug:** the gamma API's `/markets?id=<ID>` endpoint returns `[]` for **closed** markets by default. Every market is closed by 2026-09-02 → 21/21 fetch-fail → watcher exit 2 → **no verdict.** #19 (already resolved YES) is the first casualty.
- **The fix:** on an empty response, retry once with `&closed=true`. Fetch-only; two files; ~4 lines each.
- **Why now:** first resolution lands **2026-08-07** (#11); #19's YES is owed a treatment before then. Verdict day ≥2026-09-02 is the hard deadline.

## The exact two-file diff (apply identically to `fetch()` in BOTH files)

`~/Projects/forecast-scorer/fetch_resolutions.py` (fetch(), ~line 92) and
`~/Projects/forecast-scorer/score_forecast_pilot01.py` (fetch(), ~line 153):

```diff
             req = urllib.request.Request(API.format(mid=mid), headers=UA)
             with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
                 data = json.loads(r.read().decode())
+            if not data:                       # closed markets are hidden by the default filter
+                req2 = urllib.request.Request(API.format(mid=mid) + "&closed=true", headers=UA)
+                with urllib.request.urlopen(req2, timeout=TIMEOUT) as r:
+                    data = json.loads(r.read().decode())
             if data and isinstance(data, list):
                 return data[0], None
             return None, "empty/unexpected response"
```

`closed=true` is a **strict filter** (returns EMPTY for open markets — tested), so the `if not data` fallback can only ever surface an *already-resolved* outcome. It can never fire for an unresolved market.

## Critic verdict (quoted)

> **ENDORSE — apply with wording amendments (d). No KILL-level gap.** All four claims the human must trust **CONFIRMED with live evidence** … the fix is structurally incapable of touching scoring math, the verdict ladder, `parse_outcome`, `brier`, `EXTREME`, or the integrity hashes.

Critic amendments incorporated below: **(1)** `bash -n` → `py_compile` + `--selftest` (bash syntax check validates nothing for `.py` edits); **(2)** exact integration point specified (above); **(3)** snapshot backup + frozen-hash guard added.

## Re-smoke command + expected output (acceptance the apply job must hit)

```sh
cd ~/Projects/forecast-scorer
python3 -m py_compile fetch_resolutions.py score_forecast_pilot01.py   # both compile clean
python3 score_forecast_pilot01.py --selftest                            # → ALL PASS
cp resolutions_pilot01.json resolutions_pilot01.json.bak-20260802-prefixfix   # back up first
bash run_verdict.sh ; echo "exit=$?"                                    # → exit=0
```

**Expected:** `#19 (2761627) → resolved-yes (o=1.0)` · `fetch-failed=0` · `resolved 1/21 · unresolved 20 · void 0` · `watcher == scorer AGREE` · verdict **INCONCLUSIVE** (guard N=1 < 15, unchanged) · **exit 0** (today it is exit 1 partial, solely from #19) · FROZEN hashes unchanged: forge `fb6ce92417122fc5` / market `f301871bc99dca27`. Then record in the RESULT-note provenance.

## NO-GO consequence (stated plainly)

- **No fix → no verdict.** By ≥2026-09-02 all 21 markets are closed → 21/21 FETCH-FAILED → watcher exit 2 → `run_verdict.sh` exit 2 → **row 1 gets NO score.** The exact failure the frozen protocol's browser-UA design meant to prevent (it guarded against 403s; the real failure mode is the closed-market default filter).
- **#19's clean YES goes uncounted** from the first resolution (08-07): the bare URL hides it, so the batch silently drops it (a de-facto exclusion the frozen lock forbids).
- **Manual fallback exists but is inferior:** the frozen protocol's hand-read of `polymarket.com/market/<slug>` still works (all 21 slugs archived) — a laborious, error-prone substitute for a 4-line mechanical repair.

## Frozen invariants the fix does NOT touch (Critic-confirmed, by construction)

- **Probabilities:** `forge_p` / `mkt_p` frozen in code (captured 2026-07-21), tamper-guarded; `fetch` never writes them.
- **Hashes:** forge `fb6ce92417122fc5` / market `f301871bc99dca27` reproduce byte-identical; selftest ALL PASS.
- **Ladder:** INCONCLUSIVE-guard → KILL (BS_F ≥ BS_M) → NO EVIDENCE → PROMOTE — untouched.
- **Capture set:** the 21 hardcoded `FROZEN` IDs; the per-ID fallback adds/drops none.
- **Single-score-run lock (Critic G2):** the scoring path (`--from-snapshot`) makes **zero** network calls, so the fix cannot reach it; still one official capture on/after 09-02.

The fix changes **what is captured** (resolution outcomes for closed markets), never **how it is scored** or **the frozen inputs**.

## The coupled call — #19 treatment (owed before 08-07)

GO on the fix makes this moot in the honest direction: **#19 scores resolved-YES (treatment A)** — the only lock-legal treatment (criterion is public, deterministic, and resolved cleanly; exclusion is lock-illegal, void doesn't fit). F=0.90, M=0.946, o=1: A adds F +0.0100 / M +0.0029 to the BS sum, batch stays 21/21. (B=void spends the void budget and mechanically favors Forge; C=exclude is lock-illegal and is the silent current default.) Full arithmetic in [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]] §3.

---

**☐ GO** — approve the fetch fix **+** ratify #19 = resolved-YES (A) · the apply job self-executes on this box
**☐ NO-GO** — hold (state reason in [[ledger]] log; consequence: exit 2 on 09-02, row 1 unscored)

*Prepared 2026-08-02 by a Quant cron worker from [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]] §2/§5 + [[critic-forecast-closedmarket-fix-review-2026-08-02]]; diff + integration point verified against the on-disk `fetch()` in both files same day. Fix staged, NOT applied.*
