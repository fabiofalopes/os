---
title: CANON — Master Map of Essential Trading Knowledge
aliases: [CANON, Trading Canon, Quant Canon]
tags: [quant/canon, quant/index, moc, trading, research]
type: moc
status: merged-with-deep-research
created: 2026-07-23
updated: 2026-07-23
merged-from: CANON-researched (deep-research wf_6b6298b8, adversarially verified)
maintainer: cartographer (pane 1)
---

# CANON — Master Map of Essential Trading Knowledge

> [!abstract] What this is
> The single master map of what a serious algorithmic-trading research→deployment pipeline must be grounded in. Tiered so effort goes where it compounds: **read Tier 1 first, extend with Tier 2, watch Tier 3.** Plus a **Practitioner Books & Wisdom** section — the lore that actually survives contact with real markets ("follow success, study the past").
>
> **Status:** **MERGED** with the adversarially-verified deep-research map ([[CANON-researched]], workflow `wf_6b6298b8`, 107 agents, 25 claims confirmed at 3-vote). Entries the run source-confirmed are marked ✅ (DOI/pages added where verified); entries from the cartographer's memory that the run did *not* cover remain 🟡 — these are **gaps for a follow-up verification round, not rejections**. Wikilinks resolve to the team's live distillation notes in `papers/` and `strategies/`; unresolved `[[links]]` are a deliberate TODO map of notes still to write.

> [!info] How to read an entry
> **Author (Year), "Title"** — venue · [link]
> 💡 *Core idea* → 🔧 *Why it matters in practice* → ✅ *Deploy today*
> `[[Wikilinks]]` point to distillation notes (created on demand / as the team distills).
> **Verification flag:** ✅ = source-verified (adversarial 3-vote via [[CANON-researched]]; DOI shown where confirmed, else domain-consensus). 🟡 = from memory, pending a verification pass — do not cite downstream until de-flagged.

**Tier legend:** 🏛️ **Tier 1** non-negotiable canon · 🧩 **Tier 2** important extensions · 🚀 **Tier 3** modern frontier · 📚 **Practitioner** books & wisdom.

---

## 🏛️ Tier 1 — Non-Negotiable Canon

The load-bearing results. If the pipeline contradicts these without a very good reason, the pipeline is wrong.

### Portfolio theory & asset pricing

**Markowitz (1952), "Portfolio Selection"** — *Journal of Finance* 7(1) 🟡
`doi:10.1111/j.1540-6261.1952.tb01525.x` · [[theory-markowitz]]
💡 Mean-variance optimization: risk is variance, and diversification trades return against it via the covariance matrix.
🔧 Every portfolio-construction and risk model descends from this; also the source of its own failure mode — estimates of Σ are noisy and mean-variance is a "error-maximizing" estimator.
✅ Use it as the *scaffold*, never raw: shrink/covariance-regularize, and constrain weights. See [[theory-black-litterman]] and [[López de Prado AFML]].

**Sharpe (1964), "Capital Asset Prices" (CAPM)** — *Journal of Finance* 19(3) 🟡 · [[theory-capm]]
💡 In equilibrium, expected return is linear in a single systematic factor (market beta); idiosyncratic risk is not priced.
🔧 Gives the first "factor" and the return/risk language (beta, alpha, Sharpe ratio — also Sharpe's). Alpha = return left after paying for beta.
✅ Report every strategy's **alpha vs. the market**, not raw return. A strategy that just re-packages beta is not alpha.

**Ross (1976), "The Arbitrage Theory of Capital Asset Pricing" (APT)** — *J. Economic Theory* 13(3) 🟡 · [[APT]]
💡 Expected returns are linear in *multiple* factors, enforced by no-arbitrage rather than equilibrium.
🔧 Opens the door to multi-factor models without committing to a specific utility/equilibrium — the intellectual ancestor of the factor zoo.
✅ Frame alpha research as "exposure to priced factors"; residual after known factors is the candidate edge.

**Fama & French (1992/1993), "The Cross-Section of Expected Stock Returns" / "Common Risk Factors"** — *JF* / *JFE* ✅ · [[theory-fama-french]]
💡 Size (SMB) and value (HML) plus market explain most cross-sectional return variation → the three-factor model.
🔧 The empirical workhorse benchmark. Most "anomalies" are really factor exposures in disguise.
✅ Benchmark every equity strategy against FF3 (or FF5) before claiming alpha.

**Black & Litterman (1992), "Global Portfolio Optimization"** — *Financial Analysts Journal* 48(5) 🟡 · [[theory-black-litterman]]
💡 Blend the market-cap equilibrium prior with your own views via Bayes to get stable, intuitive portfolio weights.
🔧 Directly fixes Markowitz's instability — the practical way to turn forecasts into positions without corner solutions.
✅ Use as the default portfolio-construction layer when you have heterogeneous alpha views.

**Kelly (1956), "A New Interpretation of Information Rate"** — *Bell System Technical Journal* 35(4) 🟡 · [[theory-kelly]]
💡 The growth-optimal bet size: $f^* = p - q/b$ (edge/odds); betting the full Kelly fraction maximizes long-run geometric growth.
🔧 The principled answer to "how much do I size this?" — and a warning: full Kelly is brutally volatile; over-betting guarantees ruin.
✅ Size at a **fractional Kelly** (¼–½) using your estimated edge; treat full Kelly as an upper bound, never a target. See [[Thorp A Man for All Markets]].

### Derivatives pricing

**Black & Scholes (1973), "The Pricing of Options and Corporate Liabilities"** — *J. Political Economy* 81(3) ✅ · [[theory-black-scholes]]
💡 A replicating portfolio of stock + bond prices a European option; the price is independent of risk preferences.
🔧 Founded quantitative finance and the options industry; "volatility" became a tradable, quotable quantity.
✅ Use BSM as the *quoting convention* (implied vol), not gospel — its assumptions (constant vol, lognormal) are systematically violated. See [[theory-local-vol]].

**Merton (1973), "Theory of Rational Option Pricing"** — *Bell J. Economics* 4(1) 🟡 · [[theory-black-scholes]]
💡 No-arbitrage bounds and the continuous-time replication argument; option value as a contingent claim.
🔧 Gives the arbitrage bounds and the "Greeks" intuition; credit-risk-as-option (Merton model) comes from here.
✅ Enforce no-arbitrage bounds as hard sanity checks in any pricing/risk code.

**Cox, Ingersoll & Ross (1985), "A Theory of the Term Structure of Interest Rates"** — *Econometrica* 53(2) 🟡 · [[CIR Model]]
💡 Equilibrium short-rate model (CIR) with mean reversion and non-negative rates; general equilibrium pricing of claims.
🔧 Template for term-structure / short-rate modeling and for pricing anything rate-dependent.
✅ Use as the reference mean-reverting-rate model; calibrate to the curve for rate-sensitive strategies.

### Volatility modeling

**Engle (1982), "Autoregressive Conditional Heteroscedasticity" (ARCH)** — *Econometrica* 50(4) 🟡 · [[ARCH-GARCH]]
💡 Volatility clusters and is predictable: today's variance depends on yesterday's shocks.
🔧 Formalized the single most exploitable stylized fact — vol clustering / time-varying risk. Nobel 2003.
✅ Model and forecast volatility explicitly; size positions by *predicted* vol, not realized.

**Bollerslev (1986), "Generalized Autoregressive Conditional Heteroskedasticity" (GARCH)** — *J. Econometrics* 31(3) 🟡 · [[ARCH-GARCH]]
💡 GARCH(p,q): parsimonious, persistent volatility model that works in practice.
🔧 The default volatility-forecasting tool for two decades; backbone of risk and position-sizing.
✅ Fit GARCH(1,1) as your baseline vol forecast; it's hard to beat out-of-sample.

**Heston (1993), "A Closed-Form Solution for Options with Stochastic Volatility with Applications to Bond and Currency Options"** — *Review of Financial Studies* 6(2):327–343 ✅ · [[theory-heston]] · `doi:10.1093/rfs/6.2.327`
💡 Stochastic variance with a correlation to price (leverage effect) → closed-form option prices and the volatility smile.
🔧 First tractable model that *explains* the smile/skew; workhorse of equity/FX options desks.
✅ Use Heston (or a local-stochastic-vol variant) to fit the surface; never price exotics under flat BSM vol.

### Market microstructure

**Kyle (1985), "Continuous Auctions and Insider Trading"** — *Econometrica* 53(6) 🟡 · [[micro-kyle-1985]]
💡 An informed trader optimally hides in noise; market depth (λ, "Kyle's lambda") measures price impact.
🔧 Defines **price impact** and the cost of trading large — the reason your backtest dies in live size.
✅ Model slippage as impact ∝ √(your volume / ADV); never backtest without it.

**Glosten & Milgrom (1985), "Bid, Ask and Transaction Prices"** — *J. Financial Economics* 14(1) 🟡 · [[micro-glosten-milgrom-1985]]
💡 The bid-ask spread compensates the market maker for adverse selection from informed traders.
🔧 Explains the spread as an information cost — core to market-making P&L and to estimating execution cost.
✅ Treat the spread as the floor on round-trip cost; estimate the adverse-selection component before quoting.

**Roll (1984), "A Simple Implicit Measure of the Effective Bid-Ask Spread"** — *Journal of Finance* 39(4) 🟡 · [[Roll Spread]]
💡 Negative serial covariance of price changes reveals the effective spread (the "Roll model").
🔧 A data-cheap way to estimate transaction costs from trade prices alone — huge for historical backtests.
✅ Use the Roll estimator to impute costs on tick data where quotes are missing.

### Risk

**Artzner, Delbaen, Eber & Heath (1999), "Coherent Measures of Risk"** — *Mathematical Finance* 9(3) 🟡 · [[Coherent Risk Measures]]
💡 A risk measure should satisfy axioms (subadditivity, etc.); VaR fails subadditivity, Expected Shortfall (CVaR) passes.
🔧 The theoretical reason to prefer **CVaR/ES** over VaR for aggregation and optimization.
✅ Report Expected Shortfall alongside VaR; use ES as the objective in risk-constrained optimization.

---

## 🧩 Tier 2 — Important Extensions

The results that turn canon into a working research program: the factor zoo, its replication crisis, and better risk.

### Factors, momentum & value

**Jegadeesh & Titman (1993), "Returns to Buying Winners and Selling Losers"** — *Journal of Finance* 48(1):65–91 ✅ · [[Cross-Sectional Momentum (12-1)]] · `doi:10.1111/j.1540-6261.1993.tb04702.x`
💡 3–12 month past returns predict future returns (momentum) — the most robust and most traded anomaly.
🔧 The foundation of momentum strategies and of "factor investing" as a business.
✅ Momentum is a default diversifying factor; mind crashes (momentum busts) and turnover costs.

**De Bondt & Thaler (1985), "Does the Stock Market Overreact?"** — *Journal of Finance* 40(3) 🟡 · [[Short-Term Reversal (1-Month)]]
💡 Long-horizon (3–5y) losers outperform past winners → mean reversion / overreaction.
🔧 The behavioral counterweight to momentum; roots of contrarian and value strategies.
✅ Timeframe matters: momentum at months, reversal at years — don't conflate them.

**Asness, Moskowitz & Pedersen (2013), "Value and Momentum Everywhere"** — *Journal of Finance* 68(3) 🟡 · [[Value and Momentum Everywhere]]
💡 Value and momentum exist across asset classes (equities, bonds, FX, commodities) and are negatively correlated.
🔧 Evidence these are *universal* risk/behavioral premia, not data-mined equity quirks; great for diversification.
✅ Combine value + momentum across asset classes; their negative correlation is a free diversification lunch.

**Moskowitz, Ooi & Pedersen (2012), "Time Series Momentum"** — *J. Financial Economics* 104(2) 🟡 · [[Time-Series Momentum (Trend-Following)]]
💡 Each asset's own past return predicts its own future return (trend-following), across 58 instruments.
🔧 The academic backbone of managed-futures / trend-following CTAs.
✅ Time-series momentum (own past) ≠ cross-sectional momentum (rank); implement and test them separately.

**Fama & French (2015), "A Five-Factor Asset Pricing Model"** — *JFE* 116(1) ✅ · [[theory-fama-french]]
💡 Add profitability (RMW) and investment (CMA) to the three factors; value (HML) becomes partly redundant.
🔧 The current standard academic benchmark for equity returns.
✅ Benchmark against FF5; a strategy subsumed by FF5 has no standalone alpha.

**Qian (2005) / Maillard, Roncalli & Teïletche (2010), Risk Parity** — *J. Portfolio Management* / *JPM* 🟡 · [[theory-risk-parity]]
💡 Allocate so each asset (or factor) contributes *equal risk*, not equal capital — leverages low-vol assets up rather than concentrating in high-vol ones.
🔧 The idea behind Bridgewater's "All Weather"; sidesteps estimating $\mu$ entirely (only needs $\Sigma$), directly answering [[theory-markowitz]]'s fatal flaw.
✅ Use risk parity as a robust, $\mu$-free baseline allocation; benchmark your active book against it.

**Novy-Marx (2013), "The Other Side of Value: The Gross Profitability Premium"** — *JFE* 108(1) 🟡 · [[Quality (Profitability) Factor]]
💡 Profitable firms (high gross profits/assets) outperform; "value" works better when you control for quality.
🔧 Gave us the "quality" factor and reframed value investing quantitatively.
✅ Add a profitability/quality screen; it improves value and filters junk.

### The replication crisis (read before trusting any anomaly)

**Harvey, Liu & Zhu (2016), "…and the Cross-Section of Expected Returns"** — *Review of Financial Studies* 29(1):5–68 ✅ · [[Harvey Cross-Section]] · `doi:10.1093/rfs/hhv059`
💡 With 316 documented factors, the t-stat hurdle for a "new" factor should be ~3.0, not 2.0.
🔧 The single most important guardrail against data-mining in factor research.
✅ Require t > 3.0 and out-of-sample / out-of-geography confirmation for any new signal.

**McLean & Pontiff (2016), "Does Academic Research Destroy Stock Return Predictability?"** — *Journal of Finance* 71(1):5–32 ✅ · [[McLean-Pontiff]] · `doi:10.1111/jofi.12365`
💡 Across 97 predictors, anomaly returns fall **26% out-of-sample and 58% post-publication**; the extra 32-point post-publication drop is arbitrage (publication-informed trading), not just statistical bias.
🔧 Publication = crowding. In-sample academic returns overstate what you'll earn.
✅ Haircut every literature-sourced signal for post-publication decay before sizing.

**Hou, Xue & Zhang (2020), "Replicating Anomalies"** — *Review of Financial Studies* 33(5) 🟡 · [[Replicating Anomalies]]
💡 ~65% of 452 published anomalies fail to replicate under stricter screens.
🔧 Most of the "factor zoo" is p-hacking; be ruthless about which anomalies survive.
✅ Start from the replicable minority; treat the rest as hypotheses, not facts.

**Bailey, Borwein, López de Prado & Zhu (2014), "Pseudo-Mathematics and Financial Charlatanism: The Effects of Backtest Overfitting on Out-of-Sample Performance"** — *Notices of the AMS* 61(5):458–471 ✅ · [[Bailey PBO]] · `doi:10.21314/jcf.2016.322` · SSRN 2326253
💡 Standard holdout controls are unreliable for backtests because they ignore the *number of trials* tested; the Probability of Backtest Overfitting (PBO), estimated via Combinatorially Symmetric Cross-Validation (CSCV), is the chance that the in-sample-best configuration underperforms the median out-of-sample.
🔧 The core skeptical tool for discounting backtest-heavy "breakthrough" papers; a backtest that doesn't disclose its trial count is a likely false positive.
✅ Compute PBO (via CSCV) for any strategy you've searched over; treat undisclosed-trial backtests as probably overfit. Pairs with [[López de Prado AFML]].

**Bailey & López de Prado (2014), "The Deflated Sharpe Ratio: Correcting for Selection Bias, Backtest Overfitting and Non-Normality"** — *Journal of Portfolio Management* (2014) ✅ · [[Deflated Sharpe Ratio]] · SSRN 2460551
💡 Corrects a reported Sharpe ratio for selection bias under multiple testing and non-normal returns; the number of trials is the critical missing input — a backtest that hasn't controlled for the search extent is "worthless regardless of reported performance."
🔧 Turns the replication crisis into one reportable number; selection bias + overfitting otherwise route capital to strategies that systematically lose out-of-sample.
✅ Always report the Deflated Sharpe Ratio alongside the raw Sharpe, with the trial count; reinforce with White's Reality Check / Hansen's SPA.

> [!tip] The replication-crisis operating rules (from the verified canon)
> 1. **Treat any backtest that does not disclose its number of trials as a likely false positive** ([[Bailey PBO]], [[Deflated Sharpe Ratio]]).
> 2. **Discount headline anomaly returns by roughly half before sizing capital** ([[McLean-Pontiff]]: 26% OOS / 58% post-publication decay).
> 3. **Require t > 3.0 plus an economic rationale for any new factor** ([[Harvey Cross-Section]]).

### Risk measures & extremes

**Rockafellar & Uryasev (2000), "Optimization of Conditional Value-at-Risk"** — *J. Risk* 2(3) 🟡 · [[CVaR Optimization]]
💡 CVaR (Expected Shortfall) is convex and tractable to optimize, unlike VaR.
🔧 Makes tail-risk a first-class, optimizable constraint.
✅ Optimize portfolios against a CVaR constraint for realistic tail control.

**Jorion (1997/2007), "Value at Risk"** (book) — see [[Jorion Value at Risk]] in Practitioner Books.
💡 The standard reference that made VaR the industry risk metric (and documents its limits).

### Volatility surface & statistical arbitrage

**Dupire (1994), "Pricing with a Smile"** — *Risk* 7(1) 🟡 · [[theory-local-vol]]
💡 Given the full implied-vol surface, a unique *local volatility* function σ(S,t) prices all European options consistently.
🔧 Turns the observed smile into a consistent pricing model; the foundation of exotic pricing and surface interpolation.
✅ Use local vol (or local-stochastic vol) to price path-dependent/exotic payoffs off the quoted surface. See [[Gatheral Volatility Surface]].

**Hagan, Kumar, Lesniewski & Woodward (2002), "Managing Smile Risk" (SABR)** — *Wilmott Magazine* 🟡 · [[SABR Model]]
💡 The SABR stochastic-volatility model gives a closed-form implied-vol approximation and a tractable way to manage smile/skew dynamics across strikes and expiries.
🔧 A desk favorite for interpolating/extrapolating the smile, especially in rates/FX; complements [[theory-local-vol]] and [[theory-heston]].
✅ Use SABR's closed-form smile for fast calibration; watch its known breakdown at very low/negative strikes. *(Flagged by the deep-research run as worth adding; 🟡 pending verification.)*

**Gatheral, Jaisson & Rosenbaum (2018), "Volatility is Rough"** — *Quantitative Finance* 18(6) 🟡 · [[Rough Volatility]]
💡 Realized volatility is better modeled as *rough* (Hurst exponent H ≈ 0.1, fractional Brownian motion) than as a standard diffusion; rough-vol models fit the implied surface strikingly well.
🔧 The modern frontier of volatility modeling; challenges the Markovian/diffusion assumptions of [[theory-heston]] and local vol.
✅ Treat rough vol as the cutting-edge reference for surface fitting; harder to calibrate/simulate, so adopt cautiously. *(🟡 pending verification.)*

**Engle & Granger (1987), "Co-Integration and Error Correction: Representation, Estimation, and Testing"** — *Econometrica* 55(2):251–276 ✅ · [[micro-stat-arb-cointegration]] · `doi:10.2307/1913236`
💡 Non-stationary series can share a stationary long-run relationship (cointegration); deviations mean-revert and an error-correction term captures the pull back.
🔧 The statistical foundation of **pairs/stat-arb trading**: trade the spread of two cointegrated assets, not their levels. Nobel 2003.
✅ Test pairs for cointegration (ADF on the spread) before trading the spread; use the error-correction term for entry/exit. See [[Pairs Trading (Cointegration)]].

**Gatev, Goetzmann & Rouwenhorst (2006), "Pairs Trading: Performance of a Relative-Value Arbitrage Rule"** — *Review of Financial Studies* 19(3) 🟡 · [[Pairs Trading (Cointegration)]]
💡 Classic 1962–2002 evidence that simple distance-based pairs trading earned ~11%/yr excess returns.
🔧 The canonical empirical pairs-trading paper — and a caution: the edge has decayed substantially post-publication.
✅ Treat pairs as a template, not a free lunch: add cointegration filters, transaction costs, and expect post-2002 decay (see [[McLean-Pontiff]]).

---

## 🚀 Tier 3 — Modern Frontier

Where the field is going: ML asset pricing, realistic microstructure, and optimal execution. Deploy with care — this is the live edge *and* the live source of overfitting.

### Machine learning in asset pricing

**Gu, Kelly & Xiu (2020), "Empirical Asset Pricing via Machine Learning"** — *Review of Financial Studies* 33(5):2223–2273 ✅ · [[Gu-Kelly-Xiu ML]] · `doi:10.1093/rfs/hhaa009`
💡 ML (trees, nets) predicts stock returns better than linear models; nonlinearities and interactions matter.
🔧 The landmark showing ML adds real predictive power — and a template for doing it without (too much) leakage.
✅ Use gradient-boosted trees as a strong baseline; replicate their purged-CV discipline or you'll overfit.

**Kelly, Pruitt & Su (2019), "Characteristics Are Covariances: A Unified Model of Risk and Return" (IPCA)** — *JFE* 134(3) 🟡 · [[IPCA]]
💡 Instrumented PCA: firm characteristics load on latent factors — a flexible, interpretable factor model.
🔧 Bridges "characteristics" and "factor" views; strong out-of-sample performance with few factors.
✅ Consider IPCA as a data-driven factor model that stays interpretable.

**Chen, Pelger & Zhu (2024), "Deep Learning in Asset Pricing"** — *Management Science* 🟡 · [[Deep Learning Asset Pricing]]
💡 Deep nets + no-arbitrage (GAN-style) conditionally price assets and build the SDF.
🔧 State-of-the-art nonlinear conditional asset pricing.
✅ Frontier reference; adopt the no-arbitrage regularization idea even if you don't use the full model.

**Avramov, Cheng, Metzker (2023), "Machine Learning vs. Economic Restrictions"** — *Management Science* 🟡 · [[ML vs Economic Restrictions]]
💡 Imposing economic structure on ML improves out-of-sample returns; raw ML overfits.
🔧 The mature lesson: ML + theory > ML alone.
✅ Constrain your ML with priors (sign, monotonicity, economic plausibility).

**Hambly, Xu & Yang (2021/2023), "Recent Advances in Reinforcement Learning in Finance"** — *Mathematical Finance* ✅ · [[Hambly RL Finance]] · `arXiv:2112.04553`
💡 Surveys RL in finance and names the core application areas: optimal execution, portfolio optimization, option pricing & hedging, market making, smart order routing, and robo-advising.
🔧 The best-verified map of *where* RL is being applied in finance — the entry point for the RL frontier.
✅ Use as a reading map for RL applications; note it maps where RL is applied, not which results survive out-of-sample after costs (the open question).

### Microstructure modeling & optimal execution

**Almgren & Chriss (2000/2001), "Optimal Execution of Portfolio Transactions"** — *Journal of Risk* 3(2):1–39 ✅ · [[micro-almgren-chriss-2000]] · `doi:10.21314/jor.2001.041`
*(DOI year is 2001 though the paper is conventionally cited as 2000; the frequently-seen `10.21314/JOR.2000.041` is a dead link.)*
💡 Optimal trading balances market-impact cost against timing risk → an efficient "trading frontier."
🔧 The foundational optimal-execution model; every TWAP/VWAP-optimizer descends from it.
✅ Execute via an impact-vs-risk optimal schedule, never all-at-once; calibrate impact from your own fills.

**Avellaneda & Stoikov (2008), "High-Frequency Trading in a Limit Order Book"** — *Quantitative Finance* 8(3) 🟡 · [[micro-avellaneda-stoikov-2008]]
💡 Optimal market-making quotes: reservation price shifted by inventory, spreads from risk aversion.
🔧 The canonical market-making model; the reference for quoting logic and inventory control.
✅ Center quotes on an inventory-adjusted reservation price; widen with volatility and inventory.

**Cont, Stoikov & Talreja (2010), "A Stochastic Model for Order Book Dynamics"** — *Operations Research* 58(3) 🟡 · [[Cont Order Book]]
💡 A tractable Poisson limit-order-book model linking order flow to price diffusion.
🔧 Gives a structural (not just statistical) model of the book for HFT research.
✅ Use as the null model for LOB simulation and for sanity-checking your order-flow signals.

**Bacry, Mastromatteo & Muzy (2015), "Hawkes Processes in Finance"** — *Market Microstructure and Liquidity* 1(1) 🟡 · [[Hawkes Processes]]
💡 Self-exciting point processes model order arrival, clustering, and endogeneity of markets.
🔧 The standard tool for modeling event clustering and "reflexivity" in the book.
✅ Model order-arrival clustering with Hawkes if you trade at the tick level.

**Bouchaud, Farmer & Lillo (2009), "How Markets Slowly Digest Changes in Supply and Demand"** — *Handbook of Financial Markets* 🟡 · [[micro-market-impact]]
💡 Empirical laws of price impact (concave, ~√size) and long memory of order flow.
🔧 The empirical ground truth your execution and cost models must match.
✅ Assume square-root impact and long order-flow memory in cost models; verify on your own data.

**Easley, López de Prado & O'Hara (2012), "Flow Toxicity and Liquidity in a High-Frequency World" (VPIN)** — *Review of Financial Studies* 25(5) 🟡 · [[micro-order-flow-toxicity]]
💡 Volume-synchronized Probability of Informed Trading (VPIN): a real-time, trade-bucket measure of how toxic (informed) the order flow is.
🔧 Gives a live gauge of adverse-selection risk — when flow turns toxic, market makers get run over; it famously spiked before the 2010 Flash Crash.
✅ Use VPIN (or your own toxicity proxy) as a real-time risk filter: cut size / widen required edge when toxicity rises. Pairs with [[micro-kyle-1985]]'s λ.

**Cartea, Jaimungal & Penalva (2015), "Algorithmic and High-Frequency Trading"** (book) — see [[Cartea Algorithmic HFT]] in Practitioner Books.

---

## 📚 Practitioner Books & Wisdom

The lore that survives contact with real money. "Follow success, study the past."

### Market microstructure & how markets actually work

**Harris, L. (2003), *Trading and Exchanges: Market Microstructure for Practitioners*** — Oxford University Press 🟡 · [[Harris Trading and Exchanges]]
💡 The practitioner's field guide to who trades, why, and how markets are structured (orders, liquidity, dealers, exchanges).
🔧 The single best "how markets actually work" book; makes execution cost and liquidity concrete.
✅ Read before writing any execution or cost model; use its vocabulary to specify your order types.

**O'Hara, M. (1995), *Market Microstructure Theory*** — Blackwell 🟡 · [[O'Hara Market Microstructure]]
💡 The academic microstructure textbook (information-based spread models, inventory, market design).
🔧 The theory backbone behind Harris's practitioner view.
✅ Reference for the formal models; pair with Harris.

### Derivatives & volatility

**Hull, J.C. (1988; 11th ed. 2022), *Options, Futures, and Other Derivatives*** — Pearson 🟡 · [[Hull Options Futures Derivatives]]
💡 The "Bible" of derivatives: pricing, Greeks, hedging, swaps, risk-neutral valuation, across every edition.
🔧 The standard reference on every trading desk; if you need a formula, it's here.
✅ Keep as the desk reference; implement its Greeks and hedging recipes directly.

**Taleb, N.N. (1997), *Dynamic Hedging: Managing Vanilla and Exotic Options*** — Wiley 🟡 · [[Taleb Dynamic Hedging]]
💡 How to actually hedge and manage a real options book under fat tails, jumps, and model risk.
🔧 The practitioner antidote to textbook hedging; obsessed with the tails models ignore.
✅ Respect model risk and fat tails: over-hedge exotics, stress-test, and never trust a single model.

**Gatheral, J. (2006/2011), *The Volatility Surface: A Practitioner's Guide*** — Wiley 🟡 · [[Gatheral Volatility Surface]]
💡 How to build, arbitrage, and model the implied volatility surface (SVI, local & stochastic vol).
🔧 The practitioner standard for vol-surface construction and no-arbitrage constraints.
✅ Use SVI to fit/interpolate the surface; enforce calendar and butterfly no-arbitrage.

**Sinclair, E. (2010/2013), *Volatility Trading*** — Wiley 🟡 · [[Sinclair Volatility Trading]]
💡 How to trade volatility as an asset class: forecasting, position sizing, and the vol risk premium.
🔧 Turns vol from a model input into a tradeable edge with concrete sizing rules.
✅ Trade the vol risk premium with explicit sizing; forecast vol and bet on the forecast error.

### Algorithmic & quantitative trading (build the business)

**López de Prado, M. (2018), *Advances in Financial Machine Learning*** — Wiley 🟡 · [[López de Prado AFML]]
💡 How to apply ML to finance *without* fooling yourself: labeling, CV (purged/embargoed), feature importance, backtest overfitting.
🔧 The modern bible for not overfitting; most "ML trading" fails by ignoring its lessons.
✅ Adopt its data pipeline verbatim: meta-labeling, fractional differentiation, purged k-fold CV, deflated Sharpe.

**López de Prado, M. (2010), *Algorithmic Trading and DMA: An Introduction to Direct Access Trading Strategies*** — 4Myeloma Press 🟡 · [[López de Prado Algorithmic Trading DMA]]
💡 Direct market access, order types, and the mechanics of actually placing and executing orders.
⚠️ *Note:* this is López de Prado's "Algorithmic Trading **and DMA**" — distinct from Chan's *Algorithmic Trading* below.
🔧 Bridges the gap between a signal and a real executed order.
✅ Use its order-type/execution taxonomy when wiring up your broker/venue interface.

**Chan, E. (2009; 2nd ed. 2021), *Quantitative Trading: How to Build Your Own Algorithmic Trading Business*** — Wiley 🟡 · [[Chan Quantitative Trading]]
💡 A practical A→Z of running a small quant operation: idea→backtest→execution→risk, with retail-grade tools.
🔧 The best "how to actually start" book; realistic about the whole business, not just the math.
✅ Follow its workflow for a solo/small pipeline; use its backtest-hygiene checklist.

**Chan, E. (2013), *Algorithmic Trading: Winning Strategies and Their Rationale*** — Wiley 🟡 · [[Chan Algorithmic Trading]]
💡 Concrete strategy families (mean reversion, momentum) with the code and the reasoning behind them.
🔧 Bridges theory to runnable strategies; good source of first strategies to test.
✅ Implement its mean-reversion/momentum templates as baseline strategies, then stress them.

**Chan, E. (2017), *Machine Trading: Deploying Computer Algorithms to Conquer the Markets*** — Wiley 🟡 · [[Chan Machine Trading]]
💡 Deploying ML in live trading: online learning, regime awareness, and production concerns.
🔧 Focuses on the *deployment* gap that most ML research ignores.
✅ Reference for going from backtest to a live, monitored algo.

**Aldridge, I. (2010; 2nd ed. 2013), *High-Frequency Trading: A Practical Guide to Algorithmic Strategies and Trading Systems*** — Wiley 🟡 · [[Aldridge High-Frequency Trading]]
💡 A practitioner survey of HFT strategies, technology, and risk controls.
🔧 Broad, practical overview of the HFT landscape and its infrastructure demands.
✅ Use as an orientation to HFT strategy families and the tech they require. See also the team's [[micro-hft-practitioner]] note.

**Cartea, Jaimungal & Penalva (2015), *Algorithmic and High-Frequency Trading*** — Cambridge University Press 🟡 · [[Cartea Algorithmic HFT]]
💡 Rigorous, math-heavy treatment of optimal execution, market making, and microstructure-based strategies.
🔧 The serious quantitative reference for execution and market-making (more rigorous than Aldridge).
✅ Use its optimal-execution and market-making formulas directly; it's the theory behind [[micro-avellaneda-stoikov-2008]] and [[micro-almgren-chriss-2000]].

### Risk

**Jorion, P. (1997; 3rd ed. 2007), *Value at Risk: The New Benchmark for Managing Financial Risk*** — McGraw-Hill 🟡 · [[Jorion Value at Risk]]
💡 The definitive reference on VaR: estimation, backtesting, and the architecture of a risk function.
🔧 Made VaR the industry standard and documents exactly where it breaks (tails, liquidity).
✅ Implement VaR with proper backtesting (Kupiec/Christoffersen); add ES for the tail. See [[Coherent Risk Measures]].

### Trading psychology & market lore

**Lefèvre, E. (1923), *Reminiscences of a Stock Operator*** — (romanized life of Jesse Livermore) 🟡 · [[Reminiscences of a Stock Operator]]
💡 Timeless trading psychology: tape reading, pyramiding, cutting losses, and the emotional traps that never change.
🔧 A century old and still the best book on trader psychology; markets change, humans don't.
✅ Internalize its lessons on cutting losses and not fighting the trend; re-read after every drawdown.

**Thorp, E. (2017), *A Man for All Markets*** — Random House 🟡 · [[Thorp A Man for All Markets]]
💡 Ed Thorp's autobiography — from beating blackjack (card counting) to founding quantitative hedge funds.
🔧 The origin story of quantitative trading; a model of turning an edge into a disciplined business.
✅ Read for the mindset: find an edge, size it (Kelly), and manage risk ruthlessly.

**Schwager, J. (1989+), *Market Wizards* (series) 🟡 · [[Market Wizards]]**
💡 Interviews with top traders across styles; the recurring themes are risk control and discipline, not prediction.
🔧 The best evidence that *risk management and psychology* beat *forecasting* in practice.
✅ Mine it for the universal rules: cut losses, size conservatively, have a process.

**Douglas, M. (2000), *Trading in the Zone*** — Prentice Hall 🟡 · [[Trading in the Zone]]
💡 The psychology of thinking in probabilities and executing without fear/hesitation.
🔧 Addresses the execution-discipline gap that ruins otherwise-good systems.
✅ Use to build the discipline to follow your system through a losing streak.

---

## 🌐 Practitioner Blogs, Data & Resources

Where working quants actually learn and keep current.

- **arXiv q-fin** — `arxiv.org/list/q-fin/recent` · the live frontier preprint feed; cross-check against the canon before trusting.
- **SSRN** — `ssrn.com` · working papers in finance; where many practitioner-academic results first appear.
- **Alpha Architect** — `alphaarchitect.com` · practitioner factor-investing research (value, momentum, quality), plain-English.
- **QuantStart** — `quantstart.com` · building a quant stack from scratch (data, backtesting, execution) in Python.
- **QuantPedia** — `quantpedia.com` · encyclopedia of published trading strategies/anomalies with out-of-sample tracking.
- **AQR Capital (research)** — `aqr.com/insights/research` · practitioner factor research (Asness et al.); bridges academia and money.
- **Man Institute / AHL** — `man.com/maninstitute` · systematic/CTA and trend-following research.
- **Ernest Chan's blog** — `epchan.blogspot.com` · practical quant trading notes from the *Quantitative Trading* author.
- **Quantitative Finance (Taylor & Francis)** — the journal where much microstructure/HFT work (e.g. [[Avellaneda-Stoikov]]) appears.
- **Marcos López de Prado (Cornell / SSRN)** — backtest-overfitting and ML-finance papers behind [[López de Prado AFML]].

> [!warning] Verification status
> The ✅ entries were adversarially source-verified by the deep-research run ([[CANON-researched]], 3-vote per claim, confirmed against DOI/CrossRef metadata and verbatim abstracts). The remaining 🟡 entries are from the cartographer's memory and were **not** covered by that run — they are gaps for a follow-up verification round, not rejections. Direct live verification from this environment is largely infeasible (WebSearch unavailable; JSTOR/journal sites paywalled), and **identifiers must only be added when source-confirmed, never from memory** (a recalled arXiv ID once resolved to an unrelated paper). The Markowitz (1952) DOI is a long-established canonical identifier. Do not cite a 🟡 entry downstream until it is de-flagged.

---

## 🔗 Related

- [[INDEX]] — master hub linking every team note
- `papers/CANON.md` (workspace) — working copy of this map
- Distillation notes live under `papers/`, `concepts/`, `strategies/` — wikilinks above resolve as they're created.
