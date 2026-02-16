import Foundation

enum HeuristicSectionSplitter {
    static func split(_ text: String) -> [ContentSection] {
        let lines = text.components(separatedBy: .newlines)
        var sections: [ContentSection] = []
        var currentTitle = "Introduction"
        var currentContent: [String] = []
        var currentLevel = 1

        for line in lines {
            if let heading = detectHeading(line) {
                if !currentContent.isEmpty {
                    let content = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        sections.append(ContentSection(
                            title: currentTitle,
                            content: content,
                            level: currentLevel,
                            role: classifySection(title: currentTitle)
                        ))
                    }
                }
                currentTitle = heading.title
                currentLevel = heading.level
                currentContent = []
            } else {
                currentContent.append(line)
            }
        }

        let remaining = currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !remaining.isEmpty {
            sections.append(ContentSection(
                title: currentTitle,
                content: remaining,
                level: currentLevel,
                role: classifySection(title: currentTitle)
            ))
        }

        if sections.isEmpty && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append(ContentSection(
                title: "Content",
                content: text.trimmingCharacters(in: .whitespacesAndNewlines),
                level: 1,
                role: .other
            ))
        }

        return sections
    }

    private struct DetectedHeading {
        let title: String
        let level: Int
    }

    private static func detectHeading(_ line: String) -> DetectedHeading? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Markdown-style headings
        if trimmed.hasPrefix("#") {
            let hashes = trimmed.prefix(while: { $0 == "#" })
            let level = min(hashes.count, 6)
            let title = String(trimmed.dropFirst(level)).trimmingCharacters(in: .whitespaces)
            if !title.isEmpty {
                return DetectedHeading(title: title, level: level)
            }
        }

        // ALL CAPS lines (likely headings in PDFs/docs)
        if trimmed.count >= 3 && trimmed.count <= 100 &&
           trimmed == trimmed.uppercased() &&
           trimmed.rangeOfCharacter(from: .letters) != nil &&
           !trimmed.contains("  ") {
            return DetectedHeading(title: trimmed.capitalized, level: 1)
        }

        // Numbered sections like "1. Overview" or "1.2 Setup"
        let numberedPattern = #"^(\d+\.)+\s+(.+)$"#
        if let match = trimmed.range(of: numberedPattern, options: .regularExpression) {
            let title = String(trimmed[match]).replacingOccurrences(
                of: #"^(\d+\.)+\s+"#,
                with: "",
                options: .regularExpression
            )
            let dots = trimmed.prefix(while: { $0.isNumber || $0 == "." })
            let level = dots.filter({ $0 == "." }).count
            return DetectedHeading(title: title, level: max(1, level))
        }

        return nil
    }

    private static func classifySection(title: String) -> ContentSection.SectionRole {
        let lower = title.lowercased()

        if lower.contains("overview") || lower.contains("introduction") || lower.contains("about") {
            return .overview
        }
        if lower.contains("api") || lower.contains("endpoint") || lower.contains("reference") {
            return .apiReference
        }
        if lower.contains("example") || lower.contains("sample") || lower.contains("demo") {
            return .codeExample
        }
        if lower.contains("config") || lower.contains("setup") || lower.contains("setting") {
            return .configuration
        }
        if lower.contains("install") || lower.contains("getting started") || lower.contains("prerequisite") {
            return .installation
        }
        if lower.contains("usage") || lower.contains("guide") || lower.contains("tutorial") || lower.contains("how to") {
            return .usage
        }
        if lower.contains("troubleshoot") || lower.contains("faq") || lower.contains("error") || lower.contains("debug") {
            return .troubleshooting
        }

        return .other
    }
}
