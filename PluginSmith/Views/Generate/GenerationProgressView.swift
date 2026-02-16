import SwiftUI

struct GenerationProgressView: View {
    let progress: Double
    let currentStep: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.circle")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse, isActive: true)

            VStack(spacing: 8) {
                Text("Generating")
                    .font(.title2)
                    .fontWeight(.medium)

                Text(currentStep)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 300)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fontDesign(.monospaced)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
