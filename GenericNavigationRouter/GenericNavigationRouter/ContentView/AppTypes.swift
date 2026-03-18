import Foundation

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
        case .filter:
            return "filter"
        case .fullscreenInfo:
            return "fullscreenInfo"
        }
    }
}
