import SwiftUI

/// The storefront and social links. Opens the installed app or Safari via https universal links.
struct LinkButtonsView: View {
    let links: [LinkItem]
    let onFollow: () -> Void

    @Environment(\.openURL) private var openURL
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find us").font(Theme.serif(.title3))
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(links) { link in
                    Button {
                        onFollow()
                        openURL(link.url)
                    } label: {
                        Label(link.title, systemImage: link.systemImage)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.ink.opacity(0.06)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .foregroundStyle(Theme.ink)
    }
}

struct FooterView: View {
    let source: ContentLoader.Source
    let onGetApp: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            if let onGetApp {
                Button("Get the Manic Pixie Thrift app", action: onGetApp)
                    .font(.footnote.weight(.semibold))
            }
            Link("Privacy", destination: Config.privacyURL)
                .font(.footnote)
            Text("Denver, CO · made with <3")
                .font(.caption2)
                .opacity(0.5)
            #if DEBUG
            Text("content: \(source.rawValue)")
                .font(.caption2)
                .opacity(0.4)
            #endif
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .foregroundStyle(Theme.ink)
    }
}
