# Domain Pitfalls: Douyin Live TV for tvOS

**Domain:** tvOS unofficial client for Douyin Live API
**Researched:** 2026-03-30

---

## Critical Pitfalls

Mistakes that cause complete blocks, app failure, or account issues.

### Pitfall 1: Douyin Account/IP Blocking from Unofficial API Access

**What goes wrong:** Douyin actively detects and blocks API requests from unofficial clients. This can result in:
- Temporary IP blocks (hours to days)
- Account restrictions or permanent bans
- Significantly increased rate limiting that makes the app unusable

**Why it happens:**
- Douyin uses fingerprinting to identify non-official clients
- Unusual request patterns (too frequent, wrong signature headers) trigger automated anti-bot systems
- Accessing the API from unfamiliar geolocations or IP ranges increases suspicion

**Consequences:** Complete app failure, potential loss of Douyin account access.

**Prevention:**
1. **Respect the 30-minute minimum refresh interval** as specified in requirements — never refresh more often
2. **Mimic official request headers exactly** — copy User-Agent, origin, referer from official mobile client
3. **Use the same network** as your regular Douyin mobile usage to avoid geolocation mismatch
4. **Implement exponential backoff** on 429/403 responses — stop requests for increasing periods
5. **Add random jitter** to refresh timing (±2-5 minutes) instead of fixed 30-minute intervals
6. **Route through your phone's hotspot** if you get IP-blocked — mobile IPs are less likely to be permanently banned

**Detection:** Check for 403 Forbidden or 429 Too Many Requests responses. Monitor for "anti_spam" or "verify" error codes in API responses.

---

### Pitfall 2: HLS Stream Playback Failure on tvOS due to CORS/Referer Checks

**What goes wrong:** Douyin HLS live stream URLs have hotlink protection that prevents playback on tvOS when accessed directly via AVPlayer. The stream fails to load with CORS errors or 403 Forbidden.

**Why it happens:**
- Douyin validates the `Referer` and `Origin` headers on HLS playlist and segment requests
- tvOS AVPlayer doesn't allow customizing headers for individual segment requests after playlist loading
- The playlist loads fine but subsequent segment requests get blocked

**Consequences:** Live video won't play, only statistics are visible — violates core product requirement.

**Prevention:**
1. **Proxy the HLS stream** through your own simple backend endpoint that:
   - Fetches the playlist with correct Douyin headers
   - Rewrites the segment URLs to go through your proxy
   - Adds proper headers to each segment request
2. If no backend, use a `URLProtocol` subclass to inject headers into all network requests made by AVPlayer
3. Test on actual Apple TV hardware, not just simulator — behavior differs

**Detection:** Playback stalls at loading, AVPlayer error `-1008` (network error) or `-12938` (invalid segment).

---

### Pitfall 3: tvOS Background Refresh Doesn't Work at 30-Minute Intervals

**What goes wrong:** The app requests automatic refresh every 30 minutes but tvOS doesn't honor this schedule. Background refresh is throttled heavily or doesn't happen at all.

**Why it happens:**
- tvOS automatically throttles background app refresh based on usage patterns
- tvOS limits background refresh to approximately 2-3 times per day maximum for infrequently used apps
- The system decides when to allow it — you can't force a 30-minute interval
- Background refresh is completely suspended when the Apple TV is idle/screensaver is on

**Consequences:** Automatic refresh fails, user doesn't get updated statistics.

**Prevention:**
1. **Don't rely on background refresh as a guarantee** — document that it's best-effort
2. Use `BackgroundAppRefresh` framework but expect it to be throttled
3. Provide prominent manual refresh button in UI for when automatic doesn't work
4. For a personal sideloaded app, consider using `BackgroundTasks` and ask the system for a refresh after 30 minutes — if it gets deferred, it will run the next time the app is foregrounded
5. Alternative: Use push notifications from a simple server to wake the app (requires Push Notifications capability, but still doesn't guarantee delivery on tvOS)

**Detection:** Background refresh task completion handler gets called with `deferred` or not called at all within expected window.

---

## Moderate Pitfalls

### Pitfall 1: Authentication Token Expiration and Session Death

**What goes wrong:** Douyin authentication tokens expire periodically (often within 1-24 hours). When they expire, the app stops working and requires re-login.

**Why it happens:**
- Douyin issues short-lived access tokens
- Refresh tokens may also expire if not used regularly
- Unofficial clients can't use the official OAuth flow to silently refresh

**Consequences:** App suddenly stops working until user manually re-logs in on the TV, which is cumbersome with the TV remote keyboard.

**Prevention:**
1. **Store both access token AND refresh token** in securely in Keychain
2. Proactively attempt to refresh the token before it expires (if using a refreshable token)
3. If refresh fails, post a local notification asking user to open the app and re-login
4. Cache the last known room ID and statistics locally so the app still displays something when token is invalid
5. Make login as easy as possible — support QR code scanning from phone that transfers credentials to TV

**Detection:** API returns 401 Unauthorized or "token invalid" error code.

---

### Pitfall 2: Anti-Scraping Signature Verification

**What goes wrong:** Douyin API endpoints require a dynamic signature (`msToken`, `x-bogus`, `X-Gorgon`, `X-Khronos` headers) that changes periodically. Without valid signatures, requests get blocked.

**Why it happens:**
- ByteDance implements dynamic signature validation to prevent API abuse
- The signature algorithm is obfuscated in the official app and changes with app updates
- Reverse-engineered signature solutions break after Douyin app updates

**Consequences:** All API requests get 403 Forbidden, app completely stops working until the signature algorithm is re-engineered.

**Prevention:**
1. **Use well-maintained open-source signature libraries** that the community keeps updated
2. Keep the signature generation logic separate from your app code to make updates easier
3. For a personal project, extract the current signature parameters from your own mobile client using mitmproxy and hardcode for your use case (less maintainable but simpler)
4. Monitor for breakage and be prepared to update when Douyin changes the algorithm

**Detection:** Consistent 403 responses even with valid token.

---

### Pitfall 3: Insecure Token Storage on tvOS

**What goes wrong:** Storing authentication tokens in `UserDefaults` or plain plists exposes them to potential extraction if the device is compromised.

**Why it happens:**
- Easy reach for `UserDefaults` but it's not encrypted
- tvOS doesn't have the same App Store sandboxing restrictions for sideloaded apps that are jailbroken

**Consequences:** Token could be stolen, potentially allowing account takeover.

**Prevention:**
- Always use `Security.framework` Keychain on tvOS for token storage
- Set `kSecAttrAccessibleWhenUnlocked` or appropriate accessibility constant
- Even for a personal sideloaded app, follow secure storage practices

---

## Minor Pitfalls

### Pitfall 1: Over-Engineering the Architecture

**What goes wrong:** Adding too many layers, complex dependency injection, or fancy architecture patterns for a small personal app.

**Why it happens:**
- Developers trained on large projects want to "do it right" even for small projects
- Temptation to use the latest frameworks and patterns regardless of need
- Over-preparing for future features that may never happen

**Consequences:**
- More boilerplate code to write and maintain
- Steeper learning curve if you come back to the project after 6 months
- Longer development time for what should be a simple app

**Prevention:**
- Keep it simple: MVVM with 4 layers (UI, ViewModel, Domain, Data) is enough
- Use manual dependency injection — no need for a DI container
- Don't add abstractions until you actually need them
- YAGNI: You Ain't Gonna Need It — if you don't need it now, don't add it

---

### Pitfall 2: HLS Bitrate Adaptation Issues on tvOS

**What goes wrong:** Douyin HLS streams use bitrate switching that can confuse AVPlayer on tvOS, causing frequent rebuffering.

**Prevention:**
- Create an AVPlayerItem with a preferred maximum bitrate matching your TV network capabilities
- Prefer the middle quality variant if possible to avoid constant adaptation
- Test on the actual network you'll use (Wi-Fi on Apple TV can be weaker than phone/desktop)

---

### Pitfall 3: HTTPS Certificate Pinning Mismatch

**What goes wrong:** If you proxy requests through a local mitmproxy for debugging, tvOS will reject the SSL certificate by default.

**Prevention:**
- For development, add appropriate App Transport Security exceptions in Info.plist
- For production, don't disable ATS — keep it enabled

---

### Pitfall 4: App Idle Sleep During Active Playback

**What goes wrong:** Apple TV goes to sleep during live stream playback if user doesn't interact.

**Prevention:**
- Use `UIApplication.shared.isIdleTimerDisabled = true` during active playback
- Re-enable when playback stops

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Project Setup | Over-engineering architecture with too many layers | Stick to simple MVVM, manual DI, YAGNI |
| Authentication | Token expiration causing repeated login | Implement refresh flow, cache last state |
| Authentication | Storing tokens in UserDefaults instead of Keychain | Always use Keychain for sensitive credentials |
| API Integration | Missing signature headers causing 403 | Start with known working signature generation from existing projects |
| Video Playback | CORS/referer blocking segments | Plan for proxying upfront, don't assume direct playback works |
| Background Refresh | 30-minute interval not honored by tvOS | Don't promise automatic refresh as guaranteed, make manual refresh prominent |
| Live Stream Management | Putting stream/polling logic in ViewModel | Use separate dedicated managers for stream and polling |
| App Store (if needed later) | Unofficial API usage gets rejected | Already out of scope (personal sideload only), no action needed |

---

## Risk Matrix

| Risk | Likelihood | Impact | Priority |
|------|------------|--------|----------|
| IP/Account blocking | High | Critical | P0 |
| HLS playback blocked | High | Critical | P0 |
| Background refresh not working | High | Moderate | P1 |
| Signature algorithm changes | Medium | Critical | P1 |
| Token expiration | High | Moderate | P1 |
| Insecure token storage | Low | High | P2 |
| Over-engineering | Medium | Low | P2 |

---

## Sources

- General tvOS background refresh behavior: LOW confidence (based on common iOS/tvOS knowledge, multiple community sources agree)
- Douyin anti-scraping measures: MEDIUM confidence (based on community reports from reverse engineering projects)
- HLS playback on tvOS: HIGH confidence (known AVPlayer behavior, documented by Apple)
- Keychain storage on tvOS: HIGH confidence (Apple documentation confirms)
- Token expiration: MEDIUM confidence (common pattern across Douyin/TikTok API reported by community)
- Architecture over-engineering: HIGH confidence (common pitfall on small personal projects)

---

## Open Questions Requiring Validation

1. Does Douyin actually block HLS segment requests based on Referer on live streams? Need to test with actual stream URL — *LOW confidence currently*
2. What is the actual current signature algorithm required for Douyin's public API? This changes regularly and will need to be validated when implementing — *LOW confidence*
3. How aggressive is tvOS background refresh throttling for sideloaded apps? Actual testing on specific hardware needed — *MEDIUM confidence currently*
