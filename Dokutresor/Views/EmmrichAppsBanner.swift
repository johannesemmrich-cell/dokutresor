import SwiftUI

/// Sender-stamp am Ende der Einstellungen — analog zu Dresslyst/Restock/Sunwake:
/// dunkler Messing-Verlauf statt des App-eigenen Looks, bewusst als Familien-
/// Signatur abgesetzt statt als Feature gestylt.
struct EmmrichAppsBanner: View {
    private let websiteURL = URL(string: "https://emmrich-business.com")!
    private let brass = Color(red: 0.663, green: 0.557, blue: 0.357)
    private let cream = Color(red: 0.929, green: 0.886, blue: 0.800)

    var body: some View {
        Link(destination: websiteURL) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Rectangle().frame(width: 22, height: 3)
                    Rectangle().frame(width: 15, height: 3)
                    Rectangle().frame(width: 22, height: 3)
                }
                .foregroundStyle(brass)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Emmrich Apps")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(cream)
                    Text("Dresslyst · Restock · Sunwake · Dokutresor")
                        .font(.system(size: 11))
                        .foregroundStyle(brass)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(brass)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1647, green: 0.1294, blue: 0.0941),
                                Color(red: 0.2275, green: 0.1804, blue: 0.1176)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(brass.opacity(0.45), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EmmrichAppsBanner()
        .padding()
}
