import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var model: AppModel
    @State private var splashFinished = false

    var body: some View {
        ZStack {
            CosmicBackgroundView(theme: model.profile.selectedTheme, intensity: model.profile.backgroundIntensity, animate: model.effectiveMotion == .full)
                .ignoresSafeArea()

            if splashFinished {
                if model.hasCompletedOnboarding {
                    MainShellView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    OnboardingView()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            } else {
                SplashView {
                    withAnimation(.smooth(duration: 0.8)) {
                        splashFinished = true
                        model.isShowingSplash = false
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(model.profile.selectedTheme.preferredScheme)
        .dynamicTypeSize(model.profile.largeTextMode ? .accessibility1 : .large)
    }
}

private struct MainShellView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch model.selectedTab {
                case .dashboard:
                    DashboardView()
                case .milestones:
                    MilestonesView()
                case .share:
                    ShareComposerView()
                case .settings:
                    SettingsView()
                }
            }
            .padding(.bottom, 108)
            .transition(.opacity.combined(with: .scale(scale: 0.99)))

            FloatingTabBar(selectedTab: $model.selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .fullScreenCover(item: $model.selectedStat) { stat in
            StatDetailView(stat: stat)
                .environmentObject(model)
        }
    }
}
