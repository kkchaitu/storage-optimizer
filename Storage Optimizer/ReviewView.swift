import SwiftUI

struct ReviewView: View {
    let category: ScanCategory
    @ObservedObject var scanner: PhotoScanner
    @Binding var recoveredBytes: Int
    @Binding var showSuccess: Bool
    @State private var selectedItems: Set<UUID> = []
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            actionBar
        }
        .background(Theme.lightLavender.opacity(0.3).edgesIgnoringSafeArea(.all))
        .alert("Delete selected items", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task { await deleteConfirmed() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the selected items from your library or mark them as cleaned.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.largeTitle.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            Text(category.description)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                if items.isEmpty {
                    Text("No items found yet. Scan your library to populate this section.")
                        .font(.body)
                        .foregroundColor(Theme.textSecondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(items) { item in
                        ReviewItemRow(item: item, isSelected: selectedItems.contains(item.id))
                            .onTapGesture { toggleSelection(item) }
                    }
                }
            }
            .padding()
        }
    }

    private var actionBar: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Selected")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.textSecondary)
                    Text(formattedSelection)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                }
                Spacer()
                Button(action: reviewAll) {
                    Text("Select all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.primary)
                }
            }

            Button(action: { showDeleteConfirmation = true }) {
                Text(isDeleting ? "Deleting…" : "Delete Selected")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedItems.isEmpty || isDeleting ? Color.gray.opacity(0.5) : Theme.primary)
                    .cornerRadius(16)
            }
            .disabled(selectedItems.isEmpty || isDeleting)
        }
        .padding()
    }

    private var formattedSelection: String {
        let count = selectedItems.count
        return count == 0 ? "None" : "\(count) item\(count == 1 ? "" : "s")"
    }

    private var items: [StorageItem] {
        switch category.type {
        case .duplicates:
            return scanner.duplicates.flatMap { $0.map(scanner.storageItem) }
        case .blurredPhotos:
            return scanner.blurred.map(scanner.storageItem)
        default:
            return category.items
        }
    }

    private func toggleSelection(_ item: StorageItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    private func reviewAll() {
        selectedItems = Set(items.map { $0.id })
    }

    private func deleteConfirmed() async {
        isDeleting = true
        let selected = items.filter { selectedItems.contains($0.id) }
        let totalBytes = selected.reduce(0) { $0 + $1.sizeBytes }

        if selected.contains(where: { $0.assetIdentifier != nil }) {
            let assetIDs = selected.compactMap(\.assetIdentifier)
            let deletedBytes = await scanner.deleteAssets(withLocalIdentifiers: assetIDs)
            recoveredBytes = max(deletedBytes, totalBytes)
        } else {
            recoveredBytes = totalBytes
        }

        isDeleting = false
        showSuccess = true
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(category: ScanCategory.previewCategories[0], scanner: PhotoScanner(), recoveredBytes: .constant(0), showSuccess: .constant(false))
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = 8.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
