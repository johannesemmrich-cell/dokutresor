import SwiftUI
import SwiftData

struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Document.createdAt, order: .reverse) private var documents: [Document]
    @State private var viewModel = DocumentListViewModel()
    @State private var scanViewModel = ScanViewModel()
    @State private var isShowingScanner = false
    @State private var selectedDocument: Document?

    private var filteredDocuments: [Document] {
        viewModel.filteredDocuments(from: documents)
    }

    var body: some View {
        NavigationSplitView {
            Group {
                if documents.isEmpty {
                    EmptyDocumentsView()
                } else {
                    List(filteredDocuments, selection: $selectedDocument) { document in
                        DocumentRowView(document: document)
                            .tag(document)
                    }
                }
            }
            .navigationTitle("Dokutresor")
            .searchable(text: $viewModel.searchText, prompt: "Suchen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scannen", systemImage: "doc.viewfinder")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Alle") { viewModel.selectedCategory = nil }
                        ForEach(DocumentCategory.allCases) { category in
                            Button(category.rawValue) { viewModel.selectedCategory = category }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                DocumentScannerView(
                    onComplete: { pages in
                        scanViewModel.addPages(pages)
                        let document = scanViewModel.makeDocument(title: "Neues Dokument")
                        modelContext.insert(document)
                        scanViewModel.reset()
                        isShowingScanner = false
                    },
                    onCancel: {
                        isShowingScanner = false
                    },
                    onError: { _ in
                        isShowingScanner = false
                    }
                )
                .ignoresSafeArea()
            }
        } detail: {
            if let selectedDocument {
                DocumentDetailView(document: selectedDocument)
            } else {
                ContentUnavailableView("Kein Dokument ausgewählt", systemImage: "doc.text.magnifyingglass")
            }
        }
    }
}

private struct DocumentRowView: View {
    let document: Document

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.title.isEmpty ? "Ohne Titel" : document.title)
                .font(.headline)
            HStack {
                Text(document.category.rawValue)
                if !document.issuer.isEmpty {
                    Text("· \(document.issuer)")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let expiryDate = document.expiryDate {
                Text("Läuft ab: \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}

private struct EmptyDocumentsView: View {
    var body: some View {
        ContentUnavailableView(
            "Noch keine Dokumente",
            systemImage: "tray",
            description: Text("Tippe oben rechts auf das Scan-Symbol, um dein erstes Dokument hinzuzufügen.")
        )
    }
}
