import json, os
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.misc.transform import Identity

FD = os.path.expanduser("~/Library/Fonts")
SOLID  = os.path.join(FD, "Font Awesome 6 Free-Solid-900.otf")
BRANDS = os.path.join(FD, "Font Awesome 6 Brands-Regular-400.otf")

WANT = {
    SOLID:  {"envelope":0xf0e0, "home":0xf015, "scholar":0xf19d, "briefcase":0xf0b1,
             "education":0xf19d, "gear":0xf013, "book":0xf02d, "award":0xf559, "users":0xf0c0,
             "external":0xf08e},
    BRANDS: {"github":0xf09b, "linkedin":0xf08c},
}

out, raw = {}, {}
for path, wants in WANT.items():
    f = TTFont(path)
    cmap = f.getBestCmap()
    gs = f.getGlyphSet()
    for name, cp in wants.items():
        gname = cmap.get(cp)
        if gname is None:
            print("MISS", name, hex(cp)); continue
        bp = BoundsPen(gs); gs[gname].draw(bp)
        x0, y0, x1, y1 = bp.bounds
        # flip y for SVG coords
        sp = SVGPathPen(gs)
        gs[gname].draw(TransformPen(sp, Identity.scale(1, -1)))
        raw[name] = {"d": sp.getCommands(), "bbox": (x0, y0, x1, y1)}
        print(f"ok {name:10s} {len(raw[name]['d']):5d} chars  bbox={x0:.0f},{y0:.0f} {x1:.0f},{y1:.0f}")

# ONE shared box for every glyph, so they all scale by the same factor (like an
# fa-fw fixed-width icon font). A per-glyph box would scale each icon's longest
# axis to the same length, making a wide glyph render visibly smaller in height.
SIDE = max(max(x1 - x0, y1 - y0) for g in raw.values() for x0, y0, x1, y1 in [g["bbox"]])
print(f"\nshared box: {SIDE:.0f} units")
for name, g in raw.items():
    x0, y0, x1, y1 = g["bbox"]
    vx = x0 - (SIDE - (x1 - x0)) / 2      # centre the glyph in the shared box
    vy = -y1 - (SIDE - (y1 - y0)) / 2
    out[name] = {"d": g["d"], "viewBox": f"{vx:.0f} {vy:.0f} {SIDE:.0f} {SIDE:.0f}"}
    print(f"  {name:10s} renders at {(y1-y0)/SIDE:.2f} x box height")

json.dump(out, open("icons.json", "w"), indent=1)
