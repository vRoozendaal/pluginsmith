import SwiftUI

struct ConfigurePhaseView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ConfigureViewModel?

    var body: some View {
        HStack(spacing: 0) {
            // Main configuration area
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Configure")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Set up your \(appState.currentProject.outputType.displayName.lowercased()) structure")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // Output type picker
                    OutputTypePicker(outputType: Binding(
                        get: { appState.currentProject.outputType },
                        set: { appState.currentProject.outputType = $0 }
                    ))

                    // Metadata
                    MetadataFormView(
                        project: appState.currentProject,
                        onNameChange: { vm.updateNameFromDisplayName(appState.currentProject) }
                    )

                    // Type-specific configuration
                    switch appState.currentProject.outputType {
                    case .plugin:
                        PluginConfigView(
                            project: appState.currentProject,
                            viewModel: vm
                        )
                    case .skill:
                        skillConfigSection
                    }

                    // Generate button
                    if appState.canAdvance(to: .generate) {
                        Button {
                            withAnimation { appState.advanceToNext() }
                        } label: {
                            Label("Continue to Generate", systemImage: "arrow.right")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)
                    } else {
                        missingRequirementsView
                            .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // AI Assist sidebar
            AIAssistPanel(viewModel: vm)
                .frame(maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var skillConfigSection: some View {
        GlassSection("Skill Configuration") {
            VStack(alignment: .leading, spacing: 12) {
                let skill: SkillConfig = {
                    if let first = appState.currentProject.pluginConfig.skills.first {
                        return first
                    }
                    let newSkill = SkillConfig.default(name: appState.currentProject.name)
                    appState.currentProject.pluginConfig.skills.append(newSkill)
                    return newSkill
                }()

                SkillEditorView(skill: skill)
            }
        }
    }

    @ViewBuilder
    private var missingRequirementsView: some View {
        VStack(spacing: 8) {
            if appState.currentProject.name.isEmpty {
                Label("Enter a display name", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            if appState.currentProject.description.isEmpty {
                Label("Enter a description", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            if !appState.claudeService.isConfigured {
                Label("Configure Claude API key in Settings", systemImage: "key")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var vm: ConfigureViewModel {
        if let viewModel { return viewModel }
        let newVM = ConfigureViewModel(claudeService: appState.claudeService)
        viewModel = newVM
        return newVM
    }
}
