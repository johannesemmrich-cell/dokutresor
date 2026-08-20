import UIKit
import CoreTransferable
import UniformTypeIdentifiers

enum ExportConversionError: Error, Equatable {
    case noPages
}

struct ExportedDocumentFile: Transferable {
    let data: Data
    let title: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { file in
            let fileName = (file.title.isEmpty ? "Dokument" : file.title) + ".pdf"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try file.data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}

enum DocumentExportService {
    static func pdfData(fromPageImages pageImages: [Data]) throws -> Data {
        let images = pageImages.compactMap { UIImage(data: $0) }
        guard !images.isEmpty else { throw ExportConversionError.noPages }

        let renderer = UIGraphicsPDFRenderer(bounds: .zero)
        return renderer.pdfData { context in
            for image in images {
                context.beginPage(withBounds: CGRect(origin: .zero, size: image.size), pageInfo: [:])
                image.draw(in: CGRect(origin: .zero, size: image.size))
            }
        }
    }
}
