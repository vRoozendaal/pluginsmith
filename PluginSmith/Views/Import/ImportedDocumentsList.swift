import SwiftUI

struct ImportedDocumentsList: View {
    let documents: [SourceDocument]
    let onRemove: (SourceDocument) -> Void
    let onPreview: (SourceDocument) -> Void

    var body: some View {
        if documents.isEmpty {
            EmptyStateView(
                symbol: "doc.on.doc",
                title: "No documents yet",
                message: "Drop files above or paste a URL to get started"
            )
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Imported Documents")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(documents.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.quaternary))
                }

                VStack(spacing: 4) {
                    ForEach(documents) { doc in
                        DocumentRowView(
                            document: doc,
                            onRemove: { onRemove(doc) },
                            onPreview: { onPreview(doc) }
                        )
                    }
                }
            }
        }
    }
}
