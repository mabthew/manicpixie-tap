#!/bin/sh
# Check that the apple-app-site-association file is served the way iOS needs it.
host="${1:-tap.manicpixiethrift.com}"
echo "== https://$host/.well-known/apple-app-site-association"
curl -sI "https://$host/.well-known/apple-app-site-association" | grep -iE "^HTTP|^content-type|^location" || echo "  (no response)"
echo "== body"
curl -s "https://$host/.well-known/apple-app-site-association" | head -c 400; echo
echo "== Apple CDN copy (404 until Apple has fetched it, usually within 24 h)"
curl -sI "https://app-site-association.cdn-apple.com/a/v1/$host" | grep -iE "^HTTP|apple-origin|^content-type" || echo "  (no response)"
echo "== landing page"
curl -sI "https://$host/" | grep -iE "^HTTP|^content-type"
