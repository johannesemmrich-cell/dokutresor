import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    private let defaults: UserDefaults
    private let key = "hasCompletedOnboarding"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: key)
    }

    func completeOnboarding() {
        defaults.set(true, forKey: key)
    }
}
