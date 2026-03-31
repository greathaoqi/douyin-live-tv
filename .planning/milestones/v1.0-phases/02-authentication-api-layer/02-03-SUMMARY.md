---
phase: 02-authentication-api-layer
plan: 03
subsystem: Data / App
tags: [authentication, auth-service, auth-state-manager, token-refresh, qr-login]
dependency_graph:
  requires: [TokenStorage, APIClient, AuthToken, LoginQRCode, Endpoint]
  provides: [AuthService, AuthStateManager, DependencyContainer with all dependencies]
  affects: [UI Layer - observes authentication state, Network Layer - authenticated requests]
tech_stack:
  added: [actor-based concurrency, @MainActor @Observable, Swift concurrency]
  patterns: [dependency injection, observer pattern, actor isolation for thread safety]
key_files:
  created:
  - DouyinLiveTV/Data/Network/AuthService.swift
  - DouyinLiveTV/App/AuthStateManager.swift
  - DouyinLiveTV/Data/Network/DouyinAPIEndpoints.swift
  modified:
  - DouyinLiveTV/Data/Network/Endpoint.swift
  - DouyinLiveTV/App/DependencyContainer.swift
decisions:
  - Use actor for AuthService to prevent race conditions with concurrent refresh attempts
  - AuthStateManager is @MainActor @Observable for thread-safe UI observation
  - No token caching outside TokenStorage (per D-04 decision)
  - Actor isolation eliminates concurrent refresh race conditions
metrics:
  duration_seconds: 120
  completed_date: 2026-03-31
  tasks_total: 3
  tasks_completed: 3
  files_changed: 5
---

# Phase 02 Plan 03: Implement AuthService and AuthStateManager Summary

## One-Liner Summary

Actor-based `AuthService` implements QR login with polling and automatic token refresh, while `@MainActor` `AuthStateManager` provides observable authentication state for UI. All dependencies registered in `DependencyContainer`.

## Requirements Fulfilled

- **AUTH-01**: Implements QR login flow with polling - Done ✓
- **AUTH-03**: Implements automatic token refresh - Done ✓
- **AUTH-04**: Implements 401 handling with logout on refresh failure - Done ✓

## Completed Tasks

| Task | Name | Commit | Files |
| ---- | ---- | ------ | ----- |
| 1 | Implement AuthService with QR login flow and polling | dd3423f | DouyinLiveTV/Data/Network/AuthService.swift |
| 2 | Implement automatic token refresh logic | 6724d27 | AuthService.swift, Endpoint.swift, DouyinAPIEndpoints.swift |
| 3 | Create AuthStateManager and register dependencies | 09dde0c | AuthStateManager.swift, DependencyContainer.swift |

## Implementation Details

### AuthService

- Defined as `public actor AuthService` to prevent race conditions with concurrent requests
- `startQRLogin()`: Fetches QR code from API, starts background polling
- Polling: 2.5 second interval, 2 minute max (48 attempts) as recommended
- On confirmation: Saves tokens to `TokenStorage`, updates state to `.authenticated`
- `refreshIfNeeded()`: Checks expiration, uses refresh token to get new tokens
- `authenticatedRequest()`: Adds bearer token, handles 401 by clearing tokens and logging out
- One retry attempt only to prevent infinite loops

### AuthStateManager

- `@MainActor class AuthStateManager: Observable` with `@Observable` for UI observation
- `enum State`: `.unauthenticated`, `.authenticating`, `.authenticated`
- `checkStoredCredentials()`: Checks `tokenStorage.hasValidTokens()` on app launch
- `logout()`: Clears tokens via `tokenStorage.clear()` and sets state to `.unauthenticated`
- Does not cache tokens - follows D-04 decision: tokens only in Keychain

### DependencyContainer

- Registered all four dependencies as public stored properties:
  - `tokenStorage: TokenStorage`
  - `apiClient: APIClient`
  - `authService: AuthService`
  - `authStateManager: AuthStateManager`
- All initialized in `init()` as shared singletons

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

- Refresh token endpoint URL is placeholder (`https://sso.douyin.com/refresh_token`) - actual endpoint will be confirmed during validation/integration. The infrastructure is complete, endpoint path/URL can be updated easily when actual API details are known.

## Success Criteria Verification

| Criterion | Status |
| --------- | ------ |
| Actor-based AuthService prevents race conditions | ✓ Pass |
| QR login flow with polling implemented | ✓ Pass |
| Automatic token refresh on 401 implemented | ✓ Pass |
| Logout clears tokens from Keychain | ✓ Pass |
| AuthStateManager provides observable state for UI | ✓ Pass |
| Credentials checked on app launch | ✓ Pass |
| All dependencies registered in DependencyContainer | ✓ Pass |
| Follows D-07 (automatic refresh) and D-08 (logout on failure) | ✓ Pass |

## Self-Check: PASSED

- All created files exist ✓
- All commits exist ✓
- All acceptance criteria met ✓
