import SwiftUI

struct AIAssistPanel: View {
    @Environment(AppState.self) private var appState
    let viewModel: ConfigureViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("AI Assist", systemImage: "sparkles")
                    .font(.headline)

                Spacer()

                if viewModel.isAnalyzing {
                    LoadingDots()
                }
            }

            // Analyze button
            Button {
                Task {
                    await viewModel.analyzeSources(project: appState.currentProject)
                }
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text(viewModel.isAnalyzing ? "Analyzing..." : "Analyze Sources")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isAnalyzing || !appState.claudeService.isConfigured)

            if !appState.claudeService.isConfigured {
                Label("Set your API key in Settings", systemImage: "key")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            // Error
            if let error = viewModel.analysisError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 6).fill(.red.opacity(0.08)))
            }

            // Suggestions
            if !viewModel.suggestions.isEmpty {
                HStack {
                    Text("Suggestions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if viewModel.hasPendingSuggestions {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.acceptAllSuggestions(project: appState.currentProject)
                            }
                        } label: {
                            Text("Accept All")
                                .font(.caption2)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.mini)

                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.dismissAllSuggestions()
                            }
                        } label: {
                            Text("Dismiss All")
                                .font(.caption2)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                }

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.suggestions) { suggestion in
                            SuggestionCard(
                                suggestion: suggestion,
                                onAccept: {
                                    viewModel.applySuggestion(suggestion, to: appState.currentProject)
                                },
                                onDismiss: {
                                    viewModel.dismissSuggestion(suggestion)
                                }
                            )
                        }
                    }
                }
            } else if viewModel.isAnalyzing {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)

                    Text("Analyzing your sources…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Claude is reviewing your documents and will suggest plugin structure, commands, and skills.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                Spacer()
                EmptyStateView(
                    symbol: "sparkles",
                    title: "AI Analysis",
                    message: "Click Analyze to get suggestions for your plugin structure"
                )
                .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 280, idealWidth: 300, maxWidth: 340)
    }
}

private struct SuggestionCard: View {
    let suggestion: AISuggestion
    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: suggestion.type.sfSymbol)
                    .font(.caption)
                    .foregroundStyle(.tint)

                Text(suggestion.type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.tint)

                Spacer()

                if suggestion.isAccepted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Text(suggestion.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(suggestion.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if !suggestion.rationale.isEmpty {
                Text(suggestion.rationale)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .italic()
            }

            if !suggestion.isAccepted {
                HStack {
                    Button("Accept") { onAccept() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.mini)

                    Button("Dismiss") { onDismiss() }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(suggestion.isAccepted ? AnyShapeStyle(.green.opacity(0.05)) : AnyShapeStyle(.ultraThinMaterial))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            suggestion.isAccepted ? Color.green.opacity(0.3) : Color.secondary.opacity(0.2),
                            lineWidth: 0.5
                        )
                }
        }
    }
}
