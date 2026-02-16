import Foundation

enum PlainTextDocumentParser {
    static func parse(url: URL) async throws -> SourceDocument {
        let content = try String(contentsOf: url, encoding: .utf8)
        let sections = HeuristicSectionSplitter.split(content)

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .plainText,
            originalURL: url,
            rawContent: content,
            sections: sections
        )
    }
}
