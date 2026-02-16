import Foundation

@Observable
final class PluginConfiguration: Codable {
    var keywords: [String]
    var commands: [CommandConfig]
    var skills: [SkillConfig]
    var agents: [AgentConfig]
    var hooks: HooksConfig?
    var mcpServers: [MCPServerConfig]

    init(
        keywords: [String] = [],
        commands: [CommandConfig] = [],
        skills: [SkillConfig] = [],
        agents: [AgentConfig] = [],
        hooks: HooksConfig? = nil,
        mcpServers: [MCPServerConfig] = []
    ) {
        self.keywords = keywords
        self.commands = commands
        self.skills = skills
        self.agents = agents
        self.hooks = hooks
        self.mcpServers = mcpServers
    }

    enum CodingKeys: String, CodingKey {
        case keywords, commands, skills, agents, hooks, mcpServers
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            keywords: try c.decode([String].self, forKey: .keywords),
            commands: try c.decode([CommandConfig].self, forKey: .commands),
            skills: try c.decode([SkillConfig].self, forKey: .skills),
            agents: try c.decode([AgentConfig].self, forKey: .agents),
            hooks: try c.decodeIfPresent(HooksConfig.self, forKey: .hooks),
            mcpServers: try c.decode([MCPServerConfig].self, forKey: .mcpServers)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(keywords, forKey: .keywords)
        try c.encode(commands, forKey: .commands)
        try c.encode(skills, forKey: .skills)
        try c.encode(agents, forKey: .agents)
        try c.encodeIfPresent(hooks, forKey: .hooks)
        try c.encode(mcpServers, forKey: .mcpServers)
    }
}

@Observable
final class CommandConfig: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var argumentHint: String
    var allowedTools: [String]
    var model: String?
    var instructionContent: String

    init(
        id: UUID = UUID(),
        name: String = "my-command",
        description: String = "",
        argumentHint: String = "",
        allowedTools: [String] = ["Read", "Glob", "Grep"],
        model: String? = nil,
        instructionContent: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.argumentHint = argumentHint
        self.allowedTools = allowedTools
        self.model = model
        self.instructionContent = instructionContent
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, argumentHint, allowedTools, model, instructionContent
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(UUID.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            description: try c.decode(String.self, forKey: .description),
            argumentHint: try c.decode(String.self, forKey: .argumentHint),
            allowedTools: try c.decode([String].self, forKey: .allowedTools),
            model: try c.decodeIfPresent(String.self, forKey: .model),
            instructionContent: try c.decode(String.self, forKey: .instructionContent)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(argumentHint, forKey: .argumentHint)
        try c.encode(allowedTools, forKey: .allowedTools)
        try c.encodeIfPresent(model, forKey: .model)
        try c.encode(instructionContent, forKey: .instructionContent)
    }
}

@Observable
final class SkillConfig: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var version: String
    var tools: [String]
    var instructionContent: String
    var references: [ReferenceFile]
    var examples: [ExampleFile]

    init(
        id: UUID = UUID(),
        name: String = "my-skill",
        description: String = "",
        version: String = "1.0.0",
        tools: [String] = [],
        instructionContent: String = "",
        references: [ReferenceFile] = [],
        examples: [ExampleFile] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.version = version
        self.tools = tools
        self.instructionContent = instructionContent
        self.references = references
        self.examples = examples
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, version, tools, instructionContent, references, examples
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(UUID.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            description: try c.decode(String.self, forKey: .description),
            version: try c.decode(String.self, forKey: .version),
            tools: try c.decode([String].self, forKey: .tools),
            instructionContent: try c.decode(String.self, forKey: .instructionContent),
            references: try c.decode([ReferenceFile].self, forKey: .references),
            examples: try c.decode([ExampleFile].self, forKey: .examples)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(version, forKey: .version)
        try c.encode(tools, forKey: .tools)
        try c.encode(instructionContent, forKey: .instructionContent)
        try c.encode(references, forKey: .references)
        try c.encode(examples, forKey: .examples)
    }

    static func `default`(name: String) -> SkillConfig {
        SkillConfig(name: name, description: "Use this skill when the user asks about \(name)")
    }
}

@Observable
final class AgentConfig: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var tools: [String]
    var model: String
    var color: String?
    var instructionContent: String

    init(
        id: UUID = UUID(),
        name: String = "my-agent",
        description: String = "",
        tools: [String] = ["Read", "Glob", "Grep", "Bash"],
        model: String = "sonnet",
        color: String? = nil,
        instructionContent: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tools = tools
        self.model = model
        self.color = color
        self.instructionContent = instructionContent
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, tools, model, color, instructionContent
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(UUID.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            description: try c.decode(String.self, forKey: .description),
            tools: try c.decode([String].self, forKey: .tools),
            model: try c.decode(String.self, forKey: .model),
            color: try c.decodeIfPresent(String.self, forKey: .color),
            instructionContent: try c.decode(String.self, forKey: .instructionContent)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(tools, forKey: .tools)
        try c.encode(model, forKey: .model)
        try c.encodeIfPresent(color, forKey: .color)
        try c.encode(instructionContent, forKey: .instructionContent)
    }
}

struct HooksConfig: Codable {
    var description: String
    var hooks: [HookEventConfig]

    init(description: String = "", hooks: [HookEventConfig] = []) {
        self.description = description
        self.hooks = hooks
    }
}

struct HookEventConfig: Identifiable, Codable {
    let id: UUID
    var event: HookEvent
    var matchers: [HookMatcher]

    init(id: UUID = UUID(), event: HookEvent = .preToolUse, matchers: [HookMatcher] = []) {
        self.id = id
        self.event = event
        self.matchers = matchers
    }

    enum HookEvent: String, CaseIterable, Sendable, Codable {
        case sessionStart = "SessionStart"
        case preToolUse = "PreToolUse"
        case postToolUse = "PostToolUse"
        case userPromptSubmit = "UserPromptSubmit"
        case stop = "Stop"
    }
}

struct HookMatcher: Identifiable, Codable {
    let id: UUID
    var toolName: String?
    var hooks: [HookAction]

    init(id: UUID = UUID(), toolName: String? = nil, hooks: [HookAction] = []) {
        self.id = id
        self.toolName = toolName
        self.hooks = hooks
    }
}

struct HookAction: Identifiable, Codable {
    let id: UUID
    var type: String
    var command: String
    var timeout: Int

    init(id: UUID = UUID(), type: String = "command", command: String = "", timeout: Int = 10) {
        self.id = id
        self.type = type
        self.command = command
        self.timeout = timeout
    }
}

struct MCPServerConfig: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: MCPType
    var url: String
    var command: String
    var args: [String]

    init(
        id: UUID = UUID(),
        name: String = "",
        type: MCPType = .http,
        url: String = "",
        command: String = "",
        args: [String] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.command = command
        self.args = args
    }

    enum MCPType: String, CaseIterable, Sendable, Codable {
        case http
        case stdio
    }
}

struct ReferenceFile: Identifiable, Codable {
    let id: UUID
    var fileName: String
    var content: String

    init(id: UUID = UUID(), fileName: String = "", content: String = "") {
        self.id = id
        self.fileName = fileName
        self.content = content
    }
}

struct ExampleFile: Identifiable, Codable {
    let id: UUID
    var fileName: String
    var content: String

    init(id: UUID = UUID(), fileName: String = "", content: String = "") {
        self.id = id
        self.fileName = fileName
        self.content = content
    }
}
