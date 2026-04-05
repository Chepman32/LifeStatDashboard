import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var model: AppModel

    @State private var step: Step = .welcome
    @State private var draft = UserProfile.default
    @State private var showReveal = false

    var body: some View {
        let theme = draft.selectedTheme
        let palette = theme.palette

        ZStack {
            CosmicBackgroundView(theme: theme, intensity: draft.backgroundIntensity, animate: model.effectiveMotion == .full)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Lunivo")
                    .font(LunivoTypography.editorial(36, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                    .padding(.top, 24)

                Text(LocalizedStringKey(progressTitle))
                    .font(.caption.weight(.semibold))
                    .tracking(2.5)
                    .foregroundStyle(palette.textSecondary)

                Spacer(minLength: 8)

                switch step {
                case .welcome:
                    welcome(theme: theme)
                case .birthday:
                    birthday(theme: theme)
                case .style:
                    preferences(theme: theme)
                case .reveal:
                    reveal(theme: theme)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var progressTitle: String {
        switch step {
        case .welcome: "Welcome"
        case .birthday: "Birthday"
        case .style: "Style"
        case .reveal: "Reveal"
        }
    }

    @ViewBuilder
    private func welcome(theme: LunivoTheme) -> some View {
        let palette = theme.palette
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 20)
            Text("Your life, translated into impossible numbers.")
                .font(LunivoTypography.hero(44))
                .foregroundStyle(palette.textPrimary)

            Text("Lunivo keeps everything on your device. No account. No cloud. No tracking. Just your timeline, rendered at unreasonable scale.")
                .font(.title3.weight(.medium))
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            GlassCard(theme: theme, cornerRadius: 32, padding: 22) {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Offline-only calculations", systemImage: "internaldrive")
                    Label("Premium native motion", systemImage: "sparkles.tv")
                    Label("Shareable cosmic cards", systemImage: "photo.on.rectangle.angled")
                }
                .font(.headline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
            }

            Button("Begin") {
                withAnimation(.spring(duration: 0.65, bounce: 0.22)) {
                    step = .birthday
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))

            Text("No account. No cloud. No tracking.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(palette.textSecondary)
        }
    }

    @ViewBuilder
    private func birthday(theme: LunivoTheme) -> some View {
        let preview = LifeTimeline(profile: draft, now: .now, calendar: Calendar.current).ageSummary.totalDays
        let palette = theme.palette
        let previewText = LunivoLocalization.formatted(
            "You’ve lived approximately %@ days.",
            locale: model.locale,
            preview.formatted()
        )

        VStack(alignment: .leading, spacing: 18) {
            Text("When did the timeline start?")
                .font(LunivoTypography.display(36, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            Text("Used only on your device.")
                .font(.headline.weight(.medium))
                .foregroundStyle(palette.textSecondary)

            GlassCard(theme: theme, cornerRadius: 32, padding: 12) {
                VStack(spacing: 16) {
                    Picker("Input mode", selection: $draft.hasBirthTime) {
                        Text("Date only").tag(false)
                        Text("Date + time").tag(true)
                    }
                    .pickerStyle(.segmented)

                    DatePicker(
                        "",
                        selection: $draft.birthDate,
                        in: ...Date(),
                        displayedComponents: draft.hasBirthTime ? [.date, .hourAndMinute] : [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
            }

            Text(previewText)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(palette.textPrimary)
                .contentTransition(.numericText())

            Button("Continue") {
                withAnimation(.spring(duration: 0.65, bounce: 0.22)) {
                    step = .style
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
        }
    }

    @ViewBuilder
    private func preferences(theme: LunivoTheme) -> some View {
        let palette = theme.palette

        VStack(alignment: .leading, spacing: 18) {
            Text("Set the mood.")
                .font(LunivoTypography.display(36, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(LunivoTheme.allCases) { option in
                        Button {
                            withAnimation(.spring(duration: 0.55, bounce: 0.18)) {
                                draft.selectedTheme = option
                            }
                            HapticsManager.shared.selectionChanged()
                        } label: {
                            ThemePreviewCard(theme: option, selected: draft.selectedTheme == option)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            GlassCard(theme: draft.selectedTheme, cornerRadius: 32, padding: 18) {
                VStack(spacing: 16) {
                    LabeledContent("Display Density") {
                        Picker("Display Density", selection: $draft.displayDensity) {
                            Text("Calm").tag(DisplayDensity.calm)
                            Text("Detailed").tag(DisplayDensity.detailed)
                        }
                        .pickerStyle(.segmented)
                    }

                    LabeledContent("Units") {
                        Picker("Units", selection: $draft.unitPreference) {
                            Text("Metric").tag(UnitPreference.metric)
                            Text("Imperial").tag(UnitPreference.imperial)
                        }
                        .pickerStyle(.segmented)
                    }

                    LabeledContent("Motion") {
                        Picker("Motion", selection: $draft.motionPreference) {
                            Text("Full").tag(MotionPreference.full)
                            Text("Reduced").tag(MotionPreference.reduced)
                            Text("System").tag(MotionPreference.respectSystem)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .foregroundStyle(palette.textPrimary)
            }

            Button("See My Stats") {
                withAnimation(.easeInOut(duration: 0.45)) {
                    step = .reveal
                    showReveal = true
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: draft.selectedTheme))
        }
    }

    @ViewBuilder
    private func reveal(theme: LunivoTheme) -> some View {
        let palette = theme.palette
        let previewSnapshot = LifeStatEngine().snapshot(profile: draft, now: .now, language: model.preferredLanguage)
        let hero = previewSnapshot.statsByCategory[.time]?.first

        VStack(alignment: .leading, spacing: 22) {
            Text("First reveal.")
                .font(LunivoTypography.display(38, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            if let hero {
                GlassCard(theme: theme, cornerRadius: 36, padding: 28) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(LocalizedStringKey(hero.title))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(palette.textSecondary)
                        RollingNumberText(text: hero.formattedValue, unit: hero.unit, theme: theme, emphasis: true)
                        Text(LocalizedStringKey(hero.wittyComparison))
                            .font(LunivoTypography.editorial(24))
                            .foregroundStyle(palette.textPrimary)
                    }
                }
                .scaleEffect(showReveal ? 1 : 0.88)
                .opacity(showReveal ? 1 : 0)
                .animation(.spring(duration: 0.8, bounce: 0.18), value: showReveal)
            }

            Text("The rest of the dashboard is already waiting below this moment.")
                .font(.headline.weight(.medium))
                .foregroundStyle(palette.textSecondary)

            Button("Enter Lunivo") {
                model.completeOnboarding(with: draft)
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
        }
        .onAppear {
            HapticsManager.shared.impact(.medium)
        }
    }

    private enum Step {
        case welcome
        case birthday
        case style
        case reveal
    }
}

private struct ThemePreviewCard: View {
    let theme: LunivoTheme
    let selected: Bool

    var body: some View {
        let palette = theme.palette

        VStack(alignment: .leading, spacing: 14) {
            LinearGradient(colors: palette.background, startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 86)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    Circle()
                        .fill(palette.accent.opacity(0.6))
                        .frame(width: 26, height: 26)
                        .offset(x: 16, y: -14)
                }

            Text(LocalizedStringKey(theme.title))
                .font(.headline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
        }
        .padding(16)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(selected ? palette.accent : .white.opacity(0.1), lineWidth: selected ? 2 : 1)
        )
        .scaleEffect(selected ? 1.02 : 0.98)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let theme: LunivoTheme

    func makeBody(configuration: Configuration) -> some View {
        let palette = theme.palette

        return configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(theme == .light || theme == .solar ? Color.black : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [palette.accent, palette.accentSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(color: palette.glow, radius: 18, y: 10)
    }
}
