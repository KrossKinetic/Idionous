import SwiftUI

// Your single "page" for now.
struct HomePage: View {
    @State private var message: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Chat")
                .font(.largeTitle)
                .bold()
            Spacer()

            GeometryReader { proxy in
                HStack {
                    TextField("Type a message", text: $message)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(width: proxy.size.width * 0.7)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 56)
        }
        .padding()
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack { HomePage() }
}
