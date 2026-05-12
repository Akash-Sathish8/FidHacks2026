import SwiftUI

@main
struct MoneyMovesApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ZStack {
            switch app.route {
            case .splash:        SplashView()
            case .login:         LoginView()
            case .buddyPicker:   BuddyPickerView()
            case .goalSetup:     GoalSetupView()
            case .main:          MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: app.route)
    }
}
