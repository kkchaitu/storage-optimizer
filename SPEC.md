# Product Specification: Storage Optimizer iOS App

## 1. Product Overview

**Objective:** Help iPhone users reclaim storage space by scanning the device's local file system and Photo Library to identify and safely delete duplicate files, duplicate images, and blurry photos.

**Target Users:** iPhone users concerned about device storage capacity and data organization.

**Key Value Proposition:** 
- Single dashboard view of total freeable space
- Intelligent duplicate detection across files and photos
- Blur detection to remove low-quality images
- Safe, user-controlled deletion workflow

---

## 2. Core Features & Requirements

### Feature 1: Dashboard & Storage Calculation

**User Experience:**
- App launches with a prominent dashboard displaying:
  - "Calculating..." or "Scanning..." state during initial scan
  - **Total Space Able to be Freed** (e.g., "You can free up 4.2 GB today")
  - Breakdown by category:
    - Duplicate Files (size, count)
    - Duplicate Images (size, count)
    - Blurry Images (size, count)
  - Quick action button: **"Empty System Trash"** (or guide to Photos app)
  - Call-to-action button: **"Review Items"**

**Technical Requirements:**
- Request `NSPhotoLibraryUsageDescription` permission on first launch or via onboarding
- Use `PHAsset` APIs to calculate Photo Library size
- Use `FileManager` to scan accessible app directories
- Perform all scanning asynchronously to avoid UI blocking
- Cache results for 1 hour to avoid repeated scans
- Display breakdown with SwiftUI progress bars and clear typography

**Acceptance Criteria:**
✅ Dashboard loads within 2 seconds  
✅ Storage calculations are within 5% accuracy  
✅ Scanning happens in background without freezing UI  
✅ User grants permission before scanning  

---

### Feature 2: Duplicate Images & Files Scanner

**User Experience:**
- Dedicated section showing detected duplicates
- **Side-by-Side Comparison View:**
  - Display Original image/file (unchecked by default)
  - Display Duplicate(s) (pre-checked by default)
  - Show metadata: File size, resolution, date created, file type
  - Visual thumbnail/preview for images
- **List View Alternative:**
  - Grid/list of duplicates grouped by similarity
  - Tap to expand and see detailed comparison
- Prominent **"Delete Selected"** button at the bottom
- Confirmation dialog before deletion
- Success notification after deletion

**Technical Requirements:**

*Image Duplicates:*
- Use perceptual hashing (pHash or aHash) to compare image pixel data
- Set similarity threshold to 85%+ to flag duplicates
- Leverage Apple's `PHAsset` APIs to fetch images
- Generate thumbnails using `PHImageManager` for quick preview
- Support comparison of images across years (old duplicates)

*File Duplicates:*
- Use `FileManager` to scan app directories and iCloud Drive (if accessible)
- Generate MD5 or SHA-256 hashes of files
- Group files by hash; flag all but the oldest as duplicates
- Support common file types: documents, videos, audio, archives

**Acceptance Criteria:**
✅ Duplicate detection sensitivity > 90% (true positives)  
✅ False positive rate < 2%  
✅ Side-by-side view loads within 1 second  
✅ User can select/deselect items individually  
✅ Deletion confirmation is mandatory  
✅ Progress indicator shown during deletion batch operation  

---

### Feature 3: Blurry Image Detector

**User Experience:**
- Dedicated section scanning Photo Library for blurry/out-of-focus images
- Grid view (3-4 columns) showing thumbnail previews
- Each image has:
  - **Blurriness Score** (e.g., "Low clarity - 32%") or simple visual indicator
  - Checkbox for selection
- One-tap **"Delete Selected Blurry Photos"** button
- Confirmation before deletion
- Results summary (e.g., "Removed 47 blurry photos, freed 1.2 GB")

**Technical Requirements:**
- Use **Laplacian Variance method** to detect blur:
  - Apply Laplacian kernel to image
  - Calculate variance of the result
  - If variance < threshold (e.g., 100-150), flag as blurry
- Implement using `CoreImage` or `Accelerate` framework for performance
- Process images asynchronously in batches
- Allow user to adjust sensitivity slider (Conservative / Balanced / Aggressive)
- Skip images < 500KB or very small resolution (< 640px width)

**Acceptance Criteria:**
✅ Blur detection runs without freezing UI  
✅ Detection accuracy > 85% on test dataset  
✅ User can adjust sensitivity  
✅ Grid loads within 2 seconds for 1000+ photos  
✅ Batch deletion works smoothly  

---

## 3. User Flow Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                       App Launch                                     │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │ Check Permissions &  │
                  │ Request if Needed    │
                  │ (Photos Access)      │
                  └──────────┬───────────┘
                             │
                             ▼
                  ┌──────────────────────────────────────────┐
                  │ Show "Calculating..." Dashboard            │
                  │ Scan Photo Library & File System (Async) │
                  │ Calculate sizes & hashes                 │
                  └──────────┬───────────────────────────────┘
                             │
                ┌────────────┼────────────────┐
                ▼            ▼                ▼
         ┌─────────────┐ ┌──────────┐  ┌────────────┐
         │ Duplicates  │ │ Blurry   │  │ Empty      │
         │ Files       │ │ Photos   │  │ Trash      │
         ├─────────────┤ ├──────────┤  │ (Guide)    │
         │ Side-by-    │ │ Grid     │  └────────────┘
         │ Side View   │ │ View     │
         │ • Original  │ │ • Score  │
         │ • Duplicate │ │ • Toggle │
         │ • Metadata  │ │ • Delete │
         │ • Delete    │ │          │
         │   Button    │ └──────────┘
         └─────────────┘
              │
              ▼
    ┌──────────────────────┐
    │ Confirmation Dialog  │
    │ "Delete N items?"    │
    └─────┬────────────────┘
          │
     ┌────┴────┐
     ▼         ▼
  [Cancel]  [Delete]
     │         │
     │         ▼
     │   ┌──────────────────┐
     │   │ System Popup:    │
     │   │ "Allow deletion?"│  (iOS mandated)
     │   └─────┬────────────┘
     │         │
     │    ┌────┴────┐
     │    ▼         ▼
     │ [Allow]  [Deny]
     │    │         │
     │    ▼         ▼
     │  [Success] [Cancelled]
     │  Notification
     │    │
     └────┴─► Back to Dashboard
```

---

## 4. Technical Stack & iOS Constraints

| Component | Technology | Notes |
|-----------|-----------|-------|
| **UI Framework** | SwiftUI | Lists, grids, animations, responsive layout |
| **Photo Access** | Photos & PhotosUI | PHAsset, PHAssetChangeRequest for deletion |
| **File System** | FileManager | Scan app sandbox + DocumentPicker for expanded access |
| **Image Processing** | CoreImage / Accelerate | Blur detection, thumbnail generation |
| **Hashing** | CryptoKit (SHA-256) | File duplication detection |
| **Async Operations** | Swift async/await | Background scanning, non-blocking UI |
| **Storage Queries** | PHAssetCollection, URLResourceValues | Efficient size calculations |
| **Minimum iOS Version** | iOS 14+ | Modern APIs, SwiftUI support |

---

## 5. Critical iOS Guardrails & Constraints

### ⚠️ Non-Negotiable Restrictions

1. **Deletion Confirmation Popup (Mandatory)**
   - When deleting a photo via `PHAssetChangeRequest`, iOS **always shows a system popup**: *"Allow 'Storage Optimizer' to delete this photo?"*
   - This is a native privacy feature; it **cannot be bypassed**
   - User must tap "Allow" for each deletion (or batch deleteions may be grouped)

2. **Sandbox Limitations**
   - iOS apps **cannot scan the entire file system** like desktop cleaners can
   - Can only scan:
     - App's own document directory (`Documents/`, `Library/`, `tmp/`)
     - iCloud Drive container (if enabled)
     - Files explicitly granted via DocumentPickerViewController
   - Cannot directly access other apps' data or system files

3. **Photo Library Permission**
   - Must request `NSPhotoLibraryUsageDescription` 
   - User can revoke at any time via Settings > Photos
   - App should gracefully handle permission denied state

4. **Empty Trash Limitations**
   - iOS does not provide an API to programmatically empty the Recently Deleted album
   - Solution: Provide a **deep link or guide** to the Photos app:
     ```swift
     if let url = URL(string: "photos-redirect://") {
         UIApplication.shared.open(url)
     }
     ```
   - Or show in-app instructions for manual deletion

5. **Performance Constraints**
   - Avoid blocking the main thread during scanning
   - Use `async/await` or `DispatchQueue.global()` for heavy operations
   - Limit hash computations for large files; consider sampling

---

## 6. Detection Algorithm Specifications

### Duplicate Image Detection (Perceptual Hash)

```
Input: Two UIImage objects
Process:
  1. Resize image to 8x8 (or 16x16 for higher precision)
  2. Convert to grayscale
  3. Compute pixel hash
  4. Compare Hamming distance between hashes
  5. If distance < threshold (e.g., 4 out of 64 bits), mark as duplicate

Threshold: 85%+ similarity
```

**Implementation Library Options:**
- SwiftHash (if available)
- Core Image + custom implementation
- OpenCV (via CocoaPods/SPM)

### Blur Detection (Laplacian Variance)

```
Input: UIImage
Process:
  1. Convert to grayscale
  2. Apply Laplacian kernel (edge detection filter)
  3. Calculate variance of Laplacian result
  4. If variance < threshold (e.g., 100-150), mark as blurry

Threshold (adjustable):
  - Conservative: > 150 (fewer false positives)
  - Balanced: > 100 (default)
  - Aggressive: > 50 (more aggressive, higher false positive rate)
```

**Implementation:**
```swift
import CoreImage

func calculateBluriness(image: UIImage) -> CGFloat {
    let context = CIContext()
    let ciImage = CIImage(image: image)
    let kernel = CIKernel.laplacian() // or custom
    // Apply and calculate variance
    return variance
}
```

---

## 7. User Scenarios & Edge Cases

### Scenario 1: Large Photo Library (10,000+ photos)
- **Challenge:** Scanning takes >30 seconds
- **Solution:** 
  - Show progress indicator
  - Cache results
  - Allow user to cancel and retry
  - Process in batches (e.g., 100 photos at a time)

### Scenario 2: Permission Denied
- **Challenge:** User denies photo access
- **Solution:**
  - Show friendly onboarding screen
  - Explain why permission is needed
  - Provide Settings deep link to enable
  - Gracefully disable photo-related features

### Scenario 3: iCloud Sync
- **Challenge:** Deleting a photo on device may affect iCloud library
- **Solution:**
  - Inform user: "Deletion is permanent and affects all synced devices"
  - Require confirmation for iCloud sync scenarios
  - Consider fetching iCloud status before deletion

### Scenario 4: Duplicate with Different Metadata
- **Challenge:** Same image saved twice with different dates/locations
- **Solution:**
  - Always keep the **oldest version** as original
  - Mark newer versions as duplicates
  - Show metadata to help user decide

---

## 8. Acceptance Criteria & Success Metrics

### Functional Requirements
- ✅ Dashboard displays within 2s on devices with < 100GB storage
- ✅ Duplicate detection accuracy > 90%
- ✅ Blur detection accuracy > 85%
- ✅ Supports iOS 14+
- ✅ All deletions require user confirmation
- ✅ Error handling for permission denied, network issues

### Performance Requirements
- ✅ Scanning < 30s for average device (< 100GB)
- ✅ UI remains responsive during scanning
- ✅ Memory usage < 500MB during operation
- ✅ Grid view renders > 30fps

### User Experience Requirements
- ✅ Onboarding explains app permissions
- ✅ Deletion workflow is clear and safe
- ✅ Results are presented in digestible chunks
- ✅ App works offline (no internet required)

---

## 9. Out of Scope (Phase 1)

- Cloud storage scanning (Google Drive, Dropbox, etc.)
- App cache cleanup
- Video duplicate detection
- Automatic deletion without user confirmation
- Cross-device synchronization
- Ad-supported or freemium model (design as premium)

---

## 10. Next Steps for Implementation

1. **Define Thresholds:**
   - Image similarity threshold: 85% Hamming distance
   - Blur variance threshold: 100 (adjustable by user)
   - File size threshold for hashing: Skip files < 100KB

2. **Prototype Blur Detection:**
   - Test Laplacian Variance on 100+ test images
   - Validate threshold values
   - Measure false positive rate

3. **Design UI Mockups:**
   - Dashboard layout
   - Side-by-side comparison view
   - Blur detection grid

4. **Set Up Testing:**
   - Unit tests for hash algorithms
   - UI tests for deletion workflow
   - Integration tests on physical devices

5. **Performance Optimization:**
   - Batch processing for large photo libraries
   - Caching strategies
   - Memory profiling

---

**Specification Version:** 1.0  
**Last Updated:** May 15, 2026  
**Status:** Ready for Implementation
