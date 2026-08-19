import SwiftUI

struct DocumentDetailView: View {
    let document: Document
    var onDelete: () -> Void = {}
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if document.pageImages.count > 1 {
                    TabView {
                        ForEach(Array(document.pageImages.enumerated()), id: \.offset) { _, pageData in
                            PageImageView(pageData: pageData)
                                .padding(.horizontal)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 420)
                } else if let onlyPage = document.pageImages.first, let uiImage = UIImage(data: onlyPage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(document.title.isEmpty ? "Ohne Titel" : document.title)
                    .font(.title2.bold())
                LabeledContent("Kategorie", value: document.category.rawValue)
                if !document.issuer.isEmpty {
                    LabeledContent("Aussteller", value: document.issuer)
                }
                if let documentDate = document.documentDate {
                    LabeledContent("Datum", value: documentDate.formatted(date: .abbreviated, time: .omitted))
                }
                if let expiryDate = document.expiryDate {
                    LabeledContent("Läuft ab", value: expiryDate.formatted(date: .abbreviated, time: .omitted))
                }
                if !document.tags.isEmpty {
                    LabeledContent("Tags", value: document.tags.joined(separator: ", "))
                }
            }
            .padding()
        }
        .navigationTitle(document.title.isEmpty ? "Dokument" : document.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Bearbeiten") {
                    isShowingEditSheet = true
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            DocumentEditView(viewModel: DocumentCorrectionViewModel(document: document)) { updatedDocument in
                let target = updatedDocument.reminderTarget
                Task { await NotificationService().scheduleReminders(for: target) }
            }
        }
        .confirmationDialog(
            "Dokument löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive, action: onDelete)
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Das Dokument wird endgültig gelöscht. Das kann nicht rückgängig gemacht werden.")
        }
    }
}

private struct PageImageView: View {
    let pageData: Data
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task(id: pageData) {
            image = UIImage(data: pageData)
        }
    }
}
