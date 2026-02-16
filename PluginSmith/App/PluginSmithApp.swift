import SwiftUI

@main
struct PluginSmithApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .defaultSize(width: 1100, height: 740)
        .commands {
            // Replace the default File > New / Open menu items
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    appState.reset()
                }
                .keyboardShortcut("n")

                Button("Open Project…") {
                    appState.loadProject()
                }
                .keyboardShortcut("o")

                // Recent projects submenu
                if !appState.recentProjects.isEmpty {
                    Menu("Open Recent") {
                        ForEach(appState.recentProjects) { entry in
                            Button("\(entry.displayName.isEmpty ? entry.fileName : entry.displayName) — \(entry.typeDisplayName)") {
                                appState.loadProject(from: entry.url)
                            }
                        }

                        Divider()

                        Button("Clear Menu") {
                            appState.clearRecentProjects()
                        }
                    }
                }

                Divider()

                Button("Save Project") {
                    appState.saveProject()
                }
                .keyboardShortcut("s")

                Button("Save Project As…") {
                    appState.saveProjectAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
