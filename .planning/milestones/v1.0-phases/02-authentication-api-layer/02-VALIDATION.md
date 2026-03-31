---
phase: 2
slug: authentication-api-layer
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-30
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (built-in) |
| **Config file** | none — Xcode managed |
| **Quick run command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:DouyinLiveTVTests` |
| **Full suite command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick test command on modified tests
- **After every plan wave:** Run the full suite command
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | AUTH-02 | unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/TokenStorageTests` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 1 | AUTH-01 | unit/integration | `xcodebuild test ... -only-testing:DouyinLiveTVTests/AuthServiceTests` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 1 | AUTH-04 | unit/integration | `xcodebuild test ... -only-testing:DouyinLiveTVTests/TokenRefreshTests` | ❌ W0 | ⬜ pending |
| 02-04-01 | 04 | 2 | AUTH-01/AUTH-03 | manual | N/A (app launch test) | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `DouyinLiveTVTests/TokenStorageTests.swift` — stubs for AUTH-02
- [ ] `DouyinLiveTVTests/AuthServiceTests.swift` — stubs for AUTH-01
- [ ] `DouyinLiveTVTests/TokenRefreshTests.swift` — stubs for AUTH-04
- [ ] `DouyinLiveTV.xcodeproj` — add KeychainSwift Swift Package Manager dependency

*Existing XCTest infrastructure already in project.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Session persists across app restarts | AUTH-03 | Requires actual app restart on device/simulator | 1. Launch app after successful login → verify authenticated state 2. Stop app completely in app switcher 3. Relaunch app → verify still authenticated 4. If still authenticated → passes |
| QR code displays correctly for scanning | AUTH-01 | Visual verification requires human eyes | 1. Navigate to login screen 2. Verify QR code appears centered 3. Verify mobile Douyin can scan it successfully |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
