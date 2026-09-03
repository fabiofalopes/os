#!/usr/bin/env python3
"""
Agent Wealth Dashboard
Combines all alpha signals, whale activity, and yield opportunities in one view.

Run: python3 dashboard.py
"""

import subprocess
import sys
from datetime import datetime


def run_script(script_path):
    """Run a Python script and capture output."""
    try:
        result = subprocess.run(
            ["python3", script_path],
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.stdout
    except Exception as e:
        return f"Error running {script_path}: {e}"


def main():
    print("=" * 70)
    print("AGENT WEALTH DASHBOARD")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("=" * 70)

    # Run alpha signals
    print("\n" + "=" * 70)
    print("🔍 ALPHA SIGNALS")
    print("=" * 70)
    alpha_output = run_script("alpha_signals.py")
    print(alpha_output)

    # Run whale finder
    print("\n" + "=" * 70)
    print("🐋 WHALE ACTIVITY")
    print("=" * 70)
    whale_output = run_script("find_whales.py")
    print(whale_output)

    # Summary
    print("\n" + "=" * 70)
    print("📊 QUICK SUMMARY")
    print("=" * 70)
    print("""
Available scripts:
  1. python3 alpha_signals.py     - Generate trading signals
  2. python3 find_whales.py       - Detect whale activity
  3. python3 dashboard.py         - Full dashboard (this script)

Documentation:
  - DO-THIS.md        - Setup instructions
  - ROADMAP.md        - Strategy from $0 → wealth
  - STRATEGIES.md     - Revenue strategies with numbers
  - REVENUE-IDEAS.md  - All money-making ideas
  - BASE-OPPORTUNITIES.md - Base chain specific opportunities
  - WHALE-RESEARCH.md - How to find and track whales

Agents (need API keys to run):
  - alpha-scanner/    - Onchain scanning agent
  - social-agent/     - Farcaster/Twitter posting bot
  - yield-optimizer/  - Auto-yield farming agent

To activate agents:
  1. Get CDP API keys: https://cloud.coinbase.com
  2. Get OpenAI API key: https://platform.openai.com/api-keys
  3. Follow DO-THIS.md step by step
""")


if __name__ == "__main__":
    main()
