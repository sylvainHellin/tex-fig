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

- `fkpanel`: solid light grey panel behind one column of a picture.
- `fkgroup={colour}{title}`: dashed coloured box with its title above the frame.
- `fkcard`, `fkcardc={colour}`: white or tinted card, used with `fit=` around its content.
- `fkcardtitle`, `fkcardtitlec={colour}`, `fkcardsubtitle`: the header of a card and its one-line gloss.
- `fkfield`: a monospaced property or value line inside a card.
- `fkprose`: running text inside a card, for an example rather than a property; give it a `text width`.
- `fkpill={colour}{width}`, `fkpilltype`: a value label and the smaller type line under it.
- `fkblock={colour}{width}`: a heavier box for a processing step.
- `fkcaption`: grey gloss set underneath a panel.
- `fkarrow`, `fkarrowc={colour}`, `fkarrowdashed`, `fkarrowdashedc={colour}`: arrows.
- `fkelbow`: adds the corner radius an orthogonal route needs, used with the `-|` and `|-` path operators.
- `fkedgelabel`, `fkedgelabelc={colour}`: a label riding on an arrow, with a white fill so it stays legible where it crosses an edge.
- `\fklit{...}`: a literal value inside a field line.
- `\fkfigwidth`: the target width, defaulting to `\linewidth`.

## Examples

`examples/ocdi-concept.tex` is the OCDI core-concept figure: cards, pills, panels, and arrows aligned so that the ones that can be horizontal are.
`examples/codeact-loop.tex` is the CodeAct agent loop of the first journal paper, redrawn: dashed group boxes, tinted cards, blocks and orthogonal routing.

Build either one on its own with `examples/preview.tex`, which sets a fixed width because `standalone` has no useful `\linewidth`:

```sh
cd examples && tectonic -Z search-path=.. -c minimal preview.tex
pdftoppm -png -r 150 -singlefile preview.pdf out
```

## Using it in a paper

Overleaf needs the package inside the project tree, so copy `figkit.sty` next to the manuscript and update it by copying again when the kit changes.
In the document, load it with `\usepackage{figkit}` and input a figure inside `figure` or `figure*`.
