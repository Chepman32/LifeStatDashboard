import SwiftUI

struct ShareCanvasView: View {
    let stats: [LifeStat]
    let configuration: ShareRenderConfiguration
    @Environment(\.locale) private var locale

    var body: some View {
        let palette = configuration.theme.palette
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
                    orbitPoster(stat: stats.first ?? placeholderStat)
                case .minimalMono:
                    minimalCard(stat: stats.first ?? placeholderStat)
                }

                Spacer()

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
            .padding(56)
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
                Text(stat.compactValue)
                    .font(LunivoTypography.hero(110))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
                    .minimumScaleFactor(0.5)
                Text(LunivoLocalization.string(stat.unit, locale: locale))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(LocalizedStringKey(stat.wittyComparison))
                    .font(LunivoTypography.editorial(28))
                    .foregroundStyle(palette.textPrimary)
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
                Text(stat.compactValue + " " + LunivoLocalization.string(stat.unit, locale: locale))
                    .font(LunivoTypography.hero(72))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
                Text(LocalizedStringKey(stat.wittyComparison))
                    .font(LunivoTypography.editorial(36, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                    .multilineTextAlignment(.leading)
                if let alternate = stat.alternateRepresentations.first {
                    Text("\(LunivoLocalization.string(alternate.title, locale: locale)): \(alternate.value)")
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
                            Text(LocalizedStringKey(stat.title))
                                .font(.headline.weight(.semibold))
                            Text("\(stat.compactValue) \(LunivoLocalization.string(stat.unit, locale: locale))")
                                .font(LunivoTypography.hero(36))
                                .monospacedDigit()
                        }
                        Spacer()
                        Image(systemName: stat.iconName)
                            .font(.title2)
                    }
                }
            }
        }
    }

    private func orbitPoster(stat: LifeStat) -> some View {
        let palette = configuration.theme.palette
        return VStack(spacing: 28) {
            ZStack {
                Circle()
                    .stroke(palette.cardStroke.opacity(0.45), lineWidth: 2)
                    .frame(width: 520, height: 520)
                Circle()
                    .stroke(palette.accent.opacity(0.34), lineWidth: 10)
                    .frame(width: 420, height: 420)
                Circle()
                    .fill(palette.accent)
                    .frame(width: 24, height: 24)
                    .offset(x: 210, y: 0)
                VStack(spacing: 10) {
                    Text(stat.compactValue)
                        .font(LunivoTypography.hero(82))
                        .monospacedDigit()
                    Text(LocalizedStringKey(stat.title))
                        .font(LunivoTypography.editorial(28, weight: .bold))
                        .multilineTextAlignment(.center)
                }
            }
            Text(LocalizedStringKey(stat.wittyComparison))
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
        }
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
                    Text(stat.compactValue)
                        .font(LunivoTypography.hero(96))
                        .monospacedDigit()
                        .foregroundStyle(palette.textPrimary)
                    Text(LunivoLocalization.string(stat.unit, locale: locale))
                        .font(.title3.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                }
                .padding(42)
            }
            .frame(maxWidth: .infinity, minHeight: 560)
    }

    private func methodologyTag(for stat: LifeStat) -> some View {
        Text(LocalizedStringKey(stat.derivationType.title))
            .font(.caption.weight(.bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.white.opacity(0.09), in: Capsule())
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
