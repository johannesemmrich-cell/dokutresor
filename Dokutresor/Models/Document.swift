import Foundation
import SwiftData

@Model
final class Document {
    static let defaultReminderOffsetsInDays = [30, 7]

    var id: UUID
    var title: String
    var issuer: String
    var documentDate: Date?
    var category: DocumentCategory
    var tags: [String]
    var ocrText: String
    var expiryDate: Date?
    var reminderOffsetsInDays: [Int]
    var createdAt: Date
    @Attribute(.externalStorage) var pageImages: [Data]

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
