# Agent Wealth Engine

AI agents with crypto wallets that create value from $0 and scale to wealth.

## The Strategy

### Phase 0: Foundation (Free)
- CDP account + testnet wallet = zero cost entry
- Build and test agents on Base Sepolia
- **Current status:** AgentKit SDK installed

### Phase 1: Zero → First Revenue ($0 start)

**Core principle:** Information is free. Attention is valuable. Execution is rare.

**Agents:**
1. **[alpha-scanner](./alpha-scanner/)** - Scans onchain for opportunities
   - New token listings
   - Whale movements
   - Price discrepancies
   - Posts signals → builds audience → monetizes

2. **Social Agent (Farcaster/Twitter)** - Posts valuable analysis 24/7
   - Builds audience at scale
   - Paid subscriptions for premium signals

3. **Arbitrage Scanner** - Finds price differences across DEXs
   - Initially: sell signals to others
   - Later: execute when funded

**Revenue streams (no capital needed):**
- Paid alpha/signals via social platforms
- DeFi protocol affiliate programs (10-50% of referred fees)
- Service agents: people pay USDC for your agent to execute tasks
- Bounties and bug hunting

### Phase 2: Revenue → Automated Compounding
- Agent auto-deploys earned capital across DeFi
- Yield farming, liquidity provision, auto-compounding
- Runs 24/7, optimizing allocations
- No human intervention needed

### Phase 3: Multi-Agent System
- Specialized agents working in parallel:
  - Research → finds opportunities
  - Trading → executes
  - Risk → manages exposure
  - Social → builds audience
- Each agent compounds the others

### Phase 4: Infrastructure Play
- Package agent infrastructure as a service
- Others use your agents → you take a cut
- Exponential scaling

## Quick Start

```bash
# 1. Get CDP API keys (free)
# https://cloud.coinbase.com

# 2. Set environment
export CDP_API_KEY_ID="your_id"
export CDP_API_KEY_SECRET="your_secret"
export OPENAI_API_KEY="your_key"

# 3. Run alpha scanner (testnet first)
cd alpha-scanner
NETWORK_ID=base-sepolia npm run start
```

## Why This Works

- **AI never sleeps** → 24/7 opportunity scanning and execution
- **Onchain = permissionless** → no approval needed to start
- **Fee-free stablecoin payments** → users pay agents directly in USDC
- **Compounding is automatic** → agents reinvest earnings
- **Network effects** → each agent makes the others more valuable

## Stack

- [AgentKit](./agentkit/) - Coinbase's AI agent crypto toolkit
- Base/Solana - low-fee chains
- Farcaster/Twitter/XMTP - social integration
- Pyth - price oracles
- LangChain/LlamaIndex - AI frameworks
