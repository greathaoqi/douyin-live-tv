---
phase: 04
slug: live-room-core-display
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-31
---

# Phase 04 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (Xcode default) |
| **Config file** | none — uses project default |
| **Quick run command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' -only-testing DouyinLiveTVTests/<test-class> | grep -E "(FAILED|PASSED|ERROR)"` |
| **Full suite command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)'` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick command with affected test class
- **After every plan wave:** Run full suite when possible
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | LIVE-01 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveStatsModelTests` | ❌ Wave 0 | ⬜ pending |
| 04-01-02 | 01 | 1 | LIVE-04 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomDisplayTests/testTextSizesMeetsRequirements` | ❌ Wave 0 | ⬜ pending |
| 04-01-03 | 01 | 1 | LIVE-05 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomDisplayTests/testStatusIndicatorColor` | ❌ Wave 0 | ⬜ pending |
| 04-02-01 | 02 | 1 | LIVE-06 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/LiveRoomViewModelTests/testToggleOverlayChangesState` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `DouyinLiveTVTests/LiveStatsModelTests.swift` — stubs for LIVE-01 model verification
- [ ] `DouyinLiveTVTests/LiveRoomViewModelTests.swift` — covers LIVE-06 view model behavior
- [ ] `DouyinLiveTVTests/LiveRoomDisplayTests.swift` — covers LIVE-04, LIVE-05 UI contract compliance

Existing tests: `FocusSizeConstraintsTests` already covers 88pt minimum requirement (from Phase 3)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Live video preview playback via AVPlayer | LIVE-02 | Requires actual tvOS device/simulator to test playback | Build and run, verify video plays |
| Stats overlay displayed on top of video | LIVE-03 | Visual verification needed | Visual check that overlay appears in top-left |
| Picture in Picture support | LIVE-07 | Requires actual tvOS hardware/simulator | Send app to background, verify PiP starts automatically |
| Large text sizing readable from couch | LIVE-04 | Visual distance verification | Verify 48pt values and 36pt labels are large enough |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
