# Phase 5: Favorites Management - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning
**Mode:** Smart discuss (autonomous)

<domain>
## Phase Boundary

Users can save and manage favorite live rooms for quick access on tvOS. This phase implements full favorites CRUD operations, persistence via SwiftData, automatic last-room recall on app launch, and integrates with the existing tab navigation.

This phase delivers all 6 FAV-* requirements from the project requirements.

</domain>

<decisions>
## Implementation Decisions

### Data & Service Architecture
- Favorites management logic goes into `FavoritesService` (Data layer) - same pattern as `LiveStatsService` for consistency
- Last viewed room ID stored in `UserDefaults.standard` (simple, sufficient for single-user app)
- SwiftData automatically fetches favorites on view appear - no manual refresh needed for this small dataset
- LiveRoom model already exists - just needs to be added to the ModelContainer in DependencyContainer

### List UI Layout (tvOS)
- Plain `List` with full-width rows - standard tvOS navigation pattern works best
- Each cell shows: room title, author nickname, colored live indicator, last checked time - all useful info at a glance
- No section headers needed - single flat list, all favorites in one place
- Single selection only - matches the "one room at a time" monitoring scope of the project

### Interaction & Navigation
- Delete via edit mode with delete buttons - standard tvOS pattern, works well with Siri Remote (swipe to delete not reliable on tvOS)
- Immediate navigation to WatchLive tab on selection - user wants to watch immediately, no intermediate confirm needed
- Sort by `lastViewed` descending - most recently used rooms at top, matches expected usage pattern

### Add Room URL Parsing
- Extract room ID from these formats: raw ID, `https://www.douyin.com/video/XXX`, `https://v.douyin.com/XXX`, `https://www.douyin.com/user/XXX/live` - covers all common share link formats
- Validate that input is non-empty after extraction before attempting API fetch - fail early with error message
- After adding successfully: switch to Favorites tab so user sees it in the list - navigation matches user expectation

### Claude's Discretion
No open decisions - all areas decided.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `LiveRoom` already exists with `@Model` SwiftData attribute (contains all needed fields: roomId, title, nickname, isLive, lastViewed)
- `DependencyContainer` singleton pattern established, already has `modelContainer` for SwiftData
- `MainTabView` already has Favorites and Add Room tabs - just need wiring to real data
- Stubs already created: `FavoritesView` and `AddRoomView` - just need implementation
- `APIClient` and `LiveStatsService` already exist - can fetch room metadata from Douyin API after adding

### Established Patterns
- Manual dependency injection via singleton `DependencyContainer`
- SwiftUI `View` + `ViewModel` with `@Observable`/`@Published`
- SwiftData for persistence
- tvOS HIG: 88pt minimum touch targets, `focusable()` + `focusEffect()`

### Integration Points
- `DependencyContainer.modelContainer` needs `LiveRoom` added to the model list
- `MainTabView` selected tab needs to be observable for programmatic navigation after add/select
- `WatchLiveView` needs to accept a room ID parameter to open directly
- `App/EntryPoint` needs to handle last room recall on app launch

</code_context>

<specifics>
## Specific Ideas

No specific ideas beyond what's captured in decisions above.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
