import SwiftUI

struct DropGalleryView: View {
    let drop: Drop
    @Binding var activeTag: String?
    let onSelect: (Piece) -> Void

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var tags: [String] { Array(Set(drop.pieces.flatMap(\.tags))).sorted() }

    private var shown: [Piece] {
        guard let activeTag else { return drop.pieces }
        return drop.pieces.filter { $0.tags.contains(activeTag) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(drop.title).font(Theme.serif(.title2))
                Spacer()
                Text("\(shown.count) piece\(shown.count == 1 ? "" : "s")")
                    .font(.footnote)
                    .opacity(0.6)
            }
            if tags.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TagChip(title: "All", selected: activeTag == nil) { activeTag = nil }
                        ForEach(tags, id: \.self) { tag in
                            TagChip(title: tag.capitalized, selected: activeTag == tag) {
                                activeTag = (activeTag == tag) ? nil : tag
                            }
                        }
                    }
                }
            }
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(shown) { piece in
                    Button { onSelect(piece) } label: { PieceCard(piece: piece) }
                        .buttonStyle(.plain)
                }
            }
        }
        .foregroundStyle(Theme.ink)
    }
}

struct TagChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(selected ? Theme.ink : Theme.ink.opacity(0.08)))
                .foregroundStyle(selected ? Theme.cream : Theme.ink)
        }
        .buttonStyle(.plain)
    }
}

struct PieceCard: View {
    let piece: Piece

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear
                .aspectRatio(3 / 4, contentMode: .fit)
                .overlay {
                    AsyncImage(url: piece.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Placeholder(systemImage: "photo")
                        default:
                            Placeholder(systemImage: nil)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if piece.sold {
                        Text("SOLD")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Theme.ink))
                            .foregroundStyle(Theme.cream)
                            .padding(8)
                    }
                }
            Text(piece.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            HStack(spacing: 8) {
                if let size = piece.size { Text(size) }
                if let price = piece.price { Text(price).fontWeight(.semibold) }
            }
            .font(.footnote)
            .opacity(0.75)
        }
    }
}

struct Placeholder: View {
    let systemImage: String?

    var body: some View {
        ZStack {
            Rectangle().fill(Theme.ink.opacity(0.06))
            if let systemImage {
                Image(systemName: systemImage).foregroundStyle(Theme.ink.opacity(0.3))
            } else {
                ProgressView()
            }
        }
    }
}
