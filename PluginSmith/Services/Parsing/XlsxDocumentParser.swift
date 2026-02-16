import Foundation
import CoreXLSX

enum XlsxDocumentParser {
    static func parse(url: URL) async throws -> SourceDocument {
        let xlsxFile: XLSXFile
        do {
            guard let file = XLSXFile(filepath: url.path) else {
                throw ParsingError.unreadableFile(url)
            }
            xlsxFile = file
        }

        var allText = ""
        var sections: [ContentSection] = []

        let sharedStrings = try? xlsxFile.parseSharedStrings()

        for workbook in try xlsxFile.parseWorkbooks() {
            for (name, path) in try xlsxFile.parseWorksheetPathsAndNames(workbook: workbook) {
                let worksheet = try xlsxFile.parseWorksheet(at: path)
                let sheetName = name ?? "Sheet"
                var sheetText = "## \(sheetName)\n\n"

                if let rows = worksheet.data?.rows {
                    for (rowIndex, row) in rows.enumerated() {
                        let cells = row.cells.map { cell -> String in
                            if let shared = sharedStrings {
                                return cell.stringValue(shared) ?? cell.value ?? ""
                            }
                            return cell.value ?? ""
                        }

                        let rowText = "| " + cells.joined(separator: " | ") + " |"
                        sheetText += rowText + "\n"

                        // Add separator after header row
                        if rowIndex == 0 {
                            let separator = "| " + cells.map { _ in "---" }.joined(separator: " | ") + " |"
                            sheetText += separator + "\n"
                        }
                    }
                }

                allText += sheetText + "\n\n"
                sections.append(ContentSection(
                    title: sheetName,
                    content: sheetText,
                    level: 2,
                    role: .other
                ))
            }
        }

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .xlsx,
            originalURL: url,
            rawContent: allText,
            sections: sections
        )
    }
}
