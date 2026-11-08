# manicpixie-tap

iOS app + App Clip for Manic Pixie Thrift, and the small static site at `tap.manicpixiethrift.com`
that the NFC keychain fobs and QR codes point to.

* `ios/` – XcodeGen project. `ManicPixieThrift` (full app) and `ManicPixieThriftClip` (App Clip)
  share `ios/Sources/Shared`. Regenerate the project after adding files:
  `cd ios && xcodegen generate && open ManicPixieThrift.xcodeproj`
* `web/` – Netlify site (`publish = web/public`): `/.well-known/apple-app-site-association`,
  the landing page, `content.json` (what the app shows) and images.
  Deploy: `cd web && netlify deploy --prod`
* `tools/add-image.sh photo.jpg drops/2026-11 slug` – resize a photo for the gallery and print its URL.
* `tools/check-aasa.sh` – verify the association file is served correctly.

Updating what the app shows: edit `web/public/content.json` (and copy it to
`ios/Sources/Shared/Resources/content.json` so the bundled fallback stays current), add images with
`tools/add-image.sh`, deploy. No App Store update needed.

Invocation URL: `https://tap.manicpixiethrift.com/` (NFC record `https://tap.manicpixiethrift.com/?src=fob`,
QR payload `HTTPS://TAP.MANICPIXIETHRIFT.COM`). Bundle IDs `com.manicpixiethrift.app` / `.Clip`, team 379TRF57VQ.
