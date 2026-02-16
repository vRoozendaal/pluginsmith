import Foundation

enum ParsingError: LocalizedError {
    case unsupportedFileType(String)
    case unreadableFile(URL)
    case invalidDocxStructure
    case invalidURL(String)
    case fetchFailed(String, Int?)
    case textExtractionFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            return "Unsupported file type: .\(ext)"
        case .unreadableFile(let url):
            return "Cannot read file: \(url.lastPathComponent)"
        case .invalidDocxStructure:
            return "Invalid .docx file structure"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .fetchFailed(let url, let code):
            if let code {
                return "Failed to fetch \(url) (HTTP \(code))"
            }
            return "Failed to fetch \(url)"
        case .textExtractionFailed:
            return "Could not extract text from document"
        }
    }
}

final class DocumentParsingService: Sendable {
    func parse(url: URL) async throws -> SourceDocument {
        guard let fileType = SourceDocument.DocumentType(from: url) else {
            throw ParsingError.unsupportedFileType(url.pathExtension)
        }

        switch fileType {
        case .markdown:
            return try await MarkdownDocumentParser.parse(url: url)
        case .plainText:
            return try await PlainTextDocumentParser.parse(url: url)
        case .pdf:
            return try await PDFDocumentParser.parse(url: url)
        case .docx:
            return try await DocxDocumentParser.parse(url: url)
        case .doc:
            return try await DocxDocumentParser.parseLegacyDoc(url: url)
        case .xlsx:
            return try await XlsxDocumentParser.parse(url: url)
        case .webPage:
            throw ParsingError.unsupportedFileType("html")
        }
    }

    func parseFromURL(urlString: String) async throws -> SourceDocument {
        try await WebContentFetcher.fetch(urlString: urlString)
    }
}
