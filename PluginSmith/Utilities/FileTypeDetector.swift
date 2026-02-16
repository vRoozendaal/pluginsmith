import Foundation
import UniformTypeIdentifiers

enum FileTypeDetector {
    static let supportedExtensions: Set<String> = [
        "md", "markdown", "txt", "pdf", "docx", "doc", "xlsx"
    ]

    static let supportedUTTypes: [UTType] = [
        .plainText,
        .pdf,
        UTType("net.daringfireball.markdown") ?? .plainText,
        UTType("org.openxmlformats.wordprocessingml.document") ?? .data,
        UTType("com.microsoft.word.doc") ?? .data,
        UTType("org.openxmlformats.spreadsheetml.sheet") ?? .data,
    ]

    static func documentType(for url: URL) -> SourceDocument.DocumentType? {
        SourceDocument.DocumentType(from: url)
    }

    static func isSupported(_ url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }

    static func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
}
