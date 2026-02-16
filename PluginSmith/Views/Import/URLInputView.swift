import SwiftUI

struct URLInputView: View {
    @Binding var urlText: String
    let isFetching: Bool
    let onFetch: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "globe")
                .foregroundStyle(.secondary)

            TextField("Paste URL to API docs, README...", text: $urlText)
                .textFieldStyle(.plain)
                .onSubmit {
                    if isValidInput { onFetch() }
                }

            if isFetching {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button("Fetch") {
                    onFetch()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(!isValidInput)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        }
    }

    private var isValidInput: Bool {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && FileTypeDetector.isValidURL(trimmed)
    }
}
