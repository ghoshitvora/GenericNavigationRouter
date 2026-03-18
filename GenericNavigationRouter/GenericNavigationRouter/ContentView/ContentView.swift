import SwiftUI

struct ContentView: View {
    @ObservedObject var appRouter: AppRouter<AppTab>
    @ObservedObject var homeRouter: NavigationRouter<HomeRoute, AppSheet>
    @ObservedObject var settingsRouter: NavigationRouter<SettingsRoute, AppSheet>

    var body: some View {
        TabView(selection: $appRouter.selectedTab) {
            NavigationContainer(
                router: homeRouter,
                root: {
                    HomeView(router: homeRouter, appRouter: appRouter)
                },
                destination: { route in
                    switch route {
                    case .detail(let id):
                        HomeDetailView(id: id, router: homeRouter)
                    }
                },
                sheetContent: sheetView
            )
            .tabItem { Label("Home", systemImage: "house") }
            .tag(AppTab.home)

            NavigationContainer(
                router: settingsRouter,
                root: {
                    SettingsView(router: settingsRouter, appRouter: appRouter)
                },
                destination: { route in
                    switch route {
                    case .about:
                        SettingsAboutView(router: settingsRouter)
                    }
                },
                sheetContent: sheetView
            )
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(AppTab.settings)
        }
    }

    @ViewBuilder private func sheetView(_ sheet: AppSheet) -> some View {
        switch sheet {
        case .filter:
            VStack(spacing: 16) {
                Text("Filter Sheet")
                    .font(.title2)
                Text("This is a bottom sheet.")
                Button("Dismiss") {
                    homeRouter.dismissSheet()
                    settingsRouter.dismissSheet()
                }
            }
            .padding()
        case .fullscreenInfo:
            VStack(spacing: 16) {
                Text("Fullscreen")
                    .font(.title2)
                Text("This is a full screen cover.")
                Button("Dismiss") {
                    homeRouter.dismissFullScreen()
                    settingsRouter.dismissFullScreen()
                }
            }
            .padding()
        }
    }
}

#Preview {
    let home = NavigationRouter<HomeRoute, AppSheet>()
    let settings = NavigationRouter<SettingsRoute, AppSheet>()
    let appRouter: AppRouter<AppTab> = AppRouter(
        selectedTab: .home,
        routers: [
            .home: home,
            .settings: settings
        ]
    )

    ContentView(
        appRouter: appRouter,
        homeRouter: home,
        settingsRouter: settings
    )
}
