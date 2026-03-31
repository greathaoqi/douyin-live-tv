# External Integrations

**Analysis Date:** 2026-03-31

## APIs & External Services

**Authentication:**
- Douyin SSO API - QR code login flow and token refresh
  - Base URL: `https://sso.douyin.com`
  - Endpoints: `/get_qr_code`, `/check_qr_status`, `/refresh_token`
  - Implementation: `DouyinLiveTV/Data/Network/AuthService.swift`
  - Auth: Bearer token after authentication

**Live Stream Data:**
- Douyin Public API - Fetch live room statistics and stream URL
  - Base URL: `https://api.douyin.com`
  - Endpoint: `/live/room/stats`
  - Implementation: `DouyinLiveTV/Data/Services/LiveStatsService.swift`
  - Auth: Requires authenticated request with access token

## Data Storage

**Databases:**
- SwiftData (persistent storage) - Local storage for favorite live rooms
  - Model: `DouyinLiveTV/Domain/Models/LiveRoom.swift`
  - Uses native iCloud-capable persistence provided by system framework

**Keychain:**
- Apple Keychain - Secure storage for authentication tokens
  - Wrapper: KeychainSwift
  - Implementation: `DouyinLiveTV/Data/Keychain/TokenStorage.swift`

**File Storage:**
- Local filesystem only (managed by SwiftData and system)

**Caching:**
- None - No explicit caching layer beyond SwiftData persistence

## Authentication & Identity

**Auth Provider:**
- Douyin SSO (custom implementation)
  - Implementation: QR code flow with polling, access/refresh token pattern
  - Token storage: Keychain with `afterFirstUnlock` accessibility
  - Automatic token refresh on 401 responses
  - Location: `DouyinLiveTV/Data/Network/AuthService.swift`

## Monitoring & Observability

**Error Tracking:**
- None - No external error tracking service integrated

**Logs:**
- Uses default OS logging via Swift print/debug print

## CI/CD & Deployment

**Hosting:**
- Not detected - Deployment config not in repository

**CI Pipeline:**
- None - No CI/CD configuration detected

## Environment Configuration

**Required env vars:**
- None - All endpoints are hardcoded (configured in `DouyinLiveTV/Data/Network/DouyinAPIEndpoints.swift`)

**Secrets location:**
- All secrets stored in Apple Keychain at runtime

## Webhooks & Callbacks

**Incoming:**
- Deep linking via NSUserActivity - Top Shelf extension triggers opening specific room with roomId
  - Activity type: `com.douyinlivedtv.openRoom`
  - Handler: `DouyinLiveTV/App/DouyinLiveTVApp.swift`

**Outgoing:**
- None - No outgoing webhooks

---

*Integration audit: 2026-03-31*
