import Foundation
import Observation

/// Bundled content first (instant UI), then the last good download, then a fresh download.
/// The UI is never blanked: a failed refresh keeps whatever is showing.
@MainActor
@Observable
final class ContentLoader {
    enum Source: String { case bundled, cached, network }

    private(set) var content: SiteContent
    private(set) var source: Source
    private(set) var lastError: String?
    private(set) var isRefreshing = false

    private let session: URLSession
    private let cacheFile: URL

    init(session: URLSession = .shared) {
        self.session = session
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheFile = caches.appendingPathComponent("content.json")

        let bundled = Self.loadBundled()
        if let data = try? Data(contentsOf: cacheFile),
           let cached = try? JSONDecoder.content.decode(SiteContent.self, from: data),
           cached.schemaVersion == SiteContent.supportedSchema,
           cached.updatedAt >= bundled.updatedAt {
            content = cached
            source = .cached
        } else {
            content = bundled
            source = .bundled
        }
    }

    static func loadBundled() -> SiteContent {
        guard let url = Bundle.main.url(forResource: "content", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let content = try? JSONDecoder.content.decode(SiteContent.self, from: data)
        else { fatalError("Bundled content.json is missing or invalid") }
        return content
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        var request = URLRequest(url: Config.contentURL, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 8)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let fresh = try JSONDecoder.content.decode(SiteContent.self, from: data)
            guard fresh.schemaVersion == SiteContent.supportedSchema else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unsupported schema \(fresh.schemaVersion)"))
            }
            content = fresh
            source = .network
            lastError = nil
            try? data.write(to: cacheFile, options: .atomic)
        } catch {
            lastError = error.localizedDescription
        }
    }
}
