import SwiftUI

@main
struct GenericNavigationRouterApp: App {
    @StateObject private var homeRouter: NavigationRouter<HomeRoute, AppSheet>
    @StateObject private var settingsRouter: NavigationRouter<SettingsRoute, AppSheet>
    @StateObject private var appRouter: AppRouter<AppTab>

    init() {
        let home = NavigationRouter<HomeRoute, AppSheet>()
        let settings = NavigationRouter<SettingsRoute, AppSheet>()
        let appRouter: AppRouter<AppTab> = AppRouter(
            selectedTab: .home,
            routers: [
                .home: home,
                .settings: settings
            ],
            deepLinkHandler: { url in
                guard url.scheme == "myapp" else { return nil }
                let parts = url.pathComponents.filter { $0 != "/" }

                if parts.count >= 3,
                   parts[0] == "home",
                   parts[1] == "detail",
                   let id = Int(parts[2]) {
                    return DeepLinkDestination(tab: .home) {
                        home.popToRoot()
                        home.push(.detail(id: id))
                    }
                }

                if parts.first == "settings" {
                    return DeepLinkDestination(tab: .settings) {
                        settings.popToRoot()
                        settings.push(.about)
                    }
                }

                return nil
            }
        )

        _homeRouter = StateObject(wrappedValue: home)
        _settingsRouter = StateObject(wrappedValue: settings)
        _appRouter = StateObject(wrappedValue: appRouter)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                appRouter: appRouter,
                homeRouter: homeRouter,
                settingsRouter: settingsRouter
            )
            .onOpenURL { url in
                appRouter.handleDeepLink(url)
            }
        }
    }
}
