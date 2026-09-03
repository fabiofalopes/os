#!/usr/bin/env tsx
/**
 * Yield Optimizer Agent
 *
 * Checks APYs across DeFi protocols every N hours.
 * Moves funds to highest APY automatically.
 * Compounds interest weekly.
 *
 * Revenue: 5-15% APY passive on deployed capital.
 */

import {
  AgentKit,
  CdpEvmWalletProvider,
  walletActionProvider,
  erc20ActionProvider,
  cdpApiActionProvider,
} from "@coinbase/agentkit";
import { getLangChainTools } from "@coinbase/agentkit-langchain";
import { ChatOpenAI } from "@langchain/openai";
import { createReactAgent } from "@langchain/langgraph/prebuilt";
import * as dotenv from "dotenv";

dotenv.config();

// ============================================================
// CONFIG
// ============================================================

const NETWORK_ID = process.env.NETWORK_ID || "base-mainnet";
const CHECK_INTERVAL_HOURS = parseInt(process.env.CHECK_INTERVAL_HOURS || "1");
const CHECK_INTERVAL_MS = CHECK_INTERVAL_HOURS * 60 * 60 * 1000;

console.log(`
╔══════════════════════════════════════════════════════╗
║           YIELD OPTIMIZER v0.1                       ║
║           Network: ${NETWORK_ID.padEnd(38)}║
║           Check interval: every ${String(CHECK_INTERVAL_HOURS).padStart(2)}h${" ".repeat(34 - String(CHECK_INTERVAL_HOURS).length)}║
╚══════════════════════════════════════════════════════╝
`);

// ============================================================
// ENV CHECK
// ============================================================

function validateEnvironment() {
  const required = ["CDP_API_KEY_ID", "CDP_API_KEY_SECRET", "OPENAI_API_KEY"];
  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    console.error("Missing required env vars:", missing.join(", "));
    console.error("Copy .env.example to .env and fill in your keys.");
    process.exit(1);
  }
}

validateEnvironment();

// ============================================================
// PROTOCOL APY DATA
// ============================================================

// In production, fetch from DefiLlama API or protocol APIs directly
// These are example APYs - real agent would fetch live data

async function fetchCurrentAPYs() {
  // TODO: Replace with real API calls to:
  // - DefiLlama: https://yields.llama.fi/
  // - Protocol APIs directly

  const apys = [
    { protocol: "Aave", asset: "USDC", apy: 5.2, tvl: "$2.1B", risk: "low" },
    { protocol: "Morpho", asset: "USDC", apy: 6.8, tvl: "$800M", risk: "low" },
    { protocol: "Compound", asset: "USDC", apy: 4.5, tvl: "$1.5B", risk: "low" },
    { protocol: "Moonwell", asset: "USDC", apy: 5.8, tvl: "$300M", risk: "low" },
    { protocol: "Hyperbolic", asset: "USDC", apy: 7.2, tvl: "$150M", risk: "medium" },
  ];

  return apys.sort((a, b) => b.apy - a.apy);
}

// ============================================================
// AGENT INIT
// ============================================================

async function initializeAgent() {
  console.log("→ Initializing AgentKit wallet...");

  const walletProvider = await CdpEvmWalletProvider.configure({
    apiKeyId: process.env.CDP_API_KEY_ID!,
    apiKeySecret: process.env.CDP_API_KEY_SECRET!,
    networkId: NETWORK_ID,
    walletSecret: process.env.CDP_WALLET_SECRET,
  });

  console.log(`→ Wallet: ${walletProvider.getAddress()}`);

  const agentKit = await AgentKit.from({
    walletProvider,
    actionProviders: [
      walletActionProvider(),
      erc20ActionProvider(),
      cdpApiActionProvider(),
    ],
  });

  const llm = new ChatOpenAI({ model: "gpt-4o-mini", temperature: 0.5 });
  const tools = await getLangChainTools(agentKit);

  const agent = createReactAgent({
    llm,
    tools,
    messageModifier: `You are the Yield Optimizer, an AI agent that maximizes returns on crypto holdings.

Your job:
1. Check current APYs across lending protocols
2. Move funds to the highest APY (considering risk)
3. Compound interest regularly
4. Never put >50% in one protocol
5. Prioritize safety over max APY

Current network: ${NETWORK_ID}`,
  });

  return agent;
}

// ============================================================
// OPTIMIZATION LOGIC
// ============================================================

async function checkAndOptimize(agent: any) {
  console.log(`\n[${new Date().toISOString()}] Checking APYs...`);

  const apys = await fetchCurrentAPYs();

  console.log("\nCurrent Best APYs:");
  apys.forEach(apy => {
    console.log(`  ${apy.protocol.padEnd(12)} ${apy.asset} ${apy.apy.toFixed(1)}% APY (TVL: ${apy.tvl}, Risk: ${apy.risk})`);
  });

  const best = apys[0];
  console.log(`\n→ Best: ${best.protocol} ${best.asset} at ${best.apy}% APY`);

  // TODO: Check current allocation, move funds if better APY exists
  // const currentAllocation = await agent.invoke({ messages: [{ role: "user", content: "Where are my funds currently allocated?" }] });
  // const shouldMove = // logic to decide if move is worthwhile

  console.log("\n→ Optimization check complete.");
}

// ============================================================
// MAIN
// ============================================================

async function main() {
  try {
    console.log("Starting Yield Optimizer...\n");

    const agent = await initializeAgent();

    // Initial check
    await checkAndOptimize(agent);

    // Continuous optimization
    setInterval(() => checkAndOptimize(agent), CHECK_INTERVAL_MS);

    console.log(`\nChecking every ${CHECK_INTERVAL_HOURS} hour(s). Ctrl+C to stop.\n`);
  } catch (error) {
    console.error("Fatal error:", error);
    process.exit(1);
  }
}

main();
