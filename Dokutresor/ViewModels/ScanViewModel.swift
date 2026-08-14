import Foundation
import Observation

@Observable
@MainActor
final class ScanViewModel {
    private(set) var pageImages: [Data] = []
    private(set) var errorMessage: String?

    func addPages(_ pages: [Data]) {
        pageImages.append(contentsOf: pages)
    }

    func removePage(at index: Int) {
        guard pageImages.indices.contains(index) else { return }
        pageImages.remove(at: index)
    }

    func setError(_ message: String) {
        errorMessage = message
    }

    func reset() {
        pageImages = []
        errorMessage = nil
    }

    func makeDocument(title: String, category: DocumentCategory = .other) -> Document {
        Document(title: title, category: category, pageImages: pageImages)
    }

    func makeDocumentWithOCR(defaultTitle: String = "Neues Dokument") async -> Document {
        let pages = pageImages
        let recognizedTexts: [String] = await withTaskGroup(of: String?.self) { group in
            for page in pages {
                group.addTask { try? await OCRService.recognizeText(in: page) }
            }
            var results: [String] = []
            for await text in group {
                if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    results.append(text)
                }
            }
            return results
        }

        let ocrText = recognizedTexts.joined(separator: "\n\n")
        guard !ocrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            setError("Es konnte kein Text erkannt werden. Bitte trage Titel und Daten manuell ein.")
            return Document(title: defaultTitle, pageImages: pages)
        }

        let fields = GermanReceiptHeuristics.extract(from: ocrText)
        return Document(
            title: fields.issuer ?? defaultTitle,
            issuer: fields.issuer ?? "",
            documentDate: fields.documentDate,
            ocrText: ocrText,
            expiryDate: fields.expiryDate,
            pageImages: pages
        )
    }
}
