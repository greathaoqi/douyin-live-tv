# Phase 5: Favorites Management - Research

**Researched:** 2026-03-31
**Domain:** SwiftData persistence, tvOS SwiftUI List management, URL parsing, favorites CRUD
**Confidence:** HIGH

## Summary

Phase 5 implements favorites management for a tvOS Douyin live monitoring app. All architectural and UI decisions are already locked in the CONTEXT.md, so this research confirms the implementation approach aligns with existing project patterns and tvOS best practices. The feature requires adding SwiftData model configuration, a new FavoritesService for business logic, completing the stubbed FavoritesView and AddRoomView, and integrating with existing navigation and last-room recall functionality.

The LiveRoom model already exists with proper @Model SwiftData attributes, stubs for the main views already exist, and the dependency injection pattern is well-established. The main work involves wiring everything together according to the decided patterns.

**Primary recommendation:** Follow the existing project patterns (view model + service + SwiftData) as already decided, implement each requirement incrementally with tests.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

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

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FAV-01 | User can add new room by entering room ID or URL | URL parsing patterns identified, covers 4 common Douyin URL formats, APIClient exists for fetching metadata |
| FAV-02 | User can view list of saved favorite rooms | SwiftData @Query will provide automatic fetching, plain List pattern decided |
| FAV-03 | User can delete rooms from favorites | Edit mode pattern standard on tvOS, already supported by SwiftUI List |
| FAV-04 | User can quickly select a favorite room to monitor | Immediate navigation to WatchLive tab with room ID parameter, navigation pattern identified |
| FAV-05 | Last viewed room is remembered and opened on app launch | UserDefaults already used by existing temporary code, pattern confirmed as appropriate |
| FAV-06 | Favorites persist across app restarts via SwiftData | LiveRoom model already has @Model attribute, just need to add to ModelContainer |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftData | iOS 17+/tvOS 17+ (system) | Local persistence of favorite rooms | Native framework, already in use, matches project simplicity |
| SwiftUI | tvOS 17+ (system) | UI framework for List and navigation | Already established as project UI framework |
| UserDefaults | System | Last viewed room ID storage | Simple, sufficient for single-user app as decided |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine | System | Reactive state management | Already used by existing view models |
| Foundation | System | URL parsing, data processing | Core system framework |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SwiftData | Core Data | More complexity, larger API surface, no benefits for this small dataset |
| Edit mode delete | Swipe to delete | Unreliable with Siri Remote on tvOS, edit mode is standard pattern |
| Sort by name | Sort by lastViewed | Matches usage pattern - recently used rooms at top for quick access |

**Installation:**
All dependencies are system frameworks - no additional installation needed. Only configuration change required: add `LiveRoom` to `ModelContainer` in `DependencyContainer`.

## Architecture Patterns

### Recommended Project Structure
```
DouyinLiveTV/
├── Data/Services/        # FavoritesService
├── Domain/Models/        # LiveRoom (already exists)
├── UI/
│   ├── Favorites/        # FavoritesView, FavoriteRoomCell
│   └── AddRoom/          # AddRoomView (stub exists, needs completion)
└── App/
    └── DependencyContainer.swift  # Update ModelContainer
```

### Pattern 1: Service with Dependency Injection
**What:** FavoritesService holds business logic for favorites operations, instantiated in DependencyContainer following the same pattern as LiveStatsService.
**When to use:** All data operations follow this pattern in the project
**Example:**
```swift
// Data/Services/FavoritesService.swift
// Pattern matches LiveStatsService
import Foundation
import SwiftData
import DouyinLiveTVDomain

public class FavoritesService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func addRoom(roomId: String, title: String, nickname: String) -> LiveRoom {
        let room = LiveRoom(roomId: roomId, title: title, nickname: nickname)
        modelContext.insert(room)
        try? modelContext.save()
        return room
    }
    
    public func deleteRoom(_ room: LiveRoom) {
        modelContext.delete(room)
        try? modelContext.save()
    }
    
    public func updateLastViewed(_ room: LiveRoom) {
        room.lastViewed = Date()
        try? modelContext.save()
    }
}
```

### Pattern 2: SwiftData @Query for Automatic Updates
**What:** Using `@Query` property wrapper in FavoritesView to automatically get sorted results from SwiftData. No manual refresh needed.
**When to use:** Small datasets like favorites list
**Example:**
```swift
// In FavoritesView
@Query(sort: \LiveRoom.lastViewed, order: .reverse) private var rooms: [LiveRoom]
@Environment(\.modelContext) private var modelContext
```

### Pattern 3: URL ID Extraction
**What:** Regex or simple string parsing extracts room ID from multiple Douyin URL formats. Handles raw input (just ID) and shared links.
**When to use:** User input that can be either raw ID or URL
**Pattern:**
1. Trim whitespace from input
2. If input is all digits, treat as raw ID
3. Otherwise parse as URL and extract last path component
4. Validate non-empty before API fetch

### Anti-Patterns to Avoid

- **Swipe-to-delete on tvOS:** Not reliable with Siri Remote navigation, edit mode is standard.
- **Manual fetch/refresh:** @Query handles this automatically for small datasets, no need.
- **Storing last viewed room in SwiftData:** UserDefaults is simpler and sufficient for single-value recall on app launch.
- **Multiple sections/grouping:** Unnecessary complexity, flat single list matches user expectation.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Local persistence | Custom JSON file coding | SwiftData | System framework handles migrations, querying, sorting |
| URL parsing | Full URL validator | Built-in URL with path extraction | Simple extraction meets requirements, covers all common cases |
| Navigation coordination | Custom navigation stack | Observable `selectedTab` on MainTabView | Simple programmatic navigation matches existing structure |

**Key insight:** This is a simple CRUD feature on a small dataset. System frameworks already solve all the hard problems - don't over-engineer.

## Common Pitfalls

### Pitfall 1: Forgetting to add LiveRoom to ModelContainer
**What goes wrong:** SwiftData won't query any data, zero results returned with no visible error
**Why it happens:** LiveRoom already has @Model but needs to be explicitly added to the ModelContainer initializer
**How to avoid:** Update `ModelContainer(for: [LiveRoom.self])` in DependencyContainer immediately as first task
**Warning signs:** FavoritesView always shows empty state even after adding rooms

### Pitfall 2: Not handling URL format variations correctly
**What goes wrong:** User shares a link from Douyin app but ID extraction fails, can't add room
**Why it happens:** Douyin has multiple link formats: `/video/XXX`, `/XXX`, user/live URLs
**How to avoid:** Test all four formats explicitly: raw ID, `https://www.douyin.com/video/XXX`, `https://v.douyin.com/XXX`, `https://www.douyin.com/user/XXX/live`
**Warning signs:** "Invalid room ID" error even with correct URL

### Pitfall 3: Violating tvOS focus target size
**What goes wrong:** Difficult for user to navigate with Siri Remote, rejected by App Store if that were a concern (it's not for sideload, but still bad UX)
**Why it happens:** Cell content might not fill the full row width, minimum 88pt height not met
**How to avoid:** Follow existing project pattern: 88pt minimum, use `.focusable()` + `.focusEffect()`
**Warning signs:** Focus skips over cells unpredictably

### Pitfall 4: Not sorting by lastViewed
**What goes wrong:** Most recently used rooms can be at bottom of long lists
**Why it happens:** Forgetting to add the sort parameter to @Query
**How to avoid:** `@Query(sort: \LiveRoom.lastViewed, order: .reverse)` ensures most recent at top
**Warning signs:** Newest added room not at top after viewing

### Pitfall 5: Programmatic navigation not working
**What goes wrong:** After adding or selecting a room, tab doesn't change
**Why it happens:** MainTabView currently has `@State private var selectedTab` - needs to be `@Binding` or observable from child view
**How to avoid:** Change `selectedTab` to `@Binding` or wrap in Observable object so programmatic selection works from child views
**Warning signs:** Tap favorite cell, nothing changes visually even though room loads

## Code Examples

Verified patterns from existing project:

### URL ID Extraction
```swift
// Extract room ID from various Douyin URL formats
func extractRoomId(from input: String) -> String? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Raw ID case (just digits)
    if trimmed.allSatisfy(\.isNumber) {
        return trimmed
    }
    
    // URL case - extract last path component
    guard let url = URL(string: trimmed) else {
        // If not a valid URL, try removing whitespace and check again
        let cleaned = trimmed.filter { !$0.isWhitespace }
        guard let cleanedUrl = URL(string: cleaned) else {
            return nil
        }
        return cleanedUrl.lastPathComponent
    }
    
    return url.lastPathComponent
}
```

### Delete with Edit Mode (tvOS standard)
```swift
// In FavoritesView
@State private var isEditing = false

// Toolbar or navigation button:
Button(action: { isEditing.toggle() }) {
    Text(isEditing ? "Done" : "Edit")
}
.focusable()
.focusEffect()

// In List:
.listStyle(.plain)
.environment(\.editMode, $isEditing)
.onDelete(perform: deleteRoom)
```

### Last Viewed Persistence
```swift
// Save when room selected
func saveLastViewedRoomId(_ roomId: String) {
    UserDefaults.standard.set(roomId, forKey: "LastViewedRoomId")
}

// On app launch in WatchLiveView
if let lastRoomId = UserDefaults.standard.string(forKey: "LastViewedRoomId") {
    // Auto-load last room
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Core Data | SwiftData | iOS 17 / 2023 | Simpler API, zero boilerplate for basic modeling |
| Plist file persistence | SwiftData | iOS 17 | Automatic sorting, querying, change tracking |
| Swipe to delete (iOS) | Edit mode delete (tvOS) | tvOS 13+ | Better UX with Siri Remote |

**Deprecated/outdated:**
- Core Data: Too heavy for this use case, SwiftData is standard now
- Manual JSON coding: Unnecessary when SwiftData handles all persistence

## Open Questions

None - all decisions locked, all integration points identified, existing code provides clear patterns.

## Environment Availability

> SKIPPED: All dependencies are system frameworks (SwiftData, SwiftUI, Foundation). No external tools or services required.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (built-in to Xcode) |
| Config file | Xcode project configuration (DouyinLiveTV.xcodeproj) |
| Quick run command | `xcodebuild test -scheme DouyinLiveTV -destination platform=tvOS Simulator,name=Apple TV 4K (3rd generation) -only-testing:DouyinLiveTVTests |`
| Full suite command | `xcodebuild test -scheme DouyinLiveTV -destination platform=tvOS Simulator,name=Apple TV 4K (3rd generation)` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FAV-01 | Add room from ID/URL | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/FavoritesServiceTests` | ❌ Wave 0 |
| FAV-01 | URL parsing extraction | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/URLParsingTests` | ❌ Wave 0 |
| FAV-02 | View list of favorites | Unit/Integration | `xcodebuild test ... -only-testing:DouyinLiveTVTests/FavoritesViewModelTests` | ❌ Wave 0 |
| FAV-03 | Delete room from favorites | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/FavoritesServiceTests` | ❌ Wave 0 |
| FAV-04 | Select favorite navigates to WatchLive | Integration | `xcodebuild test ...` | ❌ Wave 0 |
| FAV-05 | Last room remembered across restarts | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LastRoomPersistenceTests` | ❌ Wave 0 |
| FAV-06 | Favorites persist via SwiftData | Integration | `xcodebuild test ...` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -scheme DouyinLiveTV -destination platform=tvOS Simulator,name=Apple TV 4K (3rd generation) -only-testing:DouyinLiveTVTests/FavoritesServiceTests`
- **Per wave merge:** Full test suite run
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `DouyinLiveTVTests/FavoritesServiceTests.swift` — unit tests for FavoritesService CRUD operations
- [ ] `DouyinLiveTVTests/URLParsingTests.swift` — unit tests for room ID extraction from various URL formats
- [ ] `DouyinLiveTVTests/FavoritesViewModelTests.swift` — unit tests for view model business logic
- [ ] `DouyinLiveTVTests/LastRoomPersistenceTests.swift` — tests for last viewed room persistence
- [ ] All test files need to be created as part of Wave 0 setup

## Sources

### Primary (HIGH confidence)
- Existing project code - patterns already established, stubs already created
- LiveRoom model already defined with SwiftData @Model attribute
- Dependency injection pattern already proven with LiveStatsService
- Apple tvOS Human Interface Guidelines - 88pt minimum focus targets, edit mode navigation

### Secondary (MEDIUM confidence)
- SwiftData documentation from Apple - confirms @Query automatic refreshing
- tvOS development best practices - confirms edit mode delete preferred over swipe-to-delete

### Tertiary (LOW confidence)
- Web search didn't return recent results for 2026, but all patterns are well-established since SwiftData launched in 2023

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all system frameworks already in use, project already has SwiftData
- Architecture: HIGH - all patterns follow existing project conventions, decisions locked
- Pitfalls: HIGH - all integration points identified by reading existing code, common mistakes catalogued

**Research date:** 2026-03-31
**Valid until:** 2026-04-30 (SwiftData/tvOS patterns are stable)
