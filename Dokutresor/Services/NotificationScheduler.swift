import Foundation

// Sendable Schnappschuss statt des SwiftData-Models selbst: Document ist nicht
// Sendable (an einen ModelContext gebunden) und darf nicht über Task-Grenzen
// hinweg eingefangen werden.
struct ReminderTarget: Sendable, Equatable {
    let id: UUID
    let title: String
    let expiryDate: Date?
    let reminderOffsetsInDays: [Int]
}

extension Document {
    var reminderTarget: ReminderTarget {
        ReminderTarget(id: id, title: title, expiryDate: expiryDate, reminderOffsetsInDays: reminderOffsetsInDays)
    }
}

struct NotificationPlan: Equatable {
    let identifier: String
    let fireDate: Date
    let title: String
    let body: String
}

enum NotificationScheduler {
    static func plan(for target: ReminderTarget, referenceDate: Date = .now) -> [NotificationPlan] {
        guard let expiryDate = target.expiryDate else { return [] }

        return target.reminderOffsetsInDays.compactMap { offset -> NotificationPlan? in
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -offset, to: expiryDate),
                  fireDate > referenceDate
            else { return nil }

            return NotificationPlan(
                identifier: "\(target.id.uuidString)-\(offset)",
                fireDate: fireDate,
                title: "Frist läuft bald ab",
                body: "\(target.title.isEmpty ? "Ein Dokument" : target.title) läuft in \(offset) Tagen ab."
            )
        }
    }
}
