import Foundation

struct GeneratedArtifact: Codable {
    var files: [GeneratedFile]
    var rootDirectoryName: String

    struct GeneratedFile: Identifiable, Codable {
        let id: UUID
        var relativePath: String
        var content: String
        var isDirectory: Bool

        init(
            id: UUID = UUID(),
            relativePath: String,
            content: String = "",
            isDirectory: Bool = false
        ) {
            self.id = id
            self.relativePath = relativePath
            self.content = content
            self.isDirectory = isDirectory
        }

        var fileName: String {
            URL(fileURLWithPath: relativePath).lastPathComponent
        }

        var parentPath: String {
            URL(fileURLWithPath: relativePath).deletingLastPathComponent().relativePath
        }

        var fileExtension: String {
            URL(fileURLWithPath: relativePath).pathExtension
        }

        var sfSymbol: String {
            if isDirectory { return "folder.fill" }
            switch fileExtension {
            case "json": return "curlybraces"
            case "md": return "doc.text"
            case "sh": return "terminal"
            case "py": return "chevron.left.forwardslash.chevron.right"
            default: return "doc"
            }
        }
    }

    var fileTree: [FileTreeNode] {
        buildTree(from: files)
    }

    private func buildTree(from files: [GeneratedFile]) -> [FileTreeNode] {
        var root: [String: FileTreeNode] = [:]

        for file in files.sorted(by: { $0.relativePath < $1.relativePath }) {
            let components = file.relativePath.split(separator: "/").map(String.init)
            insertIntoTree(&root, components: components, file: file, depth: 0)
        }

        return root.values.sorted { $0.name < $1.name }
    }

    private func insertIntoTree(
        _ tree: inout [String: FileTreeNode],
        components: [String],
        file: GeneratedFile,
        depth: Int
    ) {
        guard depth < components.count else { return }
        let name = components[depth]

        if depth == components.count - 1 {
            tree[name] = FileTreeNode(
                name: name,
                file: file,
                children: []
            )
        } else {
            if tree[name] == nil {
                tree[name] = FileTreeNode(
                    name: name,
                    file: nil,
                    children: []
                )
            }
            var childTree: [String: FileTreeNode] = [:]
            for child in tree[name]!.children {
                childTree[child.name] = child
            }
            insertIntoTree(&childTree, components: components, file: file, depth: depth + 1)
            tree[name]?.children = childTree.values.sorted { $0.name < $1.name }
        }
    }
}

struct FileTreeNode: Identifiable {
    let id = UUID()
    var name: String
    var file: GeneratedArtifact.GeneratedFile?
    var children: [FileTreeNode]

    var isDirectory: Bool { file == nil || file?.isDirectory == true }

    var sfSymbol: String {
        if isDirectory { return "folder.fill" }
        return file?.sfSymbol ?? "doc"
    }
}
