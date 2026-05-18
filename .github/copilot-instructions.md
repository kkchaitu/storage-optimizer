<!-- SPECKIT START -->

# Storage Optimizer - Development Guidelines

This is an iOS app for helping users reclaim device storage by detecting and safely deleting duplicate files, duplicate images, and blurry photos.

## Key Project Documents

**Read these in order for full context:**
1. **[CONSTITUTION.md](./CONSTITUTION.md)** - Project principles, mission, and guardrails
2. **[SPEC.md](./SPEC.md)** - Complete product specification with features, technical stack, and user flows
3. **[PLAN.md](./PLAN.md)** (when ready) - Detailed implementation roadmap and tasks

## Critical iOS Constraints to Remember

- ✅ **Deletion Confirmation:** iOS system popup is mandatory and cannot be bypassed
- ✅ **Sandbox Limitation:** Cannot scan entire file system; limited to app directories and user-granted access
- ✅ **Permission Required:** Must request `NSPhotoLibraryUsageDescription` before scanning
- ✅ **No Trash API:** Cannot programmatically empty Recently Deleted album; guide user to Photos app instead
- ✅ **Async Operations:** All scanning must happen off the main thread

## Technology Stack

- **UI:** SwiftUI
- **Photo Access:** Photos & PhotosUI frameworks (PHAsset APIs)
- **File System:** FileManager
- **Image Processing:** CoreImage / Accelerate (Laplacian Variance for blur detection)
- **Hashing:** CryptoKit (SHA-256 for file duplicates, perceptual hash for images)
- **Async:** Swift async/await
- **Min iOS:** iOS 14+

## Key Features to Implement

1. **Dashboard** - Storage breakdown and quick scan stats
2. **Duplicate Detection** - Side-by-side comparison for files and images
3. **Blur Detector** - Grid view of blurry photos with sensitivity slider
4. **Safe Deletion** - User-controlled with confirmation dialogs

## Detection Algorithms

- **Image Duplicates:** Perceptual hashing (pHash/aHash) with 85%+ similarity threshold
- **File Duplicates:** SHA-256 hash comparison, flag all but oldest as duplicate
- **Blurry Images:** Laplacian Variance method (threshold: 100, adjustable)

<!-- SPECKIT END -->
