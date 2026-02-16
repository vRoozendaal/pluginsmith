import SwiftUI

struct AgentEditorView: View {
    @Bindable var agent: AgentConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("agent-name", text: $agent.name)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            TextField("Description", text: $agent.description)
                .textFieldStyle(.roundedBorder)

            HStack {
                Picker("Model", selection: $agent.model) {
                    ForEach(AppConstants.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .frame(width: 140)

                Picker("Color", selection: Binding(
                    get: { agent.color ?? "" },
                    set: { agent.color = $0.isEmpty ? nil : $0 }
                )) {
                    Text("None").tag("")
                    ForEach(AppConstants.agentColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }
                .frame(width: 140)

                Spacer()
            }

            TagInputView(
                "Tools",
                tags: $agent.tools,
                suggestions: AppConstants.availableTools
            )

            MarkdownEditorView(
                "Agent Instructions",
                text: $agent.instructionContent,
                placeholder: "Mission, methodology, and workflow for this agent.\n\nLeave empty for AI-generated content.",
                minHeight: 150
            )
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
