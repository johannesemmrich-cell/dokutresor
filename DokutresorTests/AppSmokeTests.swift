import SwiftUI
import Testing
@testable import Dokutresor

struct AppSmokeTests {
    @Test func contentViewExists() {
        let view = ContentView()
        #expect(view.body is DocumentListView)
    }
}
