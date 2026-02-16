import SwiftUI

struct GeneratePhaseView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: GenerateViewModel?

    var body: some View {
        Group {
            if vm.showExportSuccess {
                ExportSuccessView(
                    installPath: vm.installPath,
                    lastPluginPackageURL: vm.lastExportedPluginURL,
                    onRevealInFinder: { vm.revealInFinder() },
                    onBackToPreview: { vm.backToPreview() },
                    onDownloadPlugin: { vm.exportAsPluginPackage() },
                    onNewProject: { appState.reset() }
                )
                .onAppear {
                    // Auto-save whenever we reach the success screen
                    appState.autoSaveProject()
                }
            } else if vm.isGenerating {
                GenerationProgressView(
                    progress: vm.progress,
                    currentStep: vm.currentStep
                )
            } else if let artifact = vm.artifact {
                previewView(artifact: artifact)
                    .onAppear {
                        // Auto-save when generation completes and preview appears
                        appState.autoSaveProject()
                    }
            } else {
                generatePromptView
            }
        }
        .onAppear {
            // Restore previously generated artifact if navigating back
            vm.restoreArtifact(from: appState.currentProject)
        }
    }

    @ViewBuilder
    private func previewView(artifact: GeneratedArtifact) -> some View {
        VStack(spacing: 0) {
            // Preview toolbar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Preview")
                        .font(.headline)

                    Text("\(artifact.files.count) files in \(artifact.rootDirectoryName)/")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                InstallOptionsView(viewModel: vm)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // File tree + content split
            HSplitView {
                FileTreePreviewView(
                    nodes: artifact.fileTree,
                    selectedFile: Binding(
                        get: { vm.selectedFile },
                        set: { vm.selectedFile = $0 }
                    )
                )
                .frame(minWidth: 220, idealWidth: 260, maxWidth: 320)

                FileContentPreviewView(file: vm.selectedFile)
            }
        }
    }

    @ViewBuilder
    private var generatePromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "hammer")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Ready to Generate")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("Claude will create your \(appState.currentProject.outputType.displayName.lowercased()) from the imported sources")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Summary
            VStack(alignment: .leading, spacing: 6) {
                summaryRow("Name", value: appState.currentProject.displayName)
                summaryRow("Type", value: appState.currentProject.outputType.displayName)
                summaryRow("Sources", value: "\(appState.currentProject.sources.count) documents")

                if appState.currentProject.outputType == .plugin {
                    let config = appState.currentProject.pluginConfig
                    summaryRow("Commands", value: "\(config.commands.count)")
                    summaryRow("Skills", value: "\(config.skills.count)")
                    summaryRow("Agents", value: "\(config.agents.count)")
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            }

            HStack(spacing: 12) {
                Button {
                    Task {
                        await vm.generate(project: appState.currentProject)
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate with Claude")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Show "View Previous" if a previous artifact exists
                if appState.currentProject.generatedArtifact != nil && vm.artifact == nil {
                    Button {
                        vm.restoreArtifact(from: appState.currentProject)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("View Previous")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }

            // Error
            if let error = vm.generationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 6).fill(.red.opacity(0.08)))
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private var vm: GenerateViewModel {
        if let viewModel { return viewModel }
        let newVM = GenerateViewModel(
            generationService: appState.generationService,
            installationService: appState.installationService
        )
        viewModel = newVM
        return newVM
    }
}
