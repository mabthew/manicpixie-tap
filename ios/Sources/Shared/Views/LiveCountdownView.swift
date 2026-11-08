import SwiftUI

struct LiveCountdownView: View {
    let event: LiveEvent

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let state = LiveState.from(now: context.date, event: event)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text(state == .live ? "Live now" : "Next live")
                        .textCase(.uppercase)
                        .tracking(1.2)
                }
                .font(.caption.weight(.bold))
                .opacity(0.85)

                Text(event.title)
                    .font(Theme.serif(.title2))

                switch state {
                case .upcoming(let seconds):
                    Text(Self.countdown(seconds))
                        .font(.system(.title, design: .rounded).weight(.bold).monospacedDigit())
                    Text(event.startsAt, format: .dateTime.weekday(.wide).month(.abbreviated).day().hour().minute())
                        .font(.footnote)
                        .opacity(0.8)
                case .live:
                    Link(destination: event.url) {
                        Label("Join on \(event.platform.capitalized)", systemImage: "play.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.cream)
                    .foregroundStyle(Theme.ink)
                case .ended:
                    Text("That one's wrapped. Follow on \(event.platform.capitalized) for the next one.")
                        .font(.footnote)
                case .none:
                    EmptyView()
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.ink))
            .foregroundStyle(Theme.cream)
        }
    }

    static func countdown(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded(.down))
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        if days > 0 { return "\(days)d \(hours)h \(minutes)m" }
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
