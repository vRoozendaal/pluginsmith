import SwiftUI

struct DocumentPreviewSheet: View {
    let document: SourceDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                DocumentTypeIcon(document.fileType, size: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(document.fileName)
                        .font(.headline)

                    HStack(spacing: 8) {
                        DocumentTypeBadge(type: document.fileType)
                        Text("\(document.sections.count) sections")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(document.rawContent.count) characters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding()

            Divider()

            // Content
            if document.sections.isEmpty {
                ScrollView {
                    Text(document.rawContent)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            } else {
                List(document.sections) { section in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(section.title)
                                .font(.headline)

                            Spacer()

                            Text(section.role.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.quaternary))
                                .foregroundStyle(.secondary)
                        }

                        Text(section.content.prefix(500) + (section.content.count > 500 ? "..." : ""))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(10)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
