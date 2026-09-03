"""How a Large Language Model works — an animated explainer.

Scenes:
  01 Tokenizer     — text becomes token IDs (BPE intuition)
  02 TokenEmbed    — IDs become vectors (bridge from word2vec)
  03 Attention     — Q·K·V: every token looks at every other
  04 Softmax       — attention weights as a heated row
  05 Transformer   — the full block: attention + MLP, stacked
  06 Training      — next-token prediction as the loss
  07 Sampling      — logits → probability → pick (temperature)
  08 Scaling       — more data/layers/params → predictable loss drop

Palette matches the word2vec set (semantic colors, dark background).
"""
from manim import *
import numpy as np

config.background_color = "#131316"

INK     = "#ECECF1"
MUTED   = "#8B8B94"
ACCENT  = "#4C8DFF"   # tokens / main objects
ACCENT2 = "#B580FF"   # weights / matrices / parameters
ACCENT3 = "#3DDC97"   # results / outputs / predictions
ACCENT4 = "#FFB86B"   # attention / warnings / heat
GRID    = "#26262C"

SENT = "the cat sat on the mat"


def t_text(s, size=26, color=None):
    return Text(s, font="Sans", color=color or INK, font_size=size)


# ───────────────────────────── 01 · tokenizer ─────────────────────────────

class Tokenizer(Scene):
    """IDEA: The model never sees words — only integer IDs from a fixed vocabulary."""
    def construct(self):
        title = Text("1 · Tokenization", color=MUTED, font_size=28)
        title.to_edge(UP)

        words = SENT.split()
        toks = VGroup(*[t_text(w) for w in words])
        toks.arrange(RIGHT, buff=0.55).shift(UP * 1.4)

        ids = VGroup()
        for i, w in enumerate(words):
            box = RoundedRectangle(corner_radius=0.1, width=0.9, height=0.7,
                                   stroke_color=ACCENT, fill_color="#1B2A44",
                                   fill_opacity=1)
            num = Text(str(1000 + i * 137), color=INK, font_size=26)
            num.move_to(box)
            ids.add(VGroup(box, num))
        ids.arrange(RIGHT, buff=0.3).shift(DOWN * 0.3)

        arrows = VGroup(*[
            Arrow(t.get_bottom(), i.get_top(), buff=0.12, color=MUTED, stroke_width=3)
            for t, i in zip(toks, ids)])

        self.play(Write(title))
        self.play(LaggedStart(*[FadeIn(t, shift=UP * 0.2) for t in toks], lag_ratio=0.1))
        self.play(LaggedStart(*[GrowArrow(a) for a in arrows], lag_ratio=0.1))
        self.play(LaggedStart(*[FadeIn(i, scale=0.7) for i in ids], lag_ratio=0.1))
        self.wait()

        # subword point: rare word splits
        rare = t_text("tokenization", 26, ACCENT4).move_to(toks[4], aligned_edge=ORIGIN)
        rare.shift(DOWN * 2.2)
        pieces = VGroup(
            t_text("token", 24, ACCENT), t_text("iza", 24, ACCENT3), t_text("tion", 24, ACCENT2))
        pieces.arrange(RIGHT, buff=0.2).next_to(rare, DOWN, buff=0.4)
        sub_ids = VGroup(
            t_text("4217", 24, ACCENT), t_text("882", 24, ACCENT3), t_text("315", 24, ACCENT2))
        sub_ids.arrange(RIGHT, buff=0.35).next_to(pieces, DOWN, buff=0.3)

        note = t_text("any word → pieces from a ~100k vocabulary", 22, MUTED)
        note.to_edge(DOWN, buff=0.4)

        self.play(FadeIn(rare, shift=UP * 0.2))
        self.play(FadeIn(pieces), FadeIn(sub_ids))
        self.play(FadeIn(note))
        self.wait(2)
        self.play(FadeOut(VGroup(title, toks, ids, arrows, rare, pieces, sub_ids, note)))


# ─────────────────────────── 02 · token → vector ─────────────────────────

class TokenEmbed(Scene):
    """IDEA: each token ID picks a learned row — the model's working representation."""
    def construct(self):
        title = Text("2 · Embeddings: IDs become vectors", color=MUTED, font_size=28)
        title.to_edge(UP)

        boxes = VGroup()
        for i in range(5):
            b = RoundedRectangle(corner_radius=0.08, width=1.1, height=0.75,
                                 stroke_color=ACCENT, fill_color="#1B2A44", fill_opacity=1)
            n = Text(str(1000 + i * 137), color=INK, font_size=24).move_to(b)
            boxes.add(VGroup(b, n))
        boxes.arrange(RIGHT, buff=0.5).shift(UP * 1.3)

        rows = VGroup()
        rng = np.random.default_rng(3)
        for i in range(5):
            vals = VGroup(*[MathTex(f"{v:+.1f}", font_size=28, color=INK)
                            for v in rng.uniform(-1, 1, 4)])
            vals.arrange(RIGHT, buff=0.45)
            rows.add(vals)
        rows.arrange(DOWN, buff=0.45, aligned_edge=LEFT).shift(DOWN * 0.5)
        rows.to_edge(LEFT, buff=1.2)

        arrows = VGroup(*[
            Arrow(b.get_bottom(), r.get_left() + LEFT * 0.3, buff=0.12,
                  color=MUTED, stroke_width=3)
            for b, r in zip(boxes, rows)])

        dim_lbl = MathTex(r"d = 4096 \ \text{(typically)}", color=MUTED, font_size=30)
        dim_lbl.next_to(rows, DOWN, buff=0.4)

        self.play(Write(title))
        self.play(LaggedStart(*[FadeIn(b) for b in boxes], lag_ratio=0.1))
        self.play(LaggedStart(*[GrowArrow(a) for a in arrows], lag_ratio=0.1))
        self.play(LaggedStart(*[FadeIn(r, shift=RIGHT * 0.3) for r in rows], lag_ratio=0.12))
        self.play(FadeIn(dim_lbl))
        self.wait()

        note = VGroup(
            t_text("every token flows in as a vector", 24, ACCENT),
            t_text("every layer transforms it into a new one", 22, MUTED),
        ).arrange(DOWN, buff=0.25, aligned_edge=LEFT).to_edge(DOWN, buff=0.5).shift(RIGHT * 1.8)
        self.play(FadeIn(note))
        self.wait(2)
        self.play(FadeOut(VGroup(title, boxes, arrows, rows, dim_lbl, note)))


# ───────────────────────────── 03 · attention ────────────────────────────

class Attention(Scene):
    """IDEA: each token asks a question (Q), every token offers a key (K),
    the match strength decides how much value (V) flows back."""
    def construct(self):
        title = Text("3 · Self-attention: every token looks around", color=MUTED, font_size=28)
        title.to_edge(UP)

        words = SENT.split()[:5]
        toks = VGroup(*[t_text(w, 22) for w in words])
        toks.arrange(RIGHT, buff=1.3).shift(UP * 1.0)
        dots = VGroup(*[Dot(t.get_bottom() + DOWN * 0.35, radius=0.07, color=ACCENT)
                        for t in toks])

        self.play(Write(title))
        self.play(LaggedStart(*[FadeIn(t) for t in toks], lag_ratio=0.1),
                  LaggedStart(*[GrowFromCenter(d) for d in dots], lag_ratio=0.1))
        self.wait(0.5)

        # "sat" attends to "cat" and "mat" strongly
        center = 2
        lens = VGroup()
        for j, strength in [(1, 1.0), (4, 0.85), (0, 0.35), (3, 0.3)]:
            a = Arrow(dots[center].get_bottom(), dots[j].get_bottom(),
                      buff=0.15, stroke_width=3 + 7 * strength,
                      color=ACCENT4).set_opacity(0.3 + 0.7 * strength)
            lens.add(a)
        self.play(LaggedStart(*[GrowArrow(a) for a in lens], lag_ratio=0.15))

        qkv = VGroup(
            MathTex(r"Q = \text{what am I looking for?}", color=ACCENT, font_size=30),
            MathTex(r"K = \text{what do I contain?}", color=ACCENT2, font_size=30),
            MathTex(r"V = \text{what do I pass on?}", color=ACCENT3, font_size=30),
        ).arrange(DOWN, buff=0.35, aligned_edge=LEFT).to_edge(DOWN, buff=0.6).shift(LEFT * 0.8)
        qkv_labels = VGroup(*[t_text("query", 20, MUTED), t_text("key", 20, MUTED),
                              t_text("value", 20, MUTED)])
        for row, lbl in zip(qkv, qkv_labels):
            lbl.next_to(row, RIGHT, buff=0.4)

        formula = MathTex(r"\text{Attention}(Q,K,V) = \mathrm{softmax}\!\left(\frac{QK^\top}{\sqrt{d}}\right)V",
                          color=INK, font_size=34)
        formula.to_edge(DOWN, buff=0.4)

        self.play(LaggedStart(*[FadeIn(r, shift=RIGHT * 0.2) for r in qkv], lag_ratio=0.2))
        self.play(LaggedStart(*[FadeIn(l) for l in qkv_labels], lag_ratio=0.15))
        self.wait(1)
        self.play(FadeOut(qkv), FadeOut(qkv_labels))
        self.play(Write(formula))
        self.wait(2)
        self.play(FadeOut(VGroup(title, toks, dots, lens, formula)))


# ───────────────────────────── 04 · softmax row ──────────────────────────

class SoftmaxRow(Scene):
    """IDEA: one attention row = a probability distribution over which tokens matter."""
    def construct(self):
        title = Text("4 · The attention row for “sat”", color=MUTED, font_size=28)
        title.to_edge(UP)

        words = SENT.split()[:5]
        weights = [0.08, 0.46, 0.02, 0.09, 0.35]  # attention from "sat"

        cells = VGroup()
        for w, p in zip(words, weights):
            h = 0.5 + 2.6 * p
            rect = Rectangle(width=1.0, height=h, stroke_color=GRID, stroke_width=1.5,
                             fill_color=ACCENT4, fill_opacity=0.15 + 0.85 * p)
            rect.align_to(ORIGIN, DOWN).shift(DOWN * 1.1)
            cells.add(rect)
        cells.arrange(RIGHT, buff=0.45, aligned_edge=DOWN)

        labels = VGroup(*[t_text(w, 22) for w in words])
        for l, c in zip(labels, cells):
            l.next_to(c, DOWN, buff=0.25)
        probs = VGroup(*[MathTex(f"{p:.2f}", font_size=26,
                                 color=ACCENT4 if p > 0.3 else MUTED)
                         for p in weights])
        for p_, c in zip(probs, cells):
            p_.next_to(c, UP, buff=0.25)

        total = MathTex(r"\sum = 1", color=MUTED, font_size=30)
        total.to_edge(RIGHT, buff=1.0).shift(UP * 0.5)

        self.play(Write(title))
        self.play(LaggedStart(*[GrowFromEdge(rect, DOWN) for rect in cells], lag_ratio=0.12))
        self.play(LaggedStart(*[FadeIn(l) for l in labels], lag_ratio=0.08))
        self.play(LaggedStart(*[FadeIn(p_) for p_ in probs], lag_ratio=0.08))
        self.play(FadeIn(total))

        note = t_text("“sat” pulls mostly from “cat” and “mat” — verbs care about their actors",
                      22, MUTED).to_edge(DOWN, buff=0.5)
        self.play(FadeIn(note))
        self.wait(2)
        self.play(FadeOut(VGroup(title, cells, labels, probs, total, note)))


# ───────────────────────────── 05 · block ────────────────────────────────

class TransformerBlock(Scene):
    """IDEA: one block = attention (mix across tokens) + MLP (think per token), stacked N times."""
    def construct(self):
        title = Text("5 · The transformer block", color=MUTED, font_size=28)
        title.to_edge(UP)

        box_attn = RoundedRectangle(corner_radius=0.15, width=4.6, height=1.0,
                                    stroke_color=ACCENT4, fill_color="#2A2214",
                                    fill_opacity=1)
        t_attn = t_text("self-attention", 26).move_to(box_attn)
        t_attn_sub = t_text("tokens mix with tokens", 18, MUTED)
        t_attn_sub.next_to(t_attn, DOWN, buff=0.12)
        attn = VGroup(box_attn, t_attn, t_attn_sub)

        box_mlp = RoundedRectangle(corner_radius=0.15, width=4.6, height=1.0,
                                   stroke_color=ACCENT2, fill_color="#221A2E",
                                   fill_opacity=1)
        t_mlp = t_text("MLP  (feed-forward)", 26).move_to(box_mlp)
        t_mlp_sub = t_text("each token thinks alone", 18, MUTED)
        t_mlp_sub.next_to(t_mlp, DOWN, buff=0.12)
        mlp = VGroup(box_mlp, t_mlp, t_mlp_sub)

        attn.shift(UP * 1.1)
        mlp.shift(DOWN * 0.6)

        addnorm1 = t_text("+ add & norm", 20, MUTED)
        addnorm1.next_to(attn, DOWN, buff=0.35)
        addnorm2 = t_text("+ add & norm", 20, MUTED)
        addnorm2.next_to(mlp, DOWN, buff=0.35)

        flow = Arrow(DOWN * 2.6 + RIGHT * 3.4, UP * 2.0 + RIGHT * 3.4,
                     buff=0.2, color=MUTED, stroke_width=4)
        flow_lbl = t_text("residual stream", 20, MUTED).rotate(-PI / 2)
        flow_lbl.next_to(flow, RIGHT, buff=0.2)

        self.play(Write(title))
        self.play(FadeIn(attn, shift=UP * 0.3))
        self.play(FadeIn(addnorm1))
        self.play(FadeIn(mlp, shift=UP * 0.3))
        self.play(FadeIn(addnorm2))
        self.play(GrowArrow(flow), FadeIn(flow_lbl))
        self.wait()

        # stack it
        stack_lbl = t_text("× N layers  (12 … 100+)", 28, INK)
        stack_lbl.to_edge(DOWN, buff=0.9)
        copies = VGroup(*[attn.copy().set_opacity(0.14 + 0.1 * i) for i in range(4)])
        copies.arrange(RIGHT, buff=0.6).scale(0.45).to_edge(DOWN, buff=0.4)
        self.play(FadeIn(stack_lbl))
        self.play(LaggedStart(*[FadeIn(c, shift=UP * 0.3) for c in copies], lag_ratio=0.15))
        self.wait(2)
        self.play(FadeOut(VGroup(title, attn, addnorm1, mlp, addnorm2, flow,
                                 flow_lbl, stack_lbl, copies)))


# ───────────────────────────── 06 · training ─────────────────────────────

class Training(Scene):
    """IDEA: training = hide the next token, predict it, nudge all weights by the error."""
    def construct(self):
        title = Text("6 · Training: predict the next token", color=MUTED, font_size=28)
        title.to_edge(UP)

        words = "the cat sat on the".split()
        answer = "mat"

        toks = VGroup(*[t_text(w, 26) for w in words])
        toks.arrange(RIGHT, buff=0.5).shift(UP * 1.3)
        blank = RoundedRectangle(corner_radius=0.1, width=1.2, height=0.7,
                                 stroke_color=ACCENT4, fill_opacity=0)
        blank.next_to(toks, RIGHT, buff=0.5)
        qmark = t_text("?", 34, ACCENT4).move_to(blank)

        self.play(Write(title))
        self.play(LaggedStart(*[FadeIn(t) for t in toks], lag_ratio=0.1))
        self.play(Create(blank), Write(qmark))
        self.wait(0.5)

        # candidate predictions with probabilities
        cands = VGroup(
            VGroup(t_text("mat", 24), MathTex("0.71", font_size=24, color=ACCENT3)),
            VGroup(t_text("floor", 24), MathTex("0.12", font_size=24, color=MUTED)),
            VGroup(t_text("sofa", 24), MathTex("0.09", font_size=24, color=MUTED)),
            VGroup(t_text("moon", 24), MathTex("0.01", font_size=24, color=MUTED)),
        )
        for c in cands:
            c.arrange(RIGHT, buff=0.35)
        cands.arrange(DOWN, buff=0.3, aligned_edge=LEFT).shift(DOWN * 0.2)
        cands.to_edge(LEFT, buff=2.2)

        arrows = VGroup(*[Arrow(blank.get_bottom() + DOWN * 0.1, c.get_left() + LEFT * 0.2,
                                buff=0.15, color=GRID, stroke_width=2.5)
                          for c in cands])

        self.play(LaggedStart(*[GrowArrow(a) for a in arrows], lag_ratio=0.08))
        self.play(LaggedStart(*[FadeIn(c, shift=RIGHT * 0.2) for c in cands], lag_ratio=0.1))
        self.wait()

        # loss update
        loss_box = VGroup(
            MathTex(r"\mathcal{L} = -\log p(\text{correct token})", color=ACCENT2, font_size=32),
            t_text("backprop nudges every weight in the model", 22, MUTED),
        ).arrange(DOWN, buff=0.3).to_edge(DOWN, buff=0.5)
        self.play(FadeIn(loss_box))

        note = t_text("repeat × trillions of tokens", 26, ACCENT)
        note.next_to(loss_box, UP, buff=0.5)
        self.play(Write(note))
        self.wait(2)
        self.play(FadeOut(VGroup(title, toks, blank, qmark, arrows, cands, loss_box, note)))


# ───────────────────────────── 07 · sampling ─────────────────────────────

class Sampling(Scene):
    """IDEA: generation is a loop — predict a distribution, pick one, append, repeat."""
    def construct(self):
        title = Text("7 · Generation: sampling the next token", color=MUTED, font_size=28)
        title.to_edge(UP)

        ctx_words = "the cat sat on the".split()
        ctx = VGroup(*[t_text(w, 24, MUTED) for w in ctx_words])
        ctx.arrange(RIGHT, buff=0.4).shift(UP * 1.4)

        self.play(Write(title), FadeIn(ctx))

        bar_words = ["mat", "floor", "sofa", "dog"]
        bar_ps = [0.62, 0.18, 0.12, 0.08]

        bars = VGroup()
        for w, p in zip(bar_words, bar_ps):
            b = Rectangle(width=0.9, height=0.1 + 2.2 * p, stroke_width=1.5,
                          stroke_color=GRID, fill_color=ACCENT, fill_opacity=0.85)
            b.align_to(ORIGIN, DOWN).shift(DOWN * 1.5)
            bars.add(b)
        bars.arrange(RIGHT, buff=0.5, aligned_edge=DOWN)
        blabels = VGroup(*[t_text(w, 20) for w in bar_words])
        for l, b in zip(blabels, bars):
            l.next_to(b, DOWN, buff=0.2)
        bprobs = VGroup(*[MathTex(f"{p:.2f}", font_size=22, color=MUTED) for p in bar_ps])
        for p_, b in zip(bprobs, bars):
            p_.next_to(b, UP, buff=0.2)

        self.play(LaggedStart(*[GrowFromEdge(b, DOWN) for b in bars], lag_ratio=0.1))
        self.play(LaggedStart(*[FadeIn(l) for l in blabels], lag_ratio=0.06))
        self.play(LaggedStart(*[FadeIn(p_) for p_ in bprobs], lag_ratio=0.06))

        temp_lbl = t_text("temperature = 0 → always “mat”   ·   higher → surprise", 20, MUTED)
        temp_lbl.to_edge(DOWN, buff=0.4)

        # sample: flash "mat"
        cursor = SurroundingRectangle(bars[0], color=ACCENT3, buff=0.15)
        picked = t_text("mat", 30, ACCENT3).next_to(ctx, RIGHT, buff=0.5)
        self.play(Create(cursor), run_time=0.8)
        self.play(TransformFromCopy(blabels[0], picked))
        self.play(FadeIn(temp_lbl))
        self.wait(2)
        self.play(FadeOut(VGroup(title, ctx, bars, blabels, bprobs, cursor, picked, temp_lbl)))


# ───────────────────────────── 08 · scaling ──────────────────────────────

class Scaling(Scene):
    """IDEA: loss falls predictably with scale — compute, data, parameters in concert."""
    def construct(self):
        title = Text("8 · Scaling laws", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[0, 10, 1], y_range=[0, 4, 1],
            x_length=9.5, y_length=5.0,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
            y_axis_config={"include_ticks": True, "tick_size": 0.06},
        ).shift(DOWN * 0.3)
        x_lbl = t_text("compute  (log scale)", 20, MUTED).next_to(axes.x_axis, DOWN, buff=0.25)
        y_lbl = t_text("loss", 20, MUTED).next_to(axes.y_axis, UP, buff=0.2)

        # power-law-ish curve
        curve = axes.plot(lambda x: 3.4 * x ** (-0.25) + 0.35, x_range=[0.5, 10],
                          color=ACCENT, stroke_width=5)

        pts_x = [1.5, 3, 5, 8]
        pts = VGroup(*[Dot(axes.c2p(x, 3.4 * x ** (-0.25) + 0.35), radius=0.08, color=ACCENT3)
                       for x in pts_x])

        model_names = ["small", "medium", "large", "frontier"]
        tags = VGroup(*[t_text(m, 18, MUTED) for m in model_names])
        for t, p in zip(tags, pts):
            t.next_to(p, UP, buff=0.2)

        formula = MathTex(r"\mathcal{L} \sim C^{-\alpha}", color=ACCENT2, font_size=38)
        formula.to_corner(UR, buff=0.8)

        note = t_text("smooth, predictable improvement — the reason scale is the strategy",
                      22, MUTED).to_edge(DOWN, buff=0.5)

        self.play(Write(title), Create(axes), FadeIn(x_lbl), FadeIn(y_lbl))
        self.play(Create(curve))
        self.play(LaggedStart(*[GrowFromCenter(p) for p in pts], lag_ratio=0.25))
        self.play(LaggedStart(*[FadeIn(t) for t in tags], lag_ratio=0.2))
        self.play(Write(formula))
        self.play(FadeIn(note))
        self.wait(2)


# ───────────────────────────── 09 · KV cache ─────────────────────────────

class KVCache(Scene):
    """IDEA: attention only needs NEW queries — past keys/values are cached, never recomputed."""
    def construct(self):
        title = Text("9 · KV-caching: why generation is fast", color=MUTED, font_size=28)
        title.to_edge(UP)

        words = "the cat sat on the".split()
        toks = VGroup(*[t_text(w, 22, MUTED) for w in words])
        toks.arrange(RIGHT, buff=0.7).shift(UP * 1.5)

        # cache column: K and V cells for each past token
        cache_k = VGroup()
        cache_v = VGroup()
        for _ in words:
            ck = Rectangle(width=0.55, height=0.4, stroke_color=ACCENT2,
                           fill_color="#221A2E", fill_opacity=1, stroke_width=1.5)
            cv = Rectangle(width=0.55, height=0.4, stroke_color=ACCENT3,
                           fill_color="#14281F", fill_opacity=1, stroke_width=1.5)
            cache_k.add(ck); cache_v.add(cv)
        cache_k.arrange(RIGHT, buff=0.16).shift(DOWN * 0.1)
        cache_v.arrange(RIGHT, buff=0.16).shift(DOWN * 0.7)
        k_lbl = MathTex("K", color=ACCENT2, font_size=30).next_to(cache_k, LEFT, buff=0.3)
        v_lbl = MathTex("V", color=ACCENT3, font_size=30).next_to(cache_v, LEFT, buff=0.3)
        cache_box = SurroundingRectangle(VGroup(cache_k, cache_v, k_lbl, v_lbl),
                                         color=GRID, buff=0.25, corner_radius=0.15)
        cache_title = t_text("the cache  (grows by one column per token)", 20, MUTED)
        cache_title.next_to(cache_box, DOWN, buff=0.2)

        self.play(Write(title), FadeIn(toks))
        self.play(Create(cache_box), FadeIn(k_lbl), FadeIn(v_lbl))
        self.play(LaggedStart(*[FadeIn(c, scale=0.6) for c in cache_k], lag_ratio=0.1),
                  LaggedStart(*[FadeIn(c, scale=0.6) for c in cache_v], lag_ratio=0.1))
        self.play(FadeIn(cache_title))
        self.wait()

        # naive: recompute everything vs cached: only new token
        naive = VGroup(
            t_text("without cache:", 22, ACCENT4),
            t_text("step N recomputes K,V for ALL N tokens", 20, MUTED),
            MathTex(r"O(N^2) \text{ total work}", font_size=26, color=ACCENT4),
        ).arrange(DOWN, buff=0.2, aligned_edge=LEFT)
        cached = VGroup(
            t_text("with cache:", 22, ACCENT3),
            t_text("step N computes K,V for the ONE new token", 20, MUTED),
            MathTex(r"O(N) \text{ per step}", font_size=26, color=ACCENT3),
        ).arrange(DOWN, buff=0.2, aligned_edge=LEFT)
        both = VGroup(naive, cached).arrange(RIGHT, buff=1.0)
        both.to_edge(DOWN, buff=0.5)

        self.play(FadeIn(naive, shift=UP * 0.2))
        self.play(FadeIn(cached, shift=UP * 0.2))
        self.wait()

        # new token arrives: only one new column appears
        new_tok = t_text("mat", 22, ACCENT3)
        new_tok.next_to(toks, RIGHT, buff=0.7)
        new_ck = Rectangle(width=0.55, height=0.4, stroke_color=ACCENT3,
                           fill_color="#14281F", fill_opacity=1, stroke_width=2.5)
        new_ck.next_to(cache_k, RIGHT, buff=0.16)
        new_cv = Rectangle(width=0.55, height=0.4, stroke_color=ACCENT3,
                           fill_color="#14281F", fill_opacity=1, stroke_width=2.5)
        new_cv.next_to(cache_v, RIGHT, buff=0.16)
        glow = VGroup(new_ck, new_cv)

        self.play(FadeIn(new_tok, shift=UP * 0.3))
        self.play(TransformFromCopy(new_tok, new_ck), TransformFromCopy(new_tok, new_cv))
        self.play(Indicate(glow, color=ACCENT4, scale_factor=1.15))
        self.wait(2)
        self.play(FadeOut(VGroup(title, toks, cache_k, cache_v, k_lbl, v_lbl,
                                 cache_box, cache_title, naive, cached,
                                 new_tok, glow)))


# ─────────────────────────── 10 · the memory bill ────────────────────────

class ContextWindow(Scene):
    """IDEA: the cache is why context costs memory — every token pays rent per layer."""
    def construct(self):
        title = Text("10 · Context is a memory bill", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[0, 10, 1], y_range=[0, 10, 1],
            x_length=9.0, y_length=5.0,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
        ).shift(DOWN * 0.3)
        x_lbl = t_text("context length (tokens)", 20, MUTED).next_to(axes.x_axis, DOWN, buff=0.25)
        y_lbl = t_text("KV-cache memory", 20, MUTED).next_to(axes.y_axis, UP, buff=0.2)

        # N tokens × 2 (K,V) × d dims × L layers — grows linearly, huge in practice
        curve = axes.plot(lambda x: 0.02 * x ** 2, x_range=[0, 10],
                          color=ACCENT2, stroke_width=5)

        self.play(Write(title), Create(axes), FadeIn(x_lbl), FadeIn(y_lbl))
        self.play(Create(curve))

        facts = VGroup(
            MathTex(r"\text{memory} = N \times 2 \times d \times L", color=INK, font_size=32),
            t_text("128k context · 4096 dims · 80 layers", 22, MUTED),
            t_text("≈ tens of GB per sequence — before the batch", 22, ACCENT4),
        ).arrange(DOWN, buff=0.3, aligned_edge=LEFT).to_corner(UR, buff=0.7)

        self.play(LaggedStart(*[FadeIn(f, shift=LEFT * 0.2) for f in facts], lag_ratio=0.25))

        note = t_text("this is the problem MQA / GQA / sliding windows solve", 22, ACCENT3)
        note.to_edge(DOWN, buff=0.5)
        self.play(FadeIn(note))
        self.wait(2)


# ─────────────────────────── 11 · emergence ──────────────────────────────

class Emergence(Scene):
    """IDEA: loss improves smoothly, but abilities arrive in jumps — arithmetic at scale N,
    multi-step reasoning at scale N+k. Nobody put them there on purpose."""
    def construct(self):
        title = Text("11 · Emergence: smooth loss, jumpy abilities", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[0, 10, 1], y_range=[0, 1, 0.25],
            x_length=9.0, y_length=5.0,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
        ).shift(DOWN * 0.2)
        x_lbl = t_text("model scale (log)", 20, MUTED).next_to(axes.x_axis, DOWN, buff=0.25)
        y_lbl = t_text("task accuracy", 20, MUTED).next_to(axes.y_axis, UP, buff=0.2)

        # flat-near-zero then sigmoid jump
        f = lambda x: 1 / (1 + np.exp(-(x - 6.5) * 1.8)) * 0.95
        curve = axes.plot(f, x_range=[0, 10], color=ACCENT, stroke_width=5)

        self.play(Write(title), Create(axes), FadeIn(x_lbl), FadeIn(y_lbl))
        self.play(Create(curve))

        # annotation: "can't do arithmetic" zone vs "can" zone
        zone1 = t_text("cannot do 3-digit arithmetic", 20, ACCENT4)
        zone1.move_to(axes.c2p(3, 0.55))
        zone2 = t_text("suddenly can", 22, ACCENT3)
        zone2.move_to(axes.c2p(8.4, 0.55))

        jump_line = DashedLine(axes.c2p(6.5, 0), axes.c2p(6.5, 0.95), color=GRID)
        self.play(FadeIn(zone1), Create(jump_line))
        self.play(FadeIn(zone2, shift=UP * 0.2))

        claim = VGroup(
            t_text("the loss curve never announced this", 24, INK),
            t_text("next-token prediction pressure alone built the circuit", 22, MUTED),
        ).arrange(DOWN, buff=0.25, aligned_edge=LEFT).to_edge(DOWN, buff=0.5)
        self.play(FadeIn(claim))
        self.wait(2)
        self.play(FadeOut(VGroup(title, axes, x_lbl, y_lbl, curve,
                                 zone1, zone2, jump_line, claim)))


# ─────────────────────── 12 · heartbeat → understanding ─────────────────

class Heartbeat(Scene):
    """IDEA: 'just predict the next token' sounds trivial — but to predict anything well
    you are forced to model whatever produced it. Compression = understanding."""
    def construct(self):
        title = Text("12 · The heartbeat: why next-token is enough", color=MUTED, font_size=28)
        title.to_edge(UP)

        # the loop as a pulse
        ctx_words = ["the", "cat", "sat", "on", "the"]
        ctx = VGroup(*[t_text(w, 24, MUTED) for w in ctx_words])
        ctx.arrange(RIGHT, buff=0.45).shift(UP * 1.6)
        new = t_text("mat", 30, ACCENT3)
        new.next_to(ctx, RIGHT, buff=0.6)

        self.play(Write(title), FadeIn(ctx))
        self.play(FadeIn(new, scale=0.6))

        pulse = SurroundingRectangle(new, color=ACCENT4, buff=0.18)
        for _ in range(3):
            self.play(Create(pulse), run_time=0.35)
            self.play(FadeOut(pulse), run_time=0.25)
        self.wait(0.5)

        # the argument, stepwise
        steps = VGroup(
            VGroup(MathTex("1.", font_size=30, color=ACCENT),
                   t_text("to predict the next token after “the prime factors of 91 are”", 22, INK)),
            VGroup(MathTex("2.", font_size=30, color=ACCENT),
                   t_text("you must actually factor 91", 22, INK)),
            VGroup(MathTex("3.", font_size=30, color=ACCENT),
                   t_text("to predict code, you must track the state of the program", 22, INK)),
            VGroup(MathTex("4.", font_size=30, color=ACCENT),
                   t_text("prediction pressure forces internal models of the world", 22, ACCENT3)),
        )
        for s in steps:
            s.arrange(RIGHT, buff=0.3, aligned_edge=ORIGIN)
        steps.arrange(DOWN, buff=0.4, aligned_edge=LEFT)
        steps.to_edge(DOWN, buff=0.5).scale(0.92)

        for s in steps:
            self.play(FadeIn(s, shift=RIGHT * 0.2))
            self.wait(0.4)

        closer = t_text("compression is understanding — the loss is the teacher",
                        26, ACCENT2)
        closer.next_to(steps, UP, buff=0.5)
        self.play(Write(closer))
        self.wait(2)
