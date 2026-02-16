import Foundation
import PDFKit

enum PDFDocumentParser {
    static func parse(url: URL) async throws -> SourceDocument {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw ParsingError.unreadableFile(url)
        }

        var fullText = ""

        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n\n"
            }
        }

        guard !fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParsingError.textExtractionFailed
        }

        let sections = HeuristicSectionSplitter.split(fullText)

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .pdf,
            originalURL: url,
            rawContent: fullText,
            sections: sections
        )
    }
}
