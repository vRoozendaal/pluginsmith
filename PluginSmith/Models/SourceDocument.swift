import Foundation

@Observable
final class SourceDocument: Identifiable, Codable {
    let id: UUID
    var fileName: String
    var fileType: DocumentType
    var originalURL: URL?
    var importedAt: Date
    var rawContent: String
    var sections: [ContentSection]
    var isWebResource: Bool
    var sourceURL: String?

    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: DocumentType,
        originalURL: URL? = nil,
        importedAt: Date = Date(),
        rawContent: String,
        sections: [ContentSection] = [],
        isWebResource: Bool = false,
        sourceURL: String? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.originalURL = originalURL
        self.importedAt = importedAt
        self.rawContent = rawContent
        self.sections = sections
        self.isWebResource = isWebResource
        self.sourceURL = sourceURL
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, fileName, fileType, originalURL, importedAt, rawContent, sections, isWebResource, sourceURL
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let fileName = try container.decode(String.self, forKey: .fileName)
        let fileType = try container.decode(DocumentType.self, forKey: .fileType)
        let urlString = try container.decodeIfPresent(String.self, forKey: .originalURL)
        let originalURL = urlString.flatMap { URL(string: $0) }
        let importedAt = try container.decode(Date.self, forKey: .importedAt)
        let rawContent = try container.decode(String.self, forKey: .rawContent)
        let sections = try container.decode([ContentSection].self, forKey: .sections)
        let isWebResource = try container.decode(Bool.self, forKey: .isWebResource)
        let sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        self.init(
            id: id, fileName: fileName, fileType: fileType, originalURL: originalURL,
            importedAt: importedAt, rawContent: rawContent, sections: sections,
            isWebResource: isWebResource, sourceURL: sourceURL
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileType, forKey: .fileType)
        try container.encodeIfPresent(originalURL?.absoluteString, forKey: .originalURL)
        try container.encode(importedAt, forKey: .importedAt)
        try container.encode(rawContent, forKey: .rawContent)
        try container.encode(sections, forKey: .sections)
        try container.encode(isWebResource, forKey: .isWebResource)
        try container.encodeIfPresent(sourceURL, forKey: .sourceURL)
    }

    enum DocumentType: String, CaseIterable, Sendable, Codable {
        case markdown = "md"
        case plainText = "txt"
        case pdf = "pdf"
        case docx = "docx"
        case doc = "doc"
        case xlsx = "xlsx"
        case webPage = "html"

        var displayName: String {
            switch self {
            case .markdown: return "Markdown"
            case .plainText: return "Plain Text"
            case .pdf: return "PDF"
            case .docx: return "Word"
            case .doc: return "Word (Legacy)"
            case .xlsx: return "Excel"
            case .webPage: return "Web Page"
            }
        }

        var sfSymbol: String {
            switch self {
            case .markdown: return "doc.text"
            case .plainText: return "doc.plaintext"
            case .pdf: return "doc.richtext"
            case .docx, .doc: return "doc.fill"
            case .xlsx: return "tablecells"
            case .webPage: return "globe"
            }
        }

        init?(from url: URL) {
            switch url.pathExtension.lowercased() {
            case "md", "markdown": self = .markdown
            case "txt": self = .plainText
            case "pdf": self = .pdf
            case "docx": self = .docx
            case "doc": self = .doc
            case "xlsx": self = .xlsx
            case "html", "htm": self = .webPage
            default: return nil
            }
        }
    }
}

struct ContentSection: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var level: Int
    var role: SectionRole

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        level: Int = 1,
        role: SectionRole = .other
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.level = level
        self.role = role
    }

    enum SectionRole: String, CaseIterable, Sendable, Codable {
        case overview
        case apiReference
        case codeExample
        case configuration
        case installation
        case usage
        case troubleshooting
        case other
    }
}
