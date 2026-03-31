---
phase: 07-integration-gap-closure
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-31
---

# Phase 7: Integration Gap Closure - Validation Strategy

## Executive Summary

This is a gap closure phase fixing existing integration issues. All requirements and implementation tasks are already clearly defined from the audit. No external research needed - the fixes are straightforward mechanical changes to existing code.

## Requirements Breakdown

| Requirement | Task | Validation Strategy |
|-------------|------|---------------------|
| **AUTH-04** | Update LiveStatsService to use AuthService.authenticatedRequest() | Check that LiveStatsService has AuthService property and uses authenticatedRequest |
| **LIVE-02** | Add streamURL property to LiveRoom model | Check that LiveRoom has `var streamURL: String?` property |
| **FAV-01** | Update FavoritesService to store streamURL when adding room | Check that addRoom updates streamURL from fetchStats response |
| **REFRESH-02** | Update RefreshService to use authenticated fetch and update streamURL | Check that refreshAllFavorites uses authenticated fetch and updates streamURL |
| **QOL-01** | Fix Top Shelf import and add deep link handling | Check that import DouyinLiveTVDomain exists and onContinueUserActivity handles openRoom |

## Validation Architecture

### Unit Tests (not required)
No new unit tests needed - this is integration fixing existing code. All changes are mechanical and will be verified by inspection in VERIFICATION.md after execution.

### Acceptance Criteria

All acceptance criteria are already specified per-task in the PLAN.md files. Each task includes:
- `<read_first>`: which file to read before change
- `<action>`: exact concrete changes
- `<acceptance_criteria>`: grep-verifiable conditions that prove correctness

### Must-Have Truths After Execution

1. **✓ LiveStatsService uses AuthService for all requests** - `grep "authService.authenticatedRequest" LiveStatsService.swift` matches once
2. **✓ DependencyContainer injects AuthService into LiveStatsService** - `grep "liveStatsService = LiveStatsService(apiClient: apiclient, authService: authService)" DependencyContainer.swift` matches once
3. **✓ LiveRoom model has streamURL property** - `grep "var streamURL: String\?" LiveRoom.swift` matches once
4. **✓ FavoritesService.addRoom updates streamURL** - `grep "room.streamURL = stats.streamURL" FavoritesService.swift` matches once
5. **✓ RefreshService uses authenticated fetch and updates streamURL** - `grep "try await liveStatsService.fetchStats" RefreshService.swift` matches and includes streamURL update
6. **✓ Top Shelf imports DouyinLiveTVDomain** - `grep "import DouyinLiveTVDomain" DouyinLiveTVTopShelf.swift` matches once
7. **✓ DouyinLiveTVApp handles onContinueUserActivity for openRoom** - `grep "onContinueUserActivity" DouyinLiveTVApp.swift` matches and extracts roomId to initialRoomId

## Nyquist Compliance Status

All requirements have explicit validation checks defined. Every task has concrete acceptance criteria that can be verified after execution. This phase is **nyquist_compliant**.

| Status | Item |
|--------|------|
| ✓ All 5 requirements have validation | nyquist_compliant: true |
| ✓ Each task has checkable acceptance criteria | All tasks pass |
| ✓ All must-have truths defined for post-execution verification | Truth list complete |
