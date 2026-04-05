import SwiftUI

struct ShareCanvasView: View {
    let stats: [LifeStat]
    let configuration: ShareRenderConfiguration
    @Environment(\.locale) private var locale

    var body: some View {
        GeometryReader { proxy in
            let palette = configuration.theme.palette
            let canvasSize = proxy.size

            ZStack {
                CosmicBackgroundView(theme: configuration.theme, intensity: 0.95, animate: false)

                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lunivo")
                                .font(LunivoTypography.editorial(34, weight: .bold))
                                .foregroundStyle(palette.textPrimary)
                            Text("Your life, translated into impossible numbers.")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                        Spacer()
                    }

                    switch configuration.template {
                    case .heroNumber:
                        heroCard(stat: stats.first ?? placeholderStat)
                    case .cosmicComparison:
                        comparisonCard(stat: stats.first ?? placeholderStat)
                    case .multiCard:
                        multiCard(stats: Array(stats.prefix(3)))
                    case .orbitPoster:
                        orbitPoster(stat: stats.first ?? placeholderStat, canvasSize: canvasSize)
                    case .minimalMono:
                        minimalCard(stat: stats.first ?? placeholderStat)
                    }

                    Spacer(minLength: 0)

                    HStack {
                        Text("Offline. Local. Deterministic.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(palette.textSecondary)
                        Spacer()
                        Text("lifta")
                            .font(LunivoTypography.editorial(18, weight: .bold))
                            .foregroundStyle(palette.textPrimary.opacity(0.8))
                    }
                }
                .padding(contentPadding(for: canvasSize))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .clipped()
        }
    }

    private func heroCard(stat: LifeStat) -> some View {
        let palette = configuration.theme.palette
        return GlassCard(theme: configuration.theme, cornerRadius: 40, padding: 36) {
            VStack(alignment: .leading, spacing: 18) {
                Text(LunivoLocalization.string(stat.title, locale: locale).uppercased(with: locale))
                    .font(.caption.weight(.bold))
                    .tracking(2.6)
                    .foregroundStyle(palette.textSecondary)
                Text(displayValue(for: stat))
                    .font(LunivoTypography.hero(110))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                Text(stat.unit)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(shareSummary(for: stat))
                    .font(LunivoTypography.editorial(24))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                if configuration.includeMethodology {
                    methodologyTag(for: stat)
                }
            }
        }
    }

    private func comparisonCard(stat: LifeStat) -> some View {
        let palette = configuration.theme.palette
        return GlassCard(theme: configuration.theme, cornerRadius: 42, padding: 36) {
            VStack(alignment: .leading, spacing: 24) {
                Text(displayValue(for: stat) + " " + stat.unit)
                    .font(LunivoTypography.hero(72))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.55)
                Text(stat.wittyComparison)
                    .font(LunivoTypography.editorial(36, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                if let alternate = stat.alternateRepresentations.first {
                    Text("\(alternate.title): \(alternate.value)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(palette.textSecondary)
                }
                if configuration.includeEstimateTag && stat.estimated {
                    Text("Estimated")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(palette.accent.opacity(0.16), in: Capsule())
                }
            }
        }
    }

    private func multiCard(stats: [LifeStat]) -> some View {
        VStack(spacing: 18) {
            ForEach(stats, id: \.id) { stat in
                GlassCard(theme: configuration.theme, cornerRadius: 34, padding: 26) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(stat.title)
                                .font(.headline.weight(.semibold))
                            Text("\(displayValue(for: stat)) \(stat.unit)")
                                .font(LunivoTypography.hero(36))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        Spacer()
                        Image(systemName: stat.iconName)
                            .font(.title2)
                    }
                }
            }
        }
    }

    private func orbitPoster(stat: LifeStat, canvasSize: CGSize) -> some View {
        let palette = configuration.theme.palette
        let outerDiameter = min(520, canvasSize.width * 0.82, canvasSize.height * 0.5)
        let innerDiameter = outerDiameter * 0.81
        let markerSize = min(24, max(14, outerDiameter * 0.046))
        let orbitOffset = innerDiameter / 2
        let valueFontSize = min(82, max(46, outerDiameter * 0.158))
        let titleFontSize = min(28, max(22, outerDiameter * 0.054))

        return VStack(spacing: 28) {
            ZStack {
                Circle()
                    .stroke(palette.cardStroke.opacity(0.45), lineWidth: 2)
                    .frame(width: outerDiameter, height: outerDiameter)
                Circle()
                    .stroke(palette.accent.opacity(0.34), lineWidth: 10)
                    .frame(width: innerDiameter, height: innerDiameter)
                Circle()
                    .fill(palette.accent)
                    .frame(width: markerSize, height: markerSize)
                    .offset(x: orbitOffset, y: 0)
                VStack(spacing: 10) {
                    Text(displayValue(for: stat))
                        .font(LunivoTypography.hero(valueFontSize))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(stat.title)
                        .font(LunivoTypography.editorial(titleFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)
                }
            }
            Text(stat.wittyComparison)
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func contentPadding(for size: CGSize) -> CGFloat {
        min(56, max(20, size.width * 0.05))
    }

    private func minimalCard(stat: LifeStat) -> some View {
        let palette = LunivoTheme.mono.palette
        return RoundedRectangle(cornerRadius: 46, style: .continuous)
            .fill(Color.black.opacity(0.72))
            .overlay(
                RoundedRectangle(cornerRadius: 46, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            .overlay {
                VStack(alignment: .leading, spacing: 18) {
                    Text(LunivoLocalization.string(stat.title, locale: locale).uppercased(with: locale))
                        .font(.caption.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(palette.textSecondary)
                    Text(displayValue(for: stat))
                        .font(LunivoTypography.hero(96))
                        .monospacedDigit()
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(stat.unit)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                }
                .padding(42)
            }
            .frame(maxWidth: .infinity, minHeight: 560)
    }

    private func methodologyTag(for stat: LifeStat) -> some View {
        Text(stat.derivationType.shortLocalizedTitle(locale: locale))
            .font(.caption.weight(.bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.white.opacity(0.09), in: Capsule())
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func displayValue(for stat: LifeStat) -> String {
        LunivoNumberFormatter.shareCompact(stat.rawValue, locale: locale)
    }

    private func shareSummary(for stat: LifeStat) -> String {
        stat.wittyComparison.isEmpty ? stat.shortDescription : stat.wittyComparison
    }

    private var placeholderStat: LifeStat {
        LifeStat(
            id: "placeholder",
            category: .time,
            title: "Seconds Lived",
            iconName: "timer",
            rawValue: 0,
            formattedValue: "0",
            compactValue: "0",
            unit: "seconds",
            precisionStyle: .seconds,
            derivationType: .exactFromTime,
            shortDescription: "",
            wittyComparison: "",
            methodologySummary: "",
            alternateRepresentations: [],
            nextMilestones: [],
            deltaPerSecond: 0,
            visualStyle: .editorial,
            highlight: false,
            estimated: false
        )
    }
}
