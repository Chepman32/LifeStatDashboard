import SwiftUI

struct AgeChipView: View {
    let summary: AgeSummary
    let theme: LunivoTheme
    @Environment(\.locale) private var locale

    var body: some View {
        let palette = theme.palette
        let format = LunivoLocalization.string("%lld years • %lld months • %lld days", locale: locale)
        let ageText = String.localizedStringWithFormat(format, summary.years, summary.months, summary.days)

        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption.weight(.bold))
            Text(ageText)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(palette.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        )
    }
}
