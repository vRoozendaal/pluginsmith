import SwiftUI

struct SkillsListView: View {
    let skills: [SkillConfig]
    let onAdd: () -> Void
    let onRemove: (SkillConfig) -> Void

    @State private var expandedID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Skills", systemImage: "brain")
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

            if skills.isEmpty {
                Text("No skills. Click + to add an auto-triggered skill.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(skills) { skill in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedID == skill.id },
                            set: { expandedID = $0 ? skill.id : nil }
                        )
                    ) {
                        SkillEditorView(skill: skill)
                    } label: {
                        HStack {
                            Text(skill.name)
                                .font(.system(.subheadline, design: .monospaced))

                            if !skill.description.isEmpty {
                                Text(skill.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Button {
                                onRemove(skill)
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
