import Foundation
import LocalAuthentication
import Observation

enum LockState: Equatable {
    case locked
    case unlocked
    case failed(String)
}

@Observable
@MainActor
final class AppLockViewModel {
    private(set) var state: LockState = .locked
    private let contextFactory: () -> BiometricAuthenticating

    init(contextFactory: @escaping () -> BiometricAuthenticating = { LAContext() }) {
        self.contextFactory = contextFactory
    }

    func authenticate() async {
        let context = contextFactory()
        let policy = LAPolicy.deviceOwnerAuthentication

        let availability = context.canEvaluate(policy: policy)
        guard availability.canEvaluate else {
            state = .failed(availability.error?.localizedDescription ?? "Face ID/Touch ID ist auf diesem Gerät nicht verfügbar.")
            return
        }

        do {
            let success = try await context.evaluate(
                policy: policy,
                reason: "Entsperre Dokutresor, um deine Dokumente zu sehen."
            )
            state = success ? .unlocked : .failed("Authentifizierung fehlgeschlagen.")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func lock() {
        state = .locked
    }
}
