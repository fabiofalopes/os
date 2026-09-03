# 🔮 The Oracle

> One glance at the Forge — curated, not complete. The richness lives behind the links; this is the lens. *Refreshed 2026-08-03 20:27 UTC by the engine.*


## 🎯 Verdict & Arc — read this first

**The arc: the engine is now at 10 breakers and healthy — and the agent runway is empty. The idle is correct.** FM-10 SHIPPED: the gateway-flap breaker (W-2 promoted) gives Guard-5 flap memory + an escalating hold (×2 per in-window repeat, capped 4×: 1800→3600→7200→7200s) + the previously-missing human-visible alert oracle.sh renders on this one screen — 41/41 sandbox, checklist item 11 signed. The below-death-bar promotion was directive-driven and documented: FM-10 adds memory + visibility, NOT protection (the fixed hold already catches every first burst). The same arc was FM-9's SECOND production proof — 23:30Z worker TIMEOUT → 23:52Z builder ok, the timed-out first attempt's mid-run code landed with NO phantom credit (the job correctly stayed `[ ]`). Since: engine idle on an empty queue — every wave SKIP(EMPTY_QUEUE) at 0s, zero burn, bridge fully drained. Rows 3+4 both killed by their own pre-committed guards (two clean falsifications in 6 days = the engine working as designed, aspiration → evidence); everything else is human-gated. $0 throughout, paper only, no capital touched.

- **ENGINE — FM-10 SHIPPED 2026-08-01 23:52Z (W-2 → FM-10, the 10th breaker).** Flap counter at both hold-latch sites; an in-window repeat escalates the hold ×2 (cap 4×) and writes the alert marker oracle.sh renders here; a clean probe resets counter + marker; kill switch `GATEWAY_FLAP=0` = exact pre-fix. 41/41 sandbox assertions on real runner/worker/oracle bytes (the suite caught two of its OWN bugs pre-ship); `_ORACLE-CURATED.md` never engine-written (invariant held). Catalog synced FM-1→FM-10 + watch item W-1 (next number FM-11); INDEX one-liner applied 04:21Z. → [[janitor-gateway-flap-fm10-ship-2026-08-01]]
- **RUNWAY — EMPTY, and that is the correct state.** ROW-4 **KILLED + Critic-CERTIFIED** on the full clean sample — selected **`SR_X(EW)` = −0.857 net** ≤ 0 (gross −0.651 — wrong-sign *before* costs), family mean **−0.627** vs the rung-0 bar **+1.377** (≈2.0 Sharpe units below), DSR **p = 0.998**, ρ = 0.776 (1540 fixed-mask pairs, 0/30 leaks); the [[ktd-fin]] "plausible LLM edge" channel falsified on this universe/window, every number reproduced to 1e-9. Ledger flip staged (Z2). ROW-5 pre-reg **staged + Critic-hardened** — [[quant-pilot-03]]: one classical 1-month reversal factor (EW ensemble of 6 configs, no ML) through the overfitting guards this vault now owns, reusing the frozen pilot-01 universe byte-for-byte (zero new fetch); modal outcome NO-EVIDENCE/KILL — the **ONLY agent runway**, awaiting human sign-off, hours to verdict once signed. ROW-1 verdict day rehearsed 6 days early — first resolution **2026-08-07**, smoke GREEN except one systemic capture bug (gamma API returns `[]` for closed markets → by 09-02 all 21 fail; fix staged + fully tested, **NOT applied** — Z2/Critic-gated). → [[quant-pilot-02-RESULT]] · [[critic-quant-pilot-02-KILL-certification-2026-08-01]] · [[quant-pilot-03]] · [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]]

**⚖️ THREE decisions + ONE call the human owes the engine:**
1. **Row-2 publish GO / NO-GO** — 5 minutes, ☐ GO / ☐ NO-GO at the foot of [[tool-pilot-01-publish-checklist]], **owed since 07-23**. With rows 3+4 dead and row-1 gated on dates, selling the forged `cron-agent-swarm` skill is the ONLY line that can produce revenue evidence this month (verdict ~3 wks after publish; a KILL is a live honest outcome). Agents cannot publish (Z2, outward-facing). **Still the FASTEST path to money.**
2. **Row-5 pre-reg GO / NO-GO** — sign off [[quant-pilot-03]] (Critic-hardened, kill math frozen): the cheapest falsification the ledger has queued — hours to verdict, $0, zero new fetch. The ONLY agent runway.
3. **Row-4 ledger KILL flip** — formality: Critic-CERTIFIED, every number reproduced to 1e-9. Flip row-4 status `idea` → `killed` at [[ledger]]; certification at [[critic-quant-pilot-02-KILL-certification-2026-08-01]].

**The call (owed BEFORE 08-07 — 5 days out):** the row-1 **#19 void/exclude** decision, paired with the staged capture-bug fix. The smoke resolved #19 (verifiable now via `&closed=true`) — the "pulled market" diagnosis was the closed-markets bug's first symptom, so the call is **moot if the fix is approved** (recommendation: approve fix + score #19 resolved-YES). Without the fix the pipeline exits 2 on verdict day and row 1 gets no score. → [[quant-forecast-pilot01-preverdict-smoke-2026-08-01]]

**⚠ Gateway flap:** 6 holds in 6h — upstream egress degraded, engine auto-holding (FM-7 surface, self-heals). GATEWAY_HOLD lines in LOG.md.

## 🔴 Pulse — FAILING
- **Today:** Success rate (did its job): 0/12 = 0%   [12 real sessions, 0 infra fails apart]
- SUCCESS 0   EMPTY 0   FAIL 12   | INFRA 0 (harness, excluded)
- **Queue:** 1 pending

## Trend (7 days)
```
date        runs  success  empty  fail  infra  rate_pct
2026-07-28  4     0        0      4     0      0
2026-07-29  14    7        3      4     3      50
2026-07-30  0     0        0      0     2      0
2026-07-31  7     7        0      0     3      100
2026-08-01  24    14       6      4     4      58
2026-08-02  8     6        1      1     0      75
2026-08-03  12    0        0      12    0      0
```

## Recently forged
- [[forecast-pilot-01-fix-checklist]]
- [[quant-pilot-03]]
- [[quant-pilot-02-RESULT]]
- [[quant-pilot-02-PLAN]]
- [[forecast-pilot-01]]

---
Go deeper → [[INDEX]] (map) · LOG.md (audit) · [[MEMORY]] (working memory)
