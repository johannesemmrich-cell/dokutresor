import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.doc.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Willkommen bei Dokutresor")
                .font(.title.bold())
            Text("""
            Scanne Kassenbons, Urkunden, Verträge und Versicherungspolicen. \
            Dokutresor erkennt automatisch Aussteller, Datum und Garantiefristen \
            und erinnert dich rechtzeitig, bevor eine Frist abläuft.
            """)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            Spacer()
            Button("Los geht's", action: onComplete)
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
        }
    }
}
