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
}
