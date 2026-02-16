import SwiftUI

struct InstallOptionsView: View {
    @Environment(AppState.self) private var appState
    let viewModel: GenerateViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Install to Claude plugins
            if appState.installationService.claudeDirectoryExists {
                Button {
                    do {
                        try viewModel.installToClaudePlugins(project: appState.currentProject)
                        appState.autoSaveProject()
                    } catch {
                        viewModel.generationError = error.localizedDescription
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.to.line")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Install to Claude Code")
                                .fontWeight(.medium)
                            Text("~/.claude/plugins/")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            // Download as .plugin package
            Button {
                viewModel.exportAsPluginPackage()
                appState.autoSaveProject()
            } label: {
                HStack {
                    Image(systemName: "archivebox")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Download .plugin")
                            .fontWeight(.medium)
                        Text("Portable .plugin package")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            // Export to folder
            Button {
                viewModel.exportToFolder(project: appState.currentProject)
                appState.autoSaveProject()
            } label: {
                HStack {
                    Image(systemName: "folder")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Export to Folder")
                            .fontWeight(.medium)
                        Text("Choose a custom location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .frame(maxWidth: 340)
    }
}
