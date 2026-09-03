# Revenue Strategies — Detailed Plans

Each strategy: what it is, how it works, revenue math, build steps, risk level.

---

## Strategy 1: Paid Alpha Signals via Farcaster

### What
AI agent posts crypto trading signals on Farcaster 24/7. Free basic signals + paid premium tier.

### How It Works
1. Alpha Scanner agent monitors onchain (whales, new tokens, volume spikes)
2. Posts free signals every 30 min → builds audience
3. Premium subscribers ($29/month USDC) get:
   - Signals 5-10 minutes earlier
   - Higher conviction plays only
   - Entry/exit prices + risk analysis

### Revenue Math
- 50 followers → 5 paying = $145/month
- 200 followers → 20 paying = $580/month
- 1000 followers → 100 paying = $2,900/month
- 5000 followers → 500 paying = $14,500/month

### Costs
- CDP API: free tier
- OpenAI API: ~$5-20/month for signal generation
- Gas for posting: ~$1-5/month on Base
- **Total: ~$10-25/month**

### Build Steps
1. ✅ Alpha scanner agent (done)
2. ⏳ Farcaster integration (AgentKit has it)
3. ⏳ x402 micropayments for subscriptions
4. ⏳ Premium signal tier logic

### Risk: LOW
- No capital at risk
- Only time + minimal API costs
- Revenue scales with audience

---

## Strategy 2: Whale Copy Trading on Base

### What
Track profitable whale wallets. When they buy/sell, we copy instantly.

### How It Works
1. Identify whales: wallets with consistent wins (use DeBank/Zerion data)
2. Whale Tracker agent monitors their wallets 24/7
3. When whale buys token X → agent buys same token within seconds
4. When whale sells → agent sells
5. Position sizing: never risk >5% of portfolio on one trade

### Revenue Math (starting with $500)
- Whale makes 15% average per trade
- We make ~13% (slippage/gas)
- 4 trades/month = 52% monthly return
- $500 → $760/month (+$260)
- Reinvest profits → compound

### Whale Targets (Base chain)
Need to research and identify. Look for:
- Wallets with >$1M balance
- Consistent winners (>60% win rate)
- Active traders (multiple trades/day)
- NOT insiders/dev wallets

### Costs
- Gas on Base: ~$0.01 per tx (very cheap)
- Monitoring: free via public RPC
- **Total: ~$1-5/month**

### Build Steps
1. ⏳ Whale Tracker agent (scaffolded)
2. ⏳ Whale identification research
3. ⏳ Copy trade execution logic
4. ⏳ Risk management (position limits, stop-loss)

### Risk: MEDIUM-HIGH
- Can lose money if whale loses
- Slippage on fast-moving tokens
- Need to filter out bad whales
- **Mitigation:** Start small ($50-100), diversify across 3-5 whales

---

## Strategy 3: Yield Optimization Bot

### What
Never let funds sit idle. Auto-move to highest APY across protocols.

### How It Works
1. Agent checks APYs every hour across: Aave, Compound, Morpho, Moonwell
2. When Protocol A offers better rate than Protocol B → move funds
3. Auto-compound interest weekly
4. Stay diversified (never put >50% in one protocol)

### Revenue Math (starting with $1000)
- Average APY: 8-15% depending on asset
- $1000 USDC → $80-150/year passive
- With compounding: ~10% effective → $1050 after 1 year
- Scale: $10k → $1000-1500/year passive

### Costs
- Gas for moving funds: ~$0.05-0.10 per move on Base
- Maybe 4 moves/month = ~$0.40/month
- **Total: ~$1/month**

### Build Steps
1. ⏳ Yield Optimizer agent (task created)
2. ⏳ APY monitoring across protocols
3. ⏳ Auto-transfer logic
4. ⏳ Compounding schedule

### Risk: LOW-MEDIUM
- Smart contract risk (use only major protocols)
- APY can change suddenly
- **Mitigation:** Stick to Aave, Compound, Morpho (battle-tested)

---

## Strategy 4: Protocol Referral Income (FREE MONEY)

### What
Earn fees from every DeFi action our agents take through referral programs.

### How It Works
1. Sign up for referral programs of protocols we use
2. All agent transactions go through our referral links
3. Earn 10-50% of fees generated

### Protocols & Rates
- Aave: ~10% of lending/borrowing fees
- Uniswap builders: various incentive programs
- Coinbase: referral bonuses
- Most DeFi protocols have affiliate programs

### Revenue Math
If agent does $50k in swaps/month at 0.3% fee:
- Fees generated: $150
- Our cut (20%): $30/month passive
Scale to $200k/month volume = $120/month

### Costs: $0

### Build Steps
1. ⏳ Sign up for referral programs
2. ⏳ Configure agents to use referral codes
3. ✅ Done — passive forever

### Risk: NONE
- Pure upside, no downside
- Just configure and forget

---

## Strategy 5: Arbitrage Scanner on Base

### What
Find price differences between DEXs. Buy low on one, sell high on another.

### How It Works
1. Agent monitors prices across Uniswap, Aerodrome, SushiSwap on Base
2. When Token X is 1% cheaper on Uniswap than Aerodrome → arbitrage
3. Buy on Uniswap, sell on Aerodrome instantly
4. Profit = price difference minus gas

### Why Base is Perfect
- Gas: ~$0.01 per transaction
- Even 0.5% price diff = profitable
- Fast block times = quick execution

### Revenue Math (starting with $1000)
- Find 2-5 arb opportunities per day
- Average profit: 0.5% per arb
- 3 arbs/day × 0.5% = 1.5%/day
- Monthly: ~45% return (before compounding)
- $1000 → $1450/month (+$450)

### Costs
- Gas: ~$0.02 per arb (2 tx)
- 90 arbs/month = ~$1.80
- **Total: ~$2-5/month**

### Build Steps
1. ⏳ Price monitoring across DEXs
2. ⏳ Arb detection logic
3. ⏳ Fast execution (sub-second)
4. ⏳ Slippage protection

### Risk: MEDIUM
- Prices can move against us during execution
- Need fast execution
- **Mitigation:** Start small, only take clear opportunities (>1% diff)

---

## Strategy 6: Service Agent (Crypto Concierge)

### What
People pay our agent to do crypto tasks for them.

### Services Offered
- "Swap 100 USDC to ETH on Base" → agent does it, charges 1%
- "Check best yield for my tokens" → agent researches, charges $2
- "Monitor this wallet and alert me" → agent watches, charges $5/month
- "What tokens does this whale hold?" → agent checks, charges $1

### Revenue Math
- 10 tasks/day at $2 average = $20/day = $600/month
- 50 tasks/day = $3000/month
- Scales with marketing

### Costs
- API costs: ~$5-10/month
- Gas: minimal (user pays)
- **Total: ~$10/month**

### Build Steps
1. ⏳ Service agent template
2. ⏳ Payment collection (x402 or direct USDC)
3. ⏳ Task execution logic
4. ⏳ Marketing on social

### Risk: LOW
- No capital at risk
- Service-based income
- **Challenge:** Need users/marketing

---

## Strategy 7: NFT Floor Sweep Bot

### What
Buy NFTs listed below floor price. Sell at floor or higher.

### How It Works
1. Agent monitors NFT marketplaces (OpenSea, MagicEden, etc.)
2. When NFT listed 10%+ below floor → buy instantly
3. Sell at floor price or hold if collection pumping

### Revenue Math
- Profit per flip: 5-20%
- 5 flips/month at $100 avg profit = $500/month
- Scale with more capital

### Costs
- Gas: minimal on Base
- **Total: ~$2-5/month**

### Build Steps
1. ⏳ NFT monitoring agent
2. ⏳ Floor price tracking
3. ⏳ Auto-buy/sell logic
4. ⏳ Collection whitelisting (only safe projects)

### Risk: MEDIUM-HIGH
- NFT markets are volatile
- Can get stuck with unsellable NFTs
- **Mitigation:** Only blue-chip collections, strict entry rules

---

## Recommended Launch Order

### Week 1-2: Zero Capital Start
1. ✅ Deploy Alpha Scanner (already built)
2. Start posting signals on Farcaster
3. Sign up for protocol referrals
4. **Goal:** Build 100 followers, first 5 paying subscribers

### Week 3-4: Small Capital ($50-100)
1. Deploy Whale Tracker (copy 1-2 whales)
2. Start Yield Optimizer on profits
3. **Goal:** $200-300 total capital

### Month 2: Scale
1. Add Arbitrage Scanner
2. More whales to copy
3. More capital in yield
4. **Goal:** $1000+ capital, $200-500/month revenue

### Month 3+: Compound
1. All strategies running
2. Reinvest profits
3. Add Service Agent
4. **Goal:** $5000+ capital, $1000-2000/month revenue

---

## Total Potential (12 months out)

| Strategy | Monthly Revenue |
|----------|----------------|
| Paid Signals (500 subs) | $14,500 |
| Whale Copy Trading ($10k) | $1,300 |
| Yield Optimization ($10k) | $80 |
| Protocol Referrals | $100-300 |
| Arbitrage ($5k) | $750 |
| Service Agent | $500-1000 |
| **Total** | **$17,230-17,730** |

Realistic conservative estimate: **$2000-5000/month within 6 months**

The key: START WITH ZERO, let each strategy fund the next.
