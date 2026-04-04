import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedCategory: StatCategory = .body

    var body: some View {
        let theme = model.profile.selectedTheme

        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                header(theme: theme)
                    .padding(.horizontal, 20)

                if model.profile.liveTickerVisibility != .hidden {
                    LiveTickerRibbon(
                        stats: model.snapshot.tickerStats,
                        theme: theme,
                        autoCycle: model.profile.liveTickerAutoCycle,
                        cycleInterval: model.profile.liveTickerInterval,
                        visibility: model.profile.liveTickerVisibility
                    ) { stat in
                        model.selectedStat = stat
                    }
                    .padding(.horizontal, 20)
                }

                CategoryPicker(selection: $selectedCategory, theme: theme)

                TabView(selection: $selectedCategory) {
                    ForEach(StatCategory.allCases) { category in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(cards(for: category)) { stat in
                                    StatCardView(stat: stat, theme: theme)
                                        .onTapGesture {
                                            model.selectedStat = stat
                                            HapticsManager.shared.impact(.soft)
                                        }
                                        .gesture(
                                            DragGesture(minimumDistance: 18)
                                                .onEnded { value in
                                                    if value.translation.height < -70 {
                                                        model.selectedStat = stat
                                                    }
                                                }
                                        )
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0.82)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 140)
                        }
                        .tag(category)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: 0.65, bounce: 0.18), value: selectedCategory)
                .onChange(of: selectedCategory) { _, _ in
                    HapticsManager.shared.selectionChanged()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if !cards(for: selectedCategory).isEmpty { return }
                selectedCategory = .body
            }
        }
    }

    @ViewBuilder
    private func header(theme: LunivoTheme) -> some View {
        let palette = theme.palette

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Life Dashboard")
                        .font(LunivoTypography.display(34, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    Text(LocalizedStringKey(selectedCategory == .space ? "Still moving through space." : currentSubtitle))
                        .font(.headline.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                        .contentTransition(.opacity)
                }
                Spacer()
            }

            AgeChipView(summary: model.snapshot.ageSummary, theme: theme)
        }
    }

    private var currentSubtitle: String {
        switch selectedCategory {
        case .body: "Your internal systems have been committed for years."
        case .time: "Time looks stranger once it starts counting back."
        case .space: "Still moving through space."
        case .life: "Everyday life has accumulated more than expected."
        case .absurd: "Polished existential accounting."
        case .milestones: "Future thresholds, already approaching."
        }
    }

    private func cards(for category: StatCategory) -> [LifeStat] {
        if category == .milestones {
            return model.snapshot.closestMilestone.map { [$0.asCard(locale: model.locale)] } ?? []
        }
        return model.snapshot.statsByCategory[category] ?? []
    }
}

private struct StatCardView: View {
    let stat: LifeStat
    let theme: LunivoTheme
    @Environment(\.locale) private var locale
    @State private var lifted = false
    @State private var alternateIndex = 0

    var body: some View {
        let palette = theme.palette

        GlassCard(theme: theme, cornerRadius: stat.highlight ? 34 : 30, padding: stat.highlight ? 24 : 20) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(LocalizedStringKey(stat.title), systemImage: stat.iconName)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                        RollingNumberText(
                            text: stat.formattedValue,
                            unit: LunivoLocalization.string(stat.unit, locale: locale),
                            theme: theme,
                            emphasis: stat.highlight
                        )
                    }

                    Spacer(minLength: 16)

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(LocalizedStringKey(stat.derivationType.title))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(palette.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.06), in: Capsule())

                        if stat.estimated {
                            Text("Estimated")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(palette.accent)
                        }
                    }
                }

                statDecoration
                    .frame(height: stat.highlight ? 118 : 84)

                Text(LocalizedStringKey(stat.shortDescription))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.textSecondary)

                Text(LocalizedStringKey(stat.wittyComparison))
                    .font(LunivoTypography.editorial(stat.highlight ? 20 : 18, weight: .medium))
                    .foregroundStyle(palette.textPrimary)

                if !stat.alternateRepresentations.isEmpty {
                    TabView(selection: $alternateIndex) {
                        ForEach(Array(stat.alternateRepresentations.enumerated()), id: \.element.id) { index, alternate in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey(alternate.title))
                                    .font(.caption.weight(.semibold))
                                    .tracking(1.8)
                                    .foregroundStyle(palette.textSecondary)
                                Text(alternate.value)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(palette.textPrimary)
                                Text(LocalizedStringKey(alternate.subtitle))
                                    .font(.caption)
                                    .foregroundStyle(palette.textSecondary)
                            }
                            .tag(index)
                        }
                    }
                    .frame(height: 74)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
            }
        }
        .scaleEffect(lifted ? 1.016 : 1)
        .rotation3DEffect(.degrees(lifted ? 1.2 : 0), axis: (x: 1, y: 0, z: 0))
        .onLongPressGesture(minimumDuration: 0.18, maximumDistance: 32, pressing: { pressing in
            withAnimation(.spring(duration: 0.42, bounce: 0.18)) {
                lifted = pressing
            }
        }, perform: {})
    }

    @ViewBuilder
    private var statDecoration: some View {
        let palette = theme.palette
        switch stat.visualStyle {
        case .pulse:
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(palette.accent.opacity(0.12))
                HStack(spacing: 8) {
                    ForEach(0..<12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 999)
                            .fill(index.isMultiple(of: 3) ? palette.accent : palette.accentSecondary.opacity(0.6))
                            .frame(width: 10, height: CGFloat(28 + (index % 4) * 12))
                    }
                }
                .padding(.horizontal, 16)
            }
        case .orbit:
            ZStack {
                Circle()
                    .stroke(palette.cardStroke.opacity(0.55), lineWidth: 1.5)
                Circle()
                    .trim(from: 0, to: min(max(stat.rawValue.truncatingRemainder(dividingBy: 100) / 100, 0.15), 0.95))
                    .stroke(palette.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(palette.accentSecondary)
                    .frame(width: 14, height: 14)
                    .offset(x: 40, y: -28)
            }
            .padding(.horizontal, 54)
        case .lunar:
            HStack(spacing: 10) {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(index % 2 == 0 ? palette.textPrimary.opacity(0.95) : palette.cardStroke.opacity(0.5))
                        .overlay(
                            Circle()
                                .fill(palette.background.last?.opacity(0.7) ?? .black.opacity(0.2))
                                .frame(width: 18 + CGFloat(index * 2), height: 44)
                                .offset(x: CGFloat(index % 3) * 5 - 4)
                                .clipShape(Circle())
                        )
                }
            }
        case .horizon:
            VStack(spacing: 18) {
                Capsule()
                    .fill(
                        LinearGradient(colors: [palette.accent.opacity(0.2), palette.accentSecondary.opacity(0.18)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(height: 28)
                Capsule()
                    .fill(palette.cardStroke.opacity(0.3))
                    .frame(height: 10)
                    .padding(.horizontal, 18)
            }
        case .stacked:
            HStack(spacing: 8) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(index < 6 ? palette.accent.opacity(0.8) : palette.cardStroke.opacity(0.3))
                        .frame(height: 24 + CGFloat(index % 4) * 10)
                }
            }
        case .editorial:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [palette.accent.opacity(0.22), palette.accentSecondary.opacity(0.12), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .bottomLeading) {
                    Text(stat.compactValue)
                        .font(LunivoTypography.editorial(38, weight: .bold))
                        .foregroundStyle(palette.textPrimary.opacity(0.1))
                        .padding()
                }
        }
    }
}

private extension Milestone {
    func asCard(locale: Locale) -> LifeStat {
        LifeStat(
            id: id,
            category: .milestones,
            title: title,
            iconName: "sparkles",
            rawValue: targetValue,
            formattedValue: value,
            compactValue: value,
            unit: "milestone",
            precisionStyle: .count,
            derivationType: .lifestyleEstimate,
            shortDescription: description,
            wittyComparison: estimatedDate.map { "Estimated for \(LunivoDateFormatter.medium(date: $0, locale: locale))." } ?? "Already reached.",
            methodologySummary: "Projected using the source stat's current rate.",
            alternateRepresentations: [
                LifeStatAlternate(title: "Progress", value: LunivoNumberFormatter.exact(progress * 100, locale: locale, fractionDigits: 1) + "%", subtitle: "Current completion"),
                LifeStatAlternate(title: "Date", value: estimatedDate.map { LunivoDateFormatter.medium(date: $0, locale: locale) } ?? "Static", subtitle: "Projected milestone date")
            ],
            nextMilestones: [self],
            deltaPerSecond: 0,
            visualStyle: .editorial,
            highlight: true,
            estimated: true
        )
    }
}
