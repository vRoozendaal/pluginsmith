import Foundation

@Observable
final class ForgeProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var displayName: String
    var description: String
    var version: String
    var author: AuthorInfo
    var outputType: OutputType
    var sources: [SourceDocument]
    var createdAt: Date
    var lastModifiedAt: Date
    var pluginConfig: PluginConfiguration
    var generationStatus: GenerationStatus
    var generatedArtifact: GeneratedArtifact?

    init(
        id: UUID = UUID(),
        name: String = "",
        displayName: String = "",
        description: String = "",
        version: String = "0.1.0",
        author: AuthorInfo = AuthorInfo(),
        outputType: OutputType = .plugin,
        sources: [SourceDocument] = [],
        createdAt: Date = Date(),
        lastModifiedAt: Date = Date(),
        pluginConfig: PluginConfiguration = PluginConfiguration(),
        generationStatus: GenerationStatus = .notStarted,
        generatedArtifact: GeneratedArtifact? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.version = version
        self.author = author
        self.outputType = outputType
        self.sources = sources
        self.createdAt = createdAt
        self.lastModifiedAt = lastModifiedAt
        self.pluginConfig = pluginConfig
        self.generationStatus = generationStatus
        self.generatedArtifact = generatedArtifact
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, displayName, description, version, author, outputType
        case sources, createdAt, lastModifiedAt, pluginConfig, generationStatus, generatedArtifact
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(UUID.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            displayName: try c.decode(String.self, forKey: .displayName),
            description: try c.decode(String.self, forKey: .description),
            version: try c.decode(String.self, forKey: .version),
            author: try c.decode(AuthorInfo.self, forKey: .author),
            outputType: try c.decode(OutputType.self, forKey: .outputType),
            sources: try c.decode([SourceDocument].self, forKey: .sources),
            createdAt: try c.decode(Date.self, forKey: .createdAt),
            lastModifiedAt: try c.decode(Date.self, forKey: .lastModifiedAt),
            pluginConfig: try c.decode(PluginConfiguration.self, forKey: .pluginConfig),
            generationStatus: try c.decode(GenerationStatus.self, forKey: .generationStatus),
            generatedArtifact: try c.decodeIfPresent(GeneratedArtifact.self, forKey: .generatedArtifact)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(displayName, forKey: .displayName)
        try c.encode(description, forKey: .description)
        try c.encode(version, forKey: .version)
        try c.encode(author, forKey: .author)
        try c.encode(outputType, forKey: .outputType)
        try c.encode(sources, forKey: .sources)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(lastModifiedAt, forKey: .lastModifiedAt)
        try c.encode(pluginConfig, forKey: .pluginConfig)
        try c.encode(generationStatus, forKey: .generationStatus)
        try c.encodeIfPresent(generatedArtifact, forKey: .generatedArtifact)
    }

    enum OutputType: String, CaseIterable, Sendable, Codable {
        case plugin
        case skill

        var displayName: String {
            switch self {
            case .plugin: return "Plugin"
            case .skill: return "Skill"
            }
        }

        var description: String {
            switch self {
            case .plugin: return "Full plugin with commands, skills, agents, and hooks"
            case .skill: return "Standalone skill with SKILL.md and references"
            }
        }
    }

    enum GenerationStatus: String, Sendable, Codable {
        case notStarted
        case analyzing
        case generating
        case previewing
        case completed
        case failed
    }
}

struct AuthorInfo: Codable {
    var name: String
    var email: String?
    var url: String?

    init(name: String = "", email: String? = nil, url: String? = nil) {
        self.name = name
        self.email = email
        self.url = url
    }
}
