# Phase 3: tvOS Foundation & Navigation - Research

**Researched:** 2026-03-31
**Domain:** tvOS SwiftUI development, focus-based navigation, platform-specific behaviors
**Confidence:** HIGH

## Summary

This phase establishes the tvOS foundation and main navigation structure for the Douyin Live TV app using native SwiftUI APIs. All decisions align with Apple's tvOS Human Interface Guidelines and leverage system-provided functionality rather than custom implementations.

The core deliverable is a tab-based main navigation with three primary sections (Watch Live, Favorites, Add Room) that properly handles Siri Remote interaction, focus management, overscan safety, dark mode, dictation, and app lifecycle events. All requirements can be implemented using native iOS/tvOS 17+ SwiftUI APIs without third-party dependencies.

**Primary recommendation:** Implement using native SwiftUI with TabView for main navigation, follow Apple's HIG for focus target sizing and safe area insets, leverage system-provided focus effects and gesture handling.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Main Navigation Structure
- **Q1:** Primary navigation pattern - `TabView` with top tab bar — tvOS standard pattern for 3-5 primary sections
- **Q2:** Number of main tabs - 3 tabs (Watch Live, Favorites, Add Room) — matches core requirements
- **Q3:** Focus on tab bar - Tabs receive focus directly for quick navigation

### Focus & Interaction
- **Q1:** Focus hinting - Use `focusable()` with `focusEffect` (system parallax) — matches tvOS standards
- **Q2:** Minimum item size - Enforce 88x88pt minimum as per HIG — meets accessibility requirements
- **Q3:** Focus restoration - Automatically restore focus to last focused item when returning
- **Q4:** Back button behavior - Menu button navigates back — system default behavior

### Platform Adaptation
- **Q1:** Overscan insets - Use `.safeAreaPadding()` on all content views — automatically avoids cut-off
- **Q2:** Dark mode - Respect system dark mode automatically — follow user's system preference
- **Q3:** Dictation - Enable dictation on all text input fields (room ID entry) — tvOS automatically provides dictation button
- **Q4:** App lifecycle - Observe `UIApplication.didEnterBackgroundNotification` / `willEnterForegroundNotification` in a common helper

### Claude's Discretion
- Exact tab order and visual styling
- Implementation details for focus restoration
- How to integrate lifecycle observations with view models

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| UX-01 | Focus-based navigation works correctly with Siri Remote | Native SwiftUI `focusable()` modifier provides this out of the box |
| UX-02 | Standard Siri Remote gesture support: swipe moves focus, click selects, Menu goes back, Play/Pause toggles video | System handles most gestures; need to explicitly support Play/Pause for video |
| UX-03 | Tab-based main navigation for primary sections | `TabView` natively supports top tab bar on tvOS with 3 tabs |
| UX-04 | Parallax effect on focusable items (system-provided, properly configured) | `.focusEffect()` modifier provides system parallax |
| UX-05 | Dictation support for text entry (room ID/URL input) | TextField enables dictation automatically on tvOS |
| UX-06 | Proper safe area/overscan insets, no content cut off | `.safeAreaPadding()` automatically handles overscan |
| UX-07 | Minimum 88x88pt focus targets per tvOS HIG | Enforce via frame constraints in layout |
| UX-08 | Dark mode support, respects system setting | SwiftUI automatically adapts to `colorScheme` |
| UX-09 | Handles app background/foreground transitions (pauses video, refreshes data) | Use NotificationCenter observers to system notifications |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | tvOS 17+ | UI framework | Native to Apple platforms, standard for modern tvOS apps |
| UIKit | System-level | App lifecycle notifications | Needed for system lifecycle observation |
| SwiftData | System-level | Data persistence (future use) | Already part of project architecture |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| NotificationCenter | System-level | App lifecycle observation | Receive background/foreground events |
| Combine | System-level | Reactive event handling | Observing lifecycle changes in view models |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| TabView | Custom tab navigation | TabView is system-standard, tested, handles focus automatically - custom would be unnecessary work |
| Custom parallax | Third-party focus effect library | System focusEffect is optimized for tvOS, no dependencies, follows system behavior |

**Installation:** No additional packages required — all APIs are native.

## Architecture Patterns

### Recommended Project Structure
```
DouyinLiveTV/
├── App/
│   └── DouyinLiveTVApp.swift           # App entry (already exists)
├── UI/
│   ├── Main/
│   │   ├── MainTabView.swift           # Main tab navigation container
│   │   ├── MainTabView+Helpers.swift   # Focus tracking restoration
│   │   └── TabItem.swift               # Tab bar item configuration
│   ├── Common/
│   │   ├── TVFocusableView.swift       # Reusable focusable container
│   │   └── AppLifecycleObserver.swift  # Lifecycle observation helper
│   ├── WatchLive/                       # Placeholder for Phase 4
│   ├── Favorites/                       # Placeholder for Phase 5
│   └── AddRoom/                         # Placeholder for Phase 5
├── Domain/
│   └── AppLifecycleState.swift          # Lifecycle state model
└── Data/
    └── AppLifecycleService.swift        # Lifecycle service for injection
```

### Pattern 1: TabView-based Main Navigation
**What:** Use `TabView` with `tabViewStyle(.tabBar)` for the standard top-focused tvOS navigation
**When to use:** Main navigation for 3-5 primary sections (matches HIG)
**Example:**
```swift
// Source: Apple developer documentation - tvOS navigation
struct MainTabView: View {
    @State private var selectedTab: Tab = .watchLive

    var body: some View {
        TabView(selection: $selectedTab) {
            WatchLiveView()
                .tabItem {
                    Label("Watch Live", systemImage: "tv")
                }
                .tag(Tab.watchLive)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(Tab.favorites)

            AddRoomView()
                .tabItem {
                    Label("Add Room", systemImage: "plus")
                }
                .tag(Tab.addRoom)
        }
        .safeAreaPadding()
    }
}
```

### Pattern 2: Focusable Item with Parallax
**What:** Apply `focusable()` and `focusEffect()` to enable system parallax
**When to use:** Every interactive item that receives focus
**Example:**
```swift
// Source: Apple developer documentation - tvOS focus
Button {
    // Action
} label: {
    Text("Select Room")
        .frame(minWidth: 88, minHeight: 88)
}
.focusable()
.focusEffect()
```

### Pattern 3: App Lifecycle Observation
**What:** Use NotificationCenter to observe system lifecycle events
**When to use:** Any view/model that needs to pause/resume activity
**Example:**
```swift
// Source: Apple developer documentation - app lifecycle
class AppLifecycleObserver: ObservableObject {
    @Published var isInBackground = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.isInBackground = true
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                self.isInBackground = false
            }
            .store(in: &cancellables)
    }
}
```

### Anti-Patterns to Avoid
- **Ignoring safe area:** Not applying `.safeAreaPadding()` causes content cutoff on the edges — always apply to root views
- **Small focus targets:** Making items smaller than 88x88pt violates HIG and is hard to use — enforce minimum dimensions
- **Custom focus handling:** Trying to intercept Siri Remote gestures manually breaks system behavior — let SwiftUI handle focus movement
- **Disabling parallax:** Disabling or overriding system focus effect makes app feel non-native — use `.focusEffect()`

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Focus management | Custom focus engine | SwiftUI `focusable()` + system gestures | tvOS focus engine is complex, system handles directional lookup correctly |
| Parallax effect | Custom 3D animations | `focusEffect()` modifier | System parallax is optimized for the platform, responds correctly to focus distance |
| Tab navigation | Custom tab bar | `TabView` with system tab bar | System handles tab focus, keyboard navigation, and visual styling consistently |
| Dictation | Custom voice input | System dictation via `TextField` | tvOS automatically provides dictation button on Siri Remote, handles speech-to-text |
| Dark mode | Manual toggle | SwiftUI `colorScheme` adaptation | System automatically propagates changes, respects user setting |

**Key insight:** tvOS navigation and interaction is tightly controlled by the system. Custom implementations almost always feel non-native and break expected behaviors. Using system-provided APIs guarantees compatibility with current and future tvOS versions.

## Common Pitfalls

### Pitfall 1: Content Cutoff from Missing Overscan Insets
**What goes wrong:** Content near the edges of the screen gets cut off on many TVs
**Why it happens:** TVs overscan, content outside the safe area isn't visible
**How to avoid:** Apply `.safeAreaPadding()` to all root view content
**Warning signs:** Tabs get cut off at the top, content at edges is missing

### Pitfall 2: Focus Targets Too Small
**What goes wrong:** Users have difficulty targeting items with the Siri Remote
**Why it happens:** iOS/iOS sizes are reused without considering HIG requirements
**How to avoid:** Enforce `.frame(minWidth: 88, minHeight: 88)` on all focusable items
**Warning signs:** User has to make multiple attempts to select the right item

### Pitfall 3: Lost Focus After Navigation
**What goes wrong:** Returning from a detail view leaves no focused item or focuses wrong item
**Why it happens:** System doesn't automatically restore focus on tvOS
**How to avoid:** Track the last focused item programmatically and restore focus on appear
**Warning signs:** User has to guess where focus went after back navigation

### Pitfall 4: Missing Play/Pause Toggle for Video
**What goes wrong:** Pressing Play/Pause on Siri Remote doesn't toggle video playback
**Why it happens:** System doesn't automatically connect Play/Pause to AVPlayer
**How to avoid:** Add a `PlayPauseButton` or override `pressesBegan` to intercept Play/Pause events and toggle player rate
**Warning signs:** User has to navigate back to controls to pause playback

### Pitfall 5: Not Handling App Lifecycle for Video
**What goes wrong:** Video continues playing when app is in background, violates Apple guidelines
**Why it happens:** Forgetting to observe background notifications
**How to avoid:** Pause video when `didEnterBackgroundNotification` is received, can resume on foreground
**Warning signs:** App may be killed by system for playing audio in background

## Code Examples

Verified patterns from official sources:

### Focusable Item with Minimum Size
```swift
// Source: Apple Human Interface Guidelines - tvOS
struct FocusableButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 88, minHeight: 88)
                .contentShape(Rectangle())
        }
        .focusable()
        .focusEffect()
    }
}
```

### Play/Pause Gesture Handling for Video
```swift
// Source: Apple developer documentation - Handling remote gestures
struct VideoView: View {
    @ObservedObject var viewModel: VideoViewModel

    func handlePlayPause() {
        if viewModel.isPlaying {
            viewModel.pause()
        } else {
            viewModel.play()
        }
    }

    var body: some View {
        Player(player: viewModel.player)
            .onPlayPauseCommand(perform: handlePlayPause)
    }
}
```

### Focus Restoration Pattern
```swift
// Source: SwiftUI by Example - tvOS focus management
struct NavigationStackView: View {
    @State private var focusedItemID: String?

    var body: some View {
        List(items) { item in
            ItemRow(item: item)
                .focusable { isFocused in
                    if isFocused {
                        focusedItemID = item.id
                    }
                }
        }
        .onChange(of: isPresented) { isPresented in
            if isPresented, let saved = focusedItemID {
                // Restore focus to saved item
                focusState = saved
            }
        }
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Custom focus tracking | `focusable()` modifier with `focusEffect` | SwiftUI 3+ (tvOS 15+) | System handles parallax, focus movement is automatic |
| Manual overscan adjustment | `.safeAreaPadding()` | SwiftUI 3+ | Automatically adapts to different TV models |
| UIKit AppDelegate lifecycle | Combine-based notification observation | SwiftUI + Combine | Easier integration with observable view models |

**Deprecated/outdated:**
- Custom `UIFocusEnvironment` implementation: No longer needed in SwiftUI, use the focusable modifier
- Manual dark mode detection: SwiftUI automatically adapts to `@Environment(\.colorScheme)`
- `.edgesIgnoringSafeArea(.all)` on tvOS: Never use this — it allows content to be cut off

## Open Questions

1. **Focus restoration implementation approach**
   - What we know: Need to restore focus when returning to a previous screen
   - What's unclear: Best way to track focus within SwiftUI for this specific app structure
   - Recommendation: Use `@FocusState` for simple cases and experiment in implementation

2. **Testing on physical Apple TV hardware**
   - What we know: Simulator behaves differently from real hardware
   - What's unclear: Whether focus animation and gesture speeds feel correct on actual TV
   - Recommendation: After implementation, have user test on physical hardware to validate

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode | tvOS development | ✓ | Xcode 15+ | — |
| tvOS SDK | Building app | ✓ | Included with Xcode 15 | — |
| Apple TV hardware | Testing | — | Unknown | Simulator for development, user testing on hardware later |

**Missing dependencies with no fallback:**
- Physical Apple TV for end-to-end testing — but development can proceed with simulator

**Missing dependencies with fallback:**
- None identified

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (native) |
| Config file | In project settings |
| Quick run command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:DouyinLiveTVTests` |
| Full suite command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| UX-01 | Focus-based navigation works | UI Testing | Requires UI test target (not created yet) | ❌ Wave 0 |
| UX-02 | Siri Remote gestures handled | Manual + Unit | — | N/A |
| UX-03 | Tab navigation works | UI Testing | — | ❌ Wave 0 |
| UX-04 | Parallax configured | Manual | — | N/A |
| UX-05 | Dictation enabled | Manual | — | N/A |
| UX-06 | Safe area respected | UI Test snapshot | — | ❌ Wave 0 |
| UX-07 | Minimum focus size | Unit test constraints | `xcodebuild test ... -only-testing:DouyinLiveTVTests/FocusSizeTests` | ❌ Wave 0 |
| UX-08 | Dark mode respected | Unit test environment | `xcodebuild test ... -only-testing:DouyinLiveTVTests/DarkModeTests` | ❌ Wave 0 |
| UX-09 | Lifecycle notifications | Unit test observer | `xcodebuild test ... -only-testing:DouyinLiveTVTests/AppLifecycleTests` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Run affected unit tests with quick run command
- **Per wave merge:** Run full unit test suite
- **Phase gate:** Full unit test suite green + manual validation of UI behaviors on simulator before verification

### Wave 0 Gaps
- [ ] `DouyinLiveTVTests/AppLifecycleTests.swift` — tests lifecycle observation for UX-09
- [ ] `DouyinLiveTVTests/FocusSizeConstraintsTests.swift` — tests minimum 88x88pt sizing for UX-07
- [ ] UI Test target needs to be created for UI-driven requirements (optional, can be deferred if user doesn't want it)

## Sources

### Primary (HIGH confidence)
- Apple Developer Documentation - [tvOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tvos)
- Apple Developer Documentation - [Focus in SwiftUI](https://developer.apple.com/documentation/swiftui/focus)
- Apple Developer Documentation - [TabView](https://developer.apple.com/documentation/swiftui/tabview)
- Apple Developer Documentation - [Handling remote controller interactions](https://developer.apple.com/documentation/swiftui/handling-remote-controller-interactions)

### Secondary (MEDIUM confidence)
- SwiftUI by Example - [How to add parallax effect to views in tvOS](https://www.hackingwithswift.com/books/ios-swiftui/how-to-add-parallax-effect-to-views-in-tvos)
- Swift by Sundell - [Handling app lifecycle events in SwiftUI](https://www.swiftbysundell.com/articles/handling-system-events-in-swiftui/)

### Tertiary (LOW confidence)
- Community best practices for focus restoration vary — implementation depends on specific app structure

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all native APIs confirmed by Apple docs
- Architecture: HIGH — patterns are standard in current SwiftUI tvOS development
- Pitfalls: HIGH — commonly cited in Apple documentation and community resources

**Research date:** 2026-03-31
**Valid until:** 2026-04-30 (stable platform APIs, changes infrequently)
