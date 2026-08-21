import SwiftUI
import SwiftData

@main
struct DokutresorApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: String = "auto"

    let modelContainer: ModelContainer = {
        do {
            return try ModelContainerFactory.makeContainer()
        } catch {
            fatalError("Konnte ModelContainer nicht erstellen: \(error)")
        }
    }()

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            LockGateView()
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(modelContainer)
    }
}
