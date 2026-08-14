import SwiftUI

struct DocumentEditView: View {
    @Bindable var viewModel: DocumentCorrectionViewModel
    var onSave: (Document) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Grunddaten") {
                    TextField("Titel", text: $viewModel.title)
                    TextField("Aussteller", text: $viewModel.issuer)
                    Picker("Kategorie", selection: $viewModel.category) {
                        ForEach(DocumentCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                Section("Datum") {
                    Toggle("Dokumentdatum vorhanden", isOn: documentDateEnabled)
                    if viewModel.documentDate != nil {
                        DatePicker("Datum", selection: documentDateBinding, displayedComponents: .date)
                    }
                }
                Section("Ablauf") {
                    Toggle("Ablaufdatum/Garantiefrist vorhanden", isOn: expiryDateEnabled)
                    if viewModel.expiryDate != nil {
                        DatePicker("Läuft ab", selection: expiryDateBinding, displayedComponents: .date)
                    }
                }
                Section("Tags") {
                    TextField("Tags, durch Komma getrennt", text: $viewModel.tagsText)
                }
            }
            .navigationTitle("Korrigieren")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Verwerfen") {
                        viewModel.discard()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.save()
                        onSave(viewModel.document)
                        dismiss()
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
    }

    private var documentDateEnabled: Binding<Bool> {
        Binding(
            get: { viewModel.documentDate != nil },
            set: { viewModel.documentDate = $0 ? (viewModel.documentDate ?? .now) : nil }
        )
    }

    private var documentDateBinding: Binding<Date> {
        Binding(get: { viewModel.documentDate ?? .now }, set: { viewModel.documentDate = $0 })
    }

    private var expiryDateEnabled: Binding<Bool> {
        Binding(
            get: { viewModel.expiryDate != nil },
            set: { viewModel.expiryDate = $0 ? (viewModel.expiryDate ?? .now) : nil }
        )
    }

    private var expiryDateBinding: Binding<Date> {
        Binding(get: { viewModel.expiryDate ?? .now }, set: { viewModel.expiryDate = $0 })
    }
}
