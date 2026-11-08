import SwiftUI

struct BookingCard: View {
    let booking: Booking
    let onBook: () -> Void

    var body: some View {
        Button(action: onBook) {
            HStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.title).font(.headline)
                    Text(booking.blurb).font(.footnote).opacity(0.75)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold))
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.lavender.opacity(0.45)))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.ink)
    }
}

/// A short native step before Calendly: what the appointment is for. Filters the gallery too.
struct BookingChooserView: View {
    let booking: Booking
    let tags: [String]
    let onFilter: (String?) -> Void
    let onBook: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var occasion = "Everyday"
    @State private var size = "Any"
    @State private var vibe: String?

    static let occasions = ["Everyday", "An event", "Work", "Just browsing"]
    static let sizes = ["Any", "XS", "S", "M", "L", "XL", "XXL"]

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you after?") {
                    Picker("Occasion", selection: $occasion) {
                        ForEach(Self.occasions, id: \.self) { Text($0) }
                    }
                    Picker("Size", selection: $size) {
                        ForEach(Self.sizes, id: \.self) { Text($0) }
                    }
                }
                if !tags.isEmpty {
                    Section("Vibe") {
                        ForEach(tags, id: \.self) { tag in
                            Button {
                                vibe = (vibe == tag) ? nil : tag
                            } label: {
                                HStack {
                                    Text(tag.capitalized)
                                    Spacer()
                                    if vibe == tag { Image(systemName: "checkmark") }
                                }
                            }
                            .foregroundStyle(Theme.ink)
                        }
                    }
                }
                Section {
                    Button {
                        onFilter(vibe)
                        onBook()
                    } label: {
                        Label("Book a \(booking.title.lowercased())", systemImage: "calendar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.ink)
                } footer: {
                    Text("We'll talk through \(occasion.lowercased()) looks\(size == "Any" ? "" : " in size \(size)") at your appointment.")
                }
            }
            .navigationTitle("Styling")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
