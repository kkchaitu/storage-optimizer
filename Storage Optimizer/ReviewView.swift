import SwiftUI

struct ReviewView: View {
    let category: ScanCategory
    @Binding var recoveredBytes: Int
    @Binding var showSuccess: Bool
    @State private var selectedItems: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            actionBar
        }
        .background(Theme.lightLavender.opacity(0.3).edgesIgnoringSafeArea(.all))
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
                ForEach(category.items) { item in
                    ReviewItemRow(item: item, isSelected: selectedItems.contains(item.id))
                        .onTapGesture {
                            toggleSelection(item)
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

            Button(action: deleteSelected) {
                Text("Delete Selected")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedItems.isEmpty ? Color.gray.opacity(0.5) : Theme.primary)
                    .cornerRadius(16)
            }
            .disabled(selectedItems.isEmpty)
        }
        .padding()
    }

    private var formattedSelection: String {
        let count = selectedItems.count
        return count == 0 ? "None" : "\(count) item\(count == 1 ? "" : "s")"
    }

    private func toggleSelection(_ item: StorageItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    private func reviewAll() {
        selectedItems = Set(category.items.map { $0.id })
    }

    private func deleteSelected() {
        let bytesRecovered = category.items.filter { selectedItems.contains($0.id) }.map(\.sizeBytes).reduce(0, +)
        recoveredBytes = bytesRecovered
        showSuccess = true
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(category: ScanCategory.previewCategories[0], recoveredBytes: .constant(0), showSuccess: .constant(false))
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
