import SwiftUI

struct SidebarSplitView: View {
    @State private var preferredColumn: NavigationSplitViewColumn = .detail
    @State private var path = NavigationPath()

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            List {
                Section {
                    ForEach(NavigationPage.mainPages) { page in
                        NavigationLink(value: page) {
                            Label(page.name, systemImage: page.symbolName)
                        }
                    }
                }
            }
            .navigationDestination(for: NavigationPage.self) { page in
                NavigationStack(path: $path) {
                    page.viewForPage()
                }
            }
            .frame(minWidth: 150)
        } detail: {
            // Default detail content (first page).
            NavigationStack(path: $path) {
                NavigationPage.mainPages.first?.viewForPage()
            }
        }
    }
}

#Preview {
    SidebarSplitView()
}
