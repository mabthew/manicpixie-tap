import SwiftUI

struct HomeView: View {
    @Environment(ContentLoader.self) private var loader
    @Environment(InvocationState.self) private var invocation
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedPiece: Piece?
    @State private var showChooser = false
    @State private var showBooking = false
    @State private var activeTag: String?
    @State private var leftForLink = false
    @State private var showPromo = false
    @State private var promoShown = false

    private var site: SiteContent { loader.content }
    private var upcoming: [LiveEvent] { site.upcomingLives() }

    private var isClip: Bool {
        #if APPCLIP
        return true
        #else
        return false
        #endif
    }

    private var allTags: [String] {
        Array(Set(site.drop?.pieces.flatMap(\.tags) ?? [])).sorted()
    }

    /// The full app can only be offered once it is on the App Store (Config.appStoreID is set then).
    private var canPromoteApp: Bool { isClip && !Config.appStoreID.isEmpty }

    private var getAppAction: (() -> Void)? {
        canPromoteApp ? { showPromo = true } : nil
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 28) {
                        BrandHeaderView(brand: site.brand)
                        if let live = upcoming.first {
                            LiveCountdownView(event: live)
                                .id(InvocationState.Section.live)
                        }
                        UpcomingLivesStrip(lives: Array(upcoming.dropFirst().prefix(8)))
                        if let booking = site.booking {
                            BookingCard(booking: booking) { showChooser = true }
                                .id(InvocationState.Section.book)
                        }
                        #if !APPCLIP
                        if let pieces = site.drop?.pieces {
                            SavedStrip(pieces: pieces) { selectedPiece = $0 }
                        }
                        #endif
                        if let drop = site.drop {
                            DropGalleryView(drop: drop, activeTag: $activeTag) { selectedPiece = $0 }
                                .id(InvocationState.Section.drop)
                        }
                        LinkButtonsView(links: site.links) { leftForLink = true }
                            .id(InvocationState.Section.links)
                        FooterView(source: loader.source, onGetApp: getAppAction)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)
                .onChange(of: invocation.scrollTarget, initial: true) { _, target in
                    guard let target else { return }
                    withAnimation { proxy.scrollTo(target, anchor: .top) }
                }
            }
            .background(Theme.cream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedPiece) { piece in
                PieceDetailView(pieces: site.drop?.pieces ?? [piece], selected: piece)
            }
            .sheet(isPresented: $showChooser) {
                if let booking = site.booking {
                    BookingChooserView(booking: booking, tags: allTags,
                                       onFilter: { activeTag = $0 },
                                       onBook: { showChooser = false; showBooking = true })
                        .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: $showBooking) {
                if let booking = site.booking {
                    SafariSheet(url: booking.url).ignoresSafeArea()
                }
            }
            .refreshable { await loader.refresh() }
        }
        .tint(Theme.ink)
        .modifier(FullAppPromo(isPresented: $showPromo))
        .onChange(of: scenePhase) { _, phase in
            // Back from Depop / Instagram: a natural pause, so offer the full app once.
            if phase == .active, leftForLink {
                leftForLink = false
                offerFullApp()
            }
        }
        .onChange(of: selectedPiece) { old, new in
            if old != nil, new == nil { offerFullApp() }
        }
    }

    private func offerFullApp() {
        guard canPromoteApp, !promoShown else { return }
        promoShown = true
        showPromo = true
    }
}
