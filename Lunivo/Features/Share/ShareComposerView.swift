import SwiftUI
import UIKit

struct ShareComposerView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.locale) private var locale
    @State private var template: ShareTemplate = .heroNumber
    @State private var ratio: ShareRatio = .story
    @State private var exportKind: ShareExportKind = .image
    @State private var selectedStatID: String?
    @State private var sharedItems: [Any] = []
    @State private var isSharing = false
    @State private var isExporting = false

    var body: some View {
        let theme = model.profile.selectedTheme

        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Share Composer")
                        .font(LunivoTypography.display(34, weight: .bold))
                        .foregroundStyle(theme.palette.textPrimary)

                    GlassCard(theme: theme, cornerRadius: 34, padding: 12) {
                        ShareCanvasView(stats: selectedStats, configuration: configuration)
                            .aspectRatio(ratio.size.width / ratio.size.height, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    }
                    .animation(.easeInOut(duration: 0.25), value: ratio)

                    controls(theme: theme)

                    Button(isExporting ? LunivoLocalization.string("Preparing video…", locale: locale) : exportButtonTitle) {
                        Task {
                            await exportContent()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(theme: theme))
                    .disabled(isExporting)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .padding(.bottom, 140)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isSharing) {
            if !sharedItems.isEmpty {
                ActivityView(activityItems: sharedItems)
            } else {
                EmptyView()
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
            return Array(orderedStats.prefix(3))
        }
        return [selectedStat]
    }

    private var slideshowStats: [LifeStat] {
        orderedStats
    }

    private var selectedStat: LifeStat {
        if let selectedStatID, let stat = allStats.first(where: { $0.id == selectedStatID }) {
            return stat
        }
        return allStats.first ?? fallbackStat
    }

    private var orderedStats: [LifeStat] {
        guard !allStats.isEmpty else { return [fallbackStat] }
        guard let selectedIndex = allStats.firstIndex(where: { $0.id == selectedStat.id }) else {
            return allStats
        }

        return Array(allStats[selectedIndex...]) + Array(allStats[..<selectedIndex])
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
    private func templateGrid(palette: ThemePalette) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(ShareTemplate.allCases) { t in
                Button { template = t } label: {
                    Text(t.localizedTitle(locale: locale))
                        .font(.system(size: 13, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(template == t ? palette.textSecondary.opacity(0.25) : Color.clear)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .foregroundStyle(palette.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func controls(theme: LunivoTheme) -> some View {
        let palette = theme.palette

        GlassCard(theme: theme, cornerRadius: 30, padding: 18) {
            VStack(alignment: .leading, spacing: 18) {
                Group {
                    Text(LunivoLocalization.string("Export Type", locale: locale))
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    Picker(LunivoLocalization.string("Export Type", locale: locale), selection: $exportKind) {
                        ForEach(ShareExportKind.allCases) { kind in
                            Text(kind.localizedTitle(locale: locale)).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Group {
                    Text("Template")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    templateGrid(palette: palette)
                }

                Group {
                    Text("Format")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    Picker("Format", selection: $ratio) {
                        ForEach(ShareRatio.allCases) { ratio in
                            Text(ratio.localizedTitle(locale: locale)).tag(ratio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Group {
                    Text(LunivoLocalization.string("Metric", locale: locale))
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(palette.textSecondary)
                    Picker(LunivoLocalization.string("Metric", locale: locale), selection: Binding(
                        get: { selectedStat.id },
                        set: { selectedStatID = $0 }
                    )) {
                        ForEach(allStats) { stat in
                            Text(stat.title).tag(stat.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(palette.textPrimary)
                }

                if exportKind == .slideshowVideo {
                    Text(LunivoLocalization.string("Video exports a slideshow of all metrics, starting from the selected one.", locale: locale))
                        .font(.footnote)
                        .foregroundStyle(palette.textSecondary)
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

    private var exportButtonTitle: String {
        switch exportKind {
        case .image:
            LunivoLocalization.string("Export Image", locale: locale)
        case .slideshowVideo:
            LunivoLocalization.string("Export Video", locale: locale)
        }
    }

    @MainActor
    private func exportContent() async {
        isExporting = true
        defer { isExporting = false }

        switch exportKind {
        case .image:
            guard let image = ShareRenderer.image(for: selectedStats, configuration: configuration) else {
                HapticsManager.shared.notify(.error)
                return
            }
            sharedItems = [image]
        case .slideshowVideo:
            guard let videoURL = await ShareRenderer.slideshowVideo(for: slideshowStats, configuration: configuration) else {
                HapticsManager.shared.notify(.error)
                return
            }
            sharedItems = [videoURL]
        }

        isSharing = true
        HapticsManager.shared.notify(.success)
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
