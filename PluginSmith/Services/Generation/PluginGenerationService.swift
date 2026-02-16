import Foundation

@MainActor @Observable
final class PluginGenerationService {
    private let claudeService: ClaudeAPIService
    var progress: Double = 0
    var currentStep: String = ""

    init(claudeService: ClaudeAPIService) {
        self.claudeService = claudeService
    }

    func generate(project: ForgeProject) async throws -> GeneratedArtifact {
        progress = 0
        currentStep = "Preparing..."

        switch project.outputType {
        case .plugin:
            return try await generatePlugin(project)
        case .skill:
            return try await generateStandaloneSkill(project)
        }
    }

    // MARK: - Plugin Generation

    private func generatePlugin(_ project: ForgeProject) async throws -> GeneratedArtifact {
        var files: [GeneratedArtifact.GeneratedFile] = []
        let config = project.pluginConfig
        let totalSteps = Double(1 + config.commands.count + config.skills.count + config.agents.count + 1)
        var completed = 0.0

        // 1. plugin.json
        currentStep = "Generating plugin.json..."
        let pluginJSON = TemplateEngine.renderPluginJSON(project: project)
        files.append(.init(relativePath: ".claude-plugin/plugin.json", content: pluginJSON))
        completed += 1
        progress = completed / totalSteps

        // 2. Commands
        for command in config.commands {
            currentStep = "Generating command: /\(command.name)..."
            let content: String
            if command.instructionContent.isEmpty {
                content = try await claudeService.generateCommandContent(
                    sources: project.sources,
                    config: command
                )
            } else {
                content = TemplateEngine.renderCommand(command)
            }
            files.append(.init(
                relativePath: "commands/\(command.name).md",
                content: content
            ))
            completed += 1
            progress = completed / totalSteps
        }

        // 3. Skills
        for skill in config.skills {
            currentStep = "Generating skill: \(skill.name)..."
            let content: String
            if skill.instructionContent.isEmpty {
                content = try await claudeService.generateSkillContent(
                    sources: project.sources,
                    config: skill
                )
            } else {
                content = TemplateEngine.renderSkill(skill)
            }
            files.append(.init(
                relativePath: "skills/\(skill.name)/SKILL.md",
                content: content
            ))

            // Add reference files
            for ref in skill.references {
                files.append(.init(
                    relativePath: "skills/\(skill.name)/references/\(ref.fileName)",
                    content: ref.content
                ))
            }

            // Add example files
            for example in skill.examples {
                files.append(.init(
                    relativePath: "skills/\(skill.name)/examples/\(example.fileName)",
                    content: example.content
                ))
            }

            completed += 1
            progress = completed / totalSteps
        }

        // 4. Agents
        for agent in config.agents {
            currentStep = "Generating agent: \(agent.name)..."
            let content: String
            if agent.instructionContent.isEmpty {
                content = try await claudeService.generateAgentContent(
                    sources: project.sources,
                    config: agent
                )
            } else {
                content = TemplateEngine.renderAgent(agent)
            }
            files.append(.init(
                relativePath: "agents/\(agent.name).md",
                content: content
            ))
            completed += 1
            progress = completed / totalSteps
        }

        // 5. Hooks
        if let hooks = config.hooks {
            currentStep = "Generating hooks..."
            let hooksJSON = TemplateEngine.renderHooksJSON(hooks)
            files.append(.init(relativePath: "hooks/hooks.json", content: hooksJSON))
        }

        // 6. MCP config
        if !config.mcpServers.isEmpty {
            currentStep = "Generating MCP config..."
            let mcpJSON = TemplateEngine.renderMCPJSON(config.mcpServers)
            files.append(.init(relativePath: ".mcp.json", content: mcpJSON))
        }

        // 7. README
        currentStep = "Generating README..."
        let readme = try await claudeService.generateReadme(project: project)
        files.append(.init(relativePath: "README.md", content: readme))
        completed += 1
        progress = 1.0

        currentStep = "Complete"

        return GeneratedArtifact(
            files: files,
            rootDirectoryName: project.name
        )
    }

    // MARK: - Standalone Skill Generation

    private func generateStandaloneSkill(_ project: ForgeProject) async throws -> GeneratedArtifact {
        var files: [GeneratedArtifact.GeneratedFile] = []
        progress = 0

        let skillConfig = project.pluginConfig.skills.first
            ?? SkillConfig.default(name: project.name)

        // 1. Generate SKILL.md
        currentStep = "Generating SKILL.md..."
        let skillContent: String
        if skillConfig.instructionContent.isEmpty {
            skillContent = try await claudeService.generateSkillContent(
                sources: project.sources,
                config: skillConfig
            )
        } else {
            skillContent = TemplateEngine.renderSkill(skillConfig)
        }

        files.append(.init(relativePath: "SKILL.md", content: skillContent))
        progress = 0.5

        // 2. Add source documents as references
        currentStep = "Adding reference files..."
        for source in project.sources {
            let refName: String
            if source.isWebResource {
                refName = NameFormatter.sanitizePluginName(source.fileName) + ".md"
            } else {
                refName = source.fileName
            }
            files.append(.init(
                relativePath: "references/\(refName)",
                content: source.rawContent
            ))
        }

        progress = 1.0
        currentStep = "Complete"

        return GeneratedArtifact(
            files: files,
            rootDirectoryName: project.name
        )
    }
}
