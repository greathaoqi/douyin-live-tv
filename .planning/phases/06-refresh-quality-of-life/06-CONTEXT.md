# Phase 6: Refresh & Quality of Life - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning
**Mode:** Smart discuss (autonomous mode)

<domain>
## Phase Boundary

Implement manual pull-to-refresh for the currently open live room, automatic 30-minute refresh using BackgroundTasks framework, add Top Shelf extension for quick access to favorites from Apple TV home screen, and configure app icon correctly. This completes the final polish features for the app.

</domain>

<decisions>
## Implementation Decisions

### Refresh Architecture
- Manual pull-to-refresh placed on WatchLiveView only (single-room monitoring focus)
- Pull-to-refresh enabled only when a room is loaded (not on empty state)

### Automatic Refresh Scheduling
- Combine foreground timer + BackgroundTasks framework: foreground timer when app is in foreground, BGAppRefreshTask when in background
- Automatic refresh updates stored favorite room data in SwiftData (updates lastViewed and isLive status)

### Top Shelf Extension Content
- Show up to 4 favorites maximum in Top Shelf (follows Apple TV design guidelines, avoids clutter)
- Sort favorites by lastViewed descending (most recently used first matches user behavior)
- Show all favorites, indicate live status with a green dot icon (don't filter out non-live rooms)

### App Icon Asset Management
- Use Asset Catalog with single 1024x1024 image — Xcode automatically generates all required sizes for tvOS
- Use a simple placeholder icon initially so project builds correctly; user can replace with custom icon later

### Claude's Discretion
- No outstanding decisions — all grey areas resolved.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `LiveRoomViewModel` already has `loadRoom()` method that can be called for refresh
- `DependencyContainer` already registers all needed services
- `FavoritesService` already fetches and updates favorites in SwiftData
- `AppLifecycleService` already handles foreground/background state changes

### Established Patterns
- `@Published` for view model state (Combine)
- Single shared `DependencyContainer` with manual DI
- SwiftData for persistent storage
- SwiftUI declarative UI with focused view models

### Integration Points
- `WatchLiveView` needs `refreshable` modifier for pull-to-refresh
- `LiveRoomViewModel` needs a `refresh()` method that calls `loadRoom()` again
- New `RefreshService` needed to manage timer and BackgroundTasks integration
- New target for Top Shelf Extension needs to be added to Xcode project
- `Info.plist` needs background mode and Top Shelf configuration
- Asset catalog needs App Icon set with 1024x1024 placeholder

</code_context>

<specifics>
## Specific Ideas

- 30-minute interval matches user requirement from PROJECT.md
- BackgroundTasks uses system scheduling to balance freshness and battery life
- Top Shelf uses `TVTopShelfProvider` API introduced in tvOS 13

</specifics>

<deferred>
## Deferred Ideas

None — all requirements addressed within this phase.

</deferred>
