import SwiftUI

struct DropZoneView: View {
    @State private var isTargeted = false
    let onDrop: ([URL]) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)

            VStack(spacing: 4) {
                Text("Drop documents here")
                    .font(.title2)
                    .fontWeight(.medium)

                Text(".md  .txt  .pdf  .docx  .xlsx")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .tracking(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.2),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(isTargeted ? 1 : 0.5)
                }
        }
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
        .dropDestination(for: URL.self) { urls, _ in
            let supported = urls.filter { FileTypeDetector.isSupported($0) }
            guard !supported.isEmpty else { return false }
            onDrop(supported)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }
}
