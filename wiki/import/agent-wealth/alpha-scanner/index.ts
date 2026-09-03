#!/usr/bin/env tsx
/**
 * Alpha Scanner Agent
 *
 * An AI agent powered by AgentKit that scans onchain for profitable opportunities:
 * - Whale wallet movements (track smart money)
 * - New token listings on DEXs (catch early gems)
 * - Yield farming opportunities across protocols
 * - Arbitrage between DEXs
 * - NFT flip opportunities
 *
 * Phase 1: Generate signals → build audience → monetize attention
 * Phase 2: Use revenue to fund wallet → agent trades its own signals
 * Phase 3: Compound 24/7 → scale → infrastructure play
 */

import {
  AgentKit,
  CdpEvmWalletProvider,
  walletActionProvider,
  erc20ActionProvider,
  erc721ActionProvider,
  cdpApiActionProvider,
  wethActionProvider,
} from "@coinbase/agentkit";
import { getLangChainTools } from "@coinbase/agentkit-langchain";
import { ChatOpenAI } from "@langchain/openai";
import { createReactAgent } from "@langchain/langgraph/prebuilt";
import * as dotenv from "dotenv";

dotenv.config();

// ============================================================
// CONFIGURATION
// ============================================================

const NETWORK_ID = process.env.NETWORK_ID || "base-sepolia";
const SCAN_INTERVAL_MS = parseInt(process.env.SCAN_INTERVAL_MS || "300000"); // 5 min
const SINGLE_SCAN = process.argv.includes("--single-scan");

console.log(`
╔══════════════════════════════════════════════════════════╗
║           ALPHA SCANNER AGENT v0.1                       ║
║           Network: ${NETWORK_ID.padEnd(38)}║
${SINGLE_SCAN ? "║           Mode: SINGLE SCAN                              ║" : `║           Scan interval: ${String(SCAN_INTERVAL_MS / 1000).padStart(2)}s${" ".repeat(31 - String(SCAN_INTERVAL_MS / 1000).length)}║`}
╚══════════════════════════════════════════════════════════╝
`);

// ============================================================
// ENVIRONMENT VALIDATION
// ============================================================

function validateEnvironment() {
  const required = ["CDP_API_KEY_ID", "CDP_API_KEY_SECRET"];
  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    console.error("Missing required environment variables:");
    missing.forEach(key => console.error(`  ${key}`));
    console.error("\nCopy .env.example to .env and fill in your CDP keys.");
    console.error("CDP keys (FREE): https://cloud.coinbase.com");
    process.exit(1);
  }

  // LLM: uses PrimeIntellect via upb (no OpenAI key needed)
  // PRIME_INTELLECT_API_KEY should be in ~/.zshrc
  if (!process.env.PRIME_INTELLECT_API_KEY && !process.env.UPB_LLM_ENDPOINT) {
    console.warn("Warning: PRIME_INTELLECT_API_KEY not found in environment.");
    console.warn("Make sure it's set in ~/.zshrc (source ~/.zshrc if needed).");
    console.warn("Falling back to OPENAI_API_KEY if available...\n");
  }
}

validateEnvironment();

// ============================================================
// AGENT INITIALIZATION
// ============================================================

async function initializeAgent() {
  console.log("→ Initializing AgentKit wallet...");

  const walletProvider = await CdpEvmWalletProvider.configure({
    apiKeyId: process.env.CDP_API_KEY_ID!,
    apiKeySecret: process.env.CDP_API_KEY_SECRET!,
    networkId: NETWORK_ID,
    walletSecret: process.env.CDP_WALLET_SECRET,
  });

  console.log(`→ Wallet address: ${walletProvider.getAddress()}`);

  if (!process.env.CDP_WALLET_SECRET) {
    console.log(`→ Wallet secret: ${walletProvider.getWalletSecret()}`);
    console.log("→ Save this wallet secret to .env as CDP_WALLET_SECRET!\n");
  }

  console.log("→ Initializing AgentKit...");

  const agentKit = await AgentKit.from({
    walletProvider,
    actionProviders: [
      walletActionProvider(),
      erc20ActionProvider(),
      erc721ActionProvider(),
      cdpApiActionProvider(),
      wethActionProvider(),
    ],
  });

  console.log("→ Loading LLM...");

  // Use PrimeIntellect (your existing models) instead of OpenAI
  // PrimeIntellect endpoint: api.pinference.ai/api/v1 (OpenAI-compatible)
  const primeIntellectKey = process.env.PRIME_INTELLECT_API_KEY;
  const openAiKey = process.env.OPENAI_API_KEY;
  const llmEndpoint = process.env.UPB_LLM_ENDPOINT || "https://api.pinference.ai/api/v1";
  const model = process.env.LLM_MODEL || "Qwen/Qwen2.5-Coder-32B-Instruct";

  const apiKey = primeIntellectKey || openAiKey;
  if (!apiKey) {
    console.error("Error: No LLM API key found.");
    console.error("Set PRIME_INTELLECT_API_KEY (in ~/.zshrc) or OPENAI_API_KEY.");
    process.exit(1);
  }

  console.log(`→ Using LLM endpoint: ${llmEndpoint}`);
  console.log(`→ Model: ${model}`);

  const llm = new ChatOpenAI({
    openAIApiKey: apiKey,
    baseUrl: llmEndpoint,
    model: model,
    temperature: 0.7,
  });

  const tools = await getLangChainTools(agentKit);

  console.log(`→ Loaded ${tools.length} AgentKit tools\n`);

  const agent = createReactAgent({
    llm,
    tools,
    messageModifier: `You are the Alpha Scanner, an AI agent specialized in finding profitable onchain opportunities.

Your capabilities:
- Check wallet balances and token holdings
- Transfer and swap tokens
- Mint and interact with NFTs
- Get price data and market information
- Fund your wallet for gas (ask user for funding)

Your mission:
1. Analyze onchain data to find alpha opportunities
2. Identify new token launches, whale movements, yield opportunities
3. Report findings clearly with actionable insights
4. When funded, execute on the best opportunities

Always be specific, data-driven, and honest about risks.
Current network: ${NETWORK_ID}`,
  });

  console.log("→ Agent initialized successfully\n");
  return agent;
}

// ============================================================
// SCAN PROMPTS
// ============================================================

const SCAN_PROMPTS = [
  // Wallet analysis
  "Check what tokens and assets are in my wallet. List them all with current values if possible.",

  // Whale tracking
  "Search for recent high-value token transfers on this network that might indicate whale activity or new opportunities.",

  // Network conditions
  "What are the current gas prices and network conditions?",

  // New tokens
  "Look for any new ERC-20 tokens that were recently deployed and might be interesting.",

  // NFT analysis
  "Check if there are any notable NFT collections with recent volume spikes.",

  // Price data
  "What are the current USDC/ETH and WETH prices if available through price oracles?",

  // Yield opportunities
  "What are the best yield farming or lending opportunities currently available on this network?",

  // Arbitrage
  "Are there any price discrepancies between DEXs that could indicate arbitrage opportunities?",
];

let promptIndex = 0;

function getNextScanPrompt(): string {
  const prompt = SCAN_PROMPTS[promptIndex];
  promptIndex = (promptIndex + 1) % SCAN_PROMPTS.length;
  return prompt;
}

// ============================================================
// MAIN SCAN LOOP
// ============================================================

async function runScan(agent: any) {
  const prompt = getNextScanPrompt();

  console.log(`\n[${new Date().toISOString()}] SCANNING...`);
  console.log(`> ${prompt}`);

  try {
    const result = await agent.invoke({
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    });

    console.log("\n--- FINDINGS ---");
    result.messages.forEach((msg: any) => {
      if (msg.content) {
        console.log(msg.content);
      }
    });
    console.log("--- END FINDINGS ---\n");

    // TODO: Post findings to social platforms (Farcaster/Twitter)
    // TODO: Save findings to a database for historical analysis
    // TODO: When funded, auto-execute on high-confidence opportunities

  } catch (error) {
    console.error("Scan error:", error);
  }
}

async function main() {
  try {
    console.log("Starting Alpha Scanner Agent...\n");

    const agent = await initializeAgent();

    // Initial wallet check
    console.log("=== INITIAL WALLET STATUS ===");
    await runScan(agent);

    // Single scan mode: exit after one scan
    if (SINGLE_SCAN) {
      console.log("\nSingle scan mode - exiting after initial scan.");
      process.exit(0);
    }

    // Continuous scan mode
    console.log(`Starting continuous scan loop (every ${SCAN_INTERVAL_MS / 1000}s)...\n`);

    setInterval(async () => {
      await runScan(agent);
    }, SCAN_INTERVAL_MS);

    // First scan
    await runScan(agent);

  } catch (error) {
    console.error("Fatal error:", error);
    process.exit(1);
  }
}

main();
