import SwiftUI

struct ExportSuccessView: View {
    let installPath: URL?
    let lastPluginPackageURL: URL?
    let onRevealInFinder: () -> Void
    let onBackToPreview: () -> Void
    let onDownloadPlugin: () -> Void
    let onNewProject: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            VStack(spacing: 6) {
                Text("Successfully Created")
                    .font(.title2)
                    .fontWeight(.bold)

                if let installPath {
                    Text(installPath.path)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }

            VStack(spacing: 10) {
                Button {
                    onRevealInFinder()
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                        .frame(minWidth: 240)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    onDownloadPlugin()
                } label: {
                    Label("Download .plugin", systemImage: "archivebox")
                        .frame(minWidth: 240)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    onBackToPreview()
                } label: {
                    Label("Back to Preview", systemImage: "doc.text.magnifyingglass")
                        .frame(minWidth: 240)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    onNewProject()
                } label: {
                    Label("New Project", systemImage: "plus")
                        .frame(minWidth: 240)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Next Steps")
                    .font(.subheadline)
                    .fontWeight(.medium)

                VStack(alignment: .leading, spacing: 4) {
                    Label("Run `claude` in your terminal", systemImage: "terminal")
                    Label("The plugin will be automatically detected", systemImage: "checkmark")
                    Label("Use /help to see available commands", systemImage: "questionmark.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
