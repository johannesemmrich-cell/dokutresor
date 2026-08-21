import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var allDocuments: [Document]
    @AppStorage("appearanceMode") private var appearanceMode: String = "auto"
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteAllFinalConfirmation = false

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

                Section("Benachrichtigungen") {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    } label: {
                        Label("Benachrichtigungen verwalten", systemImage: "bell")
                    }
                }

                Section("Darstellung") {
                    Picker(selection: $appearanceMode) {
                        Label("Automatisch", systemImage: "circle.lefthalf.filled")
                            .tag("auto")
                        Label("Hell", systemImage: "sun.max.fill")
                            .tag("light")
                        Label("Dunkel", systemImage: "moon.fill")
                            .tag("dark")
                    } label: {
                        Label("Erscheinungsbild", systemImage: "paintbrush")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteAllConfirmation = true
                    } label: {
                        Label("Alle Dokumente löschen", systemImage: "trash")
                    }
                    .disabled(allDocuments.isEmpty)
                } header: {
                    Text("Daten")
                } footer: {
                    Text("Löscht alle \(allDocuments.count) gescannten Dokumente unwiderruflich, auch aus deiner iCloud-Synchronisierung.")
                }

                Section("Support") {
                    Link(destination: URL(string: "mailto:support@emmrich-business.com?subject=Dokutresor%20Support")!) {
                        Label("Support kontaktieren", systemImage: "envelope")
                    }
                }

                Section("Rechtliches") {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Datenschutzerklärung", systemImage: "lock.shield")
                    }
                    NavigationLink {
                        ImpressumView()
                    } label: {
                        Label("Impressum", systemImage: "info.circle")
                    }
                    NavigationLink {
                        TermsOfUseView()
                    } label: {
                        Label("Nutzungsbedingungen", systemImage: "doc.text")
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
            .alert("Alle Dokumente löschen?", isPresented: $showDeleteAllConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Weiter", role: .destructive) {
                    showDeleteAllFinalConfirmation = true
                }
            } message: {
                Text("Alle \(allDocuments.count) Dokumente inklusive Scans, erkannter Daten und geplanter Erinnerungen werden unwiderruflich gelöscht.")
            }
            .alert("Wirklich endgültig löschen?", isPresented: $showDeleteAllFinalConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Alle löschen", role: .destructive) { deleteAllDocuments() }
            } message: {
                Text("Dieser Schritt kann nicht rückgängig gemacht werden.")
            }
        }
    }

    private func deleteAllDocuments() {
        let documentsToDelete = allDocuments
        Task {
            for document in documentsToDelete {
                await NotificationService().cancelReminders(for: document.reminderTarget)
            }
        }
        for document in documentsToDelete {
            modelContext.delete(document)
        }
    }
}

// MARK: - Privacy Policy

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                legalHeader(
                    icon: "lock.shield.fill",
                    title: "Datenschutzerklärung",
                    subtitle: "Zuletzt aktualisiert: August 2026"
                )

                legalSection("1. Verantwortlicher") {
                    Text("""
                    Verantwortlich für die Verarbeitung personenbezogener Daten im Rahmen dieser App ist:

                    Johannes Emmrich
                    E-Mail: support@emmrich-business.com
                    """)
                }

                legalSection("2. Welche Daten werden verarbeitet?") {
                    Text("""
                    Dokutresor speichert die Fotos/Scans deiner Dokumente sowie die daraus erkannten Angaben: Titel, Aussteller, Datum, Ablaufdatum, Kategorie, Tags und den per Texterkennung (Vision) extrahierten Volltext. Diese Verarbeitung findet vollständig auf deinem Gerät statt.

                    Für die Synchronisierung zwischen deinen Geräten werden diese Daten zusätzlich in der privaten CloudKit-Datenbank deines eigenen iCloud-Accounts abgelegt. Wir selbst betreiben dafür keinen eigenen Server – nur Apple und du haben im Rahmen von iCloud Zugriff auf diese Daten.
                    """)
                }

                legalSection("3. Berechtigungen") {
                    Text("""
                    Die App fragt folgende Gerätezugriffe ab:

                    **Kamera:** Zum Scannen von Dokumenten (VisionKit). Aufnahmen werden nur lokal bzw. in deiner privaten iCloud verarbeitet.

                    **Fotomediathek:** Um bereits vorhandene Fotos von Dokumenten hinzuzufügen.

                    **Dateien:** Um PDFs oder Bilder aus der Dateien-App zu importieren.

                    **Face ID/Touch ID:** Um die App und deine Dokumente vor unbefugtem Zugriff auf deinem Gerät zu schützen. Biometrische Daten verbleiben dabei ausschließlich in der Secure Enclave deines Geräts und werden von Dokutresor niemals gesehen oder gespeichert.

                    **Mitteilungen:** Um dich rechtzeitig vor Ablauf einer Garantie- oder Gültigkeitsfrist zu erinnern.

                    Du kannst diese Berechtigungen jederzeit in den iOS-Einstellungen verwalten.
                    """)
                }

                legalSection("4. Keine Weitergabe an Dritte") {
                    Text("""
                    Wir geben keine personenbezogenen Daten an Dritte weiter. Die App enthält keine Werbenetzwerke, kein Analytics-Tracking und keine Telemetrie. Die einzige externe Verbindung ist die Synchronisierung mit deinem eigenen privaten iCloud-Account über Apples CloudKit.

                    Die App funktioniert ohne eigenen Account oder Registrierung bei uns.
                    """)
                }

                legalSection("5. Datensicherheit") {
                    Text("""
                    Deine Dokumente werden lokal im geschützten App-Container deines iOS-Geräts gespeichert und zusätzlich über die private CloudKit-Datenbank deines iCloud-Accounts synchronisiert – für diese Übertragung gelten die Sicherheits- und Verschlüsselungsstandards von Apple. Der Zugriff auf die App selbst ist zusätzlich durch Face ID/Touch ID geschützt.
                    """)
                }

                legalSection("6. Deine Rechte") {
                    Text("""
                    Du kannst deine Daten jederzeit vollständig löschen:

                    • **Einzelne Dokumente:** Durch Wischen in der Liste oder den Löschen-Button in der Detailansicht
                    • **Alle Dokumente:** Über Einstellungen → „Alle Dokumente löschen"
                    • **iCloud-Daten:** Durch Löschen in der App oder Deaktivieren der iCloud-Synchronisierung für Dokutresor in den iOS-Einstellungen

                    Bei Fragen zu deinen Datenschutzrechten (Auskunft, Berichtigung, Löschung, Übertragbarkeit) wende dich an support@emmrich-business.com
                    """)
                }

                legalSection("7. Änderungen dieser Erklärung") {
                    Text("""
                    Diese Datenschutzerklärung kann bei wesentlichen Änderungen der App aktualisiert werden. Die jeweils aktuelle Version ist in der App abrufbar.
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("Datenschutzerklärung")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Impressum

struct ImpressumView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                legalHeader(
                    icon: "info.circle.fill",
                    title: "Impressum",
                    subtitle: "Angaben gemäß § 5 TMG"
                )

                legalSection("Anbieter") {
                    Text("""
                    Johannes Emmrich
                    Deutschland

                    E-Mail: support@emmrich-business.com
                    """)
                }

                legalSection("Verantwortlich für den Inhalt") {
                    Text("Johannes Emmrich (Anschrift wie oben)")
                }

                legalSection("Haftungsausschluss") {
                    Text("""
                    **Haftung für Inhalte**
                    Die Inhalte dieser App wurden mit größtmöglicher Sorgfalt erstellt. Für die Richtigkeit, Vollständigkeit und Aktualität der automatisch erkannten Angaben (z. B. Ablaufdaten) kann jedoch keine Gewähr übernommen werden – bitte prüfe wichtige Fristen zusätzlich selbst.

                    **Haftung für Links**
                    Diese App kann Links zu externen Websites enthalten. Auf die Inhalte dieser Seiten haben wir keinen Einfluss und übernehmen keine Haftung für diese externen Inhalte.
                    """)
                }

                legalSection("Urheberrecht") {
                    Text("""
                    Die durch den Anbieter erstellten Inhalte und Werke dieser App unterliegen dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der Grenzen des Urheberrechts bedürfen der schriftlichen Zustimmung des Anbieters.
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("Impressum")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Terms of Use

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                legalHeader(
                    icon: "doc.text.fill",
                    title: "Nutzungsbedingungen",
                    subtitle: "Zuletzt aktualisiert: August 2026"
                )

                legalSection("1. Geltungsbereich") {
                    Text("""
                    Diese Nutzungsbedingungen gelten für die Verwendung der iOS-App „Dokutresor" (nachfolgend „App"). Durch die Nutzung der App stimmst du diesen Bedingungen zu.
                    """)
                }

                legalSection("2. Leistungsumfang") {
                    Text("""
                    Dokutresor ist eine App zum Scannen, Erkennen und sicheren Verwalten von Dokumenten wie Kassenbons, Urkunden, Verträgen und Versicherungspolicen. Deine Dokumente werden lokal gespeichert und über dein privates iCloud-Konto zwischen deinen Geräten synchronisiert.

                    Für die iCloud-Synchronisierung wird eine Internetverbindung benötigt; bereits geladene Dokumente bleiben auch offline einsehbar.
                    """)
                }

                legalSection("3. Nutzungsbeschränkungen") {
                    Text("""
                    Du verpflichtest dich, die App ausschließlich für private, nicht-kommerzielle Zwecke zu nutzen. Insbesondere ist es untersagt:

                    • Die App zu dekompilieren, zu disassemblieren oder anderweitig rückzuentwickeln
                    • Die App für rechtswidrige Zwecke zu nutzen
                    • Die App oder Teile davon weiterzuverkaufen oder zu vermieten
                    """)
                }

                legalSection("4. Haftungsbeschränkung") {
                    Text("""
                    Die App wird „wie besehen" bereitgestellt. Der Anbieter übernimmt keine Gewähr für die ununterbrochene Verfügbarkeit oder fehlerfreie Funktion der App, einschließlich der automatischen Texterkennung.

                    Eine Haftung für den Verlust von in der App gespeicherten Daten ist ausgeschlossen. Es wird empfohlen, wichtige Originaldokumente zusätzlich aufzubewahren.
                    """)
                }

                legalSection("5. Geistiges Eigentum") {
                    Text("""
                    Alle Rechte an der App, ihrem Design und ihrem Code liegen beim Anbieter. Die Nutzung der App begründet kein Übertragungsrecht an geistigem Eigentum.
                    """)
                }

                legalSection("6. Änderungen") {
                    Text("""
                    Der Anbieter behält sich vor, diese Nutzungsbedingungen jederzeit zu ändern. Bei wesentlichen Änderungen wird innerhalb der App darauf hingewiesen. Die fortgesetzte Nutzung nach Änderungen gilt als Zustimmung.
                    """)
                }

                legalSection("7. Anwendbares Recht") {
                    Text("""
                    Es gilt das Recht der Bundesrepublik Deutschland. Gerichtsstand ist, soweit gesetzlich zulässig, der Sitz des Anbieters.
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("Nutzungsbedingungen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shared Legal Helpers

private func legalHeader(icon: String, title: String, subtitle: String) -> some View {
    VStack(spacing: 8) {
        Image(systemName: icon)
            .font(.system(size: 40))
            .foregroundStyle(.tint)
        Text(title)
            .font(.title2.weight(.bold))
        Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
}

private func legalSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.tint)
        content()
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Document.self, inMemory: true)
}
