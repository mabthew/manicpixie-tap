import Foundation
import Testing
@testable import ManicPixieThrift

@Suite struct ContentModelTests {
    /// web/public/content.json, relative to this file, so the app and site schemas stay in step.
    static var webContentURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // ios
            .deletingLastPathComponent()   // repo root
            .appendingPathComponent("web/public/content.json")
    }

    @Test func decodesTheSiteContentFile() throws {
        let data = try Data(contentsOf: Self.webContentURL)
        let content = try JSONDecoder.content.decode(SiteContent.self, from: data)
        #expect(content.schemaVersion == SiteContent.supportedSchema)
        #expect(!content.links.isEmpty)
        #expect(content.brand.name == "Manic Pixie Thrift")
        #expect(content.drop?.pieces.isEmpty == false)
    }

    @Test func bundledFallbackMatchesTheSiteFile() throws {
        let bundledURL = Self.webContentURL
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("ios/Sources/Shared/Resources/content.json")
        let web = try JSONDecoder.content.decode(SiteContent.self, from: Data(contentsOf: Self.webContentURL))
        let bundled = try JSONDecoder.content.decode(SiteContent.self, from: Data(contentsOf: bundledURL))
        #expect(web == bundled, "copy web/public/content.json to ios/Sources/Shared/Resources/content.json")
    }

    @Test func unknownLinkKindDecodesAsOther() throws {
        let json = #"{"id":"x","kind":"threads","title":"Threads","url":"https://example.com"}"#
        let item = try JSONDecoder.content.decode(LinkItem.self, from: Data(json.utf8))
        #expect(item.kind == .other)
        #expect(item.systemImage == "arrow.up.right.square")
    }

    @Test func pieceDefaultsSoldAndTags() throws {
        let json = #"{"id":"p","title":"T","imageURL":"https://example.com/a.jpg"}"#
        let piece = try JSONDecoder.content.decode(Piece.self, from: Data(json.utf8))
        #expect(piece.sold == false)
        #expect(piece.tags.isEmpty)
        #expect(piece.url == nil)
    }

    @Test func datesWithAndWithoutFractionsAndOffsets() throws {
        #expect(ContentDates.parse("2026-11-15T19:00:00-07:00") != nil)
        #expect(ContentDates.parse("2026-11-15T02:00:00Z") != nil)
        #expect(ContentDates.parse("2026-11-15T02:00:00.250Z") != nil)
        #expect(ContentDates.parse("yesterday") == nil)
        let a = try #require(ContentDates.parse("2026-11-15T19:00:00-07:00"))
        let b = try #require(ContentDates.parse("2026-11-16T02:00:00Z"))
        #expect(a == b)
    }

    @Test func liveStateBoundaries() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let event = LiveEvent(title: "t", startsAt: start, endsAt: nil,
                              url: URL(string: "https://example.com")!, platform: "whatnot")
        #expect(LiveState.from(now: start.addingTimeInterval(-60), event: event) == .upcoming(60))
        #expect(LiveState.from(now: start, event: event) == .live)
        #expect(LiveState.from(now: start.addingTimeInterval(LiveState.defaultDuration - 1), event: event) == .live)
        #expect(LiveState.from(now: start.addingTimeInterval(LiveState.defaultDuration), event: event) == .ended)
        #expect(LiveState.from(now: start, event: nil) == .none)
        #expect(LiveCountdownView.countdown(90_061) == "1d 1h 1m")
        #expect(LiveCountdownView.countdown(3_661) == "01:01:01")
    }

    @Test @MainActor func invocationURLParsing() {
        let state = InvocationState()
        state.handle(nil)
        #expect(state.source == .unknown)
        state.handle(URL(string: "https://tap.manicpixiethrift.com/?src=fob&section=drop")!)
        #expect(state.source == .fob)
        #expect(state.scrollTarget == .drop)
        state.handle(URL(string: "https://tap.manicpixiethrift.com/")!)
        #expect(state.source == .qr)
        state.handle(URL(string: "HTTPS://TAP.MANICPIXIETHRIFT.COM/?SRC=FOB")!)
        #expect(state.source == .fob)
    }
}
