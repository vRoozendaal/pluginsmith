import Foundation
import SwiftUI

@MainActor @Observable
final class AppState {
    var currentPhase: WorkflowPhase = .import
    var currentProject: ForgeProject = ForgeProject()
    var currentProjectURL: URL?
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    var needsOnboarding: Bool {
        !hasCompletedOnboarding || !claudeService.isConfigured
    }

    /// Whether the current project has been modified since last save
    var projectDisplayTitle: String {
        if let url = currentProjectURL {
            return url.deletingPathExtension().lastPathComponent
        }
        return currentProject.displayName.isEmpty ? "Untitled" : currentProject.displayName
    }

    let parsingService: DocumentParsingService
    let claudeService: ClaudeAPIService
    let installationService: InstallationService
    let persistenceService: ProjectPersistenceService
    @ObservationIgnored private var _generationService: PluginGenerationService?

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.parsingService = DocumentParsingService()
        self.claudeService = ClaudeAPIService()
        self.installationService = InstallationService()
        self.persistenceService = ProjectPersistenceService()
        loadRecentProjects()
    }
    var generationService: PluginGenerationService {
        if let _generationService { return _generationService }
        let service = PluginGenerationService(claudeService: claudeService)
        _generationService = service
        return service
    }

    enum WorkflowPhase: Int, CaseIterable, Sendable {
        case `import` = 0
        case configure = 1
        case generate = 2

        var label: String {
            switch self {
            case .import: return "Import"
            case .configure: return "Configure"
            case .generate: return "Generate"
            }
        }

        var sfSymbol: String {
            switch self {
            case .import: return "arrow.down.doc"
            case .configure: return "slider.horizontal.3"
            case .generate: return "hammer"
            }
        }
    }

    func canAdvance(to phase: WorkflowPhase) -> Bool {
        switch phase {
        case .import:
            return true
        case .configure:
            return !currentProject.sources.isEmpty
        case .generate:
            return !currentProject.sources.isEmpty
                && !currentProject.name.isEmpty
                && !currentProject.description.isEmpty
                && claudeService.isConfigured
        }
    }

    func advanceToNext() {
        guard let nextIndex = WorkflowPhase(rawValue: currentPhase.rawValue + 1) else { return }
        if canAdvance(to: nextIndex) {
            currentPhase = nextIndex
        }
    }

    func goBack() {
        guard let prevIndex = WorkflowPhase(rawValue: currentPhase.rawValue - 1) else { return }
        currentPhase = prevIndex
    }

    func reset() {
        currentPhase = .import
        currentProject = ForgeProject()
        currentProjectURL = nil
    }

    // MARK: - Save / Load

    /// Auto-save the current project to the app's internal projects directory.
    /// This is called automatically after generation/export so the project appears
    /// in "Recent Projects" without requiring the user to manually ⌘S.
    func autoSaveProject() {
        // Only auto-save if the project has meaningful content
        guard !currentProject.name.isEmpty else { return }

        let projectsDir = Self.autoSaveDirectory
        let fm = FileManager.default

        // Create the auto-save directory if needed
        if !fm.fileExists(atPath: projectsDir.path) {
            try? fm.createDirectory(at: projectsDir, withIntermediateDirectories: true)
        }

        // Use a stable filename based on the project's UUID
        let fileName = "\(currentProject.id.uuidString).pluginsmith"
        let url = projectsDir.appendingPathComponent(fileName)

        do {
            currentProject.lastModifiedAt = Date()
            try persistenceService.saveProject(currentProject, to: url)

            // Track the URL so subsequent ⌘S saves to the same location
            if currentProjectURL == nil {
                currentProjectURL = url
            }

            addToRecentProjects(currentProjectURL ?? url)
        } catch {
            print("Auto-save failed: \(error.localizedDescription)")
        }
    }

    private static var autoSaveDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("PluginSmith/Projects", isDirectory: true)
    }

    func saveProject() {
        if let url = currentProjectURL {
            do {
                currentProject.lastModifiedAt = Date()
                try persistenceService.saveProject(currentProject, to: url)
                addToRecentProjects(url)
            } catch {
                print("Save failed: \(error.localizedDescription)")
            }
        } else {
            saveProjectAs()
        }
    }

    func saveProjectAs() {
        let suggestedName = currentProject.displayName.isEmpty
            ? currentProject.name
            : currentProject.displayName

        guard let url = persistenceService.savePanel(suggestedName: suggestedName) else { return }

        do {
            currentProject.lastModifiedAt = Date()
            try persistenceService.saveProject(currentProject, to: url)
            currentProjectURL = url
            addToRecentProjects(url)
        } catch {
            print("Save failed: \(error.localizedDescription)")
        }
    }

    func loadProject() {
        guard let url = persistenceService.openPanel() else { return }
        loadProject(from: url)
    }

    func loadProject(from url: URL) {
        do {
            let project = try persistenceService.loadProject(from: url)
            currentProject = project
            currentProjectURL = url
            addToRecentProjects(url)

            // Restore phase based on project state
            if project.generatedArtifact != nil {
                currentPhase = .generate
            } else if !project.name.isEmpty && !project.sources.isEmpty {
                currentPhase = .configure
            } else {
                currentPhase = .import
            }
        } catch {
            print("Load failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Recent Projects

    private static let recentProjectsKey = "recentProjectsMeta"
    private static let maxRecentProjects = 10

    var recentProjects: [RecentProjectInfo] = []

    func loadRecentProjects() {
        guard let data = UserDefaults.standard.data(forKey: Self.recentProjectsKey),
              let entries = try? JSONDecoder().decode([RecentProjectInfo].self, from: data) else {
            recentProjects = []
            return
        }
        recentProjects = entries.filter { FileManager.default.fileExists(atPath: $0.url.path) }
    }

    private func addToRecentProjects(_ url: URL) {
        var entries = recentProjects
        entries.removeAll { $0.url.path == url.path }

        let entry = RecentProjectInfo(
            url: url,
            displayName: currentProject.displayName.isEmpty ? currentProject.name : currentProject.displayName,
            outputType: currentProject.outputType.rawValue,
            lastModified: Date(),
            commandCount: currentProject.pluginConfig.commands.count,
            skillCount: currentProject.pluginConfig.skills.count,
            agentCount: currentProject.pluginConfig.agents.count,
            hasGeneratedArtifact: currentProject.generatedArtifact != nil
        )

        entries.insert(entry, at: 0)
        if entries.count > Self.maxRecentProjects {
            entries = Array(entries.prefix(Self.maxRecentProjects))
        }

        saveRecentProjects(entries)
    }

    func removeFromRecentProjects(_ url: URL) {
        var entries = recentProjects
        entries.removeAll { $0.url.path == url.path }
        saveRecentProjects(entries)
    }

    func clearRecentProjects() {
        UserDefaults.standard.removeObject(forKey: Self.recentProjectsKey)
        recentProjects = []
    }

    private func saveRecentProjects(_ entries: [RecentProjectInfo]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: Self.recentProjectsKey)
        }
        recentProjects = entries
    }
}

// MARK: - Recent Project Metadata

struct RecentProjectInfo: Identifiable, Codable {
    var id: String { url.path }
    let url: URL
    let displayName: String
    let outputType: String
    let lastModified: Date
    let commandCount: Int
    let skillCount: Int
    let agentCount: Int
    let hasGeneratedArtifact: Bool

    var typeDisplayName: String {
        outputType == "plugin" ? "Plugin" : "Skill"
    }

    var fileName: String {
        url.deletingPathExtension().lastPathComponent
    }

    var summary: String {
        if outputType == "plugin" {
            var parts: [String] = []
            if commandCount > 0 { parts.append("\(commandCount) cmd\(commandCount == 1 ? "" : "s")") }
            if skillCount > 0 { parts.append("\(skillCount) skill\(skillCount == 1 ? "" : "s")") }
            if agentCount > 0 { parts.append("\(agentCount) agent\(agentCount == 1 ? "" : "s")") }
            return parts.isEmpty ? "Plugin" : parts.joined(separator: " · ")
        }
        return "Skill"
    }
}
