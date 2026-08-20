import Foundation
import Observation

enum DocumentSortOption: String, CaseIterable, Identifiable {
    case dateAddedDescending
    case dateAddedAscending
    case titleAscending
    case expiryDateAscending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateAddedDescending: return "Neueste zuerst"
        case .dateAddedAscending: return "Älteste zuerst"
        case .titleAscending: return "Titel (A–Z)"
        case .expiryDateAscending: return "Ablauf (bald zuerst)"
        }
    }
}

@Observable
final class DocumentListViewModel {
    private let defaults: UserDefaults
    private let sortOptionKey = "documentSortOption"

    var searchText: String = ""
    var selectedCategory: DocumentCategory?
    var sortOption: DocumentSortOption {
        didSet { defaults.set(sortOption.rawValue, forKey: sortOptionKey) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let rawValue = defaults.string(forKey: sortOptionKey),
           let storedOption = DocumentSortOption(rawValue: rawValue) {
            self.sortOption = storedOption
        } else {
            self.sortOption = .dateAddedDescending
        }
    }

    func filteredDocuments(from documents: [Document]) -> [Document] {
        sorted(documents.filter { matchesCategory($0) && matchesSearch($0) })
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

    private func sorted(_ documents: [Document]) -> [Document] {
        switch sortOption {
        case .dateAddedDescending:
            return documents.sorted { $0.createdAt > $1.createdAt }
        case .dateAddedAscending:
            return documents.sorted { $0.createdAt < $1.createdAt }
        case .titleAscending:
            return documents.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .expiryDateAscending:
            return documents.sorted { lhs, rhs in
                switch (lhs.expiryDate, rhs.expiryDate) {
                case let (left?, right?): return left < right
                case (nil, nil): return false
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        }
    }
}
