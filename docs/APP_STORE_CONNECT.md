# App Store Connect checklist (Matthew)

Prerequisites: the tap site is live over HTTPS (docs/PARTNER_SETUP.md), the iPhone is in Developer Mode.

1. **Register the App IDs** (usually automatic on the first device build with automatic signing; if
   Xcode complains): developer.apple.com → Identifiers → `+` → App IDs → App → explicit
   `com.manicpixiethrift.app`, capability Associated Domains. Then `+` → App IDs → **App Clip** →
   parent `com.manicpixiethrift.app` → suffix `Clip` → Associated Domains.
2. **Create the app**: App Store Connect → My Apps → `+` → New App → iOS, name **Manic Pixie Thrift**
   (fallback "Manic Pixie Thrift Shop"), English (U.S.), bundle ID `com.manicpixiethrift.app`,
   SKU `manicpixiethrift-ios`. Copy the numeric **Apple ID** into `ios/Sources/Shared/Config.swift`
   (`appStoreID`) and into the `apple-itunes-app` meta tag in `web/public/index.html`.
3. **App Information**: category Shopping (secondary Lifestyle). Age rating 4+.
   Privacy policy `https://tap.manicpixiethrift.com/privacy/`. Support URL `https://manicpixiethrift.com`.
4. **App Privacy**: Data Not Collected. **Pricing**: Free, all territories.
5. **Archive and upload**: Xcode → scheme `ManicPixieThrift` → destination Any iOS Device →
   Product → Archive → Validate App → Distribute App → App Store Connect → Upload.
6. **Version 1.0 page**: screenshots (6.9" and 6.5" iPhone, from the Simulator: home and a piece
   detail), description, keywords, attach the build.
7. **App Clip card (default experience)**: in the App Clip section of the version page upload
   `web/public/images/card-header.jpg` (1800 x 1200), subtitle
   `Secondhand styling in Denver · wear what you want <3`, action **Open**.
8. **Advanced App Clip experience**: Edit Advanced Experiences → URL `https://tap.manicpixiethrift.com`
   → same card copy → "not associated with a place" → action Open → "promotes my business".
9. **Domain status**: build → App Clip → Domain Status → Load Debug Status must say the domain is valid.
10. **TestFlight**: add yourself as an internal tester, install, open the App Clip from the TestFlight app.
11. **App Review Information**: paste docs/REVIEW_NOTES.md, attach `tools/review-qr.png`.
    Set version release to **Manually release**. Submit.
12. **After approval**: release. On the iPhone, Settings → Developer → Local Experiences: delete the test
    experience, then Clear Experience Cache. Tap a fob: card, then clip.
