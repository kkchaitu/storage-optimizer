import SwiftUI

struct ScanCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    let description: String
    let quickAction: String
    let items: [StorageItem]
}

extension ScanCategory {
    static let previewCategories: [ScanCategory] = [
        ScanCategory(
            title: "Duplicates",
            subtitle: "Review repeated files",
            iconName: "doc.on.doc",
            accentColor: Color.purple,
            description: "Compare duplicate items side by side and keep only the best version.",
            quickAction: "Clean duplicates",
            items: [
                StorageItem(title: "IMG_2024.jpg", subtitle: "Photo copy from Camera roll", sizeBytes: 2_400_000, filePath: "Photos/Camera Roll/IMG_2024.jpg"),
                StorageItem(title: "IMG_2024.jpg", subtitle: "Copy in Downloads", sizeBytes: 2_400_000, filePath: "Downloads/IMG_2024.jpg"),
                StorageItem(title: "Screenshot 15.png", subtitle: "Same screenshot saved twice", sizeBytes: 1_120_000, filePath: "Screenshots/Screenshot 15.png"),
                StorageItem(title: "Report.pdf", subtitle: "Duplicate download file", sizeBytes: 4_800_000, filePath: "Documents/Report.pdf")
            ]
        ),
        ScanCategory(
            title: "Blurred Photos",
            subtitle: "Keep sharper memories",
            iconName: "eye.slash",
            accentColor: Color.blue,
            description: "Review blurred shots and clear up space without losing the best pictures.",
            quickAction: "Review photos",
            items: [
                StorageItem(title: "IMG_3544.jpg", subtitle: "Fuzzy portrait from last week", sizeBytes: 2_750_000, filePath: "Photos/Camera Roll/IMG_3544.jpg"),
                StorageItem(title: "IMG_3591.jpg", subtitle: "Blurry motion capture", sizeBytes: 3_100_000, filePath: "Photos/Camera Roll/IMG_3591.jpg"),
                StorageItem(title: "IMG_3620.jpg", subtitle: "Low-light image", sizeBytes: 2_220_000, filePath: "Photos/Camera Roll/IMG_3620.jpg")
            ]
        ),
        ScanCategory(
            title: "Large Videos",
            subtitle: "Trim bulk media",
            iconName: "video.fill",
            accentColor: Color.orange,
            description: "Identify videos that consume lots of storage so you can delete or archive them.",
            quickAction: "Check videos",
            items: [
                StorageItem(title: "Wedding.mov", subtitle: "High-resolution clip", sizeBytes: 68_000_000, filePath: "Videos/Family/Wedding.mov"),
                StorageItem(title: "Conference.mp4", subtitle: "Long screen recording", sizeBytes: 124_000_000, filePath: "Videos/Recordings/Conference.mp4"),
                StorageItem(title: "Travel.mov", subtitle: "4K scenic video", sizeBytes: 82_000_000, filePath: "Videos/Travel/Travel.mov")
            ]
        ),
        ScanCategory(
            title: "Large Files",
            subtitle: "Documents and downloads",
            iconName: "folder.fill",
            accentColor: Color.green,
            description: "Find oversized documents, zip files, and downloads that you can remove safely.",
            quickAction: "Inspect files",
            items: [
                StorageItem(title: "Presentation.pptx", subtitle: "Project deck", sizeBytes: 32_000_000, filePath: "Documents/Work/Presentation.pptx"),
                StorageItem(title: "Archive.zip", subtitle: "Old backup archive", sizeBytes: 42_000_000, filePath: "Downloads/Archive.zip"),
                StorageItem(title: "Magazine.pdf", subtitle: "Downloaded PDF", sizeBytes: 18_000_000, filePath: "Documents/Magazines/Magazine.pdf")
            ]
        )
    ]
}
