import Foundation
import UIKit
import Testing
@testable import Dokutresor

private func renderTextImage(_ string: String, size: CGSize = CGSize(width: 600, height: 200)) -> Data {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 48),
            .foregroundColor: UIColor.black
        ]
        string.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
    }
    return image.pngData()!
}

private func blankImageData(size: CGSize = CGSize(width: 100, height: 100)) -> Data {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    return image.pngData()!
}

@MainActor
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

    @Test func makeDocumentWithOCRExtractsIssuerAndFullText() async {
        let viewModel = ScanViewModel()
        viewModel.addPages([renderTextImage("TESTFIRMA")])

        let document = await viewModel.makeDocumentWithOCR()

        #expect(document.issuer.uppercased() == "TESTFIRMA")
        #expect(document.title.uppercased() == "TESTFIRMA")
        #expect(document.ocrText.uppercased().contains("TESTFIRMA"))
        #expect(viewModel.errorMessage == nil)
    }

    @Test func makeDocumentWithOCRSetsErrorMessageWhenNoTextRecognized() async {
        let viewModel = ScanViewModel()
        viewModel.addPages([blankImageData()])

        let document = await viewModel.makeDocumentWithOCR(defaultTitle: "Neues Dokument")

        #expect(document.title == "Neues Dokument")
        #expect(viewModel.errorMessage != nil)
    }
}
