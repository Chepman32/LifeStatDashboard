import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let palette = model.profile.selectedTheme.palette
        let locale = model.locale

        NavigationStack {
            Form {
                profileSection(palette: palette, locale: locale)
                appearanceSection(palette: palette, locale: locale)
                motionSection(palette: palette, locale: locale)
                tickerSection(palette: palette, locale: locale)
                localizationSection(palette: palette, locale: locale)
                methodologySection(palette: palette, locale: locale)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .foregroundStyle(palette.textPrimary)
            .navigationTitle(LunivoLocalization.string("Settings", locale: locale))
            .tint(palette.accent)
        }
    }

    private func rowBG(_ palette: ThemePalette) -> some View {
        palette.listRowBackground.ignoresSafeArea()
    }

    private func profileSection(palette: ThemePalette, locale: Locale) -> some View {
        Section(LunivoLocalization.string("Profile Input", locale: locale)) {
            DatePicker(
                LunivoLocalization.string("Birth Date", locale: locale),
                selection: Binding(
                    get: { model.profile.birthDate },
                    set: { v in model.updateProfile { $0.birthDate = v } }
                ),
                in: ...Date(),
                displayedComponents: model.profile.hasBirthTime ? [.date, .hourAndMinute] : [.date]
            )
            .listRowBackground(rowBG(palette))

            Toggle(LunivoLocalization.string("Include birth time", locale: locale), isOn: Binding(
                get: { model.profile.hasBirthTime },
                set: { v in model.updateProfile { $0.hasBirthTime = v } }
            ))
            .listRowBackground(rowBG(palette))

            Picker(LunivoLocalization.string("Units", locale: locale), selection: Binding(
                get: { model.profile.unitPreference },
                set: { v in model.updateProfile { $0.unitPreference = v } }
            )) {
                ForEach(UnitPreference.allCases) { preference in
                    Text(preference.localizedTitle(locale: locale)).tag(preference)
                }
            }
            .listRowBackground(rowBG(palette))

            Button(LunivoLocalization.string("Reset All", locale: locale), role: .destructive) { model.resetAll() }
                .listRowBackground(rowBG(palette))
        }
    }

    private func appearanceSection(palette: ThemePalette, locale: Locale) -> some View {
        Section(LunivoLocalization.string("Appearance", locale: locale)) {
            Picker(LunivoLocalization.string("Theme", locale: locale), selection: Binding(
                get: { model.profile.selectedTheme },
                set: { v in model.updateProfile { $0.selectedTheme = v } }
            )) {
                ForEach(LunivoTheme.allCases) { theme in
                    Text(theme.localizedTitle(locale: locale)).tag(theme)
                }
            }
            .listRowBackground(rowBG(palette))

            Picker(LunivoLocalization.string("Display Density", locale: locale), selection: Binding(
                get: { model.profile.displayDensity },
                set: { v in model.updateProfile { $0.displayDensity = v } }
            )) {
                ForEach(DisplayDensity.allCases) { density in
                    Text(density.localizedTitle(locale: locale)).tag(density)
                }
            }
            .listRowBackground(rowBG(palette))

            Toggle(LunivoLocalization.string("Large text mode", locale: locale), isOn: Binding(
                get: { model.profile.largeTextMode },
                set: { v in model.updateProfile { $0.largeTextMode = v } }
            ))
            .listRowBackground(rowBG(palette))

            VStack(alignment: .leading) {
                Text(LunivoLocalization.string("Background intensity", locale: locale))
                Slider(value: Binding(
                    get: { model.profile.backgroundIntensity },
                    set: { v in model.updateProfile { $0.backgroundIntensity = v } }
                ), in: 0.3...1)
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func motionSection(palette: ThemePalette, locale: Locale) -> some View {
        Section(LunivoLocalization.string("Motion", locale: locale)) {
            Picker(LunivoLocalization.string("Motion mode", locale: locale), selection: Binding(
                get: { model.profile.motionPreference },
                set: { v in model.updateProfile { $0.motionPreference = v } }
            )) {
                ForEach(MotionPreference.allCases) { mode in
                    Text(mode.localizedTitle(locale: locale)).tag(mode)
                }
            }
            .listRowBackground(rowBG(palette))

            Stepper(
                "\(LunivoLocalization.string("Ticker interval", locale: locale)): \(model.profile.liveTickerInterval.formatted(.number.precision(.fractionLength(0))))s",
                value: Binding(
                    get: { model.profile.liveTickerInterval },
                    set: { v in model.updateProfile { $0.liveTickerInterval = v } }
                ),
                in: 2...8, step: 1
            )
            .listRowBackground(rowBG(palette))
        }
    }

    private func tickerSection(palette: ThemePalette, locale: Locale) -> some View {
        Section(LunivoLocalization.string("Live Ticker", locale: locale)) {
            Toggle(LunivoLocalization.string("Auto cycle", locale: locale), isOn: Binding(
                get: { model.profile.liveTickerAutoCycle },
                set: { v in model.updateProfile { $0.liveTickerAutoCycle = v } }
            ))
            .listRowBackground(rowBG(palette))

            Picker(LunivoLocalization.string("Visibility", locale: locale), selection: Binding(
                get: { model.profile.liveTickerVisibility },
                set: { v in model.updateProfile { $0.liveTickerVisibility = v } }
            )) {
                ForEach(LiveTickerVisibility.allCases) { option in
                    Text(option.localizedTitle(locale: locale)).tag(option)
                }
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func localizationSection(palette: ThemePalette, locale: Locale) -> some View {
        let sortedLanguages = AppLanguage.allCases.sorted { lhs, rhs in
            lhs.localizedTitle(locale: locale).compare(
                rhs.localizedTitle(locale: locale),
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: locale
            ) == .orderedAscending
        }

        Section(LunivoLocalization.string("Language", locale: locale)) {
            Picker(LunivoLocalization.string("Preferred language", locale: locale), selection: Binding(
                get: { model.preferredLanguage },
                set: { model.updateLanguage($0) }
            )) {
                ForEach(sortedLanguages) { language in
                    Text(language.localizedTitle(locale: locale)).tag(language)
                }
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func methodologySection(palette: ThemePalette, locale: Locale) -> some View {
        Section(LunivoLocalization.string("Methodology", locale: locale)) {
            NavigationLink(LunivoLocalization.string("Constants and assumptions", locale: locale)) {
                MethodologyView().environmentObject(model)
            }
            .listRowBackground(rowBG(palette))
            Text(LunivoLocalization.string("All calculations happen on this device and are labeled by derivation type.", locale: locale))
                .listRowBackground(rowBG(palette))
        }
    }
}
