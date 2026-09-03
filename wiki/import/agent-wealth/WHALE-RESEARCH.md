# Whale Research Framework

How to find and track smart money wallets on Base chain.

---

## Methods to Find Whales

### 1. DEX Transaction Analysis
- Monitor large swaps (> $50k) on Uniswap, Aerodrome, etc.
- Track wallets that consistently profit from their trades
- Look for wallets that buy before major pumps

**Tools:**
- DEXScreener.com → Base chain → "Top Movers" → click trades → see wallet addresses
- Etherscan.io (Base network) → Top Transactions → filter by value

### 2. Protocol Leaders
- Check top liquidity providers on major DEXs
- Check top lenders/borrowers on Aave, Compound, Morpho
- These wallets understand DeFi deeply

**Tools:**
- DeFiLlama.com → Base chain → protocols → "Leaders" tab
- Aave.com → governance → see large voters

### 3. NFT Flippers
- Track wallets that profit from NFT flips
- They have good market timing skills

**Tools:**
- OpenSea → top traders → filter by Base chain
- NFTGo.io → whale tracker

### 4. Known Smart Money
Some known categories of profitable wallets:
- Fund wallets (Wintermute, Jump, etc.)
- Venture capital wallets
- Successful traders' public wallets

**Research:**
- Look up "Base chain top wallets" on DeBank
- Check "Smart Money" filters on DEXScreener

---

## What Makes a Good Whale to Copy

✅ **Track these:**
- Consistent profits (>60% win rate)
- Active trader (multiple trades per week)
- Trades similar size to our capital
- Not an insider/dev wallet
- Has been profitable over 3+ months

❌ **Avoid these:**
- One-time lucky trades
- Insiders/devs (they have inside info)
- Market makers (they hedge, not directional)
- Wash traders (fake volume)

---

## Our Copy Trading Strategy

Once we identify whales:

1. **Monitor:** Agent watches their wallets 24/7
2. **Detect:** When they buy/sell → agent knows instantly
3. **Copy:** Agent buys same token within seconds
4. **Manage:** Agent sets stop-loss, takes profits

**Position sizing:**
- Never risk >5% of portfolio on one whale trade
- Start small ($50-100 per trade)
- Scale up as we prove profitability

---

## Python Script to Find Whales

See `find_whales.py` in this directory — it scans public data to find whale wallets.

---

## Next Steps

1. Run `find_whales.py` to identify candidates
2. Manually verify their track record (DeBank, Etherscan)
3. Add confirmed whales to tracking list
4. Deploy whale tracker agent to monitor them 24/7
