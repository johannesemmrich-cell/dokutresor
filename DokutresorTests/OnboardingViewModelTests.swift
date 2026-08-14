import Foundation
import Testing
@testable import Dokutresor

struct OnboardingViewModelTests {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "OnboardingViewModelTests-\(UUID().uuidString)")!
    }

    @Test func hasNotCompletedOnboardingByDefault() {
        let viewModel = OnboardingViewModel(defaults: makeDefaults())
        #expect(viewModel.hasCompletedOnboarding == false)
    }

    @Test func completeOnboardingPersistsFlag() {
        let defaults = makeDefaults()
        let viewModel = OnboardingViewModel(defaults: defaults)

        viewModel.completeOnboarding()

        #expect(viewModel.hasCompletedOnboarding == true)
        #expect(OnboardingViewModel(defaults: defaults).hasCompletedOnboarding == true)
    }
}
