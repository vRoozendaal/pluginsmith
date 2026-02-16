import SwiftUI

struct SkillEditorView: View {
    @Bindable var skill: SkillConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("skill-name", text: $skill.name)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            TextField("Trigger description (when should Claude use this?)", text: $skill.description)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField("Version", text: $skill.version)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 120)

                Spacer()
            }

            TagInputView(
                "Tools",
                tags: $skill.tools,
                suggestions: AppConstants.availableTools
            )

            MarkdownEditorView(
                "Skill Instructions",
                text: $skill.instructionContent,
                placeholder: "Instructions for Claude when this skill is triggered.\n\nLeave empty for AI-generated content based on your imported documents.",
                minHeight: 200
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
