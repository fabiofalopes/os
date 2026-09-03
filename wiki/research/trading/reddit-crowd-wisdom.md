---
tags: [research, trading, ai-agents, llm, freqtrade, crowd-wisdom, skepticism, source-clip]
date: 2026-07-21
sources:
  - "PullPush API (Pushshift successor) — 152 unique submissions scanned across 12 queries on r/algotrading + r/quant; 18 threads fetched with comment trees. Reddit's own API returned 403 from this IP (all endpoints, all UAs); redlib mirrors all dead or behind Anubis/Cloudflare. PullPush was the working route."
  - "Thread permalinks: https://www.reddit.com/r/{sub}/comments/{id}/ (ids listed per thread below)"
status: clipped+distilled 2026-07-21 — vote counts are PullPush snapshots (ingest lags; treat as approximate, not live)
related:
  - "[[the-alpha-illusion]]"
  - "[[López de Prado — Backtest Overfitting Guards]]"
  - "[[Kelly Criterion — Position Sizing]]"
  - "[[learning-path]]"
  - "[[curriculum-draft]]"
  - "[[ledger]]"
  - "[[Operating Principle — Test Don't Wonder]]"
---

# Reddit Crowd Wisdom — Practitioner Q&A on AI Trading Agents / LLM Backtests / Freqtrade ML

> **What it gives the harness:** the practitioner-ground-truth counterpart to [[the-alpha-illusion]]. The academic paper says reported LLM-agent alpha ≠ deployment evidence; the r/algotrading + r/quant crowd **independently converged on the same verdict from the trenches** — and, more usefully, they ask the *same screening questions* of every show-and-tell post. Those recurring questions are a free, battle-tested FOMO filter. Also: a clear map of where practitioners actually use LLMs (engineering, not alpha), and the freqtrade-ML entry points.

## Method & evidence caveats (test, don't wonder)
- Reddit blocks direct access from this host (403 on www/old/api/oauth, every UA). All data via PullPush archive API, sorted by score desc.
- Coverage: queries = "AI trading agent", "LLM", "ChatGPT", "GPT-4", "freqtrade", "reinforcement learning", "machine learning profitable", "LLM trading bot", "freqtrade machine learning", "ChatGPT trading", "GPT backtest" × {r/algotrading, r/quant}. Some late queries hit 429s; the broad "machine learning" query was never run — classic high-score ML threads (e.g. the perennial "is ML worth it" megathreads) may be missing.
- Vote counts = PullPush snapshot, not live. "Vetted" here means **upvote-weighted community agreement**, not truth — the crowd can be wrong; but its *questions* are valuable regardless of its answers.
- Hostility is data: low-effort/AI-generated show-and-tell gets dunked (top comment on a 76↑ AI-scanner post: "Another completely bullshit crap strategy post"; an LLM-written question on r/quant drew 27↑ "Super low-effort post"). The community's bar = evidence, and its first question is always the same (see Q1).

---

## The recurring questions (what people actually ask)

### Q1. "Is your backtest in-sample or out-of-sample?" — the universal first question
Asked of literally every ML-bot results post, from 2019 to 2025. Earliest capture: a freqtrade ML bot post (r/algotrading 2019-09, id `d2j3oa`) — top substantive reply: *"Are those results from in sample data, or out of sample?"* This is the crowd's native form of [[López de Prado — Backtest Overfitting Guards]]: no PBO math, same instinct. **Harness use: any signal note in [[ledger]] must answer this before it earns a status above `idea`.**

### Q2. "Can ChatGPT/LLMs write me a profitable trading bot?" — Consensus: no. Use them for code + inspiration, never for signal.
- **"It was build by ChatGPT"** (r/algotrading 2025-04, 56↑/23c, id `1jzzyep`) — OP showed an MT4/5 Expert Advisor (MQL/C++ dialect) written by ChatGPT with a pretty equity curve. Vetted: *"it's wild to me that people would have ChatGPT write C++ for them and then put money on the line… if you hope to actually scale your trading up, don't waste time screwing around like that"* (u/kokanee-fish); and the sharpest line in the dataset — *"I do love the way the graph stops just before the tariffs were announced"* (u/I_Am_Graydon) — **backtest-window cherry-picking gets spotted instantly**. Nuance: LLM-written C++ itself isn't the problem (u/na85); deploying unverified code with real money is.
- **"Creating the 'Bitcoin Bender' — An LLM workflow"** (r/algotrading 2024-04, 17↑/27c, id `1c261v8`) — the best-practice post: prompt → draft strategy → backtest → feed results back to the LLM. OP's own caveat got upvoted: the workflow "works" **for idea inspiration, not a tradable strategy** — *"You still have to do the important analysis work, because LLMs still obviously get things wrong or incomplete"* — his LLM recommended measuring an Hourly VMO indicator and then **never used it in any signal**. Silent incompleteness, not just wrongness.
- **"How do you backtest simulating real time?"** (r/algotrading 2025-03, 5↑/8c, id `1jh4ej3`) — OP building strategies with ChatGPT/Claude, limited dev experience. Vetted answer (8↑, u/heshiming): event-driven design — one "trade step" function called per bar in backtest AND per bar-notification live (the QuantConnect pattern). Side-finding: free data (Twelve Data, Polygon free tiers) is unreliable. Also an 8↑ "I cannot even begin to describe how stupid this is" — the sub's reflexive hostility to LLM-built strategies from non-devs is itself a signal about the credibility bar.

### Q3. "Which ML research/approach actually matters for markets — RL, supervised, NLP/LLMs?"
- **"What type of ML research is more relevant to quant?"** (r/quant 2024-09, 54↑/37c, id `1fmato0`) — the highest-signal thread in the set. Vetted answers:
  - *"be a jack of all trades AND master of one"* (38↑).
  - *"there's a great book called Advances in Financial Machine Learning… It's not trivial at all to build a good financial ML model just because you know the current research"* (36↑) — **the crowd's #1 book rec is de Prado**, i.e. the overfitting-guards corpus already in the vault. Dissent exists (*"I've read it. It's not very enlightening"*, 23↑) — label: contested, not consensus.
  - *"LLMs would be good for sentiment analysis, LSTM more for time series. Just predicting direction… is better than trying to predict price… learn to make an ensemble model where each base model has independent features"* (8↑).
- **"Reinforcement Learning Shouldn't be Used for Trading a Single asset, am I Right?"** (r/algotrading 2020-11, 4↑/11c, id `jqf11x`) — vetted: RL's theoretical edge is learning the *whole strategy* (thresholds, sizing) without manual engineering (7↑, 6↑), but *"RL is too sensitive and reward function means everything"* (7↑, u/mlord99); *"RL is used in the industry on synthetic data, not real data so you limit the risks of overfitting"* (2↑, u/PhloWers) — **claim to verify against literature before reuse; labeled practitioner-asserted**.
- **"Trading Environment for Reinforcement Learning"** (r/quant 2023-04, 32↑/19c, id `12yl7fe`) — vetted: *"it's not reinforcement learning unless it's real money"* (3↑, sim≠live); *"Stock market is not an A.I problem [it] is a Risk mGmt, Portfolio optimization, Gambling theory, Statistics problem"* — RL-only bots fail without portfolio fundamentals (2↑); price data alone (esp. crypto) "too noisy and almost useless" (2↑). Technical gem: long RL training + Adam optimizer → weights grow unbounded → periodic performance crashes (2↑, u/JacksOngoingPresence).
- **"Noise-reduced data vs 'pure' data for training a deep learning AI"** (r/algotrading 2021-05, 35↑/35c, id `n5bvs3`) — vetted: *"The bigger problem with an AI agent is the reward function. An entry isn't a good decision until the exit has been made"* (7↑); start with many features incl. **non-price** features, then feature-reduce — *"Many weak learners with unique perspectives are always better than a single strong learner"* (3↑); DL handles raw data better than other ML, filtering risks deleting signal — *"don't guess-test!"* (2↑).

### Q4. "Is unstructured/alt data (news sentiment, satellite, filings) actually alpha?"
- **"Is unstructured data useful in quant?"** (r/quant 2024-09, 41↑/22c, id `1fhi075`) — OP's premise: news sentiment etc. is "solved 70% via old-school BERT or just lagging." Vetted practitioner replies: ex-NLP-vendor — *"yes there is alpha to be found there still, it just depends on your universe and trading frequency"*; someone at a top firm — *"Unstructured data might have better signal to noise ratio for low frequency trading but it is a pain to deal with… the resources that go into reaping benefit from it are way too much"* (asteroid-mining analogy); hedge funds do consume unstructured web data (commodity reports, government alerts). **Net: alpha exists at low frequency / niche universes; cost-to-exploit kills it for retail.**

### Q5. "Freqtrade for stocks? Freqtrade + ML?"
- **"Freqtrade Equivalent For Normal Stocks?"** (r/algotrading 2022-11, 9↑/13c, id `yyqkm5`) — vetted: MetaTrader5 Python library (5↑, check broker support first); or roll your own: Interactive Brokers API + pandas + TA-Lib (multiple 2↑ replies). Freqtrade itself stays crypto-only.
- **"Freqtrade Backtesting with Strato Strategy. Machine learning bot."** (r/algotrading 2019-09, id `d2j3oa`) — content-free flex; value is Q1 being asked. Freqtrade-ML proper (FreqAI) never appears in top threads of this era — **gap worth a future Scout pass** (FreqAI shipped 2022; the crowd discussion lives in freqtrade docs/Discord more than Reddit top-posts).

### Q6. "My model has high R²/accuracy — am I onto something?" — No.
- **"Is it realistic to use Ridge Regression for trading?"** (r/algotrading 2025-02, 5↑/7c, id `1iliivd`) — OP proud of R²≈0.4 on intraday moves. Vetted: *"putting prices in the Y vector is a bad idea… it's easy to make a 'great' model, one with very high R², that is actually useless"* — predict movements/returns, never price levels (4↑, u/MengerianMango); *"back tested PnL should still be your gauge"* and econometric methods are best used to **refine a strategy that already has fundamental logic**, not to discover one (5↑, u/zumateats).

### Q7. "Where are LLMs/agentic workflows actually useful in quant work?"
- **"Where do you find LLMs or agentic workflows useful?"** (r/quant 2025-02, 11↑/7c, id `1iga1tl`) — the consensus job description: **engineering, not alpha**. Vetted: bash/YAML/git/tests — *"easy to describe and check, and boring af"* (12↑); *"a sophisticated search engine… minimal example of what I'm wanting to do"* (7↑); boilerplate skeletons + iterate-by-running (2↑); ETL pipelines. One data-vendor uses LLMs as a "conversational medium between proprietary data and understanding" (1↑ — single source, treat as anecdote).
- **"AI in Options Trading Research"** (r/quant 2025-04, 8↑/8c, id `1juzgph`) — OP used Claude Code for SPX diagonal research. Vetted nuance: LLMs are *"good at giving it specific instructions… it takes bite sizes"* but *"if it's anything complex obviously starts forgetting things"*; when it *"runs calculations… it's usually non sensical or can't be relied upon"* — **use for code, not arithmetic**; Claude's tool-use (run → self-fix) is the differentiator vs plain chat.

### Q8. "What about all these AI trading books/courses?" — Fraud watch.
- **"Beware of AI Generated garbage posing as Algo trading books on Amazon"** (r/algotrading 2025-01, 26↑/15c, id `1hxaaiq`) — the "Jamie Flux" series: *"Literal copy and pasted from ChatGPT without any attempt to understand the context… should be sued for fraud"* (27↑). **Harness use: any resource entering [[curriculum-draft]] gets an AI-slop check (incoherent code snippets + bullet points + no coherent through-line = reject).**

---

## The crowd's heuristic checklist (distilled, ranked by upvote weight)

1. **In-sample or out-of-sample?** — asked before anything else, every time (Q1).
2. **Where does the backtest window end?** — if the equity curve conveniently stops before a known crash/event, it's cherry-picked (`1jzzyep`).
3. **Net of what?** — fees, spread, latency, look-ahead bias must be charged before an exchange connection is even discussed (*"it's only worth connecting to an exchange if your agent is profitable on historical data accounting for fees, spread, latency and look ahead bias"*, `hzsohq`; matches [[the-alpha-illusion]] §2 confound 2 exactly).
4. **R²/accuracy on price levels is a fool's errand** — predict direction/returns; judge by backtested PnL, not fit statistics (Q6).
5. **The reward function is the real problem, not the data or the architecture** — recurring across every RL/DL thread (Q3).
6. **LLM = code generator + idea sounding board, never signal source** — and audit for *silent incompleteness* (recommended-but-unused features), not just errors (Q2, Q7).
7. **The market is a risk-management/portfolio problem wearing an AI costume** — RL-only and prediction-only approaches fail without sizing/risk fundamentals (Q3; connects to [[Kelly Criterion — Position Sizing]]).
8. **Industry RL runs on synthetic data to bound overfitting** — practitioner-asserted, unverified here; a literature-check candidate (Q3).
9. **Alt-data alpha exists only where exploitation cost is bearable** — i.e. low-frequency/niche; retail's cost curve kills it (Q4).
10. **No evidence, no post** — the sub's hostility to evidence-free show-and-tell is the enforcement mechanism. Mirror it internally: the Critic gate in [[CLAUDE]] is the vault's version.

## Convergence with the vault (why this matters)
- The crowd's #1 book rec (de Prado) **is** [[López de Prado — Backtest Overfitting Guards]]; their Q1/Q3 heuristics are the retail-grade version of PBO/DSR. Academic and practitioner evidence triangulate — the vault's anti-fooling foundation is not idiosyncratic.
- The crowd's verdict on LLM trading agents matches [[the-alpha-illusion]]'s thesis from the other direction: paper says "reported alpha ≠ deployment evidence"; practitioners say "don't put money on ChatGPT-written code; the graph stops before the tariffs." Two independent evidence paths, one conclusion — stronger than either alone.
- **Revenue-path implication for [[ledger]]:** the LLM use the crowd *pays for* is engineering acceleration (Q7) — tools/skills that make quant dev faster — not signal vending. The "forecasting → tool/skill → quant signal" ranking in the ledger already puts tool/skill second; this is weak crowd-evidence for that order. Label: directional support, not proof.

## Gaps / next Scout passes
- FreqAI (freqtrade's native ML module, 2022+) has no top-thread coverage here — mine freqtrade docs/Discord/GitHub discussions instead of Reddit.
- Broad "machine learning" / "is ML profitable" algotrading megathreads never queried (429s) — likely hold the strongest Q6/Q3 material.
- 2026 threads absent: PullPush ingest lag means the newest wave (agentic frameworks, Claude Code era) is under-sampled; re-mine via search engines when Reddit access is restored.
