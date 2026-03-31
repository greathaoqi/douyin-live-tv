# Feature Landscape

**Domain:** tvOS app for monitoring Douyin live rooms
**Researched:** 2026-03-30

## Table Stakes

Features users expect on tvOS. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Focus-based navigation** | Fundamental tvOS interaction model — all apps use this | Medium | Required by design, no focus engine means app is unusable with Siri Remote |
| **Siri Remote gesture support** | Click touch surface for navigation, menu button for back | Low | Standard: swipe to move focus, click to select, menu button to go back |
| **Tab-based main navigation** | Standard for top-level navigation on tvOS | Low | Use `UITabBarController` — expected UX pattern for primary sections |
| **Parallax effect on focusable items** | Visual feedback that Apple TV apps are expected to have | Low | System-provided with `UIVisualEffectView`, just needs proper configuration |
| **Keyboard entry with Siri Remote dictation** | Easier text input than directional selection on screen keyboard | Low | tvOS supports this automatically if using `UITextField` |
| **Siri Remote playback controls** | Standard remote has play/pause buttons that should work | Low | Map to play/pause for live video |
| **Picture in Picture support** | Native tvOS feature users expect for video | Medium | iOS/tvOS 15+ supports PiP out of the box for video |
| **Top Shelf extension** | Quick access to favorite rooms from Apple TV home screen | Low | Improves UX, easy to implement |
| **Keyboard focus handling** | Properly handle focus when adding room by ID | Low | Must move focus to text field automatically when screen loads |
| **Search/Add by URL/ID with autocomplete** | User needs to add new rooms, quick entry helps | Low | Even for single personal use, faster entry |
| **Pull-to-refresh** | Standard for manual refresh on all platforms | Low | Works with the Siri Remote swipe |
| **Differentiate between focus and selection** | tvOS uses focus preview before selection | Low | Visual change on focus, different on selection |
| **Handle background/foreground transitions** | App lifecycle on tvOS needs to pause/refetch | Low | Refresh data when coming to foreground |
| **App icons with correct sizing** | Required for tvOS home screen | Low | Already part of Xcode template |
| **Dark mode support** | TV viewing is almost always in dark environment | Low | tvOS supports dark mode system-wide, respect it |

## Core Features from Requirements (Already Specified)

These are already required per project:

| Feature | Complexity | Notes |
|---------|------------|-------|
| Douyin account login | Medium | Need to handle session management |
| Display live stats (viewer count, likes, gifts) | Low | Simple display overlay |
| Live video preview with stats overlay | Medium | Video player + UI overlay |
| Save favorite rooms | Low | Persistence with UserDefaults or Core Data |
| Manual + 30-minute automatic refresh | Low | Use background fetch timer |
| Add new rooms by room ID/URL | Low | Simple text input |

## Differentiators (For This Use Case)

Not expected, but valuable for this specific use case.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Large text sizing for stats** | TV is viewed from distance, big numbers easier to read | Low | Critical for this use case — stats need to be visible from couch |
| **Full-screen video option** | Can watch the live stream full screen when desired | Low | Toggle between stats overlay and full screen |
| **Quick switch between favorites** | Use menu or swipe to quickly change rooms | Low | Since single room at a time but multiple saved |
| **Status bar for live/Offline indicator** | Clear visual indication if room is live | Low | Color-coded banner at top (green = live, gray = offline) |
| **Remember last viewed room** | App opens directly to last room checked | Low | Saves navigation steps on launch |

## Anti-Features

Features to explicitly NOT build for this personal app.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Multiple concurrent rooms display | Out of scope per requirements, too cluttered on TV | Single room at a time only |
| Chat/danmaku display | Explicitly out of scope, clutters stats UI | Omit entirely |
| Historical data graphs/charts | Out of scope, not needed for monitoring | Omit |
| Push notifications for live status | User doesn't want, requires more infrastructure | Omit |
| Multi-user support | Only personal use, unnecessary complexity | Single user only |
| App Store optimization | Not going to App Store, don't waste effort | Sideload only |
| Complex gestures with multiple touches | tvOS apps use simple navigation, complex gestures confuse | Stick to standard focus clicking |
| 3D Touch / Force Touch features | Not supported on Siri Remote | Omit |

## Standard tvOS UX Patterns

### Navigation Patterns

| Pattern | How to Implement | Reasoning |
|---------|------------------|-----------|
| **Focus-driven navigation** | Use `UIFocusEngine`, `focusGuide`, update UI when `isFocused` changes | This is how tvOS works — everything revolves around focus, not selection |
| **Tab bar at bottom** | Use `UITabBar` for primary sections (Favorites, Current, Add) | Standard position, expected by users |
| **Back via Menu button** | Let system handle back navigation with Menu button | Users expect Menu button to go back, don't override it |
| **Hierarchical navigation with stacks** | Push new view controllers onto navigation stack for details | Standard `UINavigationController` pattern |
| **No back button in UI** | Don't add on-screen back buttons — use Menu button | tvOS convention, saves screen real estate |

### Siri Remote Interaction

| Gesture | Expected Behavior |
|---------|-------------------|
| **Swipe on touch surface** | Move focus between items in direction of swipe |
| **Click touch surface** | Activate focused item (select, open, play/pause) |
| **Menu button click** | Go back one screen, dismiss modal |
| **Play/Pause button click** | Toggle play/pause for live video |
| **Hold Menu button** | Go to Apple TV home screen (system handles, don't override) |
| **Swipe left/right on video** | Not applicable for live, but if implemented would seek |

### Visual Patterns

| Pattern | Why It's Expected |
|---------|-------------------|
| **Focus is 10-20% larger** | When item focused, scale up slightly (parallax) |
| **Depth effect** | Focused item comes forward visually, others recede |
| **High contrast** | TV viewed from distance — text needs good contrast |
| **Large hit targets** | Focusable items minimum 88x88 points (tvOS HIG requirement) |
| **Safe area insets** | Respect TV overscan, don't put content near edges |

## Feature Dependencies

```
Focus navigation → All other interactions (required base)
Tab-based navigation → Main sections (Favorites, Current, Settings)
Video playback → Live preview (requires AVFoundation)
Persistence → Saved favorites (requires Core Data/UserDefaults)
Login → API access (requires authentication before fetching data)
Add room → Favorites list (user can add new to favorites)
Automatic refresh → Background app refresh (requires system integration)
```

## MVP Recommendation

Prioritize **table stakes tvOS UX first** because without it the app won't feel like a proper Apple TV app.

1. **Must have first:** Focus-based navigation + Siri Remote support — without this app is unusable
2. **Next:** Tab navigation with Favorites, Current Room, Add Room
3. **Next:** Login + add first room + basic stats display
4. **Next:** Video preview with play/pause mapping to remote
5. **Next:** Large text for stats (critical for TV viewing distance)
6. **Then:** Quality-of-life: PiP support, Top Shelf, dark mode

**Defer:**
- Advanced PiP: Can be added after MVP, still usable without
- Top Shelf: Nice-to-have, not critical for basic functionality
- Autocomplete for room entry: Can add later, manual entry works initially

## Sources

- Based on standard tvOS development knowledge (tvOS 16+ patterns)
- Focus-based navigation is fundamental to Apple TV interaction model [LOW confidence - unverified via current search]
- Tab bar navigation is standard for top-level sections [LOW confidence - unverified via current search]
- Large hit targets and focus scaling are established Apple design guidance [LOW confidence - unverified via current search]
