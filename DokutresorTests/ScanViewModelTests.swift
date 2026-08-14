import Foundation
import Testing
@testable import Dokutresor

struct ScanViewModelTests {
    @Test func addPagesAppendsToExistingPages() {
        let viewModel = ScanViewModel()
        viewModel.addPages([Data([1]), Data([2])])
        viewModel.addPages([Data([3])])
        #expect(viewModel.pageImages == [Data([1]), Data([2]), Data([3])])
    }

    @Test func removePageAtValidIndexRemovesIt() {
        let viewModel = ScanViewModel()
        viewModel.addPages([Data([1]), Data([2]), Data([3])])
        viewModel.removePage(at: 1)
        #expect(viewModel.pageImages == [Data([1]), Data([3])])
    }

    @Test func removePageAtInvalidIndexIsNoOp() {
        let viewModel = ScanViewModel()
        viewModel.addPages([Data([1])])
        viewModel.removePage(at: 5)
        #expect(viewModel.pageImages == [Data([1])])
    }

    @Test func resetClearsPagesAndError() {
        let viewModel = ScanViewModel()
        viewModel.addPages([Data([1])])
        viewModel.setError("Kamera nicht verfügbar")
        viewModel.reset()
        #expect(viewModel.pageImages.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func makeDocumentUsesTitleCategoryAndPages() {
        let viewModel = ScanViewModel()
        viewModel.addPages([Data([1]), Data([2])])
        let document = viewModel.makeDocument(title: "Kassenbon", category: .receipt)
        #expect(document.title == "Kassenbon")
        #expect(document.category == .receipt)
        #expect(document.pageImages == [Data([1]), Data([2])])
    }
}
