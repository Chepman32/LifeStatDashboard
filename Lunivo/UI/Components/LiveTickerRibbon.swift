import SwiftUI

struct LiveTickerRibbon: View {
    let stats: [LifeStat]
    let theme: LunivoTheme
    let autoCycle: Bool
    let cycleInterval: Double
    let visibility: LiveTickerVisibility
    var onTap: ((LifeStat) -> Void)? = nil
    @Environment(\.locale) private var locale

    @State private var currentIndex = 0

    var body: some View {
        if visibility != .hidden, let stat = currentStat {
            let palette = theme.palette

            GlassCard(theme: theme, cornerRadius: 24, padding: visibility == .compact ? 14 : 18) {
                HStack(spacing: 14) {
                    Image(systemName: stat.iconName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(palette.accent)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey(stat.title))
                            .font(.caption.weight(.semibold))
                            .tracking(1.8)
                            .foregroundStyle(palette.textSecondary)
                        Text("\(stat.formattedValue) \(LunivoLocalization.string(stat.unit, locale: locale))")
                            .font(visibility == .compact ? .subheadline.weight(.semibold) : .headline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(palette.textPrimary)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    Image(systemName: "arrow.left.and.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(palette.textSecondary)
                }
            }
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    LinearGradient(colors: [.clear, .white.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: proxy.size.width * 0.32)
                        .offset(x: shimmerOffset(width: proxy.size.width))
                        .blur(radius: 6)
                }
                .allowsHitTesting(false)
            }
            .onTapGesture {
                onTap?(stat)
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.width < -40 {
                            step(1)
                        } else if value.translation.width > 40 {
                            step(-1)
                        }
                    }
            )
            .task(id: autoCycle) {
                guard autoCycle, stats.count > 1 else { return }
                while autoCycle {
                    try? await Task.sleep(for: .seconds(cycleInterval))
                    await MainActor.run { step(1) }
                }
            }
        }
    }

    private var currentStat: LifeStat? {
        guard !stats.isEmpty else { return nil }
        return stats[currentIndex % stats.count]
    }

    private func step(_ delta: Int) {
        guard !stats.isEmpty else { return }
        withAnimation(.spring(duration: 0.55, bounce: 0.18)) {
            currentIndex = (currentIndex + delta + stats.count) % stats.count
        }
        HapticsManager.shared.selectionChanged()
    }

    private func shimmerOffset(width: CGFloat) -> CGFloat {
        let phase = Date().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3) / 3
        return width * (phase - 0.15)
    }
}
