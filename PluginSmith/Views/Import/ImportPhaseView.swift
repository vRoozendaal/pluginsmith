import SwiftUI

struct ImportPhaseView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ImportViewModel?
    @State private var previewDocument: SourceDocument?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Import Sources")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Drop documents or paste URLs to online resources")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Drop zone
                DropZoneView { urls in
                    Task {
                        await vm.handleDrop(urls: urls, into: appState.currentProject)
                    }
                }
                .padding(.horizontal)

                // URL input
                URLInputView(
                    urlText: Binding(
                        get: { vm.urlInput },
                        set: { vm.urlInput = $0 }
                    ),
                    isFetching: vm.isFetchingURL
                ) {
                    Task {
                        await vm.fetchURL(into: appState.currentProject)
                    }
                }
                .padding(.horizontal)

                // Error message
                if let error = vm.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            vm.errorMessage = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.08))
                    }
                    .padding(.horizontal)
                }

                // Processing indicator
                if vm.isProcessing {
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Processing documents...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Document list
                ImportedDocumentsList(
                    documents: appState.currentProject.sources,
                    onRemove: { doc in
                        vm.removeDocument(doc, from: appState.currentProject)
                    },
                    onPreview: { doc in
                        previewDocument = doc
                    }
                )
                .padding(.horizontal)

                // Next button
                if !appState.currentProject.sources.isEmpty {
                    Button {
                        withAnimation { appState.advanceToNext() }
                    } label: {
                        Label("Continue to Configure", systemImage: "arrow.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $previewDocument) { doc in
            DocumentPreviewSheet(document: doc)
        }
        .task {
            if viewModel == nil {
                viewModel = ImportViewModel(parsingService: appState.parsingService)
            }
        }
    }

    private var vm: ImportViewModel {
        viewModel ?? ImportViewModel(parsingService: appState.parsingService)
    }
}
