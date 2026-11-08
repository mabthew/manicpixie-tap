import SwiftUI

struct PieceDetailView: View {
    let pieces: [Piece]
    @State private var selection: String

    init(pieces: [Piece], selected: Piece) {
        self.pieces = pieces
        _selection = State(initialValue: selected.id)
    }

    private var current: Piece? { pieces.first { $0.id == selection } }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(pieces) { piece in
                PiecePage(piece: piece).tag(piece.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: pieces.count > 1 ? .automatic : .never))
        .background(Theme.cream.ignoresSafeArea())
        .navigationTitle(current?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let url = current?.url {
                ToolbarItem(placement: .topBarTrailing) { ShareLink(item: url) }
            }
        }
    }
}

struct PiecePage: View {
    let piece: Piece
    @State private var zoomed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Color.clear
                    .aspectRatio(3 / 4, contentMode: .fit)
                    .overlay {
                        AsyncImage(url: piece.imageURL) { phase in
                            if case .success(let image) = phase {
                                image.resizable().scaledToFill()
                                    .scaleEffect(zoomed ? 1.8 : 1)
                            } else {
                                Placeholder(systemImage: nil)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .onTapGesture(count: 2) { withAnimation(.spring) { zoomed.toggle() } }

                Text(piece.title).font(Theme.serif(.title2))

                HStack(spacing: 10) {
                    if let size = piece.size { DetailPill("Size", size) }
                    if let price = piece.price { DetailPill("Price", price) }
                    if piece.sold { DetailPill("Status", "Sold") }
                }
                if let measurements = piece.measurements {
                    Text(measurements).font(.footnote).opacity(0.75)
                }
                if !piece.tags.isEmpty {
                    Text(piece.tags.map { "#" + $0 }.joined(separator: "   "))
                        .font(.footnote)
                        .opacity(0.6)
                }
                if let url = piece.url, !piece.sold {
                    Link(destination: url) {
                        Label("Buy on Depop", systemImage: "bag")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.ink)
                }
                FavouriteButton(pieceID: piece.id)
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .foregroundStyle(Theme.ink)
    }
}

struct DetailPill: View {
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).textCase(.uppercase).opacity(0.5)
            Text(value).font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.ink.opacity(0.06)))
    }
}
