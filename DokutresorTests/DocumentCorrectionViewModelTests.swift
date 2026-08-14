import Foundation
import Testing
@testable import Dokutresor

struct DocumentCorrectionViewModelTests {
    private func makeDocument() -> Document {
        Document(
            title: "Kühlschrank-Rechnung",
            issuer: "MediaMarkt",
            documentDate: Date(timeIntervalSince1970: 1_700_000_000),
            category: .receipt,
            tags: ["Küche"],
            expiryDate: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }

    @Test func initPopulatesFieldsFromDocument() {
        let document = makeDocument()
        let viewModel = DocumentCorrectionViewModel(document: document)

        #expect(viewModel.title == document.title)
        #expect(viewModel.issuer == document.issuer)
        #expect(viewModel.category == document.category)
        #expect(viewModel.documentDate == document.documentDate)
        #expect(viewModel.expiryDate == document.expiryDate)
        #expect(viewModel.tagsText == "Küche")
    }

    @Test func hasChangesIsFalseInitiallyAndTrueAfterEdit() {
        let viewModel = DocumentCorrectionViewModel(document: makeDocument())
        #expect(viewModel.hasChanges == false)

        viewModel.title = "Neuer Titel"
        #expect(viewModel.hasChanges == true)
    }

    @Test func saveWritesEditedFieldsBackToDocument() {
        let document = makeDocument()
        let viewModel = DocumentCorrectionViewModel(document: document)

        viewModel.title = "Korrigierter Titel"
        viewModel.issuer = "Saturn"
        viewModel.category = .contract
        viewModel.tagsText = "Küche, Wichtig,  "

        viewModel.save()

        #expect(document.title == "Korrigierter Titel")
        #expect(document.issuer == "Saturn")
        #expect(document.category == .contract)
        #expect(document.tags == ["Küche", "Wichtig"])
    }

    @Test func discardRevertsLocalStateWithoutTouchingDocument() {
        let document = makeDocument()
        let viewModel = DocumentCorrectionViewModel(document: document)
        let originalTitle = document.title

        viewModel.title = "Verworfener Titel"
        viewModel.discard()

        #expect(viewModel.title == originalTitle)
        #expect(viewModel.hasChanges == false)
        #expect(document.title == originalTitle)
    }
}
