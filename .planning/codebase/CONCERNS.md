# Codebase Concerns

**Analysis Date:** 2026-03-31

## Tech Debt

**Multiple URL Parsing Patterns in Favorites Extraction:**
- Issue: `FavoritesService.extractRoomId(from:)` uses a sequence of ad-hoc pattern matching checks instead of a single comprehensive regex or proper URL parsing. Handles `/video/XXX`, `v.douyin.com/XXX`, and `/user/XXX/live` patterns with separate code paths. Falls back to returning trimmed input directly when no pattern matches, which may not be valid.
- Files: `DouyinLiveTV/Data/Services/FavoritesService.swift`
- Impact: May fail to extract room IDs from less common URL formats. Adding new URL patterns requires more code. The current approach is functional but not robust.
- Fix approach: Refactor to use `URL` components and a more comprehensive regex that captures all known patterns. Add unit tests for edge cases.

**Legacy Persistence in WatchLiveView:**
- Issue: `WatchLiveView` still reads/writes last viewed room state to `UserDefaults` as "legacy" fallback alongside the `FavoritesService` that uses SwiftData. This creates dual persistence that can get out of sync.
- Files: `DouyinLiveTV/UI/WatchLive/WatchLiveView.swift` (lines 103-122)
- Impact: Potential state inconsistency between persisted favorites and the last viewed room. UserDefaults is not secure and shouldn't hold app state long-term.
- Fix approach: Remove the UserDefaults fallback and rely entirely on `FavoritesService.getLastSelectedRoomId()` which already persists this information properly.

**Sequential Refresh in Background:**
- Issue: `RefreshService.refreshAllFavorites()` refreshes all favorite rooms sequentially one after another in a for-loop.
- Files: `DouyinLiveTV/Data/Services/RefreshService.swift` (lines 129-151)
- Impact: If the user has many favorites, the background task may expire before completing all refreshes. Can be slow for large favorite lists.
- Fix approach: Add controlled concurrency with a limit on concurrent requests. Check remaining background time before starting each refresh.

**Singleton Dependency Container:**
- Issue: `DependencyContainer` uses a singleton pattern (`shared` static instance) that makes unit testing of view models more difficult. Dependencies are strongly referenced for the entire app lifecycle.
- Files: `DouyinLiveTV/App/DependencyContainer.swift`
- Impact: Cannot easily mock dependencies in integration tests. Prevents multiple container instances for different user sessions. Memory usage is higher due to permanent retention.
- Fix approach: Keep the singleton for production use but enable the container to be instantiated with mock dependencies for testing. This doesn't require changing much existing code.

## Known Bugs

**APIError Equatable Conformance is Incomplete:**
- Symptoms: The `APIError.networkError` case ignores the associated `Error` value for equality comparison. Two network errors are always considered equal regardless of the underlying error.
- Files: `DouyinLiveTV/Data/Network/APIClient.swift` (lines 3-28)
- Trigger: Any equality check on `APIError` values that involve `networkError`.
- Workaround: The conformance is only needed for tests/equatable conformance, doesn't affect runtime behavior.

**Stream URL Persistence Duplication:**
- Symptoms: `streamURL` is stored in both the `LiveRoom` SwiftData entity and cached in `UserDefaults` by `WatchLiveView`. When a user updates favorites, the cached UserDefaults entry can be stale.
- Files: `DouyinLiveTV/UI/WatchLive/WatchLiveView.swift` lines 103-121, `DouyinLiveTV/Data/Services/FavoritesService.swift`
- Trigger: App launch with a stale cache entry.
- Workaround: User refreshes manually to get current stream URL.

## Security Considerations

**Third-Party Dependency on KeychainSwift:**
- Risk: The app uses the `KeychainSwift` pod for secure token storage, which is a widely-used but external dependency. No SPM/checksum verification is documented in this analysis context.
- Files: `DouyinLiveTV/Data/Keychain/TokenStorage.swift`
- Current mitigation: Tokens are stored with `afterFirstUnlock` accessibility which is appropriate for tvOS.
- Recommendations: Consider migrating to native `Security.framework` Keychain APIs to remove third-party dependency, or add explicit dependency verification.

**HTTP API Potential:**
- Risk: The app currently expects HTTPS but there is no App Transport Security exception configured in Info.plist. If the Douyin API ever redirects to HTTP, it will fail.
- Files: `DouyinLiveTV/Info.plist`
- Current mitigation: API endpoint is configured with HTTPS. ATS blocks any HTTP requests by default.
- Recommendations: No action needed unless API changes. If you need to handle HTTP responses, add ATS exceptions.

## Performance Bottlenecks

**Background Refresh with Many Favorites:**
- Problem: Background refresh can hit time limits when user has more than 10-15 favorite rooms.
- Files: `DouyinLiveTV/Data/Services/RefreshService.swift`
- Cause: Sequential API requests in a loop accumulate latency. Background tasks on tvOS have strict time limits.
- Improvement path: Add concurrent requests with rate limiting, prioritize recently viewed rooms, stop early when running out of time.

**No Image Caching for Avatars:**
- Problem: Avatar images from Douyin CDN are reloaded every time the favorites list is displayed. No URL caching policy configured.
- Files: `DouyinLiveTV/Data/Network/APIClient.swift`
- Cause: Uses default `URLSession` configuration which may cache but there's no explicit policy.
- Improvement path: Configure `URLCache` with appropriate memory/disk capacity for images.

## Fragile Areas

**DependencyContainer FatalError on Startup:**
- Files: `DouyinLiveTV/App/DependencyContainer.swift` line 43
- Why fragile: If SwiftData `ModelContainer` initialization fails at startup, the app will crash immediately with `fatalError()`. There's no graceful error handling.
- Safe modification: Add proper error handling and display an error screen instead of crashing. However, this failure mode is extremely unlikely in production.
- Test coverage: No test coverage for this code path.

**Hardcoded 30-Minute Refresh Interval:**
- Files: `DouyinLiveTV/Data/Services/RefreshService.swift` line 23
- Why fragile: The 30-minute refresh interval is hardcoded. Changing it requires a code change. Background refresh scheduling is not adjustable based on number of favorites.
- Safe modification: Make it configurable at the container level.
- Test coverage: Covered by tests but interval is still hardcoded.

**Room ID Extraction Fallback:**
- Files: `DouyinLiveTV/Data/Services/FavoritesService.swift` lines 133-135
- Why fragile: When no regex pattern matches, the code returns the entire trimmed input string as the room ID. This can result in invalid room IDs being passed to the API.
- Why fragile: Some URLs will contain extra characters that will cause API requests to fail. The failure happens late in the flow rather than at extraction time.
- Safe modification: Return nil when no valid pattern matches to allow early error feedback to the user.
- Test coverage: No tests for edge cases with unusual URL formats.

## Scaling Limits

**Sequential Refresh:**
- Current capacity: Works fine for up to ~10-15 favorite rooms within background time limits.
- Limit: Above ~20 rooms, the background task will likely time out before completion.
- Scaling path: Implement concurrent refreshing with a max concurrent operation count. Prioritize based on `lastViewed` - refresh most recently viewed first, stop when time is low.

**SwiftData ModelContainer:**
- Current capacity: The entire app shares one `ModelContainer`, which is fine for expected use (dozens of favorites).
- Limit: Not a practical limit for this app - SwiftData handles thousands of objects easily.
- Scaling path: Not an issue for the expected use case.

## Dependencies at Risk

**KeychainSwift:**
- Risk: Third-party dependency maintained by community. While stable, it's an unnecessary dependency for simple keychain operations.
- Impact: Token storage would need to be migrated if KeychainSwift is abandoned or has a security issue.
- Migration plan: Implement simple keychain operations using native Security.framework, which is straightforward for this use case.

## Missing Critical Features

**Error Retry Logic for API Requests:**
- Problem: No automatic retry on transient network failures. All failures fail immediately.
- Blocks: No automatic recovery from temporary network blips during background refresh or foreground operations.

**Offline Support:**
- Problem: When network is unavailable, the app cannot display cached data beyond what's already loaded. Last known `isLive` status isn't shown reliably when offline.
- Blocks: App is unusable without an internet connection.

**Pull-to-Refresh for Favorites List:**
- Problem: The favorites list doesn't support manual pull-to-refresh. Only automatic refresh occurs.
- Blocks: Users cannot manually force a refresh of favorite room status when they know a stream should be live.

## Test Coverage Gaps

**FavoritesService URL Extraction:**
- What's not tested: Various URL formats haven't been unit tested. Edge cases with query parameters, extra whitespace, unexpected URL structures.
- Files: `DouyinLiveTV/Data/Services/FavoritesService.swift`
- Risk: New URL patterns from Douyin may break room ID extraction and the issue won't be caught until users report it.
- Priority: Medium

**Background Task Handling:**
- What's not tested: `RefreshService` background task scheduling and execution isn't unit tested.
- Files: `DouyinLiveTV/Data/Services/RefreshService.swift`
- Risk: Background refresh may stop working after iOS/tvOS version updates and won't be caught in CI.
- Priority: Low

**Integration Tests for Full Login Flow:**
- What's not tested: The complete QR login flow isn't integration tested with real API.
- Files: `DouyinLiveTV/Data/Network/AuthService.swift`
- Risk: Changes to the QR polling or token refresh can break authentication without breaking unit tests.
- Priority: Medium

**Top Shelf Extension:**
- What's not tested: `DouyinLiveTVTopShelf` deep linking and SwiftData access isn't unit tested.
- Files: `DouyinLiveTVTopShelf/DouyinLiveTVTopShelf.swift`
- Risk: Changes to `LiveRoom` model can break Top Shelf without being caught.
- Priority: Low

---

*Concerns audit: 2026-03-31*
