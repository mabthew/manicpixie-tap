import SwiftUI

struct BrandHeaderView: View {
    let brand: Brand

    var body: some View {
        VStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.ink.opacity(0.08), lineWidth: 1))
            Text(brand.name)
                .font(Theme.serif(.largeTitle))
            Text(brand.tagline)
                .font(.callout)
                .opacity(0.7)
        }
        .foregroundStyle(Theme.ink)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}
