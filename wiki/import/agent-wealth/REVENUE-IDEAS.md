# Revenue Ideas for AI Crypto Agents

Concrete, specific ways our AgentKit-powered agents can make money. Ranked by feasibility → revenue potential.

---

## 🟢 Tier 1: Easy to Build, Start Fast

### 1. Whale Copy Trading Bot
**What:** Track wallets that consistently win. When they buy, we buy. When they sell, we sell.

**How:**
- AgentKit wallet watches specific whale addresses
- Detects their swap transactions in real-time
- Copies trades within seconds (same token, similar amount)

**Revenue:** If whale makes 20%, we make ~18% (slippage/gas). Scale with more capital.

**Build status:** ⏳ Scaffolded, needs deployment

**Tools needed:**
- CDP API for transaction monitoring
- AgentKit swap actions
- Pyth for price verification

---

### 2. Yield Optimization Bot
**What:** Never let funds sit idle. Constantly move to highest APY.

**How:**
- Agent checks APYs across: Aave, Compound, Morpho, Moonwell, Hyperbolic
- When one protocol offers better rate, agent moves funds automatically
- Compounds interest automatically

**Revenue:** 5-15% APY on idle capital. With $10k deployed = $500-1500/month passive.

**Build status:** ⏳ Ready to build

**Tools needed:**
- AgentKit lending/borrowing actions
- DefiLlama API for APY data
- Auto-compounding logic

---

### 3. Paid Alpha Signals (Farcaster)
**What:** Post trading signals on Farcaster. Charge for premium access.

**How:**
- Agent scans for opportunities (whale buys, new listings, volume spikes)
- Posts free basic signals publicly
- Premium subscribers get signals 5-10 minutes earlier + higher conviction plays
- Payment via x402 (AgentKit supports micropayments)

**Revenue:** 50 subscribers × $30/month = $1500/month. 500 subscribers = $15k/month.

**Build status:** ⏳ Alpha scanner exists, needs Farcaster integration

**Tools needed:**
- Farcaster action provider (AgentKit has it)
- x402 for payments
- Content generation (AI writes signals)

---

### 4. Protocol Referral Income
**What:** Earn fees from every protocol our agent uses.

**How:**
- Every swap, lend, borrow, mint through AgentKit can use referral codes
- Protocols pay 10-50% of generated fees

**Protocols that pay:**
- Aave: referral program
- Uniswap: builder incentives
- Most DeFi protocols have affiliate programs

**Revenue:** Passive. If agent does $100k in swaps/month at 0.3% fee = $300 in fees → we earn ~$100-150/month passively.

**Build status:** ✅ Built into AgentKit, just configure

---

## 🟡 Tier 2: More Complex, Higher Revenue

### 5. DEX Arbitrage Bot
**What:** Buy token on DEX A where it's cheap, sell on DEX B where it's expensive.

**How:**
- Agent monitors prices across Uniswap, Aerodrome, SushiSwap on Base
- Finds price discrepancies > gas cost
- Executes arbitrage instantly

**Revenue:** Base has cheap gas (~$0.01 per tx). Even 0.5% price diff is profitable. Do this 100x/day = compounding.

**Build status:** ⏳ Needs implementation

**Tools needed:**
- Multi-DEX price monitoring
- Fast execution (sub-second)
- Slippage management

---

### 6. NFT Flip Bot
**What:** Buy undervalued NFTs, sell when price rises.

**How:**
- Agent monitors NFT listings on OpenSea, MagicEden, etc.
- Finds NFTs listed below floor price or undervalued
- Buys instantly, sells when profitable

**Revenue:** 5-20% profit per flip. Scale with capital.

**Build status:** ⏳ AgentKit has ERC721 + OpenSea support

**Tools needed:**
- Price oracle for NFT collections
- Fast listing detection
- Collection whitelisting (only flip blue-chip)

---

### 7. New Token Launch Sniper
**What:** Buy tokens the moment they launch on DEXs.

**How:**
- Agent watches for new liquidity pool creations
- Buys immediately when pool is created
- Sells after price appreciation (minutes to hours)

**Revenue:** High risk, high reward. Can make 2-10x on good tokens.

**Build status:** ⏳ Needs implementation

**Risk:** Rug pulls, honeypots. Agent needs safety checks.

---

## 🔴 Tier 3: Advanced, Maximum Revenue

### 8. MEV Bot (Maximal Extractable Value)
**What:** Capture value from transaction ordering on-chain.

**How:**
- Detect pending profitable transactions in mempool
- Front-run, back-run, or sandwich trades
- Profit from price impact

**Revenue:** Professional MEV bots make $10k-$100k+/day. We'd be smaller but still profitable.

**Build status:** ❌ Complex, needs specialized infrastructure

**Tools needed:**
- Flashbots or similar
- Custom mempool monitoring
- Advanced smart contracts

---

### 9. Multi-Agent Trading Firm
**What:** Run multiple specialized agents as a trading operation.

**Agents:**
- Research agent: finds opportunities
- Trading agent: executes
- Risk agent: manages position sizes, stop-losses
- Social agent: builds audience for capital attraction

**Revenue:** Combined effect of all strategies above, plus:
- Attract outside capital (people fund our agents)
- Take 20% performance fee on their capital

**Build status:** ⏳ Architecture planned

---

### 10. Agent-as-a-Service Infrastructure
**What:** Let others use our agent infrastructure.

**How:**
- Build a platform where users connect wallets
- Our agents manage their funds (trading, yield, etc.)
- We take 10-20% of profits

**Revenue:** Scale to thousands of users. If each user has $1k and we make 10% APY → we take 20% = $20/user/year. 1000 users = $20k/year passive.

**Build status:** ❌ Needs full product build

---

## 🚀 What We Should Do Right Now (Priority Order)

1. **Whale Copy Trading Bot** → Fast to build, proven strategy, low capital needed
2. **Yield Optimizer** → Passive income on any funds, compound growth
3. **Paid Alpha Signals** → Builds audience AND revenue, no capital needed
4. **Protocol Referrals** → Free money, just configure
5. **Arbitrage Bot** → Base cheap gas makes this viable

---

## The Compound Effect

| Month | Capital | Strategy | Monthly Revenue |
|-------|---------|----------|----------------|
| 1 | $0 | Alpha signals only | $100-300 |
| 2 | $500 | Signals + yield on earnings | $200-500 |
| 3 | $2000 | + whale copy trading | $500-1500 |
| 6 | $10000 | + arbitrage, all strategies | $2000-5000 |
| 12 | $50000 | Multi-agent, AaA infrastructure | $5000-15000 |

**The key: start with $0 information plays, let revenue fund capital deployment.**
