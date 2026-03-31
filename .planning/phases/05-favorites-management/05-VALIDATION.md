---
phase: 5
slug: favorites-management
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-31
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (native) |
| **Config file** | none — project already configured |
| **Quick run command** | `xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV' | xcpretty | grep -E '(TEST FAILED|TEST SUCCEEDED)'` |
| **Full suite command** | same as quick |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick tests
- **After every plan wave:** Run full suite
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | FAV-06 | unit | `xcodebuild test...` | ❌ W0 | ⬜ pending |
| 05-02-01 | 02 | 1 | FAV-01, FAV-06 | unit | `xcodebuild test...` | ❌ W0 | ⬜ pending |
| 05-03-01 | 03 | 2 | FAV-02, FAV-03, FAV-04, FAV-05 | integration | `xcodebuild test...` | ❌ W0 | ⬜ pending |
| 05-04-01 | 04 | 2 | FAV-05 | integration | `xcodebuild test...` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. The project already has XCTest infrastructure configured.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Add room via URL parsing | FAV-01 | UI interaction needs human validation of edge cases | Open app → Add → Enter different URL formats (raw ID, https://v.douyin.com/xxx, https://www.douyin.com/video/xxx, https://www.douyin.com/user/xxx/live) → Verify room added correctly |
| Delete favorite room | FAV-03 | tvOS focus and edit mode interaction best tested manually | Navigate to Favorites tab → Enter edit mode → Delete a room → Verify room removed from list |
| Last room auto-open on launch | FAV-05 | App startup behavior requires app restart test | Select a favorite room → Close app → Reopen app → Verify same room opens automatically |
| Persistence across restart | FAV-06 | Requires app restart to verify | Add room → Close app → Reopen → Verify room still in favorites list |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
