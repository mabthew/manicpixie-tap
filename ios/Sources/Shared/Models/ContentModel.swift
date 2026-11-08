import Foundation

/// Everything the app shows, decoded from content.json (schemaVersion 1).
struct SiteContent: Codable, Sendable, Equatable {
    static let supportedSchema = 1

    var schemaVersion: Int
    var updatedAt: Date
    var brand: Brand
    var links: [LinkItem]
    var booking: Booking?
    var nextLive: LiveEvent?
    var lives: [LiveEvent]?
    var drop: Drop?

    /// Scheduled lives that have not ended, soonest first. Falls back to `nextLive`.
    func upcomingLives(now: Date = .now) -> [LiveEvent] {
        let all = (lives ?? []) + (nextLive.map { [$0] } ?? [])
        return all
            .filter { LiveState.from(now: now, event: $0) != .ended }
            .sorted { $0.startsAt < $1.startsAt }
    }
}

struct Brand: Codable, Sendable, Equatable {
    var name: String
    var handle: String
    var tagline: String
    var logoURL: URL
    var accentHex: String
}

enum LinkKind: String, Codable, Sendable {
    case depop, whatnot, instagram, tiktok, pinterest, linktree, website, other

    /// Unknown kinds from a newer content file decode as `.other` instead of failing.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = LinkKind(rawValue: raw.lowercased()) ?? .other
    }

    var symbol: String {
        switch self {
        case .depop: "bag"
        case .whatnot: "video"
        case .instagram: "camera"
        case .tiktok: "music.note"
        case .pinterest: "pin"
        case .linktree: "link"
        case .website: "globe"
        case .other: "arrow.up.right.square"
        }
    }
}

struct LinkItem: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var kind: LinkKind
    var title: String
    var url: URL
    var symbol: String?

    var systemImage: String { symbol ?? kind.symbol }
}

struct Booking: Codable, Sendable, Equatable {
    var title: String
    var blurb: String
    var url: URL
}

struct LiveEvent: Codable, Sendable, Equatable, Identifiable, Hashable {
    var title: String
    var startsAt: Date
    var endsAt: Date?
    var url: URL
    var platform: String
    var imageURL: URL?
    var tags: [String]?

    var id: URL { url }
}

struct Drop: Codable, Sendable, Equatable {
    var title: String
    var pieces: [Piece]
}

struct Piece: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String
    var title: String
    var size: String?
    var price: String?
    var imageURL: URL
    var url: URL?
    var sold: Bool
    var tags: [String]
    var measurements: String?

    init(id: String, title: String, size: String? = nil, price: String? = nil, imageURL: URL,
         url: URL? = nil, sold: Bool = false, tags: [String] = [], measurements: String? = nil) {
        self.id = id; self.title = title; self.size = size; self.price = price
        self.imageURL = imageURL; self.url = url; self.sold = sold; self.tags = tags
        self.measurements = measurements
    }

    /// `sold` and `tags` may be omitted in the JSON.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        size = try c.decodeIfPresent(String.self, forKey: .size)
        price = try c.decodeIfPresent(String.self, forKey: .price)
        imageURL = try c.decode(URL.self, forKey: .imageURL)
        url = try c.decodeIfPresent(URL.self, forKey: .url)
        sold = try c.decodeIfPresent(Bool.self, forKey: .sold) ?? false
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        measurements = try c.decodeIfPresent(String.self, forKey: .measurements)
    }
}

/// Where a live event stands relative to `now`. Pure, so it is unit-testable.
enum LiveState: Equatable, Sendable {
    case none
    case upcoming(TimeInterval)
    case live
    case ended

    static let defaultDuration: TimeInterval = 3 * 3600

    static func from(now: Date, event: LiveEvent?) -> LiveState {
        guard let event else { return .none }
        if now < event.startsAt { return .upcoming(event.startsAt.timeIntervalSince(now)) }
        let end = event.endsAt ?? event.startsAt.addingTimeInterval(defaultDuration)
        return now < end ? .live : .ended
    }
}

enum ContentDates {
    /// ISO 8601 with or without fractional seconds, with "Z" or a numeric offset.
    static func parse(_ string: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: string) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: string)
    }
}

extension JSONDecoder {
    /// The decoder for content.json.
    static var content: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let s = try container.decode(String.self)
            guard let date = ContentDates.parse(s) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognised date: \(s)")
            }
            return date
        }
        return d
    }
}

extension SiteContent {
    /// Resolves relative paths in the JSON (for example `images/logo-512.png`) against the site
    /// the content was loaded from. Absolute URLs are left alone.
    func resolvingURLs(against base: URL) -> SiteContent {
        var c = self
        c.brand.logoURL = Self.resolve(c.brand.logoURL, against: base)
        c.links = c.links.map { var l = $0; l.url = Self.resolve(l.url, against: base); return l }
        if var b = c.booking { b.url = Self.resolve(b.url, against: base); c.booking = b }
        if var e = c.nextLive { e.url = Self.resolve(e.url, against: base); e.imageURL = e.imageURL.map { Self.resolve($0, against: base) }; c.nextLive = e }
        c.lives = c.lives?.map { live in
            var e = live
            e.url = Self.resolve(e.url, against: base)
            e.imageURL = e.imageURL.map { Self.resolve($0, against: base) }
            return e
        }
        if var d = c.drop {
            d.pieces = d.pieces.map { piece in
                var p = piece
                p.imageURL = Self.resolve(p.imageURL, against: base)
                p.url = p.url.map { Self.resolve($0, against: base) }
                return p
            }
            c.drop = d
        }
        return c
    }

    static func resolve(_ url: URL, against base: URL) -> URL {
        if url.scheme != nil { return url }
        return URL(string: url.relativeString, relativeTo: base)?.absoluteURL ?? url
    }
}

extension JSONEncoder {
    /// Matches `JSONDecoder.content` (ISO 8601 dates) for the on-device cache.
    static var content: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
}
