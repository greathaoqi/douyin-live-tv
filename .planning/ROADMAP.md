# Roadmap: Douyin Live TV

**Project:** Douyin Live TV — Native tvOS app for monitoring Douyin live rooms
**Created:** 2026-03-30
**Granularity:** standard
**Total v1 requirements:** 30
**Mapped:** 30/30 ✓

## Phases

- [ ] **Phase 1: Project Setup & Core Infrastructure** - Create Xcode project, establish architecture layers, configure dependencies
- [ ] **Phase 2: Authentication & API Layer** - Implement secure authentication, Douyin API client, token management
- [ ] **Phase 3: tvOS Foundation & Navigation** - Build basic UI structure with focus-based navigation, tab bar, tvOS HIG compliance
- [ ] **Phase 4: Live Room Core Display** - Implement main live room screen with statistics overlay and video playback
- [ ] **Phase 5: Favorites Management** - Add ability to add, view, delete, and quickly access favorite rooms
- [ ] **Phase 6: Refresh & Quality of Life** - Implement manual/automatic refresh and polish tvOS-specific features

## Phase Details

### Phase 1: Project Setup & Core Infrastructure
**Goal:** Establish a clean project structure with proper architecture and dependencies following the recommended patterns
**Depends on:** Nothing (first phase)
**Requirements:** None (infrastructure)
**Success Criteria** (what must be TRUE):
  1. Xcode project created with correct tvOS 17+ target
  2. Folder structure established for four layers (App, UI, Domain, Data)
  3. Third-party dependencies added via Swift Package Manager (Alamofire, KeychainSwift, etc.)
  4. Project builds successfully with no errors
  5. Core domain models defined (LiveRoom, LiveStats)
**Plans:** 3 plans

Plans:
- [ ] 01-01-PLAN.md — Create Xcode project and four-layer folder structure with dependencies
- [ ] 01-02-PLAN.md — Define core domain models (LiveRoom, LiveStats) with TDD
- [ ] 01-03-PLAN.md — Full build verification and manual configuration check

### Phase 2: Authentication & API Layer
**Goal:** Users can securely authenticate with Douyin and have credentials persist across sessions
**Depends on:** Phase 1
**Requirements:** AUTH-01, AUTH-02, AUTH-03, AUTH-04
**Success Criteria** (what must be TRUE):
  1. User can log into Douyin via web view in the app
  2. Authentication tokens are stored encrypted in Keychain, not UserDefaults
  3. Session persists across app restarts
  4. Token refresh is handled automatically when expired
  5. API client can make authenticated requests to Douyin endpoints
**Plans:** TBD
**UI hint**: yes

### Phase 3: tvOS Foundation & Navigation
**Goal:** App follows tvOS Human Interface Guidelines with proper focus-based navigation
**Depends on:** Phase 2
**Requirements:** UX-01, UX-02, UX-03, UX-04, UX-05, UX-06, UX-07, UX-08, UX-09
**Success Criteria** (what must be TRUE):
  1. Focus-based navigation works correctly with Siri Remote
  2. Standard Siri Remote gestures are supported (swipe to move focus, click to select, Menu to go back, Play/Pause toggles video)
  3. Tab-based main navigation works for primary sections
  4. Parallax effect configured correctly on focusable items
  5. Dictation support available for text entry
  6. Content respects safe area/overscan insets, nothing is cut off
  7. All focus targets meet minimum 88x88pt size
  8. App respects system dark mode setting
  9. App handles background/foreground transitions correctly (pauses video, refreshes data)
**Plans:** TBD
**UI hint**: yes

### Phase 4: Live Room Core Display
**Goal:** Users can view a live room with statistics overlay and live video preview
**Depends on:** Phase 3
**Requirements:** LIVE-01, LIVE-02, LIVE-03, LIVE-04, LIVE-05, LIVE-06, LIVE-07
**Success Criteria** (what must be TRUE):
  1. Basic statistics displayed: viewer count, likes, total gifts
  2. Live video preview plays via AVPlayer
  3. Statistics overlay displayed on top of video
  4. Statistics use large text sizing readable from couch distance
  5. Clear visual indicator shows whether room is live/offline
  6. User can toggle between overlay mode and full-screen video
  7. Picture in Picture (PiP) support works for video playback
**Plans:** TBD
**UI hint**: yes

### Phase 5: Favorites Management
**Goal:** Users can save and manage favorite rooms for quick access
**Depends on:** Phase 4
**Requirements:** FAV-01, FAV-02, FAV-03, FAV-04, FAV-05, FAV-06
**Success Criteria** (what must be TRUE):
  1. User can add a new room by entering room ID or URL
  2. User can view a list of all saved favorite rooms
  3. User can delete rooms from favorites
  4. User can quickly select a favorite room to monitor
  5. Last viewed room is remembered and opened automatically on app launch
  6. Favorites persist across app restarts via SwiftData
**Plans:** TBD
**UI hint**: yes

### Phase 6: Refresh & Quality of Life
**Goal:** Automatic and manual refresh work with proper background integration, and tvOS polish features are complete
**Depends on:** Phase 5
**Requirements:** REFRESH-01, REFRESH-02, REFRESH-03, QOL-01, QOL-02
**Success Criteria** (what must be TRUE):
  1. User can trigger manual pull-to-refresh for immediate stats update
  2. Automatic refresh attempts every 30 minutes when possible
  3. Uses system BackgroundTasks framework for background refresh
  4. Top Shelf extension provides quick access to favorites from Apple TV home screen
  5. App icon has correct sizing configured in Xcode project
**Plans:** TBD
**UI hint**: yes

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Project Setup & Core Infrastructure | 0/3 | Not started | - |
| 2. Authentication & API Layer | 0/0 | Not started | - |
| 3. tvOS Foundation & Navigation | 0/0 | Not started | - |
| 4. Live Room Core Display | 0/0 | Not started | - |
| 5. Favorites Management | 0/0 | Not started | - |
| 6. Refresh & Quality of Life | 0/0 | Not started | - |

---

*Last updated: 2026-03-30 after planning*
