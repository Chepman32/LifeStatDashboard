import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let theme = model.profile.selectedTheme

        NavigationStack {
            Form {
                profileSection
                appearanceSection
                motionSection
                tickerSection
                localizationSection
                methodologySection
                privacySection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .tint(theme.palette.accent)
        }
    }

    private var profileSection: some View {
        Section("Profile Input") {
            DatePicker(
                "Birth Date",
                selection: Binding(
                    get: { model.profile.birthDate },
                    set: { newValue in
                        model.updateProfile { $0.birthDate = newValue }
                    }
                ),
                in: ...Date(),
                displayedComponents: model.profile.hasBirthTime ? [.date, .hourAndMinute] : [.date]
            )

            Toggle("Include birth time", isOn: Binding(
                get: { model.profile.hasBirthTime },
                set: { value in
                    model.updateProfile { $0.hasBirthTime = value }
                }
            ))

            Picker("Units", selection: Binding(
                get: { model.profile.unitPreference },
                set: { value in
                    model.updateProfile { $0.unitPreference = value }
                }
            )) {
                ForEach(UnitPreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }

            Button("Reset All", role: .destructive) {
                model.resetAll()
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { model.profile.selectedTheme },
                set: { value in
                    model.updateProfile { $0.selectedTheme = value }
                }
            )) {
                ForEach(LiftaTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }

            Picker("Display Density", selection: Binding(
                get: { model.profile.displayDensity },
                set: { value in
                    model.updateProfile { $0.displayDensity = value }
                }
            )) {
                Text("Calm").tag(DisplayDensity.calm)
                Text("Detailed").tag(DisplayDensity.detailed)
            }

            Toggle("Large text mode", isOn: Binding(
                get: { model.profile.largeTextMode },
                set: { value in
                    model.updateProfile { $0.largeTextMode = value }
                }
            ))

            VStack(alignment: .leading) {
                Text("Background intensity")
                Slider(value: Binding(
                    get: { model.profile.backgroundIntensity },
                    set: { value in
                        model.updateProfile { $0.backgroundIntensity = value }
                    }
                ), in: 0.3...1)
            }
        }
    }

    private var motionSection: some View {
        Section("Motion") {
            Picker("Motion mode", selection: Binding(
                get: { model.profile.motionPreference },
                set: { value in
                    model.updateProfile { $0.motionPreference = value }
                }
            )) {
                ForEach(MotionPreference.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Stepper(
                "Ticker interval: \(model.profile.liveTickerInterval.formatted(.number.precision(.fractionLength(0))))s",
                value: Binding(
                    get: { model.profile.liveTickerInterval },
                    set: { value in
                        model.updateProfile { $0.liveTickerInterval = value }
                    }
                ),
                in: 2...8,
                step: 1
            )
        }
    }

    private var tickerSection: some View {
        Section("Live Ticker") {
            Toggle("Auto cycle", isOn: Binding(
                get: { model.profile.liveTickerAutoCycle },
                set: { value in
                    model.updateProfile { $0.liveTickerAutoCycle = value }
                }
            ))

            Picker("Visibility", selection: Binding(
                get: { model.profile.liveTickerVisibility },
                set: { value in
                    model.updateProfile { $0.liveTickerVisibility = value }
                }
            )) {
                ForEach(LiveTickerVisibility.allCases) { option in
                    Text(option.rawValue.capitalized).tag(option)
                }
            }
        }
    }

    private var localizationSection: some View {
        Section("Language") {
            Picker("Preferred language", selection: Binding(
                get: { model.preferredLanguage },
                set: { value in
                    model.updateLanguage(value)
                }
            )) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
        }
    }

    private var methodologySection: some View {
        Section("Methodology") {
            NavigationLink("Constants and assumptions") {
                MethodologyView()
                    .environmentObject(model)
            }
            Text("All calculations happen on this device and are labeled by derivation type.")
        }
    }

    private var privacySection: some View {
        Section("Privacy") {
            Text("All calculations happen on this device.")
            Text("No account.")
            Text("No server.")
            Text("No tracking.")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            Text("Version 1.0")
            Text("Built as a native SwiftUI iPhone app with deterministic offline calculations.")
            Text("Typography uses Apple-native system type with Helvetica Neue for select editorial treatments.")
        }
    }
}
