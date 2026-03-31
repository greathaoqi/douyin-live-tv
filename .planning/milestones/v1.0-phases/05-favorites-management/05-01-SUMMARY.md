---
phase: 05
plan: 01
subsystem: Data
tags: [SwiftData, persistence, favorites, service]
dependency_graph:
  requires: [DependencyContainer, LiveStatsService, LiveRoom model]
  provides: [FavoritesService, favorites persistence]
  affects: [UI layer favorites features]
tech_stack:
  added: [SwiftData, Combine]
  patterns: [Singleton DI container, async/await, @Published observation]
key_files:
  created: [DouyinLiveTV/Data/Services/FavoritesService.swift]
  modified: [DouyinLiveTV/App/DependencyContainer.swift]
decisions:
  - Use SwiftData for favorites persistence (locked decision)
  - Store last selected room ID in UserDefaults for app launch recall
  - Support multiple URL formats for room ID extraction (raw ID, /video/, v.douyin.com, /user/{id}/live)
  - Sort favorites by lastViewed descending so recently used rooms appear first
metrics:
  duration_seconds: 120
  completed_date: 2026-03-31
  tasks_total: 2
  tasks_completed: 2
  files_modified: 2
  lines_added: 145
---

# Phase 05 Plan 01: Favorites Persistence Foundation Summary

Creates the `FavoritesService` data layer service and configures SwiftData to include the `LiveRoom` model, establishing the persistence foundation for all favorites functionality. Follows locked decision to use SwiftData for persistence, matching existing service patterns in the project.

## Completed Tasks

| Task | Name | Commit | Files |
| ---- | -----| ------ | ----- |
| 1 | Update DependencyContainer to add LiveRoom to SwiftData ModelContainer | a20eded | DouyinLiveTV/App/DependencyContainer.swift |
| 2 | Create FavoritesService with all required operations | 903f237 | DouyinLiveTV/Data/Services/FavoritesService.swift |

## Features Implemented

**FavoritesService:**
- `fetchFavorites()` - fetches all favorite rooms sorted by `lastViewed` descending (nil lastViewed sorted last)
- `addRoom(roomId:)` - fetches room metadata via `LiveStatsService`, upserts into SwiftData, refreshes favorites
- `deleteRoom(_:)` - deletes room from SwiftData, refreshes favorites
- `updateLastViewed(_:)` - updates `lastViewed` timestamp to current date
- `saveLastSelectedRoomId(_:)` / `getLastSelectedRoomId()` - persists last selected room to `UserDefaults` for app launch recall
- `extractRoomId(from:)` - extracts room ID from raw input or various URL formats:
  - Raw numeric string: returns as-is
  - `https://www.douyin.com/video/XXX` → extracts XXX
  - `https://v.douyin.com/XXX` → extracts XXX
  - `https://www.douyin.com/user/XXX/live` → extracts XXX

**DependencyContainer changes:**
- Added `LiveRoom.self` to `ModelContainer` initialization
- Added `public let favoritesService: FavoritesService` stored property
- Initialized `FavoritesService` with `modelContainer` and `liveStatsService`

## Deviations from Plan

None - plan executed exactly as written.

## Auth Gates

None - no authentication required for this task.

## Known Stubs

None - all functionality fully implemented.

## Verification

Success criteria all met:
- DependencyContainer has `favoritesService` property and includes `LiveRoom` in model container ✓
- `FavoritesService` implements all required CRUD operations ✓
- Last room persistence implemented via `UserDefaults` ✓
- All acceptance criteria matched ✓

## Self-Check: PASSED

- All created files exist ✓
- All commits verified ✓
