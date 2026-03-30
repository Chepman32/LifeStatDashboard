import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let palette = model.profile.selectedTheme.palette

        NavigationStack {
            Form {
                profileSection(palette: palette)
                appearanceSection(palette: palette)
                motionSection(palette: palette)
                tickerSection(palette: palette)
                localizationSection(palette: palette)
                methodologySection(palette: palette)
                privacySection(palette: palette)
                aboutSection(palette: palette)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .foregroundStyle(palette.textPrimary)
            .navigationTitle("Settings")
            .tint(palette.accent)
        }
    }

    private func rowBG(_ palette: ThemePalette) -> some View {
        palette.listRowBackground.ignoresSafeArea()
    }

    private func profileSection(palette: ThemePalette) -> some View {
        Section("Profile Input") {
            DatePicker(
                "Birth Date",
                selection: Binding(
                    get: { model.profile.birthDate },
                    set: { v in model.updateProfile { $0.birthDate = v } }
                ),
                in: ...Date(),
                displayedComponents: model.profile.hasBirthTime ? [.date, .hourAndMinute] : [.date]
            )
            .listRowBackground(rowBG(palette))

            Toggle("Include birth time", isOn: Binding(
                get: { model.profile.hasBirthTime },
                set: { v in model.updateProfile { $0.hasBirthTime = v } }
            ))
            .listRowBackground(rowBG(palette))

            Picker("Units", selection: Binding(
                get: { model.profile.unitPreference },
                set: { v in model.updateProfile { $0.unitPreference = v } }
            )) {
                ForEach(UnitPreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }
            .listRowBackground(rowBG(palette))

            Button("Reset All", role: .destructive) { model.resetAll() }
                .listRowBackground(rowBG(palette))
        }
    }

    private func appearanceSection(palette: ThemePalette) -> some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { model.profile.selectedTheme },
                set: { v in model.updateProfile { $0.selectedTheme = v } }
            )) {
                ForEach(LunivoTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }
            .listRowBackground(rowBG(palette))

            Picker("Display Density", selection: Binding(
                get: { model.profile.displayDensity },
                set: { v in model.updateProfile { $0.displayDensity = v } }
            )) {
                Text("Calm").tag(DisplayDensity.calm)
                Text("Detailed").tag(DisplayDensity.detailed)
            }
            .listRowBackground(rowBG(palette))

            Toggle("Large text mode", isOn: Binding(
                get: { model.profile.largeTextMode },
                set: { v in model.updateProfile { $0.largeTextMode = v } }
            ))
            .listRowBackground(rowBG(palette))

            VStack(alignment: .leading) {
                Text("Background intensity")
                Slider(value: Binding(
                    get: { model.profile.backgroundIntensity },
                    set: { v in model.updateProfile { $0.backgroundIntensity = v } }
                ), in: 0.3...1)
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func motionSection(palette: ThemePalette) -> some View {
        Section("Motion") {
            Picker("Motion mode", selection: Binding(
                get: { model.profile.motionPreference },
                set: { v in model.updateProfile { $0.motionPreference = v } }
            )) {
                ForEach(MotionPreference.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .listRowBackground(rowBG(palette))

            Stepper(
                "Ticker interval: \(model.profile.liveTickerInterval.formatted(.number.precision(.fractionLength(0))))s",
                value: Binding(
                    get: { model.profile.liveTickerInterval },
                    set: { v in model.updateProfile { $0.liveTickerInterval = v } }
                ),
                in: 2...8, step: 1
            )
            .listRowBackground(rowBG(palette))
        }
    }

    private func tickerSection(palette: ThemePalette) -> some View {
        Section("Live Ticker") {
            Toggle("Auto cycle", isOn: Binding(
                get: { model.profile.liveTickerAutoCycle },
                set: { v in model.updateProfile { $0.liveTickerAutoCycle = v } }
            ))
            .listRowBackground(rowBG(palette))

            Picker("Visibility", selection: Binding(
                get: { model.profile.liveTickerVisibility },
                set: { v in model.updateProfile { $0.liveTickerVisibility = v } }
            )) {
                ForEach(LiveTickerVisibility.allCases) { option in
                    Text(option.rawValue.capitalized).tag(option)
                }
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func localizationSection(palette: ThemePalette) -> some View {
        Section("Language") {
            Picker("Preferred language", selection: Binding(
                get: { model.preferredLanguage },
                set: { model.updateLanguage($0) }
            )) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .listRowBackground(rowBG(palette))
        }
    }

    private func methodologySection(palette: ThemePalette) -> some View {
        Section("Methodology") {
            NavigationLink("Constants and assumptions") {
                MethodologyView().environmentObject(model)
            }
            .listRowBackground(rowBG(palette))
            Text("All calculations happen on this device and are labeled by derivation type.")
                .listRowBackground(rowBG(palette))
        }
    }

    private func privacySection(palette: ThemePalette) -> some View {
        Section("Privacy") {
            Text("All calculations happen on this device.").listRowBackground(rowBG(palette))
            Text("No account.").listRowBackground(rowBG(palette))
            Text("No server.").listRowBackground(rowBG(palette))
            Text("No tracking.").listRowBackground(rowBG(palette))
        }
    }

    private func aboutSection(palette: ThemePalette) -> some View {
        Section("About") {
            Text("Version 1.0").listRowBackground(rowBG(palette))
            Text("Built as a native SwiftUI iPhone app with deterministic offline calculations.").listRowBackground(rowBG(palette))
            Text("Typography uses Apple-native system type with Helvetica Neue for select editorial treatments.").listRowBackground(rowBG(palette))
        }
    }
}
