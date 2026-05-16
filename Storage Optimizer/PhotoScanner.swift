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
    private let imageManager = PHImageManager.default()

    func scan() async {
        scanned.removeAll()
        duplicates.removeAll()
        blurred.removeAll()

        let status = await PhotoLibraryManager.shared.requestAuthorization()
        guard status == .authorized || status == .limited else { return }

        let fetch = PHAsset.fetchAssets(with: .image, options: nil)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        var temp: [ScannedPhoto] = []

        let target = CGSize(width: 128, height: 128)

        fetch.enumerateObjects { (obj: PHAsset, _, _) in
            let asset = obj
            autoreleasepool {
                self.imageManager.requestImage(for: asset, targetSize: target, contentMode: .aspectFit, options: options) { uiImage, _ in
                    guard let uiImage = uiImage, let cg = uiImage.cgImage else { return }
                    let hash = self.averageHash(from: cg)
                    let blur = self.laplacianVariance(from: cg)
                    let sp = ScannedPhoto(id: asset.localIdentifier, asset: asset, hash: hash, blurScore: blur)
                    temp.append(sp)
                }
            }
        }

        // store scanned
        scanned = temp

        // detect blurred
        blurred = scanned.filter { $0.blurScore < 100 } // threshold, tune as needed

        // detect duplicates via hamming distance
        var groups: [[ScannedPhoto]] = []
        var used = Set<String>()
        for i in 0..<scanned.count {
            let a = scanned[i]
            if used.contains(a.id) { continue }
            var group: [ScannedPhoto] = [a]
            for j in (i+1)..<scanned.count {
                let b = scanned[j]
                if used.contains(b.id) { continue }
                let d = hamming(a.hash, b.hash)
                if d <= 6 { // threshold
                    group.append(b)
                    used.insert(b.id)
                }
            }
            if group.count > 1 {
                groups.append(group)
                group.forEach { used.insert($0.id) }
            }
        }
        duplicates = groups
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

        // Laplacian kernel
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

        // compute variance
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
