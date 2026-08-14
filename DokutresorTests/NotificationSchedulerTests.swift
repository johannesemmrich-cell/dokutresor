import Foundation
import Testing
@testable import Dokutresor

struct NotificationSchedulerTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func plansOneReminderPerOffsetBeforeExpiry() {
        let expiryDate = Calendar.current.date(byAdding: .day, value: 40, to: now)!
        let document = Document(title: "Kühlschrank", expiryDate: expiryDate)

        let plans = NotificationScheduler.plan(for: document.reminderTarget, referenceDate: now)

        #expect(plans.count == 2)
        let expected30 = Calendar.current.date(byAdding: .day, value: -30, to: expiryDate)!
        let expected7 = Calendar.current.date(byAdding: .day, value: -7, to: expiryDate)!
        #expect(plans.map(\.fireDate).sorted() == [expected30, expected7].sorted())
        #expect(Set(plans.map(\.identifier)).count == 2)
    }

    @Test func filtersOutRemindersThatWouldFireInThePast() {
        let expiryDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        let document = Document(title: "Kühlschrank", expiryDate: expiryDate)

        let plans = NotificationScheduler.plan(for: document.reminderTarget, referenceDate: now)

        #expect(plans.isEmpty)
    }

    @Test func documentWithoutExpiryDateHasNoPlans() {
        let document = Document(title: "Zeugnis")
        let plans = NotificationScheduler.plan(for: document.reminderTarget, referenceDate: now)
        #expect(plans.isEmpty)
    }

    @Test func customReminderOffsetsAreRespected() {
        let expiryDate = Calendar.current.date(byAdding: .day, value: 10, to: now)!
        let document = Document(title: "Test", expiryDate: expiryDate, reminderOffsetsInDays: [1])

        let plans = NotificationScheduler.plan(for: document.reminderTarget, referenceDate: now)

        #expect(plans.count == 1)
        #expect(plans.first?.fireDate == Calendar.current.date(byAdding: .day, value: -1, to: expiryDate))
    }
}
