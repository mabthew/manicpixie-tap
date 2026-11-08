import Foundation

/// Fixed addresses. Everything that changes lives in content.json on the site.
enum Config {
    static let host = "tap.manicpixiethrift.com"
    static let siteURL = URL(string: "https://tap.manicpixiethrift.com/")!
    static let privacyURL = URL(string: "https://tap.manicpixiethrift.com/privacy/")!
    /// Where content.json lives, in order of preference. Relative paths inside the JSON
    /// (images, logo) are resolved against whichever base actually answered.
    static let contentBases: [URL] = [
        URL(string: "https://tap.manicpixiethrift.com/")!,
        URL(string: "https://manicpixie-tap.netlify.app/")!,
    ]

    /// Numeric Apple ID of the App Store record. Filled in after App Store Connect creates it.
    static let appStoreID = ""

    /// Debug builds can point at another site: launch argument `-ContentBase https://…/`.
    static var activeContentBases: [URL] {
        #if DEBUG
        if let s = UserDefaults.standard.string(forKey: "ContentBase"), let url = URL(string: s) {
            return [url]
        }
        #endif
        return contentBases
    }
}
