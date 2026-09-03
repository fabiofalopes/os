# Agent Wealth Roadmap: $0 → Real Money

This is the exact path from nothing to a self-compounding onchain wealth machine.

---

## Phase 0: Setup (Cost: $0, Time: 30 min)

**What you get:** Your AI agent now has a crypto wallet and can execute onchain.

Steps:
1. Register at https://cloud.coinbase.com (free account)
2. Create API key pair → get `CDP_API_KEY_ID` + `CDP_API_KEY_SECRET`
3. Get OpenAI API key (free tier or pay-as-you-go)
4. Point alpha-scanner to Base Sepolia testnet (free, fake funds)
5. Run agent, verify it works

**Status:** ✅ AgentKit installed. ⏳ Need your CDP keys.

---

## Phase 1: Information → Attention (Cost: $0-5, Time: 1-2 weeks)

**Goal:** Make your agent famous for finding alpha.

### What to build:
The alpha-scanner already exists. Now make it actually find valuable things:

1. **Whale tracker**: Monitor top 100 wallets by volume. Alert when they buy.
2. **New listing scanner**: Track tokens added to Uniswap/Base DEXs in last 24h.
3. **Volume anomaly detector**: Tokens with 10x normal volume = something happening.
4. **Liquidity change monitor**: Big liquidity adds = confidence signal.

### How to distribute:
1. Connect to Farcaster (AgentKit has native support)
2. Agent posts signals automatically every scan
3. Format: "🐋 [0xABC] just bought 50k $XYZ. Price +12% since."
4. Do this 24/7. Humans can't compete with AI uptime.

### Result:
People start following your agent. Your agent becomes a trusted alpha source.

---

## Phase 2: Attention → Revenue (Time: 2-4 weeks)

**Goal:** Turn audience into money flowing into agent's wallet.

### Revenue streams:

#### Stream 1: Paid Signals (Easiest)
- Free tier: basic signals on public feed
- Paid tier ($20-50/month USDC): earlier signals, higher conviction plays
- Agent auto-manages subscriptions via x402 (AgentKit supports this)

#### Stream 2: Protocol Referrals
Every protocol AgentKit integrates with pays you:
- Aave, Compound, Morpho: % of lending/borrowing fees you refer
- Uniswap, Jupiter: % of swap fees
- NFT mints: protocol pays you per referred mint

**You don't even try. Your agent just uses normal protocols → you earn passively.**

#### Stream 3: Bounties
- Monitor protocol bounties (Immunefi, Gitcoin)
- Agent scans for bugs, submits reports
- Payouts: $1k-$1M depending on severity

#### Stream 4: Service Agent
- Let people pay agent to execute tasks for them:
  - "Swap 100 USDC to ETH on Base" → agent does it, charges 1%
  - "Check best yield for my tokens" → agent researches, charges 5 USDC
  - Agent is a crypto concierge, working 24/7

### Result:
Agent's wallet starts accumulating real funds. Maybe $100-$1000/month initially.

---

## Phase 3: Revenue → Capital Deployment (Time: 1-3 months)

**Goal:** Agent now trades its own signals and compounds earnings.

### What changes:
Agent goes from just *finding* opportunities to *exploiting* them:

1. **Auto-trade**: Agent sees a whale buy → agent also buys immediately
2. **Auto-yield**: Idle USDC goes to Aave/Morpho earning 5-15% APY automatically
3. **Auto-arbitrage**: Price diff between DEXs? Agent swaps instantly
4. **Auto-compound**: Earnings reinvested, never withdrawn

### AgentKit enables this:
- `walletActionProvider()` → check balances, manage funds
- `erc20ActionProvider()` → transfer tokens, interact with DeFi
- `wethActionProvider()` → wrap/unwrap ETH for DeFi
- `cdpApiActionProvider()` → swap tokens via Coinbase infrastructure
- `pythActionProvider()` → real-time price feeds for decisions

### Result:
Agent becomes a self-driving trading bot. Capital compounds 24/7.

---

## Phase 4: Scale → Infrastructure (Time: 3-12 months)

**Goal:** Turn single agent into multi-agent wealth machine.

### Build specialized agents:

| Agent | Role | Revenue |
|-------|------|---------|
| Scanner | Finds opportunities | Drives all others |
| Trader | Executes on opportunities | Profit from trades |
| Yield Optimizer | Deploys idle capital | APY from lending |
| Risk Manager | Protects capital | Prevents losses |
| Social | Builds audience | Drives subscribers |
| Service | Helps others | Service fees |

### How they work together:
1. Scanner finds whale buying $XYZ
2. Trader buys $XYZ immediately
3. Yield optimizer puts idle USDC to work
4. Risk manager sets stop-loss
5. Social posts signal (attracts subscribers)
6. Service agent lets subscribers copy-trade

### Infrastructure play:
Package this as a product:
- Others connect their wallets
- Your agents manage their capital
- You take 10-20% performance fee
- Scale to thousands of users

### Result:
You own an autonomous wealth generation infrastructure. It works while you sleep.

---

## The Math

| Phase | Capital | Monthly | Run Rate |
|-------|---------|---------|----------|
| 1 | $0 | $0 | Building audience |
| 2 | $0 | $100-500 | Signals + referrals |
| 3 | $1k | $200-1000 | Trading + yield |
| 4 | $10k | $2k-10k | Multi-agent + users |
| 5 | $100k | $10k-50k | Infrastructure at scale |

**The key: each phase funds the next. You never need outside capital.**

---

## Right Now: What To Do

1. **Get CDP keys** → https://cloud.coinbase.com (5 min)
2. **Run alpha-scanner on testnet** → verify it works (10 min)
3. **Switch to mainnet** → fund with $5 gas (2 min)
4. **Start scanning** → let it find its first alpha (ongoing)
5. **Connect Farcaster** → start posting signals (1 week)

Everything else compounds from there.
