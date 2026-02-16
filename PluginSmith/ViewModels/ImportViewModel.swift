import Foundation
import SwiftUI

@MainActor @Observable
final class ImportViewModel {
    var urlInput = ""
    var isProcessing = false
    var isFetchingURL = false
    var errorMessage: String?

    private let parsingService: DocumentParsingService

    init(parsingService: DocumentParsingService) {
        self.parsingService = parsingService
    }

    @MainActor
    func handleDrop(urls: [URL], into project: ForgeProject) async {
        isProcessing = true
        errorMessage = nil

        for url in urls {
            guard FileTypeDetector.isSupported(url) else {
                errorMessage = "Unsupported file: \(url.lastPathComponent)"
                continue
            }

            do {
                // Access security-scoped resource
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing { url.stopAccessingSecurityScopedResource() }
                }

                let document = try await parsingService.parse(url: url)
                project.sources.append(document)
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        isProcessing = false
    }

    @MainActor
    func fetchURL(into project: ForgeProject) async {
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard FileTypeDetector.isValidURL(trimmed) else {
            errorMessage = "Please enter a valid URL (https://...)"
            return
        }

        isFetchingURL = true
        errorMessage = nil

        do {
            let document = try await parsingService.parseFromURL(urlString: trimmed)
            project.sources.append(document)
            urlInput = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isFetchingURL = false
    }

    func removeDocument(_ document: SourceDocument, from project: ForgeProject) {
        project.sources.removeAll { $0.id == document.id }
    }
}
