import SwiftUI

struct CommandsListView: View {
    let commands: [CommandConfig]
    let onAdd: () -> Void
    let onRemove: (CommandConfig) -> Void

    @State private var expandedID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Commands", systemImage: "terminal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    onAdd()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }

            if commands.isEmpty {
                Text("No commands. Click + to add a slash command.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(commands) { command in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedID == command.id },
                            set: { expandedID = $0 ? command.id : nil }
                        )
                    ) {
                        CommandEditorView(command: command)
                    } label: {
                        HStack {
                            Text("/\(command.name)")
                                .font(.system(.subheadline, design: .monospaced))

                            if !command.description.isEmpty {
                                Text(command.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Button {
                                onRemove(command)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                }
            }
        }
    }
}
