# CV

Two-page CV built from HTML + CSS and printed to PDF with headless Chrome.

## Build

```sh
./build.sh              # cv.json + cv.css -> cv.html -> cv.pdf
./build.sh --html-only  # stop after cv.html (preview it in a browser)
```

No `node_modules` — the only requirements are Node and Google Chrome.

## Files

| File | Purpose |
| --- | --- |
| `cv.json` | All content: roles, education, publications, patents, service. **Edit this.** |
| `cv.css` | Layout and styling. Design tokens (colours, page size, margins) live in `:root`. |
| `build.mjs` | Renders `cv.json` into `cv.html`, then drives Chrome to produce `cv.pdf`. |
| `icons/` | One SVG per header/section icon, extracted from Font Awesome 6. |
| `tools/extract-icons.py` | Rebuilds `icons/` from the Font Awesome desktop fonts. |
| `cv.html` | Generated — self-contained, gitignored. |

## HTML to PDF

`build.sh` does this for you; the section below is for when you want to run the
print step by hand, or reproduce it somewhere `build.mjs` can't run.

`cv.html` is fully self-contained — the CSS is inlined and the icons are inline
SVG, so there is nothing to resolve at print time and the file can be opened or
printed from anywhere on disk.

### Headless Chrome

This is exactly what `build.mjs` shells out to:

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --no-pdf-header-footer \
  --virtual-time-budget=4000 \
  --print-to-pdf="$PWD/cv.pdf" \
  "file://$PWD/cv.html"
```

Two flags matter. `--no-pdf-header-footer` suppresses Chrome's default page URL
and date furniture, which would otherwise print into the margins. The page size
and margins come from `@page { size: A4; margin: 0 }` in `cv.css`, so no
page-setup flags are needed — Chrome honours the stylesheet.

`--virtual-time-budget=4000` gives the font and layout work time to settle
before the snapshot. Chromium also works; `build.mjs` falls back to it if
Google Chrome isn't installed.

### From the browser

`./build.sh --html-only`, open `cv.html`, then Print. Set the destination to
*Save as PDF*, paper size to A4, margins to **None**, and enable **Background
graphics** — without it the navy header and the accent-filled icon circles print
as white. This route is fine for a quick check but drifts from the headless
output; prefer `./build.sh` for anything you send out.

### Verifying the result

The layout is fixed-height, so mistakes show up as clipping rather than reflow.
Worth a glance after any content edit:

```sh
uv run --with pymupdf python -c "
import pymupdf
d = pymupdf.open('cv.pdf')
print('pages:', d.page_count)
print('links:', len({l['uri'] for p in d for l in p.get_links() if 'uri' in l}))
for i, p in enumerate(d):
    slack = (p.rect.height - max(b[3] for b in p.get_text('blocks'))) / 72 * 25.4
    print(f'page {i+1} bottom slack: {slack:.1f}mm')
"
```

Expect 2 pages and 14 links. Slack going negative, or the page count changing,
means something has outgrown its page.

## Pagination

The page break is explicit: page 1 is experience/education/expertise, page 2 is
publications/patents/academic service. Both are fixed-height `.page` divs with
`break-before: page`, so content is never split unpredictably — if a section
outgrows its page it will clip, and you move an entry or tighten `cv.css`.

## Fonts

Body text uses Inter (Inter Variable, installed locally). Chrome subsets and
embeds it into the PDF, so the output renders identically anywhere; only the
`cv.html` preview falls back on machines without Inter.

## Icons

`icons/` holds one SVG per icon, inlined into `cv.html` at build time so the page
has no external requests. Each file's `viewBox` is the glyph's **own tight
bounding box**; `build.mjs` then re-centres every glyph in one shared square box
sized to the largest glyph in the directory.

### Adding one

From Font Awesome: add its codepoint to `WANT` in `tools/extract-icons.py`, then

```sh
uv run --with fonttools python tools/extract-icons.py
```

which rewrites all of `icons/`. Requires the Font Awesome 6 desktop fonts in
`~/Library/Fonts`.

From anywhere else: drop a file in `icons/` by hand. `build.mjs` expects a single
`<path>` and a `viewBox` holding that path's tight bbox — it does not parse path
data, so a loose viewBox will offset the glyph inside its circle, and transforms,
groups, or multiple paths are not supported. Name the file after the icon
(`icons/foo.svg` becomes `icon("foo")`).
