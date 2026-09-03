---
title: GLM-5.3-Flash Gas — Z.AI vs Prime Intellect (Harness Runs)
date: 2026-09-03
tags: [z-ai, glm-5.3-flash, prime-intellect, costs, gas, upb, harness]
sources:
  - docs.z.ai/guides/overview/pricing
  - glm-5.3-flash page
  - z.ai/blog
  - prime-models.json (118 models, 2026-08-27)
related:
  - "[[Prime Intellect — Cost Analysis]]"
  - "[[Universal Provider Bridge — Project Master Map]]"
  - "[[Claude Code Routes — upb CLI Decision & Runbook]]"
  - "[[Claude Code Proxy Pattern — Master Reference]]"
---

# GLM-5.3-Flash Gas — Z.AI vs Prime Intellect

> Reconciled snapshot 2026-09-03. Do not re-fetch — write target for all harness gas needs.
> Auth by env refs `$ZAI_API_KEY` / `$PRIME_INTELLECT_API_KEY` only (no secrets in vault).
> Related: [[Prime Intellect — Cost Analysis]] · [[Universal Provider Bridge — Project Master Map]] · [[Claude Code Routes — upb CLI Decision & Runbook]]

## 1. Model spec

- **GLM-5.3-Flash**: 1M context, 128K max out, thinking always on.
- **Flagship GLM-5.3 ref**: $1.40 / $0.26 cached / $4.40 — Flash ~1/10th.
- **Prime fallbacks**: `glm-4.7-flash` $0.07/$0.40, `glm-5.3` $1.40/$4.40.

## 2. Head $/1M table

| lane | input | cached input | output |
|---|---|---|---|
| Z.AI promo (until 24:00 Sep 9 2026 UTC+8) | $0.075 | $0.015 | $0.25 |
| Z.AI list | $0.15 | $0.03 | $0.50 |
| Prime `z-ai/glm-5.3-flash` effective 2026-08-27 | $0.15 | full price (no cache discount published) | $0.50 |

- Today Z promo **2x cheaper** than Prime; after Sep 9 parity except Z cache hits (~88% hit typical → effective ~$0.022/M in).
- Z extras: web search $0.01/use.

## 3. Z.AI Coding Plan gas (credits, not $)

| tier | price | 5h allowance | weekly allowance |
|---|---|---|---|
| Lite | $18/mo | 2k | 10k |
| Pro | $80/mo | 12k | 60k |
| Max | $168/mo | 28k | 140k |

- Weekly allowance @95–98% cache: Lite Flash **146–317M**, Pro **877–1900M**, Max **2047–4433M tok/week**.
- Base URL for plan billing **must be** `https://api.z.ai/api/coding/paas/v4`.

## 4. Gas-units explainer (dollars vs credits)

- **API lanes (Z direct, Prime)**: billed in **dollars per 1M tokens**. Cache = direct $ discount (Z only).
- **Plan lane**: billed in **credits**. Formula Flash: `credits = (in*2.3 + cached_in*0.56 + out*8)/10000`, flagship **3x more**.
- **Cache weight**: cached input ~0.24x of fresh input (0.56 vs 2.3) — same ~80% saving shape as $ lane ($0.03 vs $0.15).
- **Off-peak 0.5x**: Mon–Fri 14–18 SGT peak, weekend all off-peak.
- **MCP tool**: 1.2 credits/call.

## 5. Per-harness gas math

### 5a. Turns-per-$10 (API dollars, worst-case no cache)

| turn shape | Z promo | Z list = Prime |
|---|---|---|
| chat 50k+5k | $0.0050 (2000/$10) | $0.0100 (1000/$10) |
| claude-code 1.3x loop | $0.0065 | $0.0130 |
| deep 200k+10k | $0.0175 | $0.0350 |

With 95% cache (Z only): chat promo **$0.00215**, list **$0.0043**; deep promo **$0.0061**, list **$0.0122**.

### 5b. Turns-per-week (Plan credits, Flash)

| turn shape | credits peak / off-peak | Lite | Pro | Max |
|---|---|---|---|---|
| chat 50k+5k | 15.5 / 7.75 | 645 / 1290 | 3870 / 7741 | 9032 / 18064 |
| deep 200k+10k | 54 / 27 | 185 / 370 per week | — (scale ×6 Lite) | — (scale ×14 Lite) |
| chat 95% cache | 7.24 / 3.62 | 1382 / 2764 per week | — (scale ×6 Lite) | — (scale ×14 Lite) |

Scale: Pro = 6x Lite, Max = 14x Lite (10k / 60k / 140k weekly).

## 6. UPB wiring

- **Z direct**: `zai/glm-5.3-flash` → `https://api.z.ai/api/coding/paas/v4` with `$ZAI_API_KEY`.
  - Update `providers.yaml` stale map `haiku→4.5-air` to `5.3-flash`.
- **Prime**: `prime/z-ai/glm-5.3-flash` needs new `prime:` block, `base_url https://api.pinference.ai/api/v1`, key `$PRIME_INTELLECT_API_KEY`.
- **router-alibaba.env** `haiku→glm-5.3-flash` is via opencode-go gateway, separate billing — not Z plan, not Prime.

## 7. Recommendation

- **Burn promo on Z direct until Sep 9** — 2x cheaper than Prime, cache stack on top.
- **Keep Prime as failover** — parity after Sep 9 except Z cache edge; same model ID ready.
- **Plan tiers only if sustained >1–2k chat turns/week** — Lite 645 peak / 1290 off-peak (1382/2764 cached) is the break-even vs pay-as-you-go burn.
