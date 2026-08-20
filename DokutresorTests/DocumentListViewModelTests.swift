import Foundation
import Testing
@testable import Dokutresor

struct DocumentListViewModelTests {
    private func makeDocuments() -> [Document] {
        [
            Document(title: "Kühlschrank-Rechnung", issuer: "MediaMarkt", category: .receipt, tags: ["Küche"], ocrText: "Kühlschrank 899 EUR Garantie 24 Monate"),
            Document(title: "Abiturzeugnis", issuer: "Gymnasium Musterstadt", category: .certificate, tags: ["Schule"], ocrText: "Zeugnis der allgemeinen Hochschulreife"),
            Document(title: "Mietvertrag", issuer: "Hausverwaltung Meyer", category: .contract, tags: ["Wohnung"], ocrText: "Mietvertrag über die Wohnung in der Musterstraße")
        ]
    }

    @Test func noFilterReturnsAllDocuments() {
        let viewModel = DocumentListViewModel()
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.count == 3)
    }

    @Test func categoryFilterReturnsOnlyMatchingCategory() {
        let viewModel = DocumentListViewModel()
        viewModel.selectedCategory = .certificate
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Abiturzeugnis"])
    }

    @Test func searchTextMatchesTitleCaseInsensitive() {
        let viewModel = DocumentListViewModel()
        viewModel.searchText = "mietvertrag"
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Mietvertrag"])
    }

    @Test func searchTextMatchesIssuer() {
        let viewModel = DocumentListViewModel()
        viewModel.searchText = "MediaMarkt"
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Kühlschrank-Rechnung"])
    }

    @Test func searchTextMatchesOCRFullText() {
        let viewModel = DocumentListViewModel()
        viewModel.searchText = "Hochschulreife"
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Abiturzeugnis"])
    }

    @Test func searchTextMatchesTag() {
        let viewModel = DocumentListViewModel()
        viewModel.searchText = "Wohnung"
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Mietvertrag"])
    }

    @Test func categoryAndSearchTextCombineWithAnd() {
        let viewModel = DocumentListViewModel()
        viewModel.selectedCategory = .receipt
        viewModel.searchText = "Zeugnis"
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.isEmpty)
    }

    @Test func defaultSortOptionIsNewestFirst() {
        let viewModel = DocumentListViewModel(defaults: UserDefaults(suiteName: #function)!)
        #expect(viewModel.sortOption == .dateAddedDescending)
    }

    @Test func sortByDateAddedDescendingOrdersNewestFirst() {
        let viewModel = DocumentListViewModel(defaults: UserDefaults(suiteName: #function)!)
        viewModel.sortOption = .dateAddedDescending
        let result = viewModel.filteredDocuments(from: makeDocumentsWithVaryingDates())
        #expect(result.map(\.title) == ["Neu", "Mitte", "Alt"])
    }

    @Test func sortByDateAddedAscendingOrdersOldestFirst() {
        let viewModel = DocumentListViewModel(defaults: UserDefaults(suiteName: #function)!)
        viewModel.sortOption = .dateAddedAscending
        let result = viewModel.filteredDocuments(from: makeDocumentsWithVaryingDates())
        #expect(result.map(\.title) == ["Alt", "Mitte", "Neu"])
    }

    @Test func sortByTitleOrdersAlphabetically() {
        let viewModel = DocumentListViewModel(defaults: UserDefaults(suiteName: #function)!)
        viewModel.sortOption = .titleAscending
        let result = viewModel.filteredDocuments(from: makeDocuments())
        #expect(result.map(\.title) == ["Abiturzeugnis", "Kühlschrank-Rechnung", "Mietvertrag"])
    }

    @Test func sortByExpiryDatePutsSoonestFirstAndNoExpiryLast() {
        let viewModel = DocumentListViewModel(defaults: UserDefaults(suiteName: #function)!)
        viewModel.sortOption = .expiryDateAscending
        let documents = [
            Document(title: "Ohne Ablauf", expiryDate: nil),
            Document(title: "Läuft bald ab", expiryDate: Date(timeIntervalSince1970: 1_000)),
            Document(title: "Läuft später ab", expiryDate: Date(timeIntervalSince1970: 2_000))
        ]
        let result = viewModel.filteredDocuments(from: documents)
        #expect(result.map(\.title) == ["Läuft bald ab", "Läuft später ab", "Ohne Ablauf"])
    }

    @Test func sortOptionPersistsAcrossInstances() {
        let defaults = UserDefaults(suiteName: #function)!
        let viewModel = DocumentListViewModel(defaults: defaults)
        viewModel.sortOption = .titleAscending
        let reloaded = DocumentListViewModel(defaults: defaults)
        #expect(reloaded.sortOption == .titleAscending)
    }

    private func makeDocumentsWithVaryingDates() -> [Document] {
        [
            Document(title: "Alt", createdAt: Date(timeIntervalSince1970: 1_000)),
            Document(title: "Mitte", createdAt: Date(timeIntervalSince1970: 2_000)),
            Document(title: "Neu", createdAt: Date(timeIntervalSince1970: 3_000))
        ]
    }
}
