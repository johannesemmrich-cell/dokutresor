import UIKit
import PDFKit
import Testing
@testable import Dokutresor

private func renderJPEGData(_ color: UIColor, size: CGSize = CGSize(width: 20, height: 30)) -> Data {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    return image.jpegData(compressionQuality: 0.9)!
}

struct DocumentExportServiceTests {
    @Test func singlePageProducesOnePagePDF() throws {
        let pdfData = try DocumentExportService.pdfData(fromPageImages: [renderJPEGData(.red)])
        let document = try #require(PDFDocument(data: pdfData))
        #expect(document.pageCount == 1)
    }

    @Test func multiplePagesProduceMatchingPageCountInOrder() throws {
        let pageImages = [renderJPEGData(.red), renderJPEGData(.blue), renderJPEGData(.green)]
        let pdfData = try DocumentExportService.pdfData(fromPageImages: pageImages)
        let document = try #require(PDFDocument(data: pdfData))
        #expect(document.pageCount == 3)
    }

    @Test func noPageImagesThrows() {
        #expect(throws: ExportConversionError.noPages) {
            try DocumentExportService.pdfData(fromPageImages: [])
        }
    }

    @Test func undecodableImageDataThrows() {
        #expect(throws: ExportConversionError.noPages) {
            try DocumentExportService.pdfData(fromPageImages: [Data([0x00, 0x01, 0x02])])
        }
    }
}
