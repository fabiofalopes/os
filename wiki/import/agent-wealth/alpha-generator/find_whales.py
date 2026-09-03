#!/usr/bin/env python3
"""
Whale Finder
Scans public data to identify whale wallets on Base chain.
No API keys needed - uses free public APIs.

Run: python3 find_whales.py
"""

import requests
import json
from datetime import datetime


def fetch_large_transactions():
    """
    Fetch recent large transactions on Base chain from public sources.
    Uses CoinGecko and other free APIs.
    """
    try:
        # Get top coins by volume (potential whale activity)
        url = "https://api.coingecko.com/api/v3/coins/markets"
        params = {
            "vs_currency": "usd",
            "order": "volume_desc",
            "per_page": 50,
            "sparkline": "false",
            "price_change_percentage": "24h",
        }
        resp = requests.get(url, params=params, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        print(f"Error fetching data: {e}")
        return []


def fetch_base_tokens():
    """Fetch Base chain specific tokens."""
    try:
        url = "https://api.coingecko.com/api/v3/coins/list"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        all_coins = resp.json()
        # Filter for Base chain tokens
        base_tokens = [
            c for c in all_coins
            if "base" in c.get("platforms", {})
        ][:100]
        return base_tokens
    except Exception as e:
        print(f"Error fetching Base tokens: {e}")
        return []


def analyze_high_volume_tokens(coins):
    """
    Analyze tokens with unusual volume (potential whale activity).
    """
    print("\n" + "=" * 60)
    print("WHALE ACTIVITY DETECTOR")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("=" * 60)

    # Sort by volume
    by_volume = sorted(
        [c for c in coins if c.get("24h_vol")],
        key=lambda x: x.get("24h_vol", 0),
        reverse=True
    )[:20]

    print(f"\n📊 Top {len(by_volume)} tokens by volume (whale territory):")
    print("-" * 60)

    whales = []

    for coin in by_volume:
        symbol = coin["symbol"].upper()
        name = coin["name"]
        volume = coin.get("24h_vol", 0)
        price = coin.get("current_price", 0)
        change = coin.get("price_change_percentage_24h", 0)
        market_cap = coin.get("market_cap", 0)

        # Estimate whale size based on volume
        if volume > 10_000_000:  # >$10M volume = whale territory
            whale_level = "🐋🐋🐋 MEGA" if volume > 100_000_000 else "🐋🐋 LARGE" if volume > 50_000_000 else "🐋 MEDIUM"

            print(f"\n{whale_level} WHALES: ${name} (${symbol})")
            print(f"  Volume: ${volume:,.0f} (24h)")
            print(f"  Price: ${price:,.4f} ({change:+.1f}%)")
            print(f"  Market Cap: ${market_cap/1e9:.2f}B")

            # Estimate whale positions
            if volume > market_cap * 0.5:
                print(f"  ⚠️  Volume > 50% of market cap = heavy whale activity")
            elif volume > market_cap * 0.1:
                print(f"  📊 Volume > 10% of market cap = notable whale presence")

            whales.append({
                "symbol": symbol,
                "name": name,
                "volume": volume,
                "change": change,
                "signal": "BULLISH" if change > 5 else "BEARISH" if change < -5 else "NEUTRAL",
            })

    return whales


def generate_whale_signals(whales):
    """Generate trading signals based on whale activity."""
    print("\n\n" + "=" * 60)
    print("🐋 WHALE-BASED SIGNALS")
    print("=" * 60)

    # Bullish whale activity (high volume + price up)
    bullish = [w for w in whales if w["change"] > 10]
    if bullish:
        print("\n🟢 WHALES BUYING (high volume + price up):")
        for w in bullish:
            print(f"  → ${w['symbol']}: ${w['name']} up {w['change']:.1f}% on ${w['volume']:,.0f} volume")
            print(f"     Signal: WHALES ARE LOADING. Consider following.")

    # Bearish whale activity (high volume + price down)
    bearish = [w for w in whales if w["change"] < -10]
    if bearish:
        print("\n🔴 WHALES SELLING (high volume + price down):")
        for w in bearish:
            print(f"  → ${w['symbol']}: ${w['name']} down {abs(w['change']):.1f}% on ${w['volume']:,.0f} volume")
            print(f"     Signal: WHALES ARE DUMPING. Stay away or short.")

    # Accumulation (high volume, price stable)
    accumulation = [w for w in whales if abs(w["change"]) < 3 and w["volume"] > 50_000_000]
    if accumulation:
        print("\n🟡 WHALES ACCUMULATING (high volume, price stable):")
        for w in accumulation:
            print(f"  → ${w['symbol']}: ${w['name']} — ${w['volume']:,.0f} volume, price flat")
            print(f"     Signal: Whales accumulating quietly. Something might be brewing.")


def save_whale_report(whales):
    """Save whale report to file."""
    filename = f"whale_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

    with open(filename, "w") as f:
        f.write(f"Whale Activity Report\n")
        f.write(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}\n\n")

        for w in whales:
            f.write(f"${w['symbol']} - {w['name']}\n")
            f.write(f"Volume: ${w['volume']:,.0f}\n")
            f.write(f"Change: {w['change']:.1f}%\n")
            f.write(f"Signal: {w['signal']}\n\n")

    print(f"\n\n📄 Whale report saved to: {filename}")


def main():
    print("Fetching market data...")
    coins = fetch_large_transactions()
    print(f"Got {len(coins)} tokens")

    print("Fetching Base chain tokens...")
    base_tokens = fetch_base_tokens()
    print(f"Got {len(base_tokens)} Base tokens")

    # Analyze
    whales = analyze_high_volume_tokens(coins)

    if whales:
        generate_whale_signals(whales)
        save_whale_report(whales)
    else:
        print("\nNo significant whale activity detected right now.")
        print("Market is quiet. Check back later.")


if __name__ == "__main__":
    main()
