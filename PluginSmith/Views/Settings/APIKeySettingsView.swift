import SwiftUI

struct APIKeySettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var apiKeyInput = ""
    @State private var isTesting = false
    @State private var testResult: TestResult?

    enum TestResult {
        case success
        case failure(String)
    }

    var body: some View {
        Form {
            Section {
                SecureField("sk-ant-...", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)
                    .onAppear {
                        if let key = appState.claudeService.apiKey {
                            apiKeyInput = key
                        }
                    }

                HStack {
                    Button("Save") {
                        appState.claudeService.configure(apiKey: apiKeyInput)
                        testResult = nil
                    }
                    .disabled(apiKeyInput.isEmpty)

                    Button("Test Connection") {
                        Task { await testConnection() }
                    }
                    .disabled(apiKeyInput.isEmpty || isTesting)

                    if isTesting {
                        ProgressView()
                            .controlSize(.small)
                    }

                    if let testResult {
                        switch testResult {
                        case .success:
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        case .failure(let message):
                            Label(message, systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }

                    Spacer()

                    if appState.claudeService.isConfigured {
                        Button("Clear") {
                            appState.claudeService.clearKey()
                            apiKeyInput = ""
                            testResult = nil
                        }
                        .foregroundStyle(.red)
                    }
                }
            } header: {
                Text("Claude API Key")
            } footer: {
                Text("Your API key is stored securely in the macOS Keychain. Get your key at console.anthropic.com")
            }
        }
        .formStyle(.grouped)
    }

    private func testConnection() async {
        isTesting = true
        appState.claudeService.configure(apiKey: apiKeyInput)

        do {
            let success = try await appState.claudeService.testConnection()
            testResult = success ? .success : .failure("Unexpected response")
        } catch {
            testResult = .failure(error.localizedDescription)
        }

        isTesting = false
    }
}
