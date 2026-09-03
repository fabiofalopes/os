---
title: "HFT & Execution Practitioner Knowledge"
authors: [Stoikov (lecture notes), Hasbrouck, Cartea–Jaimungal–Penalva, practitioner lore]
year: 2015
type: paper-distillation
domain: microstructure
tags: [microstructure, hft, market-making, latency, queue-position, order-book, maker-taker, execution, practitioner]
status: distilled
created: 2026-07-23
citekey: hftpractitioner
---

# HFT & Execution — Practitioner Knowledge

Part of [[CANON]]. Sibling notes: [[micro-avellaneda-stoikov-2008]], [[micro-market-impact]], [[micro-order-flow-toxicity]].

## One-liner
The academic models ([[micro-avellaneda-stoikov-2008]], [[micro-almgren-chriss-2000]]) assume a frictionless continuous book; **real HFT P&L is made in the frictions they abstract away** — queue position, latency, maker/taker fees, and the microstructure of the limit order book. This note distills the practitioner layer that turns a textbook policy into a live edge.

## The model (how the live book actually works)
- **Limit order book (LOB):** price-time priority. Your fill probability is a function of **queue position**, not just price — being best bid with 10k shares ahead of you is very different from being alone.
- **Maker vs taker:** *makers* post resting limit orders (provide liquidity, often earn a **rebate**); *takers* cross the spread with marketable orders (pay the spread + fee). Much of HFT MM profit is **rebate capture + spread**, not directional.
- **Latency hierarchy:** speed determines who picks off stale quotes. Colocation, microwave networks, and FPGA/kernel-bypass stacks exist to win **adverse-selection races** — being slow means your quotes are hit exactly when they're wrong.
- **Order-flow signals at the tick:** order-book imbalance (OFI), trade-flow imbalance, queue depletion, and micro-price (volume-weighted mid) predict the **next few ticks** — the short-horizon alpha HFT trades on.
- **Micro-price:** `p_micro = (V_ask·bid + V_bid·ask)/(V_bid+V_ask)` — a better "fair value" than the raw mid when the book is lopsided; the natural reference for quoting and signals.

## Key relationships
- **Fill probability ∝ queue position and quote aggressiveness;** decays roughly exponentially with your distance back in the queue (the live analog of A–S's `A e^{−kδ}`).
- **Adverse selection is a latency race:** you lose money on fills that arrive *immediately before* a price move (you were picked off); the cure is speed + a toxicity gate ([[micro-order-flow-toxicity]]).
- **Maker-taker economics:** net P&L ≈ (rebate + half-spread captured) − (adverse-selection losses) − (inventory cost). In many US equities the **rebate is the business**.
- **OFI → short-horizon drift:** `Δp_{t+1} ~ OFI_t = Δ(bid_size) − Δ(ask_size)` (Cont–Stoikov–Talreja) — the workhorse tick-level signal.

## Assumptions (of the textbook layer that break)
1. Continuous, frictionless clearing — reality is discrete ticks, queues, and priority.
2. Symmetric, anonymous fill probability — reality is queue-position- and latency-dependent.
3. No fees/rebates — reality: fee structure often *is* the profit.
4. Single venue — reality: fragmented across dozens of venues with different fees, latencies, and order types.
5. You can cancel freely — reality: cancel-to-trade ratios are throttled; exchanges penalize spam.

## How it breaks live (practitioner failure modes)
- **Queue-position blindness:** a backtest that assumes you fill whenever the price touches your quote massively overstates fills — you were *behind* the queue. Realistic **queue simulation** is the single biggest backtest→live gap in MM.
- **Latency decay:** an edge measured at research latency evaporates when a faster competitor picks off your quotes; alpha half-life in HFT is microseconds-to-milliseconds.
- **Fee/rebate regime shifts:** exchanges change maker-taker fees frequently; a strategy profitable on rebates can go negative overnight.
- **Adverse-selection spikes:** into news/toxic flow ([[micro-order-flow-toxicity]]) you get run over one-sidedly; without a real-time toxicity gate and instant quote-pull, one event wipes weeks of spread income.
- **Capacity is tiny:** HFT edges are real but small-capacity; scaling AUM destroys them via your own impact ([[micro-market-impact]]) and queue saturation.
- **Infrastructure is the moat and the risk:** colocation, networking, and low-latency code are table stakes; a bug or a stale quote in a fast market is a catastrophic tail (fat-finger, runaway algo).
- **Regulatory/throttle risk:** cancel-ratio limits, order-to-trade rules, and exchange-specific constraints change the feasible strategy set.

## Deployable takeaways
- **Simulate the queue, not just the price.** Any MM/HFT backtest must model queue position, partial fills, and adverse selection; assume you fill *last*, not first.
- **Quote off the micro-price and skew by inventory** ([[micro-avellaneda-stoikov-2008]]); the raw mid is a naive reference when the book is imbalanced.
- **Gate on toxicity:** pull or widen quotes when OFI/toxicity turns sharply one-sided; the best HFT risk control is *not quoting* into informed flow.
- **Model fees/rebates explicitly** in the objective — often the rebate, not the spread, is the profit; optimize for net economics per venue.
- **Treat latency as a first-class cost:** measure your quote-to-cancel and signal-to-order latency; an edge you can't act on fast enough isn't an edge.
- **Kill-switches and position limits are non-negotiable:** hard per-second loss limits, max-position caps, and stale-quote detection prevent a bad minute from ending the fund.
- **Capacity-aware sizing:** HFT alpha doesn't scale; run many small-capacity strategies rather than scaling one.
- **For non-HFT execution:** even a slower book benefits from micro-price signals, OFI-aware timing, and maker-vs-taker routing to cut costs ([[micro-almgren-chriss-2000]]).

## Connections
- [[micro-avellaneda-stoikov-2008]] — the optimal-quote skeleton this layer fleshes out with queue/latency/fees.
- [[micro-order-flow-toxicity]] — the real-time gate that protects a market maker from adverse selection.
- [[micro-market-impact]] — the capacity ceiling on any scaling.
- [[micro-glosten-milgrom-1985]] — adverse selection reframed as a latency race.
- [[micro-almgren-chriss-2000]] — slower execution that still uses micro-price/OFI timing.
- [[micro-momentum]] — tick-level OFI is the microstructure cousin of short-horizon momentum.
- [[CANON]]

## References
- Cont, R., Stoikov, S., & Talreja, R. (2010) — "A Stochastic Model for Order Book Dynamics" / Order-Flow Imbalance.
- Cartea, Á., Jaimungal, S., & Penalva, J. (2015) — *Algorithmic and High-Frequency Trading* (Cambridge).
- Hasbrouck, J. (2007) — *Empirical Market Microstructure*.
- Stoikov, S. — lecture notes on market making and the micro-price.
- Gould, M. D. et al. (2013) — "Limit Order Books" (survey).
- Practitioner: exchange maker-taker fee schedules; colocation/latency engineering lore.
