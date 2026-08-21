#!/bin/sh
# Render a font variant of the CV for comparison, without touching cv.css.
#
#   tools/font-variant.sh '"Helvetica Neue", sans-serif' cv-helvetica.pdf
#
# Works by appending an override stylesheet to the generated cv.html, so the
# committed design is unaffected. Output PDFs are gitignored by the *.pdf rule.
set -eu
cd "$(dirname "$0")/.."
[ $# -eq 2 ] || { echo "usage: $0 '<css font stack>' <out.pdf>" >&2; exit 1; }
STACK="$1"; OUT="$2"

./build.sh --html-only >/dev/null

TMP=$(mktemp -t cvfont).html
# .name is overridden too: only Inter has a separate display cut for it
{
  cat cv.html
  printf '<style>body,.name{font-family:%s !important;}</style>\n' "$STACK"
} > "$TMP"

CHROME=$(ls "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
            "/Applications/Chromium.app/Contents/MacOS/Chromium" 2>/dev/null | head -1)
[ -n "$CHROME" ] || { echo "no Chrome found" >&2; exit 1; }

"$CHROME" --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer \
  --virtual-time-budget=4000 --print-to-pdf="$(pwd)/$OUT" "file://$TMP" 2>/dev/null
rm -f "$TMP"
echo "$OUT  $(( $(wc -c < "$OUT") / 1024 ))KB   font stack: $STACK"
