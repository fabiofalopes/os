#!/usr/bin/env python3
"""
Alpha Signal Generator
Fetches real public crypto data and generates trading signals.
No API keys needed - uses free public APIs.

Run: python3 alpha_signals.py
"""

import json
import requests
from datetime import datetime


def fetch_top_gainers_losers():
    """Fetch top gainers and losers from CoinGecko (free, no key)."""
    try:
        url = "https://api.coingecko.com/api/v3/coins/markets"
        params = {
            "vs_currency": "usd",
            "order": "market_cap_desc",
            "per_page": 100,
            "sparkline": "false",
            "price_change_percentage": "24h",
        }
        resp = requests.get(url, params=params, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        print(f"Error fetching CoinGecko data: {e}")
        return []


def fetch_defi_yields():
    """Fetch current DeFi yields from DefiLlama (free, no key)."""
    try:
        url = "https://yields.llama.fi/pools"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        pools = resp.json().get("data", [])
        # Filter for stablecoin pools (lower risk)
        stable_pools = [
            p for p in pools
            if p.get("symbol", "").upper() in ["USDC", "USDT", "DAI", "FRAX"]
            and p.get("apy", 0) > 0
        ]
        return sorted(stable_pools, key=lambda x: x.get("apy", 0), reverse=True)[:20]
    except Exception as e:
        print(f"Error fetching DefiLlama data: {e}")
        return []


def generate_price_signals(coins):
    """Generate signals from price movements."""
    signals = []

    # Top gainers (momentum)
    gainers = sorted(coins, key=lambda x: x.get("price_change_percentage_24h", 0), reverse=True)[:5]
    for coin in gainers:
        change = coin.get("price_change_percentage_24h", 0)
        if change > 10:  # Only significant moves
            signals.append({
                "type": "🚀 MOMENTUM",
                "token": f"${coin['symbol'].upper()}",
                "message": f"{coin['name']} up {change:.1f}% in 24h. Price: ${coin['current_price']:,.2f}",
                "details": f"Volume: ${coin.get('24h_vol', 0):,.0f}M | Market Cap: ${coin.get('market_cap', 0) / 1e9:.1f}B",
            })

    # Top losers (potential bounce plays)
    losers = sorted(coins, key=lambda x: x.get("price_change_percentage_24h", 0))[:5]
    for coin in losers:
        change = coin.get("price_change_percentage_24h", 0)
        if change < -10:  # Only significant drops
            signals.append({
                "type": "📉 DIP ALERT",
                "token": f"${coin['symbol'].upper()}",
                "message": f"{coin['name']} down {abs(change):.1f}% in 24h. Price: ${coin['current_price']:,.2f}",
                "details": f"Possible bounce play. Volume: ${coin.get('24h_vol', 0):,.0f}M",
            })

    return signals


def generate_yield_signals(pools):
    """Generate signals from DeFi yields."""
    signals = []

    # Filter out suspiciously high APYs (>100% = likely risky/unsustainable)
    safe_pools = [p for p in pools if p.get("apy", 0) < 100]

    for pool in safe_pools[:5]:
        apy = pool.get("apy", 0)
        if apy > 5:  # Only interesting yields
            risk_label = "🟢" if apy < 15 else "🟡" if apy < 30 else "🔴"
            signals.append({
                "type": f"💰 YIELD {risk_label}",
                "token": pool.get("symbol", "UNKNOWN"),
                "message": f"{pool.get('project', 'Unknown')}: {pool.get('symbol', '')} at {apy:.1f}% APY",
                "details": f"TVL: ${pool.get('tvl', 0):,.0f} | Chain: {pool.get('chain', 'Unknown')} | {'SAFE' if apy < 15 else 'MODERATE' if apy < 30 else 'HIGH RISK'}",
            })

    return signals


def generate_volume_signals(coins):
    """Generate signals from unusual volume."""
    signals = []

    # Calculate average volume
    volumes = [c.get("24h_vol", 0) for c in coins if c.get("24h_vol")]
    if not volumes:
        return signals

    avg_volume = sum(volumes) / len(volumes)

    # Find coins with volume >> average (potential breaking out)
    high_volume = [
        c for c in coins
        if c.get("24h_vol", 0) > avg_volume * 3  # 3x average volume
        and c.get("price_change_percentage_24h", 0) > 5  # Also price moving up
    ][:5]

    for coin in high_volume:
        vol_ratio = coin["24h_vol"] / avg_volume
        signals.append({
            "type": "📊 VOLUME SPIKE",
            "token": f"${coin['symbol'].upper()}",
            "message": f"{coin['name']} volume {vol_ratio:.1f}x average! Price up {coin['price_change_percentage_24h']:.1f}%",
            "details": f"Volume: ${coin['24h_vol']:,.0f}M",
        })

    return signals


def format_signal(signal):
    """Format a signal for social media posting."""
    return f"""
{signal['type']} {signal['token']}
{signal['message']}
{signal['details']}

#crypto #trading #alpha"""


def main():
    print("=" * 60)
    print("ALPHA SIGNAL GENERATOR")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("=" * 60)

    # Fetch data
    print("\nFetching market data...")
    coins = fetch_top_gainers_losers()
    print(f"→ Got {len(coins)} coins from CoinGecko")

    print("Fetching DeFi yields...")
    pools = fetch_defi_yields()
    print(f"→ Got {len(pools)} pools from DefiLlama")

    # Generate signals
    print("\nGenerating signals...\n")

    all_signals = []
    all_signals.extend(generate_price_signals(coins))
    all_signals.extend(generate_yield_signals(pools))
    all_signals.extend(generate_volume_signals(coins))

    # Display signals
    if not all_signals:
        print("No significant signals found right now.")
        print("Market is calm. Check back later.")
        return

    print(f"Found {len(all_signals)} signals:\n")

    for i, signal in enumerate(all_signals, 1):
        print(f"--- SIGNAL {i} ---")
        print(format_signal(signal))
        print()

    # Save to file for easy copying
    output_file = f"signals_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    with open(output_file, "w") as f:
        for signal in all_signals:
            f.write(format_signal(signal) + "\n\n")

    print(f"Signals saved to: {output_file}")
    print("\nCopy these to Twitter/X, Farcaster, or Telegram!")


if __name__ == "__main__":
    main()
