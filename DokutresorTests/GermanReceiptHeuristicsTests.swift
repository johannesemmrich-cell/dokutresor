import Foundation
import Testing
@testable import Dokutresor

struct GermanReceiptHeuristicsTests {
    private func date(_ day: Int, _ month: Int, _ year: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func extractsIssuerDateAndWarrantyDurationFromReceipt() {
        let text = """
        MediaMarkt
        Musterstraße 1
        12345 Berlin

        Kassenbon
        Kühlschrank XY123        899,00 EUR
        Datum: 15.03.2026
        Garantie: 24 Monate

        Vielen Dank für Ihren Einkauf!
        """

        let fields = GermanReceiptHeuristics.extract(from: text)

        #expect(fields.issuer == "MediaMarkt")
        #expect(fields.documentDate == date(15, 3, 2026))
        #expect(fields.expiryDate == date(15, 3, 2028))
    }

    @Test func explicitGueltigBisDateTakesPrecedenceOverDuration() {
        let text = """
        Saturn Electronic GmbH
        Rechnung Nr. 45822

        Rechnungsdatum: 02.01.2026
        Garantie gültig bis 02.01.2029
        """

        let fields = GermanReceiptHeuristics.extract(from: text)

        #expect(fields.issuer == "Saturn Electronic GmbH")
        #expect(fields.documentDate == date(2, 1, 2026))
        #expect(fields.expiryDate == date(2, 1, 2029))
    }

    @Test func oneYearWarrantyIsAddedToDocumentDate() {
        let text = """
        Elektro Schmidt
        Datum: 01.06.2026
        1 Jahr Garantie auf alle Geräte
        """

        let fields = GermanReceiptHeuristics.extract(from: text)

        #expect(fields.expiryDate == date(1, 6, 2027))
    }

    @Test func plainDocumentWithoutDatesOrWarrantyHasNilExpiry() {
        let text = """
        Zeugnis

        Hiermit wird bestätigt, dass Max Mustermann die Ausbildung erfolgreich
        abgeschlossen hat.
        """

        let fields = GermanReceiptHeuristics.extract(from: text)

        #expect(fields.issuer == "Zeugnis")
        #expect(fields.documentDate == nil)
        #expect(fields.expiryDate == nil)
    }

    @Test func twoDigitYearIsExpandedToTwoThousands() {
        let text = "Datum: 15.03.26"

        let fields = GermanReceiptHeuristics.extract(from: text)

        #expect(fields.documentDate == date(15, 3, 2026))
    }
}
