import SwiftUI

@main
struct TapApp: App {
    @State private var loader = ContentLoader()
    @State private var invocation = InvocationState()
    #if !APPCLIP
    @State private var favourites = FavouritesStore()
    #endif

    init() {
        // Shared cache sized for gallery images; AsyncImage goes through it.
        URLCache.shared = URLCache(memoryCapacity: 20_000_000, diskCapacity: 100_000_000)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(loader)
                .environment(invocation)
                #if !APPCLIP
                .environment(favourites)
                #endif
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    invocation.handle(activity.webpageURL)
                }
                .onOpenURL { url in
                    invocation.handle(url)
                }
                .task { await loader.refresh() }
        }
    }
}
