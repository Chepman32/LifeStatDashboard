import SwiftUI

struct AgeChipView: View {
    let summary: AgeSummary
    let theme: LunivoTheme

    var body: some View {
        let palette = theme.palette

        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption.weight(.bold))
            Text("\(summary.years) years • \(summary.months) months • \(summary.days) days")
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
