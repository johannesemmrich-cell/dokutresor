import Foundation
import SwiftData
import Testing
@testable import Dokutresor

struct DocumentModelTests {
    @Test func defaultsToOtherCategoryAndStandardReminderOffsets() {
        let document = Document(title: "Testdokument")

        #expect(document.category == .other)
        #expect(document.reminderOffsetsInDays == [30, 7])
        #expect(document.tags.isEmpty)
        #expect(document.expiryDate == nil)
    }

    @Test func allCategoriesAreCoveredAndIdentifiableByRawValue() {
        #expect(DocumentCategory.allCases.count == 5)
        for category in DocumentCategory.allCases {
            #expect(category.id == category.rawValue)
        }
    }

    @Test func persistsAndFetchesDocumentViaSwiftData() throws {
        let schema = Schema([Document.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)

        let document = Document(
            title: "Kühlschrank-Rechnung",
            issuer: "MediaMarkt",
            category: .receipt,
            tags: ["Küche", "Garantie"],
            expiryDate: Calendar.current.date(byAdding: .day, value: 730, to: .now)
        )
        context.insert(document)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Document>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.issuer == "MediaMarkt")
        #expect(fetched.first?.tags == ["Küche", "Garantie"])
    }
}
