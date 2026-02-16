import Foundation
import ZIPFoundation

enum DocxDocumentParser {
    static func parse(url: URL) async throws -> SourceDocument {
        let archive: Archive
        do {
            archive = try Archive(url: url, accessMode: .read)
        } catch {
            throw ParsingError.unreadableFile(url)
        }

        guard let documentEntry = archive["word/document.xml"] else {
            throw ParsingError.invalidDocxStructure
        }

        var xmlData = Data()
        _ = try archive.extract(documentEntry) { data in
            xmlData.append(data)
        }

        let parser = DocxXMLParser(data: xmlData)
        let result = try parser.parse()

        let sections = HeuristicSectionSplitter.split(result.text)

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .docx,
            originalURL: url,
            rawContent: result.text,
            sections: sections
        )
    }

    static func parseLegacyDoc(url: URL) async throws -> SourceDocument {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/textutil")
        process.arguments = ["-convert", "txt", "-stdout", url.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let text = String(data: data, encoding: .utf8),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParsingError.textExtractionFailed
        }

        let sections = HeuristicSectionSplitter.split(text)

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .doc,
            originalURL: url,
            rawContent: text,
            sections: sections
        )
    }
}
