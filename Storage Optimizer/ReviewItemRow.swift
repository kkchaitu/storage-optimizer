import SwiftUI

struct ReviewItemRow: View {
    let item: StorageItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? Theme.primary : Color.gray)
                .frame(width: 24)

            // Image preview or icon
            if let imageName = item.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Theme.primary.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)

                if let filePath = item.filePath {
                    Text(filePath)
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Size
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.sizeText)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding()
        .background(isSelected ? Theme.primary.opacity(0.1) : Theme.surface)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 8) {
        ReviewItemRow(
            item: StorageItem(
                title: "IMG_2024.jpg",
                subtitle: "Photo from Camera roll",
                sizeBytes: 2_400_000,
                imageName: "doc.fill",
                filePath: "Photos/Camera Roll/IMG_2024.jpg"
            ),
            isSelected: false
        )

        ReviewItemRow(
            item: StorageItem(
                title: "Wedding.mov",
                subtitle: "High-resolution video",
                sizeBytes: 68_000_000,
                filePath: "Videos/Family/Wedding.mov"
            ),
            isSelected: true
        )
    }
    .padding()
    .background(Theme.lightLavender.opacity(0.3))
}
