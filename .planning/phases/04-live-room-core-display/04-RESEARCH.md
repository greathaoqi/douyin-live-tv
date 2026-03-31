# Phase 4: Live Room Core Display - Research

**Researched:** 2026-03-31
**Domain:** tvOS 17+ SwiftUI VideoPlayer with AVPlayer integration, statistics overlay, Picture in Picture support
**Confidence:** HIGH

## Summary

This phase implements the core live room viewing experience on tvOS 17+. The project already targets tvOS 17.0+, so we have full access to the native SwiftUI `VideoPlayer` view which wraps `AVPlayer` and `AVPlayerViewController`. The architecture follows the established clean four-layer pattern: App → UI → Domain → Data, with feature-based grouping in the UI layer.

The implementation will replace the placeholder `WatchLiveView` with a full implementation featuring full-screen video playback, a semi-transparent statistics overlay in the top-left corner, a toggle button in the top-right, and automatic Picture in Picture support when the app enters background.

All design decisions are already locked in via the UI contract and context decisions, so this is mostly implementation following established patterns rather than exploring alternatives. The main areas of discretion are animation timing, blur implementation approach, and last-viewed room ID storage strategy.

**Primary recommendation:** Use native SwiftUI APIs exclusively (no third-party video libraries), follow the established project patterns, and implement the view model with AVPlayer integration that observes app lifecycle via the existing `AppLifecycleService`.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

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

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LIVE-01 | Display basic statistics: viewer count, likes, total gifts | Domain models `LiveStats` already exist; layout and sizing defined in UI contract |
| LIVE-02 | Live video preview playback via AVPlayer | Native `VideoPlayer` (tvOS 17+) available, project already targets 17.0; AVPlayer bridge is standard |
| LIVE-03 | Stats overlay displayed on top of video | ZStack layout with overlay on top of VideoPlayer; position defined in contract |
| LIVE-04 | Large text sizing for stats (visible from couch distance)  | 36pt labels / 48pt values explicitly defined in CONTEXT and UI contract |
| LIVE-05 | Visual live/offline status indicator | Colored badge pattern defined — green=live, red=offline; positioned next to room title |
| LIVE-06 | Toggle between overlay mode and full-screen video | State flag in view model with animated show/hide of overlay via opacity/offset |
| LIVE-07 | Picture in Picture (PiP) support for video playback | AVPlayerViewController on tvOS supports PiP automatically when using native `VideoPlayer` |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI VideoPlayer | System (tvOS 17+) | Video playback wrapping AVPlayer | Native, maintained by Apple, no external dependencies |
| AVPlayer | System | Media playback engine | System native, supports HLS which Douyin uses |
| AVPlayerViewController | System | PiP and playback controls | Automatic PiP support on tvOS |
| Combine | System | Reactive state management | Already used for AppLifecycleService, follows existing patterns |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| SwiftUI `blur(radius:)` | System | Backdrop blur for overlay | Simpler if meets requirements, SwiftUI-native |
| UIBlurEffectView | System | Backdrop blur via UIKit | More control if needed, can be wrapped in UIViewRepresentable |
| UserDefaults | System | Last viewed room ID storage | Simple, sufficient for single value; will be replaced by SwiftData in Phase 5 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Native VideoPlayer | Third-party player (YouTubePlayer, etc) | Adds dependency, unnecessary complexity for simple HLS playback |
| Full-screen with separate stats | Side-by-side layout | Wastes valuable screen real estate on TV, overlay keeps video largest |
| Manual PiP management | Automatic PiP | Native behavior is what users expect on tvOS |

**Installation:**
No additional packages needed — all APIs are native system frameworks.

## Architecture Patterns

### Recommended Project Structure
```
DouyinLiveTV/
├── App/
│   └── DependencyContainer.swift  // Add LiveRoomViewModel, PlayerService registration
├── Domain/
│   ├── Models/                     // LiveRoom, LiveStats already exist
│   └── Services/
│       └── PlayerService.swift    // NEW: AVPlayer management service
├── Data/
│   └── Services/
│       └── LiveStatsService.swift  // NEW: Fetches live stats from API
└── UI/
    └── WatchLive/
        ├── WatchLiveView.swift     // UPDATE: Replace placeholder with implementation
        ├── LiveRoomViewModel.swift // NEW: View model for live room state
        ├── StatisticsOverlay.swift // NEW: Reusable stats overlay subview
        └── OverlayToggleButton.swift // NEW: Toggle button subview
```

### Pattern 1: ViewModel with AVPlayer Player Service
**What:** Separate service manages AVPlayer instance, view model holds UI state, service injected via EnvironmentObject.
**When to use:** Clean separation, allows testing view model without player.
**Example:**
```swift
// PlayerService holds the AVPlayer instance
class PlayerService: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying: Bool = false
    
    func loadVideo(url: URL) { /* ... */ }
    func play() { player?.play() }
    func pause() { player?.pause() }
}

// Source: Apple docs - https://developer.apple.com/documentation/swiftui/videoplayer
```

### Pattern 2: ZStack for Video + Overlay
**What:** `VideoPlayer` fills whole screen, ZStack places overlay and toggle button on top.
**When to use:** Required for overlay-on-video requirement.
**Example:**
```swift
ZStack(alignment: .topLeading) {
    // Full-screen video behind everything
    VideoPlayer(player: viewModel.player)
        .ignoresSafeArea()
        .scaledToFill()
    
    // Stats overlay in top-leading
    StatisticsOverlay(stats: viewModel.stats)
        .padding()
        .opacity(viewModel.showOverlay ? 1 : 0)
    
    // Toggle button in top-trailing
    OverlayToggleButton {
        viewModel.toggleOverlay()
    }
    .frame(minWidth: 88, minHeight: 88) // tvOS focus requirement
    .padding()
}
```

### Pattern 3: App Lifecycle Observation for Pause/Resume
**What:** Use existing `AppLifecycleService` publisher, observe in view model, pause when background, resume when foreground.
**When to use:** Required to follow tvOS best practices and PiP behavior.

### Anti-Patterns to Avoid
- **Storing AVPlayer in ViewModel directly:** Extract to an injectable service for testability and lifecycle management
- **Ignoring safe area:** Stats overlay and button must respect safe area + overscan insets (already established in Phase 3)
- **Small focus targets:** Overlay toggle button MUST be at least 88pt (tvOS HIG requirement already tested in existing tests)
- **Custom PiP implementation:** Let `AVPlayerViewController` (wrapped by `VideoPlayer`) handle PiP automatically

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Video playback | Custom player implementation | AVPlayer + SwiftUI VideoPlayer | Handles HLS, adaptive bitrate, PiP, all tvOS integration |
| Picture in Picture | Custom PiP UI and management | System AVPlayer PiP | Apple's implementation handles all edge cases, follows system UX |
| Blur effect | Custom blur rendering | System blur (SwiftUI or UIKit) | Hardware-accelerated, performance optimized |
| Last viewed room storage | Custom file storage | UserDefaults (temporary) | Simple, one value, will migrate to SwiftData in Phase 5 |

**Key insight:** Video playback on tvOS is a solved problem by Apple — any custom implementation will miss edge cases PiP, focus handling, accessibility that the system already handles correctly.

## Common Pitfalls

### Pitfall 1: Forgetting to set allowsPictureInPicturePlayback
**What goes wrong:** PiP doesn't activate when app enters background.
**Why it happens:** By default, PiP may not be enabled on the player.
**How to avoid:** Set `player.allowsPictureInPicturePlayback = true` after creation. On tvOS 17+ with `VideoPlayer`, this is usually enabled automatically but explicit setting is safer.
**Warning signs:** PiP doesn't start when user switches apps.

### Pitfall 2: Blocking PiP with non-interactive overlay
**What goes wrong:** User can't interact with PiP when overlay is full screen.
**Why it happens:** Overlay with `.contentShape(Rectangle())` blocks touches to the player underneath.
**How to avoid:** Ensure overlay has `.allowsHitTesting(false)` when it shouldn't intercept focus or touches. The toggle button still needs hit testing.
**Warning signs:** PiP controls don't respond to taps/clicks.

### Pitfall 3: Not pausing video when background with PiP disabled
**What goes wrong:** Video continues playing audio when app is background without PiP, wasting resources.
**Why it happens:** Missing integration with `AppLifecycleService`.
**How to avoid:** Observe `currentState` from `AppLifecycleService` and automatically pause when app enters background. If PiP is active, pausing is handled automatically.
**Warning signs:** Audio continues playing after user leaves app.

### Pitfall 4: Safe area ignored on Apple TV overscan
**What goes wrong:** Overlay or toggle button gets cut off at screen edges.
**Why it happens:** Apple TV uses overscan insets, content near edges can be cut off.
**How to avoid:** Use `.safeAreaPadding()` on overlay container, don't pin directly to edges without safe area.
**Warning signs:** Buttons or text get clipped on actual hardware.

### Pitfall 5: Focus ring doesn't appear on toggle button
**What goes wrong:** Can't navigate to toggle button with Siri Remote.
**Why it happens:** Forgot `.focusable()` modifier or `.focusEffect()`.
**How to avoid:** Always add both modifiers to focusable buttons on tvOS.
**Warning signs:** Focus skips from other content directly past the button.

### Pitfall 6: Video gravity wrong for 9:16 vertical streams
**What goes wrong:** Vertical Douyin stream doesn't fill screen properly, has letterboxing.
**Why it happens:** Used `.resizeAspect` instead of `.resizeAspectFill`.
**How to avoid:** Use `.resizeAspectFill` as decided, which fills screen and crops minor overflow at top/bottom.
**Warning signs:** Large black bars on sides of video.

## Code Examples

Verified patterns from official sources:

### Basic VideoPlayer with AVPlayer
```swift
// Source: Apple Developer Documentation
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .scaledToFill()
            .ignoresSafeArea()
    }
}
```

### Enable Picture in Picture
```swift
// Source: Apple AVKit docs
let player = AVPlayer(url: videoURL)
// Allows Picture in Picture on tvOS
player.allowsPictureInPicturePlayback = true
// PiP will start automatically when app enters background
```

### Semi-transparent Overlay with Blur
```swift
// Using SwiftUI native blur (simpler)
StatisticsOverlay()
    .padding(.xl)
    .background(.ultraThinMaterial) // has built-in blur
    .cornerRadius(16)
    .padding()

// Or using UIBlurEffectView for more control
struct BlurBackground: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
```

### Observing App Lifecycle
```swift
// Using existing AppLifecycleService
class LiveRoomViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    init(appLifecycleService: AppLifecycleService, playerService: PlayerService) {
        appLifecycleService.$currentState
            .sink { state in
                switch state {
                case .foreground: playerService.resume()
                case .background: playerService.pause()
                }
            }
            .store(in: &cancellables)
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| UIKit AVPlayerViewController wrapped | SwiftUI native VideoPlayer | tvOS 17 (2023) | Simpler integration, less boilerplate |
| Manual PiP delegate management | Automatic PiP | tvOS 15+ | Less code, follows system behavior |
| Custom blur effects | Built-in material background | SwiftUI 3+ | Better performance, automatic dark mode |

**Deprecated/outdated:**
- `AVPlayerViewController` represented manually: No longer needed on tvOS 17+, `VideoPlayer` handles it
- Third-party HLS players: Unnecessary complexity, AVPlayer handles all modern HLS features

## Open Questions

1. **Will Douyin HLS streams play directly on tvOS AVPlayer without CORS issues?**
   - What we know: Project acknowledges this open question from STATE.md
   - What's unclear: Whether CORS or domain restrictions will block direct playback
   - Recommendation: Implement direct playback first, if it fails we'll need to add proxying in a later phase. Current plan should proceed with direct integration as that's what works for most cases.

2. **Which blur approach is better for performance on tvOS — SwiftUI material or UIBlurEffectView?**
   - What we know: Both are native, hardware-accelerated
   - What's unclear: Whether SwiftUI `ultraThinMaterial` has better/worse performance than wrapped UIBlurEffectView
   - Recommendation: Try SwiftUI built-in material first (simpler), if performance is an issue fall back to UIBlurEffectView. This is within Claude's discretion per context.

3. **Where should last viewed room ID be stored until Phase 5?**
   - What we know: Phase 5 will use SwiftData for favorites persistence
   - What's unclear: Whether to use UserDefaults now or integrate SwiftData already
   - Recommendation: Use UserDefaults for temporary storage (one string value) — simpler, avoids changing model container setup before Phase 5. Will migrate to SwiftData in Phase 5 when favorites are implemented.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode | Build & run | ✓ | 15+ (assumed from tvOS 17 target) | — |
| tvOS 17.0 SDK | VideoPlayer API | ✓ | 17.0 | Project already targets this |
| AVPlayer | Video playback | ✓ | System | — |

**Missing dependencies with no fallback:**
- None identified

**Missing dependencies with fallback:**
- None identified

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (Xcode default) |
| Config file | None — uses project default |
| Quick run command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' ONLY_TESTING=DouyinLiveTVTests | grep -E "(FAILED|PASSED|ERROR)"` |
| Full suite command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LIVE-01 | Display basic statistics: viewer count, likes, total gifts | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveStatsModelTests` | ❌ Wave 0 |
| LIVE-02 | Live video preview playback via AVPlayer | Unit (view model) / Manual on device | Manual testing required for actual playback | — |
| LIVE-03 | Stats overlay displayed on top of video | UI test snapshot / Manual | Manual visual verification | — |
| LIVE-04 | Large text sizing for stats | Unit (test font values) | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomDisplayTests/testTextSizesMeetsRequirements` | ❌ Wave 0 |
| LIVE-05 | Visual live/offline status indicator | Unit / Manual | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomDisplayTests/testStatusIndicatorColor` | ❌ Wave 0 |
| LIVE-06 | Toggle between overlay mode and full-screen | Unit (test view model state) | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomViewModelTests/testToggleOverlayChangesState` | ❌ Wave 0 |
| LIVE-07 | Picture in Picture support | Manual on device | Requires actual tvOS hardware/device | — |

### Sampling Rate
- **Per task commit:** `xcodebuild test ... -only-testing with affected test classes`
- **Per wave merge:** Full suite run
- **Phase gate:** Full suite green before verification

### Wave 0 Gaps
- [ ] `DouyinLiveTVTests/LiveStatsModelTests.swift` — covers LIVE-01 model verification
- [ ] `DouyinLiveTVTests/LiveRoomViewModelTests.swift` — covers LIVE-06 view model behavior
- [ ] `DouyinLiveTVTests/LiveRoomDisplayTests.swift` — covers LIVE-04, LIVE-05 UI contract compliance
- Existing `FocusSizeConstraintsTests` already covers 88pt minimum requirement (already passes)

## Sources

### Primary (HIGH confidence)
- Existing project structure and code analysis — Domain models, services, patterns already established
- Apple Developer Documentation — SwiftUI VideoPlayer, AVPlayer, Picture in Picture on tvOS
- Project already targets tvOS 17.0, so native VideoPlayer is available by default

### Secondary (MEDIUM confidence)
- tvOS Human Interface Guidelines confirm 88pt minimum focus size requirement (already followed)
- App lifecycle observation pattern already implemented by `AppLifecycleService`

### Tertiary (LOW confidence)
- Direct HLS playback from Douyin — needs verification on actual hardware (open question documented)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all native system APIs, project already targets correct version
- Architecture: HIGH — follows established patterns already present in project
- Pitfalls: HIGH — common tvOS video integration pitfalls well understood

**Research date:** 2026-03-31
**Valid until:** 90 days (stable native APIs, no frequent changes)
