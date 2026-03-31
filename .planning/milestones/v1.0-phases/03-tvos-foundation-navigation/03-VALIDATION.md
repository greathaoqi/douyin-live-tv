---
phase: 3
slug: tvos-foundation-navigation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-31
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (native) |
| **Config file** | In project settings |
| **Quick run command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:DouyinLiveTVTests` |
| **Full suite command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run affected unit tests with quick run command
- **After every plan wave:** Run full unit test suite
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | UX-09 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/AppLifecycleTests` | ❌ W0 | ⬜ pending |
| 03-01-02 | 02 | 1 | UX-07 | Unit | `xcodebuild test ... -only-testing:DouyinLiveTVTests/FocusSizeConstraintsTests` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `DouyinLiveTVTests/AppLifecycleTests.swift` — tests lifecycle observation for UX-09
- [ ] `DouyinLiveTVTests/FocusSizeConstraintsTests.swift` — tests minimum 88x88pt sizing for UX-07
- [ ] UI Test target can be created later for UI-driven requirements (deferred)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Focus-based navigation with Siri Remote | UX-01 | Requires simulator/hardware interaction | Use direction pad/swipe to move focus between tabs and items - verify focus moves predictably |
| Standard Siri Remote gesture support | UX-02 | Requires hardware/simulator remote simulation | Test: swipe moves focus, click selects, Menu goes back, Play/Pause toggles video |
| Tab-based main navigation | UX-03 | UI behavior | Verify 3 tabs appear at top, can switch between tabs, selected tab indicates correctly |
| Parallax effect on focus | UX-04 | Visual effect | When focus moves to an item, verify the parallax 3D effect is visible |
| Dictation support | UX-05 | Requires text input field with Siri Remote | Tap text field, verify dictation button appears on Siri Remote |
| Safe area/overscan insets | UX-06 | Visual layout | Verify no content is cut off at edges of screen, respects safe area |
| Minimum 88x88pt focus targets | UX-07 | Can be measured manually | All focusable items are at least 88x88pt |
| Dark mode support | UX-08 | System-level integration | Change system appearance on Apple TV, verify app adapts correctly |
| App lifecycle transitions | UX-09 | Requires backgrounding | Background app, verify video pauses; foreground app, verify video can resume |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
