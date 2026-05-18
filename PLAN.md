# Implementation Plan: Storage Optimizer iOS App

## Purpose
This plan defines the concrete steps needed to implement the Storage Optimizer app based on the product specification.

## Scope
- Dashboard and storage calculation
- Duplicate detection for images and files
- Blur detection for photo quality
- Safe deletion workflows and iOS privacy guardrails
- SwiftUI-based user experience for review and cleanup

## Phase 1: Foundations

### 1. Project Setup
- [x] Confirm SwiftUI app target and minimum deployment target iOS 14+
- [x] Add required privacy descriptions to `Info.plist`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription` (if needed for deletion workflows)
- [x] Configure app entitlements and capabilities
- [x] Set up app directories for scan caching and results storage

### 2. Architecture
- [x] Define app state models
  - `ScanCategory` with `ScanCategoryType` enum
  - `StorageItem` with asset identifier support
  - `ScannedPhoto` (blur score and hash)
- [x] Build service layers
  - `PhotoLibraryManager` (authorization)
  - `PhotoScanner` (hashing, blur detection, deletion)
- [x] Establish async scanning workflows with Swift Concurrency
- [ ] Add a data persistence layer for cached scan results

## Phase 2: Dashboard & Scanning Flow

### 1. Dashboard UI
- [x] Create dashboard UI with SwiftUI
- [x] Show scanning status and total freeable space
- [x] Display category cards for:
  - Duplicate Files
  - Duplicate Images
  - Blurry Photos
- [ ] Add quick action button for "Empty System Trash" guidance

### 2. Scanning Implementation
- [x] Implement Photo Library permission flow
- [x] Compute file hashes (perceptual hash) for duplicate detection
- [x] Scan Photo Library assets with `PHAsset`
- [x] Compute total sizes for each category
- [ ] Cache scan results and update dashboard reactively

## Phase 3: Duplicate Detection

### 1. Duplicate Images
- [x] Implement image fingerprinting (8x8 average hash)
- [x] Compare images with Hamming distance threshold
- [x] Group duplicates automatically
- [x] Build review UI with selection and delete
- [x] Include metadata: file size, creation date

### 2. Duplicate Files
- [ ] Scan app sandbox and DocumentPicker-accessible files
- [ ] Generate SHA-256 hashes for file content
- [ ] Group exact binary duplicates
- [ ] Build review UI with file metadata

## Phase 4: Blur Detection

### 1. Blur Detection Algorithm
- [x] Implement Laplacian variance calculation using vImage
- [ ] Test thresholds for Conservative / Balanced / Aggressive modes
- [x] Use `Accelerate` framework for performance
- [ ] Add early skip for small images and thumbnails

### 2. Review UI
- [x] Build grid view for blurry photo candidates
- [ ] Show blurriness score or status label
- [x] Add selection checkboxes and batch delete button

## Phase 5: Deletion Workflow

### 1. Safe Deletion UI
- [x] Add delete confirmation dialog
- [x] Present system deletion authorization via `PHPhotoLibrary.performChanges`
- [x] Handle denial, success, and partial success cases
- [x] Show final summary after deletion (SuccessView)

### 2. System Trash Guidance
- [ ] Add a guide screen for emptying Photos trash
- [ ] Provide text instruction + deep link to Photos app
- [ ] Explain that direct system trash clearing is not available on iOS

## Phase 6: Polish & Quality Assurance

### 1. UX & Accessibility
- [ ] Ensure SwiftUI views are accessible
- [ ] Validate labels, buttons, and dynamic type support
- [ ] Add success/error messaging and retries

### 2. Performance
- [ ] Profile scanning and hash computation
- [ ] Optimize batch processing
- [ ] Ensure all heavy tasks run off the main thread

### 3. Testing
- [ ] Unit tests for:
  - hash generation
  - blur detection
  - duplicate grouping logic
- [ ] UI tests for main flows:
  - scanner dashboard
  - duplicate review
  - blur review
  - deletion confirmation
- [ ] Real-device testing for Photo Library access and deletion flow

## Phase 7: Release Preparation
- [ ] Update App Store metadata and screenshots
- [ ] Document privacy behavior clearly
- [ ] Validate app against Apple’s App Store review guidelines
- [ ] Confirm performance on multiple device models

## Milestones
1. **M1:** Dashboard + scanning core implementation
2. **M2:** Duplicate file/image review flow
3. **M3:** Blur detection and review UI
4. **M4:** Safe deletion workflow + iOS privacy compliance
5. **M5:** Testing, optimization, and release readiness

---

## Notes
- Keep all scanning and deletion actions user-triggered.
- Do not attempt to access non-user-authorized storage.
- Use clear wording around iOS limitations and required permissions.
