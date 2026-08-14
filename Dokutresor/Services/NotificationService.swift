import Foundation
import UserNotifications

protocol NotificationCenterScheduling {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: NotificationCenterScheduling {}

struct NotificationService {
    let center: NotificationCenterScheduling

    init(center: NotificationCenterScheduling = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminders(for target: ReminderTarget, referenceDate: Date = .now) async {
        await cancelReminders(for: target)
        for plan in NotificationScheduler.plan(for: target, referenceDate: referenceDate) {
            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body = plan.body
            content.sound = .default

            let triggerComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: plan.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(identifier: plan.identifier, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    func cancelReminders(for target: ReminderTarget) async {
        let prefix = target.id.uuidString
        let matchingIdentifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(prefix) }
        guard !matchingIdentifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
    }
}
