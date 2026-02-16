import SwiftUI

struct AgentsListView: View {
    let agents: [AgentConfig]
    let onAdd: () -> Void
    let onRemove: (AgentConfig) -> Void

    @State private var expandedID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Agents", systemImage: "person.circle")
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

            if agents.isEmpty {
                Text("No agents. Click + to add a spawnable agent.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(agents) { agent in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedID == agent.id },
                            set: { expandedID = $0 ? agent.id : nil }
                        )
                    ) {
                        AgentEditorView(agent: agent)
                    } label: {
                        HStack {
                            Text(agent.name)
                                .font(.system(.subheadline, design: .monospaced))

                            if !agent.description.isEmpty {
                                Text(agent.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Button {
                                onRemove(agent)
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
