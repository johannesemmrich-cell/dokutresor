import UIKit
import Testing
@testable import Dokutresor

private func renderTextImage(_ string: String) -> UIImage {
    let size = CGSize(width: 600, height: 200)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 72),
            .foregroundColor: UIColor.black
        ]
        string.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
    }
}

struct OCRServiceTests {
    @Test func recognizesLargeClearText() async throws {
        let image = renderTextImage("TESTFIRMA")
        let data = try #require(image.pngData())
        let text = try await OCRService.recognizeText(in: data)
        #expect(text.uppercased().contains("TESTFIRMA"))
    }

    @Test func throwsOnInvalidImageData() async {
        await #expect(throws: OCRError.invalidImage) {
            _ = try await OCRService.recognizeText(in: Data([0x00, 0x01]))
        }
    }
}
