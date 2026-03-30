import SwiftUI

@main
struct LiftaApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(model)
                .environment(\.locale, model.locale)
        }
    }
}
