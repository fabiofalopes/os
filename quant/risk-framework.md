---
title: "Risk Framework — Sizing, Drawdown, Concentration & Paper→Live"
aliases: [Risk Framework, Position Sizing, Risk Budgeting Framework, Sizing Rules]
type: framework
tags: [risk, sizing, position-sizing, kelly, var, drawdown, concentration, risk-management, framework]
owner: pane-7-risk
status: living
area: risk
created: 2026-07-23
updated: 2026-07-23
code: ~/Projects/trading-agents/quant-research/risk/sizing.py, ~/Projects/trading-agents/quant-research/risk/overlay.py
---

# Risk Framework

> The layer that turns an **alpha signal into a position**. Alpha answers *"what
> and which direction"*; this framework answers *"how big, and when do we stop."*
> Its job is **survival first, compounding second**: size so a run of bad luck or
> a wrong model cannot cause ruin, then let fractional-Kelly growth do its work.
> Every rule below is implemented as an importable function in
> `risk/sizing.py` (see [[#The sizing.py API]]).

## Operating philosophy (the four rules)

1. **Size for the error in your estimates, not the estimates.** Full Kelly and
   raw mean-variance assume $\mu,\Sigma$ are known; they never are. $\mu$ is the
   least estimable quantity and Kelly is *linear* in it, so naive sizing
   systematically overbets. Default to **fractional Kelly** and **shrunk edges**.
   See [[theory-kelly]].
2. **Volatility is the unit of risk, not dollars.** Scale every position to a
   *target volatility* so a 40%-vol name and an 8%-vol name carry comparable
   risk. The single most robust sizing rule in practice. See
   [[Volatility-Managed Portfolios]], [[theory-risk-parity]].
3. **Budget risk top-down, then allocate.** Set a portfolio drawdown / VaR
   budget first; size positions so the *aggregate* can't breach it. Concentration
   and correlation rules cap how much any one name — or one *independent* bet —
   may consume.
4. **Paper→live is a gated ramp, not a switch.** Deploy a small fraction of
   paper size and scale up only while live behavior tracks paper. See [[#Paper → live transition]].

---

## 1. Position sizing

### 1a. Fractional Kelly (edge-based sizing)

Kelly gives the **growth-optimal** bet given an edge ([[theory-kelly]]):

$$\text{Binary: } f^* = p - \frac{q}{b} \qquad
\text{Gaussian: } f^* = \frac{\mu - r_f}{\sigma^2} \qquad
\text{Multi-asset: } w^* = \Sigma^{-1}\mu$$

**Why never full Kelly.** Growth-vs-fraction is a parabola $g(c)/g(1) = 2c - c^2$:
flat near the top, cliff on the downside. Half-Kelly keeps ~75% of the growth for
~¼ the wealth variance; betting $2f^*$ gives *zero* growth. Full Kelly also has
~50% expected max drawdown and assumes perfect estimates. So:

$$\boxed{f_{\text{used}} = c \cdot f^*,\quad c \in [0.25,\,0.5]}$$

**Estimation-error guard (robust Kelly).** Size off a *lower confidence bound* of
the edge, not the point estimate:

$$\mu_{\text{used}} = \mu - z\,\frac{\sigma}{\sqrt{N}}, \qquad
f^*_{\text{robust}} = \frac{\mu_{\text{used}} - r_f}{\sigma^2}$$

Higher confidence $z$ (or fewer obs $N$) → smaller bet. Equivalent in spirit to
Bayesian/shrunk Kelly: "bet half of what you think, on half the edge you think
you have." → `kelly_fraction_gaussian`, `fractional_kelly`, `kelly_with_uncertainty`.

### 1b. Volatility targeting (risk-based sizing)

Independent of any return forecast — you only need $\sigma$, which *is* estimable
([[theory-risk-parity]], GARCH canon). Per name:

$$\boxed{w_i = \frac{\sigma_{\text{target}}}{\sigma_i}}\quad(\text{capped})$$

and for the whole book, a scalar that hits the portfolio vol target
(Moreira–Muir 2017, *Volatility-Managed Portfolios*):

$$\text{scale} = \frac{\sigma_{\text{target}}}{\sigma_{\text{portfolio}}},\qquad
\sigma_{\text{portfolio}} = \sqrt{w^\top \Sigma\, w}$$

**Forecast vol, don't lag it.** Use EWMA/GARCH vol (vol clusters and is
predictable — the Engle/Bollerslev stylized fact), and *de-lever as vol rises* so
dollar-risk stays constant through regimes. → `estimate_vol`, `vol_target_weight`,
`vol_target_scale`, `inverse_vol_weights`, `risk_parity_weights`.

### 1c. Combining them — the recommended rule

`size_position` takes the **most conservative** of the independent budgets, then
applies drawdown de-risking and a hard cap:

$$w_{\text{final}} = \operatorname{sign}(f^*)\;\cdot\;
\underbrace{\min\!\big(w_{\text{kelly}},\; w_{\text{vol}},\; w_{\text{VaR}}\big)}_{\text{governing budget}}
\;\cdot\; m_{\text{drawdown}},\quad \text{clamped to } w_{\max}$$

The `binding_constraint` it returns (which budget governed) is the single most
useful diagnostic in the system — **log it.**

---

## 2. Tail risk budgets: VaR & Expected Shortfall

From [[Jorion Value at Risk]] (the reference that made VaR the industry metric):

$$\text{VaR}_{\alpha} = -\big(\mu_h + z_\alpha\,\sigma_h\big)\,V,\qquad
\sigma_h = \sigma_{\text{ann}}\sqrt{h/252}$$

Inverted to size a position against a VaR budget:

$$\boxed{V_{\max} = \frac{\text{VaR budget}}{z_\alpha\,\sigma_h}}$$

**Prefer Expected Shortfall for control.** VaR is *not* coherent — it fails
subadditivity, so it can reward concentration ([[Coherent Risk Measures]]).
Expected Shortfall / CVaR (mean loss beyond the VaR cutoff) is coherent, convex,
and optimizable ([[CVaR Optimization]]), and is what Basel III/FRTB capitalizes.
Report both; optimize/constrain against ES. Parametric VaR also **understates fat
tails** — use historical simulation or ES when tails matter.
→ `var_parametric`, `var_historical`, `expected_shortfall`, `var_notional`, `es_notional`.

---

## 3. Drawdown limits (survival layer)

Kelly and vol-targeting ignore the *path*; drawdown control fixes that. Losses
reduce risk-taking capacity so a bad streak can't compound into ruin.

**De-risking multiplier** — full size until a soft limit, linear taper to a hard
limit, then flat (go to cash and review):

$$m_{\text{dd}} = \begin{cases}
1 & dd \le dd_{\text{soft}}\\[2pt]
1 - \dfrac{dd - dd_{\text{soft}}}{dd_{\text{hard}} - dd_{\text{soft}}}(1-m_{\min}) & dd_{\text{soft}} < dd < dd_{\text{hard}}\\[4pt]
m_{\min} & dd \ge dd_{\text{hard}}
\end{cases}$$

Defaults: $dd_{\text{soft}}=10\%$, $dd_{\text{hard}}=20\%$, $m_{\min}=0$. Pair with
a **time cool-off** (stay floored $N$ days after a hard-limit hit) in the executor.

**Risk-per-trade / loss budget** (Turtle "unit" logic): size so a stop-out or
stress loss can't cost more than a fixed fraction of the book:
$w = \text{loss-budget} / \text{worst-case-loss}$.

**CPPI** (Perold–Sharpe 1988): $\text{exposure} = m\cdot\text{cushion}$, floor
protects a capital guarantee. → `drawdown_multiplier`, `max_weight_from_loss_budget`,
`cppi_exposure`.

---

## 4. Correlation & concentration rules

Dollar diversification ≠ risk diversification ([[theory-risk-parity]]). Measure
concentration in *risk* space:

- **Effective-N** $= 1/\text{HHI} = 1/\sum w_i^2$: how many equal bets the book
  really is. Equal-weight $N$ names → $N$; one name → 1. Enforce a **floor**
  (default 8).
- **Diversification ratio** $\mathrm{DR} = (w^\top\sigma)/\sqrt{w^\top\Sigma w}\ge 1$:
  ratio of average asset vol to portfolio vol; $\mathrm{DR}^2$ ≈ correlation-adjusted
  effective number of *independent* bets (Choueifaty–Coignard 2008).
- **Correlation-adjusted gross cap**: tighten allowed leverage as average pairwise
  correlation rises — when everything moves together, gross ≈ net risk. Compress
  the cap toward 1 as $\bar\rho\to 1$.

**Hard policy caps** (tune per mandate): single name $\le 10\%$ gross, sector
$\le 25\%$, effective-N $\ge 8$, portfolio daily VaR $\le$ budget. `check_limits`
is the pre-trade gate: any violation → reject/reduce the book.
→ `effective_n`, `diversification_ratio`, `concentration_caps`,
`correlation_adjusted_gross_cap`, `check_limits`.

---

## 5. Paper → live transition

The most dangerous moment is the first real dollar. Transition is a **gated ramp**:

$$\text{live fraction} = \underbrace{\big(f_0 + (1-f_0)\tfrac{t}{T}\big)}_{\text{linear ramp } f_0\to 1}
\;\cdot\; \underbrace{\frac{1}{\max(\hat\sigma_{\text{live}}/\sigma_{\text{model}},\,1)}}_{\text{vol surprise }\le 1}$$

- Start at $f_0=10\%$ of paper size, ramp to 100% over $T\approx 30$ live days.
- **Gate on tracking error**: if live fills/slippage diverge from the model, hold
  at $f_0$ and investigate — do not advance.
- **Vol adjustment**: if realized live vol exceeds the model, scale down so live
  *dollar-risk* matches the paper plan; never lever up on a calm market.
- **Reset rules**: any live drawdown-limit breach → reset to $f_0$; require
  realized slippage $\le$ modeled $\times$ tolerance before advancing.
- **Pre-conditions**: $\ge T$ days of clean paper history with in-sample-consistent
  Sharpe / hit-rate before the ramp even starts.

→ `paper_to_live_ramp`.

---

## The sizing.py API

Importable at `~/Projects/trading-agents/quant-research/risk/sizing.py`
(numpy + pandas only; run `python sizing.py` for a self-test). For the backtest
engineer, the entry points are:

```python
from risk.sizing import (
    size_position,        # signal -> capped, budgeted weight (use this)
    check_limits,         # pre-trade portfolio gate -> {ok, violations, metrics}
    RiskLimits,           # policy knobs (vol target, Kelly frac, caps, VaR, dd)
    # building blocks:
    kelly_fraction_gaussian, fractional_kelly, kelly_with_uncertainty,
    vol_target_weight, vol_target_scale, risk_parity_weights,
    var_notional, expected_shortfall,
    drawdown_multiplier, max_weight_from_loss_budget,
    effective_n, concentration_caps, paper_to_live_ramp,
)
```

**Default mandate** (`RiskLimits`): 15% portfolio vol target, quarter-Kelly,
25% Kelly cap, 10% single-name cap, 2.0 gross cap, 2% daily VaR budget, 10%/20%
soft/hard drawdown, effective-N floor 8. **These are starting points, not gospel
— re-fit per strategy and regime.**

## Wiring into the backtest (`risk/overlay.py`)

The backtest pipeline separates **alpha** (`backtests/strategies.py` → a raw
weight matrix) from the **engine** (`backtests/harness.py`). The risk layer sits
between them as an *overlay* that turns a strategy's raw weights into
risk-budgeted weights the engine runs unchanged:

```python
from backtests import harness as bt, strategies as st
from risk.overlay import apply_risk_overlay
from risk.sizing import RiskLimits

W_raw     = st.ts_momentum(prices, universe)                 # alpha
W_managed = apply_risk_overlay(prices, W_raw,
                               limits=RiskLimits(target_ann_vol=0.08))  # risk
result    = bt.run(prices, W_managed, cost_bps=5)            # engine
```

Per date, using **only trailing info** (respects the harness's 1-bar lag, no
lookahead), the overlay: (1) **vol-targets** the book to `target_ann_vol`,
(2) **de-risks on drawdown** via `drawdown_multiplier`, (3) **caps** single-name
and gross exposure. It reuses `sizing.py` throughout.

Two design decisions that matter (both learned the hard way in backtest):

- **Never lever up.** The vol scale is capped at 1.0 by default — the overlay
  only *reduces* exposure beyond what the alpha chose. Letting trailing-vol
  targeting lever up in calm regimes holds levered exposure into the next vol
  spike and *worsens* drawdown. A risk overlay must never increase risk.
- **Vol refreshes slowly, drawdown reacts daily.** The vol scale refreshes
  month-end (`scale_rebalance="ME"`) to avoid daily churn, but the drawdown
  multiplier is computed daily — capital protection is never lagged to a
  cadence. Sizing is cheap to lag; survival is not.

**Caveat — turnover.** Vol/drawdown scaling adds turnover on top of the
strategy's own rebalancing (a monthly strategy can see 2–5× turnover once
overlaid). Cost it at the harness's `cost_bps`; if it bites, raise
`scale_rebalance` cadence or widen the vol band. Ablate each layer with the
`enable_*` flags.

## How this framework breaks (and the mitigations already in it)

- **Gaussian blind spot**: vol/VaR ignore skew, tails, liquidity. → ES + historical
  VaR + stress scenarios; never parametric VaR alone.
- **Correlation spikes to ~1 in crises**: diversification and risk-parity unravel
  exactly when needed. → correlation-adjusted gross cap + hard drawdown floor.
- **Estimation error in $\mu$**: → fractional Kelly + lower-confidence-bound edge.
- **Procyclical deleveraging**: vol-targeting forces selling into falls. → EWMA
  smoothing, caps on the de-lever rate, trend overlay (see [[theory-risk-parity]]).
- **Model risk / regime change**: → paper→live gates, live-vs-paper tracking-error
  monitoring, drawdown reset.

## Links

- Sizing the edge → [[theory-kelly]] · Return-free risk allocation → [[theory-risk-parity]]
- Vol as a managed quantity → [[Volatility-Managed Portfolios]] · Low-vol → [[Betting-Against-Beta (Low-Volatility)]]
- Tail-risk theory → [[Coherent Risk Measures]] · [[CVaR Optimization]] · [[Jorion Value at Risk]]
- Vol forecasting / sizing as an edge → [[Sinclair Volatility Trading]] · Scaffold → [[theory-markowitz]]
- Execution costs feed the paper→live gate → [[micro-almgren-chriss-2000]]
- Index: [[CANON]] · [[INDEX]]

## Key references

- Kelly (1956); Thorp (1997, 2006); MacLean–Thorp–Ziemba (2011), *The Kelly Capital Growth Investment Criterion*.
- Jorion (2007), *Value at Risk*, 3rd ed. · Artzner et al. (1999), *Coherent Measures of Risk*.
- Rockafellar & Uryasev (2000), *Optimization of CVaR*.
- Moreira & Muir (2017), *Volatility-Managed Portfolios* · Choueifaty & Coignard (2008), *Toward Maximum Diversification*.
- Perold & Sharpe (1988), *Dynamic Strategies for Portfolio Insurance* (CPPI).
- López de Prado, *Advances in Financial Machine Learning* (deflated Sharpe, backtest overfitting — the paper→live discipline).
