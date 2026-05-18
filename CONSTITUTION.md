# Storage Optimizer - Project Constitution

## Project Mission
Help iPhone users reclaim storage space through intelligent identification and safe removal of duplicate files, duplicate images, and blurry photos.

## Core Principles

### 1. **User Privacy & Security First**
- Respect Apple's iOS privacy sandbox and security guidelines
- Require explicit user permissions for Photo Library access
- Never bypass system confirmation dialogs (iOS mandates delete confirmations)
- Do not attempt to access files outside the app's sandbox or user-granted directories

### 2. **Safe & Reversible Operations**
- All deletions must be reviewed by the user before execution
- Provide side-by-side comparison views so users understand what they're deleting
- Pre-check duplicates; leave originals unchecked by default
- Guide users to the system Photos app for permanent trash deletion when needed

### 3. **Clean, Simple User Experience**
- Prominent dashboard showing total freeable space at a glance
- Clear breakdown of savings by category (duplicates, blurry photos)
- Straightforward scanning UI with minimal friction
- One-tap actions for reviewing and deleting items

### 4. **Accurate & Intelligent Detection**
- Use proven algorithms (perceptual hashing for images, SHA-256 for files)
- Implement Laplacian Variance for blur detection
- Validate results before presenting to users
- Set reasonable detection thresholds (similarity score, sharpness score)

### 5. **iOS-First Design**
- Leverage native SwiftUI and Apple frameworks (Photos, PhotosUI, CoreImage)
- Respect iOS performance guidelines and battery consumption
- Use modern iOS APIs (iOS 14+) for compatibility and efficiency
- Test on multiple device sizes and iOS versions

## Technical Guardrails

- **Deletion Confirmation:** iOS system will always show a deletion confirmation popup for photo deletions. This is non-negotiable.
- **File System Access:** Limited to app sandbox and files the user explicitly grants via DocumentPicker or iCloud Drive.
- **Photo Library Access:** Requires `NSPhotoLibraryUsageDescription` permission prompt.
- **Performance:** Scan operations must be asynchronous to prevent UI blocking.

## Success Criteria

✅ Dashboard displays accurate storage calculations  
✅ Duplicate detection works reliably (images & files)  
✅ Blur detection identifies out-of-focus photos  
✅ Side-by-side comparison UI makes deletion decisions clear  
✅ Deletion workflow is safe with confirmation prompts  
✅ App respects iOS privacy and sandbox constraints  
✅ UI is responsive and non-blocking  
