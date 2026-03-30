import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: StatCategory
    let theme: LunivoTheme
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let palette = theme.palette

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(StatCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(duration: 0.55, bounce: 0.22)) {
                            selection = category
                        }
                        HapticsManager.shared.selectionChanged()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.caption.weight(.bold))
                            Text(category.localizedTitle(locale: model.locale))
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(selection == category ? palette.textPrimary : palette.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selection == category ? palette.accent.opacity(0.18) : .white.opacity(0.06))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(selection == category ? palette.accent.opacity(0.32) : .white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
