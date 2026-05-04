import SwiftUI
import Foundation

struct SettingsPage: View {
    @AppStorage("ollamaBaseURL") private var ollamaBaseURLString: String = "http://localhost:11434"
    @AppStorage("selectedModel") private var selectedModel: String = ""

    @State private var availableModels: [String] = []
    @State private var tempURLString: String = ""
    @State private var isLoading: Bool = false
    private let service = LLMService()

    var body: some View {
        Form {
            Section(header: Text("LLM")) {
                if isLoading {
                    HStack { ProgressView(); Spacer() }
                }
                Picker("Model", selection: $selectedModel) {
                    if availableModels.isEmpty {
                        Text("No models found").tag("")
                    } else {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                .disabled(isLoading)
                Button("Refresh Models") { refreshModels() }
                    .disabled(isLoading)
            }

            Section(header: Text("Server"), footer: Text("Set the Ollama base URL. Defaults to http://localhost:11434")) {
                HStack(spacing: 8) {
                    TextField("Ollama Base URL", text: $tempURLString)
                    Button("Save") { saveURL() }
                        .disabled(tempURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                Text("Current: \(ollamaBaseURLString)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            tempURLString = ollamaBaseURLString
            refreshModels()
        }
    }

    private func refreshModels() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let service = serviceWithStoredURL()
                let models = try await service.fetchModels()
                await MainActor.run {
                    availableModels = models
                    // Ensure the selection is valid for the Picker tags.
                    if !models.contains(selectedModel) {
                        selectedModel = models.first ?? ""
                    }
                }
            } catch {
                print("Error fetching models: \(error.localizedDescription)")
                await MainActor.run { availableModels = [] }
            }
        }
    }

    private func saveURL() {
        let trimmed = tempURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), url.scheme == "http" || url.scheme == "https" else { return }
        ollamaBaseURLString = trimmed
        refreshModels()
    }

    private func serviceWithStoredURL() -> LLMService {
        if let url = URL(string: ollamaBaseURLString) { return LLMService(baseURL: url) }
        return LLMService()
    }
}

#Preview {
    NavigationStack { SettingsPage() }
}
