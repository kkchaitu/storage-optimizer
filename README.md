# Storage Optimizer

Storage Optimizer is an iOS app designed to help users reclaim device storage by identifying and reviewing duplicate files, duplicate images, and blurry photos.

## Project Documents

- `CONSTITUTION.md` — Project mission, principles, technical guardrails, and iOS privacy constraints.
- `SPEC.md` — Full product specification including features, user flows, detection algorithms, and acceptance criteria.
- `PLAN.md` — Implementation roadmap broken into phases for development, testing, and release.

## Key Features

- Dashboard with freeable storage calculations
- Duplicate image and file scanning
- Side-by-side duplicate review
- Blurry photo detection using image quality analysis
- Safe deletion workflows with iOS privacy compliance

## Tech Stack

- SwiftUI
- Photos / PhotosUI frameworks
- FileManager and app sandbox scanning
- CoreImage / Accelerate for blur detection
- CryptoKit for hashing
- Swift Concurrency for asynchronous scans

## Notes

- The app respects iOS sandbox restrictions and user permissions.
- Deletion confirmation is handled by the system and cannot be bypassed.
- The app does not attempt to scan the full iOS file system.

## Getting Started

1. Open the Xcode workspace/project in `Storage Optimizer.xcodeproj`.
2. Review `Info.plist` and ensure privacy descriptions are configured.
3. Use the specification and plan files to guide implementation.
