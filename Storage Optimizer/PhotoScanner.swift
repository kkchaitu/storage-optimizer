import SwiftUI
import Photos
import Accelerate
import Combine

struct ScannedPhoto: Identifiable {
    let id: String
    let asset: PHAsset
    let hash: UInt64
    let blurScore: Double
}

@MainActor
final class PhotoScanner: ObservableObject {
    @Published var scanned: [ScannedPhoto] = []
    @Published var duplicates: [[ScannedPhoto]] = []
    @Published var blurred: [ScannedPhoto] = []
    @Published var isScanning: Bool = false
    private let imageManager = PHImageManager.default()

    var duplicateRecoverableBytes: Int {
        duplicates.reduce(0) { total, group in
            let recoverable = group.dropFirst().reduce(0) { $0 + self.storageItem(for: $1).sizeBytes }
            return total + recoverable
        }
    }

    var blurredRecoverableBytes: Int {
        blurred.reduce(0) { $0 + self.storageItem(for: $1).sizeBytes }
    }

    func scan() async {
        isScanning = true
        scanned.removeAll()
        duplicates.removeAll()
        blurred.removeAll()

        let status = await PhotoLibraryManager.shared.requestAuthorization()
        guard status == .authorized || status == .limited else {
            isScanning = false
            return
        }

        let fetch = PHAsset.fetchAssets(with: .image, options: nil)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        var temp: [ScannedPhoto] = []
        let target = CGSize(width: 128, height: 128)

        for idx in 0..<fetch.count {
            let asset = fetch.object(at: idx) as! PHAsset
            autoreleasepool {
                self.imageManager.requestImage(for: asset, targetSize: target, contentMode: .aspectFit, options: options) { uiImage, _ in
                    guard let uiImage = uiImage, let cg = uiImage.cgImage else { return }
                    let hash = self.averageHash(from: cg)
                    let blur = self.laplacianVariance(from: cg)
                    let scannedPhoto = ScannedPhoto(id: asset.localIdentifier, asset: asset, hash: hash, blurScore: blur)
                    temp.append(scannedPhoto)
                }
            }
        }

        scanned = temp
        blurred = scanned.filter { $0.blurScore < 100 }

        var groups: [[ScannedPhoto]] = []
        var used = Set<String>()

        for i in 0..<scanned.count {
            let current = scanned[i]
            if used.contains(current.id) { continue }
            var group: [ScannedPhoto] = [current]

            for j in (i + 1)..<scanned.count {
                let candidate = scanned[j]
                if used.contains(candidate.id) { continue }
                if hamming(current.hash, candidate.hash) <= 6 {
                    group.append(candidate)
                    used.insert(candidate.id)
                }
            }

            if group.count > 1 {
                groups.append(group)
                group.forEach { used.insert($0.id) }
            }
        }

        duplicates = groups
        isScanning = false
    }

    func deleteAssets(withLocalIdentifiers identifiers: [String]) async -> Int {
        let fetch = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        guard fetch.count > 0 else { return 0 }

        let assets = (0..<fetch.count).compactMap { fetch.object(at: $0) }
        let deleteBytes = assets.reduce(0) { total, asset in
            let item = self.storageItem(for: ScannedPhoto(id: asset.localIdentifier, asset: asset, hash: 0, blurScore: 0))
            return total + item.sizeBytes
        }

        let deleted = await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }

        if deleted {
            removeDeletedAssets(withIdentifiers: identifiers)
            return deleteBytes
        }

        return 0
    }

    private func removeDeletedAssets(withIdentifiers identifiers: [String]) {
        scanned.removeAll { identifiers.contains($0.id) }
        blurred.removeAll { identifiers.contains($0.id) }
        duplicates = duplicates.map { group in
            group.filter { !identifiers.contains($0.id) }
        }.filter { $0.count > 1 }
    }

    func storageItem(for scannedPhoto: ScannedPhoto) -> StorageItem {
        let resources = PHAssetResource.assetResources(for: scannedPhoto.asset)
        let filename = resources.first?.originalFilename ?? "Photo"
        let sizeBytes = assetResourceSize(for: scannedPhoto.asset)
        let subtitle: String
        if let date = scannedPhoto.asset.creationDate {
            subtitle = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        } else {
            subtitle = "Photo asset"
        }

        return StorageItem(
            title: filename,
            subtitle: subtitle,
            sizeBytes: max(sizeBytes, 1_000),
            imageName: nil,
            filePath: scannedPhoto.asset.localIdentifier,
            assetIdentifier: scannedPhoto.asset.localIdentifier
        )
    }

    private func assetResourceSize(for asset: PHAsset) -> Int {
        let resources = PHAssetResource.assetResources(for: asset)
        for resource in resources {
            if let fileSize = resource.value(forKey: "fileSize") as? CLong {
                return Int(fileSize)
            }
        }
        return 0
    }

    // MARK: - Hashing (average hash 8x8)
    private func averageHash(from cg: CGImage) -> UInt64 {
        let size = CGSize(width: 8, height: 8)
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(size.width),
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return 0 }
        context.interpolationQuality = .high
        context.draw(cg, in: CGRect(origin: .zero, size: size))
        guard let data = context.data else { return 0 }
        let ptr = data.bindMemory(to: UInt8.self, capacity: Int(size.width * size.height))
        var sum: UInt64 = 0
        var pixels: [UInt8] = []
        for i in 0..<(Int(size.width * size.height)) {
            pixels.append(ptr[i])
            sum += UInt64(ptr[i])
        }
        let avg = sum / UInt64(pixels.count)
        var hash: UInt64 = 0
        for (i, p) in pixels.enumerated() {
            if UInt64(p) >= avg {
                hash |= (1 as UInt64) << UInt64(i)
            }
        }
        return hash
    }

    // MARK: - Blur metric via Laplacian variance using vImage
    private func laplacianVariance(from cg: CGImage) -> Double {
        let widthInt = cg.width
        let heightInt = cg.height
        let rowBytesGray = widthInt

        guard let context = CGContext(data: nil,
                                      width: widthInt,
                                      height: heightInt,
                                      bitsPerComponent: 8,
                                      bytesPerRow: rowBytesGray,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return 0 }
        context.interpolationQuality = .high
        context.draw(cg, in: CGRect(origin: .zero, size: CGSize(width: widthInt, height: heightInt)))
        guard let data = context.data else { return 0 }

        var srcBuffer = vImage_Buffer(data: data, height: vImagePixelCount(heightInt), width: vImagePixelCount(widthInt), rowBytes: rowBytesGray)

        let kernel: [Int16] = [0, 1, 0,
                               1,-4, 1,
                               0, 1, 0]
        let divisor: Int32 = 1

        guard let convData = malloc(Int(heightInt) * rowBytesGray) else { return 0 }
        var convBuffer = vImage_Buffer(data: convData, height: vImagePixelCount(heightInt), width: vImagePixelCount(widthInt), rowBytes: rowBytesGray)

        let convErr = vImageConvolve_Planar8(&srcBuffer, &convBuffer, nil, 0, 0, kernel, 3, 3, divisor, 0, vImage_Flags(kvImageEdgeExtend))
        if convErr != kvImageNoError {
            free(convData); return 0
        }

        let count = Int(widthInt * heightInt)
        let convPtr = convBuffer.data.bindMemory(to: UInt8.self, capacity: count)
        var mean: Double = 0
        for i in 0..<count { mean += Double(convPtr[i]) }
        mean /= Double(count)
        var variance: Double = 0
        for i in 0..<count { let v = Double(convPtr[i]) - mean; variance += v * v }
        variance /= Double(count)

        free(convData)
        return variance
    }

    private func hamming(_ a: UInt64, _ b: UInt64) -> Int {
        var x = a ^ b
        var count = 0
        while x != 0 { count += 1; x &= x - 1 }
        return count
    }
}
