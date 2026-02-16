import SwiftUI

struct PluginConfigView: View {
    @Bindable var project: ForgeProject
    let viewModel: ConfigureViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Keywords
            TagInputView(
                "Keywords",
                tags: $project.pluginConfig.keywords,
                suggestions: []
            )

            Divider()

            // Commands
            CommandsListView(
                commands: project.pluginConfig.commands,
                onAdd: { viewModel.addCommand(to: project) },
                onRemove: { viewModel.removeCommand($0, from: project) }
            )

            Divider()

            // Skills
            SkillsListView(
                skills: project.pluginConfig.skills,
                onAdd: { viewModel.addSkill(to: project) },
                onRemove: { viewModel.removeSkill($0, from: project) }
            )

            Divider()

            // Agents
            AgentsListView(
                agents: project.pluginConfig.agents,
                onAdd: { viewModel.addAgent(to: project) },
                onRemove: { viewModel.removeAgent($0, from: project) }
            )

            Divider()

            // Hooks
            HooksConfigView(project: project)
        }
    }
}
