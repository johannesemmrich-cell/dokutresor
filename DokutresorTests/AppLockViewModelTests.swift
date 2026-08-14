import LocalAuthentication
import Testing
@testable import Dokutresor

private final class FakeBiometricAuth: BiometricAuthenticating {
    var canEvaluateResult: (canEvaluate: Bool, error: Error?) = (true, nil)
    var evaluateResult: Result<Bool, Error> = .success(true)

    func canEvaluate(policy: LAPolicy) -> (canEvaluate: Bool, error: Error?) {
        canEvaluateResult
    }

    func evaluate(policy: LAPolicy, reason: String) async throws -> Bool {
        try evaluateResult.get()
    }
}

private struct StubError: Error, LocalizedError {
    var errorDescription: String? { "Simulierter Fehler" }
}

@MainActor
struct AppLockViewModelTests {
    @Test func initialStateIsLocked() {
        let viewModel = AppLockViewModel(contextFactory: { FakeBiometricAuth() })
        #expect(viewModel.state == .locked)
    }

    @Test func successfulAuthenticationUnlocks() async {
        let auth = FakeBiometricAuth()
        auth.evaluateResult = .success(true)
        let viewModel = AppLockViewModel(contextFactory: { auth })

        await viewModel.authenticate()

        #expect(viewModel.state == .unlocked)
    }

    @Test func unavailableBiometricsFailsWithoutEvaluating() async {
        let auth = FakeBiometricAuth()
        auth.canEvaluateResult = (false, StubError())
        let viewModel = AppLockViewModel(contextFactory: { auth })

        await viewModel.authenticate()

        guard case .failed = viewModel.state else {
            Issue.record("Erwartete .failed, bekam \(viewModel.state)")
            return
        }
    }

    @Test func failedEvaluationResultsInFailedState() async {
        let auth = FakeBiometricAuth()
        auth.evaluateResult = .success(false)
        let viewModel = AppLockViewModel(contextFactory: { auth })

        await viewModel.authenticate()

        guard case .failed = viewModel.state else {
            Issue.record("Erwartete .failed, bekam \(viewModel.state)")
            return
        }
    }

    @Test func throwingEvaluationResultsInFailedState() async {
        let auth = FakeBiometricAuth()
        auth.evaluateResult = .failure(StubError())
        let viewModel = AppLockViewModel(contextFactory: { auth })

        await viewModel.authenticate()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Erwartete .failed, bekam \(viewModel.state)")
            return
        }
        #expect(message.contains("Simulierter Fehler"))
    }

    @Test func lockResetsStateFromUnlocked() async {
        let auth = FakeBiometricAuth()
        let viewModel = AppLockViewModel(contextFactory: { auth })
        await viewModel.authenticate()
        #expect(viewModel.state == .unlocked)

        viewModel.lock()

        #expect(viewModel.state == .locked)
    }
}
