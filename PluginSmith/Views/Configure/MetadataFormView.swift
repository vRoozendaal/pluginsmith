import SwiftUI

struct MetadataFormView: View {
    @Bindable var project: ForgeProject
    let onNameChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassSection("Metadata") {
                VStack(alignment: .leading, spacing: 12) {
                    // Display name
                    LabeledContent("Display Name") {
                        TextField("My Plugin", text: $project.displayName)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: project.displayName) { _, _ in
                                onNameChange()
                            }
                    }

                    // Auto-generated kebab-case name
                    LabeledContent("Identifier") {
                        HStack {
                            Text(project.name.isEmpty ? "auto-generated" : project.name)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(project.name.isEmpty ? .tertiary : .primary)
                            Spacer()
                        }
                    }

                    // Description
                    LabeledContent("Description") {
                        TextField("What does this plugin/skill do?", text: $project.description)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Version
                    LabeledContent("Version") {
                        TextField("0.1.0", text: $project.version)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 120)
                    }

                    // Author
                    LabeledContent("Author") {
                        TextField("Your name", text: $project.author.name)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
    }
}
