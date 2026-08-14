import UIKit
import VisionKit

protocol ScannedPagesProviding {
    var pageCount: Int { get }
    func imageOfPage(at index: Int) -> UIImage
}

extension VNDocumentCameraScan: ScannedPagesProviding {}

enum ScanConversionError: Error, Equatable {
    case emptyScan
    case pageEncodingFailed
}

enum ScanConverter {
    static func jpegData(
        from scan: ScannedPagesProviding,
        compressionQuality: CGFloat = 0.8
    ) throws -> [Data] {
        guard scan.pageCount > 0 else { throw ScanConversionError.emptyScan }
        return try (0..<scan.pageCount).map { index in
            guard let data = scan.imageOfPage(at: index).jpegData(compressionQuality: compressionQuality) else {
                throw ScanConversionError.pageEncodingFailed
            }
            return data
        }
    }
}
