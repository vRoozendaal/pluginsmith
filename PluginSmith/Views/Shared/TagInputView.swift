import SwiftUI

struct TagInputView: View {
    let title: String
    @Binding var tags: [String]
    let suggestions: [String]

    @State private var inputText = ""

    init(_ title: String, tags: Binding<[String]>, suggestions: [String] = []) {
        self.title = title
        self._tags = tags
        self.suggestions = suggestions
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    TagChip(tag: tag) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tags.removeAll { $0 == tag }
                        }
                    }
                }

                TextField("Add...", text: $inputText)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 60, maxWidth: 120)
                    .onSubmit {
                        addTag()
                    }
            }

            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(availableSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    tags.append(suggestion)
                                }
                            }
                            .buttonStyle(.plain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.quaternary))
                        }
                    }
                }
            }
        }
    }

    private var availableSuggestions: [String] {
        suggestions.filter { !tags.contains($0) }
    }

    private func addTag() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            inputText = ""
            return
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            tags.append(trimmed)
        }
        inputText = ""
    }
}

private struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(.tint.opacity(0.1)))
        .foregroundStyle(.tint)
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(subviews: subviews, in: proposal.width ?? .infinity)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(subviews: subviews, in: bounds.width)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(subviews: Subviews, in width: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            totalWidth = max(totalWidth, x)
        }

        return (
            CGSize(width: totalWidth, height: y + maxHeight),
            positions
        )
    }
}
