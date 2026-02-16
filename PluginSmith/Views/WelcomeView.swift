import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @State private var apiKeyInput = ""
    @State private var isTesting = false
    @State private var testPassed = false
    @State private var errorMessage: String?
    @State private var currentStep: OnboardingStep = .welcome
    @FocusState private var isAPIKeyFieldFocused: Bool

    enum OnboardingStep {
        case welcome
        case apiKey
        case ready
    }

    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.04),
                    Color.clear,
                    Color.accentColor.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                switch currentStep {
                case .welcome:
                    welcomeStep
                case .apiKey:
                    apiKeyStep
                case .ready:
                    readyStep
                }

                Spacer()

                // Step indicators
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(stepIndex >= index ? Color.accentColor : Color.secondary.opacity(0.2))
                            .frame(width: stepIndex == index ? 24 : 8, height: 8)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                .padding(.bottom, 40)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            // App icon / hero
            VStack(spacing: 4) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.tint)
                    .symbolEffect(.breathe.pulse, options: .repeating)

                Text("PluginSmith")
                    .font(.system(size: 36, weight: .bold, design: .default))

                Text("Craft Claude Code plugins and skills\nfrom your documents")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Feature highlights
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "arrow.down.doc",
                    title: "Drop in documents",
                    description: ".md, .pdf, .docx, .txt, .xlsx and web URLs"
                )
                FeatureRow(
                    icon: "sparkles",
                    title: "AI-powered generation",
                    description: "Claude synthesizes your sources into ready-to-use plugins"
                )
                FeatureRow(
                    icon: "arrow.down.to.line",
                    title: "One-click install",
                    description: "Install directly to ~/.claude/ for immediate use"
                )
            }
            .frame(maxWidth: 380)

            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentStep = .apiKey
                }
            } label: {
                Text("Get Started")
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Step 2: API Key

    private var apiKeyStep: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(systemName: "key.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.tint)

                Text("Connect to Claude")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Enter your Anthropic API key to enable\nAI-powered plugin generation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                SecureField("sk-ant-api03-...", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
                    .focused($isAPIKeyFieldFocused)
                    .onAppear {
                        // Auto-focus after a short delay to let the view settle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAPIKeyFieldFocused = true
                        }
                    }
                    .onSubmit {
                        if !apiKeyInput.isEmpty { Task { await testAndSave() } }
                    }

                HStack(spacing: 12) {
                    Button {
                        Task { await testAndSave() }
                    } label: {
                        HStack(spacing: 6) {
                            if isTesting {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isTesting ? "Connecting..." : "Connect")
                        }
                        .frame(minWidth: 140)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty || isTesting)

                    if testPassed {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                            .transition(.opacity.combined(with: .scale))
                    }
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: 400)

            // Link to get API key
            Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                HStack(spacing: 4) {
                    Text("Get an API key")
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Step 3: Ready

    private var readyStep: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: currentStep)

                Text("You're all set")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("PluginSmith is ready to create\nyour first Claude Code plugin")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Quick guide
            VStack(alignment: .leading, spacing: 12) {
                QuickGuideRow(step: "1", text: "Drop in your documents and reference materials")
                QuickGuideRow(step: "2", text: "Configure the plugin structure and let AI assist")
                QuickGuideRow(step: "3", text: "Generate and install with one click")
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            }
            .frame(maxWidth: 380)

            Button {
                appState.hasCompletedOnboarding = true
            } label: {
                Text("Start Building")
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
    }

    // MARK: - Helpers

    private var stepIndex: Int {
        switch currentStep {
        case .welcome: return 0
        case .apiKey: return 1
        case .ready: return 2
        }
    }

    private func testAndSave() async {
        isTesting = true
        errorMessage = nil
        testPassed = false

        appState.claudeService.configure(apiKey: apiKeyInput)

        do {
            let success = try await appState.claudeService.testConnection()
            if success {
                withAnimation(.easeInOut(duration: 0.3)) {
                    testPassed = true
                }
                // Brief pause to show checkmark, then advance
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentStep = .ready
                }
            } else {
                errorMessage = "Connection test returned unexpected result"
            }
        } catch {
            errorMessage = error.localizedDescription
            appState.claudeService.clearKey()
        }

        isTesting = false
    }
}

// MARK: - Supporting Views

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct QuickGuideRow: View {
    let step: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(step)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 22, height: 22)
                .background(Circle().fill(.tint.opacity(0.12)))
                .foregroundStyle(.tint)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
