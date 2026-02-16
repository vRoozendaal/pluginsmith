import SwiftUI

struct ProjectSidebar: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Current project info
            VStack(alignment: .leading, spacing: 8) {
                Label("Current Project", systemImage: "hammer.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if appState.currentProject.name.isEmpty {
                    Text("New Project")
                        .font(.headline)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(appState.currentProject.displayName.isEmpty
                         ? appState.currentProject.name
                         : appState.currentProject.displayName)
                        .font(.headline)

                    if !appState.currentProject.description.isEmpty {
                        Text(appState.currentProject.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding()

            Divider()

            // Phase navigation
            VStack(spacing: 2) {
                ForEach(AppState.WorkflowPhase.allCases, id: \.self) { phase in
                    SidebarPhaseRow(
                        phase: phase,
                        isCurrent: appState.currentPhase == phase,
                        isAccessible: appState.canAdvance(to: phase)
                    )
                    .onTapGesture {
                        if appState.canAdvance(to: phase) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appState.currentPhase = phase
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            // Recent Projects
            if !appState.recentProjects.isEmpty {
                Divider()
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Recent Projects")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            appState.clearRecentProjects()
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Clear all recent projects")
                    }
                    .padding(.horizontal, 4)

                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(appState.recentProjects) { entry in
                                RecentProjectRow(
                                    entry: entry,
                                    isActive: appState.currentProjectURL?.path == entry.url.path
                                )
                                .onTapGesture {
                                    if appState.currentProjectURL?.path != entry.url.path {
                                        appState.loadProject(from: entry.url)
                                    }
                                }
                                .contextMenu {
                                    Button("Remove from Recent Projects", role: .destructive) {
                                        appState.removeFromRecentProjects(entry.url)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }

            Spacer()

            Divider()

            // Status bar
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(appState.claudeService.isConfigured ? .green : .orange)
                        .frame(width: 8, height: 8)

                    Text(appState.claudeService.isConfigured ? "API Connected" : "API Key Required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("\(appState.currentProject.sources.count) documents")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
    }
}

// MARK: - Sidebar Phase Row

private struct SidebarPhaseRow: View {
    let phase: AppState.WorkflowPhase
    let isCurrent: Bool
    let isAccessible: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: phase.sfSymbol)
                .font(.subheadline)
                .frame(width: 20)

            Text(phase.label)
                .font(.subheadline)

            Spacer()

            if isCurrent {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            if isCurrent {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.tint.opacity(0.1))
            }
        }
        .foregroundStyle(isCurrent ? .primary : (isAccessible ? .secondary : .tertiary))
    }
}

// MARK: - Recent Project Row

private struct RecentProjectRow: View {
    let entry: RecentProjectInfo
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.outputType == "plugin" ? "puzzlepiece.extension" : "brain")
                .font(.caption)
                .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName.isEmpty ? entry.fileName : entry.displayName)
                    .font(.caption)
                    .fontWeight(isActive ? .semibold : .regular)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(entry.summary)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if entry.hasGeneratedArtifact {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.green)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.tint.opacity(0.1))
            }
        }
    }
}
