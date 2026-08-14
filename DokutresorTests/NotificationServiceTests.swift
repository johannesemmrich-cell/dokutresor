import Foundation
import UserNotifications
import Testing
@testable import Dokutresor

private final class FakeNotificationCenter: NotificationCenterScheduling, @unchecked Sendable {
    private(set) var addedRequests: [UNNotificationRequest] = []
    private(set) var removedIdentifierBatches: [[String]] = []
    var authorizationGranted = true

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        authorizationGranted
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        addedRequests
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifierBatches.append(identifiers)
        addedRequests.removeAll { identifiers.contains($0.identifier) }
    }
}

struct NotificationServiceTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func scheduleRemindersAddsOneRequestPerPlan() async {
        let center = FakeNotificationCenter()
        let service = NotificationService(center: center)
        let expiryDate = Calendar.current.date(byAdding: .day, value: 40, to: now)!
        let document = Document(title: "Kühlschrank", expiryDate: expiryDate)

        await service.scheduleReminders(for: document.reminderTarget, referenceDate: now)

        #expect(center.addedRequests.count == 2)
    }

    @Test func schedulingAgainRemovesPreviouslyScheduledRemindersForSameDocument() async {
        let center = FakeNotificationCenter()
        let service = NotificationService(center: center)
        let expiryDate = Calendar.current.date(byAdding: .day, value: 40, to: now)!
        let document = Document(title: "Kühlschrank", expiryDate: expiryDate)

        await service.scheduleReminders(for: document.reminderTarget, referenceDate: now)
        let firstIdentifiers = Set(center.addedRequests.map(\.identifier))

        document.reminderOffsetsInDays = [3]
        await service.scheduleReminders(for: document.reminderTarget, referenceDate: now)

        #expect(center.addedRequests.count == 1)
        #expect(center.addedRequests.first.map { !firstIdentifiers.contains($0.identifier) } == true)
    }

    @Test func cancelRemindersRemovesAllPendingRequestsForDocument() async {
        let center = FakeNotificationCenter()
        let service = NotificationService(center: center)
        let expiryDate = Calendar.current.date(byAdding: .day, value: 40, to: now)!
        let document = Document(title: "Kühlschrank", expiryDate: expiryDate)
        await service.scheduleReminders(for: document.reminderTarget, referenceDate: now)

        await service.cancelReminders(for: document.reminderTarget)

        #expect(center.addedRequests.isEmpty)
    }

    @Test func requestAuthorizationForwardsResultFromCenter() async throws {
        let center = FakeNotificationCenter()
        center.authorizationGranted = false
        let service = NotificationService(center: center)

        let granted = try await service.requestAuthorization()

        #expect(granted == false)
    }
}
