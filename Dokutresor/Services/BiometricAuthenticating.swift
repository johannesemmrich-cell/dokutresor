import LocalAuthentication

protocol BiometricAuthenticating {
    func canEvaluate(policy: LAPolicy) -> (canEvaluate: Bool, error: Error?)
    func evaluate(policy: LAPolicy, reason: String) async throws -> Bool
}

extension LAContext: BiometricAuthenticating {
    func canEvaluate(policy: LAPolicy) -> (canEvaluate: Bool, error: Error?) {
        var error: NSError?
        let canEvaluate = canEvaluatePolicy(policy, error: &error)
        return (canEvaluate, error)
    }

    func evaluate(policy: LAPolicy, reason: String) async throws -> Bool {
        try await evaluatePolicy(policy, localizedReason: reason)
    }
}
