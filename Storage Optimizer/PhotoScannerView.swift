import SwiftUI
import Photos

struct PhotoScannerView: View {
    @ObservedObject var scanner: PhotoScanner
    @ObservedObject private var manager = PhotoLibraryManager.shared

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: startScan) {
                    Text(manager.isScanning ? "Scanning..." : "Scan Photo Library")
                        .font(.headline)
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()

            if !scanner.blurred.isEmpty {
                Section(header: Text("Blurred Photos").font(.headline).padding(.horizontal)) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(scanner.blurred) { sp in
                                PhotoThumbnail(asset: sp.asset)
                                    .frame(width: 120, height: 120)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            if !scanner.duplicates.isEmpty {
                Section(header: Text("Duplicate Groups").font(.headline).padding(.horizontal)) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(scanner.duplicates.indices, id: \ .self) { idx in
                                let group = scanner.duplicates[idx]
                                HStack(spacing: 12) {
                                    ForEach(group) { sp in
                                        PhotoThumbnail(asset: sp.asset)
                                            .frame(width: 88, height: 88)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Theme.surface)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Photo Scan")
        .background(Theme.lightLavender.opacity(0.2).edgesIgnoringSafeArea(.all))
    }

    private func startScan() {
        Task {
            if !(manager.authorizationStatus == .authorized || manager.authorizationStatus == .limited) {
                let status = await manager.requestAuthorization()
                guard status == .authorized || status == .limited else { return }
            }
            manager.startScanning()
            await scanner.scan()
            manager.stopScanning()
        }
    }
}

private struct PhotoThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.surface)
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
                    .task { await load() }
            }
        }
    }

    func load() async {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        await withCheckedContinuation { cont in
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { uiImage, _ in
                self.image = uiImage
                cont.resume()
            }
        }
    }
}

#Preview {
    PhotoScannerView(scanner: PhotoScanner())
}
