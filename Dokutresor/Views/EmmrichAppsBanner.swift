import SwiftUI

/// Sender-stamp am Ende der Einstellungen — analog zu Dresslyst/Restock/Sunwake.
struct EmmrichAppsBanner: View {
    private let websiteURL = URL(string: "https://emmrich-business.com")!
    private let brass = Color(red: 0xA9 / 255, green: 0x8E / 255, blue: 0x5B / 255)

    var body: some View {
        Link(destination: websiteURL) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Rectangle().frame(width: 22, height: 3)
                    Rectangle().frame(width: 15, height: 3)
                    Rectangle().frame(width: 22, height: 3)
                }
                .foregroundStyle(brass)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Emmrich Apps")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Dresslyst · Restock · Sunwake · Dokutresor")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(brass.opacity(0.45), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}

#Preview {
    EmmrichAppsBanner()
        .padding()
}
