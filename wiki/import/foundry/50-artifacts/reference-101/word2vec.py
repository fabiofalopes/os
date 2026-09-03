"""word2vec — an animated explainer.

Scenes (render in order):
  01 OneHot        — words as one-hot vectors, the curse of dimensionality
  02 Embedding     — one-hot × embedding matrix = dense vector
  03 SkipGram      — context windows generate training pairs
  04 EmbeddingSpace— the learned 2D map, clusters & neighbors
  05 KingQueen     — vector arithmetic: king - man + woman ≈ queen
  06 Parallelogram — analogies as shared offset vectors

Palette follows the dataviz system: one categorical accent per concept,
near-black background, no decoration that isn't information.
"""
from manim import *
import numpy as np

config.background_color = "#131316"

INK       = "#ECECF1"   # primary text
MUTED     = "#8B8B94"   # secondary text
ACCENT    = "#4C8DFF"   # primary series (vectors)
ACCENT2   = "#B580FF"   # secondary series (matrices)
ACCENT3   = "#3DDC97"   # tertiary (result/highlight)
ACCENT4   = "#FFB86B"   # quaternary (attention)
GRID      = "#26262C"

WORDS = ["king", "queen", "man", "woman", "apple", "banana"]


def word_label(w, font_size=30, **kw):
    return Text(w, font="Sans", color=INK, font_size=font_size)


# ────────────────────────────── 01 · one-hot ──────────────────────────────

class OneHot(Scene):
    """A word is just an index into a vocabulary. Huge, sparse, meaningless."""
    def construct(self):
        title = Text("1 · Words as one-hot vectors", color=MUTED, font_size=28)
        title.to_edge(UP)

        vocab = VGroup(*[word_label(w) for w in WORDS])
        vocab.arrange(DOWN, buff=0.45).shift(LEFT * 5)

        rows = VGroup()
        for i, w in enumerate(WORDS):
            cells = VGroup()
            for j in range(len(WORDS)):
                c = Square(0.5, stroke_color=GRID, fill_opacity=0.85)
                c.set_fill("#1B1B20" if j != i else ACCENT, opacity=1)
                cells.add(c)
            cells.arrange(RIGHT, buff=0.12)
            rows.add(cells)
        rows.arrange(DOWN, buff=0.18).shift(RIGHT * 1.8)

        braces = VGroup()
        for i, cells in enumerate(rows):
            b = Brace(cells, RIGHT, color=MUTED)
            t = Text("1 at position %d" % i, font_size=18, color=MUTED)
            t.next_to(b, RIGHT, buff=0.15)
            braces.add(VGroup(b, t))

        self.play(Write(title))
        self.play(FadeIn(vocab, shift=RIGHT * 0.4))
        self.play(LaggedStart(*[FadeIn(r, shift=LEFT * 0.3) for r in rows], lag_ratio=0.15))
        self.play(LaggedStart(*[FadeIn(b) for b in braces], lag_ratio=0.15))
        self.wait()

        # the problem
        prob = VGroup(
            Text("V = 50,000 words", color=INK, font_size=30),
            Text("→ vectors of 50,000 dims", color=INK, font_size=30),
            Text("→ all pairs orthogonal", color=ACCENT4, font_size=30),
            Text('"king" and "queen" share nothing.', color=MUTED, font_size=26),
        ).arrange(DOWN, buff=0.35, aligned_edge=LEFT).scale(0.9)
        prob.to_edge(DOWN, buff=0.6).shift(LEFT * 1.5)
        self.play(Write(prob[0]))
        self.play(Write(prob[1]))
        self.play(Write(prob[2]))
        self.play(FadeIn(prob[3]))
        self.wait(2)
        self.play(FadeOut(VGroup(title, vocab, rows, braces, prob)))


# ───────────────────────────── 02 · embedding ─────────────────────────────

class Embedding(Scene):
    """One-hot picks a row of a learned matrix: the word's dense vector."""
    def construct(self):
        title = Text("2 · The embedding lookup", color=MUTED, font_size=28)
        title.to_edge(UP)

        onehot = MathTex(
            r"\left[\begin{array}{c} 0 \\ 0 \\ 1 \\ 0 \\ 0 \\ 0 \end{array}\right]",
            color=INK, font_size=40).scale(0.9)
        onehot.shift(LEFT * 5.2 + DOWN * 0.3)

        oh_label = Text('one-hot "man"', color=ACCENT, font_size=24)
        oh_label.next_to(onehot, UP)

        data = np.round(np.random.default_rng(7).uniform(-1, 1, (6, 4)), 1)
        rows_tex = r" \\ ".join(" & ".join(f"{v:.1f}" for v in row) for row in data)
        mat = MathTex(r"\left[\begin{array}{cccc} " + rows_tex + r" \end{array}\right]",
                      color=INK, font_size=40).scale(0.85)
        mat.shift(DOWN * 0.3)
        mat_label = MathTex(r"W \in \mathbb{R}^{V \times d}", color=ACCENT2, font_size=36)
        mat_label.next_to(mat, UP)

        # highlight row 2 (the "man" row) — approximate position: middle row
        row_rect = SurroundingRectangle(mat, color=ACCENT3, buff=0.12)
        row_rect.stretch(0.12, 1, about_point=mat.get_center())

        result = VGroup()
        for j in range(4):
            v = MathTex(f"{data[2, j]:.1f}", color=ACCENT3, font_size=34)
            result.add(v)
        result.arrange(DOWN, buff=0.35).shift(RIGHT * 4.8 + DOWN * 0.3)
        res_label = MathTex(r"\vec{v}_{man} \in \mathbb{R}^{d}", color=ACCENT3, font_size=36)
        res_label.next_to(result, UP)

        arrow1 = Arrow(onehot.get_right(), mat.get_left() + LEFT * 0.4, buff=0.2, color=MUTED)
        times = MathTex(r"\times", color=MUTED, font_size=44).move_to(
            (onehot.get_right() + mat.get_left()) / 2 + DOWN * 0.3)
        arrow2 = Arrow(mat.get_right(), result.get_left(), buff=0.3, color=MUTED)

        self.play(Write(title))
        self.play(Write(onehot), FadeIn(oh_label))
        self.play(Write(mat), FadeIn(mat_label))
        self.play(GrowArrow(arrow1), FadeIn(times))
        # highlight the selected row
        self.play(Create(row_rect))
        self.play(GrowArrow(arrow2))
        self.play(LaggedStart(*[FadeIn(v, shift=RIGHT * 0.3) for v in result], lag_ratio=0.15),
                  FadeIn(res_label))
        self.wait()

        note = Text("d ≈ 100–1000 dims · dense · learned from text",
                    color=MUTED, font_size=24).to_edge(DOWN)
        self.play(FadeIn(note))
        self.wait(2)
        self.play(FadeOut(VGroup(title, onehot, oh_label, mat, mat_label,
                                 row_rect, arrow1, times, arrow2, result,
                                 res_label, note)))


# ───────────────────────────── 03 · skip-gram ─────────────────────────────

class SkipGram(Scene):
    """Training signal for free: predict the neighbors of each word."""
    def construct(self):
        title = Text("3 · Skip-gram: the context window", color=MUTED, font_size=28)
        title.to_edge(UP)

        sentence = ["the", "king", "sat", "on", "the", "throne"]
        toks = VGroup(*[word_label(w) for w in sentence])
        toks.arrange(RIGHT, buff=0.7).shift(UP * 0.8)
        tok_copies = VGroup(*[word_label(w, color=MUTED) for w in sentence])
        tok_copies.arrange(RIGHT, buff=0.7).shift(UP * 0.8)

        window = SurroundingRectangle(toks[2], color=ACCENT4, buff=0.18)
        self.play(Write(title), LaggedStart(*[FadeIn(t) for t in toks], lag_ratio=0.1))
        self.play(Create(window))

        # slide window across center words, highlight context
        pairs_title = Text("training pairs  (center, context)", color=MUTED, font_size=24)
        pairs_title.to_edge(DOWN, buff=1.6)
        pair_group = VGroup().next_to(pairs_title, DOWN, buff=0.4)

        for center in range(1, 5):
            rect = SurroundingRectangle(toks[center], color=ACCENT4, buff=0.18)
            ctxs = [center - 1, center + 1] if 0 < center < 5 else [center + 1]
            ctx_rects = VGroup(*[SurroundingRectangle(toks[c], color=ACCENT, buff=0.15)
                                 for c in ctxs])
            pair_texs = VGroup(*[
                MathTex(r"(\text{%s},\ \text{%s})" % (sentence[center], sentence[c]),
                        color=INK, font_size=30)
                for c in ctxs])
            pair_texs.arrange(RIGHT, buff=0.6).move_to(pair_group)

            anims = [Transform(window, rect)]
            if len(pair_group):
                anims.append(FadeOut(pair_group[-1]))
            self.play(*anims)
            self.play(*[Create(r) for r in ctx_rects], run_time=0.5)
            self.play(FadeIn(pair_texs, shift=UP * 0.2))
            self.wait(0.4)
            self.play(*[FadeOut(r) for r in ctx_rects], FadeOut(pair_texs), run_time=0.5)
            pair_group.add(pair_texs)

        # loss
        loss = MathTex(r"\max_\theta \sum_{(w,c)} \log p(c \mid w;\theta)",
                       color=ACCENT2, font_size=40).to_edge(DOWN, buff=0.7)
        self.play(Write(loss))
        self.wait(2)
        self.play(FadeOut(VGroup(title, toks, window, loss)))


# ─────────────────────────── 04 · embedding space ─────────────────────────

class EmbeddingSpace(Scene):
    """After training: similar words land near each other."""
    # hand-placed 2D projection of the toy embedding
    PTS = {
        "king":   (-2.6,  1.7), "queen": (-1.9,  2.3),
        "man":    (-2.8, -0.9), "woman": (-2.0, -0.4),
        "prince": (-3.3,  1.1), "princess": (-1.3, 1.6),
        "apple":  ( 2.4,  1.2), "banana": ( 3.0,  0.6),
        "cherry": ( 2.0,  2.0), "dog":    ( 0.6, -2.2),
        "cat":    ( 1.2, -1.8), "wolf":   (-0.2, -2.5),
    }
    def construct(self):
        title = Text("4 · The learned space", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[-4.5, 4.5, 1], y_range=[-3.2, 3.2, 1],
            x_length=10.5, y_length=5.6,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
        ).shift(DOWN * 0.2)
        dim_lbl = Text("≈ first 2 principal components", color=MUTED, font_size=20)
        dim_lbl.to_corner(DL, buff=0.5)

        dots = VGroup()
        labels = VGroup()
        for w, (x, y) in self.PTS.items():
            d = Dot(axes.c2p(x, y), radius=0.07, color=ACCENT)
            l = word_label(w, 22)
            l.next_to(d, UR, buff=0.08)
            dots.add(d); labels.add(l)
        dots.set_color_by_gradient(ACCENT, ACCENT2)

        self.play(Write(title), Create(axes), FadeIn(dim_lbl))
        self.play(LaggedStart(*[GrowFromCenter(d) for d in dots], lag_ratio=0.06))
        self.play(LaggedStart(*[FadeIn(l, shift=UP * 0.15) for l in labels], lag_ratio=0.04))
        self.wait()

        # clusters
        royalty = VGroup(*[dots[i] for i, w in enumerate(self.PTS) if w in
                           ("king", "queen", "prince", "princess", "man", "woman")])
        fruit   = VGroup(*[dots[i] for i, w in enumerate(self.PTS) if w in
                           ("apple", "banana", "cherry")])
        animals = VGroup(*[dots[i] for i, w in enumerate(self.PTS) if w in
                           ("dog", "cat", "wolf")])
        for grp, name, col in [(royalty, "royalty / gender", ACCENT2),
                               (fruit, "fruit", ACCENT3), (animals, "animals", ACCENT4)]:
            blob = SurroundingRectangle(grp, color=col, buff=0.35, corner_radius=0.3)
            tag = Text(name, color=col, font_size=22).next_to(blob, UP, buff=0.12)
            self.play(Create(blob), FadeIn(tag))
            self.wait(0.5)
        self.wait(2)


# ─────────────────────────── 05 · king − man + woman ──────────────────────

class KingQueen(EmbeddingSpace):
    """The famous arithmetic: king − man + woman lands on queen."""
    def construct(self):
        title = Text("5 · Vector arithmetic", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[-4.5, 0.5, 1], y_range=[-2.0, 3.5, 1],
            x_length=9.0, y_length=6.0,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
        ).shift(DOWN * 0.2)

        P = {w: axes.c2p(x, y) for w, (x, y) in self.PTS.items()
             if w in ("king", "queen", "man", "woman", "prince", "princess")}

        def pt(w):
            return Dot(P[w], radius=0.09, color=ACCENT)
        def lab(w):
            t = word_label(w, 26); t.next_to(P[w], UR, buff=0.1); return t

        self.play(Write(title), Create(axes))
        for w in ("king", "queen", "man", "woman"):
            self.play(GrowFromCenter(pt(w)), FadeIn(lab(w)), run_time=0.5)

        formula = MathTex(r"\vec{king} - \vec{man} + \vec{woman}",
                          color=INK, font_size=44).to_edge(DOWN, buff=1.0)
        self.play(Write(formula))

        # gender offset vector: man -> woman
        off = Arrow(P["man"], P["woman"], buff=0.1, color=ACCENT3, stroke_width=5)
        self.play(GrowArrow(off))
        self.wait()

        # copy the arrow to king's tip
        off2 = Arrow(P["king"], P["king"] + (P["woman"] - P["man"]),
                     buff=0.1, color=ACCENT3, stroke_width=5)
        ghost = off.copy().set_opacity(0.25)
        self.play(TransformFromCopy(off, off2))
        self.wait()

        target = P["king"] + (P["woman"] - P["man"])
        probe = Dot(target, radius=0.11, color=ACCENT4)
        qmark = Text("?", color=ACCENT4, font_size=36).next_to(probe, UR, buff=0.1)
        self.play(GrowFromCenter(probe), Write(qmark))

        # nearest neighbor flash
        circ = Circle(radius=1.0, color=ACCENT4).move_to(target)
        self.play(Create(circ), run_time=0.8)
        self.play(Indicate(lab("queen"), color=ACCENT4, scale_factor=1.3))
        queen_dot = pt("queen")
        result = MathTex(r"\approx \vec{queen}", color=ACCENT4, font_size=44)
        result.next_to(formula, DOWN, buff=0.3)
        self.play(ReplacementTransform(qmark, result))
        self.wait(2)


# ───────────────────────────── 06 · parallelogram ─────────────────────────

class Parallelogram(Scene):
    """Every analogy is the same offset vector, applied anywhere."""
    PTS = {
        "king":     (-3.2,  1.9), "queen":   (-2.2,  2.5),
        "man":      (-3.5, -0.7), "woman":   (-2.5, -0.1),
        "prince":   (-1.2,  1.2), "princess": (-0.2, 1.8),
        "actor":    ( 1.2,  1.5), "actress":  ( 2.2,  2.1),
    }
    def construct(self):
        title = Text("6 · Analogies as parallelograms", color=MUTED, font_size=28)
        title.to_edge(UP)

        axes = Axes(
            x_range=[-4.5, 3.5, 1], y_range=[-1.5, 3.5, 1],
            x_length=10.5, y_length=5.2,
            axis_config={"stroke_color": GRID, "include_ticks": False, "stroke_width": 1.5},
        ).shift(DOWN * 0.3)

        P = {w: axes.c2p(x, y) for w, (x, y) in self.PTS.items()}
        dots, labels = VGroup(), VGroup()
        for w, p in P.items():
            d = Dot(p, radius=0.075, color=ACCENT)
            l = word_label(w, 24).next_to(p, UR, buff=0.08)
            dots.add(d); labels.add(l)

        self.play(Write(title), Create(axes))
        self.play(LaggedStart(*[GrowFromCenter(d) for d in dots], lag_ratio=0.08))
        self.play(LaggedStart(*[FadeIn(l) for l in labels], lag_ratio=0.05))

        groups = [
            (("man", "woman", "king", "queen"), "man : woman :: king : ?"),
            (("man", "woman", "prince", "princess"), "… same offset"),
            (("man", "woman", "actor", "actress"), "… everywhere"),
        ]
        for (a, b, c, d_), cap in groups:
            quad = Polygon(P[a], P[b], P[d_], P[c], color=ACCENT3, stroke_width=3)
            self.play(Create(quad), run_time=1.0)
            t = Text(cap, color=ACCENT3, font_size=24).to_edge(DOWN, buff=0.5)
            self.play(FadeIn(t))
            self.wait(1.2)
            self.play(FadeOut(quad), FadeOut(t))

        closing = Text("meaning = position in space", color=INK, font_size=34)
        closing.to_edge(DOWN, buff=0.5)
        self.play(Write(closing))
        self.wait(2)
