#!/usr/bin/env tsx
/**
 * Social Agent - Farcaster + Twitter
 *
 * Posts alpha signals from the scanner agent to build an audience.
 * Free signals publicly + paid premium tier for early access.
 *
 * Revenue: subscriptions ($29/month USDC per premium user)
 */

import * as dotenv from "dotenv";
dotenv.config();

// ============================================================
// CONFIG
// ============================================================

const POST_INTERVAL_MS = parseInt(process.env.POST_INTERVAL_MS || "1800000"); // 30 min
const NETWORK_ID = process.env.NETWORK_ID || "base-sepolia";

console.log(`
╔══════════════════════════════════════════════════════╗
║           SOCIAL AGENT v0.1                          ║
║           Posting interval: ${String(POST_INTERVAL_MS / 60000).padStart(3)}min${" ".repeat(28)}║
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

  if (!process.env.FARCASTER_FID) {
    console.warn("Warning: FARCASTER_FID not set. Farcaster posting disabled.");
  }
}

validateEnvironment();

// ============================================================
// SIGNAL TEMPLATES
// ============================================================

type SignalType = "whale" | "new_listing" | "volume_spike" | "yield" | "general";

interface Signal {
  type: SignalType;
  token: string;
  message: string;
  conviction: "low" | "medium" | "high";
  entry?: string;
  target?: string;
  risk?: string;
}

// Example signals - in production these come from the scanner agent
function generateSampleSignal(): Signal {
  const types: SignalType[] = ["whale", "volume_spike", "general"];
  const type = types[Math.floor(Math.random() * types.length)];

  return {
    type,
    token: "$DEGEN",
    message: `🐋 Whale alert: 0x${Math.random().toString(16).slice(2, 14)}... just bought 500k $DEGEN on Base. Price +12% since.`,
    conviction: "medium",
  };
}

function formatSignalForFarcaster(signal: Signal): string {
  const emoji = {
    whale: "🐋",
    new_listing: "🚀",
    volume_spike: "📈",
    yield: "💰",
    general: "📊",
  }[signal.type];

  let cast = `${emoji} ${signal.message}`;

  if (signal.conviction === "high") {
    cast += "\n\n🔥 HIGH CONVICTION";
    if (signal.entry) cast += `\nEntry: ${signal.entry}`;
    if (signal.target) cast += `\nTarget: ${signal.target}`;
  }

  cast += "\n\n#crypto #base #alpha";

  return cast;
}

// ============================================================
// POSTING LOGIC
// ============================================================

async function postToFarcaster(cast: string) {
  if (!process.env.FARCASTER_FID) {
    console.log("[Would post to Farcaster]:", cast);
    return;
  }

  // TODO: Implement Farcaster posting using AgentKit's Farcaster action provider
  // const farcasterAgent = await initializeFarcasterAgent();
  // await farcasterAgent.postMessage(cast);

  console.log("[Farcaster]:", cast);
}

async function postToTwitter(cast: string) {
  if (!process.env.TWITTER_API_KEY) {
    console.log("[Would post to Twitter]:", cast);
    return;
  }

  // TODO: Implement Twitter posting
  console.log("[Twitter]:", cast);
}

// ============================================================
// MAIN LOOP
// ============================================================

async function runPostCycle() {
  console.log(`\n[${new Date().toISOString()}] Generating signal...`);

  // In production: fetch real signals from scanner agent
  const signal = generateSampleSignal();
  const cast = formatSignalForFarcaster(signal);

  console.log("\n--- CAST ---");
  console.log(cast);
  console.log("--- END CAST ---\n");

  await postToFarcaster(cast);
  await postToTwitter(cast);
}

async function main() {
  console.log("Starting Social Agent...\n");

  // Initial post
  await runPostCycle();

  // Continuous posting
  setInterval(runPostCycle, POST_INTERVAL_MS);

  console.log(`Posting every ${POST_INTERVAL_MS / 60000} minutes. Ctrl+C to stop.\n`);
}

main();
