import SwiftUI
import Foundation

// MARK: - View
struct HomePage: View {
    @State private var message: String = ""
    @State private var chatHistory: [ChatMessage] = []
    @State private var availableModels: [String] = []
    @AppStorage("selectedModel") private var selectedModel: String = ""
    @AppStorage("ollamaBaseURL") private var ollamaBaseURLString: String = "http://localhost:11434"
    @State private var isLoading: Bool = false
    
    private var service: LLMService { LLMService(baseURL: URL(string: ollamaBaseURLString) ?? URL(string: "http://localhost:11434")!) }

    var body: some View {
        VStack(spacing: 16) {
            Text("Chat")
                .font(.largeTitle)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(chatHistory) { msg in
                        HStack {
                            if msg.role == "user" {
                                Spacer()
                                Text(msg.content)
                                    .padding()
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(12)
                            } else {
                                Text(msg.content)
                                    .padding()
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(12)
                                Spacer()
                            }
                        }
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }

            GeometryReader { proxy in
                HStack(spacing: 12) {
                    TextField("Type a message", text: $message)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            sendMessage()
                        }
                        .disabled(isLoading)
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(message.isEmpty || isLoading)
                }
                .frame(width: proxy.size.width * 0.9)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 56)
        }
        .padding()
        .navigationTitle("Home")
        .onAppear {
            if availableModels.isEmpty {
                Task { await loadModels() }
            }
        }
    }
    
    // MARK: - Networking
    @MainActor
    private func loadModels() async {
        do {
            let models = try await service.fetchModels()
            self.availableModels = models
            // Only set a default if there's no saved selection or it's no longer available.
            if selectedModel.isEmpty || !models.contains(selectedModel) {
                if let first = models.first { self.selectedModel = first }
            }
        } catch {
            print("Error fetching models: \(error.localizedDescription)")
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty, !selectedModel.isEmpty else { return }
        let userMsg = ChatMessage(role: "user", content: message)
        chatHistory.append(userMsg)
        message = ""
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let reply = try await service.sendMessage(model: selectedModel, chatHistory: chatHistory)
                self.chatHistory.append(reply)
            } catch {
                let errorMsg = ChatMessage(role: "system", content: "Error communicating with Ollama endpoint: \(error.localizedDescription)")
                self.chatHistory.append(errorMsg)
            }
        }
    }
}

#Preview {
    NavigationStack { HomePage() }
}

