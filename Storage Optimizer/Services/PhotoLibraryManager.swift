import Foundation
import Photos
import Combine

@MainActor
final class PhotoLibraryManager: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isScanning: Bool = false

    static let shared = PhotoLibraryManager()

    private init() {
        updateStatus()
    }

    func updateStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.authorizationStatus = status
                    cont.resume(returning: status)
                }
            }
        }
    }

    func startScanning() {
        isScanning = true
    }

    func stopScanning() {
        isScanning = false
    }
}
