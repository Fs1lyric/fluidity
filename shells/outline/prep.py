#!/usr/bin/python3
"""Prepare one wallpaper for the Outline transitions, cached once per picture (like the post: cut once, then instant).

  prep.py IMAGE   ->  prints the cache folder, holding:
    edges.png   the picture's outline: white lines on transparent, 1920x1080, cropped like the wallpaper
    grow.png    the growth map: opaque on the lines (and the subject), fading with distance from them, so the
                picture can be revealed outward from its own outline by raising a threshold
    info        "character CX CY" when the edges gather around a subject (outline draws first, world grows out),
                "colonies" when they do not (pixel colonies eat the old picture)
    palette     bg fg accent accent2 (hex), the colours the bar repaints itself with (pywal's job in the post)
"""
import hashlib, os, sys
import numpy as np
from PIL import Image, ImageFilter, ImageOps

W, H = 1920, 1080


def cover(im):
    """Scale and centre-crop to fill the screen, like the wallpaper daemon does."""
    s = max(W / im.width, H / im.height)
    im = im.resize((max(W, round(im.width * s)), max(H, round(im.height * s))), Image.LANCZOS)
    l, t = (im.width - W) // 2, (im.height - H) // 2
    return im.crop((l, t, l + W, t + H))


def edges(gray):
    """Sobel magnitude, thinned to the strongest ~6 % of pixels (never below a floor, so flat art keeps only its real lines)."""
    g = np.asarray(gray.filter(ImageFilter.GaussianBlur(1.6)), dtype=np.float32)
    gx = np.zeros_like(g); gy = np.zeros_like(g)
    gx[:, 1:-1] = g[:, 2:] - g[:, :-2]
    gy[1:-1, :] = g[2:, :] - g[:-2, :]
    mag = np.hypot(gx, gy)
    return mag >= max(np.percentile(mag, 94), 0.12 * mag.max(), 4.0)


def palette(rgb):
    small = rgb.resize((96, 54)).quantize(8, method=Image.Quantize.MEDIANCUT).convert("RGB")
    px = [tuple(int(v) for v in c) for c in np.asarray(small).reshape(-1, 3)]
    cols = sorted(set(px), key=lambda c: -px.count(c))
    lum = lambda c: 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
    sat = lambda c: (max(c) - min(c)) / (max(c) + 1)
    bg = min(cols, key=lum)
    bg = tuple(int(v * 0.45) for v in bg)                       # darkened so text always reads
    fg = max(cols, key=lum)
    fg = tuple(min(255, int(v * 0.6 + 255 * 0.4)) for v in fg)   # lifted towards white
    vivid = sorted(cols, key=lambda c: -(sat(c) * (0.4 + lum(c) / 255)))
    acc = vivid[0]
    acc2 = vivid[1] if len(vivid) > 1 else acc
    lift = lambda c: tuple(min(255, int(v + (255 - v) * 0.25)) for v in c) if lum(c) < 110 else c
    return [bg, fg, lift(acc), lift(acc2)]


def main(path):
    key = hashlib.sha1((os.path.realpath(path) + str(os.path.getmtime(path))).encode()).hexdigest()[:16]
    out = os.path.join(os.path.expanduser("~/.cache/fluidity/outline"), key)
    if os.path.exists(os.path.join(out, "info")):
        print(out); return
    os.makedirs(out, exist_ok=True)
    rgb = cover(ImageOps.exif_transpose(Image.open(path)).convert("RGB"))
    e = edges(rgb.convert("L"))
    alpha = Image.fromarray((e * 255).astype(np.uint8))
    line = Image.new("RGBA", (W, H), (255, 255, 255, 0)); line.putalpha(alpha)
    line.save(os.path.join(out, "edges.png"))
    # growth map at half size: distance from the nearest line, a quarter of it distance from the subject
    from scipy import ndimage
    small = np.asarray(Image.fromarray(e.astype(np.uint8) * 255).resize((W // 2, H // 2), Image.BILINEAR)) > 40
    d_line = ndimage.distance_transform_edt(~small)
    yy, xx = np.mgrid[0: H // 2, 0: W // 2]
    ys0, xs0 = np.nonzero(e)
    cx0, cy0 = (xs0.mean() / 2, ys0.mean() / 2) if len(xs0) else (W / 4, H / 4)
    d_mid = np.hypot(xx - cx0, yy - cy0)
    d = 0.75 * d_line / max(d_line.max(), 1) + 0.25 * d_mid / max(d_mid.max(), 1)
    grow = Image.new("RGBA", (W // 2, H // 2), (255, 255, 255, 0))
    grow.putalpha(Image.fromarray((255 * (1 - d / max(d.max(), 1e-6))).astype(np.uint8)))
    grow.save(os.path.join(out, "grow.png"))
    # A subject = edges concentrated in the middle third compared with the frame's rim.
    ys, xs = np.nonzero(e)
    mid = e[H // 6: H * 5 // 6, W // 4: W * 3 // 4].mean()
    rim = np.concatenate([e[:, : W // 8].ravel(), e[:, -W // 8:].ravel(), e[: H // 8].ravel(), e[-H // 8:].ravel()]).mean()
    character = len(xs) > 0 and mid > 1.35 * max(rim, 1e-6)
    cx, cy = (int(xs.mean()), int(ys.mean())) if len(xs) else (W // 2, H // 2)
    with open(os.path.join(out, "info"), "w") as f:
        f.write(f"character {cx} {cy}\n" if character else "colonies\n")
    with open(os.path.join(out, "palette"), "w") as f:
        f.write(" ".join("#%02x%02x%02x" % c for c in palette(rgb)) + "\n")
    print(out)


if __name__ == "__main__":
    main(sys.argv[1])
