#!/bin/sh
# Rebuild the CV and copy it into the website repo, which serves it at
# https://sebastiandziadzio.com/cv/cv.pdf
#
#   tools/publish.sh          rebuild + copy, then print what's left to do
#   tools/publish.sh --push   also commit, push, and wait for it to go live
#
# Override the site location with SITE_REPO=/path/to/repo.
set -eu
cd "$(dirname "$0")/.."

SITE="${SITE_REPO:-../sebastiandziadzio.github.io}"
PDF="sebastian_dziadzio_cv.pdf"
# The published path stays cv/cv.pdf -- it is a public URL people have linked to.
DEST="cv/cv.pdf"
URL="https://sebastiandziadzio.com/$DEST"
PUSH=""
[ "${1:-}" = "--push" ] && PUSH=1

[ -d "$SITE/.git" ] || { echo "no git repo at $SITE (set SITE_REPO=...)" >&2; exit 1; }
[ -f "$SITE/$DEST" ] || { echo "$SITE/$DEST not found -- has the site moved it?" >&2; exit 1; }

# Chrome stamps /CreationDate and /ModDate, so two builds of identical content
# differ by 4 bytes. Mask those before comparing.
fingerprint() {
  LC_ALL=C sed -E 's/\/(CreationDate|ModDate) \(D:[^)]*\)/\/\1 ()/g' "$1" \
    | shasum -a 256 | cut -d' ' -f1
}

./build.sh

if [ "$(fingerprint "$PDF")" = "$(fingerprint "$SITE/$DEST")" ]; then
  echo "\n$DEST already matches this build -- nothing to publish."
  exit 0
fi

old=$(wc -c < "$SITE/$DEST" | tr -d ' ')
cp "$PDF" "$SITE/$DEST"
new=$(wc -c < "$SITE/$DEST" | tr -d ' ')
echo "\n$SITE/$DEST  ${old}B -> ${new}B"

if [ -z "$PUSH" ]; then
  cat <<MSG

Copied, not yet live. To publish:

  git -C $SITE commit -m 'Update CV' -- $DEST && git -C $SITE push

Or re-run as: tools/publish.sh --push
MSG
  exit 0
fi

git -C "$SITE" commit -m "Update CV" -- "$DEST"
git -C "$SITE" push

want=$(fingerprint "$PDF")
printf '\nwaiting for GitHub Pages to serve the new file'
i=0
while [ "$i" -lt 40 ]; do
  i=$((i + 1)); printf '.'; sleep 6
  tmp=$(mktemp)
  if curl -fsS --max-time 20 -o "$tmp" "$URL" 2>/dev/null \
     && [ "$(fingerprint "$tmp")" = "$want" ]; then
    rm -f "$tmp"; echo "\nlive at $URL"; exit 0
  fi
  rm -f "$tmp"
done
echo "\npushed, but $URL still serves the old file. Pages can lag a few minutes;"
echo "check https://github.com/sebastiandziadzio/sebastiandziadzio.github.io/actions"
