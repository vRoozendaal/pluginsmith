import Foundation

enum TemplateEngine {
    // MARK: - Plugin JSON

    static func renderPluginJSON(project: ForgeProject) -> String {
        let pluginMeta = PluginJSON(
            name: project.name,
            description: project.description,
            version: project.version,
            author: PluginJSON.Author(
                name: project.author.name,
                email: project.author.email,
                url: project.author.url
            ),
            keywords: project.pluginConfig.keywords.isEmpty ? nil : project.pluginConfig.keywords
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(pluginMeta),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        return json + "\n"
    }

    // MARK: - Command Markdown

    static func renderCommand(_ command: CommandConfig) -> String {
        var lines: [String] = ["---"]
        lines.append("description: \(command.description)")

        if !command.argumentHint.isEmpty {
            lines.append("argument-hint: \(command.argumentHint)")
        }
        if !command.allowedTools.isEmpty {
            lines.append("allowed-tools: [\(command.allowedTools.joined(separator: ", "))]")
        }
        if let model = command.model, !model.isEmpty {
            lines.append("model: \(model)")
        }

        lines.append("---")
        lines.append("")
        lines.append(command.instructionContent)

        return lines.joined(separator: "\n")
    }

    // MARK: - Skill Markdown

    static func renderSkill(_ skill: SkillConfig) -> String {
        var lines: [String] = ["---"]
        lines.append("name: \(skill.name)")
        lines.append("description: \(skill.description)")

        if !skill.version.isEmpty {
            lines.append("version: \(skill.version)")
        }
        if !skill.tools.isEmpty {
            lines.append("tools: \(skill.tools.joined(separator: ", "))")
        }

        lines.append("---")
        lines.append("")
        lines.append(skill.instructionContent)

        return lines.joined(separator: "\n")
    }

    // MARK: - Agent Markdown

    static func renderAgent(_ agent: AgentConfig) -> String {
        var lines: [String] = ["---"]
        lines.append("name: \(agent.name)")
        lines.append("description: \(agent.description)")
        lines.append("tools: \(agent.tools.joined(separator: ", "))")
        lines.append("model: \(agent.model)")

        if let color = agent.color, !color.isEmpty {
            lines.append("color: \(color)")
        }

        lines.append("---")
        lines.append("")
        lines.append(agent.instructionContent)

        return lines.joined(separator: "\n")
    }

    // MARK: - Hooks JSON

    static func renderHooksJSON(_ hooks: HooksConfig) -> String {
        var hooksDict: [String: Any] = [:]

        if !hooks.description.isEmpty {
            hooksDict["description"] = hooks.description
        }

        var eventsDict: [String: [[String: Any]]] = [:]

        for eventConfig in hooks.hooks {
            var matchersList: [[String: Any]] = []

            for matcher in eventConfig.matchers {
                var matcherDict: [String: Any] = [:]

                if let toolName = matcher.toolName, !toolName.isEmpty {
                    matcherDict["tool_name"] = toolName
                }

                let hookActions: [[String: Any]] = matcher.hooks.map { action in
                    var dict: [String: Any] = [
                        "type": action.type,
                        "command": action.command,
                    ]
                    if action.timeout != 10 {
                        dict["timeout"] = action.timeout
                    }
                    return dict
                }

                matcherDict["hooks"] = hookActions
                matchersList.append(matcherDict)
            }

            eventsDict[eventConfig.event.rawValue] = matchersList
        }

        hooksDict["hooks"] = eventsDict

        guard let data = try? JSONSerialization.data(
            withJSONObject: hooksDict,
            options: [.prettyPrinted, .sortedKeys]
        ),
        let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        return json + "\n"
    }

    // MARK: - MCP JSON

    static func renderMCPJSON(_ servers: [MCPServerConfig]) -> String {
        var dict: [String: Any] = [:]

        for server in servers where !server.name.isEmpty {
            var serverDict: [String: Any] = ["type": server.type.rawValue]

            switch server.type {
            case .http:
                if !server.url.isEmpty {
                    serverDict["url"] = server.url
                }
            case .stdio:
                if !server.command.isEmpty {
                    serverDict["command"] = server.command
                }
                if !server.args.isEmpty {
                    serverDict["args"] = server.args
                }
            }

            dict[server.name] = serverDict
        }

        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys]
        ),
        let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        return json + "\n"
    }
}
