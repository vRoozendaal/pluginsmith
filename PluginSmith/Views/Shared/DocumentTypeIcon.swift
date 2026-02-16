import SwiftUI

struct DocumentTypeIcon: View {
    let type: SourceDocument.DocumentType
    let size: CGFloat

    init(_ type: SourceDocument.DocumentType, size: CGFloat = 24) {
        self.type = type
        self.size = size
    }

    var body: some View {
        Image(systemName: type.sfSymbol)
            .font(.system(size: size * 0.6))
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }

    private var color: Color {
        switch type {
        case .markdown: return .blue
        case .plainText: return .gray
        case .pdf: return .red
        case .docx, .doc: return .indigo
        case .xlsx: return .green
        case .webPage: return .orange
        }
    }
}

struct DocumentTypeBadge: View {
    let type: SourceDocument.DocumentType

    var body: some View {
        Text(type.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(color.opacity(0.12)))
            .foregroundStyle(color)
    }

    private var color: Color {
        switch type {
        case .markdown: return .blue
        case .plainText: return .gray
        case .pdf: return .red
        case .docx, .doc: return .indigo
        case .xlsx: return .green
        case .webPage: return .orange
        }
    }
}
