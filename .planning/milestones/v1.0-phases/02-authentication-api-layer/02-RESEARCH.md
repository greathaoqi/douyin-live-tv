# Phase 2: Authentication & API Layer - Research

**Researched:** 2026-03-30
**Domain:** tvOS Douyin Authentication with QR code login, Keychain storage, and automatic token refresh
**Confidence:** MEDIUM

## Summary

This phase implements QR code-based authentication for Douyin on tvOS, following the familiar flow used by Douyin TV/WEB where users display a QR code on screen and scan it with their mobile Douyin app. Credentials are stored securely in Keychain using the KeychainSwift wrapper, with automatic token refresh and session persistence across app restarts.

The architecture requires a QR code generation and polling mechanism, a secure token store, an HTTP API client, and an auth state manager that integrates with the app's existing dependency injection pattern. The project constraints (personal use, simplicity) favor manual implementation over complex generated code.

**Primary recommendation:** Use native `URLSession` for HTTP requests (avoids extra dependency), implement the "request interceptor + retry" pattern for automatic token refresh, and structure the network layer in the Data layer with auth state as an `@MainActor` observable object for UI integration.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Login Flow
- **D-01:** QR code login flow — user scans QR code displayed on Apple TV with their mobile Douyin app to authenticate
- **D-02:** No in-app web view username/password login — QR code is the only login method

### Keychain Storage
- **D-03:** Use KeychainSwift third-party wrapper library instead of raw Keychain Services API
- **D-04:** Tokens stored encrypted, never stored in UserDefaults or SwiftData

### API Client
- **D-05:** Manual implementation of API client for Douyin endpoints
- **D-06:** No OpenAPI/Swagger generated code — only a handful of endpoints needed

### Token Refresh
- **D-07:** Automatic silent refresh when access token expires
- **D-08:** Only prompt user to re-login (re-scan QR) if refresh token is also expired or refresh fails

### Claude's Discretion
- Choice of HTTP client (native URLSession vs Alamofire)
- Exact endpoint URL structure and response parsing
- QR code polling interval configuration
- Error handling strategy for network failures
- Architectural placement (Data layer vs Network layer)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AUTH-01 | User can log into Douyin account via QR code | Complete research on QR code login flow pattern, polling mechanism identified |
| AUTH-02 | Authentication tokens stored securely in Keychain | KeychainSwift verified, tvOS compatibility confirmed, secure storage patterns documented |
| AUTH-03 | Session persists across app restarts | Keychain persists credentials across restarts, auth state loading pattern on app launch identified |
| AUTH-04 | Token refresh handled automatically | Request interceptor pattern with retry documented, 401 token detection approach verified |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| KeychainSwift | 8.0.0 | Keychain services wrapper | Most popular Swift wrapper, actively maintained, tvOS supported, simpler than raw Keychain Services API |
| SwiftUI | (System) | Login UI | Already project standard, no third-party UI needed |
| URLSession | (System) | HTTP client | Built-in, no extra dependency, supports async/await natively, sufficient for small number of endpoints |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Alamofire | 5.9.0 | HTTP client with built-in request interceptor | If automatic token refresh is simpler with the built-in interceptor |
| CoreImage | (System) | QR code generation | Built-in, no extra dependency needed for generating QR images |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| URLSession | Alamofire | More complex retry/interceptor logic built-in, but adds a 3rd-party dependency |
| KeychainSwift | Raw Keychain Services | No dependency, but much more boilerplate, error-prone |
| KeychainSwift | SwiftKeychainWrapper | Similar functionality, KeychainSwift is more popular |

**Installation:**
```swift
// In Xcode Swift Package Manager dependencies add:
https://github.com/evgenyneu/KeychainSwift.git
// Version: 8.0.0 or later
```

## Architecture Patterns

### Recommended Project Structure
```
DouyinLiveTV/
├── App/
│   └── DependencyContainer.swift  ← Register AuthService and APIClient
├── Data/
│   ├── Network/                    ← API client and network layer
│   │   ├── APIClient.swift
│   │   ├── AuthService.swift
│   │   ├── Endpoint.swift
│   │   └── DouyinAPIEndpoints.swift
│   └── Keychain/                   ← Token storage wrapper
│       └── TokenStorage.swift
├── Domain/
│   └── Models/
│       ├── AuthToken.swift         ← Auth token model
│       └── LoginQRCode.swift       ← QR code response model
└── UI/
    └── Login/                       ← Login UI
        ├── LoginView.swift
        └── LoginViewModel.swift
```

### Pattern 1: QR Code Login Flow
**What:** Standard Douyin web login flow:
1. Client requests a QR code UUID from Douyin API
2. Generate QR image from UUID/URL
3. Start polling the status endpoint
4. User scans QR with mobile app and confirms login
5. Polling completes and receives access/refresh token pair
6. Store tokens in Keychain, update auth state

**When to use:** This is the official Douyin flow, users are already familiar with it.

**Example:**
```swift
// Pseudo-code pattern
actor AuthService {
    private let tokenStorage: TokenStorage
    private let apiClient: APIClient

    func startQRLogin() async throws -> LoginQRCode {
        // 1. Get QR code from Douyin API
        let qrResponse = try await apiClient.requestQRCode()
        // 2. Start polling in background
        Task { try await pollForConfirmation(qrResponse.uuid) }
        return qrResponse
    }

    private func pollForConfirmation(uuid: String) async throws {
        // Poll every 2-3 seconds until confirmed or timeout
        for _ in 0..<maxAttempts where !isConfirmed {
            let status = try await apiClient.checkQRStatus(uuid: uuid)
            if status.confirmed {
                let tokens = status.tokens
                try await tokenStorage.save(tokens)
                updateAuthState(.authenticated)
                return
            }
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}
```

### Pattern 2: Automatic Token Refresh with Retry
**What:** Intercept 401 Unauthorized responses, attempt to refresh token, then retry original request once. If refresh fails, log out user.

**When to use:** Standard approach for automatic silent refresh that doesn't block UI.

**Example:**
```swift
// URLSession with 401 interception pattern
extension APIClient {
    func authenticatedRequest<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        do {
            return try await performRequest(endpoint, with: currentAccessToken)
        } catch let error as APIError where error == .unauthorized {
            // Got 401, try to refresh
            let newTokens = try await refreshToken()
            try await tokenStorage.save(newTokens)
            // Retry original request with new token
            return try await performRequest(endpoint, with: newTokens.accessToken)
        } catch {
            // If refresh fails, throw and trigger logout
            if refreshTokenExpired {
                authState = .unauthenticated
            }
            throw error
        }
    }
}
```

### Pattern 3: Auth State Observation for UI Routing
**What:** `@MainActor` observable auth state that the root view can observe to switch between login and main UI.

**Example:**
```swift
@MainActor
@Observable
class AuthStateManager {
    enum State {
        case unauthenticated
        case authenticating
        case authenticated
    }

    private(set) var state: State = .unauthenticated

    func checkStoredCredentials() {
        // Load from Keychain on app launch
        if tokenStorage.hasValidTokens() {
            state = .authenticated
        } else {
            state = .unauthenticated
        }
    }
}
```

### Anti-Patterns to Avoid
- **Storing tokens in UserDefaults:** UserDefaults is not encrypted, violates requirement AUTH-02, always use Keychain
- **Storing refresh token in plain text:** KeychainSwift handles encryption automatically, just don't log it
- **Polling too frequently:** Douyin may rate-limit, 2-3 seconds interval is sufficient
- **Not checking token expiration on app launch:** Always verify expiration date when loading from Keychain at startup
- **Retrying multiple times on 401:** Prevents infinite refresh loops, one retry is enough

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Keychain Services | Custom wrapper around raw C API | KeychainSwift | Keychain has many edge cases with accessibility, sharing, and error codes |
| QR code generation | Custom QR encoding | CoreImage CIFilter QRCode | Built into iOS/tvOS, no extra dependency needed |
| JSON parsing | Custom deserialization | Codable (built-in) | System handled, efficient, standard |
| HTTP request signing with retry | Custom retry logic | URLSession with do-catch pattern (or Alamofire RequestInterceptor) | Token refresh needs careful error handling to avoid logout loops |

**Key insight:** Authentication and security are areas where battle-tested libraries prevent subtle bugs that can compromise credentials. Keychain in particular is notoriously tricky with Swift variants.

## Common Pitfalls

### Pitfall 1: Keychain Accessibility on tvOS
**What goes wrong:** Tokens don't persist across app restarts because wrong accessibility setting
**Why it happens:** Default accessibility may not persist after reboot on tvOS
**How to avoid:** Use `KeychainSwiftAccessOptions.whenUnlocked` or `.afterFirstUnlock` appropriate for tvOS
**Warning signs:** User has to re-login after every reboot, works until app is terminated

### Pitfall 2: QR Code Polling Timeout
**What goes wrong:** Polling runs forever if user doesn't scan the code
**Why it happens:** Forgot to implement a maximum polling timeout
**How to avoid:** Limit polling to ~2 minutes (about 40 attempts at 3s interval), then generate new QR
**Warning signs:** App stuck in "waiting for scan" state indefinitely

### Pitfall 3: Concurrent Token Refresh Race Condition
**What goes wrong:** Multiple requests fail with 401 and trigger multiple concurrent refresh calls
**Why it happens:** No serialization of refresh attempts
**How to avoid:** Use an actor to isolate auth operations or a simple boolean flag to prevent concurrent refreshes
**Warning signs:** Multiple refresh requests in flight, corrupt token storage

### Pitfall 4: Missing Douyin API Signature Requirements
**What goes wrong:** Requests get rejected with signature error
**Why it happens:** Douyin requires specific headers/signatures that change over time
**How to avoid:** Research current required headers (user-agent, cookies, msToken), implement signature if needed
**Warning signs:** 403 responses even with valid token

## Code Examples

### KeychainSwift Token Storage (tvOS)
```swift
import KeychainSwift

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

class TokenStorage {
    private let keychain = KeychainSwift()
    private let accessTokenKey = "com.douyinlivetv.accessToken"
    private let refreshTokenKey = "com.douyinlivetv.refreshToken"
    private let expiresAtKey = "com.douyinlivetv.expiresAt"

    func save(_ token: AuthToken) throws {
        keychain.set(token.accessToken, forKey: accessTokenKey, withAccess: .afterFirstUnlock)
        keychain.set(token.refreshToken, forKey: refreshTokenKey, withAccess: .afterFirstUnlock)
        keychain.set(token.expiresAt.timeIntervalSince1970, forKey: expiresAtKey, withAccess: .afterFirstUnlock)
    }

    func load() -> AuthToken? {
        guard let accessToken = keychain.get(accessTokenKey),
              let refreshToken = keychain.get(refreshTokenKey),
              let expiresAtInterval = keychain.getDouble(expiresAtKey) else {
            return nil
        }
        let expiresAt = Date(timeIntervalSince1970: expiresAtInterval)
        return AuthToken(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
    }

    func clear() {
        keychain.delete(accessTokenKey)
        keychain.delete(refreshTokenKey)
        keychain.delete(expiresAtKey)
    }

    func hasValidTokens() -> Bool {
        guard let token = load() else { return false }
        return token.expiresAt > Date() || !token.refreshToken.isEmpty
    }
}
```

### QR Code Generation with CoreImage
```swift
import CoreImage
import UIKit

func generateQRCode(from string: String, size: CGSize) -> UIImage? {
    let data = string.data(using: .utf8)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")

    let transform = CGAffineTransform(scaleX: size.width / filter.outputImage!.extent.size.width,
                                      y: size.height / filter.outputImage!.extent.size.height)
    let scaledImage = filter.outputImage!.transformed(by: transform)

    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Raw Keychain Services | KeychainSwift wrapper | 2010s+ | Much simpler, fewer crash bugs |
| Delegate-based URLSession | async/await URLSession | Swift 5.5+ (2021) | Cleaner code, fewer delegates |
| Multiple request refresh | Serialized actor-based refresh | Swift 5.5+ (2021) | Eliminates race conditions |

**Deprecated/outdated:**
- `TokenManager` with shared defaults: Use actor or `@MainActor` for isolation
- Third-party JSON parsing libraries: `Codable` handles all use cases needed here

## Open Questions

1. **Exact Douyin QR login endpoint URLs**
   - What we know: The general flow matches public documentation
   - What's unclear: The exact endpoint paths and parameter names need to be discovered through reverse engineering
   - Recommendation: Start with known patterns from open source Douyin API clients, adjust as needed

2. **Douyin API signature requirements**
   - What we know: Douyin requires certain headers like user-agent, cookies
   - What's unclear: Whether additional request signing is required for authenticated endpoints
   - Recommendation: Start with standard headers, investigate signature generation if requests are rejected

3. **Polling interval best balance**
   - What we know: Too frequent triggers rate limiting, too slow feels unresponsive
   - What's unclear: What Douyin allows without blocking
   - Recommendation: Start at 2.5 seconds (about 24 attempts in 60 seconds), configurable

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode | Build & run | ✓ | System | — |
| Swift Package Manager | KeychainSwift dependency | ✓ | System | CocoaPods |
| tvOS SDK | App compilation | ✓ | Xcode | — |

**Missing dependencies with no fallback:**
- None identified

**Missing dependencies with fallback:**
- None identified

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (built-in) |
| Config file | None (Xcode managed) |
| Quick run command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:DouyinLiveTVTests` |
| Full suite command | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AUTH-01 | QR code generation and login flow | Unit/Integration | `xcodebuild test ... -only-testing:DouyinLiveTVTests/AuthServiceTests` | ❌ Wave 0 |
| AUTH-02 | Keychain token storage encryption | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/TokenStorageTests` | ❌ Wave 0 |
| AUTH-03 | Persistence across app restarts | Integration | Test by manual app restart | ❌ Wave 0 |
| AUTH-04 | Automatic token refresh on expiry | Unit/Integration | `xcodebuild test ... -only-testing:DouyinLiveTVTests/TokenRefreshTests` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:DouyinLiveTVTests -xctestrun:onlyTesting'`
- **Per wave merge:** Full suite above
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Tests/DouyinLiveTVTests/TokenStorageTests.swift` — covers Keychain storage behavior
- [ ] `Tests/DouyinLiveTVTests/AuthServiceTests.swift` — covers login flow and token refresh
- [ ] `Tests/DouyinLiveTVTests/APIClientTests.swift` — covers API request handling
- [ ] Swift Package Manager dependencies for KeychainSwift need to be added to Xcode project

## Project Constraints (from CLAUDE.md)
No CLAUDE.md found, no additional project constraints.

## Sources

### Primary (HIGH confidence)
- KeychainSwift GitHub - https://github.com/evgenyneu/KeychainSwift - tvOS support, usage patterns
- Swift docs - `URLSession` async/await, `@MainActor` observable patterns

### Secondary (MEDIUM confidence)
- General industry patterns for automatic token refresh in Swift apps - multiple sources confirm the request interceptor + retry approach
- CoreImage QR generation - built-in to system, well-documented

### Tertiary (LOW confidence)
- Douyin QR login endpoint details - reverse engineering required based on known flow patterns

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - KeychainSwift is well-known, URLSession is standard
- Architecture: HIGH - Patterns are standard for Swift apps, actor-based concurrency prevents race conditions
- Pitfalls: MEDIUM - Keychain tvOS pitfalls well-known, Douyin-specific details not verified

**Research date:** 2026-03-30
**Valid until:** 30 days
