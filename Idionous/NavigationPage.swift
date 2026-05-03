import SwiftUI

// A lightweight version of NavigationOptions with just one page.
enum NavigationPage: Equatable, Hashable, Identifiable {
    case home

    static let mainPages: [NavigationPage] = [.home]

    var id: String {
        switch self {
        case .home: return "Home"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .home:
            LocalizedStringResource("Home", comment: "Title for the only page shown in the sidebar.")
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house"
        }
    }

    @ViewBuilder func viewForPage() -> some View {
        HomePage()
    }
}
