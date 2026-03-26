import SwiftUI

struct RollingNumberText: View {
    let text: String
    let unit: String
    let theme: LiftaTheme
    var emphasis: Bool = false

    var body: some View {
        let palette = theme.palette

        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(LiftaTypography.hero(emphasis ? 42 : 34))
                .monospacedDigit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [palette.textPrimary, palette.accent.opacity(0.95)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())
                .animation(.smooth(duration: 0.4), value: text)

            Text(unit.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(2.2)
                .foregroundStyle(palette.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}
