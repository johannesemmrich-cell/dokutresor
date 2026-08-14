import SwiftUI
import SwiftData

@main
struct DokutresorApp: App {
    let modelContainer: ModelContainer = {
        do {
            return try ModelContainerFactory.makeContainer()
        } catch {
            fatalError("Konnte ModelContainer nicht erstellen: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LockGateView()
        }
        .modelContainer(modelContainer)
    }
}
