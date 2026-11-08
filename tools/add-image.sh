#!/bin/sh
# Resize a photo for the gallery, name it by content hash (safe with the immutable cache header), print its URL.
#   tools/add-image.sh ~/Desktop/blazer.jpg drops/2026-11 leather-blazer
set -e
src="$1"; dir="$2"; slug="$3"
[ -n "$src" ] && [ -n "$dir" ] && [ -n "$slug" ] || { echo "usage: $0 <photo> <images subdir e.g. drops/2026-11> <slug>" >&2; exit 2; }
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -t mpimg).jpg"
magick "$src" -auto-orient -resize '1200x1200>' -strip -quality 82 "$tmp"
hash="$(shasum "$tmp" | cut -c1-8)"
mkdir -p "$root/web/public/images/$dir"
out="$root/web/public/images/$dir/$slug-$hash.jpg"
mv "$tmp" "$out"
echo "https://tap.manicpixiethrift.com/images/$dir/$slug-$hash.jpg"
