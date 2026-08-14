import Foundation
import SwiftData
import Testing
@testable import Dokutresor

struct CloudKitConfigurationTests {
    @Test func schemaIsCloudKitCompatible() throws {
        // CloudKit verlangt, dass alle Attribute optional sind oder einen Default-Wert
        // haben (schema-seitig, nicht nur im Initializer). Wirft sonst beim Laden des Stores.
        let schema = Schema([Document.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .private(ModelContainerFactory.cloudKitContainerIdentifier)
        )
        _ = try ModelContainer(for: schema, configurations: [configuration])
    }

    @Test func factoryProducesWorkingContainer() throws {
        let container = try ModelContainerFactory.makeContainer(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let document = Document(title: "Test")
        context.insert(document)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Document>())
        #expect(fetched.count == 1)
    }
}
