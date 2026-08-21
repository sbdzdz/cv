#!/bin/sh
# One-shot setup for a fresh clone: check prerequisites, install fonts, build.
#
#   ./setup.sh
#
# Safe to re-run -- every step is a no-op once satisfied.
set -eu
cd "$(dirname "$0")"

fail=""

printf 'Node          '
if command -v node >/dev/null 2>&1; then echo "ok  $(node --version)"
else echo "MISSING -- install Node (https://nodejs.org)"; fail=1; fi

printf 'Chrome        '
CHROME=$(ls "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
            "/Applications/Chromium.app/Contents/MacOS/Chromium" 2>/dev/null | head -1 || true)
if [ -n "$CHROME" ]; then echo "ok  $(basename "$(dirname "$(dirname "$(dirname "$CHROME")")")")"
else echo "MISSING -- install Google Chrome"; fail=1; fi

printf 'uv (optional) '
if command -v uv >/dev/null 2>&1; then echo "ok  -- tools/screenshots.sh available"
else echo "absent -- only tools/screenshots.sh needs it"; fi

[ -z "$fail" ] || { echo; echo "Install the missing prerequisites, then re-run ./setup.sh" >&2; exit 1; }

echo
echo 'Fonts'
./tools/fetch-fonts.sh | sed 's/^/  /'

echo
echo 'Icons'
if [ -n "$(ls icons/*.svg 2>/dev/null)" ]; then
  echo "  present  $(ls icons/*.svg | wc -l | tr -d ' ') svgs (committed; tools/fetch-icons.sh re-downloads)"
else
  ./tools/fetch-icons.sh | sed 's/^/  /'
fi

echo
echo 'Build'
./build.sh | sed 's/^/  /'
echo
echo 'Done. cv.pdf is ready; ./build.sh rebuilds after editing cv.json.'
