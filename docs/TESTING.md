# Testing the App Clip before it is on the App Store

## Simulator
    cd ios && xcodegen generate
    xcodebuild test -project ManicPixieThrift.xcodeproj -scheme ManicPixieThrift \
      -destination 'platform=iOS Simulator,name=iPhone Air' CODE_SIGNING_ALLOWED=NO
Run the `ManicPixieThriftClip` scheme in Xcode: the scheme's `_XCAppClipURL` environment variable
feeds it `https://tap.manicpixiethrift.com/?src=fob`. Untick the variable to exercise the no-URL path. Add the launch argument
`-ContentBase https://invalid.example/` to prove the bundled fallback.

## Your iPhone, with the real fob (no App Store needed)
1. Settings → Privacy & Security → Developer Mode → on (restart).
2. Plug the phone in, select it in Xcode, run the `ManicPixieThriftClip` scheme once (caches the clip).
3. Settings → Developer → Local Experiences → Register Local Experience:
   URL `https://tap.manicpixiethrift.com`, bundle ID `com.manicpixiethrift.app.Clip`,
   title `Manic Pixie Thrift`, subtitle `Secondhand styling in Denver · wear what you want <3`,
   any photo, action Open.
4. With NFC Tools, write a URL record `https://tap.manicpixiethrift.com/?src=fob` to a coin or fob.
   Tap it: the App Clip card appears, Open launches the clip.
5. Show `tools/review-qr.png` on a screen and scan it with the Camera: same card.
6. Before testing the App Store version later, delete the local experience (it takes precedence)
   and tap Clear Experience Cache.

## Size
Xcode → Organizer → Distribute App → Development → All compatible device variants → export, then read
`App Thinning Size Report.txt`. The clip must stay well under 15 MB uncompressed (it is about 2 MB).

## Website
    tools/check-aasa.sh
