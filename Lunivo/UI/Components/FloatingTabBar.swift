import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let theme = model.profile.selectedTheme
        let palette = theme.palette

        HStack(spacing: 10) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.spring(duration: 0.6, bounce: 0.22)) {
                        selectedTab = tab
                    }
                    HapticsManager.shared.selectionChanged()
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.localizedTitle(locale: model.locale))
                            .font(.caption2.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(selectedTab == tab ? palette.textPrimary : palette.textSecondary)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(palette.accent.opacity(theme == .light || theme == .solar ? 0.18 : 0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(palette.accentSecondary.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 30, y: 14)
    }
}
