#if !APPCLIP
import SwiftUI
import Observation

/// Hearts on pieces, kept on this device. Full app only: App Clip storage is short-lived.
@MainActor
@Observable
final class FavouritesStore {
    private(set) var ids: Set<String> = []
    private let file: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        file = dir.appendingPathComponent("favourites.json")
        if let data = try? Data(contentsOf: file),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            ids = saved
        }
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    func toggle(_ id: String) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        if let data = try? JSONEncoder().encode(ids) {
            try? data.write(to: file, options: .atomic)
        }
    }
}

struct FavouriteButton: View {
    let pieceID: String
    @Environment(FavouritesStore.self) private var store

    var body: some View {
        let saved = store.contains(pieceID)
        Button {
            store.toggle(pieceID)
        } label: {
            Label(saved ? "Saved" : "Save for later", systemImage: saved ? "heart.fill" : "heart")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(Theme.ink)
    }
}

/// Saved pieces, shown above the gallery in the full app.
struct SavedStrip: View {
    let pieces: [Piece]
    let onSelect: (Piece) -> Void
    @Environment(FavouritesStore.self) private var store

    private var saved: [Piece] { pieces.filter { store.contains($0.id) } }

    var body: some View {
        if !saved.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Saved").font(Theme.serif(.title3))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(saved) { piece in
                            Button { onSelect(piece) } label: {
                                PieceCard(piece: piece).frame(width: 150)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .foregroundStyle(Theme.ink)
        }
    }
}

/// No-op in the full app; the App Clip's version shows the App Store overlay.
struct FullAppPromo: ViewModifier {
    @Binding var isPresented: Bool
    func body(content: Content) -> some View { content }
}
#endif
