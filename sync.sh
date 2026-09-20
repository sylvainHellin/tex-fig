#!/usr/bin/env bash
# sync.sh <target-dir> -- vendor the packages into a paper that cannot pull them
# from here, which is every Overleaf repo: it compiles from its own tree alone.
# The copy carries the commit it came from, so a stale one is visible in a diff.
# texfig-plots.sty follows only into a target that already had it.
set -euo pipefail

src=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=${1:?target directory, usually the root of a paper repo}
[[ -d $target ]] || { echo "no such directory: $target" >&2; exit 1; }

rev=$(git -C "$src" rev-parse --short HEAD)
[[ -z $(git -C "$src" status --porcelain) ]] ||
  { echo "commit tex-fig first: the copy would claim $rev and differ from it" >&2; exit 1; }
stamp="%% vendored from tex-fig $rev on $(date -I); edit it there, not here."

for f in texfig.sty texfig-plots.sty; do
  [[ $f == texfig.sty || -e $target/$f ]] || continue
  { head -1 "$src/$f"; echo "$stamp"; tail -n +2 "$src/$f"; } > "$target/$f"
  echo "$target/$f"
done
