import SwiftUI

struct LockGateView: View {
    @State private var lockViewModel = AppLockViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            ContentView()
            if lockViewModel.state != .unlocked {
                LockedOverlayView(state: lockViewModel.state) {
                    Task { await lockViewModel.authenticate() }
                }
            }
        }
        .task {
            await lockViewModel.authenticate()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                lockViewModel.lock()
            }
        }
    }
}

private struct LockedOverlayView: View {
    let state: LockState
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Dokutresor ist gesperrt")
                    .font(.headline)
                if case .failed(let message) = state {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Button("Entsperren", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
