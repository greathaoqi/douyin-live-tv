# Technology Stack

**Project:** Douyin Live TV (tvOS)
**Researched:** 2026-03-30

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Swift + SwiftUI | tvOS 17+ | UI framework and language | SwiftUI is the modern Apple-recommended declarative framework for tvOS development. It's fully supported on tvOS 17+ which covers nearly all currently shipping Apple TV hardware (4K and HD models). Results in cleaner, shorter code compared to UIKit for a simple app like this. |
| Combine | System framework | Reactive state management | Built-in to iOS/tvOS, works perfectly with MVVM for ViewModel state observation. No need for third-party libraries like RxSwift. |
| Xcode | 16.x | IDE | Official Apple IDE, required for tvOS development. Latest stable version includes complete SwiftUI and SwiftData support. |

### Networking
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Alamofire | 5.9.x | HTTP networking library | The de facto standard networking library for Apple platforms. Fully tvOS-compatible, simplifies JSON parsing, request authentication, and error handling. Cleaner API than raw URLSession for this use case. |

### Authentication & Security
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Keychain | Security framework | Secure token storage | System-provided encrypted storage for authentication credentials. Tokens survive app reinstalls and are encrypted on disk. The only acceptable place to store authentication tokens on tvOS. |
| KeychainSwift | 20.0.x | Convenience wrapper for Keychain | Simple lightweight wrapper that avoids writing boilerplate for the Security framework C API. Small, well-maintained, fully supports tvOS. |

### Video Player
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| AVPlayer (with AVKit) | System framework | HLS live stream playback | Apple's built-in AVPlayer is fully optimized for tvOS hardware and supports HLS natively. It handles adaptive bitrate streaming automatically which is perfect for Douyin live streams. No third-party player needed - AVPlayer is battle-tested and hardware-accelerated. |
| SwiftUI VideoPlayer | System | SwiftUI wrapper | Convenient SwiftUI wrapper around AVPlayer that integrates seamlessly with the rest of the SwiftUI interface. |

### Persistence
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| SwiftData | System (tvOS 17+) | Favorite room storage | Modern declarative persistence built directly into the Apple ecosystem. Perfect for storing a simple list of favorite rooms (dozens at most). No heavy migrations needed, integrates seamlessly with SwiftUI views for automatic UI updates. Much simpler than Core Data for this use case. |

### Background Processing
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| BackgroundTasks | System framework | Background app refresh | Apple's modern API for scheduling background refresh tasks. Works natively with tvOS to perform periodic stats updates even when app is in background. |

### Supporting Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Kingfisher | 7.12.x | Image loading/caching | If you need to load thumbnails for live rooms. Native tvOS image loading can be clunky, Kingfisher handles caching and async loading smoothly. |
| SwiftJWT | 4.0.x | JWT signing/verification | If Douyin API requires signed requests for authentication. |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Core Framework | SwiftUI | UIKit | UIKit is still supported but imperative and more verbose. For a greenfield project in 2026, SwiftUI is the clear choice. Apple continues to invest heavily in SwiftUI across all platforms including tvOS. |
| Core Framework | SwiftUI | React Native / Flutter | Cross-platform frameworks add unnecessary overhead for a single-platform tvOS app. Performance worse than native, especially for video playback. Not justified for a personal sideloaded app. |
| Authentication | Keychain + KeychainSwift | UserDefaults | UserDefaults stores data in plain text, insecure for authentication tokens. Can be lost on reinstall. Not appropriate for sensitive credentials. |
| Networking | Alamofire | URLSession (raw) | Raw URLSession works but requires more boilerplate for request handling, authentication, and JSON parsing. Alamofire is the standard and doesn't add significant bloat. |
| Networking | Alamofire | Moya | Overkill for this simple app - only one API client needed, the extra abstraction isn't worth it. |
| Video Player | AVPlayer + VideoPlayer | Third-party player (like VLC for tvOS) | VLC is overkill when AVPlayer already handles HLS perfectly with hardware acceleration on Apple TV. Adds unnecessary app size and potential compatibility issues. |
| Persistence | SwiftData | Core Data | Heavyweight for storing just a list of favorite rooms. More boilerplate, steeper learning curve. SwiftData is simpler and fully sufficient. |
| Persistence | SwiftData | UserDefaults | UserDefaults isn't designed for storing mutable collections of data. It loads everything into memory at startup and doesn't handle queries efficiently. Fine for app settings, not for favorite rooms. |
| Persistence | SwiftData | SQLite | Requires manual query construction, unnecessary complexity. SwiftData handles all the ORM work automatically. |

## Installation

In Xcode 16+, add via Swift Package Manager:

```
https://github.com/Alamofire/Alamofire.git -> from: 5.9.0
https://github.com/onevcat/Kingfisher.git -> from: 7.12.0
https://github.com/jwt-swift/SwiftJWT.git -> from: 4.0.0
https://github.com/evgenyneu/keychain-swift.git -> from: 20.0.0
```

Or add to `Package.swift` if using Swift Package Manager directly:

```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
    .package(url: "https://github.com/jwt-swift/SwiftJWT.git", from: "4.0.0"),
    .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0")
]
```

## What NOT to Use

| Technology | Why Avoid |
|------------|-----------|
| **Objective-C** | No need - all modern development is in Swift. |
| **UIKit for new code** | While still supported, SwiftUI is the future and more productive. |
| **Storing tokens in UserDefaults** | Insecure, plain text, not encrypted. |
| **RxSwift** | Unnecessary third-party dependency when Combine is built-in. |
| **Realm** | Overkill for 10-100 favorite rooms. Adds third-party dependency when SwiftData is built-in. |
| **VLCKit** | AVPlayer does everything needed for HLS and is hardware-accelerated. |
| **Cocoapods** | In 2026, Swift Package Manager is built directly into Xcode and works perfectly. No need for a third-party dependency manager. |
| **Third-party JSON parsing libraries (SwiftyJSON)** | Swift's built-in `Codable` is sufficient and standard. |
| **Heavy dependency injection containers** | Overkill for a small app. Simple manual dependency injection is enough. |

## Sources

- Apple Developer Documentation: Keychain Services (HIGH confidence - well-established system API)
- Apple Developer Documentation: Combine (HIGH confidence - built-in system framework)
- Apple Developer Documentation: BackgroundTasks (HIGH confidence - built-in system framework)
- [KeychainSwift GitHub](https://github.com/evgenyneu/keychain-swift) - confirms tvOS support (MEDIUM confidence)
- [Alamofire GitHub](https://github.com/Alamofire/Alamofire) - confirms tvOS support (MEDIUM confidence)
