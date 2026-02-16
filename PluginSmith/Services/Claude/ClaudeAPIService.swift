import Foundation

@MainActor @Observable
final class ClaudeAPIService {
    private static let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let apiVersion = "2023-06-01"
    private static let defaultModel = "claude-sonnet-4-5-20250929"
    private static let keychainKey = "claude-api-key"

    private(set) var apiKey: String?
    var isConfigured: Bool { apiKey != nil && !apiKey!.isEmpty }

    /// Dedicated URLSession with generous timeout for generation requests
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300   // 5 minutes per request
        config.timeoutIntervalForResource = 600  // 10 minutes total
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    init() {
        loadStoredKey()
    }

    func configure(apiKey: String) {
        self.apiKey = apiKey
        KeychainHelper.save(key: Self.keychainKey, value: apiKey)
    }

    func clearKey() {
        self.apiKey = nil
        KeychainHelper.delete(key: Self.keychainKey)
    }

    func loadStoredKey() {
        self.apiKey = KeychainHelper.load(key: Self.keychainKey)
    }

    // MARK: - Test Connection

    func testConnection() async throws -> Bool {
        let response = try await sendMessage(
            prompt: "Reply with exactly: ok",
            maxTokens: 10
        )
        return !response.isEmpty
    }

    // MARK: - Analysis

    func analyzeSources(
        _ sources: [SourceDocument],
        outputType: ForgeProject.OutputType
    ) async throws -> [AISuggestion] {
        let prompt = PromptBuilder.buildAnalysisPrompt(
            sources: sources,
            outputType: outputType
        )
        let response = try await sendMessage(prompt: prompt, maxTokens: 4096)
        return parseAnalysisResponse(response)
    }

    // MARK: - Content Generation

    func generateSkillContent(
        sources: [SourceDocument],
        config: SkillConfig
    ) async throws -> String {
        let prompt = PromptBuilder.buildSkillGenerationPrompt(
            sources: sources,
            config: config
        )
        return try await sendMessage(prompt: prompt, maxTokens: 8192)
    }

    func generateCommandContent(
        sources: [SourceDocument],
        config: CommandConfig
    ) async throws -> String {
        let prompt = PromptBuilder.buildCommandGenerationPrompt(
            sources: sources,
            config: config
        )
        return try await sendMessage(prompt: prompt, maxTokens: 4096)
    }

    func generateAgentContent(
        sources: [SourceDocument],
        config: AgentConfig
    ) async throws -> String {
        let prompt = PromptBuilder.buildAgentGenerationPrompt(
            sources: sources,
            config: config
        )
        return try await sendMessage(prompt: prompt, maxTokens: 4096)
    }

    func generateReadme(project: ForgeProject) async throws -> String {
        let prompt = PromptBuilder.buildReadmePrompt(project: project)
        return try await sendMessage(prompt: prompt, maxTokens: 4096)
    }

    // MARK: - API Communication

    private func sendMessage(
        prompt: String,
        maxTokens: Int,
        model: String = defaultModel,
        retries: Int = 2
    ) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else {
            throw ClaudeAPIError.notConfigured
        }

        var request = URLRequest(url: Self.baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.apiVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 300 // 5 minutes per request

        let body = ClaudeRequest(
            model: model,
            maxTokens: maxTokens,
            system: PromptBuilder.systemPrompt,
            messages: [
                ClaudeRequest.Message(role: "user", content: prompt)
            ]
        )

        request.httpBody = try JSONEncoder().encode(body)

        var lastError: Error?

        for attempt in 0...retries {
            if attempt > 0 {
                // Exponential backoff: 2s, 4s
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }

            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ClaudeAPIError.invalidResponse
                }

                // Retry on server errors (529 overloaded, 500, 502, 503)
                if [500, 502, 503, 529].contains(httpResponse.statusCode), attempt < retries {
                    lastError = ClaudeAPIError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: "Server error, retrying..."
                    )
                    continue
                }

                if httpResponse.statusCode != 200 {
                    let errorMessage: String?
                    if let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) {
                        errorMessage = errorResponse.error.message
                    } else {
                        errorMessage = String(data: data, encoding: .utf8)
                    }
                    throw ClaudeAPIError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: errorMessage
                    )
                }

                let result = try JSONDecoder().decode(ClaudeResponse.self, from: data)
                return result.textContent
            } catch let error as ClaudeAPIError {
                lastError = error
                // Only retry on network/server errors, not auth or decoding
                if case .networkError = error, attempt < retries {
                    continue
                }
                throw error
            } catch {
                lastError = error
                // Retry on URLError timeout/network issues
                if (error as? URLError)?.code == .timedOut || (error as? URLError)?.code == .networkConnectionLost,
                   attempt < retries {
                    continue
                }
                throw ClaudeAPIError.networkError(error)
            }
        }

        throw lastError ?? ClaudeAPIError.invalidResponse
    }

    // MARK: - Response Parsing

    private func parseAnalysisResponse(_ response: String) -> [AISuggestion] {
        // Try to extract JSON from the response (might be wrapped in markdown code blocks)
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip markdown code fences if present
        if jsonString.hasPrefix("```") {
            let lines = jsonString.components(separatedBy: .newlines)
            let filtered = lines.dropFirst().dropLast().joined(separator: "\n")
            jsonString = filtered
            // Handle ```json prefix
            if jsonString.hasPrefix("json") {
                jsonString = String(jsonString.dropFirst(4))
            }
        }

        guard let data = jsonString.data(using: .utf8) else {
            return []
        }

        do {
            let parsed = try JSONDecoder().decode(AISuggestionResponse.self, from: data)
            return parsed.toSuggestions()
        } catch {
            return []
        }
    }
}
