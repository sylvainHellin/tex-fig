# figkit

A LaTeX package for the figures in Sylvain's papers and slide decks, so every diagram in every publication shares one look instead of being redrawn in whatever tool was open.
The look comes from the ByteDance Falcon paper: Apple system colours, white cards with rounded corners, pill labels, thin `Latex` arrowheads, light grey panels behind a group of related nodes.
Everything is TikZ code, so a figure is versioned, diffable, searchable and typeset in the document's own fonts, and no PNG or SVG render is ever committed.

## The recipe

Author the picture on a comfortable coordinate canvas, in centimetres, without worrying about the column width.
Wrap it in `\resizebox{\fkfigwidth}{!}{...}`, which scales the finished picture to whatever width the including document gives it.
Place the background panels and the group boxes last, fitted around the nodes they contain with `fit=`, so their size follows the content rather than being guessed.
Nodes that a panel must sit behind go on the `background` layer, and the panel itself on the `grouping` layer below it.

## Minimal working example

```latex
\documentclass[border=8pt]{standalone}
\usepackage{figkit}
\renewcommand{\fkfigwidth}{12cm}
\begin{document}
\resizebox{\fkfigwidth}{!}{%
\begin{tikzpicture}
  \node[fkcardtitlec=appleBlue] (t) at (0,2) {A card};
  \node[fkfield] (f) at (0,1.5) {one field line};
  \begin{scope}[on background layer]
    \node[fkcard, fit=(t)(f)] (card) {};
  \end{scope}
  \node[fkpill={appleOrange}{3cm}] (p) at (7,1.75) {a value\\[1pt]{\tiny its type}};
  \draw[fkarrowc=appleOrange] (card.east) -- (p.west)
    node[fkedgelabelc=appleOrange, pos=0.5] {relates to};
\end{tikzpicture}}
\end{document}
```

## Choosing a colour

The palette defines `appleBlue`, `appleGreen`, `appleOrange`, `applePurple`, `appleRed`, `applePink`, `appleTeal`, `appleGray`, `appleDarkGray` and `appleDark`, each with a near-white `appleLight...` tint.
Every style that carries a colour takes it as an argument rather than existing once per colour: `fkcardc=appleGreen`, `fkpill={applePurple}{4.7cm}`, `fkarrowc=appleBlue`, `fkgroup={appleRed}{Title}`.
Text on an accent colour is darkened to `#1!62!black` so it stays legible against the 10 percent fill.
Pick colours by role and keep the mapping constant across the figures of one paper.

## Styles

- `fkpanel`, `fkpanelc={colour}`: solid panel behind one column of a picture, grey or tinted.
- `fkgroup={colour}{title}`: dashed coloured box with its title above the frame.
- `fkcard`, `fkcardc={colour}`: white or tinted card, used with `fit=` around its content.
- `fkcardtitle`, `fkcardtitlec={colour}`, `fkcardsubtitle`: the header of a card and its one-line gloss.
- `fkfield`: a monospaced property or value line inside a card.
- `fkprose`: running text inside a card, for an example rather than a property; give it a `text width`.
- `fkpill={colour}{width}`, `fkpilltype`: a value label and the smaller type line under it.
- `fkblock={colour}{width}`: a heavier box for a processing step.
- `fkchip={colour}{size}`, `fkdot={colour}`: a square and a round chip of a fixed size, for a state or a token in a chain.
- `fkop`: a small circle carrying an operator symbol on a path.
- `fkghost`: a dashed outline with no fill, for something produced rather than held.
- `fkformula`, `fknote={colour}`: a white card for a displayed equation, and the coloured callout that states what it costs.
- `fktitle`: the title of a figure section, set above the panel it names.
- `fkcaption`: grey gloss set underneath a panel.
- `fklabel`, `fklabelc={colour}`: free-standing label in the document tone, for something named but not boxed.
- `fktag={colour}`: small solid chip, for labelling a panel from inside it.
- `fkicon={colour}`, `fkglyph={colour}`, `fkrule={colour}`: a tinted canvas for a small icon, and the outlined shapes and rules drawn inside it.
- `fkarrow`, `fkarrowc={colour}`, `fkarrowdashed`, `fkarrowdashedc={colour}`: arrows.
- `fkelbow`: adds the corner radius an orthogonal route needs, used with the `-|` and `|-` path operators.
- `fkedgelabel`, `fkedgelabelc={colour}`: a label riding on an arrow, with a white fill so it stays legible where it crosses an edge.
- `\fkrow{<x>}{<node.anchor>}`, `\fkcol{<node.anchor>}{<y>}`: place a node on the line of another one, so the arrow between them is horizontal or vertical by construction. Declare the node you align to first; a fitted group counts.
- `\fklit{...}`: a literal value inside a field line.
- `\fkcutmark[colour]{(x,y)}`: the two slashes that cut an arrow where a gradient is stopped.
- `\fkfigwidth`: the target width, defaulting to `\linewidth`.

## Examples

`examples/ocdi-concept.tex` is the OCDI core-concept figure: cards, pills, panels, and arrows aligned so that the ones that can be horizontal are.
`examples/codeact-loop.tex` is the CodeAct agent loop of the first journal paper, redrawn: dashed group boxes, tinted cards, blocks and orthogonal routing.
`examples/jina-architecture.tex` reproduces figure 1 of arXiv 2609.03181: icons, curved arrows, a tagged panel and a chain of small blocks.
`examples/jina-benchmarks.tex` reproduces its figure 2, and is the one plotted figure: two bar panels and two scatter plots.

`examples/fixed-point-forcing.tex` shows how to fade what a second panel repeats: put the repeated nodes in a `transparency group` scope with an `opacity`, which keeps overlapping strokes from showing through each other.
`examples/linattn-{recurrent,parallel,chunkwise}.tex` are three views of the same operator, and the widest exercise of the kit: chips, chained states, dashed outputs, tall matrix operands with a clipped mask, formula cards and cost callouts.

Build any of them with `examples/build.sh`, which generates the `standalone` wrapper in a scratch directory and leaves a PNG in `~/Documents/tmp`:

```sh
examples/build.sh linattn-parallel      # one figure
examples/build.sh all 200               # all of them, at 200 dpi
```

## Plots

A figure that carries measured numbers loads `figkit-plots` instead of `figkit`; the plot package requires the node package, so everything above stays available.
It adds pgfplots and keeps the same split: the package holds the look of an axis, the document holds the data.

- `fkaxis`: the shared look, a frame-free axis with thin grey rules and light grid lines.
- `fkbaraxis`: horizontal bars against a category axis that carries names rather than a scale. Give the categories with `symbolic y coords` and repeat them in `ytick`, since `ytick=data` only picks up what the first series plots, and print a value at the end of each bar by passing it as `[explicit symbolic]` meta.
- `fkplotaxis`: a value plot, both axes drawn, grid on the measured axis.
- `fkbar={colour}`: one bar series. Plot the highlighted category as a second series so it is drawn over the grey one.
- `fkpoint={colour}`, `fkstar={colour}`: a plain scatter mark and the open five-pointed star for the series the figure argues about.
- `fkline={colour}`, `fktrend`: a line through the points that form the frontier, and the dashed grey trend behind them.
- `fkpointlabel`, `fkpointlabelc={colour}`: the name of a point, set beside it with `at (axis cs:x,y)`.
- `fkpanelletter`: the (a), (b), (c) of a multi-panel figure.

Place several panels by giving each `axis` an explicit `at={(<x>cm,<y>cm)}, anchor=south west` and `scale only axis`, which `fkaxis` sets, so `width` and `height` measure the plot body and the panels line up whatever their labels do.

## Using it in a paper

Overleaf needs the package inside the project tree, so copy `figkit.sty` next to the manuscript and update it by copying again when the kit changes.
In the document, load it with `\usepackage{figkit}` and input a figure inside `figure` or `figure*`.
