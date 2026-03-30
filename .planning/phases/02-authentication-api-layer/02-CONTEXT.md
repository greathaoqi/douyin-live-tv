# Phase 2: Authentication & API Layer - Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement secure Douyin authentication with QR code login flow, persistent credential storage in Keychain, and an API client capable of making authenticated requests to Douyin endpoints. Handles automatic token refresh when credentials expire.

This phase delivers:
- QR code login screen where user scans with mobile Douyin app
- Secure token storage in Keychain
- Session persistence across app restarts
- Automatic token refresh
- API client for Douyin endpoints

Success criteria from roadmap:
1. User can log into Douyin via QR code flow
2. Authentication tokens stored encrypted in Keychain
3. Session persists across app restarts
4. Token refresh handled automatically when expired
5. API client can make authenticated requests to Douyin endpoints
</domain>

<decisions>
## Implementation Decisions

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
</decisions>

<specifics>
## Specific Ideas

- QR code login should match the standard Douyin TV/WEB login flow that users are already familiar with
- Keep it simple — this is a personal single-user app, no need for complex multi-user account switching
- Priority on simplicity over "enterprise-grade" architecture since only one person uses it
</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Requirements
- `.planning/PROJECT.md` — Overall project vision, constraints (tvOS only, personal use)
- `.planning/REQUIREMENTS.md` — AUTH-01 through AUTH-04 requirements for this phase

### Phase 1 (completed)
- `DouyinLiveTV/App/DependencyContainer.swift` — Existing dependency injection pattern
- `DouyinLiveTV/Domain/Models/` — Existing domain model patterns

No external specs beyond project requirements.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DependencyContainer` singleton — API client can be registered as a dependency here
- SwiftData already configured for model persistence (will be used by Phase 5 favorites)

### Established Patterns
- Manual plain Swift with SwiftUI — no third-party architecture frameworks
- Domain model classes with SwiftData `@Model` annotations

### Integration Points
- App entry point in `DouyinLiveTVApp.swift` needs to check authentication state on launch
- `ContentView` needs to route to either login screen or main UI based on auth state
</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>

---

*Phase: 02-authentication-api-layer*
*Context gathered: 2026-03-30 via discuss-phase*
