import SwiftUI

struct CommandEditorView: View {
    @Bindable var command: CommandConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("/")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
                TextField("command-name", text: $command.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }

            TextField("Description", text: $command.description)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField("Argument hint (e.g. <file> [options])", text: $command.argumentHint)
                    .textFieldStyle(.roundedBorder)

                Picker("Model", selection: Binding(
                    get: { command.model ?? "" },
                    set: { command.model = $0.isEmpty ? nil : $0 }
                )) {
                    Text("Default").tag("")
                    ForEach(AppConstants.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .frame(width: 120)
            }

            TagInputView(
                "Allowed Tools",
                tags: $command.allowedTools,
                suggestions: AppConstants.availableTools
            )

            MarkdownEditorView(
                "Instructions",
                text: $command.instructionContent,
                placeholder: "What should Claude do when this command is invoked?\n\nLeave empty for AI-generated content.",
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
