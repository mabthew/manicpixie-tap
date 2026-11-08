import SwiftUI
import SafariServices

/// In-app Safari for the booking flow, so people finish booking without leaving the clip.
struct SafariSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor(Theme.ink)
        controller.preferredBarTintColor = UIColor(Theme.cream)
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
