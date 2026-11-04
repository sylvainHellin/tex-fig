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
# OUT sets the output directory, for a figure whose PNG lives next to its source:
#   OUT=design/figures examples/build.sh design/figures/arch.tex
# STEPS renders a figure that reveals itself step by step (tffrom, \tfshowfrom)
# as one PNG per step, <name>-1.png to <name>-<n>.png, for one slide page each:
#   STEPS=3 examples/build.sh stepped-reveal
set -euo pipefail

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dpi=${2:-300}  # PNGs end up in reports and mail, not only previews
out=${OUT:-$HOME/Documents/tmp}
palette=${PALETTE:-apple}
font=${FONT:-times}
steps=${STEPS:-}
[[ -z $steps || $steps =~ ^[1-9][0-9]*$ ]] || { echo "STEPS must be a positive integer: $steps" >&2; exit 1; }

build_one() {
  local src=$1 fig name s
  [[ $src == *.tex || $src == */* ]] || src=$dir/$src.tex
  [[ -e $src ]] || { echo "no such figure: $src" >&2; exit 1; }
  src=$(cd "$(dirname "$src")" && pwd)/$(basename "$src")
  fig=$(basename "$src" .tex)
  name=$fig
  [[ $palette == apple ]] || name=$fig-$palette
  if [[ -z $steps ]]; then
    render "$src" "$name" ""
  else
    for ((s = 1; s <= steps; s++)); do render "$src" "$name-$s" "$s"; done
  fi
}

# render <source> <output name> <step, or empty for the full figure>
render() {
  local src=$1 name=$2 step=$3 tmp stepdef=""
  [[ -z $step ]] || stepdef="\\newcommand{\\tfstep}{$step}"
  tmp=$(mktemp -d)
  cat > "$tmp/$name.tex" <<EOF
\\documentclass[border=8pt]{standalone}
$stepdef
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
