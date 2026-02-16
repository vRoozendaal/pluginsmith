import Foundation
import PDFKit

enum WebContentFetcher {
    static func fetch(urlString: String) async throws -> SourceDocument {
        guard let url = URL(string: urlString) else {
            throw ParsingError.invalidURL(urlString)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ParsingError.fetchFailed(urlString, httpResponse.statusCode)
        }

        // Determine content type from the HTTP header and/or URL extension
        let contentType = (response as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
        let ext = url.pathExtension.lowercased()

        // Route to the correct parser based on content type
        if contentType.contains("application/pdf") || ext == "pdf" {
            return try await parsePDFData(data, urlString: urlString, url: url)
        }

        if ext == "docx" || contentType.contains("wordprocessingml") ||
           contentType.contains("application/vnd.openxmlformats") {
            return try await parseBinaryDocument(data, ext: "docx", urlString: urlString, url: url)
        }

        if ext == "doc" || contentType.contains("application/msword") {
            return try await parseBinaryDocument(data, ext: "doc", urlString: urlString, url: url)
        }

        if ext == "xlsx" || contentType.contains("spreadsheetml") {
            return try await parseBinaryDocument(data, ext: "xlsx", urlString: urlString, url: url)
        }

        if ext == "md" || ext == "markdown" || contentType.contains("text/markdown") {
            return try parseTextDocument(data, ext: "md", urlString: urlString, url: url)
        }

        if ext == "txt" || contentType.hasPrefix("text/plain") {
            return try parseTextDocument(data, ext: "txt", urlString: urlString, url: url)
        }

        // Default: treat as HTML web page
        return try parseAsHTML(data, urlString: urlString, url: url)
    }

    // MARK: - PDF

    private static func parsePDFData(_ data: Data, urlString: String, url: URL) async throws -> SourceDocument {
        // PDFKit can open from Data directly
        guard let pdfDocument = PDFDocument(data: data) else {
            throw ParsingError.textExtractionFailed
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
        let displayName = url.lastPathComponent.isEmpty ? (url.host ?? urlString) : url.lastPathComponent

        return SourceDocument(
            fileName: displayName,
            fileType: .pdf,
            rawContent: fullText,
            sections: sections,
            isWebResource: true,
            sourceURL: urlString
        )
    }

    // MARK: - Binary documents (docx, doc, xlsx)

    private static func parseBinaryDocument(_ data: Data, ext: String, urlString: String, url: URL) async throws -> SourceDocument {
        // Write to a temp file so the existing parsers can read it
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString + "." + ext)

        try data.write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        // Use the existing file-based parsers
        guard let fileType = SourceDocument.DocumentType(from: tempFile) else {
            throw ParsingError.unsupportedFileType(ext)
        }

        var doc: SourceDocument
        switch fileType {
        case .docx:
            doc = try await DocxDocumentParser.parse(url: tempFile)
        case .doc:
            doc = try await DocxDocumentParser.parseLegacyDoc(url: tempFile)
        case .xlsx:
            doc = try await XlsxDocumentParser.parse(url: tempFile)
        default:
            throw ParsingError.unsupportedFileType(ext)
        }

        // Override metadata to reflect the web source
        let displayName = url.lastPathComponent.isEmpty ? (url.host ?? urlString) : url.lastPathComponent
        doc.fileName = displayName
        doc.isWebResource = true
        doc.sourceURL = urlString

        return doc
    }

    // MARK: - Text documents (md, txt)

    private static func parseTextDocument(_ data: Data, ext: String, urlString: String, url: URL) throws -> SourceDocument {
        let text = String(data: data, encoding: .utf8) ?? ""

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParsingError.textExtractionFailed
        }

        let sections = HeuristicSectionSplitter.split(text)
        let displayName = url.lastPathComponent.isEmpty ? (url.host ?? urlString) : url.lastPathComponent
        let fileType: SourceDocument.DocumentType = (ext == "md" || ext == "markdown") ? .markdown : .plainText

        return SourceDocument(
            fileName: displayName,
            fileType: fileType,
            rawContent: text,
            sections: sections,
            isWebResource: true,
            sourceURL: urlString
        )
    }

    // MARK: - HTML (default web page)

    private static func parseAsHTML(_ data: Data, urlString: String, url: URL) throws -> SourceDocument {
        let html = String(data: data, encoding: .utf8) ?? ""
        let plainText = stripHTML(html)

        guard !plainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParsingError.textExtractionFailed
        }

        let sections = HeuristicSectionSplitter.split(plainText)
        let displayName = url.host ?? url.absoluteString

        return SourceDocument(
            fileName: displayName,
            fileType: .webPage,
            rawContent: plainText,
            sections: sections,
            isWebResource: true,
            sourceURL: urlString
        )
    }

    // MARK: - HTML Stripping

    private static func stripHTML(_ html: String) -> String {
        // Remove script and style blocks entirely
        var text = html
        text = text.replacingOccurrences(
            of: "<script[^>]*>[\\s\\S]*?</script>",
            with: "",
            options: .regularExpression
        )
        text = text.replacingOccurrences(
            of: "<style[^>]*>[\\s\\S]*?</style>",
            with: "",
            options: .regularExpression
        )

        // Replace block-level tags with newlines
        let blockTags = ["p", "div", "br", "h1", "h2", "h3", "h4", "h5", "h6",
                         "li", "tr", "td", "th", "blockquote", "pre", "hr"]
        for tag in blockTags {
            text = text.replacingOccurrences(
                of: "</?\\s*\(tag)[^>]*>",
                with: "\n",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        // Remove remaining tags
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        // Decode common HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")

        // Collapse multiple blank lines
        text = text.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
