import Foundation
import Markdown

enum MarkdownDocumentParser {
    static func parse(url: URL) async throws -> SourceDocument {
        let content = try String(contentsOf: url, encoding: .utf8)
        let sections = extractSections(from: content)

        return SourceDocument(
            fileName: url.lastPathComponent,
            fileType: .markdown,
            originalURL: url,
            rawContent: content,
            sections: sections
        )
    }

    static func extractSections(from content: String) -> [ContentSection] {
        let document = Document(parsing: content)
        var walker = SectionExtractor()
        walker.visit(document)
        walker.flushCurrentSection()
        return walker.sections
    }
}

private struct SectionExtractor: MarkupWalker {
    var sections: [ContentSection] = []
    private var currentHeading: String = ""
    private var currentLevel: Int = 1
    private var currentContent: [String] = []
    private var hasStartedContent = false

    mutating func flushCurrentSection() {
        let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !content.isEmpty || hasStartedContent {
            let title = currentHeading.isEmpty ? "Introduction" : currentHeading
            sections.append(ContentSection(
                title: title,
                content: content,
                level: currentLevel,
                role: classifyTitle(title)
            ))
        }
    }

    mutating func visitHeading(_ heading: Heading) {
        flushCurrentSection()
        currentHeading = heading.plainText
        currentLevel = heading.level
        currentContent = []
        hasStartedContent = true
    }

    mutating func visitParagraph(_ paragraph: Paragraph) {
        currentContent.append(paragraph.plainText)
        hasStartedContent = true
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        let lang = codeBlock.language ?? ""
        currentContent.append("```\(lang)\n\(codeBlock.code)```")
        hasStartedContent = true
    }

    mutating func visitListItem(_ listItem: ListItem) {
        let text = listItem.plainText
        currentContent.append("- \(text)")
        hasStartedContent = true
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        let text = blockQuote.plainText
        currentContent.append("> \(text)")
        hasStartedContent = true
    }

    private func classifyTitle(_ title: String) -> ContentSection.SectionRole {
        let lower = title.lowercased()
        if lower.contains("overview") || lower.contains("introduction") { return .overview }
        if lower.contains("api") || lower.contains("endpoint") { return .apiReference }
        if lower.contains("example") || lower.contains("sample") { return .codeExample }
        if lower.contains("config") || lower.contains("setup") { return .configuration }
        if lower.contains("install") || lower.contains("getting started") { return .installation }
        if lower.contains("usage") || lower.contains("guide") { return .usage }
        if lower.contains("troubleshoot") || lower.contains("faq") { return .troubleshooting }
        return .other
    }
}

private extension Markup {
    var plainText: String {
        var result = ""
        for child in children {
            if let text = child as? Markdown.Text {
                result += text.string
            } else if let code = child as? InlineCode {
                result += "`\(code.code)`"
            } else if let soft = child as? SoftBreak {
                _ = soft
                result += " "
            } else if let line = child as? LineBreak {
                _ = line
                result += "\n"
            } else {
                result += child.plainText
            }
        }
        return result
    }
}
