import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Document.createdAt, order: .reverse) private var documents: [Document]
    @State private var viewModel = DocumentListViewModel()
    @State private var scanViewModel = ScanViewModel()
    @State private var onboardingViewModel = OnboardingViewModel()
    @State private var isShowingScanner = false
    @State private var isShowingFileImporter = false
    @State private var isShowingPhotoPicker = false
    @State private var selectedDocument: Document?
    @State private var scanErrorMessage: String?
    @State private var photoPickerItems: [PhotosPickerItem] = []

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
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteDocument(document)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Dokutresor")
            .searchable(text: $viewModel.searchText, prompt: "Suchen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isShowingScanner = true
                        } label: {
                            Label("Scannen", systemImage: "doc.viewfinder")
                        }
                        Button {
                            isShowingPhotoPicker = true
                        } label: {
                            Label("Aus Fotos", systemImage: "photo")
                        }
                        Button {
                            isShowingFileImporter = true
                        } label: {
                            Label("Aus Dateien", systemImage: "folder")
                        }
                    } label: {
                        Label("Hinzufügen", systemImage: "plus")
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
                        isShowingScanner = false
                        processImportedPages(pages)
                    },
                    onCancel: {
                        isShowingScanner = false
                    },
                    onError: { _ in
                        isShowingScanner = false
                        scanErrorMessage = "Dokument konnte nicht gescannt werden. Bitte überprüfe den Kamera-Zugriff in den Einstellungen."
                    }
                )
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $isShowingPhotoPicker, selection: $photoPickerItems, maxSelectionCount: 1, matching: .images)
            .onChange(of: photoPickerItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                Task {
                    var pages: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            pages.append(data)
                        }
                    }
                    photoPickerItems = []
                    if pages.isEmpty {
                        scanErrorMessage = "Das ausgewählte Foto konnte nicht geladen werden."
                    } else {
                        processImportedPages(pages)
                    }
                }
            }
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.pdf, .image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importFile(at: url)
                case .failure:
                    scanErrorMessage = "Die Datei konnte nicht importiert werden."
                }
            }
            .alert(
                "Hinweis",
                isPresented: Binding(
                    get: { scanErrorMessage != nil },
                    set: { isPresented in if !isPresented { scanErrorMessage = nil } }
                ),
                presenting: scanErrorMessage
            ) { _ in
                Button("OK") { scanErrorMessage = nil }
            } message: { message in
                Text(message)
            }
        } detail: {
            if let selectedDocument {
                DocumentDetailView(document: selectedDocument) {
                    deleteDocument(selectedDocument)
                }
            } else {
                ContentUnavailableView("Kein Dokument ausgewählt", systemImage: "doc.text.magnifyingglass")
            }
        }
        .task {
            _ = try? await NotificationService().requestAuthorization()
        }
        .fullScreenCover(isPresented: .init(
            get: { !onboardingViewModel.hasCompletedOnboarding },
            set: { _ in }
        )) {
            OnboardingView {
                onboardingViewModel.completeOnboarding()
            }
        }
    }

    private func processImportedPages(_ pages: [Data]) {
        scanViewModel.addPages(pages)
        Task {
            let document = await scanViewModel.makeDocumentWithOCR()
            modelContext.insert(document)
            if let ocrErrorMessage = scanViewModel.errorMessage {
                scanErrorMessage = ocrErrorMessage
            }
            scanViewModel.reset()
            await NotificationService().scheduleReminders(for: document.reminderTarget)
        }
    }

    private func deleteDocument(_ document: Document) {
        if selectedDocument?.id == document.id {
            selectedDocument = nil
        }
        let target = document.reminderTarget
        modelContext.delete(document)
        Task { await NotificationService().cancelReminders(for: target) }
    }

    private func importFile(at url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { url.stopAccessingSecurityScopedResource() }
        }
        guard let data = try? Data(contentsOf: url) else {
            scanErrorMessage = "Die Datei konnte nicht gelesen werden."
            return
        }
        guard let pages = try? ImportConverter.pages(fromFileData: data) else {
            scanErrorMessage = "Dieses Dateiformat wird nicht unterstützt."
            return
        }
        processImportedPages(pages)
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
