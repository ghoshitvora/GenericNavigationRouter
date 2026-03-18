import SwiftUI
import Combine

final class NavigationRouter<Route: Hashable, SheetRoute: Identifiable & Hashable>: ObservableObject {
    @Published var path: [Route] = []
    @Published var presentedSheet: SheetRoute?
    @Published var presentedFullScreen: SheetRoute?

    init() {}

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func presentSheet(_ route: SheetRoute) {
        presentedSheet = route
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func presentFullScreen(_ route: SheetRoute) {
        presentedFullScreen = route
    }

    func dismissFullScreen() {
        presentedFullScreen = nil
    }

    func dismissAllModals() {
        presentedSheet = nil
        presentedFullScreen = nil
    }
}

final class AppRouter<Tab: Hashable>: ObservableObject {
    @Published var selectedTab: Tab

    private var routers: [Tab: AnyObject]
    private let deepLinkHandler: DeepLinkHandler<Tab>?

    init(
        selectedTab: Tab,
        routers: [Tab: AnyObject],
        deepLinkHandler: DeepLinkHandler<Tab>? = nil
    ) {
        self.selectedTab = selectedTab
        self.routers = routers
        self.deepLinkHandler = deepLinkHandler
    }

    func switchTab(_ tab: Tab) {
        selectedTab = tab
    }

    func router<Route: Hashable, SheetRoute: Identifiable & Hashable>(
        for tab: Tab,
        as type: NavigationRouter<Route, SheetRoute>.Type = NavigationRouter<Route, SheetRoute>.self
    ) -> NavigationRouter<Route, SheetRoute>? {
        routers[tab] as? NavigationRouter<Route, SheetRoute>
    }

    func handleDeepLink(_ url: URL) {
        guard let destination = deepLinkHandler?(url) else { return }
        switchTab(destination.tab)
        destination.action()
    }
}

struct DeepLinkDestination<Tab: Hashable> {
    let tab: Tab
    let action: () -> Void

    init(tab: Tab, action: @escaping () -> Void) {
        self.tab = tab
        self.action = action
    }
}

typealias DeepLinkHandler<Tab: Hashable> = (URL) -> DeepLinkDestination<Tab>?

struct NavigationContainer<Route: Hashable, SheetRoute: Identifiable & Hashable, Root: View, Destination: View, SheetContent: View>: View {
    @ObservedObject private var router: NavigationRouter<Route, SheetRoute>
    private let root: () -> Root
    private let destination: (Route) -> Destination
    private let sheetContent: (SheetRoute) -> SheetContent

    init(
        router: NavigationRouter<Route, SheetRoute>,
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder sheetContent: @escaping (SheetRoute) -> SheetContent
    ) {
        self.router = router
        self.root = root
        self.destination = destination
        self.sheetContent = sheetContent
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack(path: $router.path) {
                    root()
                        .navigationDestination(for: Route.self) { route in
                            destination(route)
                        }
                }
            } else {
                NavigationView {
                    LegacyNavigationStack(
                        router: router,
                        index: 0,
                        root: { AnyView(root()) },
                        destination: { route in AnyView(destination(route)) }
                    )
                }
            }
        }
        .sheet(item: $router.presentedSheet) { route in
            sheetContent(route)
        }
        .fullScreenCover(item: $router.presentedFullScreen) { route in
            sheetContent(route)
        }
    }
}

private struct LegacyNavigationStack<Route: Hashable, SheetRoute: Identifiable & Hashable>: View {
    @ObservedObject var router: NavigationRouter<Route, SheetRoute>
    let index: Int
    let root: () -> AnyView
    let destination: (Route) -> AnyView

    var body: some View {
        ZStack {
            root()

            NavigationLink(
                destination: nextView(),
                isActive: Binding(
                    get: { router.path.count > index },
                    set: { isActive in
                        if !isActive {
                            router.path = Array(router.path.prefix(index))
                        }
                    }
                ),
                label: { EmptyView() }
            )
            .hidden()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder private func nextView() -> some View {
        if router.path.count > index {
            let route = router.path[index]
            LegacyNavigationStack(
                router: router,
                index: index + 1,
                root: { destination(route) },
                destination: destination
            )
        }
    }
}
