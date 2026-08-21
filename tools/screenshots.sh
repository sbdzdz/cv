#!/bin/sh
# Render each page of cv.pdf to docs/page-N.png for the README preview.
#
# Unlike the build, this needs Python (via uv). It is a docs tool, not a build
# dependency -- ./build.sh still requires only Node and Chrome.
set -eu
cd "$(dirname "$0")/.."
[ -f cv.pdf ] || { echo "cv.pdf missing -- run ./build.sh first" >&2; exit 1; }
mkdir -p docs
uv run --quiet --with pymupdf python - "$@" <<'PY'
import pymupdf
doc = pymupdf.open("cv.pdf")
for i, page in enumerate(doc, 1):
    out = f"docs/page-{i}.png"
    page.get_pixmap(dpi=120).save(out)
    print(f"{out}  {page.rect.width * 120 / 72:.0f}px wide")
PY
