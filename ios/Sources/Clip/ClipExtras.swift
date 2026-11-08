#if APPCLIP
import SwiftUI
import StoreKit

/// Offers the full app with Apple's App Store overlay, once, at a natural pause.
struct FullAppPromo: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.appStoreOverlay(isPresented: $isPresented) {
            SKOverlay.AppClipConfiguration(position: .bottom)
        }
    }
}

/// Favourites live in the full app only; the clip shows nothing here.
struct FavouriteButton: View {
    let pieceID: String
    var body: some View { EmptyView() }
}
#endif
