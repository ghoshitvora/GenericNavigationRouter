import SwiftUI

struct SettingsView: View {
    @ObservedObject var router: NavigationRouter<SettingsRoute, AppSheet>
    @ObservedObject var appRouter: AppRouter<AppTab>

    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.largeTitle)

            Button("Go to About") {
                router.push(.about)
            }

            Button("Switch to Home") {
                appRouter.switchTab(.home)
            }
        }
        .padding()
        .navigationTitle("Settings")
    }
}
