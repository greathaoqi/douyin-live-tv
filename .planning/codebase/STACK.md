# Technology Stack

**Analysis Date:** 2026-03-31

## Languages

**Primary:**
- Swift 5.x - Main application, all layers including UI, data, and domain logic

**Secondary:**
- XML - Project configuration (Info.plist, project.pbxproj)

## Runtime

**Environment:**
- tvOS 17+ - Target platform is Apple TV

**Package Manager:**
- Swift Package Manager (built into Xcode)
- Lockfile: Not checked into repo (managed by Xcode)

## Frameworks

**Core:**
- SwiftUI - Declarative UI framework for all user interfaces
- SwiftData - Local persistence and data modeling framework
- AVKit - Video playback infrastructure (used by PlayerService)
- TVMLKit/TVTopShelf - Top Shelf extension for Apple TV home screen integration
- Combine - Reactive programming for state observation
- Foundation - Core system frameworks

**Testing:**
- XCTest - Built-in testing framework (located in `DouyinLiveTVTests/`)

**Build/Dev:**
- Xcode 15+ - Primary IDE and build tool
- Clang/LLVM - Swift compiler toolchain

## Key Dependencies

**Critical:**
- KeychainSwift - Secure token storage in Apple Keychain for authentication tokens

**Infrastructure:**
- All other dependencies are Apple system frameworks (no third-party beyond KeychainSwift)

## Configuration

**Environment:**
- Configured via Xcode build settings and `Info.plist`
- No .env files or external configuration detected

**Build:**
- `DouyinLiveTV.xcodeproj/project.pbxproj` - Xcode project configuration
- `DouyinLiveTV/Info.plist` - Application configuration including background refresh capabilities

## Platform Requirements

**Development:**
- macOS with Xcode 15+
- Swift 5.x toolchain

**Production:**
- tvOS 17+ on Apple TV hardware

---

*Stack analysis: 2026-03-31*
