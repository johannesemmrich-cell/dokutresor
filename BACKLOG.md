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

- [ ] `Category`-Enum/Model: Beleg/Garantie, Urkunde/Zeugnis, Vertrag, Versicherung, Sonstiges
- [ ] `Tag`-Model
- [ ] `Document`-Model: Titel, Aussteller, Datum, Kategorie, Tags, OCR-Volltext, Ablaufdatum,
      Erinnerungs-Offsets, Bild-/PDF-Referenz(en)
- [ ] Validierung/Defaults (z.B. Standard-Erinnerungs-Offsets 30/7 Tage)
- [ ] Unit-Tests fürs Modell (Erstellung, Defaults, Kategorien)

## M2 – CloudKit-Sync-Integration

- [ ] `ModelContainer` mit CloudKit-Konfiguration (private Datenbank)
- [ ] Entitlements/Capabilities (iCloud, CloudKit-Container, Push für Sync) – bereits im
      Grundgerüst vorbereitet, hier verdrahten
- [ ] Fehlerbehandlung, falls iCloud nicht verfügbar/nicht angemeldet
- [ ] Tests für Container-Setup (soweit ohne echtes iCloud-Konto testbar)

## M3 – Kamera-Scan-Flow (VisionKit)

- [ ] `ScanService`: Wrapper um `VNDocumentCameraViewController`
- [ ] SwiftUI-Integration (`UIViewControllerRepresentable`)
- [ ] Mehrseiten-Scan → Dokument mit mehreren Seiten
- [ ] Import aus Fotos/Dateien als Alternative zum Scan
- [ ] ViewModel-Tests ohne UIKit-Abhängigkeit, wo möglich

## M4 – OCR-Extraktion (Vision) + Heuristik

- [ ] `OCRService`: `VNRecognizeTextRequest` über Scan-Bilder, liefert Volltext
- [ ] Heuristik: Aussteller/Händler aus Belegtext erkennen
- [ ] Heuristik: Datum aus deutschem Belegtext erkennen (diverse Formate)
- [ ] Heuristik: Garantiefrist/Ablaufdatum erkennen ("Garantie 24 Monate", "gültig bis", etc.)
- [ ] Unit-Tests mit synthetischen deutschen Beleg-/Dokumenttexten (keine echten Testdaten)

## M5 – Dokument-Liste + Suche/Filter

- [ ] Liste aller Dokumente (adaptive Layout, `NavigationSplitView`)
- [ ] Volltextsuche über OCR-Text, Titel, Kategorie, Tags
- [ ] Filter nach Kategorie/Tags
- [ ] ViewModel-Tests für Such-/Filterlogik

## M6 – Dokument-Detailansicht + manuelle Korrektur

- [ ] Detail-View mit Bild-/PDF-Viewer
- [ ] Erkannte Felder editierbar (Aussteller, Datum, Ablaufdatum, Kategorie, Tags)
- [ ] Speichern/Verwerfen von Korrekturen
- [ ] ViewModel-Tests für Korrektur-Flow

## M7 – Lokale Notifications für Ablauffristen

- [ ] `NotificationService`: lokale Erinnerungen vor Ablaufdatum planen
- [ ] Standard 30 und 7 Tage vorher, konfigurierbar pro Dokument
- [ ] Erinnerungen aktualisieren/löschen bei Änderung/Löschung des Dokuments
- [ ] Unit-Tests für Planungslogik (Datumsberechnung, Konfigurierbarkeit)

## M8 – Face ID/Touch ID App-Sperre

- [ ] `AuthService`: LocalAuthentication-Wrapper (Face ID/Touch ID + Passcode-Fallback)
- [ ] App-Sperre beim Start/Foreground
- [ ] Tests für AuthService-Logik (soweit ohne echte Biometrie testbar, z.B. Zustandsautomat)

## M9 – Onboarding/Leerzustand/Fehlerbehandlung

- [ ] Leerzustand, wenn noch keine Dokumente vorhanden
- [ ] Kurzes Onboarding beim ersten Start
- [ ] Fehlerbehandlung: Kamera-Zugriff verweigert
- [ ] Fehlerbehandlung: Face ID nicht verfügbar/verweigert
- [ ] Fehlerbehandlung: OCR liefert keinen Text

## M10 – Doku & Abschluss

- [x] README mit Setup-Anleitung und Architektur-Überblick
- [ ] Finale Durchsicht: keine TODOs/Platzhalter, keine echten Testdaten im Repo
- [ ] Statusbericht an Nutzer mit Link zum Repo und offenen manuellen Xcode-Schritten
