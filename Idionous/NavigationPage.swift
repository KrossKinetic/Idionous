import SwiftUI

// A lightweight version of NavigationOptions with just one page.
enum NavigationPage: Equatable, Hashable, Identifiable {
    case home
    case settings

    static let mainPages: [NavigationPage] = [.home, .settings]

    var id: String {
        switch self {
        case .home: return "Home"
        case .settings:
            return "Settings"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .home:
            LocalizedStringResource("Home", comment: "Title for the only page shown in the sidebar.")
        case .settings:
            LocalizedStringResource("Settings", comment: "Title for the settings page in the sidebar.")
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house"
        case .settings:
            "gear"
        }
    }

    @ViewBuilder func viewForPage() -> some View {
            switch self {
            case .home:
                HomePage()
            case .settings:
                SettingsPage()
            }
        }
}
