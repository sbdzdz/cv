#!/bin/sh
# Render a font variant of the CV for comparison, without touching cv.css.
#
#   tools/font-variant.sh '"Helvetica Neue", sans-serif' cv-helvetica.pdf
#
# The output path is taken relative to wherever you run this, and may be
# absolute. Works by appending an override stylesheet to the generated cv.html,
# so the committed design is unaffected. Output PDFs are gitignored by the
# *.pdf rule.
set -eu
[ $# -eq 2 ] || { echo "usage: $0 '<css font stack>' <out.pdf>" >&2; exit 1; }
STACK="$1"

# Resolve the output before cd'ing to the repo root, so a relative path lands
# where the caller expects rather than in the repo.
case "$2" in
  /*) OUT="$2" ;;
  *)  OUT="$PWD/$2" ;;
esac
OUT_DIR=$(dirname "$OUT")
[ -d "$OUT_DIR" ] || { echo "no such directory: $OUT_DIR" >&2; exit 1; }

cd "$(dirname "$0")/.."

./build.sh --html-only >/dev/null

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
TMP="$WORK/variant.html"
# .name is overridden too: only Inter has a separate display cut for it
{
  cat cv.html
  printf '<style>body,.name{font-family:%s !important;}</style>\n' "$STACK"
} > "$TMP"

# Same order of preference as build.mjs -- the variant is only comparable to
# the real build if the same browser rendered both.
CHROME=""
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
  if [ -x "$c" ]; then CHROME="$c"; break; fi
done
[ -n "$CHROME" ] || { echo "no Chrome found" >&2; exit 1; }

"$CHROME" --headless=new --no-pdf-header-footer \
  --print-to-pdf="$OUT" "file://$TMP" 2>/dev/null
[ -f "$OUT" ] || { echo "Chrome did not write $OUT" >&2; exit 1; }
echo "$OUT  $(( $(wc -c < "$OUT") / 1024 ))KB   font stack: $STACK"
