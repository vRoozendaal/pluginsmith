import SwiftUI

struct OutputTypePicker: View {
    @Binding var outputType: ForgeProject.OutputType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Output Type")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Output Type", selection: $outputType) {
                ForEach(ForgeProject.OutputType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Text(outputType.description)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
