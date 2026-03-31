# Architecture

**Analysis Date:** 2026-03-31

## Pattern Overview

**Overall:** Clean Architecture (Layered) with manual dependency injection

**Key Characteristics:**
- Strict dependency rule: Domain layer has no external dependencies
- Outer layers (Data, UI) depend inward on Domain layer abstractions
- Separation of concerns by architectural layer
- Manual dependency injection via singleton container
- SwiftUI for UI with observable view models
- Local persistence via SwiftData

## Layers

**Domain Layer:**
- Purpose: Holds core business logic, models, and protocols. Pure Swift with no external dependencies.
- Location: `DouyinLiveTV/Domain/`
- Contains: Business models, domain services, common types
- Depends on: Only Foundation and SwiftData (system frameworks)
- Used by: Data layer, UI layer, App layer

**Data Layer:**
- Purpose: Implements data access and external communication. Conforms to Domain protocols.
- Location: `DouyinLiveTV/Data/`
- Contains: API networking, authentication, keychain storage, SwiftData persistence, service implementations
- Depends on: Domain layer
- Used by: App layer, UI layer via DependencyContainer

**UI Layer:**
- Purpose: User interface for tvOS, user interaction handling, navigation
- Location: `DouyinLiveTV/UI/`
- Contains: SwiftUI views, view models, view components organized by feature screen
- Depends on: Domain layer, Data layer services
- Used by: App entry point

**App Layer:**
- Purpose: Application entry point, DI container configuration, global state management
- Location: `DouyinLiveTV/App/`
- Contains: App entry point, dependency container, authentication state manager
- Depends on: All layers (resolves dependencies)
- Used by: System (app launch point)

## Data Flow

**User Authentication Flow:**

1. User opens app → `DouyinLiveTVApp` init triggers `AuthStateManager.checkStoredCredentials()`
2. `AuthStateManager` queries `TokenStorage` (Data/Keychain) for valid tokens
3. If valid tokens exist → state becomes `.authenticated`, main UI loads
4. If no valid tokens → state becomes `.unauthenticated`, LoginView presented
5. LoginView requests QR code via `AuthService` → `APIClient` fetches QR from Douyin SSO API
6. User scans QR on mobile device → ViewModel polls QR status via `AuthService`
7. Once confirmed, `AuthService` receives tokens → stores in `TokenStorage` (Keychain)
8. `AuthStateManager` transitions to `.authenticated` → main UI navigates to root

**Add Favorite Room Flow:**

1. User enters room ID/URL in AddRoomView → ViewModel calls `FavoritesService.addRoom(roomId:)`
2. `FavoritesService` extracts room ID via parsing → calls `LiveStatsService.fetchStats(for:)`
3. `LiveStatsService` requests stats from Douyin API via `APIClient`
4. API returns `LiveStats` with current room status and stream URL
5. `FavoritesService` checks SwiftData for existing room with same ID
6. Updates existing or inserts new `LiveRoom` with fresh stats → saves to SwiftData
7. `Favorites` publisher emits updated list → UI updates to show new room

**Live Playback Flow:**

1. User selects favorite room → `WatchLiveView` appears
2. `LiveRoomViewModel` calls `PlayerService.loadVideo(url:)` with stream URL
3. `PlayerService` creates `AVPlayer` with enables Picture-in-Picture
4. `Player` is held by service, observed by ViewModel
5. View binds to player and playback state → displays video

## State Management

- `AuthStateManager` is `@MainActor @Observable` manages global auth state
- Services use `@Published` for observable collections (e.g., `FavoritesService.favorites`)
- ViewModels use `@Observable` or `@Published` for view state
- `PlayerService` holds current `AVPlayer` instance as published state
- Persistence: SwiftData (`ModelContainer`) for favorites, Keychain for auth tokens, UserDefaults for simple preferences

## Key Abstractions

**Endpoint:**
- Purpose: Type-safe API endpoint abstraction for generic request handling
- Examples: `DouyinLiveTV/Data/Network/Endpoint.swift`, `DouyinLiveTV/Data/Network/DouyinAPIEndpoints.swift`
- Pattern: Generic `Endpoint<T>` where `T: Decodable` allows `APIClient.request<T: Decodable>(_ endpoint:)` to automatically decode responses

**API Client:**
- Purpose: Abstract network communication from specific endpoints
- Examples: `DouyinLiveTV/Data/Network/APIClient.swift`
- Pattern: `Sendable` class with generic async `request` method that handles URL construction, header injection, status code checking, and JSON decoding

**Service:**
- Purpose: Encapsulate single business capability with clear API
- Examples: `FavoritesService`, `LiveStatsService`, `PlayerService`, `RefreshService`, `AuthService`
- Pattern: Classes with focused responsibilities, initialized via DI container, async methods where appropriate

## Entry Points

**Application Main Entry:**
- Location: `DouyinLiveTV/App/DouyinLiveTVApp.swift`
- Triggers: App launch by system
- Responsibilities:
  - Initialize DependencyContainer singleton (creates all dependencies)
  - Register background refresh on launch
  - Load last selected room ID from FavoritesService for deep linking
  - Check stored authentication credentials on appear
  - Handle deep link continuation for Top Shelf room opening

**ContentView:**
- Location: `DouyinLiveTV/UI/Common/ContentView.swift`
- Triggers: Root view after app launch
- Responsibilities: Route between LoginView (unauthenticated) and MainTabView (authenticated) based on `AuthStateManager.state`

## Error Handling

**Strategy:** Throwing functions with typed error representation

**Patterns:**
- `APIError` enum with specific cases: `networkError`, `invalidResponse`, `decodingError`, `unauthorized`, `forbidden`, `serverError(Int)`
- `APIError` conforms to `Equatable` and `CustomStringConvertible` for testing and display
- Async/await with throwing semantics propagates errors to caller
- ViewModels catch errors and expose them to view for user display
- Fatal error only on unrecoverable initialization failure (SwiftData container creation)

## Cross-Cutting Concerns

**Logging:** Not currently standardized; implemented ad-hoc or via system logging
**Validation:** Room ID/URL parsing in `FavoritesService.extractRoomId(from:)` uses regex patterns for multiple input formats
**Authentication:** Token storage in Keychain via `TokenStorage`, state managed by `AuthStateManager`, automatic token refresh handled by `AuthService`
**Background Refresh:** `RefreshService` registers background tasks to update favorite room statuses when app isn't running
**Picture in Picture:** Enabled by default on `AVPlayer` in `PlayerService` as required for tvOS

---

*Architecture analysis: 2026-03-31*
