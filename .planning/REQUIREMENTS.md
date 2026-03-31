# Requirements: Douyin Live TV

**Defined:** 2026-03-30
**Core Value:** Conveniently monitor Douyin live room statistics on the big TV screen, keep it simple and fast.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Platform UX (tvOS Fundamentals)

- [x] **UX-01**: Focus-based navigation works correctly with Siri Remote
- [x] **UX-02**: Standard Siri Remote gesture support: swipe moves focus, click selects, Menu goes back, Play/Pause toggles video
- [x] **UX-03**: Tab-based main navigation for primary sections
- [x] **UX-04**: Parallax effect on focusable items (system-provided, properly configured)
- [x] **UX-05**: Dictation support for text entry (room ID/URL input)
- [x] **UX-06**: Proper safe area/overscan insets, no content cut off
- [x] **UX-07**: Minimum 88x88pt focus targets per tvOS HIG
- [x] **UX-08**: Dark mode support, respects system setting
- [x] **UX-09**: Handles app background/foreground transitions (pauses video, refreshes data)

### Authentication

- [x] **AUTH-01**: User can log into Douyin account via web view
- [x] **AUTH-02**: Authentication tokens stored securely in Keychain
- [x] **AUTH-03**: Session persists across app restarts
- [x] **AUTH-04**: Token refresh handled automatically

### Live Room Display (Core Feature)

- [x] **LIVE-01**: Display basic statistics: viewer count, likes, total gifts
- [x] **LIVE-02**: Live video preview playback via AVPlayer
- [x] **LIVE-03**: Stats overlay displayed on top of video
- [x] **LIVE-04**: Large text sizing for stats (visible from couch distance)
- [x] **LIVE-05**: Visual live/offline status indicator
- [x] **LIVE-06**: Toggle between overlay mode and full-screen video
- [x] **LIVE-07**: Picture in Picture (PiP) support for video playback

### Favorites Management

- [x] **FAV-01**: User can add new room by entering room ID or URL
- [x] **FAV-02**: User can view list of saved favorite rooms
- [x] **FAV-03**: User can delete rooms from favorites
- [x] **FAV-04**: User can quickly select a favorite room to monitor
- [x] **FAV-05**: Last viewed room is remembered and opened on app launch
- [x] **FAV-06**: Favorites persist across app restarts via SwiftData

### Refresh

- [ ] **REFRESH-01**: Manual pull-to-refresh for immediate stats update
- [ ] **REFRESH-02**: Automatic refresh every 30 minutes when possible
- [ ] **REFRESH-03**: Uses system BackgroundTasks framework for background refresh

### Quality of Life (tvOS)

- [x] **QOL-01**: Top Shelf extension for quick access to favorites from home screen
- [x] **QOL-02**: Correct tvOS app icon sizing in Xcode project

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

*(None currently)*

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Multiple concurrent rooms display | User requirement: single room only, too cluttered on TV |
| Chat/danmaku display | Explicitly out of scope per user request, clutters stats UI |
| Historical data graphs/charts | User doesn't need analysis/recording, only current monitoring |
| Push notifications for live status | User explicitly declined, adds unnecessary infrastructure complexity |
| Multi-user support | Only for personal use, unnecessary complexity |
| App Store publication and optimization | Personal sideload use only, no need to invest in compliance |
| 3D Touch / Force Touch | Not supported on Siri Remote |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| UX-01 | Phase 3 | Complete |
| UX-02 | Phase 3 | Complete |
| UX-03 | Phase 3 | Complete |
| UX-04 | Phase 3 | Complete |
| UX-05 | Phase 3 | Complete |
| UX-06 | Phase 3 | Complete |
| UX-07 | Phase 3 | Complete |
| UX-08 | Phase 3 | Complete |
| UX-09 | Phase 3 | Complete |
| AUTH-01 | Phase 2 | Complete |
| AUTH-02 | Phase 2 | Complete |
| AUTH-03 | Phase 2 | Complete |
| AUTH-04 | Phase 2 | Complete |
| LIVE-01 | Phase 4 | Complete |
| LIVE-02 | Phase 4 | Complete |
| LIVE-03 | Phase 4 | Complete |
| LIVE-04 | Phase 4 | Complete |
| LIVE-05 | Phase 4 | Complete |
| LIVE-06 | Phase 4 | Complete |
| LIVE-07 | Phase 4 | Complete |
| FAV-01 | Phase 5 | Complete |
| FAV-02 | Phase 5 | Complete |
| FAV-03 | Phase 5 | Complete |
| FAV-04 | Phase 5 | Complete |
| FAV-05 | Phase 5 | Complete |
| FAV-06 | Phase 5 | Complete |
| REFRESH-01 | Phase 6 | Pending |
| REFRESH-02 | Phase 6 | Pending |
| REFRESH-03 | Phase 6 | Pending |
| QOL-01 | Phase 6 | Complete |
| QOL-02 | Phase 6 | Complete |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0 ✓

---

*Requirements defined: 2026-03-30*
*Last updated: 2026-03-30 after roadmap creation*
