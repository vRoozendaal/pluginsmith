import SwiftUI

struct DocumentRowView: View {
    let document: SourceDocument
    let onRemove: () -> Void
    let onPreview: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            DocumentTypeIcon(document.fileType, size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    DocumentTypeBadge(type: document.fileType)

                    if document.isWebResource {
                        Image(systemName: "link")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Text("\(document.sections.count) sections")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Text("\(document.rawContent.count) chars")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button {
                onPreview()
            } label: {
                Image(systemName: "eye")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.background)
        }
    }
}
