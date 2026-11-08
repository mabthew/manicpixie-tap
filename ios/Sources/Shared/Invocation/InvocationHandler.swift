import Foundation
import Observation

/// What launched us. Read from the invocation URL; nothing is stored or sent anywhere.
///   https://tap.manicpixiethrift.com/?src=fob            NFC fob
///   https://tap.manicpixiethrift.com/                    printed QR (no query)
///   https://tap.manicpixiethrift.com/?section=drop       jump to a section
@MainActor
@Observable
final class InvocationState {
    enum Source: String { case fob, qr, web, unknown }
    enum Section: String, Hashable { case drop, live, book, links }

    private(set) var source: Source = .unknown
    private(set) var url: URL?
    var scrollTarget: Section?

    func handle(_ url: URL?) {
        self.url = url
        guard let url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            source = .unknown
            return
        }
        var query: [String: String] = [:]
        for item in components.queryItems ?? [] {
            if let value = item.value, query[item.name.lowercased()] == nil {
                query[item.name.lowercased()] = value.lowercased()
            }
        }
        source = query["src"].flatMap(Source.init(rawValue:)) ?? .qr
        scrollTarget = query["section"].flatMap(Section.init(rawValue:))
    }
}
