import Foundation

enum NameFormatter {
    static func toKebabCase(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        var result = ""
        var previousWasHyphen = false

        for char in trimmed {
            if char.isLetter || char.isNumber {
                if char.isUppercase && !result.isEmpty && !previousWasHyphen {
                    result += "-"
                }
                result += String(char).lowercased()
                previousWasHyphen = false
            } else if char == " " || char == "_" || char == "-" {
                if !result.isEmpty && !previousWasHyphen {
                    result += "-"
                    previousWasHyphen = true
                }
            }
        }

        return result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    static func toDisplayName(_ kebabCase: String) -> String {
        kebabCase
            .split(separator: "-")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    static func sanitizePluginName(_ input: String) -> String {
        let kebab = toKebabCase(input)
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return String(kebab.unicodeScalars.filter { allowed.contains($0) })
    }
}
