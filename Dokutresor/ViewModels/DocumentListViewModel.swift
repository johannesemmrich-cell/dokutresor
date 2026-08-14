import Foundation
import Observation

@Observable
final class DocumentListViewModel {
    var searchText: String = ""
    var selectedCategory: DocumentCategory?

    func filteredDocuments(from documents: [Document]) -> [Document] {
        documents.filter { matchesCategory($0) && matchesSearch($0) }
    }

    private func matchesCategory(_ document: Document) -> Bool {
        guard let selectedCategory else { return true }
        return document.category == selectedCategory
    }

    private func matchesSearch(_ document: Document) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return true }
        return document.title.lowercased().contains(query)
            || document.issuer.lowercased().contains(query)
            || document.ocrText.lowercased().contains(query)
            || document.category.rawValue.lowercased().contains(query)
            || document.tags.contains { $0.lowercased().contains(query) }
    }
}
