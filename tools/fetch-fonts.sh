#!/bin/sh
# Install the Inter faces the CV needs into ~/Library/Fonts.
#
#   tools/fetch-fonts.sh           install anything missing
#   tools/fetch-fonts.sh --force   re-download and overwrite
#
# Pinned to a release tag so the metrics can't shift under the layout. Only the
# four faces the build embeds are installed -- deliberately NOT InterVariable,
# which Chrome cannot subset (see the Fonts section of the README).
#
# FONT_DIR=/some/dir overrides the install location (used for testing).
set -eu
cd "$(dirname "$0")/.."

REF=v4.1
DIR="${FONT_DIR:-$HOME/Library/Fonts}"
FACES="Inter-Regular Inter-SemiBold Inter-Bold InterDisplay-SemiBold"

[ "${1:-}" = "--force" ] && FORCE=1 || FORCE=""

missing=""
for f in $FACES; do
  if [ -n "$FORCE" ] || [ ! -e "$DIR/$f.ttf" ]; then
    missing="$missing $f"
  else
    echo "  present  $f"
  fi
done
[ -n "$missing" ] || { echo "All fonts present. Use --force to reinstall."; exit 0; }

mkdir -p "$DIR"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

URL="https://github.com/rsms/inter/releases/download/$REF/Inter-${REF#v}.zip"
echo "downloading Inter ${REF#v} ..."
curl -fsSL --max-time 180 -o "$TMP/inter.zip" "$URL" \
  || { echo "download failed: $URL" >&2; exit 1; }
unzip -qo "$TMP/inter.zip" -d "$TMP" 'extras/ttf/*'

for f in $missing; do
  src="$TMP/extras/ttf/$f.ttf"
  [ -e "$src" ] || { echo "$f.ttf not in the release -- did the layout change?" >&2; exit 1; }
  cp "$src" "$DIR/$f.ttf"
  echo "  installed $f"
done
echo "Inter ${REF#v} -> $DIR"
