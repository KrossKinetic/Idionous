import Foundation
import SwiftUI

struct OllamaModelList: Decodable {
    let models: [OllamaModel]
}

struct OllamaModel: Decodable, Hashable {
    let name: String
}

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    let role: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
}

struct ChatResponse: Decodable {
    let message: ChatMessage
}

final class LLMService {
    let baseURL: URL
    
    init(baseURL: URL = URL(string: "http://localhost:11434")!) {
        self.baseURL = baseURL
    }
    
    func fetchModels() async throws -> [String] {
        let url = baseURL.appendingPathComponent("/api/tags")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "LLMService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch models: HTTP \(httpResponse.statusCode)"])
        }
        
        let decoder = JSONDecoder()
        do {
            let modelList = try decoder.decode(OllamaModelList.self, from: data)
            return modelList.models.map { $0.name }
        } catch {
            throw NSError(domain: "LLMService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode models list: \(error.localizedDescription)"])
        }
    }
    
    func sendMessage(model: String, chatHistory: [ChatMessage]) async throws -> ChatMessage {
        let url = baseURL.appendingPathComponent("/api/chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(model: model, messages: chatHistory, stream: false)
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(chatRequest)
        } catch {
            throw NSError(domain: "LLMService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode chat request: \(error.localizedDescription)"])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "LLMService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to send message: HTTP \(httpResponse.statusCode)"])
        }
        
        let decoder = JSONDecoder()
        do {
            let chatResponse = try decoder.decode(ChatResponse.self, from: data)
            return chatResponse.message
        } catch {
            throw NSError(domain: "LLMService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode chat response: \(error.localizedDescription)"])
        }
    }
}

