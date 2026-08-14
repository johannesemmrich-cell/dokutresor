import Foundation

struct ExtractedReceiptFields: Equatable {
    var issuer: String?
    var documentDate: Date?
    var expiryDate: Date?
}

enum GermanReceiptHeuristics {
    private static let berlinCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        return calendar
    }()

    private static let explicitExpiryKeywords = [
        "gültig bis", "ablaufdatum", "garantie bis", "gewährleistung bis", "verfällt am"
    ]

    static func extract(from text: String) -> ExtractedReceiptFields {
        let issuer = extractIssuer(from: text)
        let documentDate = extractFirstDate(in: text)
        let expiryDate = extractExpiryDate(from: text, documentDate: documentDate)
        return ExtractedReceiptFields(issuer: issuer, documentDate: documentDate, expiryDate: expiryDate)
    }

    private static func extractIssuer(from text: String) -> String? {
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty }
    }

    private static func extractFirstDate(in text: String) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: #"\b(\d{1,2})\.(\d{1,2})\.(\d{2,4})\b"#) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }
        return date(fromDayMonthYearMatch: match, in: text)
    }

    private static func date(fromDayMonthYearMatch match: NSTextCheckingResult, in text: String) -> Date? {
        guard let dayRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 2), in: text),
              let yearRange = Range(match.range(at: 3), in: text),
              let day = Int(text[dayRange]),
              let month = Int(text[monthRange]),
              var year = Int(text[yearRange]),
              (1...31).contains(day),
              (1...12).contains(month)
        else { return nil }

        if year < 100 { year += 2000 }
        return berlinCalendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    private static func extractExpiryDate(from text: String, documentDate: Date?) -> Date? {
        if let explicit = extractExplicitExpiryDate(from: text) {
            return explicit
        }
        if let duration = extractWarrantyDuration(from: text) {
            return berlinCalendar.date(byAdding: duration, to: documentDate ?? .now)
        }
        return nil
    }

    private static func extractExplicitExpiryDate(from text: String) -> Date? {
        for keyword in explicitExpiryKeywords {
            guard let keywordRange = text.range(of: keyword, options: .caseInsensitive) else { continue }
            let remainder = String(text[keywordRange.upperBound...])
            if let date = extractFirstDate(in: remainder) {
                return date
            }
        }
        return nil
    }

    private static func extractWarrantyDuration(from text: String) -> DateComponents? {
        guard let regex = try? NSRegularExpression(pattern: #"(\d{1,3})\s*(Jahre|Jahr|Monate|Monat)\b"#, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let numberRange = Range(match.range(at: 1), in: text),
              let unitRange = Range(match.range(at: 2), in: text),
              let value = Int(text[numberRange])
        else { return nil }

        var components = DateComponents()
        if text[unitRange].lowercased().hasPrefix("jahr") {
            components.year = value
        } else {
            components.month = value
        }
        return components
    }
}
