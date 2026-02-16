import SwiftUI

struct OutputSettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section {
                LabeledContent("Claude Directory") {
                    HStack {
                        Text(appState.installationService.claudeDirectory.path)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)

                        Circle()
                            .fill(appState.installationService.claudeDirectoryExists ? .green : .red)
                            .frame(width: 8, height: 8)
                    }
                }

                LabeledContent("Plugins Directory") {
                    Text(appState.installationService.pluginsDirectory.path)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            } header: {
                Text("Default Paths")
            } footer: {
                Text("These paths are determined by your Claude Code installation. Plugins installed here will be automatically available in Claude Code.")
            }

            Section {
                LabeledContent("Default Version") {
                    Text(AppConstants.defaultVersion)
                        .font(.system(.body, design: .monospaced))
                }
            } header: {
                Text("Defaults")
            }
        }
        .formStyle(.grouped)
    }
}
