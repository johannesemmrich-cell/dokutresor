import UIKit
import PDFKit
import Testing
@testable import Dokutresor

private func renderJPEGData(_ color: UIColor, size: CGSize = CGSize(width: 20, height: 20)) -> Data {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    return image.jpegData(compressionQuality: 0.9)!
}

private func renderTwoPagePDFData() -> Data {
    let pageBounds = CGRect(x: 0, y: 0, width: 200, height: 300)
    let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
    return renderer.pdfData { context in
        context.beginPage()
        UIColor.red.setFill()
        context.fill(pageBounds)
        context.beginPage()
        UIColor.blue.setFill()
        context.fill(pageBounds)
    }
}

struct ImportConverterTests {
    @Test func imageDataIsPassedThroughAsSinglePage() throws {
        let imageData = renderJPEGData(.green)
        let pages = try ImportConverter.pages(fromFileData: imageData)
        #expect(pages == [imageData])
    }

    @Test func pdfDataIsRasterizedIntoOnePagePerPDFPage() throws {
        let pdfData = renderTwoPagePDFData()
        let pages = try ImportConverter.pages(fromFileData: pdfData)
        #expect(pages.count == 2)
        for page in pages {
            #expect(UIImage(data: page) != nil)
        }
    }

    @Test func unsupportedDataThrows() {
        let garbage = Data([0x00, 0x01, 0x02])
        #expect(throws: ImportConversionError.unsupportedData) {
            try ImportConverter.pages(fromFileData: garbage)
        }
    }
}
