import Foundation
import UniformTypeIdentifiers

enum AppConstants {
    static let appName = "PluginSmith"
    static let bundleIdentifier = "com.pluginsmith.app"

    static let supportedExtensions: Set<String> = [
        "md", "markdown", "txt", "pdf", "docx", "doc", "xlsx"
    ]

    static let supportedContentTypes: [UTType] = [
        .plainText,
        .pdf,
        .data, // Fallback for Office formats
    ]

    static let defaultVersion = "0.1.0"

    static let availableTools: [String] = [
        "Read", "Write", "Edit", "Glob", "Grep", "Bash",
        "Task", "WebFetch", "WebSearch", "NotebookEdit"
    ]

    static let availableModels: [String] = [
        "sonnet", "haiku", "opus"
    ]

    static let agentColors: [String] = [
        "yellow", "blue", "green", "red", "purple", "orange", "cyan"
    ]

    enum Paths {
        static var home: URL {
            FileManager.default.homeDirectoryForCurrentUser
        }

        static var claudeDir: URL {
            home.appendingPathComponent(".claude")
        }

        static var pluginsDir: URL {
            claudeDir.appendingPathComponent("plugins")
        }

        static var localPluginsDir: URL {
            pluginsDir.appendingPathComponent("marketplaces/local-desktop-app-uploads/plugins")
        }
    }
}
