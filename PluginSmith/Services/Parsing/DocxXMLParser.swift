import Foundation

final class DocxXMLParser: NSObject, XMLParserDelegate {
    struct Result {
        let text: String
    }

    private let data: Data
    private var paragraphs: [String] = []
    private var currentParagraph: String = ""
    private var insideText = false

    init(data: Data) {
        self.data = data
    }

    func parse() throws -> Result {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false

        guard parser.parse() else {
            throw ParsingError.invalidDocxStructure
        }

        let text = paragraphs.joined(separator: "\n\n")
        return Result(text: text)
    }

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let localName = elementName.components(separatedBy: ":").last ?? elementName

        switch localName {
        case "p":
            currentParagraph = ""
        case "t":
            insideText = true
        case "tab":
            currentParagraph += "\t"
        case "br":
            currentParagraph += "\n"
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let localName = elementName.components(separatedBy: ":").last ?? elementName

        switch localName {
        case "p":
            let trimmed = currentParagraph.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                paragraphs.append(trimmed)
            }
        case "t":
            insideText = false
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if insideText {
            currentParagraph += string
        }
    }
}
