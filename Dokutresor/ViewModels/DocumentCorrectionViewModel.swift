import Foundation
import Observation

@Observable
final class DocumentCorrectionViewModel {
    var title: String
    var issuer: String
    var category: DocumentCategory
    var documentDate: Date?
    var expiryDate: Date?
    var tagsText: String

    private let document: Document

    init(document: Document) {
        self.document = document
        self.title = document.title
        self.issuer = document.issuer
        self.category = document.category
        self.documentDate = document.documentDate
        self.expiryDate = document.expiryDate
        self.tagsText = document.tags.joined(separator: ", ")
    }

    private var parsedTags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var hasChanges: Bool {
        title != document.title
            || issuer != document.issuer
            || category != document.category
            || documentDate != document.documentDate
            || expiryDate != document.expiryDate
            || parsedTags != document.tags
    }

    func save() {
        document.title = title
        document.issuer = issuer
        document.category = category
        document.documentDate = documentDate
        document.expiryDate = expiryDate
        document.tags = parsedTags
    }

    func discard() {
        title = document.title
        issuer = document.issuer
        category = document.category
        documentDate = document.documentDate
        expiryDate = document.expiryDate
        tagsText = document.tags.joined(separator: ", ")
    }
}
