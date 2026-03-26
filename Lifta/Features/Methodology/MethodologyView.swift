import SwiftUI

struct MethodologyView: View {
    @EnvironmentObject private var model: AppModel
    @State private var searchText = ""

    var body: some View {
        let theme = model.profile.selectedTheme

        List(filteredSections) { section in
            DisclosureGroup {
                ForEach(section.rows) { row in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(row.title)
                            .font(.headline.weight(.semibold))
                        Text(row.formula)
                            .font(.subheadline.monospaced())
                            .foregroundStyle(theme.palette.accent)
                        Text(row.derivationType.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.palette.textSecondary)
                        Text(row.note)
                            .font(.footnote)
                            .foregroundStyle(theme.palette.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.title)
                        .font(.headline.weight(.semibold))
                    Text(section.summary)
                        .font(.footnote)
                        .foregroundStyle(theme.palette.textSecondary)
                }
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle("Methodology")
        .searchable(text: $searchText, prompt: "Search a stat or formula")
    }

    private var filteredSections: [MethodologySection] {
        guard !searchText.isEmpty else { return model.snapshot.methodologySections }
        return model.snapshot.methodologySections.compactMap { section in
            let rows = section.rows.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.formula.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
            guard !rows.isEmpty else { return nil }
            return MethodologySection(title: section.title, summary: section.summary, rows: rows)
        }
    }
}
