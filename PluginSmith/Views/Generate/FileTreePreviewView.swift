import SwiftUI

struct FileTreePreviewView: View {
    let nodes: [FileTreeNode]
    @Binding var selectedFile: GeneratedArtifact.GeneratedFile?
    @State private var expandedNodes: Set<String> = []

    var body: some View {
        List {
            ForEach(nodes) { node in
                FileTreeNodeView(
                    node: node,
                    selectedFile: $selectedFile,
                    expandedNodes: $expandedNodes
                )
            }
        }
        .listStyle(.sidebar)
        .onAppear {
            // Auto-expand top-level directories on first appear
            if expandedNodes.isEmpty {
                for node in nodes where node.isDirectory {
                    expandedNodes.insert(node.name)
                }
            }
        }
    }
}

private struct FileTreeNodeView: View {
    let node: FileTreeNode
    @Binding var selectedFile: GeneratedArtifact.GeneratedFile?
    @Binding var expandedNodes: Set<String>

    private var isExpanded: Binding<Bool> {
        Binding(
            get: { expandedNodes.contains(node.name) },
            set: { newValue in
                if newValue {
                    expandedNodes.insert(node.name)
                } else {
                    expandedNodes.remove(node.name)
                }
            }
        )
    }

    var body: some View {
        if node.isDirectory && !node.children.isEmpty {
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(node.children) { child in
                    FileTreeNodeView(
                        node: child,
                        selectedFile: $selectedFile,
                        expandedNodes: $expandedNodes
                    )
                }
            } label: {
                Label(node.name, systemImage: "folder.fill")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .animation(nil, value: isExpanded.wrappedValue)
        } else if let file = node.file, !file.isDirectory {
            Label(node.name, systemImage: file.sfSymbol)
                .font(.subheadline)
                .tag(file.id)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedFile = file
                }
                .padding(.vertical, 1)
                .listRowBackground(
                    selectedFile?.id == file.id
                        ? Color.accentColor.opacity(0.15)
                        : Color.clear
                )
        }
    }
}
