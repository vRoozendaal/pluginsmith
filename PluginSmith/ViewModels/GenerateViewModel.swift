import Foundation
import AppKit
import SwiftUI

@MainActor @Observable
final class GenerateViewModel {
    var artifact: GeneratedArtifact?
    var selectedFile: GeneratedArtifact.GeneratedFile?
    var isGenerating = false
    var generationError: String?
    var installPath: URL?
    var showExportSuccess = false
    var lastExportedPluginURL: URL?

    private let generationService: PluginGenerationService
    private let installationService: InstallationService

    init(generationService: PluginGenerationService, installationService: InstallationService) {
        self.generationService = generationService
        self.installationService = installationService
    }

    var progress: Double { generationService.progress }
    var currentStep: String { generationService.currentStep }

    /// Whether we have a generated artifact to show (either fresh or from a previous generation)
    var hasArtifact: Bool { artifact != nil }

    @MainActor
    func generate(project: ForgeProject) async {
        isGenerating = true
        generationError = nil
        artifact = nil
        selectedFile = nil
        installPath = nil
        showExportSuccess = false
        lastExportedPluginURL = nil

        project.generationStatus = .generating

        do {
            let result = try await generationService.generate(project: project)
            artifact = result
            project.generatedArtifact = result
            project.generationStatus = .previewing

            // Auto-select the first non-directory file
            selectedFile = result.files.first { !$0.isDirectory }
        } catch {
            generationError = error.localizedDescription
            project.generationStatus = .failed
        }

        isGenerating = false
    }

    /// Restores a previously generated artifact from the project
    func restoreArtifact(from project: ForgeProject) {
        if artifact == nil, let savedArtifact = project.generatedArtifact {
            artifact = savedArtifact
            selectedFile = savedArtifact.files.first { !$0.isDirectory }
        }
    }

    func installToClaudePlugins(project: ForgeProject) throws {
        guard let artifact else { return }

        let path = try installationService.installPlugin(artifact: artifact, project: project)
        installPath = path
        project.generationStatus = .completed
        showExportSuccess = true
    }

    func exportToFolder(project: ForgeProject) {
        guard let artifact else { return }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.prompt = "Export Here"
        panel.message = "Choose a directory for your \(project.outputType.displayName.lowercased())"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let path = try installationService.export(artifact: artifact, to: url)
            installPath = path
            project.generationStatus = .completed
            showExportSuccess = true
        } catch {
            generationError = error.localizedDescription
        }
    }

    func exportAsPluginPackage() {
        guard let artifact else { return }

        do {
            if let savedURL = try installationService.exportAsPluginPackage(artifact: artifact) {
                lastExportedPluginURL = savedURL
                installPath = savedURL
                showExportSuccess = true
            }
        } catch {
            generationError = error.localizedDescription
        }
    }

    func backToPreview() {
        showExportSuccess = false
    }

    func revealInFinder() {
        guard let installPath else { return }
        installationService.revealInFinder(url: installPath)
    }

    func revealPluginPackage() {
        guard let lastExportedPluginURL else { return }
        installationService.revealInFinder(url: lastExportedPluginURL)
    }
}
