import UIKit
import Testing
@testable import Dokutresor

private struct FakeScan: ScannedPagesProviding {
    let images: [UIImage]
    var pageCount: Int { images.count }
    func imageOfPage(at index: Int) -> UIImage { images[index] }
}

private func solidColorImage(_ color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

struct ScanConverterTests {
    @Test func convertsEachPageToJPEGData() throws {
        let scan = FakeScan(images: [solidColorImage(.red), solidColorImage(.blue)])
        let data = try ScanConverter.jpegData(from: scan)
        #expect(data.count == 2)
        #expect(data.allSatisfy { !$0.isEmpty })
    }

    @Test func emptyScanThrows() {
        let scan = FakeScan(images: [])
        #expect(throws: ScanConversionError.emptyScan) {
            try ScanConverter.jpegData(from: scan)
        }
    }
}
