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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                settingsCard(title: "LLM Host Endpoint", subtitle: "Set the Ollama base URL. Defaults to http://localhost:11434") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Ollama Base URL", text: $tempURLString)
                                .textFieldStyle(.roundedBorder)
                                .font(.callout)
                            Button("Save") { saveURL() }
                                .disabled(tempURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        Text("Current: \(ollamaBaseURLString)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                settingsCard(title: "LLM", subtitle: "Choose which local model to use.") {
                    VStack(alignment: .leading, spacing: 8) {
                        if isLoading {
                            HStack { ProgressView(); Spacer() }
                        }
                        HStack(spacing: 8) {
                            Picker("Model", selection: $selectedModel) {
                                if availableModels.isEmpty {
                                    Text("No models found").tag("")
                                } else {
                                    ForEach(availableModels, id: \.self) { model in
                                        Text(model).tag(model)
                                    }
                                }
                            }
                            .labelsHidden()
                            .disabled(isLoading)

                            Button("Refresh") { refreshModels() }
                                .disabled(isLoading)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Settings")
        .onAppear {
            tempURLString = ollamaBaseURLString
            refreshModels()
        }
    }

    // MARK: - Card helper
    private func settingsCard<Content: View>(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.secondary.opacity(0.15))
        )
    }

    // MARK: - Logic
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
