import Foundation
import Observation

@Observable
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
}
