import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Über") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dokutresor")
                            .font(.headline)
                        Text("Ein sicherer, durchsuchbarer Ort für Dokumente, die du selten aber dringend brauchst.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    LabeledContent("Version", value: appVersion)
                }

                Section("Support") {
                    Link(destination: URL(string: "mailto:support@emmrich-business.com?subject=Dokutresor%20Support")!) {
                        Label("Support kontaktieren", systemImage: "envelope")
                    }
                }

                Section {
                    EmmrichAppsBanner()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Mehr von Emmrich")
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
