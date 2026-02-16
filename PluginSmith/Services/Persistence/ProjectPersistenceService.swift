import Foundation
import AppKit
import UniformTypeIdentifiers

final class ProjectPersistenceService: Sendable {

    static let fileExtension = "pluginsmith"
    static let fileType = UTType(exportedAs: "com.pluginsmith.project", conformingTo: .json)

    // MARK: - Save

    func saveProject(_ project: ForgeProject, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(project)
        try data.write(to: url, options: .atomic)
    }

    // MARK: - Load

    func loadProject(from url: URL) throws -> ForgeProject {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ForgeProject.self, from: data)
    }

    // MARK: - Panels

    func savePanel(suggestedName: String) -> URL? {
        let panel = NSSavePanel()
        panel.title = "Save PluginSmith Project"
        panel.nameFieldStringValue = suggestedName.isEmpty
            ? "Untitled.\(Self.fileExtension)"
            : "\(suggestedName).\(Self.fileExtension)"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        // Ensure correct extension
        if url.pathExtension != Self.fileExtension {
            return url.deletingPathExtension().appendingPathExtension(Self.fileExtension)
        }
        return url
    }

    func openPanel() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Open PluginSmith Project"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]

        guard panel.runModal() == .OK else {
            return nil
        }
        return panel.url
    }
}
