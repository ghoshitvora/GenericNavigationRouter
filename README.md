# GenericNavigationRouter

A lightweight, SwiftUI‑first navigation helper that combines tab navigation, stack navigation, deep linking, and sheet/modal presentation in a single, beginner‑friendly file.

## Highlights

- iOS 14–17 support (NavigationStack on iOS 16+, NavigationView fallback)
- Enum‑based tabs and routes
- Independent navigation stacks per tab
- Simple push/pop/popToRoot API
- Central deep link handler
- Sheet and full‑screen presentation
- MVVM‑friendly and ObservableObject‑based

## Single‑File Setup

Just add this file to your project:

```
NavigationRouter.swift
```

That file contains:
- `NavigationRouter` (stack + modal state)
- `AppRouter` (tab coordination + deep links)
- `NavigationContainer` (SwiftUI wiring)
- Deep link types

## Example

### Routes

```swift
enum AppTab: String, Hashable, CaseIterable {
    case home
    case settings
}

enum HomeRoute: Hashable {
    case detail(id: Int)
}

enum SettingsRoute: Hashable {
    case about
}

enum AppSheet: Hashable, Identifiable {
    case filter
    case fullscreenInfo

    var id: String {
        switch self {
        case .filter: return "filter"
        case .fullscreenInfo: return "fullscreenInfo"
        }
    }
}
```

### App Router Setup

```swift
let home = NavigationRouter<HomeRoute, AppSheet>()
let settings = NavigationRouter<SettingsRoute, AppSheet>()

let appRouter = AppRouter(
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
```

### Only Tabs (No Navigation Stack)

```swift
TabView(selection: $appRouter.selectedTab) {
    HomeView(router: home, appRouter: appRouter)
        .tabItem { Label("Home", systemImage: "house") }
        .tag(AppTab.home)

    SettingsView(router: settings, appRouter: appRouter)
        .tabItem { Label("Settings", systemImage: "gearshape") }
        .tag(AppTab.settings)
}
```

### Only Navigation (Single Stack)

```swift
let singleRouter = NavigationRouter<HomeRoute, AppSheet>()

NavigationContainer(
    router: singleRouter,
    root: { HomeView(router: singleRouter, appRouter: appRouter) },
    destination: { route in
        switch route {
        case .detail(let id):
            HomeDetailView(id: id, router: singleRouter)
        }
    },
    sheetContent: { sheet in
        switch sheet {
        case .filter: FilterView()
        case .fullscreenInfo: FullscreenInfoView()
        }
    }
)
```

### Tab + Navigation UI

```swift
TabView(selection: $appRouter.selectedTab) {
    NavigationContainer(
        router: home,
        root: { HomeView(router: home, appRouter: appRouter) },
        destination: { route in
            switch route {
            case .detail(let id):
                HomeDetailView(id: id, router: home)
            }
        },
        sheetContent: { sheet in
            switch sheet {
            case .filter: FilterView()
            case .fullscreenInfo: FullscreenInfoView()
            }
        }
    )
    .tabItem { Label("Home", systemImage: "house") }
    .tag(AppTab.home)

    NavigationContainer(
        router: settings,
        root: { SettingsView(router: settings, appRouter: appRouter) },
        destination: { route in
            switch route {
            case .about:
                SettingsAboutView(router: settings)
            }
        },
        sheetContent: { sheet in
            switch sheet {
            case .filter: FilterView()
            case .fullscreenInfo: FullscreenInfoView()
            }
        }
    )
    .tabItem { Label("Settings", systemImage: "gearshape") }
    .tag(AppTab.settings)
}
```

### Clean API Calls

```swift
router.push(.detail(id: 1))
router.pop()
router.popToRoot()
appRouter.switchTab(.settings)
appRouter.handleDeepLink(URL(string: "myapp://home/detail/1")!)
router.presentSheet(.filter)
router.presentFullScreen(.fullscreenInfo)
router.dismissAllModals()
```

## Deep Linking

Register a URL scheme (e.g., `myapp`) and forward incoming URLs:

```swift
.onOpenURL { url in
    appRouter.handleDeepLink(url)
}
```

## License

MIT
