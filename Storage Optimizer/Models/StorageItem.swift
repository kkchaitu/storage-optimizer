import Foundation

struct StorageItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let sizeBytes: Int
    let imageName: String?
    let filePath: String?
    let assetIdentifier: String?

    init(title: String, subtitle: String, sizeBytes: Int, imageName: String? = nil, filePath: String? = nil, assetIdentifier: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.sizeBytes = sizeBytes
        self.imageName = imageName
        self.filePath = filePath
        self.assetIdentifier = assetIdentifier
    }

    var sizeText: String {
        switch sizeBytes {
        case 0..<1_000:
            return "\(sizeBytes) bytes"
        case 1_000..<1_000_000:
            return String(format: "%.1f KB", Double(sizeBytes) / 1_000)
        default:
            return String(format: "%.1f MB", Double(sizeBytes) / 1_000_000)
        }
    }
}
