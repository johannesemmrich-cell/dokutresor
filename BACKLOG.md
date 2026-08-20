# Dokutresor Backlog

Gruppiert nach Milestones, jeweils in kleine, einzeln testbare Tasks geschnitten. Workflow pro
Task: Test schreiben (muss rot sein) → minimalen Code schreiben, bis grün → `xcodebuild test`
komplett grün → committen → Task hier abhaken. Siehe auch die
[GitHub Issues](https://github.com/johannesemmrich-cell/dokutresor/issues), gruppiert nach denselben
Milestones.

## M0 – Projekt-Grundgerüst

- [x] XcodeGen-Setup (`project.yml`), `Dokutresor.xcodeproj` generiert & eingecheckt
- [x] Ordnerstruktur (`Models/`, `Services/`, `ViewModels/`, `Views/`, `DokutresorTests/`)
- [x] Leere, lauffähige App + Smoke-Test grün
- [x] GitHub-Repo (privat) angelegt, initialer Commit gepusht
- [x] CI-Workflow (Build+Test bei Push/PR), analog zu Restock/Dresslyst

## M1 – Datenmodell (SwiftData)

- [x] `Category`-Enum/Model: Beleg/Garantie, Urkunde/Zeugnis, Vertrag, Versicherung, Sonstiges
- [x] `Tag`-Model
- [x] `Document`-Model: Titel, Aussteller, Datum, Kategorie, Tags, OCR-Volltext, Ablaufdatum,
      Erinnerungs-Offsets, Bild-/PDF-Referenz(en)
- [x] Validierung/Defaults (z.B. Standard-Erinnerungs-Offsets 30/7 Tage)
- [x] Unit-Tests fürs Modell (Erstellung, Defaults, Kategorien)

## M2 – CloudKit-Sync-Integration

- [x] `ModelContainer` mit CloudKit-Konfiguration (private Datenbank)
- [x] Entitlements/Capabilities (iCloud, CloudKit-Container, Push für Sync) – bereits im
      Grundgerüst vorbereitet, hier verdrahten
- [x] Fehlerbehandlung, falls iCloud nicht verfügbar/nicht angemeldet
- [x] Tests für Container-Setup (soweit ohne echtes iCloud-Konto testbar)

## M3 – Kamera-Scan-Flow (VisionKit)

- [x] `ScanService`: Wrapper um `VNDocumentCameraViewController`
- [x] SwiftUI-Integration (`UIViewControllerRepresentable`)
- [x] Mehrseiten-Scan → Dokument mit mehreren Seiten
- [x] Import aus Fotos/Dateien als Alternative zum Scan
- [x] ViewModel-Tests ohne UIKit-Abhängigkeit, wo möglich

## M4 – OCR-Extraktion (Vision) + Heuristik

- [x] `OCRService`: `VNRecognizeTextRequest` über Scan-Bilder, liefert Volltext
- [x] Heuristik: Aussteller/Händler aus Belegtext erkennen
- [x] Heuristik: Datum aus deutschem Belegtext erkennen (diverse Formate)
- [x] Heuristik: Garantiefrist/Ablaufdatum erkennen ("Garantie 24 Monate", "gültig bis", etc.)
- [x] Unit-Tests mit synthetischen deutschen Beleg-/Dokumenttexten (keine echten Testdaten)

## M5 – Dokument-Liste + Suche/Filter

- [x] Liste aller Dokumente (adaptive Layout, `NavigationSplitView`)
- [x] Volltextsuche über OCR-Text, Titel, Kategorie, Tags
- [x] Filter nach Kategorie/Tags
- [x] ViewModel-Tests für Such-/Filterlogik

## M6 – Dokument-Detailansicht + manuelle Korrektur

- [x] Detail-View mit Bild-/PDF-Viewer
- [x] Erkannte Felder editierbar (Aussteller, Datum, Ablaufdatum, Kategorie, Tags)
- [x] Speichern/Verwerfen von Korrekturen
- [x] ViewModel-Tests für Korrektur-Flow

## M7 – Lokale Notifications für Ablauffristen

- [x] `NotificationService`: lokale Erinnerungen vor Ablaufdatum planen
- [x] Standard 30 und 7 Tage vorher, konfigurierbar pro Dokument
- [x] Erinnerungen aktualisieren/löschen bei Änderung/Löschung des Dokuments
- [x] Unit-Tests für Planungslogik (Datumsberechnung, Konfigurierbarkeit)

## M8 – Face ID/Touch ID App-Sperre

- [x] `AuthService`: LocalAuthentication-Wrapper (Face ID/Touch ID + Passcode-Fallback)
- [x] App-Sperre beim Start/Foreground
- [x] Tests für AuthService-Logik (soweit ohne echte Biometrie testbar, z.B. Zustandsautomat)

## M9 – Onboarding/Leerzustand/Fehlerbehandlung

- [x] Leerzustand, wenn noch keine Dokumente vorhanden
- [x] Kurzes Onboarding beim ersten Start
- [x] Fehlerbehandlung: Kamera-Zugriff verweigert
- [x] Fehlerbehandlung: Face ID nicht verfügbar/verweigert
- [x] Fehlerbehandlung: OCR liefert keinen Text

## M10 – Doku & Abschluss

- [x] README mit Setup-Anleitung und Architektur-Überblick
- [x] Finale Durchsicht: keine TODOs/Platzhalter, keine echten Testdaten im Repo
- [x] Statusbericht an Nutzer mit Link zum Repo und offenen manuellen Xcode-Schritten

## M11 – Dokumente löschen + Mehrseiten-Ansicht

- [x] Swipe-to-Delete in der Liste, Löschen-Button mit Bestätigungsdialog in der Detailansicht
- [x] Beim Löschen zuerst evtl. geplante Erinnerungen stornieren, dann aus dem ModelContext entfernen
- [x] Mehrseiten-Ansicht in der Detailansicht (TabView über alle Seiten statt nur der ersten)
- [x] Unit-Test fürs SwiftData-Löschen; verify-changes-Review (Build+Test+Multi-Agent) durchlaufen,
      zwei gefundene Regressionen (Bildgröße bei Einzelseite, eager Decode aller Seiten) behoben

## M12 – Export/Teilen, Einstellungen, Sortierung

- [x] `DocumentExportService`: Seiten eines Dokuments zu einer mehrseitigen PDF zusammenführen
      (Gegenstück zu `ImportConverter`), Unit-Tests (Einzel-/Mehrseiten, leere/undekodierbare Daten)
- [x] Teilen-Button in der Detailansicht (`ShareLink` über `Transferable`-PDF-Wrapper)
- [x] Sortierungsoptionen in der Dokumentliste (Neueste/Älteste zuerst, Titel A–Z, Ablaufdatum) als
      Menü im Toolbar, Auswahl persistiert über `UserDefaults`; Unit-Tests für alle Sortierungen
      inkl. Persistenz
- [x] `SettingsView` (Über, Support-Kontakt, Emmrich-Apps-Banner), erreichbar über Zahnrad-Symbol
      im Toolbar der Dokumentliste
- [x] Emmrich-Apps-Banner analog zu Dresslyst/Restock/Sunwake (Link zu emmrich-business.com)
- [x] `xcodebuild test` komplett grün (63 Tests)
