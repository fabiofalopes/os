# DO THIS. Step by step. Nothing extra.

---

## Step 1: Get Coinbase Developer Platform API Keys (FREE)

**Where:** https://cloud.coinbase.com

**What to do:**
1. Go to the URL above
2. Click "Sign Up" or "Log In"
3. Create account (or log in)
4. Go to "API Keys" section
5. Click "Create New Key Pair"
6. You'll get TWO values:
   - `CDP_API_KEY_ID` (copy this)
   - `CDP_API_KEY_SECRET` (copy this)

**Save both. You'll need them in Step 3.**

---

## Step 2: Get OpenAI API Key

**Where:** https://platform.openai.com/api-keys

**What to do:**
1. Go to the URL above
2. Log in (or create account)
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)

**Save it. You'll need it in Step 3.**

**Cost:** You only pay for what you use. Alpha scanner uses cheap models (~$0.01 per scan). Start with $5 credit if you want.

---

## Step 3: Configure Alpha Scanner

**Where:** Terminal

**What to do (copy-paste these commands exactly):**

```bash
# Go to the alpha-scanner folder
cd ~/projects/agent-wealth/alpha-scanner

# Copy the example env file
cp .env.example .env

# Open it for editing
nano .env
```

**In nano, fill in these values (replace the placeholder text):**

```
CDP_API_KEY_ID=paste_your_cdp_key_id_here
CDP_API_KEY_SECRET=paste_your_cdp_api_key_secret_here
OPENAI_API_KEY=paste_your_openai_key_here
NETWORK_ID=base-sepolia
```

**Save:** Ctrl+O, Enter, then Ctrl+X to exit.

---

## Step 4: Run It on Testnet (FREE)

**What to do:**

```bash
cd ~/projects/agent-wealth/alpha-scanner
npm run scan
```

**What happens:**
- Agent connects to Base Sepolia testnet (fake money, free)
- Scans for opportunities
- Prints findings to your terminal
- You verify it works

**If it errors:** Check your keys in `.env`. Paste the output here and I'll fix it.

---

## Step 5: Get Your Wallet Secret

**First run only.** After Step 4 runs successfully, you'll see output like:

```
→ Wallet address: 0xABC123...
→ Wallet secret: abc123secret...
```

**Copy the wallet secret.** Then update your `.env`:

```bash
nano .env
```

Add this line:

```
CDP_WALLET_SECRET=paste_your_wallet_secret_here
```

Save (Ctrl+O, Enter, Ctrl+X).

**Why:** This persists your wallet. Without it, you get a new wallet every time.

---

## Step 6: Start Continuous Scanning

**What to do:**

```bash
cd ~/projects/agent-wealth/alpha-scanner
npm start
```

**What happens:**
- Agent scans every 5 minutes automatically
- Runs in terminal (keep it open)
- Prints findings as they come in

**To stop:** Ctrl+C

**To run in background (optional):**

```bash
npm start > scanner.log 2>&1 &
```

---

## Step 7: Move to Real Money (Base Mainnet)

**When you're ready** (after testnet works):

**1. Update `.env`:**

```bash
nano .env
```

Change:
```
NETWORK_ID=base-mainnet
```

**2. Fund your agent's wallet:**

- Go to Coinbase Wallet or any exchange
- Send **$5-10 worth of ETH to Base** (or your agent's wallet address from Step 4)
- This is for gas fees only

**3. Restart scanner:**

```bash
npm start
```

Now it's scanning real onchain data, finding real opportunities.

---

## Step 8: Connect Social (Coming Soon)

I'll build this next:
- Auto-post signals to Farcaster
- Auto-post signals to Twitter
- Build audience → monetize

You'll just need to provide:
- Farcaster FID + keys (free at https://warpcast.com)
- Twitter API keys (free tier available)

---

## Quick Reference

| Command | What it does |
|---------|-------------|
| `cd ~/projects/agent-wealth/alpha-scanner` | Go to agent folder |
| `npm start` | Run continuous scanning |
| `npm run scan` | Run single scan (test) |
| `nano .env` | Edit your keys |
| `cat .env` | View your keys |

---

## That's It

1. Get CDP keys (Step 1)
2. Get OpenAI key (Step 2)
3. Put keys in `.env` (Step 3)
4. Run on testnet (Step 4)
5. Save wallet secret (Step 5)
6. Start scanning (Step 6)
7. Move to mainnet when ready (Step 7)

Everything else I handle. You just follow these steps.
