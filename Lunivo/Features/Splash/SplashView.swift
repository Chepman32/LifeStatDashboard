import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void

    @EnvironmentObject private var model: AppModel
    @State private var ringRotation = 0.0
    @State private var logoVisible = false
    @State private var digitsVisible = false
    @State private var land = false

    var body: some View {
        let theme = model.profile.selectedTheme
        let palette = theme.palette

        ZStack {
            CosmicBackgroundView(theme: theme, intensity: 1, animate: true)

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            AngularGradient(colors: [palette.accent, palette.accentSecondary, palette.accent], center: .center),
                            lineWidth: 6
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(ringRotation))

                    Circle()
                        .fill(palette.glow)
                        .frame(width: 80, height: 80)
                        .blur(radius: 24)

                    Text("Lunivo")
                        .font(LunivoTypography.editorial(48, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                        .opacity(logoVisible ? 1 : 0)
                        .blur(radius: logoVisible ? 0 : 16)
                }

                VStack(spacing: 12) {
                    Text(digitsVisible ? "3,184,557,024" : "0")
                        .font(LunivoTypography.hero(46))
                        .monospacedDigit()
                        .foregroundStyle(palette.textPrimary)
                        .contentTransition(.numericText())

                    Text("life keeps moving")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                        .opacity(digitsVisible ? 1 : 0)
                }
                .scaleEffect(land ? 1 : 0.92)
                .opacity(land ? 1 : 0.7)
            }
        }
        .task {
            HapticsManager.shared.prepare()
            withAnimation(.easeOut(duration: 0.5)) {
                logoVisible = true
            }
            HapticsManager.shared.impact(.soft)

            withAnimation(.easeInOut(duration: 1.3).repeatCount(1, autoreverses: false)) {
                ringRotation = 220
            }
            try? await Task.sleep(for: .milliseconds(850))
            withAnimation(.spring(duration: 0.8, bounce: 0.18)) {
                digitsVisible = true
                land = true
            }
            HapticsManager.shared.impact(.medium)
            try? await Task.sleep(for: .milliseconds(950))
            onComplete()
        }
    }
}
