import SwiftUI

struct MarkdownEditorView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat

    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "Enter content...",
        minHeight: CGFloat = 200
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(text.count) chars")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .font(.system(.body, design: .monospaced))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: minHeight)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator, lineWidth: 0.5)
                    }
            }
        }
    }
}
