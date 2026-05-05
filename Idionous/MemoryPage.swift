import SwiftUI
import UniformTypeIdentifiers

struct MemoryPage: View {
    // MARK: - State
    @State private var noteText: String = ""
    @State private var pickedFiles: [URL] = []
    @State private var isImporting: Bool = false
    @State private var isSubmitting: Bool = false

    // Hardcoded active memory list (pdf/txt/md)
    @State private var activeMemory: [String] = [
        "ProjectNotes.md",
        "ResearchPaper.pdf",
        "TodoList.txt"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Section 1 & 2 combined: Text input and file upload
                settingsCard(title: "Add Memory", subtitle: "Enter text or upload files (.txt, .pdf, .md) and submit.") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Text field + submit
                        HStack(spacing: 8) {
                            TextField("Enter memory text", text: $noteText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .font(.callout)
                            Button("Submit") { submitText() }
                                .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                        }

                        // File picker + selected files list + submit
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Button {
                                    isImporting = true
                                } label: {
                                    Label("Choose Files", systemImage: "tray.and.arrow.down")
                                }

                                Button("Submit Files") { submitFiles() }
                                    .disabled(pickedFiles.isEmpty || isSubmitting)
                            }

                            if !pickedFiles.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(pickedFiles, id: \.self) { url in
                                        HStack {
                                            Image(systemName: iconName(for: url))
                                                .foregroundStyle(.secondary)
                                            Text(url.lastPathComponent)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Section 3: Active Memory list
                settingsCard(title: "Active Memory", subtitle: "Files currently loaded into memory.") {
                    if activeMemory.isEmpty {
                        Text("No active memory yet.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(activeMemory, id: \.self) { item in
                                HStack(spacing: 8) {
                                    Image(systemName: iconName(forFileName: item))
                                        .foregroundStyle(.secondary)
                                    Text(item)
                                    Spacer()
                                    Button {
                                        delete(item: item)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.red)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: allowedTypes(), allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                pickedFiles.append(contentsOf: urls)
            case .failure:
                break
            }
        }
        #if canImport(UIKit)
        .background(Color(uiColor: .systemBackground))
        #elseif canImport(AppKit)
        .background(Color(nsColor: .windowBackgroundColor))
        #else
        .background(Color.background)
        #endif
        .navigationTitle("Memory")
    }

    // MARK: - Actions
    private func submitText() {
        guard !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSubmitting = true
        // Simulate submit work; in real app, send to your memory service
        // After submit, clear the field
        noteText = ""
        isSubmitting = false
    }

    private func submitFiles() {
        guard !pickedFiles.isEmpty else { return }
        isSubmitting = true
        // Simulate submit; in real app, process the files and add to active memory
        // For demo, append file names to activeMemory (avoiding duplicates)
        let newNames = pickedFiles.map { $0.lastPathComponent }
        for name in newNames where !activeMemory.contains(name) {
            activeMemory.append(name)
        }
        pickedFiles.removeAll()
        isSubmitting = false
    }

    private func delete(item: String) {
        activeMemory.removeAll { $0 == item }
    }

    // MARK: - Helpers
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

    private func iconName(for url: URL) -> String {
        iconName(forFileName: url.lastPathComponent)
    }

    private func iconName(forFileName name: String) -> String {
        let ext = name.lowercased().split(separator: ".").last ?? ""
        switch ext {
        case "pdf": return "doc.richtext" // pdf icon alternative
        case "md": return "doc.text"      // markdown
        case "txt": return "note.text"
        default: return "doc"
        }
    }

    private func allowedTypes() -> [UTType] {
        // `.markdown` isn't available on older SDKs. Construct it via identifier or file extension.
        let markdownType = UTType("net.daringfireball.markdown") ?? UTType(filenameExtension: "md")
        return [
            .plainText,
            .pdf,
            markdownType
        ].compactMap { $0 }
    }
}
