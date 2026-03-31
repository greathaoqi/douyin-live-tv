# Architecture Patterns

**Domain:** tvOS app for Douyin live monitoring
**Researched:** 2026-03-30

## Recommended Architecture

### Clean Layered Architecture with MVVM

For a small single-purpose tvOS app like Douyin Live TV, **MVVM (Model-View-ViewModel) with clean layered architecture** is recommended. It strikes the right balance between structure and simplicity — not over-engineered but maintainable.

```
┌─────────────────────────────────────────┐
│  UI Layer (Views + ViewControllers)     │
│  - RoomListViewController               │
│  - LiveRoomViewController               │
│  - AddRoomViewController                │
│  - SettingsViewController               │
└──────────────┬──────────────────────────┘
               │
        ┌──────▼──────────────────────────┐
        │  ViewModel Layer                │
        │  - RoomListViewModel            │
        │  - LiveRoomViewModel            │
        │  - AddRoomViewModel             │
        └──────────────┬──────────────────┘
                     │
              ┌──────▼──────────────────────┐
              │  Domain Layer               │
              │  - Models (LiveRoom, Stats) │
              │  - Use Cases                │
              │  - Repository Protocol      │
              └──────────────┬──────────────┘
                           │
                    ┌──────▼──────────────────────┐
                    │  Data Layer                 │
                    │  - APIClient (Douyin API)   │
                    │  - Repository Impl          │
                    │  - KeychainManager (tokens) │
                    │  - LocalStorage (favorites) │
                    └────────────────────────────┘
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Views/ViewControllers** | Display UI, handle user focus/navigation, tvOS specific interactions | ViewModels |
| **ViewModels** | Business logic for screen, expose bindable state, coordinate use cases | Views, Use Cases/Repositories |
| **Models** | Data structures, value types | All layers |
| **Use Cases** | Single-responsibility business actions (fetchStats, saveRoom, refresh) | ViewModels, Repository |
| **Repository Protocol** | Abstract data source definitions, dependency inversion | Domain Layer (use by use cases) |
| **APIClient** | Low-level Douyin API HTTP requests, authentication signing | Repository Implementation |
| **KeychainManager** | Secure token storage, credential management | APIClient |
| **LocalStorage** | Persist favorite rooms to UserDefaults/AppGroup | Repository Implementation |
| **LiveStreamManager** | Manage AVPlayer for live video, connection lifecycle | ViewController, ViewModel |
| **StatsPollingManager** | Schedule periodic stats refresh, handle background refresh | AppDelegate, ViewModel |

### Data Flow

1. **User Action**: User selects a saved room → ViewController sends action to ViewModel
2. **ViewModel**: Requests room data from Repository via Use Case
3. **Repository**: Checks local storage first for cached data, then fetches from API
4. **APIClient**: Adds authentication token from Keychain to request
5. **Response**: Data returned → Repository maps to domain model → ViewModel updates published state
6. **UI Update**: ViewController observes state change and updates UI
7. **Live Stream**: ViewModel instructs LiveStreamManager to load stream URL → AVPlayer plays in UI

## Patterns to Follow

### Pattern 1: MVVM with Combine
**What:** Use Swift's Combine framework for reactive state management in ViewModels.
**When:** Always for tvOS 15+ (current deployment target)
**Example:**
```swift
import Combine

class LiveRoomViewModel: ObservableObject {
    @Published var room: LiveRoom
    @Published var stats: LiveStats?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let fetchStatsUseCase: FetchStatsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(room: LiveRoom, fetchStatsUseCase: FetchStatsUseCase) {
        self.room = room
        self.fetchStatsUseCase = fetchStatsUseCase
    }

    func refreshStats() {
        isLoading = true
        fetchStatsUseCase.execute(roomId: room.roomId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.stats = stats
                }
            )
            .store(in: &cancellables)
    }
}
```

### Pattern 2: Dependency Injection with Protocols
**What:** Depend on abstractions not concretions for testability.
**When:** For all data layer components.
**Example:**
```swift
// Domain layer (protocol definition)
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

### Pattern 3: Centralized Live Stream Management
**What:** A dedicated `LiveStreamManager` to handle AVPlayer lifecycle.
**Why:** Live streaming has complex connection state that shouldn't live in a ViewModel.
**Example:**
```swift
protocol LiveStreamManager {
    var player: AVPlayer { get }
    var isPlaying: Bool { get }

    func loadStream(url: URL)
    func play()
    func pause()
    func stop()
}

class LiveStreamManagerImpl: LiveStreamManager {
    let player = AVPlayer()
    var isPlaying: Bool { player.timeControlStatus == .playing }

    func loadStream(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Massive ViewController
**What:** Putting all API, business, and state logic into UIViewControllers.
**Why bad:** Massive view controllers are unmaintainable, impossible to test, and make the app fragile.
**Instead:** Move all business logic to ViewModels, move data access to repositories. ViewControllers should only handle UI setup, focus management, and state observation.

### Anti-Pattern 2: Storing Tokens in UserDefaults
**What:** Saving authentication tokens in plain text in UserDefaults.
**Why bad:** Tokens can be accessed if device is compromised.
**Instead:** Always use Keychain for authentication tokens even for personal projects.

### Anti-Pattern 3: Frequent Polling
**What:** Polling the Douyin API more frequently than needed.
**Why bad:** Increases risk of rate limiting or account detection.
**Instead:** Honor the 30-minute requirement, use background fetch scheduled by the system.

### Anti-Pattern 4: Ignoring tvOS Focus Engine
**What:** Treating tvOS like iOS and not designing for focus-based navigation.
**Why bad:** Poor user experience on TV remote.
**Instead:** Keep focus management in View layer, design UI with focus in mind.

## Specific Architecture Answers

### How to handle Douyin API authentication (where to store tokens)?

**Recommendation:**
- Store access tokens and refresh tokens in **Keychain** using `Security` framework or a simple wrapper like `KeychainSwift`
- Token refresh logic lives in the `APIClient` class (data layer)
- On each API request, `APIClient` automatically adds the access token to headers
- If token is expired, `APIClient` attempts to refresh before failing the request
- Store the current user (if needed) in Keychain as well
- **Why Keychain over UserDefaults?** Keychain is encrypted, survives app reinstalls, and is the secure storage location on tvOS

**Structure:**
```
Data/Authentication/
├── AuthService.swift      // Login, refresh token flows
├── KeychainManager.swift  // Low-level Keychain operations
└── CredentialStore.swift  // Wraps Keychain for getting/setting tokens
```

### How to organize API calls vs data modeling vs UI layers?

**Clear separation by folder structure:**
```
DouyinLiveTV/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── DependencyContainer.swift
├── UI/
│   ├── Common/           // Shared UI components
│   ├── RoomList/         // RoomListViewController + RoomListViewModel
│   ├── LiveRoom/         // LiveRoomViewController + LiveRoomViewModel
│   └── AddRoom/          // AddRoomViewController + AddRoomViewModel
├── Domain/
│   ├── Models/           // LiveRoom, LiveStats, Credentials (value types)
│   ├── UseCases/         // FetchStatsUseCase, LoginUseCase, SaveRoomUseCase
│   └── Repositories/     // Protocol definitions (no implementation here)
└── Data/
    ├── API/              // DouyinAPIClient, endpoint definitions
    ├── Authentication/   // AuthService, KeychainManager
    ├── Local/            // LocalStorage, UserDefaults persistence
    └── Repositories/     // Repository implementations
```

**Concrete layering rules:**
- **UI layer** can only depend on ViewModels and Domain layer (models, protocols)
- **ViewModels** can depend on Use Cases and Repository protocols (Domain)
- **Domain layer** has no external dependencies — pure Swift
- **Data layer** implements Domain protocols — depends on Domain
- This is dependency inversion: high-level modules (Domain) don't depend on low-level modules (Data)

### How to handle background refresh?

**Recommendation:** Use tvOS's built-in `BackgroundAppRefresh` framework.

**Architecture:**
1. **AppDelegate** registers for background app refresh
2. `StatsPollingManager` schedules next refresh when app enters foreground
3. When background fetch is triggered, app wakes up → `StatsPollingManager` refreshes stats for all favorite rooms
4. Updated stats are cached locally
5. **Important constraints for tvOS:**
   - System controls how often background refresh actually runs — can't guarantee exactly 30 minutes
   - For personal use with 30-minute interval, this is acceptable
   - Background fetch has strict time limits (~30 seconds) — keep it simple, just fetch stats and store

**Code structure:**
```swift
class StatsPollingManager {
    private let repository: LiveRoomRepository
    private let refreshInterval: TimeInterval = 1800 // 30 minutes

    func scheduleNextRefresh() {
        BGAppRefreshTaskRequest(identifier: "com.douyinlive.refresh")
        // Schedule with system
    }

    func handleRefresh(task: BGAppRefreshTask) {
        Task {
            // Refresh all favorite rooms
            let rooms = repository.getFavoriteRooms()
            for room in rooms {
                _ = try await repository.fetchStats(roomId: room.roomId)
            }
            scheduleNextRefresh()
            task.complete()
        }
    }
}
```

### What architecture pattern makes sense (MVVM? MVC? Something simpler for small app?)

**Recommendation: MVVM with Combine is the right choice, even for a small app.**

**Why not MVC?**
- MVC on Apple platforms naturally leads to massive view controllers
- No separation of concerns — business logic in UI layer
- Harder to test

**Why not something simpler (like everything in ViewController)?**
- Even for a small app with 4-5 screens, separation pays off
- When you need to add a feature later, you won't need to rewrite
- MVVM isn't that much extra code with modern Swift and `@Published`

**Why not VIPER/clean architecture with 10 layers?**
- Overkill for a single-person small app
- Too much boilerplate for what this app needs

**MVVM is the sweet spot:**
- Separates UI from business logic
- Easy to understand with modern Swift
- Reactive state with Combine is natural
- Works well with tvKits native patterns
- Low boilerplate, high maintainability

### How to manage the live stream connection and stats polling?

**Two separate dedicated managers:**

**1. LiveStreamManager (for video connection):**
- Owns the `AVPlayer` instance
- Manages stream lifecycle (load, play, pause, stop)
- Handles stream errors (disconnection, network issues)
- Exposes player object to ViewController for display in `AVPlayerViewController` or `VideoPlayer` (SwiftUI)
- When user switches rooms, manager stops current stream and loads new one

**2. StatsPollingManager (for periodic stats refresh):**
- Handles both foreground polling and background refresh
- When app is foregrounded, can poll every 30 seconds for live room if user is watching
- When app is backgrounded, relies on system background fetch every 30 minutes
- Doesn't keep connection open — connects briefly, fetches stats, disconnects
- This respects the requirement and minimizes API exposure

**Interaction:**
- When user opens a live room: `LiveRoomViewModel` tells `LiveStreamManager` to load the stream → `StatsPollingManager` starts foreground polling at reasonable interval
- When user leaves room or app backgrounds: stream paused/stopped, polling stops, background refresh scheduled

## Scalability Considerations

| Concern | At 1 user (current) | At 10 users | At 100 rooms |
|---------|----------------------|-------------|--------------|
| **Authentication** | Single token in Keychain is fine | Add multi-user support via credential switching | Same approach, Keychain handles multiple items |
| **Data storage** | UserDefaults for favorites is fine | Core Data or SwiftData | SwiftData better for large number of rooms |
| **Polling** | 30-minute background refresh OK | Same approach, doesn't depend on user count | For 100 rooms, fetch sequentially within background time limit |
| **Live stream** | One AVPlayer enough | Single stream at a time matches requirement | Still single stream, same architecture works |
| **Memory** | Everything cached in memory fine | Same, no changes | Implement simple LRU cache for room data |

## Confidence Level

**Overall confidence: MEDIUM**

- Core architecture patterns (MVVM, layered clean architecture, dependency inversion) are well-established on Apple platforms — HIGH confidence
- Keychain for token storage is standard practice — HIGH confidence
- Background refresh mechanism matches Apple's documentation — HIGH confidence
- tvOS-specific patterns are based on iOS best practices adapted to tvOS, which is standard in industry — MEDIUM confidence
- The recommendation aligns with the "small app" constraint — not over-engineered

## Sources

- **LOW confidence:** Web search results were not available in this environment. This architecture is based on established Apple platform best practices that have been consistent for many years. The recommendations align with:
  - Apple's MVVM guidance for iOS/tvOS
  - Clean architecture principles adapted for small apps
  - Standard security practices (Keychain for tokens)
  - Background programming model documented by Apple for tvOS
  - Common sense separation of concerns for maintainable codebases
