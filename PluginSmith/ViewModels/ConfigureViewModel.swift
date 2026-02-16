import Foundation

@MainActor @Observable
final class ConfigureViewModel {
    var isAnalyzing = false
    var suggestions: [AISuggestion] = []
    var analysisError: String?

    private let claudeService: ClaudeAPIService

    init(claudeService: ClaudeAPIService) {
        self.claudeService = claudeService
    }

    @MainActor
    func analyzeSources(project: ForgeProject) async {
        guard claudeService.isConfigured else {
            analysisError = "Configure your Claude API key in Settings first."
            return
        }

        guard !project.sources.isEmpty else {
            analysisError = "Import at least one document first."
            return
        }

        isAnalyzing = true
        analysisError = nil
        suggestions = []

        do {
            let result = try await claudeService.analyzeSources(
                project.sources,
                outputType: project.outputType
            )
            suggestions = result
        } catch {
            analysisError = error.localizedDescription
        }

        isAnalyzing = false
    }

    func applySuggestion(_ suggestion: AISuggestion, to project: ForgeProject) {
        var updated = suggestion
        updated.isAccepted = true

        if let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) {
            suggestions[index] = updated
        }

        switch suggestion.type {
        case .command:
            let command = CommandConfig(
                name: suggestion.name,
                description: suggestion.description,
                allowedTools: suggestion.tools
            )
            project.pluginConfig.commands.append(command)

        case .skill:
            let skill = SkillConfig(
                name: suggestion.name,
                description: suggestion.description,
                tools: suggestion.tools
            )
            project.pluginConfig.skills.append(skill)

        case .agent:
            let agent = AgentConfig(
                name: suggestion.name,
                description: suggestion.description,
                tools: suggestion.tools
            )
            project.pluginConfig.agents.append(agent)

        case .reference:
            // Add as reference to the first skill, or create one
            if project.pluginConfig.skills.isEmpty {
                let skill = SkillConfig.default(name: project.name)
                project.pluginConfig.skills.append(skill)
            }
            if let firstSkill = project.pluginConfig.skills.first {
                firstSkill.references.append(ReferenceFile(
                    fileName: "\(suggestion.name).md",
                    content: suggestion.description
                ))
            }
        }
    }

    func dismissSuggestion(_ suggestion: AISuggestion) {
        suggestions.removeAll { $0.id == suggestion.id }
    }

    func acceptAllSuggestions(project: ForgeProject) {
        for suggestion in suggestions where !suggestion.isAccepted {
            applySuggestion(suggestion, to: project)
        }
    }

    func dismissAllSuggestions() {
        suggestions.removeAll { !$0.isAccepted }
    }

    var hasPendingSuggestions: Bool {
        suggestions.contains { !$0.isAccepted }
    }

    func addCommand(to project: ForgeProject) {
        project.pluginConfig.commands.append(CommandConfig())
    }

    func addSkill(to project: ForgeProject) {
        project.pluginConfig.skills.append(SkillConfig())
    }

    func addAgent(to project: ForgeProject) {
        project.pluginConfig.agents.append(AgentConfig())
    }

    func removeCommand(_ command: CommandConfig, from project: ForgeProject) {
        project.pluginConfig.commands.removeAll { $0.id == command.id }
    }

    func removeSkill(_ skill: SkillConfig, from project: ForgeProject) {
        project.pluginConfig.skills.removeAll { $0.id == skill.id }
    }

    func removeAgent(_ agent: AgentConfig, from project: ForgeProject) {
        project.pluginConfig.agents.removeAll { $0.id == agent.id }
    }

    func updateNameFromDisplayName(_ project: ForgeProject) {
        if !project.displayName.isEmpty {
            project.name = NameFormatter.sanitizePluginName(project.displayName)
        }
    }
}
