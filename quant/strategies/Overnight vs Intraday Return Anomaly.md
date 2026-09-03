---
title: Overnight vs Intraday Return Anomaly
type: strategy-hypothesis
category: mean-reversion
status: proposed
data-source: yfinance + ccxt
priority: medium
edge: "Equity returns accrue overnight (gap), intraday is flat/negative; in crypto, session/funding-time effects create mean-reversion windows."
decay: "Medium — the equity overnight drift is well-known; intraday execution is the constraint. Crypto session effects less studied."
tags: [quant/strategy, quant/mean-reversion, quant/microstructure]
created: 2026-07-23
---

# Overnight vs Intraday Return Anomaly

## Source
- **Aboody, Lev & Shi (2018)** "Overnight Returns and Firm-Specific Investor Sentiment"; **Bogousslavsky (2016)** on overnight vs intraday risk premia.
- Practitioner lore: "the overnight move is the real move"; intraday is noise/liquidity provision.
- Crypto: funding-rate settlement times (every 8h) and US/EU session flows create predictable intraday patterns.

## Hypothesis
Two related sub-hypotheses:
1. **Equities:** the bulk of the long-run equity premium and momentum accrues in the overnight (close-to-open) segment; intraday (open-to-close) averages ~0 or negative. A strategy that holds overnight and is flat intraday captures the premium with less intraday noise.
2. **Crypto:** returns mean-revert around funding-settlement times and around the US cash open; fading extreme post-settlement moves earns a small edge.

## Expected edge & decay
- **Edge:** overnight = informed/sentiment repricing; intraday = liquidity-provision/noise. Crypto: mechanical funding flows + session liquidity.
- **Magnitude:** equity overnight premium a few %/yr; intraday reversal small and cost-limited.
- **Decay:** medium — overnight drift is documented (hard to exploit without holding inventory overnight); crypto session effects fresher but tiny per-trade.

## Data needed (FREE)
- Equities: daily OHLC with open & close (yfinance provides) → decompose close-to-open vs open-to-close.
- Crypto: hourly OHLCV via ccxt aligned to UTC funding times (00/08/16 UTC) and US open (13:30/14:30 UTC).

## Test design
1. **Equity decomposition:** for SPY/QQQ and large caps, compute cumulative overnight vs intraday returns over 10+ years; t-test the difference.
2. **Overnight strategy:** hold close→open, flat otherwise; compare Sharpe to buy-and-hold; account for gap risk (DD).
3. **Crypto session test:** bucket hourly returns by hour-of-day and by distance-to-funding; test for significant mean reversion in the 1–2h after settlement.
4. **Signal:** fade top/bottom-decile post-settlement 1h moves, hold 1–4h.
5. **Costs:** crypto taker fees + slippage dominate — run at 5–10 bps; edge must survive.
6. **Metrics:** per-bucket mean/t-stat, net Sharpe, turnover.
7. **Robustness:** multiple exchanges (confirm not venue artifact); timezone/DST handling for US open.

## Failure modes / risks
- Equity overnight edge requires bearing gap risk (not free lunch).
- Crypto intraday edges are sub-bps — easily eaten by fees/latency; likely only viable with maker rebates.
- Timezone/DST misalignment can create spurious session effects → validate carefully.

## Links
- [[Avellaneda-Stoikov Crypto Market-Making]] — natural home for intraday edges
- [[Short-Term Reversal (1-Month)]]
- [[Crypto Funding-Rate Carry]]
- [[Strategies Index]]
