import SwiftUI

struct StatDetailView: View {
    let stat: LifeStat

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var mode: DetailMode = .overview
    @State private var shareImage: UIImage?
    @State private var isSharing = false

    var body: some View {
        let theme = model.profile.selectedTheme
        let palette = theme.palette

        NavigationStack {
            ZStack {
                CosmicBackgroundView(theme: theme, intensity: model.profile.backgroundIntensity, animate: model.effectiveMotion == .full)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header(theme: theme)

                        Picker("Mode", selection: $mode) {
                            ForEach(DetailMode.allCases) { mode in
                                Text(LocalizedStringKey(mode.title)).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        switch mode {
                        case .overview:
                            overview(theme: theme)
                        case .calculation:
                            methodology(theme: theme)
                        case .comparisons:
                            comparisons(theme: theme)
                        case .milestones:
                            milestones(theme: theme)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .padding(.bottom, 44)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.headline.weight(.semibold))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let configuration = ShareRenderConfiguration(
                            template: .heroNumber,
                            ratio: .story,
                            theme: theme,
                            includeMethodology: model.profile.showMethodologyInShare,
                            includeEstimateTag: model.profile.showEstimatedTagsInShare
                        )
                        shareImage = ShareRenderer.image(for: [stat], configuration: configuration)
                        isSharing = shareImage != nil
                        HapticsManager.shared.impact(.soft)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $isSharing) {
                if let shareImage {
                    ActivityView(activityItems: [shareImage])
                }
            }
            .tint(palette.textPrimary)
        }
    }

    @ViewBuilder
    private func header(theme: LunivoTheme) -> some View {
        let palette = theme.palette

        GlassCard(theme: theme, cornerRadius: 36, padding: 24) {
            VStack(alignment: .leading, spacing: 18) {
                Label {
                    Text(LocalizedStringKey(stat.title))
                } icon: {
                    Image(systemName: stat.iconName)
                }
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.textPrimary)

                RollingNumberText(text: stat.formattedValue, unit: stat.unit, theme: theme, emphasis: true)

                Text(LocalizedStringKey(stat.derivationType.title))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08), in: Capsule())

                Text(LocalizedStringKey(stat.shortDescription))
                    .font(.headline.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func overview(theme: LunivoTheme) -> some View {
        let palette = theme.palette
        GlassCard(theme: theme) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Context")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(LocalizedStringKey(stat.wittyComparison))
                    .font(LunivoTypography.editorial(28))
                    .foregroundStyle(palette.textPrimary)

                Divider().overlay(.white.opacity(0.1))

                Text(LocalizedStringKey(stat.methodologySummary))
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func methodology(theme: LunivoTheme) -> some View {
        let palette = theme.palette
        GlassCard(theme: theme) {
            VStack(alignment: .leading, spacing: 18) {
                Text("How it is calculated")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(LocalizedStringKey(stat.methodologySummary))
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
                Text(LocalizedStringKey(stat.derivationType.title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text("These numbers are deterministic and local only. No external services are involved.")
                    .font(.body)
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func comparisons(theme: LunivoTheme) -> some View {
        VStack(spacing: 14) {
            ForEach(stat.alternateRepresentations) { alternate in
                GlassCard(theme: theme, cornerRadius: 28, padding: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey(alternate.title))
                            .font(.caption.weight(.semibold))
                            .tracking(2)
                            .foregroundStyle(theme.palette.textSecondary)
                        Text(alternate.value)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(theme.palette.textPrimary)
                        Text(LocalizedStringKey(alternate.subtitle))
                            .font(.subheadline)
                            .foregroundStyle(theme.palette.textSecondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func milestones(theme: LunivoTheme) -> some View {
        VStack(spacing: 14) {
            ForEach(stat.nextMilestones) { milestone in
                MilestoneRow(milestone: milestone, theme: theme, favorite: model.favoriteMilestoneIDs.contains(milestone.id)) {
                    model.toggleFavoriteMilestone(milestone.id)
                }
            }
        }
    }
    private enum DetailMode: String, CaseIterable, Identifiable {
        case overview
        case calculation
        case comparisons
        case milestones

        var id: String { rawValue }

        var title: String {
            switch self {
            case .overview: "Overview"
            case .calculation: "How"
            case .comparisons: "Comparisons"
            case .milestones: "Milestones"
            }
        }
    }
}
