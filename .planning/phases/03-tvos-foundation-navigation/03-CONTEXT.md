# Phase 3: tvOS Foundation & Navigation - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish proper tvOS-specific foundation with focus-based navigation that follows Apple's Human Interface Guidelines. This phase creates the main navigation structure for the app after authentication and ensures all platform-specific behaviors work correctly with the Siri Remote.

This phase delivers:
- Main tab-based navigation structure for primary app sections
- Proper focus management with parallax effect for focusable items
- Siri Remote gesture support (swipe, click, Menu, Play/Pause)
- Overscan/safe area handling to prevent content cutoff
- Dark mode support
- App lifecycle handling (background/foreground transitions)
- Dictation support for text entry

Success criteria from roadmap:
1. Focus-based navigation works correctly with Siri Remote
2. Standard Siri Remote gestures are supported (swipe to move focus, click to select, Menu to go back, Play/Pause toggles video)
3. Tab-based main navigation works for primary sections
4. Parallax effect configured correctly on focusable items
5. Dictation support available for text entry
6. Content respects safe area/overscan insets, nothing is cut off
7. All focus targets meet minimum 88x88pt size
8. App respects system dark mode setting
9. App handles background/foreground transitions correctly (pauses video, refreshes data)
</domain>

<decisions>
## Implementation Decisions

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
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DependencyContainer` singleton - All navigation and app environment objects can be registered here
- `AuthStateManager` already integrated at app entry point for conditional routing
- SwiftUI-based architecture already established - use native SwiftUI navigation APIs

### Established Patterns
- Manual plain Swift with SwiftUI - no third-party architecture frameworks
- Clean architecture: App > UI > Domain > Data layers already in place
- Environment-based injection of shared objects

### Integration Points
- `ContentView` routes authenticated users to `mainUI` - currently placeholder, needs actual main navigation
- `DouyinLiveTVApp` app entry point already handles authentication check on launch
- Future phases (Live Room, Add Room, Favorites) will plug into the main navigation structure created here
</code_context>

<specifics>
## Specific Ideas

- Follow Apple's tvOS Human Interface Guidelines strictly for navigation and focus
- Prioritize simplicity - use native TabView instead of custom navigation
- Keep focus targets large enough for comfortable Siri Remote interaction
- Since it's a personal app, prefer simpler native solutions over complex custom implementations
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>

---

*Phase: 03-tvos-foundation-navigation*
*Context gathered: 2026-03-31 via smart discuss*
