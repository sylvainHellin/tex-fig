#!/usr/bin/env bash
# build.sh <figure|path.tex|all> [dpi] -- build one figure, or every example, and
# leave a PNG in ~/Documents/tmp, which syncs to the devices a PDF cannot be
# opened from. A bare name is looked up in examples/; a path builds a figure that
# lives anywhere, which is how a figure inside a paper repo is previewed.
# The LaTeX wrapper is generated in a scratch directory, so nothing in the repo
# has to be edited to look at a different figure.
#
# PALETTE and FONT select what the preview is drawn with; a non-default palette
# is written to its own file, so two palettes can be compared side by side.
#   PALETTE=tum examples/build.sh ocdi-concept
set -euo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dpi=${2:-300}  # PNGs end up in reports and mail, not only previews
out=$HOME/Documents/tmp
palette=${PALETTE:-apple}
font=${FONT:-times}

build_one() {
  local src=$1 fig name tmp
  [[ $src == *.tex || $src == */* ]] || src=$dir/$src.tex
  [[ -e $src ]] || { echo "no such figure: $src" >&2; exit 1; }
  src=$(cd "$(dirname "$src")" && pwd)/$(basename "$src")
  fig=$(basename "$src" .tex)
  name=$fig
  [[ $palette == apple ]] || name=$fig-$palette
  tmp=$(mktemp -d)
  cat > "$tmp/$name.tex" <<EOF
\\documentclass[border=8pt]{standalone}
\\usepackage[palette=$palette, font=$font]{texfig-plots}
\\renewcommand{\\tffigwidth}{20cm}
\\begin{document}
\\input{$src}
\\end{document}
EOF
  tectonic -Z search-path="$dir/.." -c minimal -o "$tmp" "$tmp/$name.tex" >/dev/null
  mkdir -p "$out"
  pdftoppm -png -r "$dpi" -singlefile "$tmp/$name.pdf" "$out/$name"
  echo "$out/$name.png"
}

if [[ ${1:?figure name, path to a .tex, or all} == all ]]; then
  for f in "$dir"/*.tex; do build_one "$f"; done
else
  build_one "$1"
fi
