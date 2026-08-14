import UIKit
import PDFKit

enum ImportConversionError: Error, Equatable {
    case unsupportedData
}

enum ImportConverter {
    static func pages(fromFileData data: Data) throws -> [Data] {
        if let pdfDocument = PDFDocument(data: data), pdfDocument.pageCount > 0 {
            return try pages(fromPDFDocument: pdfDocument)
        }
        guard UIImage(data: data) != nil else { throw ImportConversionError.unsupportedData }
        return [data]
    }

    private static func pages(fromPDFDocument document: PDFDocument) throws -> [Data] {
        var pages: [Data] = []
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: bounds.size)
            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: bounds.size))
                context.cgContext.translateBy(x: 0, y: bounds.size.height)
                context.cgContext.scaleBy(x: 1, y: -1)
                page.draw(with: .mediaBox, to: context.cgContext)
            }
            guard let jpegData = image.jpegData(compressionQuality: 0.85) else { continue }
            pages.append(jpegData)
        }
        guard !pages.isEmpty else { throw ImportConversionError.unsupportedData }
        return pages
    }
}
