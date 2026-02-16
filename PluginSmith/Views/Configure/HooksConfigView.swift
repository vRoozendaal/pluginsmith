import SwiftUI

struct HooksConfigView: View {
    @Bindable var project: ForgeProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Hooks", systemImage: "arrow.triangle.branch")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if project.pluginConfig.hooks == nil {
                    Button("Enable Hooks") {
                        project.pluginConfig.hooks = HooksConfig()
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                } else {
                    Button("Remove Hooks") {
                        project.pluginConfig.hooks = nil
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    .foregroundStyle(.red.opacity(0.6))
                }
            }

            if let hooks = project.pluginConfig.hooks {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Description", text: Binding(
                        get: { hooks.description },
                        set: { project.pluginConfig.hooks?.description = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)

                    ForEach(hooks.hooks) { eventConfig in
                        HStack {
                            Text(eventConfig.event.rawValue)
                                .font(.system(.caption, design: .monospaced))

                            Spacer()

                            Button {
                                project.pluginConfig.hooks?.hooks.removeAll { $0.id == eventConfig.id }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.red.opacity(0.6))
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.quaternary))
                    }

                    Menu {
                        ForEach(HookEventConfig.HookEvent.allCases, id: \.self) { event in
                            Button(event.rawValue) {
                                let newEvent = HookEventConfig(event: event)
                                project.pluginConfig.hooks?.hooks.append(newEvent)
                            }
                        }
                    } label: {
                        Label("Add Hook Event", systemImage: "plus")
                    }
                    .controlSize(.small)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.separator, lineWidth: 0.5)
                        }
                }
            }
        }
    }
}
