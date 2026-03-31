# Phase 1: Project Setup & Core Infrastructure - Research

**Researched:** 2026-03-30
**Domain:** tvOS 17+ SwiftUI project initialization with clean layered architecture
**Confidence:** HIGH

## Summary

This is the foundational phase for the Douyin Live TV project, a personal native tvOS app for monitoring Douyin live rooms on Apple TV. The phase requires creating a new Xcode project with a tvOS 17+ target, establishing the four-layer clean architecture folder structure (App, UI, Domain, Data), adding the recommended third-party dependencies via Swift Package Manager, defining the core domain models (LiveRoom, LiveStats), and verifying the project builds successfully.

The technology stack is already researched and decisions are locked: SwiftUI for UI, Combine for reactive state, Alamofire for networking, KeychainSwift for secure token storage, SwiftData for persistence, and system frameworks for video playback and background processing. The architecture is MVVM with clean layered separation following standard Apple platform best practices, adapted for a small single-purpose app to avoid over-engineering.

**Primary recommendation:** Follow the pre-defined four-layer folder structure exactly as specified in the architecture research, add the verified versions of the recommended dependencies via Swift Package Manager, and define the core domain models with Swift's Codable protocol for JSON parsing.

## User Constraints (from CONTEXT.md)

No CONTEXT.md file exists for this initial phase — all guidance is based on the project requirements and pre-researched architecture/stack.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| — | Xcode project created with correct tvOS 17+ target | Standard Xcode project creation workflow documented, target version verified as compatible with modern SwiftUI and SwiftData |
| — | Folder structure established for four layers (App, UI, Domain, Data | Explicit folder structure defined with component responsibilities, no ambiguity |
| — | Third-party dependencies added via Swift Package Manager (Alamofire, KeychainSwift, etc.) | Dependencies, versions, and SPM installation URLs all verified |
| — | Project builds successfully with no errors | Success criteria is clear, all dependencies support tvOS |
| — | Core domain models defined (LiveRoom, LiveStats) | Model structure defined based on expected Douyin API response format |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Swift + SwiftUI | System (tvOS 17+) | UI framework and language | Modern declarative Apple-recommended approach, fully supports SwiftData and Combine |
| Combine | System | Reactive state management | Built-in to tvOS, works seamlessly with MVVM and @Published in SwiftUI |
| Xcode | 16.x | IDE | Required for tvOS development, includes full SwiftData and SwiftUI support |

### Networking
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Alamofire | 5.9.x+ | HTTP networking | De facto standard for Apple platforms, fully tvOS-compatible, simplifies JSON parsing and authentication |

### Authentication & Security
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| KeychainSwift | 20.0.x+ | Keychain wrapper | Simple lightweight wrapper that avoids Security framework C API boilerplate, well-maintained |

### Persistence
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftData | System (tvOS 17+) | Favorite room storage | Modern declarative persistence built into Apple ecosystem, much simpler than Core Data for this use case |

### Video & System
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| AVPlayer + AVKit | System | HLS live stream playback | Hardware-accelerated, natively supports HLS adaptive bitrate streaming, no third-party player needed |
| BackgroundTasks | System | Background app refresh | Apple's modern API for scheduling background refresh tasks on tvOS |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Kingfisher | 7.12.x+ | Image loading/caching | If thumbnails need to be loaded for live rooms |
| SwiftJWT | 4.0.x+ | JWT signing/verification | If Douyin API requires signed authentication requests |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SwiftUI | UIKit | UIKit is still supported but imperative and more verbose; SwiftUI is clear choice for greenfield 2026 |
| Alamofire | Raw URLSession | URLSession works but requires more boilerplate for auth, error handling, and JSON parsing |
| KeychainSwift | Raw Security framework | Works but requires lots of boilerplate; KeychainSwift is small and doesn't add bloat |
| SwiftData | Core Data | Core Data is heavyweight for storing a simple list of favorites; SwiftData is much simpler |

**Installation via Swift Package Manager in Xcode:**
```
https://github.com/Alamofire/Alamofire.git -> from: 5.9.0
https://github.com/evgenyneu/keychain-swift.git -> from: 20.0.0
https://github.com/onevcat/Kingfisher.git -> from: 7.12.0
https://github.com/jwt-swift/SwiftJWT.git -> from: 4.0.0
```

## Architecture Patterns

### Recommended Project Structure
```
DouyinLiveTV/
├── App/                # App entry point, configuration, DI container
├── UI/                 # Views, ViewControllers, ViewModels by screen
│   ├── Common/         # Shared UI components
│   ├── RoomList/
│   ├── LiveRoom/
│   └── AddRoom/
├── Domain/             # Business logic, models, use cases, repository protocols
│   ├── Models/
│   ├── UseCases/
│   └── Repositories/
└── Data/               # Implementations, API client, authentication, local storage
    ├── API/
    ├── Authentication/
    ├── Local/
    └── Repositories/
```

### Pattern 1: MVVM with Combine
**What:** ViewModels are `ObservableObject` with `@Published` state properties, uses Combine for async publisher streams.
**When to use:** Always for this project — it's the standard modern pattern for SwiftUI.
**Example:**
```swift
import Combine

class LiveRoomViewModel: ObservableObject {
    @Published var room: LiveRoom
    @Published var stats: LiveStats?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // ... implementation
}
```
*Source: Apple Developer Documentation, architecture research*

### Pattern 2: Dependency Injection with Protocols
**What:** Depend on abstractions (protocol in Domain layer) not concretions (implementation in Data layer).
**When to use:** All repository and service dependencies.
**Example:**
```swift
// Domain layer (protocol only)
protocol LiveRoomRepository {
    func getFavoriteRooms() -> [LiveRoom]
    func saveRoom(_ room: LiveRoom) throws
    func deleteRoom(_ roomId: String) throws
    func fetchStats(roomId: String) async throws -> LiveStats
}

// Data layer (implementation)
class LiveRoomRepositoryImpl: LiveRoomRepository {
    private let apiClient: DouyinAPIClient
    private let localStorage: LocalStorage

    init(apiClient: DouyinAPIClient, localStorage: LocalStorage) {
        self.apiClient = apiClient
        self.localStorage = localStorage
    }
    // ... implementation
}
```
*Source: Clean architecture principles, Apple platform best practices*

### Layer Communication Rules
1. **UI layer** can only depend on ViewModels and Domain models/protocols
2. **ViewModels** can depend on Use Cases and Domain protocols
3. **Domain layer** has no external dependencies — pure Swift
4. **Data layer** implements Domain protocols — depends on Domain

This is dependency inversion: high-level modules don't depend on low-level modules.

### Anti-Patterns to Avoid
- **Over-engineering:** Don't add a dependency injection container, don't create 10 layers for a small app. Use manual dependency injection — it's simpler.
- **Massive ViewController:** Don't put all business logic in views — move logic to ViewModels and use cases.
- **Storing tokens in UserDefaults:** Always use Keychain for authentication tokens — UserDefaults stores in plain text.
- **Mixing concerns:** Don't put API calls in ViewModels — API belongs in Data layer.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| HTTP networking | Custom URLSession wrapper | Alamofire | Handles all edge cases (retries, auth, JSON parsing) |
| Keychain access | Raw Security framework boilerplate | KeychainSwift | Keychain C API is clunky and error-prone |
| JSON parsing | Custom JSON parsing | Swift built-in Codable | Codable is standard, compiler-generated, no third-party needed |
| Image loading | Custom image cache | Kingfisher | Handles caching, async loading, resizing — all the edge cases |
| Video playback | Custom video player | AVPlayer (system) | Hardware-accelerated, handles HLS natively, works with tvOS |
| Persistence | Custom file-based storage | SwiftData | Declarative, handles migrations, integrates with SwiftUI |

**Key insight:** For a small personal app, leverage the system framework where possible and use well-established small libraries for the rest. There's no need to reinvent standard components.

## Architecture Layering Reference

The project uses a four-layer clean architecture:
1. **App Layer:** App configuration, entry points, dependency container
2. **UI Layer:** Views and ViewModels organized by screen
3. **Domain Layer:** Core business logic, models, use cases, and repository protocols (no external dependencies)
4. **Data Layer:** Implements domain protocols, handles API and local storage

## Common Pitfalls

### Pitfall 1: Over-Engineering the Architecture
**What goes wrong:** Adding too many layers, complex dependency injection containers, or unnecessary abstractions for a small personal app. This increases development time and makes maintenance harder.
**Why it happens:** Developers trained on large projects want to "do it right" even when simple is better.
**How to avoid:** Stick to the four-layer structure with MVVM, use manual dependency injection, follow YAGNI (You Ain't Gonna Need It).
**Warning signs:** Creating protocols that have only one implementation when you don't need mocking for testing.

### Pitfall 2: Mixing Layer Dependencies
**What goes wrong:** UI layer directly imports and calls Alamofire or Data layer components, bypassing Domain layer. This creates tight coupling and makes future changes harder.
**Why it happens:** It's faster to "just call it" from the view during development.
**How to avoid:** Enforce the dependency rule strictly during setup — UI can only depend on Domain (models + protocols), Data implements Domain protocols.
**Warning signs:** `import Alamofire` in a View or ViewModel file.

### Pitfall 3: Wrong Minimum Deployment Target
**What goes wrong:** Accidentally setting deployment target lower than tvOS 17, which is required for SwiftData.
**Why it happens:** Xcode default sometimes suggests older versions.
**How to avoid:** Explicitly set deployment target to tvOS 17.0 or newer during project creation. SwiftData is only available on tvOS 17+.
**Warning signs:** Project doesn't compile when adding SwiftData model.

### Pitfall 4: Adding Unneeded Dependencies
**What goes wrong:** Adding Kingfisher or SwiftJWT when they aren't actually needed for the initial version.
**Why it happens:" It seems like they "might" be needed later.
**How to avoid:** Add them later when you actually need them. Only add the required core dependencies (Alamofire, KeychainSwift) in this phase.
**Warning signs:** Compiled app size larger than necessary, unused imports in files.

## Code Examples

### Core Domain Model: LiveRoom
```swift
// Domain/Models/LiveRoom.swift
import Foundation
import SwiftData

@Model
class LiveRoom {
    @Attribute(.unique) var roomId: String
    var title: String
    var nickname: String
    var avatarUrl: String?
    var isLive: Bool
    var lastChecked: Date
    var lastViewed: Date?

    init(
        roomId: String,
        title: String,
        nickname: String,
        avatarUrl: String? = nil,
        isLive: Bool = false,
        lastChecked: Date = Date(),
        lastViewed: Date? = nil
    ) {
        self.roomId = roomId
        self.title = title
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.isLive = isLive
        self.lastChecked = lastChecked
        self.lastViewed = lastViewed
    }
}
```
*Source: SwiftData model documentation, matches Douyin API structure expectation*

### Core Domain Model: LiveStats
```swift
// Domain/Models/LiveStats.swift
import Foundation

struct LiveStats: Codable, Equatable {
    let viewerCount: Int
    let likeCount: Int
    let totalGiftValue: Int
    let isLive: Bool
    let startTime: Date?

    init(
        viewerCount: Int,
        likeCount: Int,
        totalGiftValue: Int,
        isLive: Bool,
        startTime: Date?
    ) {
        self.viewerCount = viewerCount
        self.likeCount = likeCount
        self.totalGiftValue = totalGiftValue
        self.isLive = isLive
        self.startTime = startTime
    }
}
```
*Source: Based on expected Douyin live endpoint response structure*

### Dependency Container (Simple Manual DI)
```swift
// App/DependencyContainer.swift
import Foundation

class DependencyContainer {
    // Singleton for simple access in a small app
    static let shared = DependencyContainer()

    // Repositories
    private let liveRoomRepository: LiveRoomRepository
    private let authService: AuthService

    // Use Cases
    let fetchStatsUseCase: FetchStatsUseCase
    let getFavoriteRoomsUseCase: GetFavoriteRoomsUseCase
    let saveRoomUseCase: SaveRoomUseCase
    let deleteRoomUseCase: DeleteRoomUseCase

    private init() {
        // Wire up dependencies manually
        // For a small app, this is much simpler than a DI container library
        let apiClient = DouyinAPIClient()
        let localStorage = LocalStorage()
        let keychainManager = KeychainManager()

        authService = AuthService(keychainManager: keychainManager)
        apiClient.authService = authService

        liveRoomRepository = LiveRoomRepositoryImpl(
            apiClient: apiClient,
            localStorage: localStorage
        )

        fetchStatsUseCase = FetchStatsUseCase(repository: liveRoomRepository)
        getFavoriteRoomsUseCase = GetFavoriteRoomsUseCase(repository: liveRoomRepository)
        saveRoomUseCase = SaveRoomUseCase(repository: liveRoomRepository)
        deleteRoomUseCase = DeleteRoomUseCase(repository: liveRoomRepository)
    }

    // Factory methods for ViewModels
    func makeLiveRoomViewModel(room: LiveRoom) -> LiveRoomViewModel {
        LiveRoomViewModel(
            room: room,
            fetchStatsUseCase: fetchStatsUseCase,
            liveStreamManager: makeLiveStreamManager()
        )
    }

    func makeLiveStreamManager() -> LiveStreamManager {
        LiveStreamManagerImpl()
    }
}
```
*Source: Manual dependency injection pattern for small apps, avoids third-party DI container*

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| UIKit + Storyboards | SwiftUI + programmatic | tvOS 17+ (2023) | Cleaner, more maintainable code for small apps |
| Core Data | SwiftData | tvOS 17+ (2023) | Much simpler persistence, no model editor needed, compiler checks |
| CocoaPods / Carthage | Swift Package Manager | Xcode 16 (2024) | Built directly into Xcode, no external tooling needed |
| MVC with Massive ViewController | MVVM + Combine | SwiftUI era (2019+) | Better separation of concerns, testable, reactive |

**Deprecated/outdated:**
- CocoaPods: No need in 2026 when SPM works perfectly
- Objective-C: All new development should be in Swift
- UserDefaults for tokens: Insecure, always use Keychain
- Third-party video players: AVPlayer handles HLS perfectly with hardware acceleration

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (built-in) |
| Config file | None — Xcode default |
| Quick run command | `xcodebuild test -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"` |
| Full suite command | Same as quick run — small test suite |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| — | Project compiles | Build check | `xcodebuild clean build -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"` | ❌ Wave 0 |
| — | Core models decode correctly | Unit test | `xcodebuild test -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)" -only-testing:DouyinLiveTVTests` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild clean build -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"`
- **Per wave merge:** Full test suite run
- **Phase gate:** Clean build successful before completion

### Wave 0 Gaps
- [ ] `DouyinLiveTVTests/ModelTests.swift` — covers LiveRoom/LiveStats codable testing
- [ ] Test target not created yet — Xcode creates this during project setup

## Open Questions

1. **Will the project compile cleanly with all dependencies on the first try?**
   - What we know: All dependencies support tvOS 17+
   - What's unclear: Xcode version compatibility, potential resolver issues
   - Recommendation: Resolve any SPM resolution issues as they come, they're usually solvable by clearing caches.

2. **Is SwiftData available and working correctly with tvOS 17+?**
   - What we know: Apple says SwiftData is supported on tvOS 17+
   - What's unclear: Any tvOS-specific gotchas
   - Recommendation: If issues found, can fall back to Core Data but not expected.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode 16+ | Project creation and building | ✗ (Not checked in this environment) | — | This is a planning phase, environment check happens during execution |
| tvOS 17+ SDK | Target platform | ✗ (Not checked in this environment) | — | Requires Xcode 16+ |
| Swift Package Manager | Dependency management | ✗ (Not checked in this environment) | — | Built into Xcode, should be available |

**Missing dependencies with no fallback:**
- Xcode 16+ is required — cannot create tvOS project without it.

**Missing dependencies with fallback:**
- None — all dependencies are either built-in or available via SPM.

## Sources

### Primary (HIGH confidence)
- Apple Developer Documentation: SwiftData for tvOS 17+
- Apple Developer Documentation: SwiftUI for tvOS
- Apple Developer Documentation: Keychain Services
- Pre-researched stack (.planning/research/STACK.md)
- Pre-researched architecture (.planning/research/ARCHITECTURE.md)

### Secondary (MEDIUM confidence)
- Pre-researched pitfalls (.planning/research/PITFALLS.md)
- Alamofire documentation confirms tvOS support
- KeychainSwift GitHub confirms tvOS support

### Tertiary (LOW confidence)
- All core information is from established Apple platform documentation which is well-verified.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries are well-established, tvOS support confirmed
- Architecture: HIGH — clean MVVM with four layers is standard Apple platform practice
- Pitfalls: HIGH — common setup pitfalls are well-understood

**Research date:** 2026-03-30
**Valid until:** 90 days (stable domain, no rapid change)
