import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    private let defaults: UserDefaults
    private let key = "hasCompletedOnboarding"

    private(set) var hasCompletedOnboarding: Bool

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedOnboarding = defaults.bool(forKey: key)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: key)
    }
}
