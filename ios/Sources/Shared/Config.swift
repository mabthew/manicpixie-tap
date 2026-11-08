import Foundation

/// Fixed addresses. Everything that changes lives in content.json on the site.
enum Config {
    static let host = "tap.manicpixiethrift.com"
    static let siteURL = URL(string: "https://tap.manicpixiethrift.com/")!
    static let privacyURL = URL(string: "https://tap.manicpixiethrift.com/privacy/")!
    static let defaultContentURL = URL(string: "https://tap.manicpixiethrift.com/content.json")!

    /// Numeric Apple ID of the App Store record. Filled in after App Store Connect creates it.
    static let appStoreID = ""

    /// Debug builds can point at another content file: launch argument `-ContentURL https://…`.
    static var contentURL: URL {
        #if DEBUG
        if let s = UserDefaults.standard.string(forKey: "ContentURL"), let url = URL(string: s) {
            return url
        }
        #endif
        return defaultContentURL
    }
}
