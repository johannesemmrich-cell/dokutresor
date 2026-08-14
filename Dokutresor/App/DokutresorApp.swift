import SwiftUI
import SwiftData

@main
struct DokutresorApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([Document.self])
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
