---
tags: [project, trading, moon-dev, wayback, recovery, scout]
date: 2026-07-21
status: complete — 12 pages recovered, verdicts attached
related:
  - "[[Moon Dev — Research Brief & Leads]]"
  - "[[legitimacy-ledger]]"
  - "[[Moon Dev — Current Work (2026)]]"
  - "[[curriculum-draft]]"
  - "[[the-alpha-illusion]]"
---

# Wayback Recovery — algotradecamp.com + moondev.com

> **Scout job (2026-07-21):** recover what was public before paywalling from the two Moon Dev domains, verdict each resource. Method: Wayback CDX API (`web.archive.org/cdx/search/cdx`) to enumerate snapshots, `curl` of `id_` (pristine) captures, stdlib HTML→text extraction. Every claim below carries its capture timestamp. Verdicts use the [[legitimacy-ledger]] vocabulary: **substantive / mixed / hype**.

## TL;DR

- **The paywalled bootcamp curriculum is fully recoverable from sales pages** — the 2025 sales page lists all 32 days with video lengths. That structure (not the videos) is the durable artifact; it's captured in full below.
- **moondev.com's free layer is the real value**: the Hyperliquid Data Layer API docs and the trading calculators are public, substantive, and align with [[Moon Dev — Current Work (2026)]] (the data-moat pivot).
- **Moon Dev's own marketing converges with our research verdict** ([[the-alpha-illusion]], [[ktd-fin]]): "no one is going to give you a profitable bot… if everyone ran the same bot, the profits would converge to 0." Rare honesty in this niche — but it coexists with hard hype machinery (fake countdowns, placeholder testimonials on old pages, an off-mission $7/mo make-money-online scheme).
- **Clean negatives:** the 2023 ChatGPT "ai-plugin.json" is a redirect (no plugin existed); `/roadmap` is email-gated; `/backtests` is JS-rendered (nothing static to recover); the 2008–2011 moondev.com blog is a **different owner** entirely.

## Verdict table

| Resource | Capture | Verdict | Why |
|---|---|---|---|
| algotradecamp `/bootcamp` | 2023-01-16 | **mixed** | Real curriculum (10 lessons + 7 algos w/ code) behind $197; FOMO "only 100 members"; refund voided if you open the code folder |
| algotradecamp `/learnnow` | 2022-11-29 | **mixed** | Richest early curriculum map (6-week agenda, 14 named bots, done-for-you bot); same hype chassis |
| algotradecamp `/2025-update-1` | 2025-09-03 | **substantive** | Full 32-day curriculum w/ durations + honest disclaimer ("no plug-and-play millionaire bots"); best single recovery |
| algotradecamp `/100day` | 2023-08-06 | **hype** | NOT trading: "$100/day with AI" faceless-video scheme, $7/mo. Off-mission; FTC Biz-Op disclosure, arbitration in Puerto Rico |
| algotradecamp blog (`5-reasons…`) | 2022-11-29 | **hype** | Generic SEO filler; **testimonials are template placeholders** ("Amanda Souzanne, MarketingCompany.com") |
| algotradecamp `ai-plugin.json` | 2023-07-06 | **negative** | 302 → ClickFunnels homepage; no ChatGPT plugin ever existed |
| moondev.com `/` (2024) | 2024-08-25 | **substantive** | Data-API launch (OI/funding/liquidations history) + the anti-hype manifesto, repeated 10×: build your own edge or don't algo trade |
| moondev.com `/docs` | 2026-01-08 | **substantive** | Complete free API reference: Hyperliquid Data Layer (ticks, liquidations, smart-money, order flow). API key gated, docs not |
| moondev.com `/calculators` | 2026-04-21 | **substantive** | Free fee/ROI calculators teaching fee drag quantitatively (market 0.045% vs limit 0.001%; "fee blow-up date"). Genuinely educational |
| moondev.com `/roadmap` | 2026-02-09 | **gated** | JS shell only; embedded meta: "curated roadmap of trading videos, strategy ideas, backtested systems." Delivered by email newsletter, free but not archived |
| moondev.com `/backtests` | 2026-04-21 | **unrecoverable** | Client-rendered Next.js; no static content in capture |
| moondev.com 2008–2011 blog | 2011-07-03 | **unrelated** | Prior domain owner: "Cash Cow jumps over the Moon" — AdSense/MTurk/MMO-game make-money blog. Zero connection to trading Moon Dev |

## Recovered: the bootcamp curriculum (the artifact)

### 2025 state — 32 days (`/2025-update-1`, captured 2025-09-03)

Days 1–15 (core, ~9 hrs total): 1 Intro to algo trading + Python (3h) · 2 setup/packages walkthrough (49m) · 3 risk management (11m) · 4 algo orders (23m) · 5 automated risk systems (29m) · 6–9 SMA/RSI/VWAP/VWMA indicators (6–8m each) · 10 Bot 1: SMA+orderbook (11m) · 11 Bot 2: breakout (5m) · 12 Bot 3: engulfing (7m) · **13 backtesting + "RBI system" (2.9h)** · 14 ML in trading (10m) · 15 scaling/finding strategies (29m).
Events: DYDX "Goblin" bot (63m) · Funding-rate algo backtest (19m).
Days 16–32 (monthly updates): strategy-finding system · talib + gap-up backtest · breakout + liquidations/funding/OI bot · cloud deployment · mean-reversion backtest+bot · liquidation bot backtest · **monte-carlo + alpha-decay robustness** · seasonality/multi-dataset · liquidations+SMA · Solana onchain buys/sells · Solana price-trigger bot · Solana new-token scanner via RPC · X/Twitter sentiment bots · **genetic algorithms + grammatical evolution for strategy generation** · AI-credits arbitrage · 2 data sources · free stock/futures/forex data.

Pricing (2025): $69/mo or $295 lifetime (claimed $420); $149 add-on bundle = Polymarket prediction bot + Solana sniper + Solana copy-bot courses. Perks: Discord code-help, "unlimited AI" (shared OpenAI/Anthropic access via Discord), monthly updates.

### 2022 state — 6-week agenda (`/learnnow`, captured 2022-11-29)

Weeks 1–2 foundation: intro, coding basics, algo basics, orders, risk mgmt, SMA/RSI/VWMA/VWAP, "Back Testing Mastery". Weeks 3–4: **14 bots** — Reversion, Trending, Breakout, Correlation, Engulfing, Scalping, Turtle, Capitulation, PnL, Pop, TradingView, SMA, Orderbook, "Fee Skipper". Weeks 5–6: done-for-you — "we code 1 bot for you (based on your strategy)".

### The 7 flagship algos (`/bootcamp`, captured 2023-01-16)

Turtle Trending (55-period trend) · Order Book Stalking (any timeframe, documented) · Engulfing (candle-pattern entry) · Breakout · Correlation (BTC/ETH divergence) · +Bonus Mean Reversion (74 symbols simultaneously) · Market Maker (long/short, any market).

> **Cross-check:** the Dec-2025 Software-Heritage snapshot ([[snapshot-survey]]) already catalogues 56 agents and rates the backtest honesty "naive/overfit-prone". The curriculum's *topics* (monte-carlo, alpha decay, walk-forward-ish "RBI") are better than the code's execution — consistent with MIXED.

## Recovered: the free layer (usable now, no paywall)

1. **Hyperliquid Data Layer API docs** — `moondev.com/docs` (captured 2026-01-08): base `https://api.moondev.com`, 60 req/s; endpoints for ticks (BTC/ETH/HYPE/SOL/XRP, 500ms), liquidations (10m→30d windows), smart-money rankings/signals (top/bottom 100 by PnL, 3,488 tracked addresses), order flow + buy/sell imbalance, whale positions, decoded Hyperliquid L1 events, contract registry. Key required; docs + endpoint list free. → this is the data layer for any future paper-trading agent we build; connects to `~/Projects` Hyperliquid-Data-Layer-API clone ([[repos]]).
2. **Fee/ROI calculators** — `moondev.com/calculators` (captured 2026-04-21): interactive fee-drag demo (40x leverage × 5 market-order trades/day at 0.045% → account "99% gone in 31 days"; limit orders cut 97.5%). The single best free intuition-builder for why execution costs dominate — pairs with [[Kelly Criterion — Position Sizing]] and the friction confound in [[the-alpha-illusion]].
3. **The anti-hype manifesto** — `moondev.com` homepage (captured 2024-08-25), verbatim core: *"no one is going to give you a profitable bot · please stop buying bots on the internet · if everyone ran the same bot, the profits would converge to 0 · ai can not code for you but can make you way more efficient · algo trading is not about getting rich fast, it's about building non-correlated low risk automated trading systems."* This independently matches the academic verdict ([[the-alpha-illusion]] P1, [[ktd-fin]]: selection alpha negative in 9/10).
4. **Free roadmap via newsletter** — the 2025 page offers "the roadmap & resources for free, no purchase necessary" for an email. Not archivable (email-delivered); deprioritized — our [[learning-path]] + [[curriculum-draft]] already supersede it.
5. YouTube daily livestreams + the public `github.com/moondevonyt` — referenced from every page; the actual free corpus. (Transcript harvest remains a separate Scout job per [[Moon Dev — Research Brief & Leads]] §3.)

## Red flags (evidence, not vibes)

- **Placeholder testimonials** on the 2022 blog pages: "Amanda Souzanne — MarketingCompany.com", "George Matthew — SEOMox.com" — unmodified ClickFunnels template copy.
- **Refund trap (2023):** "The only thing that will void the refund policy is if you open the code folder… we've had many people steal it, then refund." (By 2025 this became a clean 90-day guarantee — improvement.)
- **Perpetual urgency (2025 page):** simultaneous "CLOSING FOREVER" countdown + 4th-of-July + Cyber Monday + Halloween + BOGO banners stacked on one page; "only allowing 100 members" since at least 2022.
- **The 100day scheme** (2023): same LLC sold a $7/mo "make $100/day with AI, no product, faceless videos" program to the make-money-online crowd — the exact FOMO product our hard rule #2 exists to filter.
- **Domain provenance:** moondev.com in 2008–2011 was an AdSense "make money online" blog ("Cash Cow jumps over the Moon"). No continuity — but the domain's history rhymes with the 100day product.

## What could NOT be recovered (clean negatives)

- Members-area video content — never public; only titles/durations leaked via sales pages (captured above).
- `/roadmap` and `/backtests` — client-rendered or email-gated; static captures empty.
- The 2023 ChatGPT plugin (`/.well-known/ai-plugin.json`) — a 302 to the sales funnel; no plugin existed.
- `moondev.com/live`, `/funding`, `/hyperliquid`, `/polymarket` pages exist in the archive but are JS shells; their substance is the API docs + YouTube, already covered.

## Actions seeded (for the queue, not done here)

- **[Scout]** YouTube transcript harvest of the free daily streams — the actual free curriculum; pair transcript topics against the 32-day list above to measure what the paywall adds (hypothesis: mostly convenience + Discord, per his own "everything I know is on youtube").
- **[Quant]** Stand up the moondev API free tier (key request) → evaluate smart-money/liquidation feeds as *data*, never as signal; paper-only ([[ledger]]).
- **[Critic]** Pass this note's two "substantive" moondev verdicts before any wiki promotion (Z2 gate).
