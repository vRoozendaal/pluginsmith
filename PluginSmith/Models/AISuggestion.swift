import Foundation

struct AISuggestion: Identifiable, Codable {
    let id: UUID
    var type: SuggestionType
    var name: String
    var description: String
    var tools: [String]
    var contentMapping: String
    var rationale: String
    var isAccepted: Bool

    init(
        id: UUID = UUID(),
        type: SuggestionType,
        name: String,
        description: String,
        tools: [String] = [],
        contentMapping: String = "",
        rationale: String = "",
        isAccepted: Bool = false
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.tools = tools
        self.contentMapping = contentMapping
        self.rationale = rationale
        self.isAccepted = isAccepted
    }

    enum SuggestionType: String, CaseIterable, Sendable, Codable {
        case skill
        case command
        case agent
        case reference

        var displayName: String {
            rawValue.capitalized
        }

        var sfSymbol: String {
            switch self {
            case .skill: return "brain"
            case .command: return "terminal"
            case .agent: return "person.circle"
            case .reference: return "book"
            }
        }
    }
}

struct AISuggestionResponse: Decodable {
    let suggestions: [SuggestionItem]

    struct SuggestionItem: Decodable {
        let type: String
        let name: String
        let description: String
        let tools: [String]?
        let contentMapping: String?
        let rationale: String?
    }

    func toSuggestions() -> [AISuggestion] {
        suggestions.compactMap { item in
            guard let type = AISuggestion.SuggestionType(rawValue: item.type) else {
                return nil
            }
            return AISuggestion(
                type: type,
                name: item.name,
                description: item.description,
                tools: item.tools ?? [],
                contentMapping: item.contentMapping ?? "",
                rationale: item.rationale ?? ""
            )
        }
    }
}
