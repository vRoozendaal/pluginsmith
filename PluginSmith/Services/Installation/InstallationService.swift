import Foundation
import AppKit
import ZIPFoundation

enum InstallationError: LocalizedError {
    case directoryCreationFailed(URL)
    case fileWriteFailed(String)
    case manifestUpdateFailed(Error)
    case zipCreationFailed(String)

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed(let url):
            return "Failed to create directory: \(url.path)"
        case .fileWriteFailed(let path):
            return "Failed to write file: \(path)"
        case .manifestUpdateFailed(let error):
            return "Failed to update marketplace manifest: \(error.localizedDescription)"
        case .zipCreationFailed(let message):
            return "Failed to create .plugin package: \(message)"
        }
    }
}

final class InstallationService: Sendable {
    private var homeDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
    }

    var claudeDirectory: URL {
        homeDirectory.appendingPathComponent(".claude")
    }

    var pluginsDirectory: URL {
        claudeDirectory.appendingPathComponent("plugins/marketplaces/local-desktop-app-uploads/plugins")
    }

    var localMarketplacePath: URL {
        claudeDirectory.appendingPathComponent(
            "plugins/marketplaces/local-desktop-app-uploads"
        )
    }

    var claudeDirectoryExists: Bool {
        FileManager.default.fileExists(atPath: claudeDirectory.path)
    }

    // MARK: - Install Plugin

    func installPlugin(
        artifact: GeneratedArtifact,
        project: ForgeProject
    ) throws -> URL {
        let targetDir = pluginsDirectory.appendingPathComponent(artifact.rootDirectoryName)
        try writeArtifact(artifact, to: targetDir)
        return targetDir
    }

    // MARK: - Export to Custom Location

    func export(
        artifact: GeneratedArtifact,
        to directory: URL
    ) throws -> URL {
        let targetDir = directory.appendingPathComponent(artifact.rootDirectoryName)
        try writeArtifact(artifact, to: targetDir)
        return targetDir
    }

    // MARK: - File Writing

    private func writeArtifact(
        _ artifact: GeneratedArtifact,
        to baseDirectory: URL
    ) throws {
        let fm = FileManager.default

        // Remove existing if present
        if fm.fileExists(atPath: baseDirectory.path) {
            try fm.removeItem(at: baseDirectory)
        }

        // Create base directory
        try fm.createDirectory(at: baseDirectory, withIntermediateDirectories: true)

        for file in artifact.files {
            let filePath = baseDirectory.appendingPathComponent(file.relativePath)
            let parentDir = filePath.deletingLastPathComponent()

            // Create parent directories
            if !fm.fileExists(atPath: parentDir.path) {
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }

            if !file.isDirectory {
                try file.content.write(to: filePath, atomically: true, encoding: .utf8)
            }
        }
    }

    // MARK: - Export as .plugin Package (ZIP)

    /// Packages the artifact as a .plugin file (ZIP with .plugin extension).
    /// Shows an NSSavePanel for the user to choose the save location.
    /// Returns the URL of the saved file, or nil if the user cancelled.
    func exportAsPluginPackage(artifact: GeneratedArtifact) throws -> URL? {
        let panel = NSSavePanel()
        panel.title = "Save Plugin Package"
        panel.nameFieldStringValue = "\(artifact.rootDirectoryName).plugin"
        panel.allowedContentTypes = [.data]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false

        guard panel.runModal() == .OK, let saveURL = panel.url else {
            return nil
        }

        // Ensure the file has .plugin extension
        let finalURL: URL
        if saveURL.pathExtension != "plugin" {
            finalURL = saveURL.appendingPathExtension("plugin")
        } else {
            finalURL = saveURL
        }

        // Remove existing file if present
        let fm = FileManager.default
        if fm.fileExists(atPath: finalURL.path) {
            try fm.removeItem(at: finalURL)
        }

        // Write artifact to a temp directory first, then zip it
        let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let artifactDir = tempDir.appendingPathComponent(artifact.rootDirectoryName)

        defer { try? fm.removeItem(at: tempDir) }

        try writeArtifact(artifact, to: artifactDir)

        // Create ZIP archive with .plugin extension
        try fm.zipItem(at: artifactDir, to: finalURL, shouldKeepParent: true)

        return finalURL
    }

    // MARK: - Reveal in Finder

    func revealInFinder(url: URL) {
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
}
