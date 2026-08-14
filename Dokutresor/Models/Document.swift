import Foundation
import SwiftData

// CloudKit verlangt, dass jedes Attribut optional ist oder einen Default-Wert hat —
// deshalb Default-Werte direkt an den Property-Deklarationen (nicht nur im Initializer).
@Model
final class Document {
    static let defaultReminderOffsetsInDays = [30, 7]

    var id: UUID = UUID()
    var title: String = ""
    var issuer: String = ""
    var documentDate: Date?
    var category: DocumentCategory = DocumentCategory.other
    var tags: [String] = []
    var ocrText: String = ""
    var expiryDate: Date?
    var reminderOffsetsInDays: [Int] = Document.defaultReminderOffsetsInDays
    var createdAt: Date = Date.now
    @Attribute(.externalStorage) var pageImages: [Data] = []

    init(
        title: String,
        issuer: String = "",
        documentDate: Date? = nil,
        category: DocumentCategory = .other,
        tags: [String] = [],
        ocrText: String = "",
        expiryDate: Date? = nil,
        reminderOffsetsInDays: [Int] = Document.defaultReminderOffsetsInDays,
        pageImages: [Data] = [],
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.issuer = issuer
        self.documentDate = documentDate
        self.category = category
        self.tags = tags
        self.ocrText = ocrText
        self.expiryDate = expiryDate
        self.reminderOffsetsInDays = reminderOffsetsInDays
        self.pageImages = pageImages
        self.createdAt = createdAt
    }
}
