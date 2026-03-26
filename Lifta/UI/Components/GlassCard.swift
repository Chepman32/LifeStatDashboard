import SwiftUI

struct GlassCard<Content: View>: View {
    let theme: LiftaTheme
    var cornerRadius: CGFloat = 30
    var padding: CGFloat = 22
    @ViewBuilder var content: Content

    var body: some View {
        let palette = theme.palette

        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(palette.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(palette.cardStroke, lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.22),
                                        .white.opacity(0.02),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)
                    }
                    .shadow(color: palette.glow.opacity(0.45), radius: 32, y: 20)
                    .shadow(color: .black.opacity(theme == .light || theme == .solar ? 0.08 : 0.24), radius: 24, y: 16)
            )
    }
}
