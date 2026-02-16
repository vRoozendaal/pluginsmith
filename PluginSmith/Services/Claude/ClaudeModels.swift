import Foundation

struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

struct ClaudeResponse: Decodable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let usage: Usage

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }

    struct Usage: Decodable {
        let inputTokens: Int
        let outputTokens: Int

        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }
    }

    var textContent: String {
        content.compactMap(\.text).joined()
    }
}

struct ClaudeErrorResponse: Decodable {
    let type: String
    let error: ErrorDetail

    struct ErrorDetail: Decodable {
        let type: String
        let message: String
    }
}

enum ClaudeAPIError: LocalizedError {
    case notConfigured
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Claude API key not configured. Add your key in Settings."
        case .invalidResponse:
            return "Received an invalid response from the Claude API."
        case .httpError(let code, let message):
            if let message {
                return "API error (HTTP \(code)): \(message)"
            }
            return "API error (HTTP \(code))"
        case .decodingError(let error):
            return "Failed to parse API response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
