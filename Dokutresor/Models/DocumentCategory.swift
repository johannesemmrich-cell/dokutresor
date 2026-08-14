import Foundation

enum DocumentCategory: String, Codable, CaseIterable, Identifiable {
    case receipt = "Beleg/Garantie"
    case certificate = "Urkunde/Zeugnis"
    case contract = "Vertrag"
    case insurance = "Versicherung"
    case other = "Sonstiges"

    var id: String { rawValue }
}
