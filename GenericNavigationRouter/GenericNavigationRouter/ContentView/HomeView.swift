import SwiftUI

struct HomeView: View {
    @ObservedObject var router: NavigationRouter<HomeRoute, AppSheet>
    @ObservedObject var appRouter: AppRouter<AppTab>

    var body: some View {
        VStack(spacing: 16) {
            Text("Home")
                .font(.largeTitle)

            Button("Go to Detail 1") {
                router.push(.detail(id: 1))
            }

            Button("Present Filter Sheet") {
                router.presentSheet(.filter)
            }

            Button("Show Fullscreen Info") {
                router.presentFullScreen(.fullscreenInfo)
            }

            Button("Switch to Settings") {
                appRouter.switchTab(.settings)
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}
