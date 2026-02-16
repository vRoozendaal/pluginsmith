import SwiftUI

struct FileContentPreviewView: View {
    let file: GeneratedArtifact.GeneratedFile?

    var body: some View {
        if let file {
            VStack(alignment: .leading, spacing: 0) {
                // File header
                HStack(spacing: 8) {
                    Image(systemName: file.sfSymbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(file.relativePath)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(file.content.count) chars")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(file.content, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help("Copy to clipboard")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)

                Divider()

                // File content
                ScrollView([.horizontal, .vertical]) {
                    Text(file.content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
        } else {
            EmptyStateView(
                symbol: "doc.text.magnifyingglass",
                title: "Select a file",
                message: "Click a file in the tree to preview its contents"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
