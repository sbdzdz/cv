#!/bin/sh
# Download the icon SVGs from Font Awesome Free into icons/.
#
# Pinned to a release tag rather than a branch: the repo's master branch still
# serves Font Awesome 5, whose outlines differ from the 6.x ones this CV uses.
#
# Font Awesome renamed several icons in v6 -- home became house, external-link
# became up-right-from-square -- so the left column below is the name build.mjs
# asks for and the right column is the upstream path.
set -eu

REF=6.7.2
BASE="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/$REF/svgs"
DIR="$(dirname "$0")/../icons"
mkdir -p "$DIR"

while IFS=: read -r name path; do
  [ -z "$name" ] && continue
  curl -fsS --max-time 20 -o "$DIR/$name.svg" "$BASE/$path.svg" \
    || { echo "FAILED $name <- $path.svg" >&2; exit 1; }
  printf '  %-10s <- %s.svg\n' "$name" "$path"
done <<'ICONS'
envelope:solid/envelope
home:solid/house
scholar:solid/graduation-cap
education:solid/graduation-cap
briefcase:solid/briefcase
gear:solid/gear
book:solid/book
award:solid/award
users:solid/users
external:solid/up-right-from-square
github:brands/github
linkedin:brands/linkedin
ICONS

echo "Font Awesome Free $REF -> $DIR/"
