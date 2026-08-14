# Dokutresor

Ein sicherer, durchsuchbarer Ort für Dokumente, die man selten aber dringend braucht:
Kassenbons/Rechnungen mit Garantiefrist, Zeugnisse, Urkunden, Versicherungspolicen, Verträge.

Foto machen → App erkennt automatisch die wichtigen Daten (on-device OCR) → Jahre später in
Sekunden wiederfinden.

## Architektur

- **Swift 6, SwiftUI**, iOS 17 als Minimum-Deployment-Target
- **Persistenz:** SwiftData mit CloudKit-Sync (private Datenbank, an die iCloud des Nutzers
  gebunden – kein eigener Server)
- **Scan:** VisionKit (`VNDocumentCameraViewController`), plus Import aus Fotos (PhotosPicker)
  und Dateien (`fileImporter`, Bilder + PDF). PDFs werden beim Import seitenweise zu Bildern
  gerastert (`ImportConverter`) und wie gescannte Seiten behandelt – es gibt bewusst keinen
  eigenen PDFKit-Live-Viewer, das hätte den MVP-Scope unnötig vergrößert.
- **OCR:** Vision (`VNRecognizeTextRequest`), vollständig on-device
- **Auth:** LocalAuthentication (Face ID/Touch ID) mit Passcode-Fallback
- **Notifications:** UNUserNotificationCenter, rein lokal
- **Muster:** MVVM – `Models/`, `Services/`, `ViewModels/`, `Views/`. ViewModels sind ohne
  UIKit/SwiftUI-Abhängigkeit testbar. Views nutzen `NavigationSplitView`/adaptive Layouts statt
  hart auf iPhone zugeschnittener Stacks, damit iPad/Mac später ohne Rewrite ergänzbar sind.
- **Tests:** Swift Testing (`import Testing`)

## Projekt-Erzeugung: XcodeGen + eingecheckter Xcodeproj

`project.yml` ist die Grundlage für `xcodegen generate`, aber **nicht** die laufende Quelle der
Wahrheit für CI oder für das, was tatsächlich gebaut wird. Analyse der Referenzprojekte
[Restock](https://github.com/johannesemmrich-cell/Restock) und Dresslyst hat gezeigt: beide
checken `*.xcodeproj` fest ein und lassen CI direkt dagegen bauen, weil `project.yml` mit der Zeit
gegenüber manuellen Xcode-Änderungen (Targets, Entitlements, Schemes) veraltet und ein
`xcodegen generate` in CI solche Änderungen stillschweigend verwerfen würde.

Dasselbe Prinzip gilt hier: `Dokutresor.xcodeproj` ist eingecheckt und die verbindliche Quelle.
CI führt **kein** `xcodegen generate` aus, sondern baut exakt das eingecheckte `.xcodeproj`.

- Neue Dateien/Targets **lokal** über `xcodegen generate` hinzufügen (in `project.yml` eintragen,
  dann `xcodegen generate` laufen lassen) und das Ergebnis mit committen.
- Sobald jemand manuell in Xcode Capabilities/Targets/Schemes ändert, ohne `project.yml`
  nachzuziehen, sollte man aufhören `xcodegen generate` laufen zu lassen (Drift-Gefahr) und
  stattdessen `project.pbxproj` direkt pflegen – wie bei Restock/Dresslyst.

## Bauen & Testen

```bash
xcodegen generate   # nur nötig nach Änderungen an project.yml

xcodebuild test \
  -project Dokutresor.xcodeproj \
  -scheme Dokutresor \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:DokutresorTests
```

## Manuelle Einmal-Schritte in Xcode

Diese Schritte lassen sich nicht automatisieren und müssen einmalig manuell in Xcode erledigt
werden:

1. **Signing:** Projekt in Xcode öffnen (`Dokutresor.xcodeproj`), unter „Signing & Capabilities“
   das eigene Apple-Entwicklerteam auswählen (in `project.yml`/Entitlements ist testweise dasselbe
   Team wie bei Restock/Dresslyst hinterlegt – `DEVELOPMENT_TEAM: XK87E2B3VR` – ggf. anpassen).
2. **CloudKit-Container freischalten:** In Xcode unter „Signing & Capabilities“ → „iCloud“ →
   CloudKit aktivieren und den Container `iCloud.com.emmrich.dokutresor` im
   [Apple Developer Portal](https://developer.apple.com/account) bzw. über Xcode anlegen/bestätigen.
3. **Push Notifications Capability:** Wird für stille CloudKit-Sync-Benachrichtigungen benötigt –
   in Xcode unter „Signing & Capabilities“ hinzufügen, falls nicht automatisch übernommen.
4. **Auf echtem Gerät testen:** Face ID, Kamera-Scan und CloudKit-Sync lassen sich nur auf einem
   echten Gerät (nicht im Simulator) vollständig verifizieren.
5. **CI aktuell rot wegen GitHub-Billing, nicht wegen des Codes:** Alle bisherigen Actions-Läufe
   scheitern sofort mit "The job was not started because recent account payments have failed or
   your spending limit needs to be increased." – das ist ein Account-Problem
   (GitHub → Settings → Billing & plans), keine fehlerhafte Workflow-Konfiguration. Lokal läuft
   `xcodebuild test` durchgehend grün (siehe Commit-Historie). Nach Behebung sollte der nächste
   Push automatisch grün laufen; falls nicht, bitte den Workflow-Log prüfen.

## Backlog

Siehe [`BACKLOG.md`](BACKLOG.md) sowie die [GitHub Issues](https://github.com/johannesemmrich-cell/dokutresor/issues).

## Entwicklungs-Workflow

Rot/Grün pro Task: Test schreiben (muss fehlschlagen) → minimalen Code schreiben, bis er grün ist
→ `xcodebuild test` komplett grün bestätigen → committen. Siehe Commit-Historie für Beispiele.
