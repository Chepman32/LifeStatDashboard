import SwiftUI
import UIKit

struct ShareComposerView: View {
    @EnvironmentObject private var model: AppModel
    @State private var template: ShareTemplate = .heroNumber
    @State private var ratio: ShareRatio = .story
    @State private var selectedStatID: String?
    @State private var sharedImage: UIImage?
    @State private var isSharing = false

    var body: some View {
        let theme = model.profile.selectedTheme

        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Share Composer")
                        .font(LiftaTypography.display(34, weight: .bold))
                        .foregroundStyle(theme.palette.textPrimary)

                    GlassCard(theme: theme, cornerRadius: 34, padding: 12) {
                        ShareCanvasView(stats: selectedStats, configuration: configuration)
                            .frame(height: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    }

                    controls(theme: theme)

                    Button("Export") {
                        sharedImage = ShareRenderer.image(for: selectedStats, configuration: configuration)
                        isSharing = sharedImage != nil
                        HapticsManager.shared.notify(.success)
                    }
                    .buttonStyle(PrimaryButtonStyle(theme: theme))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .padding(.bottom, 140)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isSharing) {
            if let sharedImage {
                ActivityView(activityItems: [sharedImage])
            }
        }
    }

    private var allStats: [LifeStat] {
        model.snapshot.statsByCategory
            .filter { $0.key != .milestones }
            .values
            .flatMap { $0 }
            .sorted { $0.title < $1.title }
    }

    private var selectedStats: [LifeStat] {
        if template == .multiCard {
            return Array(allStats.prefix(3))
        }
        if let selectedStatID, let stat = allStats.first(where: { $0.id == selectedStatID }) {
            return [stat]
        }
        return [allStats.first ?? fallbackStat]
    }

    private var configuration: ShareRenderConfiguration {
        ShareRenderConfiguration(
            template: template,
            ratio: ratio,
            theme: model.profile.selectedTheme,
            includeMethodology: model.profile.showMethodologyInShare,
            includeEstimateTag: model.profile.showEstimatedTagsInShare
        )
    }

    @ViewBuilder
    private func controls(theme: LiftaTheme) -> some View {
        let palette = theme.palette

        GlassCard(theme: theme, cornerRadius: 30, padding: 18) {
            VStack(alignment: .leading, spacing: 18) {
                Group {
                    Text("Template")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    Picker("Template", selection: $template) {
                        ForEach(ShareTemplate.allCases) { template in
                            Text(template.title).tag(template)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Group {
                    Text("Format")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    Picker("Format", selection: $ratio) {
                        ForEach(ShareRatio.allCases) { ratio in
                            Text(ratio.rawValue.capitalized).tag(ratio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if template != .multiCard {
                    Picker("Stat", selection: Binding(
                        get: { selectedStatID ?? allStats.first?.id },
                        set: { selectedStatID = $0 }
                    )) {
                        ForEach(allStats) { stat in
                            Text(stat.title).tag(Optional(stat.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(palette.textPrimary)
                }

                Toggle("Show methodology label", isOn: Binding(
                    get: { model.profile.showMethodologyInShare },
                    set: { value in
                        model.updateProfile { $0.showMethodologyInShare = value }
                    }
                ))

                Toggle("Show estimated tags", isOn: Binding(
                    get: { model.profile.showEstimatedTagsInShare },
                    set: { value in
                        model.updateProfile { $0.showEstimatedTagsInShare = value }
                    }
                ))
            }
            .toggleStyle(.switch)
            .foregroundStyle(palette.textPrimary)
        }
    }

    private var fallbackStat: LifeStat {
        LifeStat(
            id: "share-fallback",
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

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
