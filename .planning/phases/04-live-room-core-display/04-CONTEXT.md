# Phase 4: Live Room Core Display - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning
**Mode:** Smart discuss (autonomous mode)

<domain>
## Phase Boundary

Implement the main live room viewing experience with video playback and statistics overlay. Users can view a live video stream with large, readable statistics displayed on a semi-transparent overlay, toggle between overlay mode and full-screen video, and use Picture in Picture playback.

This phase delivers:
- Live video playback via AVPlayer (native SwiftUI VideoPlayer on tvOS 17+)
- Statistics overlay with viewer count, likes, and total gifts
- Large text sizing readable from couch distance
- Visual live/offline status indicator
- Toggle between overlay mode and full-screen video
- Picture in Picture (PiP) support

Success criteria from roadmap:
1. Basic statistics displayed: viewer count, likes, total gifts
2. Live video preview plays via AVPlayer
3. Statistics overlay displayed on top of video
4. Statistics use large text sizing readable from couch distance
5. Clear visual indicator shows whether room is live/offline
6. User can toggle between overlay mode and full-screen video
7. Picture in Picture (PiP) support works for video playback
</domain>

<decisions>
## Implementation Decisions

### Screen Layout Arrangement
- **Overall layout**: Full-screen video with semi-transparent stats overlay — matches requirement "statistics overlay displayed on top", keeps video as large as possible
- **Overlay position**: Stats in top-leading corner (top-left) — doesn't block center of video where most action happens
- **Overlay styling**: Semi-transparent blurred background — ensures readability while letting video show through
- **Toggle button location**: Top-trailing corner (top-right) opposite the overlay — easy to reach with focus navigation, doesn't block content

### Statistics Display
- **Font size**: 36pt for labels, 48pt for values — large enough for couch reading, matches "readable from couch" requirement
- **Live/offline indicator**: Colored badge with text next to room title at top — Green = Live, Red = Offline — clear at a glance
- **Statistics order**: Viewer count → Likes → Total gifts — matches natural reading order of importance
- **Spacing**: Generous vertical spacing (16pt-24pt) between stats — easier to read from distance

### Video Playback Integration
- **SwiftUI integration**: Use native `VideoPlayer` view from SwiftUI (tvOS 17+) — simplest integration, maintained by Apple
- **Picture in Picture**: Enable PiP automatically when user enters background or taps toggle — follows tvOS standard behavior
- **Video gravity**: `.resizeAspectFill` — fills screen, crops minor edges if different aspect (most Douyin streams are 9:16 vertical)
- **Auto-play**: Start playing automatically when room loads — user expects video to start immediately

### Claude's Discretion
- Exact animation timing for toggle between overlay and full-screen modes
- Whether to use SwiftUI `blur(radius:)` for the overlay background or a custom UIBlurEffectView
- How to store the last viewed room ID (will need for Phase 5 favorites persistence)
- Integration with app lifecycle observation (pause video when background, resume when foreground)
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DependencyContainer` singleton — LiveRoomViewModel, PlayerService can be registered here
- `AppLifecycleService` — can observe app background/foreground to pause/resume video
- `APIClient` from Phase 2 already exists to fetch live room data
- `LiveRoom` and `LiveStats` domain models already defined in Phase 1
- SwiftUI- and tvOS-native navigation patterns already established by Phase 3
- All 88pt minimum focus size requirements already understood and followed

### Established Patterns
- Manual plain Swift with SwiftUI — no third-party architecture frameworks
- Clean four-layer architecture: App → UI → Domain → Data
- Feature-based grouping in UI folder (WatchLive/, etc.)
- Environment object dependency injection
- Domain models as Swift classes/structs

### Integration Points
- `WatchLiveView` already created as a placeholder in Phase 3 — this is where the live room display will live
- `MainTabView` has WatchLive tab already wired up
- `AppLifecycleObserver` can notify view model to pause/resume video when app changes state
</code_context>

<specifics>
## Specific Ideas

- Follow the existing project patterns: SwiftUI with clean architecture, no unnecessary third-party libraries
- Keep focus targets large (≥88pt) for Siri Remote compatibility as established in Phase 3
- Respect safe area insets and dark mode as established in Phase 3
- Since it's a personal app, prioritize simplicity over extensibility — native APIs preferred
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>

---

*Phase: 04-live-room-core-display*
*Context gathered: 2026-03-31 via smart discuss*
