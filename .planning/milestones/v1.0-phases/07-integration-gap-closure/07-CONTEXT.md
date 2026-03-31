# Phase 7: Integration Gap Closure - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning
**Mode:** Smart discuss with user acceptance

<domain>
## Phase Boundary

Fix cross-phase integration gaps identified in the v1.0 milestone audit. This phase closes the gaps that prevent core functionality from working:
1. Wire authentication correctly so all API requests include authorization header
2. Add streamURL property to LiveRoom model for video playback
3. Fix Top Shelf extension compilation and deep-linking

After this phase, the end-to-end user flow should work: authentication → select favorite → fetch stats → play video.
</domain>

<decisions>
## Implementation Decisions

### LiveStatsService Dependency Injection
- LiveStatsService will store AuthService as a private property
- Keep existing apiClient parameter and add new authService parameter to the initializer

### LiveRoom Model and API Parsing
- streamURL will be Optional<String> (nil when unavailable)
- LiveStatsService.fetchStats will update the LiveRoom.streamURL property when the API provides a stream URL

### Top Shelf Module Import
- Import `DouyinLiveTVDomain` where LiveRoom is defined to fix compilation

### Deep Link Handling
- Handle `com.douyinlivedtv.openRoom` user activity in `DouyinLiveTVApp` using `onContinueUserActivity` modifier
- Parse roomId from userInfo and pass to ContentView as `initialRoomId` - reuses existing navigation logic

### Claude's Discretion
All decisions accepted by user as recommended.
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AuthService` already has complete `authenticatedRequest(_:)` implementation with token refresh
- `DependencyContainer` already registers all services, just needs update for LiveStatsService initializer
- `MainTabView` already handles `initialRoomId` navigation, so deep-linking just needs to pass it
- SwiftData already handles model versioning, adding property is straightforward

### Established Patterns
- Manual dependency injection via DependencyContainer shared instance
- SwiftUI with MVVM view model pattern
- tvOS focus handling with standard SwiftUI modifiers

### Integration Points
- `LiveStatsService` used by: `LiveRoomViewModel`, `FavoritesService`, `RefreshService` - all need updated initializer
- `LiveRoom` model used everywhere - adding property is transparent
- `DouyinLiveTVApp` needs `onContinueUserActivity` modifier to handle Top ShelF deep link
- `DouyinLiveTVTopShelf` needs module import to fix compilation
</code_context>

<specifics>
## Specific Ideas

Follow the decisions captured above. All major decisions already approved.
</specifics>

<deferred>
## Deferred Ideas

None — all gaps addressed in this phase.
</deferred>
