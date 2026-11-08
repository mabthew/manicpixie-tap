#!/usr/bin/env python3
"""
Build web/public/content.json (and the bundled copy in ios/Sources/Shared/Resources) from
tools/whatnot_snapshot.json, downloading and resizing the Whatnot photos into web/public/images.

Refreshing: open https://www.whatnot.com/user/manicpixiethrift (Shows tab) and /shop in a browser,
update the snapshot's `shows` [liveId, thumbId, localStart, title, tags] and `listings`
[listingId, imageFile, title, price], then run:  python3 tools/build-content.py [--download-dir DIR]
Needs: curl, magick (ImageMagick).
"""
import argparse, hashlib, json, re, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / "web/public"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"

TAG_RULES = [
    (r"corset", "corsets"), (r"jacket|moto|poncho|coat", "outerwear"), (r"dress", "dresses"),
    (r"skirt", "skirts"), (r"jeans|denim", "denim"), (r"boot|shoe|heel", "shoes"),
    (r"\bset\b|two piece", "sets"), (r"\btop\b|tank|mesh|tube", "tops"),
    (r"barbie|fairy|fairytopia", "fairy"), (r"leather|fur", "leather & fur"),
]


def slug(s, n=40):
    s = re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
    return s[:n].rstrip("-") or "item"


def clean_title(t):
    return re.sub(r"^\s*\d+[a-z]?\.\s*", "", t).strip()


def tags_for(title):
    low = title.lower()
    return sorted({tag for pattern, tag in TAG_RULES if re.search(pattern, low)})


def price_label(p):
    m = re.search(r"\$([\d,]+)", p or "")
    if not m:
        return None
    value = int(m.group(1).replace(",", ""))
    return f"from {p.strip()}" if value <= 20 else p.strip()   # low values are live-auction starting bids


def fetch_image(urls, dest_dir):
    for url in urls:
        tmp = Path(tempfile.mkdtemp(dir=dest_dir)) / "img"
        r = subprocess.run(["curl", "-sL", "-A", UA, "-o", str(tmp), "-w", "%{http_code} %{content_type}", url],
                           capture_output=True, text=True)
        code, _, ctype = r.stdout.partition(" ")
        if code == "200" and ctype.startswith("image/") and tmp.stat().st_size > 1000:
            return tmp
    return None


def publish_image(src, subdir, name_slug, max_px=1200):
    out_dir = WEB / "images" / subdir
    out_dir.mkdir(parents=True, exist_ok=True)
    tmp = Path(tempfile.mkdtemp()) / "out.jpg"
    subprocess.run(["magick", str(src), "-auto-orient", "-resize", f"{max_px}x{max_px}>", "-strip", "-quality", "82", str(tmp)], check=True)
    digest = hashlib.sha1(tmp.read_bytes()).hexdigest()[:8]
    final = out_dir / f"{name_slug}-{digest}.jpg"
    if not final.exists():
        final.write_bytes(tmp.read_bytes())
    return f"images/{subdir}/{final.name}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--download-dir", type=Path, default=Path(tempfile.mkdtemp(prefix="whatnot_dl_")))
    ap.add_argument("--max-pieces", type=int, default=24)
    args = ap.parse_args()
    snap = json.loads((ROOT / "tools/whatnot_snapshot.json").read_text())
    tz = snap["timezone"]
    args.download_dir.mkdir(parents=True, exist_ok=True)

    lives = []
    for live_id, thumb, start, title, tags in snap["shows"]:
        img = fetch_image([f"https://images.whatnot.com/fit-in/900x0/filters:format(jpeg)/livestream_thumbnails%2F{thumb}.jpeg",
                           f"https://images.whatnot.com/fit-in/640x0/filters:format(webp)/livestream_thumbnails%2F{thumb}.jpeg"], args.download_dir)
        lives.append({
            "title": title,
            "startsAt": f"{start}:00{tz}",
            "url": f"https://www.whatnot.com/live/{live_id}",
            "platform": "whatnot",
            **({"imageURL": publish_image(img, "lives", slug(title))} if img else {}),
            **({"tags": [t.strip() for t in tags.split(",") if t.strip()]} if tags else {}),
        })
        print(f"live  {title[:40]:40s} {'image ok' if img else 'NO IMAGE'}", file=sys.stderr)

    pieces = []
    for listing_id, image_file, title, price in snap["listings"][: args.max_pieces]:
        img = fetch_image([f"https://images.whatnot.com/fit-in/1000x0/filters:format(jpeg)/listings%2F{image_file}.jpeg",
                           f"https://images.whatnot.com/fit-in/640x0/filters:format(webp)/listings%2F{image_file}.jpeg"], args.download_dir)
        if not img:
            print(f"piece {title[:40]:40s} NO IMAGE, skipped", file=sys.stderr)
            continue
        clean = clean_title(title)
        pieces.append({
            "id": listing_id.rstrip("=").replace("+", "-").replace("/", "_"),
            "title": clean,
            "price": price_label(price),
            "imageURL": publish_image(img, "drops/2026-11", slug(clean)),
            "url": f"https://www.whatnot.com/listing/{listing_id}",
            "sold": False,
            "tags": tags_for(clean),
        })
        print(f"piece {clean[:40]:40s} ok", file=sys.stderr)

    content = {
        "schemaVersion": 1,
        "updatedAt": snap["capturedAt"],
        "brand": {"name": "Manic Pixie Thrift", "handle": "@manicpixiethrift", "tagline": "wear what you want <3",
                  "logoURL": "images/logo-512.png", "accentHex": "#C9B6E4"},
        "links": [
            {"id": "whatnot", "kind": "whatnot", "title": "Whatnot shop & lives", "url": snap["profile"]},
            {"id": "depop", "kind": "depop", "title": "Depop", "url": "https://www.depop.com/manicpixiethrift"},
            {"id": "instagram", "kind": "instagram", "title": "Instagram", "url": "https://www.instagram.com/manicpixiethrift/"},
            {"id": "tiktok", "kind": "tiktok", "title": "TikTok", "url": "https://www.tiktok.com/@manicpixiethrift"},
            {"id": "pinterest", "kind": "pinterest", "title": "Pinterest", "url": "https://www.pinterest.com/manicpixiethrift/"},
            {"id": "site", "kind": "website", "title": "manicpixiethrift.com", "url": "https://manicpixiethrift.com/"},
        ],
        "booking": {"title": "Styling appointment",
                    "blurb": "Style bundles shipped to you, or shop the studio together in Denver",
                    "url": "https://calendly.com/mpdgthrift"},
        "lives": lives,
        "drop": {"title": "In the shop now", "pieces": pieces},
    }
    text = json.dumps(content, indent=2, ensure_ascii=False) + "\n"
    for path in (WEB / "content.json", ROOT / "ios/Sources/Shared/Resources/content.json"):
        path.write_text(text)
    print(f"content.json: {len(lives)} lives, {len(pieces)} pieces, {len(text)} bytes")


if __name__ == "__main__":
    main()
