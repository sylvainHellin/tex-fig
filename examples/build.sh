#!/usr/bin/env bash
# build.sh <figure|all> [dpi] -- build one example, or every one, and leave a PNG
# in ~/Documents/tmp, which syncs to the devices a PDF cannot be opened from.
# The LaTeX wrapper is generated in a scratch directory, so nothing in the repo
# has to be edited to look at a different figure.
#
# PALETTE and FONT select what the preview is drawn with; a non-default palette
# is written to its own file, so two palettes can be compared side by side.
#   PALETTE=tum examples/build.sh ocdi-concept
set -euo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dpi=${2:-150}
out=$HOME/Documents/tmp
palette=${PALETTE:-apple}
font=${FONT:-times}

build_one() {
  local fig=$1 name=$1 tmp
  [[ $palette == apple ]] || name=$fig-$palette
  tmp=$(mktemp -d)
  cat > "$tmp/$name.tex" <<EOF
\\documentclass[border=8pt]{standalone}
\\usepackage[palette=$palette, font=$font]{texfig-plots}
\\renewcommand{\\tffigwidth}{20cm}
\\begin{document}
\\input{$dir/$fig.tex}
\\end{document}
EOF
  tectonic -Z search-path="$dir/.." -c minimal -o "$tmp" "$tmp/$name.tex" >/dev/null
  mkdir -p "$out"
  pdftoppm -png -r "$dpi" -singlefile "$tmp/$name.pdf" "$out/$name"
  echo "$out/$name.png"
}

if [[ ${1:?figure name without .tex, or all} == all ]]; then
  for f in "$dir"/*.tex; do build_one "$(basename "$f" .tex)"; done
else
  build_one "${1%.tex}"
fi
