import SwiftUI

struct DashboardView: View {
    @Binding var selectedCategory: ScanCategory?
    @Binding var recoveredBytes: Int
    @ObservedObject var scanner: PhotoScanner

    init(selectedCategory: Binding<ScanCategory?>, recoveredBytes: Binding<Int>, scanner: PhotoScanner) {
        self._selectedCategory = selectedCategory
        self._recoveredBytes = recoveredBytes
        self.scanner = scanner
    }

    private var totalStorage: Double = 128
    private var usedStorage: Double = 92.4
    private var freeStorage: Double { totalStorage - usedStorage }

    private var recoverableBytes: Int {
        scanner.duplicateRecoverableBytes + scanner.blurredRecoverableBytes
    }

    private var formattedRecoverable: String {
        if recoverableBytes >= 1_000_000 {
            return String(format: "%.1f GB", Double(recoverableBytes) / 1_000_000)
        }
        return String(format: "%.1f MB", Double(recoverableBytes) / 1_000_000)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                storageSummary
                scanAction
                categoryGrid
                recommendations
            }
            .padding()
            .background(Theme.lightLavender.opacity(0.4).edgesIgnoringSafeArea(.all))
        }
    }

    private var storageSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your storage health")
                .font(.title2.weight(.semibold))
                .foregroundColor(Theme.textPrimary)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Used")
                        .font(.footnote)
                        .foregroundColor(Theme.textSecondary)
                    Text(String(format: "%.1f GB", usedStorage))
                        .font(.title3.weight(.bold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Free")
                        .font(.footnote)
                        .foregroundColor(Theme.textSecondary)
                    Text(String(format: "%.1f GB", freeStorage))
                        .font(.title3.weight(.bold))
                }
            }

            ProgressView(value: usedStorage, total: totalStorage)
                .tint(Theme.primary)

            Text(recoverableBytes > 0 ? "Detected content can reclaim up to \(formattedRecoverable) of space." : "Scan your photo library to identify duplicates and blurred photos.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 24, x: 0, y: 10)
    }

    private var scanAction: some View {
        Button(action: startScan) {
            HStack {
                ProgressView() .opacity(scanner.isScanning ? 1 : 0)
                Text(scanner.isScanning ? "Scanning Photos…" : "Scan Photo Library")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(scanner.isScanning ? Color.gray : Theme.primary)
            .cornerRadius(16)
        }
        .disabled(scanner.isScanning)
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(ScanCategory.previewCategories) { category in
                Button(action: { selectedCategory = category }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: category.iconName)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(category.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Text(category.title)
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                        Text(subtitle(for: category))
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface)
                    .cornerRadius(18)
                }
            }
        }
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick actions")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            ForEach(ScanCategory.previewCategories) { category in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text(category.quickAction)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    Button(action: { selectedCategory = category }) {
                        Text("Review")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Theme.primary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Theme.surface)
                .cornerRadius(18)
            }
        }
    }

    private func subtitle(for category: ScanCategory) -> String {
        switch category.type {
        case .duplicates:
            return scanner.duplicates.isEmpty ? category.subtitle : "\(scanner.duplicates.count) duplicate groups found"
        case .blurredPhotos:
            return scanner.blurred.isEmpty ? category.subtitle : "\(scanner.blurred.count) blurred photos found"
        default:
            return category.subtitle
        }
    }

    private func startScan() {
        Task {
            await scanner.scan()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(selectedCategory: .constant(ScanCategory.previewCategories.first), recoveredBytes: .constant(0), scanner: PhotoScanner())
    }
}
