import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject private var model: AppModel
    @State private var editMode: EditMode = .inactive

    var body: some View {
        let theme = model.profile.selectedTheme
        let palette = theme.palette
        let visibleUpcomingMilestones = model.snapshot.allMilestones
            .filter { !model.favoriteMilestoneIDs.contains($0.id) }

        NavigationStack {
            List {
                if let hero = model.snapshot.closestMilestone {
                    Section {
                        GlassCard(theme: theme, cornerRadius: 34, padding: 22) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Closest Upcoming Milestone")
                                    .font(.caption.weight(.bold))
                                    .tracking(2.2)
                                    .foregroundStyle(palette.textSecondary)
                                Text(hero.title)
                                    .font(LiftaTypography.display(30, weight: .bold))
                                    .foregroundStyle(palette.textPrimary)
                                Text(hero.value)
                                    .font(LiftaTypography.hero(44))
                                    .monospacedDigit()
                                    .foregroundStyle(palette.accent)
                                Text(hero.estimatedDate.map { LiftaDateFormatter.medium(date: $0, locale: model.locale) } ?? "Static")
                                    .font(.headline.weight(.medium))
                                    .foregroundStyle(palette.textSecondary)
                                ProgressView(value: hero.progress)
                                    .tint(palette.accent)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                if !model.favoriteMilestones.isEmpty {
                    Section("Favorites") {
                        ForEach(model.favoriteMilestones) { milestone in
                            MilestoneRow(
                                milestone: milestone,
                                theme: theme,
                                favorite: true
                            ) {
                                model.toggleFavoriteMilestone(milestone.id)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onMove(perform: model.moveFavoriteMilestones)
                    }
                }

                Section("All Upcoming") {
                    ForEach(Array(visibleUpcomingMilestones.prefix(18)), id: \.id) { milestone in
                        MilestoneRow(
                            milestone: milestone,
                            theme: theme,
                            favorite: model.favoriteMilestoneIDs.contains(milestone.id)
                        ) {
                            model.toggleFavoriteMilestone(milestone.id)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .environment(\.editMode, $editMode)
            .navigationTitle("Milestones")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editMode == .active ? "Done" : "Reorder") {
                        withAnimation(.smooth) {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }
                }
            }
        }
    }
}

struct MilestoneRow: View {
    let milestone: Milestone
    let theme: LiftaTheme
    let favorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        let palette = theme.palette

        GlassCard(theme: theme, cornerRadius: 28, padding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(milestone.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                        Text(milestone.value)
                            .font(.title2.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(palette.accent)
                    }

                    Spacer()

                    Button(action: onFavorite) {
                        Image(systemName: favorite ? "star.fill" : "star")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(favorite ? palette.accent : palette.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                if let estimatedDate = milestone.estimatedDate {
                    Text(LiftaDateFormatter.medium(date: estimatedDate, locale: Locale.current))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                }

                ProgressView(value: milestone.progress)
                    .tint(palette.accent)

                Text(milestone.description)
                    .font(.footnote)
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }
}
